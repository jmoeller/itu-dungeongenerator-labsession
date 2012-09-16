class Array
	def sampleif
		begin
			a = self.sample
		end until yield(a)

		a
	end

	def sampleindexif
		begin
			index = rand(self.length)
		end until yield(self[index])
		
		index
	end
end
