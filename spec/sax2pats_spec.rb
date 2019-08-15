require "spec_helper"

RSpec.describe Sax2pats do
  it "has a version number" do
    expect(Sax2pats::VERSION).not_to be nil
  end

  context 'SAX parse USPTO Patent XML' do

    before(:all) do
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

    describe 'patent' do
      let(:abstract_patent) do
        @patents.detect do |patent|
          patent.publication_reference['document-id']['doc-number'] == '09537660'
        end
      end

      it 'has xml version' do
        expect(patent_1.from_version).to eq '4.5'
      end

      describe 'element attributes' do
        it 'invention_title' do
          expect(patent_1.invention_title).to eq 'Authenticating a user device to access services based on a device ID'
        end

        it 'publication_reference' do
          expect_hash = {
            'doc-number' => '09537659',
            'country' => 'US',
            'kind' => 'B2',
            'date' => '20170103'
          }

          ref_hash = patent_1.publication_reference['document-id']
          ref_hash.each do |k,v|
            expect(v).to eq expect_hash[k]
          end
        end
      end

      it 'patent abstract doc' do
        expect_abstract_doc = '<abstract id="abstract"><p id="p-0001" num="0000">The present invention relates to information security and discloses a method of establishing public key cryptographic protocols against the quantum computational attack. The method includes the following steps: definition of an infinite non-abelian group G; choosing two private keys in G by two entities; a second entity computing y, and sending y to a first entity; the first entity computing x and z, and sending (x, z) to the second entity; the second entity computing w and v, and sending (w, v) to the first entity; the first entity computing u, and sending u to the second entity; and the first entity computing K<sub>A</sub>, and the second entity computing K<sub>B</sub>, thereby reaching a shared key K=K<sub>A</sub>=K<sub>B</sub>. The security guarantee of a public key cryptographic algorithm created by the present invention relies on unsolvability of a problem, and has an advantage of free of the quantum computational attack.</p></abstract>'
        expect(abstract_patent.abstract.as_doc).to eq expect_abstract_doc
      end

      it 'patent abstract text' do
        expect_abstract_text = 'The present invention relates to information security and discloses a method of establishing public key cryptographic protocols against the quantum computational attack. The method includes the following steps: definition of an infinite non-abelian group G; choosing two private keys in G by two entities; a second entity computing y, and sending y to a first entity; the first entity computing x and z, and sending (x, z) to the second entity; the second entity computing w and v, and sending (w, v) to the first entity; the first entity computing u, and sending u to the second entity; and the first entity computing KA, and the second entity computing KB, thereby reaching a shared key K=KA=KB. The security guarantee of a public key cryptographic algorithm created by the present invention relies on unsolvability of a problem, and has an advantage of free of the quantum computational attack.'
        expect(abstract_patent.abstract.as_text).to eq expect_abstract_text
      end

      it 'patent description' do
        expect_descr_fragment = 'Computer program code for carrying out operations for aspects of the present inventive subject matter may be written in any combination of one or more programming languages, including an object oriented programming language such as Java, Smalltalk, C++ or the like and conventional procedural programming languages, such as the “C” programming language or similar programming languages.'
        expect(patent_2.description.as_doc).to include(expect_descr_fragment)
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

      it 'patent cpc classifications' do
        expect(patent_1.cpc_classifications.size).to eq 2
      end

      it 'patent ipc classifications' do
        expect(patent_1.ipc_classifications.size).to eq 2
      end

      it 'patent drawings' do
        expect(patent_2.drawings.size).to eq 10
      end

      context 'having national classifications' do
        let(:patent_3) do
          @patents.detect do |patent|
            patent.publication_reference['document-id']['doc-number'] == '09537663'
          end
        end

        it { expect(patent_3.national_classifications.size).to eq 5 }
      end
    end

    context 'claim' do
      subject do
        patent_2.claims.first
      end

      it { expect(subject.claim_id).to eq 'CLM-00001' }

      it '#as_doc' do
        expect(subject.as_doc).to eq '<claim id="CLM-00001" num="00001"><claim-text>1. A method for data transmission, the method comprising: <claim-text>determining, by a master network device, to transmit data from the master network device to a plurality of client network devices;</claim-text><claim-text>generating, by the master network device, a data frame including a payload, the payload including a first plurality of symbols arranged in a pattern that is known to the plurality of client network devices; and</claim-text><claim-text>allocating, by the master network device, at least one symbol of the first plurality of symbols to each of the plurality of client network devices, wherein at least a first symbol of the first plurality of symbols is allocated only to a first client network device of the plurality of client network devices.</claim-text></claim-text></claim>'
      end
    end

    context 'inventor' do
      it '#last_name' do
        expect(patent_2.inventors.map(&:last_name)).to match_array(["Afkhami", "Katar", "Rouhana"])
      end
    end

    context 'citation' do
      it 'doc-number' do
        expect(patent_1.citations.first.document_id.fetch('doc-number')).to eq '8607306'
      end

      it 'national_classification' do
        expect(patent_1.citations.first.classification_national.country).to eq 'US'
      end
    end

    context 'classifications' do
      let(:patent_3) do
        @patents.detect do
          |patent| patent.publication_reference['document-id']['doc-number'] == '09537663'
        end
      end

      it 'national' do
        expected_mains = ["380277", "380270", "713168", "455410", "455411"]
        expect(patent_3.national_classifications.map(&:main_classification)).to match_array(expected_mains)
      end

      it 'cpc' do
        expected_cclass = Array.new(2) { '04' }
        expect(patent_1.cpc_classifications.map(&:cclass)).to match_array(expected_cclass)
      end
    end

    context 'drawing' do
      subject do
        patent_2.drawings.first
      end

      it 'drawings' do
        expect(subject.id).to eq 'Fig-EMI-D00000'
      end

      it 'drawing doc' do
        # TODO original doc has no closing tag for img
        original = '<figure id="Fig-EMI-D00000" num="00000"><img id="EMI-D00000" he="171.45mm" wi="267.04mm" file="US09537792-20170103-D00000.TIF" alt="embedded image" img-content="drawing" img-format="tif"></img></figure>'
        expect(subject.as_doc).to eq original
      end
    end
  end
end
