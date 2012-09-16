load "dungeon.rb"
load "astar.rb"

@width = 10
@height = 10
@probability = 0.1
@mutate_probability = 0.1
@xswitch = 5
@yswitch = 5

def gen_population(size)
	population = Array.new(size)
	size.times do |i|
		population[i] = { :dungeon => Dungeon.new(@width, @height, @probability), :fitness => -1, :calculated => false }
	end

	population
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
		children << Dungeon.crossover(ps[0], ps[1], @xswitch, @yswitch)
	end

	children
end

@population_size = 100
@pop_worst_count = 50

# if the following numbers combined are not less than or equal @pop_worst_count, the array will be truncated
# if the numbers combined are less than @pop_worst_count, the remaining places will be filled with new genomes
@pop_mutate_count = 20
@pop_crossover_parent_count = 30 # will result in (count / 2) children
# end numbers

@iterations = 100

@population = gen_population(@population_size)

data = "iteration, maximum fitness\n"

last_iteration = 0
diff = 100

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
	@population.pop(@pop_worst_count)

	# crossover
	@population += crossover_population(@population, @pop_crossover_parent_count)

	# mutate
	@population += mutate_population(@population, @pop_mutate_count)

	# truncate population if there are too many genomes in it
	if @population.size > @population_size then
		@population.pop(@population.size - @populationsize)
	else
		# generate some new dungeons to maintain variety
		@population += gen_population(@population_size - @population.size)
	end


	if i >= last_iteration + diff
		print "#{i}.."
		last_iteration = i
	end
end

puts "#{@iterations}!"

@population.sort_by! { |g| -g[:fitness] }
maze = @population.first

filename_suffix = "crossover_mutateprob_#{@mutate_probability}_wallprob_#{@probability}"
File.open("data_#{filename_suffix}.csv", "w") { |f| f.write(data) }
File.open("maze_#{filename_suffix}.txt", "w") { |f| f.write(maze) }
