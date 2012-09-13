class Dungeon
	def initialize(width, height, floorprob)
		@width = width
		@height = height
		@floorprob = floorprob

		@tiles = Array.new(@width * @height, :wall)

		create!
	end

	def create!
		prob = @floorprob || 0.5

		@tiles.length.times do |index|
			if rand(nil) < prob then
				@tiles[index] = :floor
			end
		end
	end

	def tiles
		@tiles
	end

	def c2i(x, y)
		y * @width + x
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

	def to_s
		padwidth = @width + 2
		padheight = @height + 2

		padheight.times do |y|
			str = ""

			padwidth.times do |x|
				if (x == 0 and y == 0) or
					(x == padwidth - 1 and y == 0) or
					(x == padwidth - 1 and y == padheight - 1) or
					(x == 0 and y == padheight - 1) then
					str += "+"
				elsif (x == 0 or x == padwidth - 1) then
					str += "|"
				elsif (y == 0 or y == padheight - 1) then
					str += "-"
				else
					str += cell_to_s(x - 1, y - 1)
				end
			end

			puts str
		end
	end
end
