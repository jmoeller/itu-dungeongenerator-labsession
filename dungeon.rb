class Dungeon
	attr_reader :tiles, :a, :b, :c, :width, :height, :floorprobability

	def initialize(width, height, floorprobability)
		@width = width
		@height = height
		@floorprobability = floorprobability

		@tiles = Array.new(@width * @height, :wall)

		create!
	end

	def mutate(mutation_probability)
		@tiles.map! do |tile|
			if rand(nil) < mutation_probability then
				if tile == :wall then
					:floor
				else
					:wall
				end
			else
				tile
			end	
		end

		self
	end

	def neighbors(index)
		xs, ys = i2c(index)

		neighbors = []

		(ys-1..ys+1).to_a.each do |y|
			(xs-1..xs+1).to_a.each do |x|
				next if x < 0 or x == @width
				next if y < 0 or y == @height
				next if x == xs and y == ys
				next if (x == xs - 1 or x == xs + 1) and (y == ys - 1 or y == ys + 1)

				neighbors << c2i(x, y) if cell(x, y) == :floor
			end
		end

		neighbors
	end

	def manhattan(from, to)
		xf, yf = i2c(from)
		xt, yt = i2c(to)

		(xt - xf).abs + (yt - yf).abs
	end

	def to_s
		padwidth = @width + 2
		padheight = @height + 2

		maze = ""

		padheight.times do |y|
			line = ""

			padwidth.times do |x|
				if (x == 0 and y == 0) or
					(x == padwidth - 1 and y == 0) or
					(x == padwidth - 1 and y == padheight - 1) or
					(x == 0 and y == padheight - 1) then
					line += "+"
				elsif (x == 0 or x == padwidth - 1) then
					line += "|"
				elsif (y == 0 or y == padheight - 1) then
					line += "-"
				else
					case c2i(x-1, y-1)
					when @a
						line += "A"
					when @b
						line += "B"
					when @c
						line += "C"
					else
						line += cell_to_s(x - 1, y - 1)
					end
				end
			end

			maze += line + "\n"
		end

		"[ #{@width}, #{@height}, #{@floorprobability} ]\n" +
		"[ A: #{@a}, B: #{@b}, C: #{@c} ]\n" +
		"#{maze}"
	end

	private

	def create!
		prob = @floorprobability || 0.5

		floortiles = []

		@tiles.length.times do |index|
			if rand(nil) < prob then
				@tiles[index] = :floor
				floortiles << index
			end
		end

		@a = floortiles.shift
		@c = floortiles.pop
		@b = floortiles.sample
	end

	def c2i(x, y)
		y * @width + x
	end

	def i2c(i)
		[i % @width, i / @width]
	end

	def cell(x, y)
		@tiles[c2i(x, y)]
	end

	def cell_to_s(x, y)
		case cell(x, y)
		when :wall
			"X"
		when :floor
			" "
		end
	end

end
