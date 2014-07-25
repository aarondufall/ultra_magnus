require "ultra_magnus/version"
require "ultra_magnus/property"
require "ultra_magnus/collection"
require "ultra_magnus/transformer"
require "ultra_magnus/definition_proxy"

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

end
