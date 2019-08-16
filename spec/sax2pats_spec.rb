require "spec_helper"

shared_examples 'a patent' do
  it 'has xml version' do
    expect(patent.from_version).to eq expect_version
  end

  it 'invention_title' do
    expect(patent.invention_title).to eq expect_invention_title
  end

  it 'publication_reference' do
    ref_hash = patent.publication_reference['document-id']
    ref_hash.each do |k,v|
      expect(v).to eq expect_pub_ref_hash[k]
    end
  end

  it 'patent description' do
    expect(patent.description.as_doc).to include(expect_descr_fragment)
  end

  it 'patent inventors' do
    expect(patent.inventors.size).to eq expect_inventors_size
  end

  it 'patent citations' do
    expect(patent.citations.size).to eq expect_patent_citations_size
  end

  it 'patent claims' do
    expect(patent.claims.size).to eq expect_patent_claims_size
  end

  it 'patent claim refs' do
    expect(patent.claims.map(&:refs)).to match_array(expect_claim_refs_array)
  end

  it 'patent classifications' do
    expect(patent.classifications.size).to eq expect_classifications_size
  end

  it 'patent cpc classifications' do
    expect(patent.cpc_classifications.size).to eq expect_cpc_classifications_size
  end

  it 'patent ipc classifications' do
    expect(patent.ipc_classifications.size).to eq expect_ipc_classifications_size
  end

  it 'patent drawings' do
    expect(patent.drawings.size).to eq expect_patent_drawings_size
  end

  it 'national classifications size' do
    expect(patent.national_classifications.size).to eq expect_national_classifications_size
  end
end

shared_examples 'a patent with abstract' do
  it 'patent abstract doc' do
    expect(patent.abstract.as_doc).to eq expect_abstract_doc
  end

  it 'patent abstract text' do
    expect(patent.abstract.as_text).to eq expect_abstract_text
  end
end

RSpec.describe Sax2pats do
  it "has a version number" do
    expect(Sax2pats::VERSION).not_to be nil
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

  let(:patent_3) do
    @patents.detect do |patent|
      patent.publication_reference['document-id']['doc-number'] == '09537663'
    end
  end

  context 'SAX parse USPTO Patent XML' do

    before(:all) do
      @patents = []
      patent_handler = Proc.new{|pt| @patents << pt  }
      filename = File.join(File.dirname(__FILE__), 'test_45.xml')
      h = Sax2pats::SplitHandler.new(filename, patent_handler)
      h.parse_patents
    end

    it 'parsed all patents' do
      expect(@patents.size).to eq 130
    end

    it 'patent claims' do
      expect(@patents.map{|pt| pt.claims.size}).to match_array(@patents.map{|pt| pt.number_of_claims.to_i})
    end

    describe 'patent' do
      let(:expect_version) { '4.5' }
      let(:expect_invention_title) { '' }
      let(:expect_descr_fragment) { '' }
      let(:expect_abstract_doc) { nil }
      let(:expect_abstract_text) { nil }
      let(:expect_patent_citations_size) { 0 }
      let(:expect_patent_claims_size) { 0 }
      let(:expect_claim_refs_array) { [] }
      let(:expect_classifications_size) { 0 }
      let(:expect_cpc_classifications_size) { 0 }
      let(:expect_ipc_classifications_size) { 0 }
      let(:expect_patent_drawings_size) { 0 }
      let(:expect_national_classifications_size) { 0 }
      let(:expect_inventors_size) { 0 }

      let(:expect_pub_ref_hash) { {} }

      context 'patent 1' do
        let(:patent) { patent_1 }
        let(:expect_invention_title) { 'Authenticating a user device to access services based on a device ID' }
        let(:expect_pub_ref_hash) do
          {
            'doc-number' => '09537659',
            'country' => 'US',
            'kind' => 'B2',
            'date' => '20170103'
          }
        end
        let(:expect_abstract_doc) do
          '<abstract id="abstract"><p id="p-0001" num="0000">A first device may receive a first session token from a second device; determine that the first session token is expired or invalid; provide a security input to the second device to cause the second device to generate a first hash value of the security input using a key corresponding to a key identifier (ID); receive the key ID and the first hash value from the second device; generate a second hash value using the key corresponding to the key ID; determine that the first hash value matches the second hash value; and establish a session with the second device based on determining that the first hash value matches the second hash value.</p></abstract>'
        end
        let(:expect_abstract_text) do
          'A first device may receive a first session token from a second device; determine that the first session token is expired or invalid; provide a security input to the second device to cause the second device to generate a first hash value of the security input using a key corresponding to a key identifier (ID); receive the key ID and the first hash value from the second device; generate a second hash value using the key corresponding to the key ID; determine that the first hash value matches the second hash value; and establish a session with the second device based on determining that the first hash value matches the second hash value.'
        end
        let(:expect_claim_refs_array) { [[],["CLM-00001"],["CLM-00001"],["CLM-00001"],["CLM-00001"],["CLM-00001"],["CLM-00001"],["CLM-00001"],[],["CLM-00009"],["CLM-00009"],["CLM-00009"],["CLM-00009"],["CLM-00009"],["CLM-00009"],[],["CLM-00016"],["CLM-00016"],["CLM-00016"],["CLM-00016"]] }
        let(:expect_inventors_size) { 1 }
        let(:expect_patent_citations_size) { 6 }
        let(:expect_patent_claims_size) { 20 }
        let(:expect_classifications_size) { 4 }
        let(:expect_cpc_classifications_size) { 2 }
        let(:expect_ipc_classifications_size) { 2 }
        let(:expect_patent_drawings_size) { 9 }

        it_behaves_like 'a patent'
        it_behaves_like 'a patent with abstract'
      end

      context 'patent 2' do
        let(:patent) { patent_2 }
        let(:expect_descr_fragment) do
          'Computer program code for carrying out operations for aspects of the present inventive subject matter may be written in any combination of one or more programming languages, including an object oriented programming language such as Java, Smalltalk, C++ or the like and conventional procedural programming languages, such as the “C” programming language or similar programming languages.'
        end
        let(:expect_abstract_doc) do
          '<abstract id="abstract"><p id="p-0001" num="0000">A master network device determines to transmit data from the master network device to a plurality of client network devices of a network. In one example, the master network device can generate a data frame including a payload with a plurality of symbols. The payload may include at least one symbol allocated for each of the client network devices. The plurality of symbols may be arranged in a predefined pattern in the payload. In another example, the master network device may generate a data frame including a payload with one or more symbols. Each symbol may include a plurality of frequency carriers, and may include at least one frequency carrier allocated for each of the client network devices. The plurality of frequency carriers can be allotted to the client network devices according to a partitioning pattern. The master network device then transmits the data frame to the client network devices.</p></abstract>'
        end
        let(:expect_abstract_text) do
          'A master network device determines to transmit data from the master network device to a plurality of client network devices of a network. In one example, the master network device can generate a data frame including a payload with a plurality of symbols. The payload may include at least one symbol allocated for each of the client network devices. The plurality of symbols may be arranged in a predefined pattern in the payload. In another example, the master network device may generate a data frame including a payload with one or more symbols. Each symbol may include a plurality of frequency carriers, and may include at least one frequency carrier allocated for each of the client network devices. The plurality of frequency carriers can be allotted to the client network devices according to a partitioning pattern. The master network device then transmits the data frame to the client network devices.'
        end
        let(:expect_invention_title) { 'Channel loading for one-to-many communications in a network' }
        let(:expect_patent_drawings_size) { 10 }
        let(:expect_inventors_size) { 3 }
        let(:expect_pub_ref_hash) do
          {
            'doc-number' => '09537792',
            'country' => 'US',
            'kind' => 'B2',
            'date' => '20170103'
          }
        end
        let(:expect_patent_citations_size) { 15 }
        let(:expect_patent_claims_size) { 21 }
        let(:expect_claim_refs_array) do
          [
            [],
            ["CLM-00001"],
            ["CLM-00002"],
            ["CLM-00001"],
            ["CLM-00004"],
            ["CLM-00001"],
            ["CLM-00006"],
            ["CLM-00001"],
            ["CLM-00001"],
            ["CLM-00001"],
            ["CLM-00001"],
            [],
            ["CLM-00012"],
            ["CLM-00012"],
            ["CLM-00014"],
            ["CLM-00012"],
            ["CLM-00012"],
            ["CLM-00012"],
            [],
            ["CLM-00019"],
            ["CLM-00019"]
          ]
        end
        let(:expect_classifications_size) { 11 }
        let(:expect_cpc_classifications_size) { 7 }
        let(:expect_ipc_classifications_size) { 4 }

        it_behaves_like 'a patent'
        it_behaves_like 'a patent with abstract'
      end

      context 'patent 3' do
        let(:patent) { patent_3 }
        let(:expect_invention_title) { 'Manipulation and restoration of authentication challenge parameters in network authentication procedures' }
        let(:expect_inventors_size) { 3 }
        let(:expect_abstract_doc) do
          '<abstract id="abstract"><p id="p-0001" num="0000">A challenge manipulation and restoration capability is provided for use during network authentication. A mobile device (MD) and a subscriber server (SS) each have provisioned therein a binding key (B-KEY) that is associated with a subscriber identity of a network authentication module (NAM) of the MD. The SS obtains an authentication vector (AV) in response to a request from a Radio Access Network (RAN) when the MD attempts to attach to the RAN. The AV includes an original authentication challenge parameter (ACP). The SS encrypts the original ACP based on its B-KEY, and updates the AV by replacing the original ACP with the encrypted ACP. The MD receives the encrypted ACP, and decrypts the encrypted ACP based on its B-KEY to recover the original ACP. The MD provides the original ACP to the NAM for use in computing an authentication response for validation by the RAN.</p></abstract>'
        end
        let(:expect_abstract_text) do
          'A challenge manipulation and restoration capability is provided for use during network authentication. A mobile device (MD) and a subscriber server (SS) each have provisioned therein a binding key (B-KEY) that is associated with a subscriber identity of a network authentication module (NAM) of the MD. The SS obtains an authentication vector (AV) in response to a request from a Radio Access Network (RAN) when the MD attempts to attach to the RAN. The AV includes an original authentication challenge parameter (ACP). The SS encrypts the original ACP based on its B-KEY, and updates the AV by replacing the original ACP with the encrypted ACP. The MD receives the encrypted ACP, and decrypts the encrypted ACP based on its B-KEY to recover the original ACP. The MD provides the original ACP to the NAM for use in computing an authentication response for validation by the RAN.'
        end
        let(:expect_pub_ref_hash) do
          {
            'doc-number' => '09537663',
            'country' => 'US',
            'kind' => 'B2',
            'date' => '20170103'
          }
        end
        let(:expect_claim_refs_array) do
          [[], [], ["CLM-00001"], ["CLM-00001"], ["CLM-00001"], ["CLM-00001"], ["CLM-00001"], ["CLM-00001"]]
        end
        let(:expect_national_classifications_size) { 5 }
        let(:expect_patent_claims_size) { 8 }
        let(:expect_patent_drawings_size) { 5 }
        let(:expect_classifications_size) { 11 }
        let(:expect_cpc_classifications_size) { 3 }
        let(:expect_ipc_classifications_size) { 3 }
        let(:expect_patent_citations_size) { 64 }

        it_behaves_like 'a patent'
        it_behaves_like 'a patent with abstract'
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
