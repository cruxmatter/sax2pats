require 'yaml'
require 'json'
require 'zip'
require 'redis'
require 'redis-namespace'

module Sax2pats
  module CPC
    class LoadingError < StandardError; end

    class Loader
      VERSION_FILE_MAPPER = {
        '201908' => 'cpc_201908.zip',
        '201309' => 'cpc_201309.zip'
      }.freeze

      # The cpc version indicator in the patent xml
      # needs to be mapped to a cpc version release
      VERSION_DATE_MAPPER = {
        '20130101' => '201309',
        '20150115' => '201908'
      }.freeze

      CPC_DATA_PATH = [
        'lib',
        'sax2pats',
        'classifications',
        'data',
      ].freeze

      ALL_LOADED_KEY = 'all_loaded'.freeze

      def initialize(redis_host: nil, redis_port: nil, redis_password: nil, data_path: nil)
        @current_version = nil
        @redis_client = Redis.new(**{
          host: redis_host,
          port: redis_port,
          password: redis_password
        }.compact)
        @data_path = data_path || CPC_DATA_PATH
      end

      def title(symbol, cpc_release_date: nil, cpc_version_indicator: nil)
        version_key = "#{cpc_release_date || VERSION_DATE_MAPPER[cpc_version_indicator]}"
        unless VERSION_FILE_MAPPER.keys.include?(version_key)
          raise LoadingError.new("Unrecognized version date #{version_key}")
        end
        key = "#{version_key}:#{symbol}"
        JSON.parse(@redis_client.get(key) || '{}')
      end

      def loaded?
        @redis_client.get(ALL_LOADED_KEY) == 'true'
      end

      def clear_data!
        @redis_client.flushall
      end

      def process_all_versions!
        VERSION_FILE_MAPPER.keys.each do |version|
          process!(version)
        end

        @redis_client.set(ALL_LOADED_KEY, true)
      end

      def process!(version)
        @current_version = version
        @redis = Redis::Namespace.new(
          @current_version.to_sym,
          redis: @redis_client
        )
        return unless VERSION_FILE_MAPPER.key?(version)

        Zip::File.open(version_path(version)) do |zip_file|
          zip_file.entries.each do |zip_entry|
            next unless zip_entry.file? && zip_entry.name.include?('xml')
            scheme_reader = CPCSchemeXMLParser.new(
              StringIO.new(zip_entry.get_input_stream.read),
              self
            )
            scheme_reader.parse
          end
        end
      end

      def read_classification_item(class_item, parent_item)
        parent_symbol = parent_item ? parent_item['classification-symbol'] : nil
        symbol = class_item['classification-symbol']
        title = class_item['class-title'].to_hash if class_item['class-title']
        @redis.set(
          symbol.to_s,
          {
            symbol: symbol.to_s,
            parent: parent_symbol,
            title: title
          }.to_json
        )
      end

      def key_size
        @redis_client.dbsize
      end

      private

      def version_path(version)
        root = File.expand_path ''

        File.join(
          root,
          *@data_path,
          VERSION_FILE_MAPPER[version]
        )
      end
    end

    class CPCSchemeXMLParser
      attr_accessor :classifications

      def initialize(file, loader)
        @loader = loader
        @file = file
      end

      def parse
        read_classification_scheme
        @parser.for_tag(:'classification-item').each do |item|
          @loader.read_classification_item(item, nil)
          next_items(item)
        end
      end

      private

      def read_classification_scheme
        @parser = Saxerator.parser(@file) do |config|
          config.adapter = :ox
          config.put_attributes_in_hash!
        end
      end

      def next_items(item)
        return unless item['classification-item']

        Utility::array_wrap(item['classification-item']).each do |class_item|
          @loader.read_classification_item(class_item, item)
          next_items(class_item)
        end
      end
    end
  end
end
