load "evolution.rb"

class MetaEvolution
	def initialize
		# regular evolution
		@population_size = 100
		@iterations = 100
		@width = 10
		@height = 10

		# meta
		@meta_population_size = 100
		@meta_iterations = 100
		@meta_mutate_probability = 0.2
		@meta_mutate_count = 20
		@meta_crossover_parent_count = 10
		
		@population = create_population(@meta_population_size)

		@meta_iterations.times do
			@population += mutate_population(@population, @meta_mutate_count)
			
			@population += crossover_population(@population, @meta_crossover_parent_count * 2)

			# delete unnecessary genomes
			@population.delete_if { |g| g[:fitness] < 0 }

			if @population.size > @population_size then
				@population.pop(@population.size - @population_size)
			else
				# fill up the population to the cap
				@population += create_population(@population_size - @population.size)
			end

			@population.sort_by! { |g| -g[:fitness] }
		end
	end

	private

	FLOOR_PROBABILITY = 0
	MUTATE_PROBABILITY = 1
	CROSSOVER_BLOCK_WIDTH = 2
	CROSSOVER_BLOCK_HEIGHT = 3
	POPULATION_KILL_COUNT = 4
	POPULATION_MUTATE_COUNT = 5
	POPULATION_CROSSOVER_COUNT = 6

	def mutate_population(population, count)
		count = population.count if count > population.count

		pop = Marshal.load(Marshal.dump(population.take(count)))

		pop.map do |p|
			if rand(nil) < @meta_mutate_probability then
				genome = p[:genome]

				genome.map! do |g|
					int = g.is_a? Integer

					# between + and - 10%
					mutation_amount = (rand(nil) * 2.0 - 1.0) / 10.0

					g = g + mutation_amount * g

					if int then
						g = g.round

						# prevent negative or zerolength arrays
						if g < 1 then
							g = 1
						end
					end

					g
				end

				{ :genome => genome, :fitness => create_evolution(genome).fitness }
			else
				p
			end
		end
	end

	def crossover_population(population, parent_count)
		if parent_count > population.count then
			# highest even number which is less than popcount
			parent_count = population.count / 2 * 3
		end

		pop = Marshal.load(Marshal.dump(population.take(parent_count)))

		children = []

		return children if parent_count > population.count

		pop.each_slice(2) do |ps|
			break if ps[0] == nil or ps[1] == nil

			g1 = ps[0][:genome]
			g2 = ps[1][:genome]

			child_genome = []

			g1.length.times do |i|
				c = (g1[i] + g2[i]) / 2.0

				# preserve the original types
				if g1[i].is_a? Integer then
					c = c.round

					if c < 1 then
						c = 1
					end
				end

				child_genome << c
			end

			fitness = create_evolution(child_genome).fitness

			children << { :genome => child_genome, :fitness => fitness }
		end

		children
	end

	def create_population(size)
		Array.new(size) do |i|
			g = random_genome
			f = create_evolution(g).fitness

			{ :fitness => f, :genome => g }
		end
	end

	def random_genome
		a = Array.new(7)
		a[FLOOR_PROBABILITY] = floor_probability
		a[MUTATE_PROBABILITY] = mutate_probability
		a[CROSSOVER_BLOCK_WIDTH] = crossover_block_width
		a[CROSSOVER_BLOCK_HEIGHT] = crossover_block_height
		a[POPULATION_KILL_COUNT] = population_kill_count
		a[POPULATION_MUTATE_COUNT] = population_mutate_count(a[POPULATION_KILL_COUNT])
		a[POPULATION_CROSSOVER_COUNT] = population_crossover_count(a[POPULATION_KILL_COUNT])
		a
	end

	def create_evolution(e)
		Evolution.new(@population_size, @width, @height, @iterations,
			      e[FLOOR_PROBABILITY], e[MUTATE_PROBABILITY],
			      e[CROSSOVER_BLOCK_WIDTH], e[CROSSOVER_BLOCK_HEIGHT],
			      e[POPULATION_KILL_COUNT], e[POPULATION_MUTATE_COUNT], e[POPULATION_CROSSOVER_COUNT])
	end

	def floor_probability
		rand(nil)
	end

	def mutate_probability
		rand(nil)
	end

	def crossover_block_width
		rand(1..10)
	end

	def crossover_block_height
		rand(1..10)
	end

	def population_kill_count(max = @population_size)
		rand(1..max)
	end

	def population_mutate_count(max = @population_size)
		rand(1..max)
	end

	def population_crossover_count(max = @population_size)
		rand(1..max)
	end
end

MetaEvolution.new
