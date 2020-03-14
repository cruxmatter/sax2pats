require 'yaml'
require 'zip'

module Sax2pats
  module CPC
    class Loader
      attr_accessor :classifications, :metadata

      VERSION_FILE_MAPPER = {
        '201908' => 'cpc_201908.zip',
        '201309' => 'cpc_201309.zip'
      }

      VERSION_DATE_MAPPER = {
        '20130101' => '201309', # TODO: remove and replace
        '20150115' => '201908' # TODO: remove and replace
      }

      def initialize
        @metadata = {}
        @current_version = nil
      end

      def title(version_date, symbol)
        @metadata[VERSION_DATE_MAPPER[version_date]][symbol]
      end

      def process(version)
        @current_version = version
        @metadata[version] ||= {}
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
        @metadata[@current_version][symbol.to_s] = {
          symbol: symbol.to_s,
          parent: parent_symbol,
          title: title
        }
      end

      private

      def version_path(version)
        root = File.expand_path ''

        File.join(
          root,
          'lib',
          'sax2pats',
          'classifications',
          'data',
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

      def array_wrap(o)
        o.is_a?(Saxerator::Builder::ArrayElement) ? o : [o]
      end

      def next_items(item)
        return unless item['classification-item']

        array_wrap(item['classification-item']).each do |class_item|
          @loader.read_classification_item(class_item, item)
          next_items(class_item)
        end
      end
    end
  end
end
