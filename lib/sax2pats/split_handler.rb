module Sax2pats
  class SplitHandler
    attr_accessor :filename, :patent_handler

    def initialize(filename, patent_handler)
      @filename = filename
      @patent_handler = patent_handler
    end

    def parse_patent(patent_doc)
      h = Sax2pats::Handler.new(
        StringIO.new(patent_doc),
        patent_handler
      )
      h.parse_patents
    end

    def parse_patents
      patent_doc = ''
      File.open(filename, 'r').each_line do |line|
        # TODO filter out non-patents
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
