module UltraMagnus	
	class DefinitionProxy
	  def transformer(transformer_name, &block)
	    transformer = Transformer.new
	    if block_given?
	    	transformer.instance_eval(&block)
	    end

	    UltraMagnus.registry[transformer_name] = transformer
	  end
	end
end