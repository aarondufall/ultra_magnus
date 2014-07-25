require "ultra_magnus/version"
require "ultra_magnus/property"

module UltraMagnus
  @registry = {}
	def	self.define(&block)
		definition_proxy = DefinitionProxy.new
    definition_proxy.instance_eval(&block)
	end

	def self.registry
		@registry
	end

	def self.transform(transformer_name, data)
		transformer = registry[transformer_name]
		transformer.process(data)
	  transformer.result
	end

	class DefinitionProxy
	  def transformer(transformer_name, &block)
	    transformer = Transformer.new
	    if block_given?
	    	transformer.instance_eval(&block)
	    end

	    UltraMagnus.registry[transformer_name] = transformer
	  end
	end


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
