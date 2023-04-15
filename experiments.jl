### A Pluto.jl notebook ###
# v0.19.22

using Markdown
using InteractiveUtils

# ╔═╡ 668bb938-f4e3-473c-aced-599a759ba645
begin
	using Makie
	using CairoMakie
	# using AbstractPlotting.MakieLayout
	# using AbstractPlotting
	using Colors, ColorSchemes
end

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

# ╔═╡ bf268a10-ac94-452a-8436-834e7befa111
function draw_map_makie(
		simulation_map, 
		ants,
		axs;
		title::String = "",
	)

	map_objects_colors = Dict(
		AntsModel.OBSTACLE => AntsModel.hex2rgba(0xFF00F0),
		AntsModel.FREE => AntsModel.hex2rgba(0x000000),
		AntsModel.NEST => AntsModel.hex2rgba(0xFF4500),
		AntsModel.FOOD => AntsModel.hex2rgba(0x7A871E),
		AntsModel.TRAP => AntsModel.hex2rgba(0x159874)
	)

	FOOD_PHER_COLOR = (250, 0, 0)
	NEST_PHER_COLOR = (0, 250, 0)

	set_color(rgb, alpha) = AntsModel.Plots.RGBA(rgb[1], rgb[2], rgb[3], alpha)
	
		# Sets color based on the pheromones concentrations. 
	set_pheromone_color(food_pheromone, nest_pheromone) =
		(set_color(FOOD_PHER_COLOR .* food_pheromone .+ 
				NEST_PHER_COLOR .* nest_pheromone, 
			#max(food_pheromone, nest_pheromone)^color_normalization
			((food_pheromone + nest_pheromone) / 2)^1
			)
		)
		
	# Function to determine color of the pixel based on the map object and pheromones.
	color_map_objects_pheromones(object, food_pheromone, nest_pheromone) = 
		(food_pheromone == 0 && nest_pheromone == 0 ) ||
		(object != AntsModel.FREE) ?
			map_objects_colors[object] : 
			set_pheromone_color(food_pheromone, nest_pheromone)

	axs.yreversed = true

	hidedecorations!(axs)  # hides ticks, grid and lables
	hidespines!(axs) 


	unique_values = sort(unique(simulation_map.map_objects))

	mycmap = ColorScheme([map_objects_colors[x] for x in unique_values])


	return heatmap!(axs, 
		simulation_map.map_objects,
		colormap=cgrad(mycmap, size(unique_values)[1], categorical=true, )#rev=true),
	)
	
	# Create a heatmap plot for the simulation map
	# return heatmap!(axs, 
	# 		map(set_pheromone_color, 
	# 			simulation_map.food_pheromones, simulation_map.nest_pheromones),
			# map(s -> map_objects_colors[s], simulation_map.map_objects), 
			# colorrange=AntsModel.hex2rgba(0x000000), 
			# colorrange=(0, 1),
			# colormap=Reverse(:viridis)
	# )
end

# ╔═╡ cf5d17bc-900a-4420-a863-dbbf8b64d54a
# begin
# 	plot_array = []
	
# 	food_variants = [
# 		DEFAULT_FOOD_COORDINATES,
# 		FOOD_VARIANT_1,
# 		FOOD_VARIANT_2,
# 		FOOD_VARIANT_3,
# 		FOOD_VARIANT_4,
# 		FOOD_VARIANT_5,
# 	]
	
# 	nest_variants = [
# 		DEFAULT_NEST_COORDINATES,
# 		NEST_VARIANT_1,
# 		NEST_VARIANT_2,
# 		NEST_VARIANT_3,
# 		NEST_VARIANT_4,
# 		NEST_VARIANT_5,
# 	]
	
# 	obstacle_variants = [
# 		DEFAULT_OBSTACLE_COORDINATES,
# 		OBSTACLE_VARIANT_1,
# 		OBSTACLE_VARIANT_2,
# 		OBSTACLE_VARIANT_3,
# 		OBSTACLE_VARIANT_4,
# 		OBSTACLE_VARIANT_5,
# 	]
	
# 	for i in 1:length(food_variants)	
# 		p = draw_map(
# 			AntsModel.init_simulation(
# 					food_coordinates = food_variants[i],
# 					nest_coordinates = nest_variants[i],
# 					obstacle_coordinates = obstacle_variants[i]
# 			)[1:2]...,
# 		)
		
#         push!(plot_array, p)
# 	end
	
# 	all_plots = AntsModel.Plots.plot(
# 		plot_array...,
# 		layout = (2, 3),
# 		showaxis=false,
# 		title=["var-0" "var-1" "var-2" "var-3" "var-4" "var-5"],
# 		xlims=(0, 100),
# 		ylims=(0, 100),
# 		)

	
# 	AntsModel.Plots.plot(all_plots,
# 		plot_title="Varianty prostředí modelu",
# 		size=(800,600),
# 	)
# end

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
# begin
# 	"""
# 	Animated model with default map and parameters.
# 	"""
	
# 	AntsModel.sim!(
# 			AntsModel.init_simulation(
# 				num_ants = 400,
# 				search_depth = 10,
# 			)..., 
# 			num_iterations = 4000, 
# 			# animation_type = AntsModel.PHEROMONE_ANIM,
# 			animation_type = AntsModel.PHEROMONE_ANTS_ANIM,
# 			animate = true,
# 		)
# end

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
# begin
# 	"""
# 	Animated variant with map defined by `VARIANT_1` variables.
# 	"""
	
# 	AntsModel.sim!(
# 			AntsModel.init_simulation(
# 				food_coordinates = FOOD_VARIANT_1,
# 				nest_coordinates = NEST_VARIANT_1,
# 				obstacle_coordinates = OBSTACLE_VARIANT_1,
# 				# num_ants = 400,
# 				# search_depth = 10,
# 				pheromone_fade_rate = 0.00021,
# 				search_depth = 10,
# 				pheromone_power = 0.02,
# 				difusion_rate = 0.495,
# 				normalization_parameter = 0.0005,
# 			)..., 
# 			num_iterations = 4000, 
# 			# animation_type = AntsModel.PHEROMONE_ANIM,
# 			animation_type = AntsModel.PHEROMONE_ANTS_ANIM,
# 			animate = true,
# 		)
# end

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
# begin
# 	"""
# 	Animated variant with map defined by `VARIANT_2` variables.
# 	"""
	
# 	AntsModel.sim!(
# 			AntsModel.init_simulation(
# 				food_coordinates = FOOD_VARIANT_2,
# 				nest_coordinates = NEST_VARIANT_2,
# 				obstacle_coordinates = OBSTACLE_VARIANT_2,
# 				# num_ants = 400,
# 				# search_depth = 10,
# 				pheromone_fade_rate = 0.00021,
# 				search_depth = 10,
# 				pheromone_power = 0.02,
# 				difusion_rate = 0.495,
# 				normalization_parameter = 0.0005,
# 			)..., 
# 			num_iterations = 4000, 
# 			# animation_type = AntsModel.PHEROMONE_ANIM,
# 			animation_type = AntsModel.PHEROMONE_ANTS_ANIM,
# 			animate = true,
# 		)
# end

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
# begin
# 	"""
# 	Animated variant with map defined by `VARIANT_3` variables.
# 	"""
	
# 	AntsModel.sim!(
# 			AntsModel.init_simulation(
# 				food_coordinates = FOOD_VARIANT_3,
# 				nest_coordinates = NEST_VARIANT_3,
# 				obstacle_coordinates = OBSTACLE_VARIANT_3,
# 				# num_ants = 400,
# 				# search_depth = 10,
# 				pheromone_fade_rate = 0.00021,
# 				search_depth = 10,
# 				pheromone_power = 0.02,
# 				difusion_rate = 0.495,
# 				normalization_parameter = 0.0005,
# 			)..., 
# 			num_iterations = 4000, 
# 			# animation_type = AntsModel.PHEROMONE_ANIM,
# 			animation_type = AntsModel.PHEROMONE_ANTS_ANIM,
# 			animate = true,
# 		)
# end

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
# begin
# 	"""
# 	Animated variant with map defined by `VARIANT_4` variables.
# 	"""
	
# 	AntsModel.sim!(
# 			AntsModel.init_simulation(
# 				food_coordinates = FOOD_VARIANT_4,
# 				nest_coordinates = NEST_VARIANT_4,
# 				obstacle_coordinates = OBSTACLE_VARIANT_4,
# 				# num_ants = 400,
# 				# search_depth = 10,
# 				pheromone_fade_rate = 0.00021,
# 				search_depth = 10,
# 				pheromone_power = 0.02,
# 				difusion_rate = 0.495,
# 				normalization_parameter = 0.0005,
# 			)..., 
# 			num_iterations = 4000, 
# 			# animation_type = AntsModel.PHEROMONE_ANIM,
# 			animation_type = AntsModel.PHEROMONE_ANTS_ANIM,
# 			animate = true,
# 		)
# end

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

# ╔═╡ 3f814e35-543b-47e6-9b05-c4409de5d02e
function squares_layout()
    # Call the function for each variant and combine the plots
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

	height = 2
	width = 3

	# Makie
    letters = reshape(collect('a':'f'), (width, height))
    fig = Figure(resolution=(600, 400), #font="CMU Serif",
        backgroundcolor=:snow2)
    axs = [Axis(fig[j, i], aspect=DataAspect()) for i = 1:width, j = 1:height]
	
	hms = [draw_map_makie(AntsModel.init_simulation(
						food_coordinates = food_variants[(j-1)*width + i],
						nest_coordinates = nest_variants[(j-1)*width + i],
						obstacle_coordinates = obstacle_variants[(j-1)*width + i]
				)[1:2]...,
				axs[i, j],
				title = "Variant-$i") 
		for i = 1:width, j = 1:height
	]

	cbar = Colorbar(fig[1:2, 4], hms[2], label = "Objekty na mapě", height=Relative(3/4))

	
	cbar.ticks = (
		[-0.66, 0.11, 0.88, 1.55], 
		["Překážka", "Volno", "Hnízdo","Potrava"]
	)


	label = Label(
			fig[1:2, 1:4, Top()],
			"Varianty prostředí modelu",
	        padding=(0, 0, 30, 0),
		)

	new_fontsize = 25
	label.textsize = new_fontsize
	
	[Label(
		fig[j, i, Top()], 
		"($(letters[i, j])) var-$((j-1)*width + i - 1)",
		fontsize=10,
		padding=(0, 0, 0, 0),
		# halign=:center,
		valign=:bottom,
		) for i = 1:width, j = 1:height
	]

    colgap!(fig.layout, 10)
    rowgap!(fig.layout, 0)

    fig

	save("test.png", fig)
end

# ╔═╡ 5c9f12a6-01a8-4a85-a8b4-93cad94bff2a
squares_layout()

# ╔═╡ 6732a55d-2ae3-43d2-b229-a404d8a54a15
# begin
# 	"""
# 	Animated variant with map defined by `VARIANT_5` variables.
# 	"""
	
# 	AntsModel.sim!(
# 			AntsModel.init_simulation(
# 				food_coordinates = FOOD_VARIANT_5,
# 				nest_coordinates = NEST_VARIANT_5,
# 				obstacle_coordinates = OBSTACLE_VARIANT_5,
# 				# num_ants = 400,
# 				# search_depth = 10,
# 				pheromone_fade_rate = 0.00021,
# 				search_depth = 10,
# 				pheromone_power = 0.02,
# 				difusion_rate = 0.495,
# 				normalization_parameter = 0.0005,
# 			)..., 
# 			num_iterations = 4000, 
# 			# animation_type = AntsModel.PHEROMONE_ANIM,
# 			animation_type = AntsModel.PHEROMONE_ANTS_ANIM,
# 			animate = true,
# 		)
# end

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
# begin
# 	"""
# 	Animated variant with map defined by `VARIANT_6` variables.
# 	"""
	
# 	AntsModel.sim!(
# 			AntsModel.init_simulation(
# 				food_coordinates = FOOD_VARIANT_6,
# 				nest_coordinates = NEST_VARIANT_6,
# 				obstacle_coordinates = OBSTACLE_VARIANT_6,
# 				# num_ants = 400,
# 				# search_depth = 10,
# 				pheromone_fade_rate = 0.00021,
# 				search_depth = 10,
# 				pheromone_power = 0.02,
# 				difusion_rate = 0.495,
# 				normalization_parameter = 0.0005,
# 			)..., 
# 			num_iterations = 4000, 
# 			# animation_type = AntsModel.PHEROMONE_ANIM,
# 			animation_type = AntsModel.PHEROMONE_ANTS_ANIM,
# 			animate = true,
# 		)
# end

# ╔═╡ 00000000-0000-0000-0000-000000000001
PLUTO_PROJECT_TOML_CONTENTS = """
[deps]
CairoMakie = "13f3f980-e62b-5c42-98c6-ff1f3baf88f0"
ColorSchemes = "35d6a980-a343-548e-a6ea-1d62b119f2f4"
Colors = "5ae59095-9a9b-59fe-a467-6f913c188581"
Makie = "ee78f7c6-11fb-53f2-987a-cfe4a2b5a57a"
Pkg = "44cfe95a-1eb2-52ea-b672-e2afdf69b78f"

[compat]
CairoMakie = "~0.6.3"
ColorSchemes = "~3.20.0"
Colors = "~0.12.10"
Makie = "~0.15.0"
"""

# ╔═╡ 00000000-0000-0000-0000-000000000002
PLUTO_MANIFEST_TOML_CONTENTS = """
# This file is machine-generated - editing it directly is not advised

[[AbstractFFTs]]
deps = ["ChainRulesCore", "LinearAlgebra"]
git-tree-sha1 = "16b6dbc4cf7caee4e1e75c49485ec67b667098a0"
uuid = "621f4979-c628-5d54-868e-fcf4e3e8185c"
version = "1.3.1"

[[AbstractTrees]]
git-tree-sha1 = "03e0550477d86222521d254b741d470ba17ea0b5"
uuid = "1520ce14-60c1-5f80-bbc7-55ef81b5835c"
version = "0.3.4"

[[Adapt]]
deps = ["LinearAlgebra", "Requires"]
git-tree-sha1 = "cc37d689f599e8df4f464b2fa3870ff7db7492ef"
uuid = "79e6a3ab-5dfb-504d-930d-738a2a938a0e"
version = "3.6.1"

[[Animations]]
deps = ["Colors"]
git-tree-sha1 = "e81c509d2c8e49592413bfb0bb3b08150056c79d"
uuid = "27a7e980-b3e6-11e9-2bcd-0b925532e340"
version = "0.4.1"

[[ArgTools]]
uuid = "0dad84c5-d112-42e6-8d28-ef12dabb789f"
version = "1.1.1"

[[ArrayInterface]]
deps = ["Adapt", "LinearAlgebra", "Requires", "SnoopPrecompile", "SparseArrays", "SuiteSparse"]
git-tree-sha1 = "38911c7737e123b28182d89027f4216cfc8a9da7"
uuid = "4fba245c-0d91-5ea0-9b3e-6abc04ee57a9"
version = "7.4.3"

[[Artifacts]]
uuid = "56f22d72-fd6d-98f1-02f0-08ddc0907c33"

[[Automa]]
deps = ["Printf", "ScanByte", "TranscodingStreams"]
git-tree-sha1 = "d50976f217489ce799e366d9561d56a98a30d7fe"
uuid = "67c07d97-cdcb-5c2c-af73-a7f9c32a568b"
version = "0.8.2"

[[AxisAlgorithms]]
deps = ["LinearAlgebra", "Random", "SparseArrays", "WoodburyMatrices"]
git-tree-sha1 = "66771c8d21c8ff5e3a93379480a2307ac36863f7"
uuid = "13072b0f-2c55-5437-9ae7-d433b7a33950"
version = "1.0.1"

[[AxisArrays]]
deps = ["Dates", "IntervalSets", "IterTools", "RangeArrays"]
git-tree-sha1 = "1dd4d9f5beebac0c03446918741b1a03dc5e5788"
uuid = "39de3d68-74b9-583c-8d2d-e117c070f3a9"
version = "0.4.6"

[[Base64]]
uuid = "2a0f44e3-6c83-55bd-87e4-b1978d98bd5f"

[[Bzip2_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "19a35467a82e236ff51bc17a3a44b69ef35185a2"
uuid = "6e34b625-4abd-537c-b88f-471c36dfa7a0"
version = "1.0.8+0"

[[CEnum]]
git-tree-sha1 = "eb4cb44a499229b3b8426dcfb5dd85333951ff90"
uuid = "fa961155-64e5-5f13-b03f-caf6b980ea82"
version = "0.4.2"

[[Cairo]]
deps = ["Cairo_jll", "Colors", "Glib_jll", "Graphics", "Libdl", "Pango_jll"]
git-tree-sha1 = "d0b3f8b4ad16cb0a2988c6788646a5e6a17b6b1b"
uuid = "159f3aea-2a34-519c-b102-8c37f9878175"
version = "1.0.5"

[[CairoMakie]]
deps = ["Base64", "Cairo", "Colors", "FFTW", "FileIO", "FreeType", "GeometryBasics", "LinearAlgebra", "Makie", "SHA", "StaticArrays"]
git-tree-sha1 = "7d37b0bd71e7f3397004b925927dfa8dd263439c"
uuid = "13f3f980-e62b-5c42-98c6-ff1f3baf88f0"
version = "0.6.3"

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
git-tree-sha1 = "485193efd2176b88e6622a39a246f8c5b600e74e"
uuid = "9e997f8a-9a97-42d5-a9f1-ce6bfc15e2c0"
version = "0.1.6"

[[ColorBrewer]]
deps = ["Colors", "JSON", "Test"]
git-tree-sha1 = "61c5334f33d91e570e1d0c3eb5465835242582c4"
uuid = "a2cac450-b92f-5266-8821-25eda20663c8"
version = "0.4.0"

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
git-tree-sha1 = "7a60c856b9fa189eb34f5f8a6f6b5529b7942957"
uuid = "34da2185-b29b-5c13-b0c7-acf172513d20"
version = "4.6.1"

[[CompilerSupportLibraries_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "e66e0078-7015-5450-92f7-15fbd957f2ae"
version = "0.5.2+0"

[[Contour]]
deps = ["StaticArrays"]
git-tree-sha1 = "9f02045d934dc030edad45944ea80dbd1f0ebea7"
uuid = "d38c429a-6771-53c6-b99e-75d170b6e991"
version = "0.5.7"

[[DataAPI]]
git-tree-sha1 = "e8119c1a33d267e16108be441a287a6981ba1630"
uuid = "9a962f9c-6df0-11e9-0e5d-c546b8b5ee8a"
version = "1.14.0"

[[DataStructures]]
deps = ["Compat", "InteractiveUtils", "OrderedCollections"]
git-tree-sha1 = "d1fff3a548102f48987a52a2e0d114fa97d730f0"
uuid = "864edb3b-99cc-5e75-8d2d-829cb0a9cfe8"
version = "0.18.13"

[[DataValueInterfaces]]
git-tree-sha1 = "bfc1187b79289637fa0ef6d4436ebdfe6905cbd6"
uuid = "e2d170a0-9d28-54be-80f0-106bbe20a464"
version = "1.0.0"

[[Dates]]
deps = ["Printf"]
uuid = "ade2ca70-3891-5945-98fb-dc099432e06a"

[[DensityInterface]]
deps = ["InverseFunctions", "Test"]
git-tree-sha1 = "80c3e8639e3353e5d2912fb3a1916b8455e2494b"
uuid = "b429d917-457f-4dbc-8f4c-0cc954292b1d"
version = "0.4.0"

[[Distributed]]
deps = ["Random", "Serialization", "Sockets"]
uuid = "8ba89e20-285c-5b6f-9357-94700520ee1b"

[[Distributions]]
deps = ["ChainRulesCore", "DensityInterface", "FillArrays", "LinearAlgebra", "PDMats", "Printf", "QuadGK", "Random", "SparseArrays", "SpecialFunctions", "Statistics", "StatsBase", "StatsFuns", "Test"]
git-tree-sha1 = "13027f188d26206b9e7b863036f87d2f2e7d013a"
uuid = "31c24e10-a181-5473-b8eb-7969acd0382f"
version = "0.25.87"

[[DocStringExtensions]]
deps = ["LibGit2"]
git-tree-sha1 = "b19534d1895d702889b219c382a6e18010797f0b"
uuid = "ffbed154-4ef7-542d-bbb7-c09d3a79fcae"
version = "0.8.6"

[[Downloads]]
deps = ["ArgTools", "FileWatching", "LibCURL", "NetworkOptions"]
uuid = "f43a241f-c20a-4ad4-852c-f6b1247861c6"
version = "1.6.0"

[[EarCut_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "e3290f2d49e661fbd94046d7e3726ffcb2d41053"
uuid = "5ae413db-bbd1-5e63-b57d-d24a61df00f5"
version = "2.2.4+0"

[[EllipsisNotation]]
deps = ["StaticArrayInterface"]
git-tree-sha1 = "d89f0d98f6296a08b73fdfed559f8e86f871cc06"
uuid = "da5c29d0-fa7d-589e-88eb-ea29b0a81949"
version = "1.7.0"

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

[[FFTW]]
deps = ["AbstractFFTs", "FFTW_jll", "LinearAlgebra", "MKL_jll", "Preferences", "Reexport"]
git-tree-sha1 = "f9818144ce7c8c41edf5c4c179c684d92aa4d9fe"
uuid = "7a1cc6ca-52ef-59f5-83cd-3a7055c09341"
version = "1.6.0"

[[FFTW_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "c6033cc3892d0ef5bb9cd29b7f2f0331ea5184ea"
uuid = "f5851436-0d7a-5f13-b9de-f02708fd171a"
version = "3.3.10+0"

[[FileIO]]
deps = ["Pkg", "Requires", "UUIDs"]
git-tree-sha1 = "7be5f99f7d15578798f338f5433b6c432ea8037b"
uuid = "5789e2e9-d7fb-5bc7-8068-2c6fae9b9549"
version = "1.16.0"

[[FileWatching]]
uuid = "7b1f6079-737a-58dc-b8bc-7a2ca5c1b5ee"

[[FillArrays]]
deps = ["LinearAlgebra", "Random", "SparseArrays", "Statistics"]
git-tree-sha1 = "fc86b4fd3eff76c3ce4f5e96e2fdfa6282722885"
uuid = "1a297f60-69ca-5386-bcde-b61e274b549b"
version = "1.0.0"

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

[[FreeType]]
deps = ["CEnum", "FreeType2_jll"]
git-tree-sha1 = "cabd77ab6a6fdff49bfd24af2ebe76e6e018a2b4"
uuid = "b38be410-82b0-50bf-ab77-7b57e271db43"
version = "4.0.0"

[[FreeType2_jll]]
deps = ["Artifacts", "Bzip2_jll", "JLLWrappers", "Libdl", "Pkg", "Zlib_jll"]
git-tree-sha1 = "87eb71354d8ec1a96d4a7636bd57a7347dde3ef9"
uuid = "d7e528f0-a631-5988-bf34-fe36492bcfd7"
version = "2.10.4+0"

[[FreeTypeAbstraction]]
deps = ["ColorVectorSpace", "Colors", "FreeType", "GeometryBasics", "StaticArrays"]
git-tree-sha1 = "d51e69f0a2f8a3842bca4183b700cf3d9acce626"
uuid = "663a7486-cb36-511b-a19d-713bb74d65c9"
version = "0.9.1"

[[FriBidi_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "aa31987c2ba8704e23c6c8ba8a4f769d5d7e4f91"
uuid = "559328eb-81f9-559d-9380-de523a88c83c"
version = "1.0.10+0"

[[GeometryBasics]]
deps = ["EarCut_jll", "IterTools", "LinearAlgebra", "StaticArrays", "StructArrays", "Tables"]
git-tree-sha1 = "4136b8a5668341e58398bb472754bff4ba0456ff"
uuid = "5c1252a2-5f33-56bf-86c9-59e7332b4326"
version = "0.3.12"

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

[[Graphics]]
deps = ["Colors", "LinearAlgebra", "NaNMath"]
git-tree-sha1 = "d61890399bc535850c4bf08e4e0d3a7ad0f21cbd"
uuid = "a2bd30eb-e257-5431-a919-1863eab51364"
version = "1.1.2"

[[Graphite2_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "344bf40dcab1073aca04aa0df4fb092f920e4011"
uuid = "3b182d85-2403-5c21-9c21-1e1f0cc25472"
version = "1.3.14+0"

[[GridLayoutBase]]
deps = ["GeometryBasics", "InteractiveUtils", "Match", "Observables"]
git-tree-sha1 = "d44945bdc7a462fa68bb847759294669352bd0a4"
uuid = "3955a311-db13-416c-9275-1d80ed98e5e9"
version = "0.5.7"

[[Grisu]]
git-tree-sha1 = "53bb909d1151e57e2484c3d1b53e19552b887fb2"
uuid = "42e2da0e-8278-4e71-bc24-59509adca0fe"
version = "1.0.2"

[[HarfBuzz_jll]]
deps = ["Artifacts", "Cairo_jll", "Fontconfig_jll", "FreeType2_jll", "Glib_jll", "Graphite2_jll", "JLLWrappers", "Libdl", "Libffi_jll", "Pkg"]
git-tree-sha1 = "129acf094d168394e80ee1dc4bc06ec835e510a3"
uuid = "2e76f6c2-a576-52d4-95c1-20adfe4de566"
version = "2.8.1+1"

[[IfElse]]
git-tree-sha1 = "debdd00ffef04665ccbb3e150747a77560e8fad1"
uuid = "615f187c-cbe4-4ef1-ba3b-2fcf58d6d173"
version = "0.1.1"

[[ImageAxes]]
deps = ["AxisArrays", "ImageBase", "ImageCore", "Reexport", "SimpleTraits"]
git-tree-sha1 = "c54b581a83008dc7f292e205f4c409ab5caa0f04"
uuid = "2803e5a7-5153-5ecf-9a86-9b4c37f5f5ac"
version = "0.6.10"

[[ImageBase]]
deps = ["ImageCore", "Reexport"]
git-tree-sha1 = "b51bb8cae22c66d0f6357e3bcb6363145ef20835"
uuid = "c817782e-172a-44cc-b673-b171935fbb9e"
version = "0.1.5"

[[ImageCore]]
deps = ["AbstractFFTs", "ColorVectorSpace", "Colors", "FixedPointNumbers", "Graphics", "MappedArrays", "MosaicViews", "OffsetArrays", "PaddedViews", "Reexport"]
git-tree-sha1 = "acf614720ef026d38400b3817614c45882d75500"
uuid = "a09fc81d-aa75-5fe9-8630-4744c3626534"
version = "0.9.4"

[[ImageIO]]
deps = ["FileIO", "Netpbm", "PNGFiles"]
git-tree-sha1 = "0d6d09c28d67611c68e25af0c2df7269c82b73c7"
uuid = "82e4d734-157c-48bb-816b-45c225c6df19"
version = "0.4.1"

[[ImageMetadata]]
deps = ["AxisArrays", "ImageAxes", "ImageBase", "ImageCore"]
git-tree-sha1 = "36cbaebed194b292590cba2593da27b34763804a"
uuid = "bc367c6b-8a6b-528e-b4bd-a4b897500b49"
version = "0.9.8"

[[IndirectArrays]]
git-tree-sha1 = "012e604e1c7458645cb8b436f8fba789a51b257f"
uuid = "9b13fd28-a010-5f03-acff-a1bbcff69959"
version = "1.0.0"

[[IntelOpenMP_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "d979e54b71da82f3a65b62553da4fc3d18c9004c"
uuid = "1d5cc7b8-4909-519e-a0f8-d0f5ad9712d0"
version = "2018.0.3+2"

[[InteractiveUtils]]
deps = ["Markdown"]
uuid = "b77e0a4c-d291-57a0-90e8-8db25a27a240"

[[Interpolations]]
deps = ["Adapt", "AxisAlgorithms", "ChainRulesCore", "LinearAlgebra", "OffsetArrays", "Random", "Ratios", "Requires", "SharedArrays", "SparseArrays", "StaticArrays", "WoodburyMatrices"]
git-tree-sha1 = "721ec2cf720536ad005cb38f50dbba7b02419a15"
uuid = "a98d9a8b-a2ab-59e6-89dd-64a1c18fca59"
version = "0.14.7"

[[IntervalSets]]
deps = ["Dates", "EllipsisNotation", "Statistics"]
git-tree-sha1 = "bcf640979ee55b652f3b01650444eb7bbe3ea837"
uuid = "8197267c-284f-5f27-9208-e0e47529a953"
version = "0.5.4"

[[InverseFunctions]]
deps = ["Test"]
git-tree-sha1 = "49510dfcb407e572524ba94aeae2fced1f3feb0f"
uuid = "3587e190-3f89-42d0-90ee-14403ec27112"
version = "0.1.8"

[[IrrationalConstants]]
git-tree-sha1 = "7fd44fd4ff43fc60815f8e764c0f352b83c49151"
uuid = "92d709cd-6900-40b7-9082-c6be49f344b6"
version = "0.1.1"

[[Isoband]]
deps = ["isoband_jll"]
git-tree-sha1 = "f9b6d97355599074dc867318950adaa6f9946137"
uuid = "f1662d9f-8043-43de-a69a-05efc1cc6ff4"
version = "0.1.1"

[[IterTools]]
git-tree-sha1 = "fa6287a4469f5e048d763df38279ee729fbd44e5"
uuid = "c8e1da08-722c-5040-9ed9-7db0dc04731e"
version = "1.4.0"

[[IteratorInterfaceExtensions]]
git-tree-sha1 = "a3f24677c21f5bbe9d2a714f95dcd58337fb2856"
uuid = "82899510-4779-5014-852e-03e436cf321d"
version = "1.0.0"

[[JLLWrappers]]
deps = ["Preferences"]
git-tree-sha1 = "abc9885a7ca2052a736a600f7fa66209f96506e1"
uuid = "692b3bcd-3c85-4b1f-b108-f13ce0eb3210"
version = "1.4.1"

[[JSON]]
deps = ["Dates", "Mmap", "Parsers", "Unicode"]
git-tree-sha1 = "31e996f0a15c7b280ba9f76636b3ff9e2ae58c9a"
uuid = "682c06a0-de6a-54ab-a142-c8b1cf79cde6"
version = "0.21.4"

[[KernelDensity]]
deps = ["Distributions", "DocStringExtensions", "FFTW", "Interpolations", "StatsBase"]
git-tree-sha1 = "9816b296736292a80b9a3200eb7fbb57aaa3917a"
uuid = "5ab0869b-81aa-558d-bb23-cbf5423bbe9b"
version = "0.6.5"

[[LAME_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "f6250b16881adf048549549fba48b1161acdac8c"
uuid = "c1c5ebd0-6772-5130-a774-d5fcae4a789d"
version = "3.100.1+0"

[[LZO_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "e5b909bcf985c5e2605737d2ce278ed791b89be6"
uuid = "dd4b983a-f0e5-5f8d-a1b7-129d4a5fb1ac"
version = "2.10.1+0"

[[LaTeXStrings]]
git-tree-sha1 = "f2355693d6778a178ade15952b7ac47a4ff97996"
uuid = "b964fa9f-0449-5b57-a5c2-d3ea65f4040f"
version = "1.3.0"

[[LazyArtifacts]]
deps = ["Artifacts", "Pkg"]
uuid = "4af54fe1-eca0-43a8-85a7-787d91b784e3"

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

[[Libuuid_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "7f3efec06033682db852f8b3bc3c1d2b0a0ab066"
uuid = "38a345b3-de98-5d2b-a5d3-14cd9215e700"
version = "2.36.0+0"

[[LinearAlgebra]]
deps = ["Libdl", "libblastrampoline_jll"]
uuid = "37e2e46d-f89d-539d-b4ee-838fcccc9c8e"

[[LogExpFunctions]]
deps = ["ChainRulesCore", "ChangesOfVariables", "DocStringExtensions", "InverseFunctions", "IrrationalConstants", "LinearAlgebra"]
git-tree-sha1 = "0a1b7c2863e44523180fdb3146534e265a91870b"
uuid = "2ab3a3ac-af41-5b50-aa03-7779005ae688"
version = "0.3.23"

[[Logging]]
uuid = "56ddb016-857b-54e1-b83d-db4d58db5568"

[[MKL_jll]]
deps = ["Artifacts", "IntelOpenMP_jll", "JLLWrappers", "LazyArtifacts", "Libdl", "Pkg"]
git-tree-sha1 = "2ce8695e1e699b68702c03402672a69f54b8aca9"
uuid = "856f044c-d86e-5d09-b602-aeab76dc8ba7"
version = "2022.2.0+0"

[[MacroTools]]
deps = ["Markdown", "Random"]
git-tree-sha1 = "42324d08725e200c23d4dfb549e0d5d89dede2d2"
uuid = "1914dd2f-81c6-5fcd-8719-6d5c9610ff09"
version = "0.5.10"

[[Makie]]
deps = ["Animations", "Artifacts", "Base64", "ColorBrewer", "ColorSchemes", "ColorTypes", "Colors", "Contour", "Distributions", "DocStringExtensions", "FFMPEG", "FileIO", "FixedPointNumbers", "Formatting", "FreeType", "FreeTypeAbstraction", "GeometryBasics", "GridLayoutBase", "ImageIO", "IntervalSets", "Isoband", "KernelDensity", "LaTeXStrings", "LinearAlgebra", "MakieCore", "Markdown", "Match", "MathTeXEngine", "Observables", "Packing", "PlotUtils", "PolygonOps", "Printf", "Random", "Serialization", "Showoff", "SignedDistanceFields", "SparseArrays", "StaticArrays", "Statistics", "StatsBase", "StatsFuns", "StructArrays", "UnicodeFun"]
git-tree-sha1 = "5761bfd21ad271efd7e134879e39a2289a032fc8"
uuid = "ee78f7c6-11fb-53f2-987a-cfe4a2b5a57a"
version = "0.15.0"

[[MakieCore]]
deps = ["Observables"]
git-tree-sha1 = "7bcc8323fb37523a6a51ade2234eee27a11114c8"
uuid = "20f20a25-4f0e-4fdf-b5d1-57303727442b"
version = "0.1.3"

[[MappedArrays]]
git-tree-sha1 = "e8b359ef06ec72e8c030463fe02efe5527ee5142"
uuid = "dbb5928d-eab1-5f90-85c2-b9b0edb7c900"
version = "0.4.1"

[[Markdown]]
deps = ["Base64"]
uuid = "d6f4376e-aef5-505a-96c1-9c027394607a"

[[Match]]
git-tree-sha1 = "1d9bc5c1a6e7ee24effb93f175c9342f9154d97f"
uuid = "7eb4fadd-790c-5f42-8a69-bfa0b872bfbf"
version = "1.2.0"

[[MathTeXEngine]]
deps = ["AbstractTrees", "Automa", "DataStructures", "FreeTypeAbstraction", "GeometryBasics", "LaTeXStrings", "REPL", "Test"]
git-tree-sha1 = "69b565c0ca7bf9dae18498b52431f854147ecbf3"
uuid = "0a4f8689-d25c-4efe-a92b-7142dfc1aa53"
version = "0.1.2"

[[MbedTLS_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "c8ffd9c3-330d-5841-b78e-0817d7145fa1"
version = "2.28.0+0"

[[Missings]]
deps = ["DataAPI"]
git-tree-sha1 = "f66bdc5de519e8f8ae43bdc598782d35a25b1272"
uuid = "e1d29d7a-bbdc-5cf2-9ac0-f12de2c33e28"
version = "1.1.0"

[[Mmap]]
uuid = "a63ad114-7e13-5084-954f-fe012c677804"

[[MosaicViews]]
deps = ["MappedArrays", "OffsetArrays", "PaddedViews", "StackViews"]
git-tree-sha1 = "7b86a5d4d70a9f5cdf2dacb3cbe6d251d1a61dbe"
uuid = "e94cdb99-869f-56ef-bcf0-1ae2bcbe0389"
version = "0.3.4"

[[MozillaCACerts_jll]]
uuid = "14a3606d-f60d-562e-9121-12d972cd8159"
version = "2022.2.1"

[[NaNMath]]
deps = ["OpenLibm_jll"]
git-tree-sha1 = "0877504529a3e5c3343c6f8b4c0381e57e4387e4"
uuid = "77ba4419-2d1f-58cd-9bb1-8ffee604a2e3"
version = "1.0.2"

[[Netpbm]]
deps = ["FileIO", "ImageCore", "ImageMetadata"]
git-tree-sha1 = "5ae7ca23e13855b3aba94550f26146c01d259267"
uuid = "f09324ee-3d7c-5217-9330-fc30815ba969"
version = "1.1.0"

[[NetworkOptions]]
uuid = "ca575930-c2e3-43a9-ace4-1e988b2c1908"
version = "1.2.0"

[[Observables]]
git-tree-sha1 = "fe29afdef3d0c4a8286128d4e45cc50621b1e43d"
uuid = "510215fc-4207-5dde-b226-833fc4488ee2"
version = "0.4.0"

[[OffsetArrays]]
deps = ["Adapt"]
git-tree-sha1 = "82d7c9e310fe55aa54996e6f7f94674e2a38fcb4"
uuid = "6fe1bfb0-de20-5000-8ca7-80f57d26f881"
version = "1.12.9"

[[Ogg_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "887579a3eb005446d514ab7aeac5d1d027658b8f"
uuid = "e7412a2a-1a6e-54c0-be00-318e2571c051"
version = "1.3.5+1"

[[OpenBLAS_jll]]
deps = ["Artifacts", "CompilerSupportLibraries_jll", "Libdl"]
uuid = "4536629a-c528-5b80-bd46-f80d51c5b363"
version = "0.3.20+0"

[[OpenLibm_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "05823500-19ac-5b8b-9628-191a04bc5112"
version = "0.8.1+0"

[[OpenSSL_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "9ff31d101d987eb9d66bd8b176ac7c277beccd09"
uuid = "458c3c95-2e84-50aa-8efc-19380b2a3a95"
version = "1.1.20+0"

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
git-tree-sha1 = "d321bf2de576bf25ec4d3e4360faca399afca282"
uuid = "bac558e1-5e72-5ebc-8fee-abe8a469f55d"
version = "1.6.0"

[[PCRE2_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "efcefdf7-47ab-520b-bdef-62a2eaa19f15"
version = "10.40.0+0"

[[PDMats]]
deps = ["LinearAlgebra", "SparseArrays", "SuiteSparse"]
git-tree-sha1 = "67eae2738d63117a196f497d7db789821bce61d1"
uuid = "90014a1f-27ba-587c-ab20-58faa44d9150"
version = "0.11.17"

[[PNGFiles]]
deps = ["Base64", "CEnum", "ImageCore", "IndirectArrays", "OffsetArrays", "libpng_jll"]
git-tree-sha1 = "f809158b27eba0c18c269cf2a2be6ed751d3e81d"
uuid = "f57f5aa1-a3ce-4bc8-8ab9-96f992907883"
version = "0.3.17"

[[Packing]]
deps = ["GeometryBasics"]
git-tree-sha1 = "f4049d379326c2c7aa875c702ad19346ecb2b004"
uuid = "19eb6ba3-879d-56ad-ad62-d5c202156566"
version = "0.4.1"

[[PaddedViews]]
deps = ["OffsetArrays"]
git-tree-sha1 = "0fac6313486baae819364c52b4f483450a9d793f"
uuid = "5432bcbf-9aad-5242-b902-cca2824c8663"
version = "0.5.12"

[[Pango_jll]]
deps = ["Artifacts", "Cairo_jll", "Fontconfig_jll", "FreeType2_jll", "FriBidi_jll", "Glib_jll", "HarfBuzz_jll", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "84a314e3926ba9ec66ac097e3635e270986b0f10"
uuid = "36c8627f-9965-5494-a995-c6b170f724f3"
version = "1.50.9+0"

[[Parsers]]
deps = ["Dates", "SnoopPrecompile"]
git-tree-sha1 = "478ac6c952fddd4399e71d4779797c538d0ff2bf"
uuid = "69de0a69-1ddd-5017-9359-2bf0b02dc9f0"
version = "2.5.8"

[[Pixman_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "b4f5d02549a10e20780a24fce72bea96b6329e29"
uuid = "30392449-352a-5448-841d-b1acce4e97dc"
version = "0.40.1+0"

[[Pkg]]
deps = ["Artifacts", "Dates", "Downloads", "LibGit2", "Libdl", "Logging", "Markdown", "Printf", "REPL", "Random", "SHA", "Serialization", "TOML", "Tar", "UUIDs", "p7zip_jll"]
uuid = "44cfe95a-1eb2-52ea-b672-e2afdf69b78f"
version = "1.8.0"

[[PlotUtils]]
deps = ["ColorSchemes", "Colors", "Dates", "Printf", "Random", "Reexport", "SnoopPrecompile", "Statistics"]
git-tree-sha1 = "c95373e73290cf50a8a22c3375e4625ded5c5280"
uuid = "995b91a9-d308-5afd-9ec6-746e21dbc043"
version = "1.3.4"

[[PolygonOps]]
git-tree-sha1 = "77b3d3605fc1cd0b42d95eba87dfcd2bf67d5ff6"
uuid = "647866c9-e3ac-4575-94e7-e3d426903924"
version = "0.1.2"

[[Preferences]]
deps = ["TOML"]
git-tree-sha1 = "47e5f437cc0e7ef2ce8406ce1e7e24d44915f88d"
uuid = "21216c6a-2e73-6563-6e65-726566657250"
version = "1.3.0"

[[Printf]]
deps = ["Unicode"]
uuid = "de0858da-6303-5e67-8744-51eddeeeb8d7"

[[QuadGK]]
deps = ["DataStructures", "LinearAlgebra"]
git-tree-sha1 = "6ec7ac8412e83d57e313393220879ede1740f9ee"
uuid = "1fd47b50-473d-5c70-9696-f719f8f3bcdc"
version = "2.8.2"

[[REPL]]
deps = ["InteractiveUtils", "Markdown", "Sockets", "Unicode"]
uuid = "3fa0cd96-eef1-5676-8a61-b3b8758bbffb"

[[Random]]
deps = ["SHA", "Serialization"]
uuid = "9a3f8284-a2c9-5f02-9a11-845980a1fd5c"

[[RangeArrays]]
git-tree-sha1 = "b9039e93773ddcfc828f12aadf7115b4b4d225f5"
uuid = "b3c3ace0-ae52-54e7-9d0b-2c1406fd6b9d"
version = "0.3.2"

[[Ratios]]
deps = ["Requires"]
git-tree-sha1 = "dc84268fe0e3335a62e315a3a7cf2afa7178a734"
uuid = "c84ed2f1-dad5-54f0-aa8e-dbefe2724439"
version = "0.4.3"

[[Reexport]]
git-tree-sha1 = "45e428421666073eab6f2da5c9d310d99bb12f9b"
uuid = "189a3867-3050-52da-a836-e630ba90ab69"
version = "1.2.2"

[[Requires]]
deps = ["UUIDs"]
git-tree-sha1 = "838a3a4188e2ded87a4f9f184b4b0d78a1e91cb7"
uuid = "ae029012-a4dd-5104-9daa-d747884805df"
version = "1.3.0"

[[Rmath]]
deps = ["Random", "Rmath_jll"]
git-tree-sha1 = "f65dcb5fa46aee0cf9ed6274ccbd597adc49aa7b"
uuid = "79098fc4-a85e-5d69-aa6a-4863f24498fa"
version = "0.7.1"

[[Rmath_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "6ed52fdd3382cf21947b15e8870ac0ddbff736da"
uuid = "f50d1b31-88e8-58de-be2c-1cc44531875f"
version = "0.4.0+0"

[[SHA]]
uuid = "ea8e919c-243c-51af-8825-aaa63cd721ce"
version = "0.7.0"

[[SIMD]]
deps = ["SnoopPrecompile"]
git-tree-sha1 = "8b20084a97b004588125caebf418d8cab9e393d1"
uuid = "fdea26ae-647d-5447-a871-4b548cad5224"
version = "3.4.4"

[[ScanByte]]
deps = ["Libdl", "SIMD"]
git-tree-sha1 = "2436b15f376005e8790e318329560dcc67188e84"
uuid = "7b38b023-a4d7-4c5e-8d43-3f3097f304eb"
version = "0.3.3"

[[Serialization]]
uuid = "9e88b42a-f829-5b0c-bbe9-9e923198166b"

[[SharedArrays]]
deps = ["Distributed", "Mmap", "Random", "Serialization"]
uuid = "1a1011a3-84de-559e-8e89-a11a2f7dc383"

[[Showoff]]
deps = ["Dates", "Grisu"]
git-tree-sha1 = "91eddf657aca81df9ae6ceb20b959ae5653ad1de"
uuid = "992d4aef-0814-514b-bc4d-f2e9a6c4116f"
version = "1.0.3"

[[SignedDistanceFields]]
deps = ["Random", "Statistics", "Test"]
git-tree-sha1 = "d263a08ec505853a5ff1c1ebde2070419e3f28e9"
uuid = "73760f76-fbc4-59ce-8f25-708e95d2df96"
version = "0.4.0"

[[SimpleTraits]]
deps = ["InteractiveUtils", "MacroTools"]
git-tree-sha1 = "5d7e3f4e11935503d3ecaf7186eac40602e7d231"
uuid = "699a6c99-e7fa-54fc-8d76-47d257e15c1d"
version = "0.9.4"

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
git-tree-sha1 = "ef28127915f4229c971eb43f3fc075dd3fe91880"
uuid = "276daf66-3868-5448-9aa4-cd146d93841b"
version = "2.2.0"

[[StackViews]]
deps = ["OffsetArrays"]
git-tree-sha1 = "46e589465204cd0c08b4bd97385e4fa79a0c770c"
uuid = "cae243ae-269e-4f55-b966-ac2d0dc13c15"
version = "0.1.1"

[[Static]]
deps = ["IfElse"]
git-tree-sha1 = "08be5ee09a7632c32695d954a602df96a877bf0d"
uuid = "aedffcd0-7271-4cad-89d0-dc628f76c6d3"
version = "0.8.6"

[[StaticArrayInterface]]
deps = ["ArrayInterface", "Compat", "IfElse", "LinearAlgebra", "Requires", "SnoopPrecompile", "SparseArrays", "Static", "SuiteSparse"]
git-tree-sha1 = "fd5f417fd7e103c121b0a0b4a6902f03991111f4"
uuid = "0d7ed370-da01-4f52-bd93-41d350b8b718"
version = "1.3.0"

[[StaticArrays]]
deps = ["LinearAlgebra", "Random", "StaticArraysCore", "Statistics"]
git-tree-sha1 = "70e0cc0c0f9ef7ea76b3d7a50ada18c8c52e69a2"
uuid = "90137ffa-7385-5640-81b9-e52037218182"
version = "1.5.20"

[[StaticArraysCore]]
git-tree-sha1 = "6b7ba252635a5eff6a0b0664a41ee140a1c9e72a"
uuid = "1e83bf80-4336-4d27-bf5d-d5a4f845583c"
version = "1.4.0"

[[Statistics]]
deps = ["LinearAlgebra", "SparseArrays"]
uuid = "10745b16-79ce-11e8-11f9-7d13ad32a3b2"

[[StatsAPI]]
deps = ["LinearAlgebra"]
git-tree-sha1 = "45a7769a04a3cf80da1c1c7c60caf932e6f4c9f7"
uuid = "82ae8749-77ed-4fe6-ae5f-f523153014b0"
version = "1.6.0"

[[StatsBase]]
deps = ["DataAPI", "DataStructures", "LinearAlgebra", "LogExpFunctions", "Missings", "Printf", "Random", "SortingAlgorithms", "SparseArrays", "Statistics", "StatsAPI"]
git-tree-sha1 = "d1bf48bfcc554a3761a133fe3a9bb01488e06916"
uuid = "2913bbd2-ae8a-5f71-8c99-4fb6c76f3a91"
version = "0.33.21"

[[StatsFuns]]
deps = ["ChainRulesCore", "InverseFunctions", "IrrationalConstants", "LogExpFunctions", "Reexport", "Rmath", "SpecialFunctions"]
git-tree-sha1 = "5950925ff997ed6fb3e985dcce8eb1ba42a0bbe7"
uuid = "4c63d2b9-4356-54db-8cca-17b64c39e42c"
version = "0.9.18"

[[StructArrays]]
deps = ["Adapt", "DataAPI", "Tables"]
git-tree-sha1 = "44b3afd37b17422a62aea25f04c1f7e09ce6b07f"
uuid = "09ab397b-f2b6-538f-b94a-2f83cf4a842a"
version = "0.5.1"

[[SuiteSparse]]
deps = ["Libdl", "LinearAlgebra", "Serialization", "SparseArrays"]
uuid = "4607b0f0-06f3-5cda-b6b1-a6196a1729e9"

[[TOML]]
deps = ["Dates"]
uuid = "fa267f1f-6049-4f14-aa54-33bafae1ed76"
version = "1.0.0"

[[TableTraits]]
deps = ["IteratorInterfaceExtensions"]
git-tree-sha1 = "c06b2f539df1c6efa794486abfb6ed2022561a39"
uuid = "3783bdb8-4a98-5b6b-af9a-565f29a5fe9c"
version = "1.0.1"

[[Tables]]
deps = ["DataAPI", "DataValueInterfaces", "IteratorInterfaceExtensions", "LinearAlgebra", "OrderedCollections", "TableTraits", "Test"]
git-tree-sha1 = "1544b926975372da01227b382066ab70e574a3ec"
uuid = "bd369af6-aec1-5ad0-b16a-f7cc5008161c"
version = "1.10.1"

[[Tar]]
deps = ["ArgTools", "SHA"]
uuid = "a4e569a6-e804-4fa4-b0f3-eef7a1d5b13e"
version = "1.10.0"

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
git-tree-sha1 = "0b829474fed270a4b0ab07117dce9b9a2fa7581a"
uuid = "3bb67fe8-82b1-5028-8e26-92a6c54297fa"
version = "0.9.12"

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

[[WoodburyMatrices]]
deps = ["LinearAlgebra", "SparseArrays"]
git-tree-sha1 = "de67fa59e33ad156a590055375a30b23c40299d3"
uuid = "efce3f68-66dc-5838-9240-27a6d6f5f9b6"
version = "0.5.5"

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

[[Xorg_xtrans_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "79c31e7844f6ecf779705fbc12146eb190b7d845"
uuid = "c5fb5394-a638-5e4d-96e5-b29de1b5cf10"
version = "1.4.0+3"

[[Zlib_jll]]
deps = ["Libdl"]
uuid = "83775a58-1f1d-513f-b197-d71354ab007a"
version = "1.2.12+3"

[[isoband_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "51b5eeb3f98367157a7a12a1fb0aa5328946c03c"
uuid = "9a68df92-36a6-505f-a73e-abb412b6bfb4"
version = "0.2.3+0"

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

[[libblastrampoline_jll]]
deps = ["Artifacts", "Libdl", "OpenBLAS_jll"]
uuid = "8e850b90-86db-534c-a0d3-1478176c7d93"
version = "5.1.1+0"

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
version = "1.48.0+0"

[[p7zip_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "3f19e933-33d8-53b3-aaab-bd5110c3b7a0"
version = "17.4.0+0"

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
"""

# ╔═╡ Cell order:
# ╠═78142762-ae33-11ed-3e6b-75b2fc3af2b5
# ╠═9cb64897-e862-444b-8435-54a90fc8690c
# ╠═f03578ab-8ab0-4564-b7e3-6c368b61eb5a
# ╠═668bb938-f4e3-473c-aced-599a759ba645
# ╠═bf268a10-ac94-452a-8436-834e7befa111
# ╠═3f814e35-543b-47e6-9b05-c4409de5d02e
# ╠═5c9f12a6-01a8-4a85-a8b4-93cad94bff2a
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
