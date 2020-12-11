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

    def patent_type(state, patent_hash)
      if state == :grant
        patent_hash.dig(
          *@version_mapper.dig('patent_grant', 'patent_type')
        )
      elsif state == :application
        patent_hash.dig(
          *@version_mapper.dig('patent_application', 'patent_type')
        )
      end
    end

    def transform_entity_data(parent_key, entity_key, data_hash)
      return data_hash unless parent_key

      key_path = version_mapper.dig(parent_key.to_s, entity_key.to_s)
      
      if key_path
        transform_attribute_data(parent_key.to_s, entity_key.to_s, data_hash)
      end
    end 

    def transform_attribute_data(entity_key, attribute_key, data_hash)
      paths = @attribute_paths.dig(entity_key, attribute_key)
      return if paths.to_a.empty?
      attrs = paths.map { |path| data_hash.dig(*path) }.compact
      return nil if attrs.empty?
      return attrs.first if attrs.size == 1
      attrs
    end

    def filter_entity_data(parent_key, entity_key, data)
      return data unless @filter_keys[parent_key.to_s][entity_key.to_s]

      if Sax2pats::Utility.is_array?(data)
        data.select { |item| item.keys.include? @filter_keys[parent_key.to_s][entity_key.to_s] }
      elsif (Sax2pats::Utility.is_hash?(data) && data.keys.include?(@filter_keys[parent_key.to_s][entity_key.to_s]))
        data
      end
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
      @filter_keys = {}
      @version_mapper.each do |entity_key, attribute_keys|
        @attribute_paths[entity_key] ||= {}
        @filter_keys[entity_key] ||= {}
        attribute_keys.each do |k,v|
          paths = find_all_attribute_paths(v)
          @attribute_paths[entity_key][k] = paths

          paths.each do |path|
            if path.last.starts_with? '~'
              # Only support 1 filter key
              @filter_keys[entity_key][k] = path.pop[1..-1]
            end
          end

          @attribute_paths[entity_key][k] = paths
        end
      end
    end
  end
end
