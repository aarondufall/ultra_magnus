module UltraMagnus
	class Transformer
	  def initialize
	    @result = {}
	    @properties = []
	    @collections = []
	    @filters = []
	    @parent = nil
	  end

	  attr_accessor :parent_collection,:parent
	  attr_reader :result, :properties, :collections
		attr_writer :result	  


	  def process(data)

		 	process_properties(data)
	 
	  	if !@filters.empty?
		  	process_filters(data)
		  end

		  process_collections(data)
		  @result
	  end

	  private

  	def process_properties(data)
			@properties.each do |property|
				@result.merge! property.process(data)
	  	end
	  end
	  
  	def process_collections(data)
	  	@collections.each do |collection|
	  		@result.merge! collection.process(data)
	  		# next if options[:source].empty?
	  		# if options[:block]
	  		# 	@result[name] = transform_collection(data, options)	  			
	  		# else	
	  		# 	@result[name] = fetch_result(options[:source], data)
	  		# end
	  		# if options[:recursive]
	  		# 	r_data = deep_result_fetch(data,options)
	  		# 	transform_recusive(r_data, options, @result[name])
	  		# end
	  	end
  	end


  	def process_filters(data)
  		@filters.map do |options|
	  		if options[:condition].call
		  		transformer = Transformer.new
					transformer.instance_exec(result, &options[:block])
					@result.merge! transformer.process({})
				end
	  	end
  	end


  	def deep_result_fetch(data, options)
  		fetch_result(options[:source], data).select { |d| fetch_result(options[:source], d)}.first
  	end

  	def property(name, source, options={})
	  	@properties << Property.new(name, source, options)
	  end

	  def collection(name, source, options={}, &block)
	  	@collections << Collection.new(name, source, options, &block) 
	  end

	  def filter(source, options={}, &block)
	  	@filters << {
	  		source: source,
	  		condition: options[:if],
	  		block: block
	  	}
	  end
	end
end