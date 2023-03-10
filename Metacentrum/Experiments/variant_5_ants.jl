### A Pluto.jl notebook ###
# v0.19.13

using Markdown
using InteractiveUtils

# ╔═╡ 78142762-ae33-11ed-3e6b-75b2fc3af2b5
module AntsModel

import Pkg
Pkg.add("Plots")

include("ant_colony.jl")

end

# ╔═╡ b94e4c8c-5335-4e99-b92a-28d5a5b00b1b
"""
	print_experiment_header(title_line = "", parameters_line = "", table_header = "")

Prints header of the experiment in appropriate format based on the arguments.
"""
function print_experiment_header(;
		title_line::String = "",
		parameters_line::String = "",
		table_header::String = "",	
	)
	println(title_line)
	println(parameters_line)
	println("---------------------------------------------------")	
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
# 				# num_ants = 400,
# 				# search_depth = 10,
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
# 				grid_size = GRID_SIZE_VARIANT_2,
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
# 				grid_size = GRID_SIZE_VARIANT_2,
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
# 				search_depth = 50,
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
begin
	run_experiments(
		NUM_ANTS_FIRST_VARIANT,
		EXPERIMENT_NUM_ANTS,
		food_coordinates = FOOD_VARIANT_5,
		nest_coordinates = NEST_VARIANT_5,
		obstacle_coordinates = OBSTACLE_VARIANT_5,
		maze_variant = "VARIANT_5",
		num_iterations = 8000,
	)
end

# ╔═╡ 00000000-0000-0000-0000-000000000001
PLUTO_PROJECT_TOML_CONTENTS = """
[deps]
Pkg = "44cfe95a-1eb2-52ea-b672-e2afdf69b78f"
Plots = "91a5bcdd-55d7-5caf-9e0b-520d859cae80"
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
git-tree-sha1 = "485193efd2176b88e6622a39a246f8c5b600e74e"
uuid = "9e997f8a-9a97-42d5-a9f1-ce6bfc15e2c0"
version = "0.1.6"

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
git-tree-sha1 = "61fdd77467a5c3ad071ef8277ac6bd6af7dd4c04"
uuid = "34da2185-b29b-5c13-b0c7-acf172513d20"
version = "4.6.0"

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
git-tree-sha1 = "660b2ea2ec2b010bb02823c6d0ff6afd9bdc5c16"
uuid = "28b8d3ca-fb5f-59d9-8090-bfdbd6d07a71"
version = "0.71.7"

[[GR_jll]]
deps = ["Artifacts", "Bzip2_jll", "Cairo_jll", "FFMPEG_jll", "Fontconfig_jll", "GLFW_jll", "JLLWrappers", "JpegTurbo_jll", "Libdl", "Libtiff_jll", "Pixman_jll", "Qt5Base_jll", "Zlib_jll", "libpng_jll"]
git-tree-sha1 = "d5e1fd17ac7f3aa4c5287a61ee28d4f8b8e98873"
uuid = "d2c73de3-f751-5644-a686-071e5b155ba9"
version = "0.71.7+0"

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
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "6f2675ef130a300a112286de91973805fcc5ffbc"
uuid = "aacddb02-875f-59d6-b918-886e6ef4fbf8"
version = "2.1.91+0"

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
git-tree-sha1 = "071602a0be5af779066df0d7ef4e14945a010818"
uuid = "2ab3a3ac-af41-5b50-aa03-7779005ae688"
version = "0.3.22"

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
git-tree-sha1 = "0877504529a3e5c3343c6f8b4c0381e57e4387e4"
uuid = "77ba4419-2d1f-58cd-9bb1-8ffee604a2e3"
version = "1.0.2"

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
git-tree-sha1 = "85f8e6578bf1f9ee0d11e7bb1b1456435479d47c"
uuid = "bac558e1-5e72-5ebc-8fee-abe8a469f55d"
version = "1.4.1"

[[PCRE2_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "efcefdf7-47ab-520b-bdef-62a2eaa19f15"

[[Parsers]]
deps = ["Dates", "SnoopPrecompile"]
git-tree-sha1 = "6f4fbcd1ad45905a5dee3f4256fabb49aa2110c6"
uuid = "69de0a69-1ddd-5017-9359-2bf0b02dc9f0"
version = "2.5.7"

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
git-tree-sha1 = "8ac949bd0ebc46a44afb1fdca1094554a84b086e"
uuid = "91a5bcdd-55d7-5caf-9e0b-520d859cae80"
version = "1.38.5"

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
git-tree-sha1 = "074f993b0ca030848b897beff716d93aca60f06a"
uuid = "5c2747f8-b7ea-4ff2-ba2e-563bfd36b1d4"
version = "1.4.2"

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
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "c6edfe154ad7b313c01aceca188c05c835c67360"
uuid = "3161d3a3-bdf6-5164-811a-617609db77b4"
version = "1.5.4+0"

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
# ╠═78142762-ae33-11ed-3e6b-75b2fc3af2b5
# ╠═b94e4c8c-5335-4e99-b92a-28d5a5b00b1b
# ╠═1f1d6b11-6d87-4ff2-81c7-0f2ba2ceffec
# ╠═23d7831b-233e-457b-839c-81955bd824a7
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
# ╠═4941ab5c-c9f7-4de0-9711-c81927a52f68
# ╠═d900a7d0-a07f-4dda-a98f-b8850780ff49
# ╠═5ca84557-316a-47bd-897b-3deacdccface
# ╠═365fba99-5528-4a23-9a84-a42647fa5d7d
# ╠═4dd90806-ff62-49dc-be11-16cf4e81975a
# ╠═ea4d58f4-4945-4883-a44a-3dbb19824193
# ╠═95fafcd5-9efb-4e29-85ea-d9f0baa09801
# ╠═3d529786-248f-4235-a9a7-454d2454a437
# ╠═b399cb54-cf61-4b71-804a-fd4103584293
# ╠═6732a55d-2ae3-43d2-b229-a404d8a54a15
# ╠═97514545-2661-40cd-9127-2d13df72dd0f
# ╠═a52e86bb-5ad3-4405-8f12-4a23982e69f3
# ╟─00000000-0000-0000-0000-000000000001
# ╟─00000000-0000-0000-0000-000000000002
