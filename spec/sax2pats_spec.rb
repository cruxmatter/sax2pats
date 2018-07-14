require "spec_helper"

RSpec.describe Sax2pats do
  it "has a version number" do
    expect(Sax2pats::VERSION).not_to be nil
  end

  context 'SAX parse USPTO Patent XML' do

    before(:each) do
      @patents = []
      patent_handler = Proc.new{|pt| @patents << pt  }
      filename = File.join(File.dirname(__FILE__), 'test.xml')
      h = Sax2pats::SplitHandler.new(filename, patent_handler)
      h.parse_patents
    end

    let(:patent_1) do
      @patents.detect do |patent|
        patent.publication_reference['document-id']['doc-number'] == '09537659'
      end
    end

    let(:patent_2) do
      @patents.detect do |patent|
        patent.publication_reference['document-id']['doc-number'] == '09537792'
      end
    end

    it 'parsed all patents' do
      expect(@patents.size).to eq 130
    end

    context 'patent' do
      it 'has xml version' do
        expect(patent_1.from_version).to eq '4.5'
      end

      it 'element attributes' do
        expect(patent_1.invention_title).to eq 'Authenticating a user device to access services based on a device ID'
        expect(patent_1.publication_reference['document-id']['doc-number']).to eq '09537659'
        expect(patent_1.publication_reference['document-id']['country']).to eq 'US'
        expect(patent_1.publication_reference['document-id']['kind']).to eq 'B2'
        expect(patent_1.publication_reference['document-id']['date']).to eq '20170103'

        expect(patent_1.application_reference['document-id']['doc-number']).to eq '14015072'
        expect(patent_1.application_reference['document-id']['country']).to eq 'US'
        expect(patent_1.application_reference['document-id']['date']).to eq '20130830'
      end

      it 'patent abstract' do
        expect(patent_1.abstract_text.include?(
          'A first device may receive a first session token from a second device;'
          )).to be_truthy
      end

      it 'patent description' do
        expect(patent_2.description_text.include?('Computer program code for carrying out operations for aspects of the present inventive subject matter may be written in any combination of one or more programming languages, including an object oriented programming language such as Java, Smalltalk, C++ or the like and conventional procedural programming languages, such as the “C” programming language or similar programming languages.')).to be_truthy
      end

      it 'patent inventors' do
        expect(patent_2.inventors.size).to eq 3
        expect(patent_1.inventors.size).to eq 1
      end

      it 'patent citations' do
        expect(patent_1.citations.size).to eq 6
      end

      it 'patent claims' do
        expect(@patents.map{|pt| pt.claims.size}).to match_array(@patents.map{|pt| pt.number_of_claims.to_i})
      end

      it 'patent claim refs' do
        expect(patent_1.claims.map(&:refs)).to match_array([[],["CLM-00001"],["CLM-00001"],["CLM-00001"],["CLM-00001"],["CLM-00001"],["CLM-00001"],["CLM-00001"],[],["CLM-00009"],["CLM-00009"],["CLM-00009"],["CLM-00009"],["CLM-00009"],["CLM-00009"],[],["CLM-00016"],["CLM-00016"],["CLM-00016"],["CLM-00016"]])
      end

      it 'patent classifications' do
        expect(patent_1.classifications.size).to eq 4
      end

      it 'patent drawings' do
        expect(patent_2.drawings.size).to eq 10
      end
    end

    context 'inventor' do
      it 'inventor' do
        expect(patent_2.inventors.map(&:last_name)).to match_array(["Afkhami", "Katar", "Rouhana"])
      end
    end

    context 'citation' do
      it 'citation' do
        expect(patent_1.citations.first.document_id.fetch('doc-number')).to eq '8607306'
      end
    end

    context 'classifications' do
      let(:patent_3) do
        @patents.detect do
          |patent| patent.publication_reference['document-id']['doc-number'] == '09537663'
        end
      end

      it 'national' do
        expect(patent_3.classification_national.main_classification).to eq "455411"
      end

      it 'other' do
        expect(patent_1.classifications.first.classification_level).to eq "A"
        expect(patent_1.classifications.first.section).to eq "H"
      end
    end

    context 'drawing' do
      it 'drawing' do
        expect(patent_2.drawings.first.figure['id']).to eq 'Fig-EMI-D00000'
      end
    end
  end
end
