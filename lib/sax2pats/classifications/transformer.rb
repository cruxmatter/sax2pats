require 'yaml'

module Sax2pats
  module CPC
    class Transformer
      def initialize(schema_directory, titles_directory, output_file)
        @classifications = {}
        @titles = {}
        @schema_directory = schema_directory
        @titles_directory = titles_directory
        @output_file = output_file

        map_title_files
      end

      def map_title_files
        Dir.entries(@titles_directory).select { |f| f.include? '.txt' }.each do |file_name|
          titles_reader = CPCTitles.new(File.join(@titles_directory, file_name))
          titles_reader.parse
          @titles.merge! titles_reader.titles
        end
      end

      def process
        Dir.entries(@schema_directory).select { |f| f.include? '.xml' }.each do |file_name|
          p file_name
          scheme_reader = CPCSchemeXML.new(File.join(@schema_directory, file_name))
          scheme_reader.parse
          c = scheme_reader.classifications
          c.each do |k, v|
            v[:title] = @titles[k]
          end
          @classifications.merge! c
        end
      end

      def to_yaml
        File.open(@output_file, 'w') do |f|
          @classifications.each do |k, values|
            write_symbol(f, k, values)
          end
        end
      end

      private

      def write_symbol(file, symbol, values)
        file.write "#{symbol}:\n"
        values.each do |k, d|
          if k == :title
            file.write "\s\s#{k}: \"#{d.gsub('"', "'")}\"\n"
          elsif k == :date_revised
            file.write "\s\s#{k}: \"#{d}\"\n"
          else
            file.write "\s\s#{k}: #{d}\n"
          end
        end
      end
    end

    class CPCTitles
      attr_accessor :titles

      def initialize(titles_file_path)
        @file = File.open(titles_file_path, 'r')
        @titles = {}
      end

      def parse
        @titles = @file.readlines.map(&:chomp).map{ |l| l.split(/\t/) }.to_h
      end
    end

    class CPCSchemeXML
      attr_accessor :classifications

      def initialize(schema_file_path)
        @file = File.open(schema_file_path, 'r')
        @classifications = {}
      end

      def parse
        read_classification_scheme
        @parser.for_tag(:'classification-item').each do |item|
          set_data(item)
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

      def set_data(item)
        symbol = item['classification-symbol']
        @classifications[symbol] = {
          date_revised: item['date-revised']
        }
      end

      def next_items(item)
        return unless item['classification-item']

        array_wrap(item['classification-item']).each do |class_item|
          set_data(class_item)
          next_items(class_item)
        end
      end
    end
  end
end
