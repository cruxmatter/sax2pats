require 'yaml'

module Sax2pats
  module EntityVersion
    attr_accessor :entity_attribute_hash

    def initialize(entity_hash)
      @entity_attribute_hash = entity_hash
      self.class.version_mapper.keys.map do |attr|
        @entity_attribute_hash[attr] =
          entity_hash.dig(*self.class.version_mapper[attr]) ||
          entity_hash[attr]
      end
    end

    def enumerate_child_entities(child_entities)
      if child_entities.is_a?(Saxerator::Builder::HashElement)
        yield child_entities
      elsif child_entities.is_a?(Saxerator::Builder::ArrayElement)
        child_entities.each do |child_entity_hash|
          yield child_entity_hash
        end
      end
    end
  end

  module XMLVersion
    attr_accessor :version_mapper

    def self.define_version_entity(entity_key, class_name)
      version_class = Class.new(Object) do
        include EntityVersion

        # TODO: allow custom block
      end

      version_class.define_singleton_method(:version_mapper) do
        @@version_mapper.fetch(entity_key)
      end
      const_set(class_name, version_class)
    end

    def self.included(mod)
      root = File.expand_path ''
      File.open(
        File.join(
          root,
          'lib',
          'sax2pats',
          'xml_version_adaptors',
          'version_data_mappers',
          mod::DATA_MAPPER_FILE
        )
      ) { |f| @@version_mapper = YAML.safe_load(f) }

      define_version_entity('patent', 'PatentGrantVersion')
      define_version_entity('inventor', 'InventorVersion')
      define_version_entity('claim', 'ClaimVersion')
      define_version_entity('drawing', 'DrawingVersion')
      define_version_entity('citation', 'CitationVersion')
      define_version_entity('cpc_classification', 'CPCClassificationVersion')
      define_version_entity('ipc_classification', 'IPCClassificationVersion')
      define_version_entity('national_classification', 'NationalClassificationVersion')
    end

    def patent_tag(mode)
      if mode == :grant
        @@version_mapper.dig('xml', 'patent_grant_tag')
      elsif mode == :application
        @@version_mapper.dig('xml', 'patent_application_tag')
      end
    end

    def patent_type(patent_grant_hash)
      patent_grant_hash.dig(
        *@@version_mapper.dig('patent', 'patent_type')
      )
    end
  end
end
