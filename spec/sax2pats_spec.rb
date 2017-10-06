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
      expect(@patents.first.abstract.include?('A first device may receive a first session token from a second device;')).to be_truthy
    end

    it 'inventors' do
      expect(@patents.last.inventors.size).to eq 3
      expect(@patents.last.inventors.map(&:last_name)).to match_array(["Afkhami", "Katar", "Rouhana"])
    end

    it 'patent classifications' do
      expect(@patents.first.classifications.size).to eq 4
      expect(@patents.first.classifications.first.classification_level).to eq "A"
      expect(@patents.first.classifications.first.section).to eq "H"
    end

    it 'drawings' do
      expect(@patents.last.drawings.size).to eq 10
      expect(@patents.last.drawings.first.figure[:id]).to eq 'Fig-EMI-D00000'
    end

    it 'description' do
      expect(@patents.last.description.include?('Computer program code for carrying out operations for aspects of the present inventive subject matter may be written in any combination of one or more programming languages, including an object oriented programming language such as Java, Smalltalk, C++ or the like and conventional procedural programming languages, such as the “C” programming language or similar programming languages.')).to be_truthy
    end
  end
end
