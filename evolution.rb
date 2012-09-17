load "dungeon.rb"
load "astar.rb"

class Evolution
	attr_reader :floor_probability, :mutate_probability, :crossover_block_width, :crossover_block_height,
		:population_kill_count, :population_mutate_count, :population_crossover_count,
		:fitness

	def initialize(population_size, width, height, iterations,
		       floor_probability, mutate_probability, crossover_block_width, crossover_block_height,
		       population_kill_count, population_mutate_count, population_crossover_count)

		@width = width
		@height = height

		@floor_probability = floor_probability
		@mutate_probability = mutate_probability
		@crossover_block_width = crossover_block_width
		@crossover_block_height = crossover_block_height

		@population_size = population_size
		@iterations = iterations

		@population_kill_count = population_kill_count
		@population_mutate_count = population_mutate_count
		@population_crossover_count = population_crossover_count

		@filename  = "floor-#{@floor_probability}_"
		@filename += "kill-#{@population_kill_count}_"
		@filename += "crossover-#{@population_crossover_count}-#{@crossover_block_width}-#{@crossover_block_height}_"
		@filename += "mutate-#{@population_mutate_count}-#{@mutate_probability}"

		@folder = "metaresults"

		if @population_kill_count < (@population_mutate_count + @population_crossover_count) then
			@fitness = -1
		elsif @population_kill_count >= @population_size then
			@fitness = -1
		elsif (@population_crossover_count * 2) > (@population_size - @population_kill_count)
			@fitness = -1
		else
			@fitness = evolve
		end
	end


	private

	def evolve
		@population = gen_population(@population_size)

		data = "iteration, maximum fitness\n"
		@iterations.times do |i|
			# calculate fitness for population
			@population.map! do |genome|
				# the unchanged dungeons don't need to be updated
				genome if genome[:calculated] == true

				d = genome[:dungeon]

				if d.a == nil or d.b == nil or d.b == nil
					genome[:fitness] = -1
				else
					ab = AStar.pathlength(d, d.a, d.b)
					bc = AStar.pathlength(d, d.b, d.c)
					ca = AStar.pathlength(d, d.c, d.a)

					if ab < 0 or bc < 0 or ca < 0 then
						genome[:fitness] = -1
					else
						genome[:fitness] = ab + bc + ca
					end
				end

				genome[:calculated] = true

				genome
			end

			@population.sort_by! { |g| -g[:fitness] }

			data += "#{i}, #{@population.first[:fitness]}\n"

			# throw away the worst
			@population.pop(@population_kill_count)

			# crossover. count is multiplied by two to get the number of parents
			@population += crossover_population(@population, @population_crossover_count * 2)

			# mutate
			@population += mutate_population(@population, @population_mutate_count)

			# truncate population if there are too many genomes in it
			if @population.size > @population_size then
				@population.pop(@population.size - @population_size)
			else
				# generate some new dungeons to maintain variety
				@population += gen_population(@population_size - @population.size)
			end
		end
		
		@population.sort_by! { |g| -g[:fitness] }
		maze = @population.first

		folder = @folder + "/" || ""

		File.open("#{folder}data_#{@filename}.csv", "w") { |f| f.write(data) }
		File.open("maze_#{@filename}.txt", "w") { |f| f.write(maze) }

		maze[:fitness]
	end

	def gen_population(size)
		Array.new(size) { |i| {
			:dungeon => Dungeon.new(@width, @height, @floor_probability),
			:fitness => -1,
			:calculated => false
		} }
	end

	def mutate_population(population, count)
		pop = Marshal.load(Marshal.dump(population.take(count)))

		pop.map! do |genome|
			{ :dungeon => genome[:dungeon].mutate(@mutate_probability),
				:fitness => -1,
				:calculated => false
			}
		end

		pop
	end

	def crossover_population(population, parentcount)
		pop = Marshal.load(Marshal.dump(population.take(parentcount)))

		children = []

		pop.each_slice(2) do |ps|
			children << {
				:dungeon => Dungeon.crossover(ps[0][:dungeon], ps[1][:dungeon], @crossover_block_width, @crossover_block_height),
				:fitness => -1, :calculated => false
			}
		end

		children
	end

end
