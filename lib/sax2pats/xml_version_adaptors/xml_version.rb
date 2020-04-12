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

    def enumerate_child_entities(child_entities, filter_block: nil)
      if child_entities.is_a?(Saxerator::Builder::HashElement)
        yield child_entities
      elsif child_entities.is_a?(Saxerator::Builder::ArrayElement)
        child_entities = filter_block.call(child_entities) if filter_block
        child_entities.each do |child_entity_hash|
          yield child_entity_hash
        end
      end
    end
  end

  module XMLVersion
    module ClassMethods
      CHILD_ENTITIES = [
        :inventors,
        :claims,
        :drawings,
        :citations,
        :ipc_classifications,
        :national_classifications
      ]

      CHILD_ENTITIES.each do |entities_name|
        define_method("#{entities_name}_filter") {}
      end

      def patent_version_class
        this = self
        Class.new(Object) do
          include EntityVersion

          CHILD_ENTITIES.each do |entities_name|
            define_method("enumerate_child_#{entities_name}") do |child_entities, &block|
              enumerate_child_entities(
                child_entities,
                filter_block: this.send("#{entities_name}_filter")
              ) do |child_entity|
                block.call(child_entity)
              end
            end
          end
        end
      end

      def define_patent_version(version_mapper)
        version_class = patent_version_class
        define_version_entity(
          version_mapper,
          'patent',
          'PatentGrantVersion',
          version_class: version_class
        )
      end

      def define_version_entity(version_mapper, entity_key, class_name, version_class: nil)
        version_class ||= Class.new(Object) do
          include EntityVersion
        end

        version_class.define_singleton_method(:version_mapper) do
          version_mapper.fetch(entity_key)
        end
        const_set(class_name, version_class)
      end
    end

    def self.included(base)
      base.extend(ClassMethods)

      root = Gem::Specification.find_by_name("sax2pats").gem_dir
      version_mapper = nil
      File.open(
        File.join(
          root,
          'lib',
          'sax2pats',
          'xml_version_adaptors',
          'version_data_mappers',
          base::DATA_MAPPER_FILE
        )
      ) { |f| version_mapper = YAML.safe_load(f) }

      base.define_patent_version(version_mapper)
      base.define_version_entity(version_mapper, 'inventor', 'InventorVersion')
      base.define_version_entity(version_mapper, 'claim', 'ClaimVersion')
      base.define_version_entity(version_mapper, 'drawing', 'DrawingVersion')
      base.define_version_entity(version_mapper, 'citation', 'CitationVersion')
      base.define_version_entity(version_mapper, 'cpc_classification', 'CPCClassificationVersion')
      base.define_version_entity(version_mapper, 'ipc_classification', 'IPCClassificationVersion')
      base.define_version_entity(version_mapper, 'national_classification', 'NationalClassificationVersion')

      define_method(:patent_tag) do |mode|
        if mode == :grant
          version_mapper.dig('xml', 'patent_grant_tag')
        elsif mode == :application
          version_mapper.dig('xml', 'patent_application_tag')
        end
      end
      define_method(:patent_type) do |patent_grant_hash|
        patent_grant_hash.dig(
          *version_mapper.dig('patent', 'patent_type')
        )
      end
    end
  end
end
