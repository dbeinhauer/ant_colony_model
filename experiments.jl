### A Pluto.jl notebook ###
# v0.19.22

using Markdown
using InteractiveUtils

# ╔═╡ 78142762-ae33-11ed-3e6b-75b2fc3af2b5
module AntsModel

import Pkg
Pkg.add("Plots")

include("ant_colony.jl")

end

# ╔═╡ 9cb64897-e862-444b-8435-54a90fc8690c
"""
	compute_num_food(food_coordinates)

Compute amount of food on the grid.
"""
function compute_num_food(
		food_coordinates,
	)

	# println("Food Coordinates: $food_coordinates")
	total_food = 0
	for (x_coord, y_coord) in food_coordinates
		# println("x coords: $x_coord    y coords: $y_coord")
		total_food += 
			(x_coord[end] - (x_coord[1] - 1))*(y_coord[end] - (y_coord[1] - 1)) 
		# println(total_food)
	end
	
	return total_food
end

# ╔═╡ f03578ab-8ab0-4564-b7e3-6c368b61eb5a
"""
	draw_map(simulation_map, ants, title)

Draw the map.
"""
function draw_map(
		simulation_map, 
		ants;
		title::String = ""
	)

	map_objects_colors = Dict(
		AntsModel.OBSTACLE => AntsModel.hex2rgba(0xFF00F0),
		AntsModel.FREE => AntsModel.hex2rgba(0x000000),
		AntsModel.NEST => AntsModel.hex2rgba(0xFF4500),
		AntsModel.FOOD => AntsModel.hex2rgba(0x7A871E),
		AntsModel.TRAP => AntsModel.hex2rgba(0x159874)
	)

	return AntsModel.Plots.plot(
		map(s -> map_objects_colors[s], transpose(simulation_map.map_objects))
	)
end

# ╔═╡ b94e4c8c-5335-4e99-b92a-28d5a5b00b1b
"""
	print_experiment_header(food_coordinates, title_line = "", parameters_line = "", table_header = "")

Prints header of the experiment in appropriate format based on the arguments.
"""
function print_experiment_header(
		food_coordinates;
		title_line::String = "",
		parameters_line::String = "",
		table_header::String = "",	
	)
	println(title_line)
	println(parameters_line)
	println("Total amount of food on the map: $(compute_num_food(food_coordinates))")
	println("---------------------------------------------------")
	println()
	println(table_header)
	println("---------------------------------------------------")
end

# ╔═╡ 1f1d6b11-6d87-4ff2-81c7-0f2ba2ceffec
"""
	print_experiment_bottom()

Prints tail of the experiment in appropriate format.
"""
function print_experiment_bottom()
	println("---------------------------------------------------")
	println("End of Experiment!")
	println()
	println()
end

# ╔═╡ 23d7831b-233e-457b-839c-81955bd824a7
begin
	EXPERIMENT_DEPTHS = "search_depth"
	EXPERIMENT_NUM_ANTS = "num_ants"
end

# ╔═╡ 5428328c-f34f-4221-a16d-bc343eff8a4b
begin
	DEFAULT_GRID_SIZE = (100, 100)
	DEFAULT_FOOD_COORDINATES = [(1:15, 1:20), (80:100, 85:95)]
	DEFAULT_NEST_COORDINATES = [(45:52, 55:62)]
	DEFAULT_OBSTACLE_COORDINATES = []
	DEFAULT_SEARCH_DEPTH = 10
	DEFAULT_NUM_ANTS = 400
end

# ╔═╡ d661c668-fa91-4964-8817-22cdba31c38b
compute_num_food(DEFAULT_FOOD_COORDINATES)

# ╔═╡ 59fae562-b2a9-4926-89d2-10f94b936fb8
function run_experiments(
		data_interval,
		variant;
		grid_size = DEFAULT_GRID_SIZE,
		food_coordinates = DEFAULT_FOOD_COORDINATES,
		nest_coordinates = DEFAULT_NEST_COORDINATES,
		obstacle_coordinates = DEFAULT_OBSTACLE_COORDINATES,
		maze_variant::String = "DEFAULT",
		num_iterations = 8000,
	)

	search_depth = DEFAULT_NUM_ANTS
	num_ants = DEFAULT_NUM_ANTS

 	# search_depths = SEARCH_DEPTHS_FIRST_VARIANT

 	print_experiment_header(
			food_coordinates,
 			title_line = "Experiments for `$variant` on `$maze_variant` map with $num_iterations iterations.",
			parameters_line = "$variant=$data_interval",
			table_header = "$variant num_food",
		)

	for parameter in data_interval
		if variant == EXPERIMENT_DEPTHS
			search_depth = parameter
		elseif variant == EXPERIMENT_NUM_ANTS
			num_ants = parameter
		end
		
		print("$parameter ")
		println(
			AntsModel.sim!(
				AntsModel.init_simulation(
					grid_size = grid_size,
					food_coordinates = food_coordinates,
					nest_coordinates = nest_coordinates,
					obstacle_coordinates = obstacle_coordinates,
					search_depth = search_depth,
					num_ants = num_ants,
				)..., 
				num_iterations=num_iterations,
				animate=false,
			)
		)
	end

	print_experiment_bottom()
end

# ╔═╡ 3a0450e1-7009-4494-a8f2-514409a36727
md"""
## Experiments
"""

# ╔═╡ 2aa49e8a-0323-491d-a802-64ecbed69a70
md"""
### Grid Search Model Parameters

Following blocks contain code to run grid search on choosen model parameters to
set default values.
"""

# ╔═╡ 81732f05-ea97-402e-8f4c-365814fd4280
# begin
# 	"""
# 	First variant of experiments testing variants of `fade_rate`, `difusion_rate` and 
# 	`normalization_parameter` on 4000 iterations.
# 	"""

# 	fade_rates = 0.0001:0.0001:0.001
# 	difusion_rates = 0:0.1:1
# 	normalization_parameters = 0:0.0005:0.001

# 	print_experiment_header(
# 			title_line = "First experiments for variants on 4000 iterations.",
# 			parameters_line = "fade_rate=$fade_rates difusion_rate=$difusion_rates normalization_parameter=$normalization_parameters",
# 			table_header = "f-{fade_rate} d-{difusion_rate} n-{normalization_parameter}: num_food",
# 		)
	
# 	for fade in fade_rates
# 		for difusion in difusion_rates
# 			for norm in normalization_parameters
# 				print("f-$fade d-$difusion n-$norm: ")
# 				println(AntsModel.sim!(
# 					AntsModel.init_simulation(
# 							pheromone_fade_rate = fade,
# 							difusion_rate = difusion,
# 							normalization_parameter = norm,
# 						)..., 
# 						num_iterations = 4000,
# 						animate=false
# 					)
# 				)
# 			end
# 		end
# 	end

# 	print_experiment_bottom()
# end

# ╔═╡ 6fef22b7-c441-459a-96d5-143d91674d31
# begin
# 	"""
# 	Second variant of experiments testing variants of `fade_rate` and `difusion_rate` 
# 	on 8000 iterations.
# 	"""

# 	fade_rates = 0.0001:0.0001:0.001
# 	difusion_rates = 0:0.1:1

# 	print_experiment_header(
# 			title_line = "Second experiments for variants on 8000 iterations.",
# 			parameters_line = "fade_rate=$fade_rates difusion_rate=$difusion_rates",
# 			table_header = "f-{fade_rate} d-{difusion_rate}: num_food",
# 		)

	
# 	for fade in fade_rates
# 		for difusion in difusion_rates
# 			print("f-$fade d-$difusion: ")
# 			println(AntsModel.sim!(
# 				AntsModel.init_simulation(
# 						pheromone_fade_rate = fade,
# 						difusion_rate = difusion,
# 					)..., 
# 					num_iterations = 8000,
# 					animate=false
# 				)
# 			)
# 		end
# 	end

# 	print_experiment_bottom()
# end

# ╔═╡ 3dfd629a-49f5-4d2a-a56f-1fc67ab9bdba
md"""
### Search Depth and Num Ants State Space search

Following part contains parts for state space search on different variants of model 
map.

Each part always contains at least following 3 blocks of code:
- animation of choosen model with default parameters
- state space search of `search_depth` with appropriate map
- state space search of `num_ants` with appropriate map
"""

# ╔═╡ 341fae45-5ce5-486e-beb3-6e38592b0ae1
md"""
__First variant of `search_depth` and `num_ants` state space__
"""

# ╔═╡ 2f016ebe-9f08-4948-a995-af037341aab0
begin
	SEARCH_DEPTHS_FIRST_VARIANT = 0:1:50
	NUM_ANTS_FIRST_VARIANT = 20:10:2000
end

# ╔═╡ bb39e826-5bc0-46b7-8a95-22d84181e2ff
md"""
#### Default Map Without Obstacles
"""

# ╔═╡ be442933-4574-4abc-a692-fc94fda5edf7
begin
	"""
	Animated model with default map and parameters.
	"""
	
	AntsModel.sim!(
			AntsModel.init_simulation(
				# num_ants = 400,
				# search_depth = 10,
			)..., 
			num_iterations = 4000, 
			# animation_type = AntsModel.PHEROMONE_ANIM,
			animation_type = AntsModel.PHEROMONE_ANTS_ANIM,
			animate = true,
		)
end

# ╔═╡ 22565199-80fe-4862-ab38-f397f63c706f
# begin
# 	run_experiments(
# 		SEARCH_DEPTHS_FIRST_VARIANT,
# 		EXPERIMENT_DEPTHS,
# 		num_iterations = 8000,
# 	)
# end

# ╔═╡ 16d61d98-75f0-47c8-8da9-18f954a22054
# begin
# 	run_experiments(
# 		NUM_ANTS_FIRST_VARIANT,
# 		EXPERIMENT_NUM_ANTS,
# 		num_iterations = 8000,
# 	)
# end

# ╔═╡ 049b60e2-13e3-4c0d-bb58-9ef415328abd
md"""
#### Obstacles Around Food Sources
"""

# ╔═╡ 9c100f25-a7c0-4a19-97ef-7df25b23f222
begin
	FOOD_VARIANT_1 = [(1:15, 1:20), (80:100, 85:95)]
	NEST_VARIANT_1 = [(45:52, 55:62)]
	OBSTACLE_VARIANT_1 = [(1:7, 25:25), (12:18, 25:25), (18:18, 1:25),
		(75:100, 80:80), (75:75, 80:93)]
end

# ╔═╡ 359185c3-32cf-4418-b791-dd122d0be554
begin
	"""
	Animated variant with map defined by `VARIANT_1` variables.
	"""
	
	AntsModel.sim!(
			AntsModel.init_simulation(
				food_coordinates = FOOD_VARIANT_1,
				nest_coordinates = NEST_VARIANT_1,
				obstacle_coordinates = OBSTACLE_VARIANT_1,
				# num_ants = 400,
				# search_depth = 10,
				pheromone_fade_rate = 0.00021,
				search_depth = 10,
				pheromone_power = 0.02,
				difusion_rate = 0.495,
				normalization_parameter = 0.0005,
			)..., 
			num_iterations = 4000, 
			# animation_type = AntsModel.PHEROMONE_ANIM,
			animation_type = AntsModel.PHEROMONE_ANTS_ANIM,
			animate = true,
		)
end

# ╔═╡ 3745f7aa-ae46-4307-bfa8-47bf518dde8f
# begin
# 	run_experiments(
# 		SEARCH_DEPTHS_FIRST_VARIANT,
# 		EXPERIMENT_DEPTHS,
# 		food_coordinates = FOOD_VARIANT_1,
# 		nest_coordinates = NEST_VARIANT_1,
# 		obstacle_coordinates = OBSTACLE_VARIANT_1,
# 		maze_variant = "VARIANT_1",
# 		num_iterations = 8000,
# 	)
# end

# ╔═╡ 2372d2b9-d30a-4772-b826-54c03d980f7e
# begin
# 	run_experiments(
# 		NUM_ANTS_FIRST_VARIANT,
# 		EXPERIMENT_NUM_ANTS,
# 		food_coordinates = FOOD_VARIANT_1,
# 		nest_coordinates = NEST_VARIANT_1,
# 		obstacle_coordinates = OBSTACLE_VARIANT_1,
# 		maze_variant = "VARIANT_1",
# 		num_iterations = 8000,
# 	)
# end

# ╔═╡ 7e1df792-4b2d-4816-ae84-a5adc1ce9e09
md"""
#### Easy Maze Split Further
"""

# ╔═╡ f4bd62af-e81f-467e-b8ce-ca19d47e2dee
begin
	FOOD_VARIANT_2 = [(80:90, 1:20), (80:90, 80:100)]
	NEST_VARIANT_2 = [(3:10, 45:55)]
	OBSTACLE_VARIANT_2 = [
			(1:60, 35:35), (60:60, 1:35),
			(1:60, 65:65), (60:60, 65:100),
			(75:75, 25:75),
			(75:100, 25:25), (75:100, 75:75)

		]
end

# ╔═╡ 4125fd48-1b77-4f32-a5ed-79a59797edba
begin
	"""
	Animated variant with map defined by `VARIANT_2` variables.
	"""
	
	AntsModel.sim!(
			AntsModel.init_simulation(
				food_coordinates = FOOD_VARIANT_2,
				nest_coordinates = NEST_VARIANT_2,
				obstacle_coordinates = OBSTACLE_VARIANT_2,
				# num_ants = 400,
				# search_depth = 10,
				pheromone_fade_rate = 0.00021,
				search_depth = 10,
				pheromone_power = 0.02,
				difusion_rate = 0.495,
				normalization_parameter = 0.0005,
			)..., 
			num_iterations = 4000, 
			# animation_type = AntsModel.PHEROMONE_ANIM,
			animation_type = AntsModel.PHEROMONE_ANTS_ANIM,
			animate = true,
		)
end

# ╔═╡ 0223727a-0dd0-4f27-9ecd-d67ff4169f53
# begin
# 	run_experiments(
# 		SEARCH_DEPTHS_FIRST_VARIANT,
# 		EXPERIMENT_DEPTHS,
# 		food_coordinates = FOOD_VARIANT_2,
# 		nest_coordinates = NEST_VARIANT_2,
# 		obstacle_coordinates = OBSTACLE_VARIANT_2,
# 		maze_variant = "VARIANT_2",
# 		num_iterations = 8000,
# 	)
# end

# ╔═╡ 8615fffe-1970-4f8a-ab77-fb798411ea25
# begin
# 	run_experiments(
# 		NUM_ANTS_FIRST_VARIANT,
# 		EXPERIMENT_NUM_ANTS,
# 		food_coordinates = FOOD_VARIANT_2,
# 		nest_coordinates = NEST_VARIANT_2,
# 		obstacle_coordinates = OBSTACLE_VARIANT_2,
# 		maze_variant = "VARIANT_2",
# 		num_iterations = 8000,
# 	)
# end

# ╔═╡ 03a047d1-d48b-4558-b433-3f7cc8031e5a
md"""
#### Easy Maze Split Closer
"""

# ╔═╡ d4866da1-2128-4968-a72b-022cdd879516
begin
	FOOD_VARIANT_3 = [(80:90, 1:20), (80:90, 80:100)]
	NEST_VARIANT_3 = [(3:10, 45:55)]
	OBSTACLE_VARIANT_3 = [
			(1:40, 35:35), (40:40, 1:35),
			(1:40, 65:65), (40:40, 65:100),
			(55:55, 25:75),
			(55:100, 25:25), (55:100, 75:75)

		]
end

# ╔═╡ eb092e0b-ee95-47df-904d-4ee34ce05943
begin
	"""
	Animated variant with map defined by `VARIANT_3` variables.
	"""
	
	AntsModel.sim!(
			AntsModel.init_simulation(
				food_coordinates = FOOD_VARIANT_3,
				nest_coordinates = NEST_VARIANT_3,
				obstacle_coordinates = OBSTACLE_VARIANT_3,
				# num_ants = 400,
				# search_depth = 10,
				pheromone_fade_rate = 0.00021,
				search_depth = 50,
				pheromone_power = 0.02,
				difusion_rate = 0.495,
				normalization_parameter = 0.0005,
			)..., 
			num_iterations = 4000, 
			# animation_type = AntsModel.PHEROMONE_ANIM,
			animation_type = AntsModel.PHEROMONE_ANTS_ANIM,
			animate = true,
		)
end

# ╔═╡ 68f84e2f-4f1f-46c0-b4f1-6dce72d6b711


# ╔═╡ 4941ab5c-c9f7-4de0-9711-c81927a52f68
# begin
# 	run_experiments(
# 		SEARCH_DEPTHS_FIRST_VARIANT,
# 		EXPERIMENT_DEPTHS,
# 		food_coordinates = FOOD_VARIANT_3,
# 		nest_coordinates = NEST_VARIANT_3,
# 		obstacle_coordinates = OBSTACLE_VARIANT_3,
# 		maze_variant = "VARIANT_3",
# 		num_iterations = 8000,
# 	)
# end

# ╔═╡ d900a7d0-a07f-4dda-a98f-b8850780ff49
# begin
# 	run_experiments(
# 		NUM_ANTS_FIRST_VARIANT,
# 		EXPERIMENT_NUM_ANTS,
# 		food_coordinates = FOOD_VARIANT_3,
# 		nest_coordinates = NEST_VARIANT_3,
# 		obstacle_coordinates = OBSTACLE_VARIANT_3,
# 		maze_variant = "VARIANT_3",
# 		num_iterations = 8000,
# 	)
# end

# ╔═╡ 5ca84557-316a-47bd-897b-3deacdccface
md"""
#### Two Sided Maze
"""

# ╔═╡ 365fba99-5528-4a23-9a84-a42647fa5d7d
begin
	FOOD_VARIANT_4 = [
			(1:10, 1:25), (1:10, 75:100),
			(90:100, 1:25), (90:100, 75:100),
		]
	NEST_VARIANT_4 = [(45:55, 45:55)]
	OBSTACLE_VARIANT_4 = [
			(20:80, 40:40), (20:80, 60:60),
			(20:20, 1:40), (80:80, 1:40),
			(20:20, 60:100), (80:80, 60:100),

		]
end

# ╔═╡ 4dd90806-ff62-49dc-be11-16cf4e81975a
begin
	"""
	Animated variant with map defined by `VARIANT_4` variables.
	"""
	
	AntsModel.sim!(
			AntsModel.init_simulation(
				food_coordinates = FOOD_VARIANT_4,
				nest_coordinates = NEST_VARIANT_4,
				obstacle_coordinates = OBSTACLE_VARIANT_4,
				# num_ants = 400,
				# search_depth = 10,
				pheromone_fade_rate = 0.00021,
				search_depth = 10,
				pheromone_power = 0.02,
				difusion_rate = 0.495,
				normalization_parameter = 0.0005,
			)..., 
			num_iterations = 4000, 
			# animation_type = AntsModel.PHEROMONE_ANIM,
			animation_type = AntsModel.PHEROMONE_ANTS_ANIM,
			animate = true,
		)
end

# ╔═╡ ea4d58f4-4945-4883-a44a-3dbb19824193
# begin
# 	run_experiments(
# 		SEARCH_DEPTHS_FIRST_VARIANT,
# 		EXPERIMENT_DEPTHS,
# 		food_coordinates = FOOD_VARIANT_4,
# 		nest_coordinates = NEST_VARIANT_4,
# 		obstacle_coordinates = OBSTACLE_VARIANT_4,
# 		maze_variant = "VARIANT_4",
# 		num_iterations = 8000,
# 	)
# end

# ╔═╡ 95fafcd5-9efb-4e29-85ea-d9f0baa09801
# begin
# 	run_experiments(
# 		NUM_ANTS_FIRST_VARIANT,
# 		EXPERIMENT_NUM_ANTS,
# 		food_coordinates = FOOD_VARIANT_4,
# 		nest_coordinates = NEST_VARIANT_4,
# 		obstacle_coordinates = OBSTACLE_VARIANT_4,
# 		maze_variant = "VARIANT_4",
# 		num_iterations = 8000,
# 	)
# end

# ╔═╡ 3d529786-248f-4235-a9a7-454d2454a437
md"""
#### Maze with Fake Branch
"""

# ╔═╡ b399cb54-cf61-4b71-804a-fd4103584293
begin
	FOOD_VARIANT_5 = [(80:90, 1:20)]
	NEST_VARIANT_5 = [(3:10, 45:55)]
	OBSTACLE_VARIANT_5 = [
			(1:60, 35:35), (60:60, 1:35),
			(1:60, 65:65), (60:60, 65:100),
			(75:75, 25:75),
			(75:100, 25:25), (75:100, 75:75)

		]
end

# ╔═╡ cf5d17bc-900a-4420-a863-dbbf8b64d54a
begin
	plot_array = []
	
	food_variants = [
		DEFAULT_FOOD_COORDINATES,
		FOOD_VARIANT_1,
		FOOD_VARIANT_2,
		FOOD_VARIANT_3,
		FOOD_VARIANT_4,
		FOOD_VARIANT_5,
	]
	
	nest_variants = [
		DEFAULT_NEST_COORDINATES,
		NEST_VARIANT_1,
		NEST_VARIANT_2,
		NEST_VARIANT_3,
		NEST_VARIANT_4,
		NEST_VARIANT_5,
	]
	
	obstacle_variants = [
		DEFAULT_OBSTACLE_COORDINATES,
		OBSTACLE_VARIANT_1,
		OBSTACLE_VARIANT_2,
		OBSTACLE_VARIANT_3,
		OBSTACLE_VARIANT_4,
		OBSTACLE_VARIANT_5,
	]
	
	for i in 1:length(food_variants)	
		p = draw_map(
			AntsModel.init_simulation(
					food_coordinates = food_variants[i],
					nest_coordinates = nest_variants[i],
					obstacle_coordinates = obstacle_variants[i]
			)[1:2]...,
		)
		
        push!(plot_array, p)
	end
	
	all_plots = AntsModel.Plots.plot(
		plot_array...,
		layout = (2, 3),
		# showaxis=false,
		title=["var-0" "var-1" "var-2" "var-3" "var-4" "var-5"],
		xlims=(0, 100),
		ylims=(0, 100),
		)

	
	AntsModel.Plots.plot(all_plots,
		plot_title="Varianty prostředí modelu",
		size=(800,600),
	)
end

# ╔═╡ 6732a55d-2ae3-43d2-b229-a404d8a54a15
begin
	"""
	Animated variant with map defined by `VARIANT_5` variables.
	"""
	
	AntsModel.sim!(
			AntsModel.init_simulation(
				food_coordinates = FOOD_VARIANT_5,
				nest_coordinates = NEST_VARIANT_5,
				obstacle_coordinates = OBSTACLE_VARIANT_5,
				# num_ants = 400,
				# search_depth = 10,
				pheromone_fade_rate = 0.00021,
				search_depth = 10,
				pheromone_power = 0.02,
				difusion_rate = 0.495,
				normalization_parameter = 0.0005,
			)..., 
			num_iterations = 4000, 
			# animation_type = AntsModel.PHEROMONE_ANIM,
			animation_type = AntsModel.PHEROMONE_ANTS_ANIM,
			animate = true,
		)
end

# ╔═╡ 97514545-2661-40cd-9127-2d13df72dd0f
# begin
# 	run_experiments(
# 		SEARCH_DEPTHS_FIRST_VARIANT,
# 		EXPERIMENT_DEPTHS,
# 		food_coordinates = FOOD_VARIANT_5,
# 		nest_coordinates = NEST_VARIANT_5,
# 		obstacle_coordinates = OBSTACLE_VARIANT_5,
# 		maze_variant = "VARIANT_5",
# 		num_iterations = 8000,
# 	)
# end

# ╔═╡ a52e86bb-5ad3-4405-8f12-4a23982e69f3
# begin
# 	run_experiments(
# 		NUM_ANTS_FIRST_VARIANT,
# 		EXPERIMENT_NUM_ANTS,
# 		food_coordinates = FOOD_VARIANT_5,
# 		nest_coordinates = NEST_VARIANT_5,
# 		obstacle_coordinates = OBSTACLE_VARIANT_5,
# 		maze_variant = "VARIANT_5",
# 		num_iterations = 8000,
# 	)
# end

# ╔═╡ 2fbedeb7-9e2b-4a83-9008-206c542b7f92
begin
	FOOD_VARIANT_6 = [(10:20, 80:90), (50:60, 10:20)]
	NEST_VARIANT_6 = [(5:10, 5:10), (90:95, 90:95)]
	OBSTACLE_VARIANT_6 = [
			(20:20, 5:25)
		]
end

# ╔═╡ ab709e50-3caf-44ca-81ec-49b48f7dff3c
begin
	"""
	Animated variant with map defined by `VARIANT_6` variables.
	"""
	
	AntsModel.sim!(
			AntsModel.init_simulation(
				food_coordinates = FOOD_VARIANT_6,
				nest_coordinates = NEST_VARIANT_6,
				obstacle_coordinates = OBSTACLE_VARIANT_6,
				# num_ants = 400,
				# search_depth = 10,
				pheromone_fade_rate = 0.00021,
				search_depth = 10,
				pheromone_power = 0.02,
				difusion_rate = 0.495,
				normalization_parameter = 0.0005,
			)..., 
			num_iterations = 4000, 
			# animation_type = AntsModel.PHEROMONE_ANIM,
			animation_type = AntsModel.PHEROMONE_ANTS_ANIM,
			animate = true,
		)
end

# ╔═╡ 00000000-0000-0000-0000-000000000001
PLUTO_PROJECT_TOML_CONTENTS = """
[deps]
Pkg = "44cfe95a-1eb2-52ea-b672-e2afdf69b78f"
"""

# ╔═╡ 00000000-0000-0000-0000-000000000002
PLUTO_MANIFEST_TOML_CONTENTS = """
# This file is machine-generated - editing it directly is not advised

[[ArgTools]]
uuid = "0dad84c5-d112-42e6-8d28-ef12dabb789f"
version = "1.1.1"

[[Artifacts]]
uuid = "56f22d72-fd6d-98f1-02f0-08ddc0907c33"

[[Base64]]
uuid = "2a0f44e3-6c83-55bd-87e4-b1978d98bd5f"

[[Dates]]
deps = ["Printf"]
uuid = "ade2ca70-3891-5945-98fb-dc099432e06a"

[[Downloads]]
deps = ["ArgTools", "FileWatching", "LibCURL", "NetworkOptions"]
uuid = "f43a241f-c20a-4ad4-852c-f6b1247861c6"
version = "1.6.0"

[[FileWatching]]
uuid = "7b1f6079-737a-58dc-b8bc-7a2ca5c1b5ee"

[[InteractiveUtils]]
deps = ["Markdown"]
uuid = "b77e0a4c-d291-57a0-90e8-8db25a27a240"

[[LibCURL]]
deps = ["LibCURL_jll", "MozillaCACerts_jll"]
uuid = "b27032c2-a3e7-50c8-80cd-2d36dbcbfd21"
version = "0.6.3"

[[LibCURL_jll]]
deps = ["Artifacts", "LibSSH2_jll", "Libdl", "MbedTLS_jll", "Zlib_jll", "nghttp2_jll"]
uuid = "deac9b47-8bc7-5906-a0fe-35ac56dc84c0"
version = "7.84.0+0"

[[LibGit2]]
deps = ["Base64", "NetworkOptions", "Printf", "SHA"]
uuid = "76f85450-5226-5b5a-8eaa-529ad045b433"

[[LibSSH2_jll]]
deps = ["Artifacts", "Libdl", "MbedTLS_jll"]
uuid = "29816b5a-b9ab-546f-933c-edad1886dfa8"
version = "1.10.2+0"

[[Libdl]]
uuid = "8f399da3-3557-5675-b5ff-fb832c97cbdb"

[[Logging]]
uuid = "56ddb016-857b-54e1-b83d-db4d58db5568"

[[Markdown]]
deps = ["Base64"]
uuid = "d6f4376e-aef5-505a-96c1-9c027394607a"

[[MbedTLS_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "c8ffd9c3-330d-5841-b78e-0817d7145fa1"
version = "2.28.0+0"

[[MozillaCACerts_jll]]
uuid = "14a3606d-f60d-562e-9121-12d972cd8159"
version = "2022.2.1"

[[NetworkOptions]]
uuid = "ca575930-c2e3-43a9-ace4-1e988b2c1908"
version = "1.2.0"

[[Pkg]]
deps = ["Artifacts", "Dates", "Downloads", "LibGit2", "Libdl", "Logging", "Markdown", "Printf", "REPL", "Random", "SHA", "Serialization", "TOML", "Tar", "UUIDs", "p7zip_jll"]
uuid = "44cfe95a-1eb2-52ea-b672-e2afdf69b78f"
version = "1.8.0"

[[Printf]]
deps = ["Unicode"]
uuid = "de0858da-6303-5e67-8744-51eddeeeb8d7"

[[REPL]]
deps = ["InteractiveUtils", "Markdown", "Sockets", "Unicode"]
uuid = "3fa0cd96-eef1-5676-8a61-b3b8758bbffb"

[[Random]]
deps = ["SHA", "Serialization"]
uuid = "9a3f8284-a2c9-5f02-9a11-845980a1fd5c"

[[SHA]]
uuid = "ea8e919c-243c-51af-8825-aaa63cd721ce"
version = "0.7.0"

[[Serialization]]
uuid = "9e88b42a-f829-5b0c-bbe9-9e923198166b"

[[Sockets]]
uuid = "6462fe0b-24de-5631-8697-dd941f90decc"

[[TOML]]
deps = ["Dates"]
uuid = "fa267f1f-6049-4f14-aa54-33bafae1ed76"
version = "1.0.0"

[[Tar]]
deps = ["ArgTools", "SHA"]
uuid = "a4e569a6-e804-4fa4-b0f3-eef7a1d5b13e"
version = "1.10.0"

[[UUIDs]]
deps = ["Random", "SHA"]
uuid = "cf7118a7-6976-5b1a-9a39-7adc72f591a4"

[[Unicode]]
uuid = "4ec0a83e-493e-50e2-b9ac-8f72acf5a8f5"

[[Zlib_jll]]
deps = ["Libdl"]
uuid = "83775a58-1f1d-513f-b197-d71354ab007a"
version = "1.2.12+3"

[[nghttp2_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "8e850ede-7688-5339-a07c-302acd2aaf8d"
version = "1.48.0+0"

[[p7zip_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "3f19e933-33d8-53b3-aaab-bd5110c3b7a0"
version = "17.4.0+0"
"""

# ╔═╡ Cell order:
# ╠═78142762-ae33-11ed-3e6b-75b2fc3af2b5
# ╠═9cb64897-e862-444b-8435-54a90fc8690c
# ╠═f03578ab-8ab0-4564-b7e3-6c368b61eb5a
# ╠═cf5d17bc-900a-4420-a863-dbbf8b64d54a
# ╠═b94e4c8c-5335-4e99-b92a-28d5a5b00b1b
# ╠═1f1d6b11-6d87-4ff2-81c7-0f2ba2ceffec
# ╠═23d7831b-233e-457b-839c-81955bd824a7
# ╠═d661c668-fa91-4964-8817-22cdba31c38b
# ╠═5428328c-f34f-4221-a16d-bc343eff8a4b
# ╠═59fae562-b2a9-4926-89d2-10f94b936fb8
# ╟─3a0450e1-7009-4494-a8f2-514409a36727
# ╟─2aa49e8a-0323-491d-a802-64ecbed69a70
# ╠═81732f05-ea97-402e-8f4c-365814fd4280
# ╠═6fef22b7-c441-459a-96d5-143d91674d31
# ╟─3dfd629a-49f5-4d2a-a56f-1fc67ab9bdba
# ╟─341fae45-5ce5-486e-beb3-6e38592b0ae1
# ╠═2f016ebe-9f08-4948-a995-af037341aab0
# ╟─bb39e826-5bc0-46b7-8a95-22d84181e2ff
# ╠═be442933-4574-4abc-a692-fc94fda5edf7
# ╠═22565199-80fe-4862-ab38-f397f63c706f
# ╠═16d61d98-75f0-47c8-8da9-18f954a22054
# ╟─049b60e2-13e3-4c0d-bb58-9ef415328abd
# ╠═9c100f25-a7c0-4a19-97ef-7df25b23f222
# ╠═359185c3-32cf-4418-b791-dd122d0be554
# ╠═3745f7aa-ae46-4307-bfa8-47bf518dde8f
# ╠═2372d2b9-d30a-4772-b826-54c03d980f7e
# ╠═7e1df792-4b2d-4816-ae84-a5adc1ce9e09
# ╠═f4bd62af-e81f-467e-b8ce-ca19d47e2dee
# ╠═4125fd48-1b77-4f32-a5ed-79a59797edba
# ╠═0223727a-0dd0-4f27-9ecd-d67ff4169f53
# ╠═8615fffe-1970-4f8a-ab77-fb798411ea25
# ╟─03a047d1-d48b-4558-b433-3f7cc8031e5a
# ╠═d4866da1-2128-4968-a72b-022cdd879516
# ╠═eb092e0b-ee95-47df-904d-4ee34ce05943
# ╠═68f84e2f-4f1f-46c0-b4f1-6dce72d6b711
# ╠═4941ab5c-c9f7-4de0-9711-c81927a52f68
# ╠═d900a7d0-a07f-4dda-a98f-b8850780ff49
# ╟─5ca84557-316a-47bd-897b-3deacdccface
# ╠═365fba99-5528-4a23-9a84-a42647fa5d7d
# ╠═4dd90806-ff62-49dc-be11-16cf4e81975a
# ╠═ea4d58f4-4945-4883-a44a-3dbb19824193
# ╠═95fafcd5-9efb-4e29-85ea-d9f0baa09801
# ╟─3d529786-248f-4235-a9a7-454d2454a437
# ╠═b399cb54-cf61-4b71-804a-fd4103584293
# ╠═6732a55d-2ae3-43d2-b229-a404d8a54a15
# ╠═97514545-2661-40cd-9127-2d13df72dd0f
# ╠═a52e86bb-5ad3-4405-8f12-4a23982e69f3
# ╠═2fbedeb7-9e2b-4a83-9008-206c542b7f92
# ╠═ab709e50-3caf-44ca-81ec-49b48f7dff3c
# ╟─00000000-0000-0000-0000-000000000001
# ╟─00000000-0000-0000-0000-000000000002
