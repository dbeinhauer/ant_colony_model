### A Pluto.jl notebook ###
# v0.19.13

using Markdown
using InteractiveUtils

# ╔═╡ 977b71d0-9c95-11ed-3c8a-45665d8bb919
import Plots

# ╔═╡ a0d827a2-eee1-4b45-a12b-0f5c7ba7d937
import Statistics

# ╔═╡ 8690a8df-3b42-4148-93bd-d6c7a37bd553
begin
	rc(hex) = ((hex & 0xff0000) >> 16) / 255
	gc(hex) = ((hex & 0xff00) >> 8) / 255
	bc(hex) = (hex & 0xff) / 255
	hex2rgba(hex) = Plots.RGBA(rc(hex), gc(hex), bc(hex), 1.)
end

# ╔═╡ f20a15ba-5eeb-49d6-96bb-61904cbf0a3b
md"""
__Map objects__
"""

# ╔═╡ 2ee43943-7253-40ef-b05a-a1db2b6f7aac
begin
	OBSTACLE = -1
	FREE = 0
	NEST = 1
	FOOD = 2
	TRAP = 3
end

# ╔═╡ 01b88ac4-4a69-4259-8d46-16796ee9b3ea
md"""
__Ant orientations__

Each orientation is represented by the tuple which signifies all possible movements \
of the ant which is heading on the given position.

For example:
	(-1, 0) - first number means that ant can move to position which differs in first 
	coordinate by -1 (continue forward), second number means that ant can move to both
	neighboring position in second coordinate (turn left or right)
"""

# ╔═╡ b9b139f8-2672-4547-80e0-aadb0714c62f
begin
	NORTH = (0, -1)
	EAST = (1, 0)
	SOUTH = (0, 1)
	WEST = (-1, 0)
end

# ╔═╡ 06720cf4-e09d-4f14-901d-a4f2ab6e851c
md"""
__Parameters of the model__

"""

# ╔═╡ 4eb0710c-d432-4e6b-83ad-c1445f38d362
"All model parameters."
struct ModelParameters
	"How much pheromone level diminishes after one iteration (from interval (0, 1))."
	pheromone_fade_rate::Float64 # `f` from the model description
	"Maximal distance of the tile to check for searched object (food, nest)."
	search_depth::Integer # `d` from the model description
	"Amount of the pheromone placed by singe ant (from interval (0, 1))."
	ant_pheromone_power::Float64 # `p` from the model description
	"""
	Fraction of pheromone which stays on original position after one iteration, 
  	the rest will spread around the neigborhood (from interval (0, 1)).
	"""
	pheromone_difusion_rate::Float64 # `r` from the model description
	"Diminishes importance of pheromone level while choosing next step."
	normalization_parameter::Float64 # `c` from the model description 
end

# ╔═╡ ce28bd06-898a-45b5-a1e8-30e188be8888
"All model map informations."
struct Map
	"Layout of the map objects."
	map_objects::Matrix{Integer}
	"Coordinates of all nests in the map." 
	nest_coordinates::Vector{Tuple{UnitRange{Int64}, UnitRange{Int64}}}
	"Levels of food pheromone over the map."
	food_pheromones::Matrix{Float64}
	"Levels of nest pheromone over the map."
	nest_pheromones::Matrix{Float64}
end

# ╔═╡ 4ff5c174-ba68-493a-98c5-55196d7601f5
"All informations about ants."
struct Ants
	"Positions of all ants."
	positions::Vector{Tuple{Integer, Integer}}
	"Orientations of all ants."
	orientations::Vector{Tuple{Integer, Integer}}
	"Whether ant is searching for food `false` or going to nest `true`."
	going_home::Vector{Bool}
	"Sum of food inside the nest."
	nest_food::Base.RefValue{Int}
end

# ╔═╡ eec95f9a-ba0f-45e5-b90c-55433fa05df4
"""
	place_to_map!(map_array, coordinates, object_identifier)

Place `object_identifier` to `map_array` on given `coordinates`.
"""
function place_to_map!(
		map_array,
		coordinates,
		object_identifier,
	)
	
	for coordinate in coordinates
		map_array[coordinate...] .= object_identifier
	end
end

# ╔═╡ e2aa2184-b8ae-4f98-9b34-d9b4110b9095
"""
	create_map(<keyword arguments>)

Prepare map layout for the simulation.

# Atributes
- `grid_size=(100, 100)` 
- `food_coordinates=[(1:15, 1:20), (80:100, 85:95)]`
- `nest_coordinates=[(40:52, 50:62)]`
- `obstacle_coordinates=[(1:4, 10:11)]`


See also [`Map`]().
"""
function create_map(;
		grid_size = (100, 100), 
		food_coordinates = [(1:15, 1:20), (80:100, 85:95)],
		nest_coordinates = [(40:52, 50:62)],
		obstacle_coordinates = [(1:4, 10:11)],
	)
	map_objects = zeros(Integer, grid_size)

	place_to_map!(map_objects, food_coordinates, FOOD)
	place_to_map!(map_objects, nest_coordinates, NEST)
	place_to_map!(map_objects, obstacle_coordinates, OBSTACLE)

	return Map(map_objects, 
				nest_coordinates,
				zeros(Float64, grid_size),
				zeros(Float64, grid_size),
			)
end

# ╔═╡ 7566c3af-517c-453a-9b68-b3bac7a124ac
"""
	init_ants(nest_coordinates, num_ants)

Initialize `Ants` object with randomly generated `num_ants` ants on
`nest_coordinates`.


See also [`Ants`]().
"""
function init_ants(
		nest_coordinates,
		num_ants,
		)

	return Ants(
			[(rand(i[1]), rand(i[2])) for i in rand(nest_coordinates, num_ants)],
			rand([NORTH, EAST, SOUTH, WEST], num_ants),
			zeros(Bool, num_ants),
			Ref(0)
		)
end

# ╔═╡ 8242293f-3195-4b65-8fe2-dde03ac72a76
md"""
__Loop of the simulation__
* updates pheromone values
* updates performs next action of the ant
"""

# ╔═╡ a0024991-f93d-463c-9001-3f3c22528b9b
"""
	get_neighborhood(matrix, coordinates, neighborhood_size=1)

Obtain set of at most `neighborhood_size` distant values from `matrix`
on `coordinates` (including value on `coordinates` itself).
"""
function get_neighborhood(
		matrix,
		coordinates;
		neighborhood_size = 1,
	)
	
	return [matrix[i, j]
		for i in max(1, coordinates[1] - neighborhood_size):
			min(size(matrix)[1], coordinates[1] + neighborhood_size)
		for j in max(1, coordinates[2] - neighborhood_size):
			min(size(matrix)[2], coordinates[2] + neighborhood_size)
		]
end

# ╔═╡ 4f876c82-6c94-4b92-93f6-77e6814e4402
"""
	simulation_step_pheromones!(simulation_map, model_parameters)

Perform one step of pheromone spreading.

Fade pheromone with the following rule:
```
	new_pheromone_value = old_pheromone_value - fade_rate
```

Difuse pheromone based on the old pheromone value and its surounding with the following rule:
```
	new_pheromone_value = 
		difusion_rate * old_pheromone_value + 
		(1 - difusion_rate) * mean_of_the_neighborhood_pheromones
```
"""
function simulation_step_pheromones!(
		simulation_map::Map,
		model_parameters::ModelParameters,
	)
	
	map_2d_indices = CartesianIndices(simulation_map.food_pheromones)

	# display(map_2d_indices)

	# Pheromone rules:
	pheromone_fade(x) = 
		x < model_parameters.pheromone_fade_rate ? 
			0 : x - model_parameters.pheromone_fade_rate
	
	# Lets fragment of the pheromone on original position and the rest difuses.
	pheromone_difusion(grid) = 
		reshape(
			[simulation_map.map_objects[map_2d_indices[iter]] == OBSTACLE ? 		
				# Obstacle -> pheromone level is always zero.
				0 :
				# Not obstacle -> difuse pheromone.
				model_parameters.pheromone_difusion_rate * 
					grid[map_2d_indices[iter]] + 
				(1-model_parameters.pheromone_difusion_rate) * 
					Statistics.mean(get_neighborhood(grid, map_2d_indices[iter])) 
			for iter in	eachindex(grid)
			], 
			size(grid)
		)

	
	# Update pheromones (fade and difusion):
	simulation_map.food_pheromones .= 
		pheromone_fade.(simulation_map.food_pheromones)
	simulation_map.nest_pheromones .= 
		pheromone_fade.(simulation_map.nest_pheromones)

	simulation_map.food_pheromones .=
		pheromone_difusion(simulation_map.food_pheromones)
	simulation_map.nest_pheromones .=	
		pheromone_difusion(simulation_map.nest_pheromones)
end

# ╔═╡ f6d52ec9-5ef5-462d-8cf0-1f6144148493
"""
	check_object_forward(position,
						orientation,
						searched_object,
						searched_map,
						search_depth,
					)

Based on `orientation` and `position` searches for `searched_object` on 
`searched_map` in maximum distance `search_depth`.


Checks whether `searched_object` is placed in the forward direction from the given
position and whether it is not hidden under `OBSTACLE`.
"""
function check_object_forward(
		position,
		orientation,
		searched_object,
		searched_map,
		search_depth,
	)
	
	for i in 1:search_depth
		new_x = position[1] + i * orientation[1]
		new_y = position[2] + i * orientation[2]

		
		# Check map borders:
		if new_x < 1 || 
			new_y < 1 || 
			new_x > size(searched_map)[1] ||
			new_y > size(searched_map)[2]
			# Coordinates outside the map borders -> searched object not found
			return false
		else
			# Coordinates inside the map.
			if searched_map[new_x, new_y] == OBSTACLE
				# Obstacle in the front direction -> searched object not found
				return false
			elseif searched_map[new_x, new_y] == searched_object
				# Seached object found.
				return true
			end
		end
	end

	# Seached object not found.
	return false
end

# ╔═╡ cab3bbd9-c1dd-4f4a-94ce-612f52a7e7c8
"""
	turn_orientation(orient, to_left)

Return orientation after turn from `orient` to left or right based on `to_left`.
"""
function turn_orientation(orient, to_left)
	if orient == NORTH
		return to_left ? EAST : WEST
	elseif orient == EAST
		return to_left ?  SOUTH :  NORTH
	elseif orient == SOUTH
		return to_left ?  WEST :  EAST
	elseif orient == WEST
		return to_left ?  NORTH :  SOUTH
	end
end

# ╔═╡ e5caecdb-6a66-458a-b8b8-37d0ab442aa5
"""
	get_rigit_move(coord, orientation, returning, simulation_map, model_parameters)

Find possible rigit move on `coord` with `orientation` based whether ant is
`returning` to nest on `simulation_map` with `model_parameters`.

Searches to left, forward and to right for either the `FOOD` or `NEST` 
based on `returning`. If searched object is found returns new coordinates 
of the ant heading towards item which was found the first (else `nothing`).


See also [`check_object_forward`]().
"""
function get_rigit_move(
		coord,
		orientation, 
		returning::Bool,
		simulation_map::Map,
		model_parameters::ModelParameters,
	)

	# Check searched object in 3 directions (left, forward, right).
	for orient in 
		[turn_orientation(orientation, true), # left
			orientation, # forward
			turn_orientation(orientation, false), # right 
		]

		if check_object_forward(
				coord,
				orientation, 
				returning ? NEST : FOOD, 
				simulation_map.map_objects, 
				model_parameters.search_depth
			)
			return [(coord[1] + orientation[1], coord[2] + orientation[2])]	
		end
	end

	# No searched item found.
	return nothing
end

# ╔═╡ b48bc8f7-7577-41b2-b611-426e394436fb
"""
	get_possible_moves(coordinates, orientation, map_objects)

Return set of all possible moves on the `coordinates` with `orientation` on map 
with `map_objects`.
"""
function get_possible_moves(
		coordinates,
		orientation,
		map_objects
	)

	first_coord = coordinates[1]
	second_coord = coordinates[2]
	all_moves = []

	# Changes 2D coordinates on the specified position (specified by `i`).
	set_coord(i, how) = 
		i == 1 ? (first_coord + how, second_coord) : (first_coord, second_coord + how)

	# Checks whether position if valid for ant movent 
	# 	-> if so adds it to the set of all possible movements.
	check_obstacle(coord) = 
		map_objects[coord[1], coord[2]] == OBSTACLE ?
			nothing : push!(all_moves, coord)

	# Finds all possible movements.
	for i in 1:2
		if orientation[i] == 0
		# Possible movement in two directions in the given coordinate.
			
			# Eliminate map borders.
			coordinates[i] == 1 ? 
				 nothing : check_obstacle(set_coord(i, -1))
			coordinates[i] == size(map_objects)[i] ? 
				 nothing : check_obstacle(set_coord(i, 1))
		else
		# Movement possible only in one direction in given coordinate.

			# Eliminate map borders.
			new_coord = set_coord(i, orientation[i])
			new_coord[i] < 1 || new_coord[i] > size(map_objects)[i] ? 
				nothing : check_obstacle(new_coord)
		end
	end

	return all_moves
end

# ╔═╡ d7bf15ca-58fa-4e9b-af6e-bcc30a5b5631
"""
	randomly_choose_move(possible_moves, pheromone_map, normalization_parameter)

Randomly select move from `possible_moves` based on pheromone levels 
from `pheromone_map` and `normalization_parameter`.

Move from the set is randomly selected from the weighted distribution where
weights are pheromone levels. Weights are also increased by the 
`normalization_parameter` which diminishes differences the importance of 
pheromone level (moves distribution toward uniform distribution).
"""
function randomly_choose_move(
		possible_moves,
		pheromone_map,
		normalization_parameter
	)

	# Randomly sample item from weighted distribution.
	sample(items, weights) = items[findfirst(cumsum(weights) .> rand())]

	# Find weights of each move and normalise them.
	weights = [pheromone_map[coord[1], coord[2]]  + normalization_parameter 
			for coord in possible_moves
			]
	weights ./= sum(weights)

	# Choose move based on the weights.
	return sum(weights) > 0 ?
			sample(possible_moves, weights) :
			possible_moves[rand(1:size(possible_moves)[1])]
end

# ╔═╡ c2c81457-e0d7-44e6-8cdb-17121ad3ccaa
"""
	ants_movement!(simulation_map, ants, model_parameter)

Perform one step of the simulation of ants movement.

Ant can move only in 3 directions (left, towards and right). The choice of 
the direction is random and depends on the amount of the corresponding pheromone 
level on the possible positions. If the food (resp. nest) is nearby, then ant 
always moves towards the food (resp. nest). If no movement possible the ant 
randomly turns in place.


See also [`get_rigit_move`]() and [`get_possible_moves`]().
"""
function ants_movement!(
		simulation_map::Map,
		ants::Ants,
		model_parameters::ModelParameters,
	)

	# Value symbolising that position is not valid.
	NO_POSSIBLE_MOVE = (0, 0)


	# Choose next move of the ant (if no possible -> randomly_turns).
	choose_move(possible_moves, going_home) = 
		isempty(possible_moves) ? 
			NO_POSSIBLE_MOVE :
			randomly_choose_move(
				possible_moves, 
				going_home ? 
					simulation_map.nest_pheromones : 
					simulation_map.food_pheromones,
				model_parameters.normalization_parameter
			)

	# Determines the new orientation of the ant after the move.
	determine_new_orientation(old_orientation, old_coord, new_coord) = 
		new_coord == NO_POSSIBLE_MOVE ? 
			turn_orientation(old_orientation, rand() < 0.5) :
			filter(x -> x == new_coord .- old_coord, [NORTH, EAST, SOUTH, WEST])[1]
	
	# Sets positions of the ants which cann't move at any neighbor position. 
	treat_no_possible_move(new, original) = 
		new == NO_POSSIBLE_MOVE ? original : new

	
	# All rigit moves (towards the searched object)
	rigit_moves = 
		[get_rigit_move(coord,
							orient,
							returning,
							simulation_map,
							model_parameters
						) 
		for (coord, orient, returning) in zip(ants.positions,
											ants.orientations,
											ants.going_home)
		]


	# All possible moves of all ants.
	all_possible_moves = 
		[isnothing(rigit_move) ?
			get_possible_moves(coord, orient, simulation_map.map_objects) :
			rigit_move
	 	for (rigit_move, coord, orient, returning) in zip(rigit_moves,
																ants.positions,
																ants.orientations,
																ants.going_home)
		]

	# New positions of the ants.
	new_positions = 
		[choose_move(possible, going_home) 
			for (possible, going_home) in zip(all_possible_moves, ants.going_home)
		]


	# Update orientations and positions of the ants:
	map!(determine_new_orientation,
		ants.orientations,
		ants.orientations, ants.positions, new_positions
	)
	
	map!(treat_no_possible_move,
		ants.positions,
		new_positions, ants.positions
	)
end

# ╔═╡ 04ddea98-1582-47db-bc06-634dc28cf313
"""
	ants_food_managment!(simulation_map, ants)

Check for food un/load for each ant from `ants` on `simulation_map`.
"""
function ants_food_managment!(
		simulation_map,
		ants::Ants
	)

	# If possible -> take the food, return new `returning` status.
	check_food(coord, returning) =
		simulation_map.map_objects[coord[1], coord[2]] == FOOD && !returning ?
			begin
				simulation_map.map_objects[coord[1], coord[2]] = FREE
				!returning
			end : returning

	# If possible -> unload food.
	check_home(coord, returning) =
		simulation_map.map_objects[coord[1], coord[2]] == NEST && returning ?
			begin
				ants.nest_food[] += 1
				!returning
			end : returning


	# Update food carriage.
	map!(check_food,
		ants.going_home,
		ants.positions, ants.going_home)
	
	map!(check_home,
		ants.going_home,
		ants.positions, ants.going_home)
end

# ╔═╡ 7813d6fe-94ca-4278-9d6f-6d31a19eb765
"""
	simulation_step_ants!(simulation_map, ants, model_parameters)

Perform one step of ant behaviour.

1. If possible take food or unload it in the nest.
2. Move to new position.
3. Place there pheromone.


See also [`ants_food_managment!`]() and [`ants_movement!`]().
"""
function simulation_step_ants!(
		simulation_map::Map,
		ants::Ants,
		model_parameters::ModelParameters,
	)

	MAX_PHEROMONE_LEVEL = 1
	
	# Place pheromone on given coordinates.
	# Based on the returning status decides which pheromone place. Then increases pheromone level on the position (if pheromone concentration is not maximal).
	place_pheromone(coord, returning) =
		# Decide which pheromone place.
		returning ?
			# Going home:
			(# Check maximal pheromone level.
			simulation_map.food_pheromones[coord...] +
				model_parameters.ant_pheromone_power > MAX_PHEROMONE_LEVEL ? 
					simulation_map.food_pheromones[coord...] = 
						MAX_PHEROMONE_LEVEL :
					simulation_map.food_pheromones[coord...] +=
						model_parameters.ant_pheromone_power
			) :
			# Finding food:
			(# Check maximal pheromone level.
			simulation_map.food_pheromones[coord...] +
				model_parameters.ant_pheromone_power > MAX_PHEROMONE_LEVEL ? 
					simulation_map.nest_pheromones[coord...] = 
						MAX_PHEROMONE_LEVEL :
					simulation_map.nest_pheromones[coord...] +=
						model_parameters.ant_pheromone_power
			)
	

	# All operations of the ants.
	ants_food_managment!(simulation_map, ants)
	ants_movement!(simulation_map, ants, model_parameters)
	place_pheromone.(ants.positions, ants.going_home)
	
end

# ╔═╡ e9451707-1c67-494f-813f-2b45ec7675c7
"""
	simulation_step!(simulation_map, ants, model_parameters)

Perform one step of the simulation.

Update the pheromone levels and simulate next step of the ants.


See also [`simulation_step_pheromones!`]() and [`simulation_step_ants!`]().
"""
function simulation_step!(
		simulation_map::Map,
		ants::Ants,
		model_parameters::ModelParameters,
	)
	
	simulation_step_pheromones!(simulation_map, model_parameters)
	simulation_step_ants!(simulation_map, ants, model_parameters)
end

# ╔═╡ 18b60e48-767f-4b52-aad9-322268af9931
begin
	PHEROMONE_ANIM = 0
	ONLY_PHEROMONE_ANIM = 1
	ANTS_ANIM = 2
	ONLY_ANTS_ANIM = 3
	PHEROMONE_ANTS_ANIM = 4
end

# ╔═╡ a93d44f2-a1d8-4389-8151-3b040b0873a0
"""
	choose_animation(simulation_map, 
					ants, 
					animation_type=PHEROMONE_ANIM, 
					color_normalization=1
				)

Set proper animation frame of the current state of `simulation_map` and `ants`.

# Arguments
- `animation_type=PHEROMONE_ANIM`: animation type switch (possible options: `PHEROMONE_ANIM` - animate pheromone levels with map objects, `ONLY_PHEROMONE_ANIM` - animate only pheromone levels, `ANTS_ANIM` - animate ants with map objects, `ONLY_ANTS_ANIM` - animate only ants, `PHEROMONE_ANTS_ANIM` - animate both pheromone and ants)
- `color_normalization=1`: parameter to adjust color intensity of the pheromone
"""
function choose_animation(
		simulation_map::Map,
		ants::Ants; 
		animation_type = PHEROMONE_ANIM,
		color_normalization = 1,
	)
	
	# Colors of the objects on the map.
	map_objects_colors = Dict(
		OBSTACLE => hex2rgba(0xFF00F0),
		FREE => hex2rgba(0x000000),
		NEST => hex2rgba(0xFF4500),
		FOOD => hex2rgba(0x7A871E),
		TRAP => hex2rgba(0x159874)
	)

	# Pheromone colors
	FOOD_PHER_COLOR = (250, 0, 0)
	NEST_PHER_COLOR = (0, 250, 0)

	# Create RGBA color based on the RGB and alpha values.
	set_color(rgb, alpha) = Plots.RGBA(rgb[1], rgb[2], rgb[3], alpha)

	# Sets color based on the pheromones concentrations. 
	set_pheromone_color(food_pheromone, nest_pheromone) =
		(set_color(FOOD_PHER_COLOR .* food_pheromone .+ 
				NEST_PHER_COLOR .* nest_pheromone, 
			#max(food_pheromone, nest_pheromone)^color_normalization
			((food_pheromone + nest_pheromone) / 2)^color_normalization
			)
		)
		
	# Function to determine color of the pixel based on the map object and pheromones.
	color_map_objects_pheromones(object, food_pheromone, nest_pheromone) = 
		(food_pheromone == 0 && nest_pheromone == 0 ) ||
		(object != FREE) ?
			map_objects_colors[object] : 
			set_pheromone_color(food_pheromone, nest_pheromone)

	
	result_colors = nothing
	
	if animation_type == PHEROMONE_ANIM
		result_colors = map(color_map_objects_pheromones, 
				simulation_map.map_objects, 
				simulation_map.food_pheromones, 
				simulation_map.nest_pheromones
			)
	elseif animation_type == ANTS_ANIM
		result_colors = 
			map(s -> map_objects_colors[s], simulation_map.map_objects)
		for (coord, returning) in zip(ants.positions, ants.going_home)
			result_colors[coord[1], coord[2]] = returning ? 
				set_color(FOOD_PHER_COLOR, 1.0) :
				set_color(NEST_PHER_COLOR, 1.0)
		end
	elseif animation_type == ONLY_PHEROMONE_ANIM
		result_colors = 
			map(set_pheromone_color, 
				simulation_map.food_pheromones, simulation_map.nest_pheromones)
	elseif animation_type == ONLY_ANTS_ANIM
		result_colors = map(s -> Plots.RGBA(0, 0, 0, 0.0), simulation_map.map_objects)
		for (coord, returning) in zip(ants.positions, ants.going_home)
			result_colors[coord[1], coord[2]] = returning ? 
				set_color(FOOD_PHER_COLOR, 1.0) :
				set_color(NEST_PHER_COLOR, 1.0)
		end
	elseif animation_type == PHEROMONE_ANTS_ANIM
		result_colors = map(color_map_objects_pheromones, 
				simulation_map.map_objects, 
				simulation_map.food_pheromones, 
				simulation_map.nest_pheromones
			)
		for (coord, returning) in zip(ants.positions, ants.going_home)
			result_colors[coord[1], coord[2]] = returning ? 
				set_color(FOOD_PHER_COLOR, 1.0) :
				set_color(NEST_PHER_COLOR, 1.0)
		end
	end

	return result_colors
end

# ╔═╡ 9fd64400-6b98-4e6d-b682-624b1a2fc543
md"""
__Initization of the simulation__
Creates simulation objects based on the given parameters.
"""

# ╔═╡ 8bcca12c-8a17-4296-9a46-40d277fc504f
"""
	init_simulation(<keyword arguments>)

Initialize the simulation.

# Arguments:
- `grid_size=(100, 100)`
- `food_coordinates=[(1:15, 1:20), (80:100, 85:95)]`
- `nest_coordinates=[(45:52, 55:62)]`
- `obstacle_coordinates=[]`
- `num_ants=400`
- `pheromone_fade_rate=0.00021`
- `search_depth=10`
- `pheromone_power=0.02`
- `difusion_rate=0.495`
- `normalization_parameter=0.0005`


See also [`Map`](), [`Ants`](), [`ModelParameters`](), [`create_map`]() 
and [`init_ants`]().
"""
function init_simulation(;
		grid_size = (100, 100),
		food_coordinates = [(1:15, 1:20), (80:100, 85:95)],
		nest_coordinates = [(45:52, 55:62)],
		obstacle_coordinates = [],
		num_ants = 400,
		pheromone_fade_rate = 0.00021,
		search_depth = 10,
		pheromone_power = 0.02,
		difusion_rate = 0.495,
		normalization_parameter = 0.0005,
	)

	simulation_map = 
		create_map(grid_size=grid_size, 
			food_coordinates=food_coordinates, 
			nest_coordinates=nest_coordinates, obstacle_coordinates=obstacle_coordinates
		)
	
	model_parameters = 
		ModelParameters(pheromone_fade_rate, 
			search_depth, 
			pheromone_power, 
			difusion_rate, 
			normalization_parameter)
	
	# food_counter = 0

	ants = init_ants(simulation_map.nest_coordinates, num_ants)

	return simulation_map, ants, model_parameters	
end

# ╔═╡ 9d048ca0-a9b0-4e06-a3a0-96cb30fb430d
md"""
__Simulation run__

Runs all steps of the simulation and draws animation of the simulation.
"""

# ╔═╡ 756e733e-a2d9-44cb-aad3-1a89706e6075
"""
	sim!(simulation_map, ants, model_parameters; <keyword arguments>)

Simulate the model with `simulation_map`, `ants` and `model_parameters`.

# Arguments:
- `simulation_map::Map`
- `ants::Ants`
- `model_parameters::ModelParameters`
- `num_iterations=1000`
- `animate=true`
- `animation_type=PHEROMONE_ANIM`
- `draw_each=10`
- `color_normalization=1`
- `gif_fps=10`
- `filename=nothing`


See also [`simulation_step!`]() and [`choose_animation`]().
"""
function sim!(
		simulation_map::Map,
		ants::Ants,
		model_parameters::ModelParameters;
		num_iterations = 1000,
		animate = true,
		animation_type = PHEROMONE_ANIM,
		draw_each = 10,
		color_normalization = 1,
		gif_fps = 10,
		filename = nothing,
	)


	# Init plot (just black picture):
	p = Plots.plot(map(s -> Plots.RGBA(0, 0, 0, 0.0), simulation_map.map_objects),
		background_color=:black,
		#foreground_color=:black,
		)

	if animate
		# Run simulation and draw 
		animation = Plots.@animate for i in 1:num_iterations
			
			simulation_step!(simulation_map, ants, model_parameters)
	
			p[1][1][:z] = choose_animation(simulation_map, ants, animation_type=animation_type)
			Plots.title!("FOOD COUNTER: " * string(ants.nest_food[]))
			
		end every draw_each
	
		isnothing(filename) ? 
			Plots.gif(animation, fps=gif_fps) :
			Plots.gif(animation, filename, fps=gif_fps)

	else
		for i in 1:num_iterations
			simulation_step!(simulation_map, ants, model_parameters)
		end
		return ants.nest_food[]
	end

	# return ants.nest_food[]
end

# ╔═╡ 95959428-ee7f-4557-a84a-0e2f82f9d27c
# begin
# 	sim!(init_simulation(
# 				grid_size = (100, 100),
# 				food_coordinates = [(1:15, 1:20), (80:100, 85:95)],
# 				nest_coordinates = [(45:52, 55:62)],
# 				obstacle_coordinates = [(1:7, 25:26), (9:18, 25:26), (18:19, 1:25),
# 				(75:100, 80:80), (75:75, 80:93)],
# 				# num_ants = 400,
# 				pheromone_fade_rate = 0.0005,
# 				search_depth = 20,
# 				pheromone_power = 0.02,
# 				difusion_rate = 0.7,
# 				normalization_parameter = 0.0001,
# 			)..., 
# 			num_iterations=4000, 
# 			animation_type=PHEROMONE_ANIM,
# 			animate=true,
# 			color_normalization = 0.01,
# 		)
# end

# ╔═╡ f9a3c633-a4d3-4368-88a9-06ae7e4eaba3
# begin
# 	sim!(init_simulation()...,
# 			num_iterations=1000,
# 			animation_type=PHEROMONE_ANIM,
# 		)
# end

# ╔═╡ 67065f32-9c47-4010-ab92-7f7e45f66a6f
# begin
# 	sim!(init_simulation()..., 
# 			num_iterations=2000,
# 			animation_type = PHEROMONE_ANTS_ANIM,
# 		)
# end

# ╔═╡ 38e68fae-0200-4c9c-9f3a-df44d0b1bf36
# begin
# 	sim!(init_simulation(grid_size = (50, 50),
# 				food_coordinates = [(1:10, 1:13), (44:50, 1:10)],
# 				nest_coordinates =  [(10:15, 40:45)],
# 				obstacle_coordinates = [],
# 				num_ants = 400,
# 				num_iterations = 1000,
# 				pheromone_fade_rate = 0.0005,
# 				search_depth = 20,
# 				pheromone_power = 0.02,
# 				difusion_rate = 0.3,
# 				normalization_parameter = 0.0001
# 			)..., 
# 			num_iterations=1000, 
# 			animation_type=PHEROMONE_ANIM
# 		)
# end

# ╔═╡ f23ed720-e268-446a-9226-a4bd3f306cab
# begin
# 	sim!(init_simulation(#grid_size = (50, 50),
# 				# food_coordinates = [(1:10, 1:13), (44:50, 1:10)],
# 				# nest_coordinates =  [(10:15, 40:45)],
# 				# obstacle_coordinates = [],
# 				# num_ants = 400,
# 				num_iterations = 1000,
# 				pheromone_fade_rate = 0.0005,
# 				search_depth = 20,
# 				pheromone_power = 0.02,
# 				difusion_rate = 0.7,
# 				normalization_parameter = 0.0001,
# 			)..., 
# 			num_iterations=1000, 
# 			animation_type=PHEROMONE_ANIM,
# 			animate=true,
# 			color_normalization = 0.01,
# 		)
# end

# ╔═╡ af047c9d-7dfe-48f5-aa22-179b8ac34cb9
# begin
# 	sim!(init_simulation()..., animate=false)
# end

# ╔═╡ 34aeec52-136a-43ed-b6f6-c1242a386744
# begin
# 	# Parameters testing
# 	difusion_rates = 0:0.1:1;
	
# 	for difusion in difusion_rates
# 		println(sim!(init_simulation(
# 			difusion_rate = difusion,
# 				)...,
# 				animate = false,
# 			)
# 		)
# 	end
# end

# ╔═╡ 00000000-0000-0000-0000-000000000001
PLUTO_PROJECT_TOML_CONTENTS = """
[deps]
Plots = "91a5bcdd-55d7-5caf-9e0b-520d859cae80"
Statistics = "10745b16-79ce-11e8-11f9-7d13ad32a3b2"

[compat]
Plots = "~1.38.3"
"""

# ╔═╡ 00000000-0000-0000-0000-000000000002
PLUTO_MANIFEST_TOML_CONTENTS = """
# This file is machine-generated - editing it directly is not advised

[[ArgTools]]
uuid = "0dad84c5-d112-42e6-8d28-ef12dabb789f"

[[Artifacts]]
uuid = "56f22d72-fd6d-98f1-02f0-08ddc0907c33"

[[Base64]]
uuid = "2a0f44e3-6c83-55bd-87e4-b1978d98bd5f"

[[BitFlags]]
git-tree-sha1 = "43b1a4a8f797c1cddadf60499a8a077d4af2cd2d"
uuid = "d1d4a3ce-64b1-5f1a-9ba4-7e7e69966f35"
version = "0.1.7"

[[Bzip2_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "19a35467a82e236ff51bc17a3a44b69ef35185a2"
uuid = "6e34b625-4abd-537c-b88f-471c36dfa7a0"
version = "1.0.8+0"

[[Cairo_jll]]
deps = ["Artifacts", "Bzip2_jll", "CompilerSupportLibraries_jll", "Fontconfig_jll", "FreeType2_jll", "Glib_jll", "JLLWrappers", "LZO_jll", "Libdl", "Pixman_jll", "Pkg", "Xorg_libXext_jll", "Xorg_libXrender_jll", "Zlib_jll", "libpng_jll"]
git-tree-sha1 = "4b859a208b2397a7a623a03449e4636bdb17bcf2"
uuid = "83423d85-b0ee-5818-9007-b63ccbeb887a"
version = "1.16.1+1"

[[ChainRulesCore]]
deps = ["Compat", "LinearAlgebra", "SparseArrays"]
git-tree-sha1 = "c6d890a52d2c4d55d326439580c3b8d0875a77d9"
uuid = "d360d2e6-b24c-11e9-a2a3-2a2ae2dbcce4"
version = "1.15.7"

[[ChangesOfVariables]]
deps = ["ChainRulesCore", "LinearAlgebra", "Test"]
git-tree-sha1 = "844b061c104c408b24537482469400af6075aae4"
uuid = "9e997f8a-9a97-42d5-a9f1-ce6bfc15e2c0"
version = "0.1.5"

[[CodecZlib]]
deps = ["TranscodingStreams", "Zlib_jll"]
git-tree-sha1 = "9c209fb7536406834aa938fb149964b985de6c83"
uuid = "944b1d66-785c-5afd-91f1-9de20f533193"
version = "0.7.1"

[[ColorSchemes]]
deps = ["ColorTypes", "ColorVectorSpace", "Colors", "FixedPointNumbers", "Random", "SnoopPrecompile"]
git-tree-sha1 = "aa3edc8f8dea6cbfa176ee12f7c2fc82f0608ed3"
uuid = "35d6a980-a343-548e-a6ea-1d62b119f2f4"
version = "3.20.0"

[[ColorTypes]]
deps = ["FixedPointNumbers", "Random"]
git-tree-sha1 = "eb7f0f8307f71fac7c606984ea5fb2817275d6e4"
uuid = "3da002f7-5984-5a60-b8a6-cbb66c0b333f"
version = "0.11.4"

[[ColorVectorSpace]]
deps = ["ColorTypes", "FixedPointNumbers", "LinearAlgebra", "SpecialFunctions", "Statistics", "TensorCore"]
git-tree-sha1 = "600cc5508d66b78aae350f7accdb58763ac18589"
uuid = "c3611d14-8923-5661-9e6a-0046d554d3a4"
version = "0.9.10"

[[Colors]]
deps = ["ColorTypes", "FixedPointNumbers", "Reexport"]
git-tree-sha1 = "fc08e5930ee9a4e03f84bfb5211cb54e7769758a"
uuid = "5ae59095-9a9b-59fe-a467-6f913c188581"
version = "0.12.10"

[[Compat]]
deps = ["Dates", "LinearAlgebra", "UUIDs"]
git-tree-sha1 = "00a2cccc7f098ff3b66806862d275ca3db9e6e5a"
uuid = "34da2185-b29b-5c13-b0c7-acf172513d20"
version = "4.5.0"

[[CompilerSupportLibraries_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "e66e0078-7015-5450-92f7-15fbd957f2ae"

[[Contour]]
git-tree-sha1 = "d05d9e7b7aedff4e5b51a029dced05cfb6125781"
uuid = "d38c429a-6771-53c6-b99e-75d170b6e991"
version = "0.6.2"

[[DataAPI]]
git-tree-sha1 = "e8119c1a33d267e16108be441a287a6981ba1630"
uuid = "9a962f9c-6df0-11e9-0e5d-c546b8b5ee8a"
version = "1.14.0"

[[DataStructures]]
deps = ["Compat", "InteractiveUtils", "OrderedCollections"]
git-tree-sha1 = "d1fff3a548102f48987a52a2e0d114fa97d730f0"
uuid = "864edb3b-99cc-5e75-8d2d-829cb0a9cfe8"
version = "0.18.13"

[[Dates]]
deps = ["Printf"]
uuid = "ade2ca70-3891-5945-98fb-dc099432e06a"

[[DelimitedFiles]]
deps = ["Mmap"]
uuid = "8bb1440f-4735-579b-a4ab-409b98df4dab"

[[DocStringExtensions]]
deps = ["LibGit2"]
git-tree-sha1 = "2fb1e02f2b635d0845df5d7c167fec4dd739b00d"
uuid = "ffbed154-4ef7-542d-bbb7-c09d3a79fcae"
version = "0.9.3"

[[Downloads]]
deps = ["ArgTools", "LibCURL", "NetworkOptions"]
uuid = "f43a241f-c20a-4ad4-852c-f6b1247861c6"

[[Expat_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "bad72f730e9e91c08d9427d5e8db95478a3c323d"
uuid = "2e619515-83b5-522b-bb60-26c02a35a201"
version = "2.4.8+0"

[[FFMPEG]]
deps = ["FFMPEG_jll"]
git-tree-sha1 = "b57e3acbe22f8484b4b5ff66a7499717fe1a9cc8"
uuid = "c87230d0-a227-11e9-1b43-d7ebe4e7570a"
version = "0.4.1"

[[FFMPEG_jll]]
deps = ["Artifacts", "Bzip2_jll", "FreeType2_jll", "FriBidi_jll", "JLLWrappers", "LAME_jll", "Libdl", "Ogg_jll", "OpenSSL_jll", "Opus_jll", "PCRE2_jll", "Pkg", "Zlib_jll", "libaom_jll", "libass_jll", "libfdk_aac_jll", "libvorbis_jll", "x264_jll", "x265_jll"]
git-tree-sha1 = "74faea50c1d007c85837327f6775bea60b5492dd"
uuid = "b22a6f82-2f65-5046-a5b2-351ab43fb4e5"
version = "4.4.2+2"

[[FixedPointNumbers]]
deps = ["Statistics"]
git-tree-sha1 = "335bfdceacc84c5cdf16aadc768aa5ddfc5383cc"
uuid = "53c48c17-4a7d-5ca2-90c5-79b7896eea93"
version = "0.8.4"

[[Fontconfig_jll]]
deps = ["Artifacts", "Bzip2_jll", "Expat_jll", "FreeType2_jll", "JLLWrappers", "Libdl", "Libuuid_jll", "Pkg", "Zlib_jll"]
git-tree-sha1 = "21efd19106a55620a188615da6d3d06cd7f6ee03"
uuid = "a3f928ae-7b40-5064-980b-68af3947d34b"
version = "2.13.93+0"

[[Formatting]]
deps = ["Printf"]
git-tree-sha1 = "8339d61043228fdd3eb658d86c926cb282ae72a8"
uuid = "59287772-0a20-5a39-b81b-1366585eb4c0"
version = "0.4.2"

[[FreeType2_jll]]
deps = ["Artifacts", "Bzip2_jll", "JLLWrappers", "Libdl", "Pkg", "Zlib_jll"]
git-tree-sha1 = "87eb71354d8ec1a96d4a7636bd57a7347dde3ef9"
uuid = "d7e528f0-a631-5988-bf34-fe36492bcfd7"
version = "2.10.4+0"

[[FriBidi_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "aa31987c2ba8704e23c6c8ba8a4f769d5d7e4f91"
uuid = "559328eb-81f9-559d-9380-de523a88c83c"
version = "1.0.10+0"

[[GLFW_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Libglvnd_jll", "Pkg", "Xorg_libXcursor_jll", "Xorg_libXi_jll", "Xorg_libXinerama_jll", "Xorg_libXrandr_jll"]
git-tree-sha1 = "d972031d28c8c8d9d7b41a536ad7bb0c2579caca"
uuid = "0656b61e-2033-5cc2-a64a-77c0f6c09b89"
version = "3.3.8+0"

[[GR]]
deps = ["Artifacts", "Base64", "DelimitedFiles", "Downloads", "GR_jll", "HTTP", "JSON", "Libdl", "LinearAlgebra", "Pkg", "Preferences", "Printf", "Random", "Serialization", "Sockets", "TOML", "Tar", "Test", "UUIDs", "p7zip_jll"]
git-tree-sha1 = "9e23bd6bb3eb4300cb567bdf63e2c14e5d2ffdbc"
uuid = "28b8d3ca-fb5f-59d9-8090-bfdbd6d07a71"
version = "0.71.5"

[[GR_jll]]
deps = ["Artifacts", "Bzip2_jll", "Cairo_jll", "FFMPEG_jll", "Fontconfig_jll", "GLFW_jll", "JLLWrappers", "JpegTurbo_jll", "Libdl", "Libtiff_jll", "Pixman_jll", "Pkg", "Qt5Base_jll", "Zlib_jll", "libpng_jll"]
git-tree-sha1 = "aa23c9f9b7c0ba6baeabe966ea1c7d2c7487ef90"
uuid = "d2c73de3-f751-5644-a686-071e5b155ba9"
version = "0.71.5+0"

[[Gettext_jll]]
deps = ["Artifacts", "CompilerSupportLibraries_jll", "JLLWrappers", "Libdl", "Libiconv_jll", "Pkg", "XML2_jll"]
git-tree-sha1 = "9b02998aba7bf074d14de89f9d37ca24a1a0b046"
uuid = "78b55507-aeef-58d4-861c-77aaff3498b1"
version = "0.21.0+0"

[[Glib_jll]]
deps = ["Artifacts", "Gettext_jll", "JLLWrappers", "Libdl", "Libffi_jll", "Libiconv_jll", "Libmount_jll", "PCRE2_jll", "Pkg", "Zlib_jll"]
git-tree-sha1 = "d3b3624125c1474292d0d8ed0f65554ac37ddb23"
uuid = "7746bdde-850d-59dc-9ae8-88ece973131d"
version = "2.74.0+2"

[[Graphite2_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "344bf40dcab1073aca04aa0df4fb092f920e4011"
uuid = "3b182d85-2403-5c21-9c21-1e1f0cc25472"
version = "1.3.14+0"

[[Grisu]]
git-tree-sha1 = "53bb909d1151e57e2484c3d1b53e19552b887fb2"
uuid = "42e2da0e-8278-4e71-bc24-59509adca0fe"
version = "1.0.2"

[[HTTP]]
deps = ["Base64", "CodecZlib", "Dates", "IniFile", "Logging", "LoggingExtras", "MbedTLS", "NetworkOptions", "OpenSSL", "Random", "SimpleBufferStream", "Sockets", "URIs", "UUIDs"]
git-tree-sha1 = "37e4657cd56b11abe3d10cd4a1ec5fbdb4180263"
uuid = "cd3eb016-35fb-5094-929b-558a96fad6f3"
version = "1.7.4"

[[HarfBuzz_jll]]
deps = ["Artifacts", "Cairo_jll", "Fontconfig_jll", "FreeType2_jll", "Glib_jll", "Graphite2_jll", "JLLWrappers", "Libdl", "Libffi_jll", "Pkg"]
git-tree-sha1 = "129acf094d168394e80ee1dc4bc06ec835e510a3"
uuid = "2e76f6c2-a576-52d4-95c1-20adfe4de566"
version = "2.8.1+1"

[[IniFile]]
git-tree-sha1 = "f550e6e32074c939295eb5ea6de31849ac2c9625"
uuid = "83e8ac13-25f8-5344-8a64-a9f2b223428f"
version = "0.5.1"

[[InteractiveUtils]]
deps = ["Markdown"]
uuid = "b77e0a4c-d291-57a0-90e8-8db25a27a240"

[[InverseFunctions]]
deps = ["Test"]
git-tree-sha1 = "49510dfcb407e572524ba94aeae2fced1f3feb0f"
uuid = "3587e190-3f89-42d0-90ee-14403ec27112"
version = "0.1.8"

[[IrrationalConstants]]
git-tree-sha1 = "7fd44fd4ff43fc60815f8e764c0f352b83c49151"
uuid = "92d709cd-6900-40b7-9082-c6be49f344b6"
version = "0.1.1"

[[JLFzf]]
deps = ["Pipe", "REPL", "Random", "fzf_jll"]
git-tree-sha1 = "f377670cda23b6b7c1c0b3893e37451c5c1a2185"
uuid = "1019f520-868f-41f5-a6de-eb00f4b6a39c"
version = "0.1.5"

[[JLLWrappers]]
deps = ["Preferences"]
git-tree-sha1 = "abc9885a7ca2052a736a600f7fa66209f96506e1"
uuid = "692b3bcd-3c85-4b1f-b108-f13ce0eb3210"
version = "1.4.1"

[[JSON]]
deps = ["Dates", "Mmap", "Parsers", "Unicode"]
git-tree-sha1 = "3c837543ddb02250ef42f4738347454f95079d4e"
uuid = "682c06a0-de6a-54ab-a142-c8b1cf79cde6"
version = "0.21.3"

[[JpegTurbo_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "b53380851c6e6664204efb2e62cd24fa5c47e4ba"
uuid = "aacddb02-875f-59d6-b918-886e6ef4fbf8"
version = "2.1.2+0"

[[LAME_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "f6250b16881adf048549549fba48b1161acdac8c"
uuid = "c1c5ebd0-6772-5130-a774-d5fcae4a789d"
version = "3.100.1+0"

[[LERC_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "bf36f528eec6634efc60d7ec062008f171071434"
uuid = "88015f11-f218-50d7-93a8-a6af411a945d"
version = "3.0.0+1"

[[LZO_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "e5b909bcf985c5e2605737d2ce278ed791b89be6"
uuid = "dd4b983a-f0e5-5f8d-a1b7-129d4a5fb1ac"
version = "2.10.1+0"

[[LaTeXStrings]]
git-tree-sha1 = "f2355693d6778a178ade15952b7ac47a4ff97996"
uuid = "b964fa9f-0449-5b57-a5c2-d3ea65f4040f"
version = "1.3.0"

[[Latexify]]
deps = ["Formatting", "InteractiveUtils", "LaTeXStrings", "MacroTools", "Markdown", "OrderedCollections", "Printf", "Requires"]
git-tree-sha1 = "2422f47b34d4b127720a18f86fa7b1aa2e141f29"
uuid = "23fbe1c1-3f47-55db-b15f-69d7ec21a316"
version = "0.15.18"

[[LibCURL]]
deps = ["LibCURL_jll", "MozillaCACerts_jll"]
uuid = "b27032c2-a3e7-50c8-80cd-2d36dbcbfd21"

[[LibCURL_jll]]
deps = ["Artifacts", "LibSSH2_jll", "Libdl", "MbedTLS_jll", "Zlib_jll", "nghttp2_jll"]
uuid = "deac9b47-8bc7-5906-a0fe-35ac56dc84c0"

[[LibGit2]]
deps = ["Base64", "NetworkOptions", "Printf", "SHA"]
uuid = "76f85450-5226-5b5a-8eaa-529ad045b433"

[[LibSSH2_jll]]
deps = ["Artifacts", "Libdl", "MbedTLS_jll"]
uuid = "29816b5a-b9ab-546f-933c-edad1886dfa8"

[[Libdl]]
uuid = "8f399da3-3557-5675-b5ff-fb832c97cbdb"

[[Libffi_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "0b4a5d71f3e5200a7dff793393e09dfc2d874290"
uuid = "e9f186c6-92d2-5b65-8a66-fee21dc1b490"
version = "3.2.2+1"

[[Libgcrypt_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Libgpg_error_jll", "Pkg"]
git-tree-sha1 = "64613c82a59c120435c067c2b809fc61cf5166ae"
uuid = "d4300ac3-e22c-5743-9152-c294e39db1e4"
version = "1.8.7+0"

[[Libglvnd_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_libX11_jll", "Xorg_libXext_jll"]
git-tree-sha1 = "6f73d1dd803986947b2c750138528a999a6c7733"
uuid = "7e76a0d4-f3c7-5321-8279-8d96eeed0f29"
version = "1.6.0+0"

[[Libgpg_error_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "c333716e46366857753e273ce6a69ee0945a6db9"
uuid = "7add5ba3-2f88-524e-9cd5-f83b8a55f7b8"
version = "1.42.0+0"

[[Libiconv_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "c7cb1f5d892775ba13767a87c7ada0b980ea0a71"
uuid = "94ce4f54-9a6c-5748-9c1c-f9c7231a4531"
version = "1.16.1+2"

[[Libmount_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "9c30530bf0effd46e15e0fdcf2b8636e78cbbd73"
uuid = "4b2f31a3-9ecc-558c-b454-b3730dcb73e9"
version = "2.35.0+0"

[[Libtiff_jll]]
deps = ["Artifacts", "JLLWrappers", "JpegTurbo_jll", "LERC_jll", "Libdl", "Pkg", "Zlib_jll", "Zstd_jll"]
git-tree-sha1 = "3eb79b0ca5764d4799c06699573fd8f533259713"
uuid = "89763e89-9b03-5906-acba-b20f662cd828"
version = "4.4.0+0"

[[Libuuid_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "7f3efec06033682db852f8b3bc3c1d2b0a0ab066"
uuid = "38a345b3-de98-5d2b-a5d3-14cd9215e700"
version = "2.36.0+0"

[[LinearAlgebra]]
deps = ["Libdl"]
uuid = "37e2e46d-f89d-539d-b4ee-838fcccc9c8e"

[[LogExpFunctions]]
deps = ["ChainRulesCore", "ChangesOfVariables", "DocStringExtensions", "InverseFunctions", "IrrationalConstants", "LinearAlgebra"]
git-tree-sha1 = "45b288af6956e67e621c5cbb2d75a261ab58300b"
uuid = "2ab3a3ac-af41-5b50-aa03-7779005ae688"
version = "0.3.20"

[[Logging]]
uuid = "56ddb016-857b-54e1-b83d-db4d58db5568"

[[LoggingExtras]]
deps = ["Dates", "Logging"]
git-tree-sha1 = "cedb76b37bc5a6c702ade66be44f831fa23c681e"
uuid = "e6f89c97-d47a-5376-807f-9c37f3926c36"
version = "1.0.0"

[[MacroTools]]
deps = ["Markdown", "Random"]
git-tree-sha1 = "42324d08725e200c23d4dfb549e0d5d89dede2d2"
uuid = "1914dd2f-81c6-5fcd-8719-6d5c9610ff09"
version = "0.5.10"

[[Markdown]]
deps = ["Base64"]
uuid = "d6f4376e-aef5-505a-96c1-9c027394607a"

[[MbedTLS]]
deps = ["Dates", "MbedTLS_jll", "MozillaCACerts_jll", "Random", "Sockets"]
git-tree-sha1 = "03a9b9718f5682ecb107ac9f7308991db4ce395b"
uuid = "739be429-bea8-5141-9913-cc70e7f3736d"
version = "1.1.7"

[[MbedTLS_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "c8ffd9c3-330d-5841-b78e-0817d7145fa1"

[[Measures]]
git-tree-sha1 = "c13304c81eec1ed3af7fc20e75fb6b26092a1102"
uuid = "442fdcdd-2543-5da2-b0f3-8c86c306513e"
version = "0.3.2"

[[Missings]]
deps = ["DataAPI"]
git-tree-sha1 = "f66bdc5de519e8f8ae43bdc598782d35a25b1272"
uuid = "e1d29d7a-bbdc-5cf2-9ac0-f12de2c33e28"
version = "1.1.0"

[[Mmap]]
uuid = "a63ad114-7e13-5084-954f-fe012c677804"

[[MozillaCACerts_jll]]
uuid = "14a3606d-f60d-562e-9121-12d972cd8159"

[[NaNMath]]
deps = ["OpenLibm_jll"]
git-tree-sha1 = "a7c3d1da1189a1c2fe843a3bfa04d18d20eb3211"
uuid = "77ba4419-2d1f-58cd-9bb1-8ffee604a2e3"
version = "1.0.1"

[[NetworkOptions]]
uuid = "ca575930-c2e3-43a9-ace4-1e988b2c1908"

[[Ogg_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "887579a3eb005446d514ab7aeac5d1d027658b8f"
uuid = "e7412a2a-1a6e-54c0-be00-318e2571c051"
version = "1.3.5+1"

[[OpenLibm_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "05823500-19ac-5b8b-9628-191a04bc5112"

[[OpenSSL]]
deps = ["BitFlags", "Dates", "MozillaCACerts_jll", "OpenSSL_jll", "Sockets"]
git-tree-sha1 = "6503b77492fd7fcb9379bf73cd31035670e3c509"
uuid = "4d8831e6-92b7-49fb-bdf8-b643e874388c"
version = "1.3.3"

[[OpenSSL_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "f6e9dba33f9f2c44e08a020b0caf6903be540004"
uuid = "458c3c95-2e84-50aa-8efc-19380b2a3a95"
version = "1.1.19+0"

[[OpenSpecFun_jll]]
deps = ["Artifacts", "CompilerSupportLibraries_jll", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "13652491f6856acfd2db29360e1bbcd4565d04f1"
uuid = "efe28fd5-8261-553b-a9e1-b2916fc3738e"
version = "0.5.5+0"

[[Opus_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "51a08fb14ec28da2ec7a927c4337e4332c2a4720"
uuid = "91d4177d-7536-5919-b921-800302f37372"
version = "1.3.2+0"

[[OrderedCollections]]
git-tree-sha1 = "85f8e6578bf1f9ee0d11e7bb1b1456435479d47c"
uuid = "bac558e1-5e72-5ebc-8fee-abe8a469f55d"
version = "1.4.1"

[[PCRE2_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "efcefdf7-47ab-520b-bdef-62a2eaa19f15"

[[Parsers]]
deps = ["Dates", "SnoopPrecompile"]
git-tree-sha1 = "8175fc2b118a3755113c8e68084dc1a9e63c61ee"
uuid = "69de0a69-1ddd-5017-9359-2bf0b02dc9f0"
version = "2.5.3"

[[Pipe]]
git-tree-sha1 = "6842804e7867b115ca9de748a0cf6b364523c16d"
uuid = "b98c9c47-44ae-5843-9183-064241ee97a0"
version = "1.3.0"

[[Pixman_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "b4f5d02549a10e20780a24fce72bea96b6329e29"
uuid = "30392449-352a-5448-841d-b1acce4e97dc"
version = "0.40.1+0"

[[Pkg]]
deps = ["Artifacts", "Dates", "Downloads", "LibGit2", "Libdl", "Logging", "Markdown", "Printf", "REPL", "Random", "SHA", "Serialization", "TOML", "Tar", "UUIDs", "p7zip_jll"]
uuid = "44cfe95a-1eb2-52ea-b672-e2afdf69b78f"

[[PlotThemes]]
deps = ["PlotUtils", "Statistics"]
git-tree-sha1 = "1f03a2d339f42dca4a4da149c7e15e9b896ad899"
uuid = "ccf2f8ad-2431-5c83-bf29-c5338b663b6a"
version = "3.1.0"

[[PlotUtils]]
deps = ["ColorSchemes", "Colors", "Dates", "Printf", "Random", "Reexport", "SnoopPrecompile", "Statistics"]
git-tree-sha1 = "c95373e73290cf50a8a22c3375e4625ded5c5280"
uuid = "995b91a9-d308-5afd-9ec6-746e21dbc043"
version = "1.3.4"

[[Plots]]
deps = ["Base64", "Contour", "Dates", "Downloads", "FFMPEG", "FixedPointNumbers", "GR", "JLFzf", "JSON", "LaTeXStrings", "Latexify", "LinearAlgebra", "Measures", "NaNMath", "Pkg", "PlotThemes", "PlotUtils", "Preferences", "Printf", "REPL", "Random", "RecipesBase", "RecipesPipeline", "Reexport", "RelocatableFolders", "Requires", "Scratch", "Showoff", "SnoopPrecompile", "SparseArrays", "Statistics", "StatsBase", "UUIDs", "UnicodeFun", "Unzip"]
git-tree-sha1 = "0a3a23e0c67adf9433111467b0522077c596de58"
uuid = "91a5bcdd-55d7-5caf-9e0b-520d859cae80"
version = "1.38.3"

[[Preferences]]
deps = ["TOML"]
git-tree-sha1 = "47e5f437cc0e7ef2ce8406ce1e7e24d44915f88d"
uuid = "21216c6a-2e73-6563-6e65-726566657250"
version = "1.3.0"

[[Printf]]
deps = ["Unicode"]
uuid = "de0858da-6303-5e67-8744-51eddeeeb8d7"

[[Qt5Base_jll]]
deps = ["Artifacts", "CompilerSupportLibraries_jll", "Fontconfig_jll", "Glib_jll", "JLLWrappers", "Libdl", "Libglvnd_jll", "OpenSSL_jll", "Pkg", "Xorg_libXext_jll", "Xorg_libxcb_jll", "Xorg_xcb_util_image_jll", "Xorg_xcb_util_keysyms_jll", "Xorg_xcb_util_renderutil_jll", "Xorg_xcb_util_wm_jll", "Zlib_jll", "xkbcommon_jll"]
git-tree-sha1 = "0c03844e2231e12fda4d0086fd7cbe4098ee8dc5"
uuid = "ea2cea3b-5b76-57ae-a6ef-0a8af62496e1"
version = "5.15.3+2"

[[REPL]]
deps = ["InteractiveUtils", "Markdown", "Sockets", "Unicode"]
uuid = "3fa0cd96-eef1-5676-8a61-b3b8758bbffb"

[[Random]]
deps = ["Serialization"]
uuid = "9a3f8284-a2c9-5f02-9a11-845980a1fd5c"

[[RecipesBase]]
deps = ["SnoopPrecompile"]
git-tree-sha1 = "261dddd3b862bd2c940cf6ca4d1c8fe593e457c8"
uuid = "3cdcf5f2-1ef4-517c-9805-6587b60abb01"
version = "1.3.3"

[[RecipesPipeline]]
deps = ["Dates", "NaNMath", "PlotUtils", "RecipesBase", "SnoopPrecompile"]
git-tree-sha1 = "e974477be88cb5e3040009f3767611bc6357846f"
uuid = "01d81517-befc-4cb6-b9ec-a95719d0359c"
version = "0.6.11"

[[Reexport]]
git-tree-sha1 = "45e428421666073eab6f2da5c9d310d99bb12f9b"
uuid = "189a3867-3050-52da-a836-e630ba90ab69"
version = "1.2.2"

[[RelocatableFolders]]
deps = ["SHA", "Scratch"]
git-tree-sha1 = "90bc7a7c96410424509e4263e277e43250c05691"
uuid = "05181044-ff0b-4ac5-8273-598c1e38db00"
version = "1.0.0"

[[Requires]]
deps = ["UUIDs"]
git-tree-sha1 = "838a3a4188e2ded87a4f9f184b4b0d78a1e91cb7"
uuid = "ae029012-a4dd-5104-9daa-d747884805df"
version = "1.3.0"

[[SHA]]
uuid = "ea8e919c-243c-51af-8825-aaa63cd721ce"

[[Scratch]]
deps = ["Dates"]
git-tree-sha1 = "f94f779c94e58bf9ea243e77a37e16d9de9126bd"
uuid = "6c6a2e73-6563-6170-7368-637461726353"
version = "1.1.1"

[[Serialization]]
uuid = "9e88b42a-f829-5b0c-bbe9-9e923198166b"

[[Showoff]]
deps = ["Dates", "Grisu"]
git-tree-sha1 = "91eddf657aca81df9ae6ceb20b959ae5653ad1de"
uuid = "992d4aef-0814-514b-bc4d-f2e9a6c4116f"
version = "1.0.3"

[[SimpleBufferStream]]
git-tree-sha1 = "874e8867b33a00e784c8a7e4b60afe9e037b74e1"
uuid = "777ac1f9-54b0-4bf8-805c-2214025038e7"
version = "1.1.0"

[[SnoopPrecompile]]
deps = ["Preferences"]
git-tree-sha1 = "e760a70afdcd461cf01a575947738d359234665c"
uuid = "66db9d55-30c0-4569-8b51-7e840670fc0c"
version = "1.0.3"

[[Sockets]]
uuid = "6462fe0b-24de-5631-8697-dd941f90decc"

[[SortingAlgorithms]]
deps = ["DataStructures"]
git-tree-sha1 = "a4ada03f999bd01b3a25dcaa30b2d929fe537e00"
uuid = "a2af1166-a08f-5f64-846c-94a0d3cef48c"
version = "1.1.0"

[[SparseArrays]]
deps = ["LinearAlgebra", "Random"]
uuid = "2f01184e-e22b-5df5-ae63-d93ebab69eaf"

[[SpecialFunctions]]
deps = ["ChainRulesCore", "IrrationalConstants", "LogExpFunctions", "OpenLibm_jll", "OpenSpecFun_jll"]
git-tree-sha1 = "d75bda01f8c31ebb72df80a46c88b25d1c79c56d"
uuid = "276daf66-3868-5448-9aa4-cd146d93841b"
version = "2.1.7"

[[Statistics]]
deps = ["LinearAlgebra", "SparseArrays"]
uuid = "10745b16-79ce-11e8-11f9-7d13ad32a3b2"

[[StatsAPI]]
deps = ["LinearAlgebra"]
git-tree-sha1 = "f9af7f195fb13589dd2e2d57fdb401717d2eb1f6"
uuid = "82ae8749-77ed-4fe6-ae5f-f523153014b0"
version = "1.5.0"

[[StatsBase]]
deps = ["DataAPI", "DataStructures", "LinearAlgebra", "LogExpFunctions", "Missings", "Printf", "Random", "SortingAlgorithms", "SparseArrays", "Statistics", "StatsAPI"]
git-tree-sha1 = "d1bf48bfcc554a3761a133fe3a9bb01488e06916"
uuid = "2913bbd2-ae8a-5f71-8c99-4fb6c76f3a91"
version = "0.33.21"

[[TOML]]
deps = ["Dates"]
uuid = "fa267f1f-6049-4f14-aa54-33bafae1ed76"

[[Tar]]
deps = ["ArgTools", "SHA"]
uuid = "a4e569a6-e804-4fa4-b0f3-eef7a1d5b13e"

[[TensorCore]]
deps = ["LinearAlgebra"]
git-tree-sha1 = "1feb45f88d133a655e001435632f019a9a1bcdb6"
uuid = "62fd8b95-f654-4bbd-a8a5-9c27f68ccd50"
version = "0.1.1"

[[Test]]
deps = ["InteractiveUtils", "Logging", "Random", "Serialization"]
uuid = "8dfed614-e22c-5e08-85e1-65c5234f0b40"

[[TranscodingStreams]]
deps = ["Random", "Test"]
git-tree-sha1 = "94f38103c984f89cf77c402f2a68dbd870f8165f"
uuid = "3bb67fe8-82b1-5028-8e26-92a6c54297fa"
version = "0.9.11"

[[URIs]]
git-tree-sha1 = "ac00576f90d8a259f2c9d823e91d1de3fd44d348"
uuid = "5c2747f8-b7ea-4ff2-ba2e-563bfd36b1d4"
version = "1.4.1"

[[UUIDs]]
deps = ["Random", "SHA"]
uuid = "cf7118a7-6976-5b1a-9a39-7adc72f591a4"

[[Unicode]]
uuid = "4ec0a83e-493e-50e2-b9ac-8f72acf5a8f5"

[[UnicodeFun]]
deps = ["REPL"]
git-tree-sha1 = "53915e50200959667e78a92a418594b428dffddf"
uuid = "1cfade01-22cf-5700-b092-accc4b62d6e1"
version = "0.4.1"

[[Unzip]]
git-tree-sha1 = "34db80951901073501137bdbc3d5a8e7bbd06670"
uuid = "41fe7b60-77ed-43a1-b4f0-825fd5a5650d"
version = "0.1.2"

[[Wayland_jll]]
deps = ["Artifacts", "Expat_jll", "JLLWrappers", "Libdl", "Libffi_jll", "Pkg", "XML2_jll"]
git-tree-sha1 = "ed8d92d9774b077c53e1da50fd81a36af3744c1c"
uuid = "a2964d1f-97da-50d4-b82a-358c7fce9d89"
version = "1.21.0+0"

[[Wayland_protocols_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "4528479aa01ee1b3b4cd0e6faef0e04cf16466da"
uuid = "2381bf8a-dfd0-557d-9999-79630e7b1b91"
version = "1.25.0+0"

[[XML2_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Libiconv_jll", "Pkg", "Zlib_jll"]
git-tree-sha1 = "93c41695bc1c08c46c5899f4fe06d6ead504bb73"
uuid = "02c8fc9c-b97f-50b9-bbe4-9be30ff0a78a"
version = "2.10.3+0"

[[XSLT_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Libgcrypt_jll", "Libgpg_error_jll", "Libiconv_jll", "Pkg", "XML2_jll", "Zlib_jll"]
git-tree-sha1 = "91844873c4085240b95e795f692c4cec4d805f8a"
uuid = "aed1982a-8fda-507f-9586-7b0439959a61"
version = "1.1.34+0"

[[Xorg_libX11_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_libxcb_jll", "Xorg_xtrans_jll"]
git-tree-sha1 = "5be649d550f3f4b95308bf0183b82e2582876527"
uuid = "4f6342f7-b3d2-589e-9d20-edeb45f2b2bc"
version = "1.6.9+4"

[[Xorg_libXau_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "4e490d5c960c314f33885790ed410ff3a94ce67e"
uuid = "0c0b7dd1-d40b-584c-a123-a41640f87eec"
version = "1.0.9+4"

[[Xorg_libXcursor_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_libXfixes_jll", "Xorg_libXrender_jll"]
git-tree-sha1 = "12e0eb3bc634fa2080c1c37fccf56f7c22989afd"
uuid = "935fb764-8cf2-53bf-bb30-45bb1f8bf724"
version = "1.2.0+4"

[[Xorg_libXdmcp_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "4fe47bd2247248125c428978740e18a681372dd4"
uuid = "a3789734-cfe1-5b06-b2d0-1dd0d9d62d05"
version = "1.1.3+4"

[[Xorg_libXext_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_libX11_jll"]
git-tree-sha1 = "b7c0aa8c376b31e4852b360222848637f481f8c3"
uuid = "1082639a-0dae-5f34-9b06-72781eeb8cb3"
version = "1.3.4+4"

[[Xorg_libXfixes_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_libX11_jll"]
git-tree-sha1 = "0e0dc7431e7a0587559f9294aeec269471c991a4"
uuid = "d091e8ba-531a-589c-9de9-94069b037ed8"
version = "5.0.3+4"

[[Xorg_libXi_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_libXext_jll", "Xorg_libXfixes_jll"]
git-tree-sha1 = "89b52bc2160aadc84d707093930ef0bffa641246"
uuid = "a51aa0fd-4e3c-5386-b890-e753decda492"
version = "1.7.10+4"

[[Xorg_libXinerama_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_libXext_jll"]
git-tree-sha1 = "26be8b1c342929259317d8b9f7b53bf2bb73b123"
uuid = "d1454406-59df-5ea1-beac-c340f2130bc3"
version = "1.1.4+4"

[[Xorg_libXrandr_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_libXext_jll", "Xorg_libXrender_jll"]
git-tree-sha1 = "34cea83cb726fb58f325887bf0612c6b3fb17631"
uuid = "ec84b674-ba8e-5d96-8ba1-2a689ba10484"
version = "1.5.2+4"

[[Xorg_libXrender_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_libX11_jll"]
git-tree-sha1 = "19560f30fd49f4d4efbe7002a1037f8c43d43b96"
uuid = "ea2f1a96-1ddc-540d-b46f-429655e07cfa"
version = "0.9.10+4"

[[Xorg_libpthread_stubs_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "6783737e45d3c59a4a4c4091f5f88cdcf0908cbb"
uuid = "14d82f49-176c-5ed1-bb49-ad3f5cbd8c74"
version = "0.1.0+3"

[[Xorg_libxcb_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "XSLT_jll", "Xorg_libXau_jll", "Xorg_libXdmcp_jll", "Xorg_libpthread_stubs_jll"]
git-tree-sha1 = "daf17f441228e7a3833846cd048892861cff16d6"
uuid = "c7cfdc94-dc32-55de-ac96-5a1b8d977c5b"
version = "1.13.0+3"

[[Xorg_libxkbfile_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_libX11_jll"]
git-tree-sha1 = "926af861744212db0eb001d9e40b5d16292080b2"
uuid = "cc61e674-0454-545c-8b26-ed2c68acab7a"
version = "1.1.0+4"

[[Xorg_xcb_util_image_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_xcb_util_jll"]
git-tree-sha1 = "0fab0a40349ba1cba2c1da699243396ff8e94b97"
uuid = "12413925-8142-5f55-bb0e-6d7ca50bb09b"
version = "0.4.0+1"

[[Xorg_xcb_util_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_libxcb_jll"]
git-tree-sha1 = "e7fd7b2881fa2eaa72717420894d3938177862d1"
uuid = "2def613f-5ad1-5310-b15b-b15d46f528f5"
version = "0.4.0+1"

[[Xorg_xcb_util_keysyms_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_xcb_util_jll"]
git-tree-sha1 = "d1151e2c45a544f32441a567d1690e701ec89b00"
uuid = "975044d2-76e6-5fbe-bf08-97ce7c6574c7"
version = "0.4.0+1"

[[Xorg_xcb_util_renderutil_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_xcb_util_jll"]
git-tree-sha1 = "dfd7a8f38d4613b6a575253b3174dd991ca6183e"
uuid = "0d47668e-0667-5a69-a72c-f761630bfb7e"
version = "0.3.9+1"

[[Xorg_xcb_util_wm_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_xcb_util_jll"]
git-tree-sha1 = "e78d10aab01a4a154142c5006ed44fd9e8e31b67"
uuid = "c22f9ab0-d5fe-5066-847c-f4bb1cd4e361"
version = "0.4.1+1"

[[Xorg_xkbcomp_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_libxkbfile_jll"]
git-tree-sha1 = "4bcbf660f6c2e714f87e960a171b119d06ee163b"
uuid = "35661453-b289-5fab-8a00-3d9160c6a3a4"
version = "1.4.2+4"

[[Xorg_xkeyboard_config_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_xkbcomp_jll"]
git-tree-sha1 = "5c8424f8a67c3f2209646d4425f3d415fee5931d"
uuid = "33bec58e-1273-512f-9401-5d533626f822"
version = "2.27.0+4"

[[Xorg_xtrans_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "79c31e7844f6ecf779705fbc12146eb190b7d845"
uuid = "c5fb5394-a638-5e4d-96e5-b29de1b5cf10"
version = "1.4.0+3"

[[Zlib_jll]]
deps = ["Libdl"]
uuid = "83775a58-1f1d-513f-b197-d71354ab007a"

[[Zstd_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "e45044cd873ded54b6a5bac0eb5c971392cf1927"
uuid = "3161d3a3-bdf6-5164-811a-617609db77b4"
version = "1.5.2+0"

[[fzf_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "868e669ccb12ba16eaf50cb2957ee2ff61261c56"
uuid = "214eeab7-80f7-51ab-84ad-2988db7cef09"
version = "0.29.0+0"

[[libaom_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "3a2ea60308f0996d26f1e5354e10c24e9ef905d4"
uuid = "a4ae2306-e953-59d6-aa16-d00cac43593b"
version = "3.4.0+0"

[[libass_jll]]
deps = ["Artifacts", "Bzip2_jll", "FreeType2_jll", "FriBidi_jll", "HarfBuzz_jll", "JLLWrappers", "Libdl", "Pkg", "Zlib_jll"]
git-tree-sha1 = "5982a94fcba20f02f42ace44b9894ee2b140fe47"
uuid = "0ac62f75-1d6f-5e53-bd7c-93b484bb37c0"
version = "0.15.1+0"

[[libfdk_aac_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "daacc84a041563f965be61859a36e17c4e4fcd55"
uuid = "f638f0a6-7fb0-5443-88ba-1cc74229b280"
version = "2.0.2+0"

[[libpng_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Zlib_jll"]
git-tree-sha1 = "94d180a6d2b5e55e447e2d27a29ed04fe79eb30c"
uuid = "b53b4c65-9356-5827-b1ea-8c7a1a84506f"
version = "1.6.38+0"

[[libvorbis_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Ogg_jll", "Pkg"]
git-tree-sha1 = "b910cb81ef3fe6e78bf6acee440bda86fd6ae00c"
uuid = "f27f6e37-5d2b-51aa-960f-b287f2bc3b7a"
version = "1.3.7+1"

[[nghttp2_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "8e850ede-7688-5339-a07c-302acd2aaf8d"

[[p7zip_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "3f19e933-33d8-53b3-aaab-bd5110c3b7a0"

[[x264_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "4fea590b89e6ec504593146bf8b988b2c00922b2"
uuid = "1270edf5-f2f9-52d2-97e9-ab00b5d0237a"
version = "2021.5.5+0"

[[x265_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "ee567a171cce03570d77ad3a43e90218e38937a9"
uuid = "dfaa095f-4041-5dcd-9319-2fabd8486b76"
version = "3.5.0+0"

[[xkbcommon_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Wayland_jll", "Wayland_protocols_jll", "Xorg_libxcb_jll", "Xorg_xkeyboard_config_jll"]
git-tree-sha1 = "9ebfc140cc56e8c2156a15ceac2f0302e327ac0a"
uuid = "d8fb68d0-12a3-5cfd-a85a-d49703b185fd"
version = "1.4.1+0"
"""

# ╔═╡ Cell order:
# ╠═977b71d0-9c95-11ed-3c8a-45665d8bb919
# ╠═a0d827a2-eee1-4b45-a12b-0f5c7ba7d937
# ╠═8690a8df-3b42-4148-93bd-d6c7a37bd553
# ╟─f20a15ba-5eeb-49d6-96bb-61904cbf0a3b
# ╠═2ee43943-7253-40ef-b05a-a1db2b6f7aac
# ╟─01b88ac4-4a69-4259-8d46-16796ee9b3ea
# ╠═b9b139f8-2672-4547-80e0-aadb0714c62f
# ╟─06720cf4-e09d-4f14-901d-a4f2ab6e851c
# ╠═4eb0710c-d432-4e6b-83ad-c1445f38d362
# ╠═ce28bd06-898a-45b5-a1e8-30e188be8888
# ╠═4ff5c174-ba68-493a-98c5-55196d7601f5
# ╠═e2aa2184-b8ae-4f98-9b34-d9b4110b9095
# ╠═eec95f9a-ba0f-45e5-b90c-55433fa05df4
# ╠═7566c3af-517c-453a-9b68-b3bac7a124ac
# ╟─8242293f-3195-4b65-8fe2-dde03ac72a76
# ╠═e9451707-1c67-494f-813f-2b45ec7675c7
# ╠═a0024991-f93d-463c-9001-3f3c22528b9b
# ╠═4f876c82-6c94-4b92-93f6-77e6814e4402
# ╠═7813d6fe-94ca-4278-9d6f-6d31a19eb765
# ╠═f6d52ec9-5ef5-462d-8cf0-1f6144148493
# ╠═e5caecdb-6a66-458a-b8b8-37d0ab442aa5
# ╠═cab3bbd9-c1dd-4f4a-94ce-612f52a7e7c8
# ╠═b48bc8f7-7577-41b2-b611-426e394436fb
# ╠═d7bf15ca-58fa-4e9b-af6e-bcc30a5b5631
# ╠═c2c81457-e0d7-44e6-8cdb-17121ad3ccaa
# ╠═04ddea98-1582-47db-bc06-634dc28cf313
# ╠═18b60e48-767f-4b52-aad9-322268af9931
# ╠═a93d44f2-a1d8-4389-8151-3b040b0873a0
# ╟─9fd64400-6b98-4e6d-b682-624b1a2fc543
# ╠═8bcca12c-8a17-4296-9a46-40d277fc504f
# ╟─9d048ca0-a9b0-4e06-a3a0-96cb30fb430d
# ╠═756e733e-a2d9-44cb-aad3-1a89706e6075
# ╠═95959428-ee7f-4557-a84a-0e2f82f9d27c
# ╠═f9a3c633-a4d3-4368-88a9-06ae7e4eaba3
# ╠═67065f32-9c47-4010-ab92-7f7e45f66a6f
# ╠═38e68fae-0200-4c9c-9f3a-df44d0b1bf36
# ╠═f23ed720-e268-446a-9226-a4bd3f306cab
# ╠═af047c9d-7dfe-48f5-aa22-179b8ac34cb9
# ╠═34aeec52-136a-43ed-b6f6-c1242a386744
# ╟─00000000-0000-0000-0000-000000000001
# ╟─00000000-0000-0000-0000-000000000002
