require 'yaml'
require 'zlib'
require 'active_support/core_ext/hash/indifferent_access'

module Sax2pats
  class XMLVersion
    attr_accessor :version_mapper

    def initialize
      File.open(
        File.join(
          Utility::root,
          'lib',
          'sax2pats',
          'xml_version_adaptors',
          'version_data_mappers',
          self.class::VERSION_MAP_FILE
        )
      ) { |f| @version_mapper = YAML.safe_load(f).with_indifferent_access }

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

    def get_entity_data(parent_key, entity_key, data_hash)
      return data_hash unless parent_key
      data_hash.dig(*version_mapper.dig(parent_key, entity_key))
    end 

    def get_attribute_data(attribute_key, data_hash)
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
end
