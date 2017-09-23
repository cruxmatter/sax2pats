require "spec_helper"

RSpec.describe Sax2pats do
  it "has a version number" do
    expect(Sax2pats::VERSION).not_to be nil
  end

  it "SAX parse USPTO Patent XML" do
    patents = []
    patent_handler = Proc.new{|pt| patents << pt  }
    processor = Sax2pats::Processor.new(patent_handler)
    filename = File.join(File.dirname(__FILE__), 'test.xml')
    File.open(filename) do |f|
      Ox.sax_parse(processor, f)
    end
    expect(patents.first.inventors.size).to eq 1
    expect(patents.size).to eq 146
    # expect(patents.map{|pt| pt.claims.size}).to match_array(patents.map{|pt| pt.number_of_claims})
  end
end
