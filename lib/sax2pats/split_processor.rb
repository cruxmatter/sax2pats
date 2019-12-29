module Sax2pats
  class SplitProcessor < Processor
    def parse_patent(patent_doc)
      processor = Sax2pats::SingleProcessor.new(
        StringIO.new(patent_doc),
        @patent_handler
      ) do |config|
        config.instance_variables.each do |v|
          config.instance_variable_set(v, @config.instance_variable_get(v))
        end
      end
      processor.parse_patents
    end

    def parse_patents
      patent_doc = ''
      @file.each_line do |line|
        if line.start_with?('<?xml') && !patent_doc.empty?
          parse_patent(patent_doc)
          patent_doc = line
        else
          patent_doc << line
        end
      end
      parse_patent(patent_doc) unless patent_doc.empty?
    end
  end
end
