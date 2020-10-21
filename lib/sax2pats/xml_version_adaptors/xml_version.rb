require 'yaml'
require 'zlib'

module Sax2pats
  class XMLVersion
    attr_accessor :version_mapper

    def initialize(version, version_map_file)
      File.open(
        File.join(
          Utility::root,
          'lib',
          'sax2pats',
          'xml_version_adaptors',
          'version_data_mappers',
          version_map_file
        )
      ) { |f| @version_mapper = YAML.safe_load(f) }

      compute_attribute_paths
    end

    def patent_tag(state)
      if state == :grant
        @version_mapper.dig('xml', 'patent_grant_tag')
      elsif state == :application
        @version_mapper.dig('xml', 'patent_application_tag')
      end
    end

    def patent_type(patent_hash)
      patent_hash.dig(
        *@version_mapper.dig('patent', 'patent_type')
      )
    end

    def get_entity_data(attribute_key, data_hash)
      attrs = 
        @attribute_paths.fetch(attribute_key)
          .map { |path| data_hash.dig(*path) }
          .compact
      return nil if attrs.empty?
      return attrs.first if attrs.size == 1
      attrs
    end

    def find_all_attribute_paths(lookup_path, paths=[], current_path=[])
      if lookup_path.is_a? String
        if current_path.empty?
          paths << current_path
        end
        current_path << lookup_path
      elsif lookup_path.is_a? Array
        lookup_path.each { |key| find_all_attribute_paths(key, paths, current_path)  }
      elsif lookup_path.is_a? Hash
        dup = current_path.dup if lookup_path.keys.size > 1
        lookup_path.each do |k,v|
          find_all_attribute_paths(v, paths, current_path)
          current_path = dup
          paths << current_path
        end
      end
      paths
    end

    private

    def compute_attribute_paths
      @attribute_paths = {}
      @version_mapper.each do |entity_key, attribute_keys|
        attribute_keys.each do |k,v|
          @attribute_paths[k] = find_all_attribute_paths(v)
        end
      end
    end
  end

  # module EntityVersion
  #   attr_accessor :entity_attribute_hash

  #   def initialize(entity_hash)
  #     @entity_attribute_hash = entity_hash
  #     self.class.version_mapper.keys.map do |attribute|
  #       attrs_list = find_all_attribute_paths(self.class.version_mapper[attribute])
  #       @entity_attribute_hash[attribute] = if attrs_list.size > 1
  #         get_attributes_from_entity_hash(entity_hash, attrs_list, attribute)
  #       else
  #         entity_hash.dig(*self.class.version_mapper[attribute])
  #       end
  #       @entity_attribute_hash[attribute] = @entity_attribute_hash[attribute] || entity_hash[attribute]
  #     end
  #   end

  #   def get_attributes_from_entity_hash(entity_hash, attrs_list, attribute)
  #     attrs = attrs_list.map { |path| entity_hash.dig(*path) }.compact
  #     unless self.attribute_types[attribute] == 'array' || self.child_entity_types.dig(attribute, :type) == 'array'
  #       return nil if attrs.empty?
  #       attrs.first
  #     end
  #     attrs
  #   end

  #   def find_all_attribute_paths(lookup_path, paths=[], current_path=[])
  #     if lookup_path.is_a? String
  #       if current_path.empty?
  #         paths << current_path
  #       end
  #       current_path << lookup_path
  #     elsif lookup_path.is_a? Array
  #       lookup_path.each { |key| find_all_attribute_paths(key, paths, current_path)  }
  #     elsif lookup_path.is_a? Hash
  #       dup = current_path.dup if lookup_path.keys.size > 1
  #       lookup_path.each do |k,v|
  #         find_all_attribute_paths(v, paths, current_path)
  #         current_path = dup
  #         paths << current_path
  #       end
  #     end
  #     paths
  #   end

  #   def enumerate_child_entities(child_entities, filter_block: nil)
  #     if Utility::is_array?(child_entities)
  #       child_entities = filter_block.call(child_entities) if filter_block
  #       child_entities.each do |child_entity_hash|
  #         yield child_entity_hash
  #       end
  #     elsif Utility::is_hash?(child_entities)
  #       yield child_entities
  #     end
  #   end
  # end

  # module XMLVersion
  #   module ClassMethods
  #     CHILD_ENTITIES = [
  #       :inventors,
  #       :assignees,
  #       :examiners,
  #       :applicants,
  #       :claims,
  #       :drawings,
  #       :citations,
  #       :ipc_classifications,
  #       :national_classifications
  #     ]

  #     CHILD_ENTITIES.each do |entities_name|
  #       define_method("#{entities_name}_filter") {}
  #     end

  #     def patent_version_class
  #       this = self
  #       Class.new(Object) do
  #         include EntityVersion

  #         CHILD_ENTITIES.each do |entities_name|
  #           define_method("enumerate_child_#{entities_name}") do |child_entities, &block|
  #             enumerate_child_entities(
  #               child_entities,
  #               filter_block: this.send("#{entities_name}_filter")
  #             ) do |child_entity|
  #               block.call(child_entity)
  #             end
  #           end
  #         end
  #       end
  #     end

  #     def define_patent_version(version_mapper)
  #       version_class = patent_version_class
  #       define_version_entity(
  #         version_mapper,
  #         'patent',
  #         'PatentGrantVersion',
  #         version_class: version_class
  #       )
  #     end

  #     def define_version_entity(version_mapper, entity_key, class_name, version_class: nil)
  #       version_class ||= Class.new(Object) do
  #         include EntityVersion
  #       end

  #       version_class.define_singleton_method(:version_mapper) do
  #         version_mapper.fetch(entity_key)
  #       end
  #       const_set(class_name, version_class)
  #     end
  #   end

  #   def self.included(base)
  #     base.extend(ClassMethods)

  #     version_mapper = nil
  #     File.open(
  #       File.join(
  #         Utility::root,
  #         'lib',
  #         'sax2pats',
  #         'xml_version_adaptors',
  #         'version_data_mappers',
  #         base::DATA_MAPPER_FILE
  #       )
  #     ) { |f| version_mapper = YAML.safe_load(f) }

  #     base.define_patent_version(version_mapper)
  #     base.define_version_entity(version_mapper, 'inventor', 'InventorVersion')
  #     base.define_version_entity(version_mapper, 'assignee', 'AssigneeVersion')
  #     base.define_version_entity(version_mapper, 'examiner', 'ExaminerVersion')
  #     base.define_version_entity(version_mapper, 'applicant', 'ApplicantVersion')
  #     base.define_version_entity(version_mapper, 'claim', 'ClaimVersion')
  #     base.define_version_entity(version_mapper, 'drawing', 'DrawingVersion')
  #     base.define_version_entity(version_mapper, 'citation', 'CitationVersion')
  #     base.define_version_entity(version_mapper, 'cpc_classification', 'CPCClassificationVersion')
  #     base.define_version_entity(version_mapper, 'ipc_classification', 'IPCClassificationVersion')
  #     base.define_version_entity(version_mapper, 'national_classification', 'NationalClassificationVersion')

  #     define_method(:patent_tag) do |state|
  #       if state == :grant
  #         version_mapper.dig('xml', 'patent_grant_tag')
  #       elsif state == :application
  #         version_mapper.dig('xml', 'patent_application_tag')
  #       end
  #     end
  #     define_method(:patent_type) do |patent_grant_hash|
  #       patent_grant_hash.dig(
  #         *version_mapper.dig('patent', 'patent_type')
  #       )
  #     end
  #   end
  # end
end
