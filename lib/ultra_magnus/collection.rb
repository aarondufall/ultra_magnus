module UltraMagnus
	class Collection
		def initialize(name, source, options, &block)
			@name = name
			@source = source
			@options = options || {}
			@block = block
		end

		def process(data)
			# NOTE All transformers return a Hash
			result = {@name => transform_collection(data, @options)}	  			
			result[@name] = result[@name].reject {|r| r.empty? }
  		if @options[:recursive]
  			r_data = deep_result_fetch(data,@options)
  			transform_recusive(r_data, @options, result[@name])
  		end
  		result
		end


	 	def transform_collection(data, options)
	  	results = fetch_collection(@source, data)
	  	if @block
	  	results = results.map do |result|
				if @block
					transformer = Transformer.new
					transformer.instance_exec(result, &@block)
					transformer.process({})
				end
	  	end
	  	results.reject { |r| r.nil? || r.empty? }
	  	end
	  	results
	  end

	  def transform_recusive(data, options, collection)
		 	transform_collection(data, options).each do |td|
 				collection << td
 			end	

 			if r_data = deep_result_fetch(data,options)
 				transform_recusive(r_data, options, collection)
 			end
  	end

	  def deep_result_fetch(data, options)
			fetch_collection(@source, data).map {|d| fetch_collection(@source, d)}.reject {|r| r.empty? }.first
  	end

	  def fetch_collection(location, data)
	  	#TODO log if data found
	  	#TODO return empty array for transform collection
	  	return [] if location.nil?
	  	return location if location[0].is_a?(Hash)
  		result = Array(location).inject(data) do |d, key| 
  			next if d == location
  			next if d.nil?
  			d.fetch(key, location) 
  		end
  		Array(result)
	  end
	end
end