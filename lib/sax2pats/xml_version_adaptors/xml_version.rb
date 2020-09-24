require 'yaml'
require 'zlib'

module Sax2pats
  module EntityVersion
    attr_accessor :entity_attribute_hash

    def initialize(entity_hash)
      @entity_attribute_hash = entity_hash
      self.class.version_mapper.keys.each do |attribute|
        attrs_list = find_all_attribute_paths(self.class.version_mapper[attribute])
        @entity_attribute_hash[attribute] = if attrs_list.size > 1
          get_attributes_from_entity_hash(entity_hash, attrs_list)
        else
          entity_hash.dig(*self.class.version_mapper[attribute])
        end
        @entity_attribute_hash[attribute] = @entity_attribute_hash[attribute] || entity_hash[attribute]
      end
    end

    def get_attributes_from_entity_hash(entity_hash, attrs_list)
      attrs_list.map { |path| entity_hash.dig(*path) }.compact
    end

    def find_all_attribute_paths(lookup_path, paths=[], current_path=[])
      lookup_path = Utility::array_wrap(lookup_path)
      lookup_path.each do |key|
        if key.is_a? String
          current_path << key
        elsif key.is_a? Hash
          key.each do |k,v|
            find_all_attribute_paths(v, paths, current_path.dup)
          end
        end
      end
      paths << current_path if lookup_path.last.is_a? String
      paths
    end

    def enumerate_child_entities(child_entities, filter_block: nil)
      if Utility::is_array?(child_entities)
        child_entities = filter_block.call(child_entities) if filter_block
        child_entities.each do |child_entity_hash|
          yield child_entity_hash
        end
      elsif Utility::is_hash?(child_entities)
        yield child_entities
      end
    end
  end

  module XMLVersion
    module ClassMethods
      CHILD_ENTITIES = [
        :inventors,
        :assignees,
        :examiners,
        :applicants,
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

      def define_patent_application_version(version_mapper)
        version_class = patent_version_class

        define_version_entity(
          version_mapper,
          ['patent', 'patent_application'],
          'PatentApplicationVersion',
          version_class: version_class
        )
      end

      def define_patent_grant_version(version_mapper)
        version_class = patent_version_class

        define_version_entity(
          version_mapper,
          ['patent', 'patent_grant'],
          'PatentGrantVersion',
          version_class: version_class
        )
      end

      def define_version_entity(version_mapper, entity_keys, class_name, version_class: nil)
        entity_keys = Array(entity_keys)
        
        version_class ||= Class.new(Object) do
          include EntityVersion
        end

        version_class.define_singleton_method(:version_mapper) do
          entity_keys.inject({}) { |hash, key| hash.merge(version_mapper.dig(key) || {}) }
        end
        const_set(class_name, version_class)
      end
    end

    def self.included(base)
      base.extend(ClassMethods)

      version_mapper = nil
      File.open(
        File.join(
          Utility::root,
          'lib',
          'sax2pats',
          'xml_version_adaptors',
          'version_data_mappers',
          base::DATA_MAPPER_FILE
        )
      ) { |f| version_mapper = YAML.safe_load(f) }

      base.define_patent_grant_version(version_mapper)
      base.define_patent_application_version(version_mapper)
      base.define_version_entity(version_mapper, 'inventor', 'InventorVersion')
      base.define_version_entity(version_mapper, 'assignee', 'AssigneeVersion')
      base.define_version_entity(version_mapper, 'examiner', 'ExaminerVersion')
      base.define_version_entity(version_mapper, 'applicant', 'ApplicantVersion')
      base.define_version_entity(version_mapper, 'claim', 'ClaimVersion')
      base.define_version_entity(version_mapper, 'drawing', 'DrawingVersion')
      base.define_version_entity(version_mapper, 'citation', 'CitationVersion')
      base.define_version_entity(version_mapper, 'cpc_classification', 'CPCClassificationVersion')
      base.define_version_entity(version_mapper, 'ipc_classification', 'IPCClassificationVersion')
      base.define_version_entity(version_mapper, 'national_classification', 'NationalClassificationVersion')

      base.class_eval do 
        define_method(:patent_tag) do |state|
          if state == :grant
            version_mapper.dig('xml', 'patent_grant_tag')
          elsif state == :application
            version_mapper.dig('xml', 'patent_application_tag')
          end
        end
      end
      base.class_eval do 
        define_method(:patent_type) do |state, patent_hash|
          if state == :grant
            patent_hash.dig(
              *version_mapper.dig('patent_grant', 'patent_type')
            )
          elsif state == :application
            patent_hash.dig(
              *version_mapper.dig('patent_application', 'patent_type')
            )
          end
        end
      end
    end
  end
end
