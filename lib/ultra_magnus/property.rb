module UltraMagnus
	class Property
		def initialize(name, source, options)
			@name = name
			@source = source
			@options = options
		end

		def process(data)
			return {} if @source.nil?
  		result = Array(fetch_result(@source,data)).first
  		result = result.match(@options[:normalize]).captures.join(" ") if @options[:normalize]
  		result = set_type(@options[:type], result)
  		{@name => result}
		end

		private

	 	def fetch_result(location, data)
	  	#TODO log if data found / not found
  		Array(location).inject(data) do |d, key| 
  			next if d == location
  			d.fetch(key, location) 
  		end
	  end

	  def set_type(type,data)
	  	case type 
	  		when :string then data.to_s
	  		when :date   then Date.parse(data)	
	  		when :integer then data.to_i
	  		when :float then data.to_f
	  		else data
	  	end
	  end
	end
end