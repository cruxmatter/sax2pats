require 'yaml'

module Sax2pats
  class ClassificationParser
    attr_accessor :classifications

    def initialize(file_path, output_file)
      @output_file = output_file
      file = File.open(file_path, 'r')
      @parser = Saxerator.parser(file) do |config|
        config.adapter = :ox
        config.put_attributes_in_hash!
      end

      @classifications = {}
    end

    def parse
      raise NotImplementedError
    end

    def to_yaml
      raise NotImplementedError
    end
  end

  class CPCParser < ClassificationParser
    def parse
      @parser.for_tag(:definitions).each do |definition|
        definition['definition-item'].each do |item|
          symbol = item['classification-symbol']
          raise 'classification symbol already found' if @classifications.keys.include? symbol
          title = if item['definition-title'].kind_of? Saxerator::Builder::ArrayElement
            item['definition-title'].join
          else
            item['definition-title']
          end

          @classifications[symbol] = {
            title: title,
            statement: statement(item['definition-statement']),
            date_revised: item['date-revised']
          }
        end
      end
    end

    def to_yaml
      File.open(@output_file, 'w') { |f| f.write(YAML.dump(@classifications)) }
    end

    private

    def statement(input, text='')
      return text if input.nil?
      if input.kind_of? Saxerator::Builder::ArrayElement
        text += input.map{|i| statement(i, text) }.join
      elsif input.kind_of? Saxerator::Builder::HashElement
        text += input.values.map{|i| statement(i, text) }.join
      elsif input.kind_of? Saxerator::Builder::StringElement
        text += input
      else
        raise 'unknown type'
      end

      text
    end
  end
end
