require "spec_helper"

RSpec.describe Sax2pats do
  it "has a version number" do
    expect(Sax2pats::VERSION).not_to be nil
  end

  context 'SAX parse USPTO Patent XML' do

    before(:each) do
      @patents = []
      patent_handler = Proc.new{|pt| @patents << pt  }
      processor = Sax2pats::Processor.new(patent_handler)
      filename = File.join(File.dirname(__FILE__), 'test.xml')
      File.open(filename) do |f|
        Ox.sax_parse(processor, f)
      end
    end

    it "SAX parse USPTO Patent XML" do
      expect(@patents.first.inventors.size).to eq 1
      expect(@patents.size).to eq 130
      expect(@patents.map{|pt| pt.claims.size}).to match_array(@patents.map{|pt| pt.number_of_claims.to_i})
    end

    it 'abstract' do
      expect(@patents.first.abstract.start_with?('A first device may receive a first session token from a second device;')).to be_truthy
    end

    it 'patent classifications' do
      expect(@patents.first.classifications.size).to eq 4
      expect(@patents.first.classifications.first["classification-level"]).to eq "A"
      expect(@patents.first.classifications.first["section"]).to eq "H"
    end
  end
end
