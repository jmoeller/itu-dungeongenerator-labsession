class AStar
	@@pathcost = 1

	def self.pathlength(dungeon, from, to)
		open = [from]
		closed = []
		data = { from => {
			:g => 0,
			:f => dungeon.manhattan(from, to)
		} }

		current_index = -1

		while open.size > 0
			open = open.sort_by { |i| data[i][:f] }

			current_index = open.shift
			
			if current_index == to then
				path = []
				index = current_index

				path << index
				parent = data[index][:parent]

				while not parent == nil
					path << parent
					parent = data[parent][:parent]
				end

				return path.length
			end

			closed << current_index

			dungeon.neighbors(current_index).each do |neighbor|
				next if closed.include?(neighbor)

				cost_from_current = data[current_index][:g] + @@pathcost

				if (not open.include?(neighbor)) or cost_from_current < data[neighbor][:g] then
					open << neighbor if not open.include?(neighbor)

					data[neighbor] = {
						:parent => current_index,
						:g => cost_from_current,
						:f => cost_from_current + dungeon.manhattan(neighbor, to)
					}
				end
			end
		end

		# no path found
		-1	
	end
end
