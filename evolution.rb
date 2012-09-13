load "dungeon.rb"
load "astar.rb"

@width = 10
@height = 10
@probability = 0.9

def gen_population(size)
	population = Array.new(size)
	size.times do |i|
		population[i] = { :dungeon => Dungeon.new(@width, @height, @probability), :fitness => -1 }
	end

	population
end

# ensure that population is larger than or equal to micro + lambda
@population_size = 100
@pop_micro = 50
@pop_lambda = 50

@iterations = 1000

#

@population = gen_population(@population_size)

data = ""
data += "iteration, maximum fitness\n"

last_percentage = 0.0
diff = 9

@iterations.times do |i|
	# calculate fitness for population
	@population.map! do |genome|
		d = genome[:dungeon]

		ab = AStar.pathlength(d, d.a, d.b)
		bc = AStar.pathlength(d, d.b, d.c)
		ca = AStar.pathlength(d, d.c, d.a)

		if ab < 0 or bc < 0 or ca < 0 then
			genome[:fitness] = -1
		else
			genome[:fitness] = ab + bc + ca
		end

		genome
	end

	@population.sort_by! { |g| -g[:fitness] }

	data += "#{i}, #{@population[0][:fitness]}\n"

	@population.pop(@pop_lambda)

	new_population = gen_population(@pop_lambda)

	@population += new_population

	percentage = (i * 100.0) / @iterations
	if percentage > last_percentage + diff then
		print "#{percentage}%..."
		last_percentage = percentage
	end
end

puts "100%!"

@population.sort_by! { |g| -g[:fitness] }
maze = @population.first

filename_suffix = "nomutate_nocrossover_prob_#{@probability}"
File.open("data_#{suffix}.csv", "w") { |f| f.write(data) }
File.open("maze_#{suffix}.txt", "w") { |f| f.write(maze) }
