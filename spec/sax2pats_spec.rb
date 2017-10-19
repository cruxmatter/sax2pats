require "spec_helper"
require 'pry'

RSpec.describe Sax2pats do
  it "has a version number" do
    expect(Sax2pats::VERSION).not_to be nil
  end

  context 'SAX parse USPTO Patent XML' do

    before(:each) do
      @patents = []
      patent_handler = Proc.new{|pt| @patents << pt  }
      filename = File.join(File.dirname(__FILE__), 'test.xml')
      f = File.new(filename)
      h = Sax2pats::Handler.new(f, patent_handler)
      h.parse_patents
    end

    it 'parsed all patents' do
      expect(@patents.size).to eq 130
    end

    context 'patent' do
      it 'element attributes' do
        patent = @patents.first
        expect(patent.invention_title).to eq 'Authenticating a user device to access services based on a device ID'
        expect(patent.publication_reference['document-id']['doc-number']).to eq '09537659'
        expect(patent.publication_reference['document-id']['country']).to eq 'US'
        expect(patent.publication_reference['document-id']['kind']).to eq 'B2'
        expect(patent.publication_reference['document-id']['date']).to eq '20170103'

        expect(patent.application_reference['document-id']['doc-number']).to eq '14015072'
        expect(patent.application_reference['document-id']['country']).to eq 'US'
        expect(patent.application_reference['document-id']['date']).to eq '20130830'
      end

      it 'patent abstract' do
        expect(@patents.first.abstract.include?('A first device may receive a first session token from a second device;')).to be_truthy
      end

      it 'patent description' do
        expect(@patents.last.description.include?('Computer program code for carrying out operations for aspects of the present inventive subject matter may be written in any combination of one or more programming languages, including an object oriented programming language such as Java, Smalltalk, C++ or the like and conventional procedural programming languages, such as the “C” programming language or similar programming languages.')).to be_truthy
      end

      it 'patent inventors' do
        expect(@patents.last.inventors.size).to eq 3
        expect(@patents.first.inventors.size).to eq 1
      end

      it 'patent citations' do
        expect(@patents.first.citations.size).to eq 6
      end

      it 'patent claims' do
        expect(@patents.map{|pt| pt.claims.size}).to match_array(@patents.map{|pt| pt.number_of_claims.to_i})
      end

      it 'patent classifications' do
        expect(@patents.first.classifications.size).to eq 4
      end

      it 'patent drawings' do
        expect(@patents.last.drawings.size).to eq 10
      end
    end

    context 'inventor' do
      it 'inventor' do
        expect(@patents.last.inventors.map(&:last_name)).to match_array(["Afkhami", "Katar", "Rouhana"])
      end
    end

    context 'citation' do
      it 'citation' do
        expect(@patents.first.citations.first.doc_number).to eq '8607306'
      end
    end

    context 'classification' do
      it 'classification' do
        expect(@patents.first.classifications.first["classification-level"]).to eq "A"
        expect(@patents.first.classifications.first["section"]).to eq "H"
      end
    end

    context 'drawing' do
      it 'drawing' do
        expect(@patents.last.drawings.first.figure[:id]).to eq 'Fig-EMI-D00000'
      end
    end
  end
end
