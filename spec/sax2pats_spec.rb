# frozen_string_literal: true

require 'spec_helper'

shared_examples 'a parsed patent file' do
  it 'has correct number of patents' do
    expect(patents.size).to eq expected_patent_count
  end
end

shared_examples 'a parsed patent grant file' do
  it_behaves_like 'a parsed patent file'

  it 'has correct number of patent claims' do
    expect(patents.map { |pt| pt.claims.size })
      .to match_array(patents.map { |pt| pt.number_of_claims.to_i })
  end
end

shared_examples 'a patent' do
  it 'has xml version' do
    expect(patent.from_version).to eq expected_version
  end

  it 'invention_title' do
    expect(patent.invention_title).to eq expected_invention_title
  end

  it 'publication_reference' do
    ref_hash = patent.publication_reference['document-id']
    ref_hash.each do |k, v|
      expect(v).to eq expected_pub_ref_hash[k]
    end
  end

  it 'patent description' do
    expect(patent.description.as_doc).to include(expected_descr_fragment)
  end

  it 'patent inventors' do
    expect(patent.inventors.size).to eq expected_inventors_size
  end

  it 'patent citations' do
    expect(patent.citations.size).to eq expected_patent_citations_size
  end

  it 'patent claims' do
    expect(patent.claims.size).to eq expected_patent_claims_size
  end

  it 'patent claim refs' do
    expect(patent.claims.map(&:refs)).to match_array(expected_claim_refs_array)
  end

  it 'patent classifications' do
    expect(patent.classifications.size).to eq expected_classifications_size
  end

  it 'patent cpc classifications' do
    expect(patent.cpc_classifications.size).to eq expected_cpc_classifications_size
  end

  it 'patent ipc classifications' do
    expect(patent.ipc_classifications.size).to eq expected_ipc_classifications_size
  end

  it 'patent drawings' do
    expect(patent.drawings.size).to eq expected_patent_drawings_size
  end

  it 'national classifications size' do
    expect(patent.national_classifications.size).to eq expected_national_classifications_size
  end
end

shared_examples 'a patent grant' do
  it_behaves_like 'a patent'

  it 'number_of_claims' do
    expect(patent.number_of_claims.is_a?(Integer)).to be_truthy
    expect(patent.number_of_claims).to eq expected_patent_claims_size
  end
end

shared_examples 'a patent with abstract' do
  it 'patent abstract doc' do
    expect(patent.abstract.as_doc).to eq expected_abstract_doc
  end

  it 'patent abstract text' do
    expect(patent.abstract.as_text).to eq expected_abstract_text
  end
end

shared_examples 'a claim' do
  it { expect(claim.claim_id).to eq expected_claim_id }

  it '#as_doc' do
    expect(claim.as_doc).to eq expected_claim_doc
  end
end

shared_examples 'an inventor' do
  it '#last_name' do
    expect(inventor.last_name).to eq expected_inventor_last_name
  end
end

shared_examples 'an assignee' do
  it '#last_name' do
    expect(assignee.last_name).to eq expected_assignee_last_name
  end

  it '#orgname' do
    expect(assignee.orgname).to eq expected_assignee_orgname
  end
end

shared_examples 'an applicant' do
  it '#last_name' do
    expect(applicant.last_name).to eq expected_applicant_last_name
  end

  it '#orgname' do
    expect(applicant.orgname).to eq expected_applicant_orgname
  end
end

shared_examples 'an examiner' do
  it '#last_name' do
    expect(examiner.last_name).to eq expected_examiner_last_name
  end

  it '#department' do
    expect(examiner.department).to eq expected_examiner_department
  end
end

shared_examples 'a drawing' do
  it 'drawings' do
    expect(drawing.id).to eq expected_drawing_id
  end

  it 'drawing doc' do
    # TODO: original doc has no closing tag for img
    expect(drawing.as_doc).to eq expected_drawing_doc
  end
end

shared_examples 'a citation' do
  it 'doc-number' do
    citation.document_id.each do |k, _v|
      expect(citation.document_id[k]).to eq expected_document_id[k]
    end
  end

  it 'national_classification' do
    expect(citation.classification_national.country).to eq expected_citation_national_class
  end
end

shared_examples 'a national classification' do
  it '#main_classification' do
    expect(national_classification.main_classification).to eq expected_main_class
  end
end

shared_examples 'a cpc classification' do
  it '#cclass' do
    expect(cpc_classification.cclass).to eq expected_cclass
  end

  it '#title' do
    expect(cpc_classification.title['title']).to eq expected_cpc_title
  end

  it '#action_date' do
    expect(cpc_classification.action_date.year).to eq expected_cpc_action_date_year
  end
end

shared_context 'parsed patents' do
  before(:all) do
    @patents = []
    patent_handler = proc { |pt| @patents << pt }
    filename = File.join(File.dirname(__FILE__), @file_name)
    h = Sax2pats::SplitProcessor.new(File.open(filename, 'r'), patent_handler) do |config|
      config.set_cpc_config(@cpc_metadata)
    end
    h.parse_patents
    @patents
  end

  let(:patents) { @patents }

  it_behaves_like 'a parsed patent file'
end

shared_context 'a parsed patent' do
  let(:patent) do
    patents.detect do |pat|
      pat.publication_reference['document-id']['doc-number'] == patent_doc_number
    end
  end
end

RSpec.describe Sax2pats do
  it 'has a version number' do
    expect(Sax2pats::VERSION).not_to be nil
  end

  describe 'Sax parse USPTO Patent Application XML' do
    context 'from version 4.4' do
      before(:all) do 
        @cpc_metadata = {
          include_cpc_metadata: false
        }
        @file_name = 'test_44_applications.xml'
      end

      let(:expected_patent_count) { 2 }

      include_context 'parsed patents'

      describe 'patent' do
        let(:expected_version) { '4.4' }
        let(:expected_descr_fragment) { '' }
        let(:expected_national_classifications_size) { 0 }

        context 'utility patent' do
          let(:expected_invention_title) do
            'ADJUSTABLE CLOSING SYSTEM FOR AN AGRICULTURAL IMPLEMENT'
          end
          let(:expected_pub_ref_hash) do
            {
              'doc-number' => '20200281107',
              'country' => 'US',
              'kind' => 'A1',
              'date' => '20200910'
            }
          end
          let(:expected_abstract_doc) do
            '<abstract id="abstract"><p id="p-0001" num="0000">A row unit of an agricultural implement includes an opening system configured to engage soil to form a furrow, sensors configured to detect a soil tightness, soil conditions, operational conditions, or a combination thereof, and a closing system configured to close the furrow. The closing system includes a first closing disc configured to engage the soil and close the furrow and a second closing disc configured to engage the soil and close the furrow. The row unit also includes a controller configured to receive feedback from the sensors and to control a position, an orientation, or both, of the first closing disc, the second closing disc, or both, in response to feedback from the sensors.</p></abstract>'
          end
          let(:expected_abstract_text) do
            'A row unit of an agricultural implement includes an opening system configured to engage soil to form a furrow, sensors configured to detect a soil tightness, soil conditions, operational conditions, or a combination thereof, and a closing system configured to close the furrow. The closing system includes a first closing disc configured to engage the soil and close the furrow and a second closing disc configured to engage the soil and close the furrow. The row unit also includes a controller configured to receive feedback from the sensors and to control a position, an orientation, or both, of the first closing disc, the second closing disc, or both, in response to feedback from the sensors.'
          end
          let(:expected_claim_refs_array) { 
            [
              [],
              ["CLM-00001"],
              ["CLM-00001"],
              ["CLM-00003"],
              ["CLM-00004"],
              ["CLM-00005"],
              ["CLM-00001"],
              ["CLM-00001"],
              ["CLM-00001"],
              [],
              ["CLM-00010"],
              ["CLM-00011"],
              ["CLM-00010"],
              ["CLM-00010"],
              ["CLM-00014"],
              [],
              ["CLM-00016"],
              ["CLM-00016"],
              ["CLM-00016"],
              ["CLM-00016"]
            ] 
          }
          let(:expected_inventors_size) { 1 }
          let(:expected_patent_citations_size) { 0 }
          let(:expected_patent_claims_size) { 20 }
          let(:expected_classifications_size) { 12 }
          let(:expected_cpc_classifications_size) { 6 }
          let(:expected_ipc_classifications_size) { 6 }
          let(:expected_national_classifications_size) { 0 }
          let(:expected_patent_drawings_size) { 8 }

          let(:patent_doc_number) { '20200281107' }

          include_context 'a parsed patent'
          it_behaves_like 'a patent'
          it_behaves_like 'a patent with abstract'

          context 'applicant' do
            let(:applicant) { patent.applicants.first }
            let(:expected_applicant_last_name) { nil }
            let(:expected_applicant_orgname) { 'CNH Industrial America LLC' }

            it_behaves_like 'an applicant'
          end

          # context 'assignee' do
          #   let(:assignee) { patent.assignees.first }
          #   let(:expected_assignee_last_name) { nil }
          #   let(:expected_assignee_orgname) { 'SangStat Medical Corporation' }

          #   it_behaves_like 'an assignee'
          # end
        end
      end
    end
  end

  describe 'SAX parse USPTO Patent Grant XML' do
    context 'from version 4.1' do
      before(:all) do 
        @cpc_metadata = {
          include_cpc_metadata: false
        }
        @file_name = 'test_41.xml'
      end

      let(:expected_patent_count) { 96 }

      include_context 'parsed patents'
      include_context 'a parsed patent grant file'

      describe 'patent' do
        let(:expected_version) { '4.1' }
        let(:expected_descr_fragment) { '' }
        let(:expected_national_classifications_size) { 0 }

        context 'utility patent' do
          let(:expected_invention_title) do
            'Cytomodulating peptide for inhibiting lymphocyte activity'
          end
          let(:expected_pub_ref_hash) do
            {
              'doc-number' => '06982246',
              'country' => 'US',
              'kind' => 'B1',
              'date' => '20060103'
            }
          end
          let(:expected_abstract_doc) do
            '<abstract id="abstract"><p id="p-0001" num="0000">Novel oligopeptides comprising a sequence associated with HLA-B α<sub>1 </sub>domain, but comprising a tyrosine-tyrosine-tryptophan triad are provided for use in inhibiting cytotoxic activity of CTLs and natural killer cells. By combining the subject compositions with mixtures of cells comprising the cytotoxic cells and cells which would otherwise activate the cytotoxic cells, lysis of the target cells can be substantially inhibited. the oligopeptides may be joined to a wide variety of other groups or compounds for varying the activity of the subject compositions. The subject compositions may be administered by any convenient means to a host to inhibit CTL and NK attack on tissue, particularly involved with xenogeneic or allogeneic transplants.</p></abstract>'
          end
          let(:expected_abstract_text) do
            'Novel oligopeptides comprising a sequence associated with HLA-B α1 domain, but comprising a tyrosine-tyrosine-tryptophan triad are provided for use in inhibiting cytotoxic activity of CTLs and natural killer cells. By combining the subject compositions with mixtures of cells comprising the cytotoxic cells and cells which would otherwise activate the cytotoxic cells, lysis of the target cells can be substantially inhibited. the oligopeptides may be joined to a wide variety of other groups or compounds for varying the activity of the subject compositions. The subject compositions may be administered by any convenient means to a host to inhibit CTL and NK attack on tissue, particularly involved with xenogeneic or allogeneic transplants.'
          end
          let(:expected_claim_refs_array) { [[], ['CLM-00001'], ['CLM-00002'], ['CLM-00001'], ['CLM-00001'], ['CLM-00001']] }
          let(:expected_inventors_size) { 1 }
          let(:expected_patent_citations_size) { 15 }
          let(:expected_patent_claims_size) { 6 }
          let(:expected_classifications_size) { 12 }
          let(:expected_cpc_classifications_size) { 0 }
          let(:expected_ipc_classifications_size) { 5 }
          let(:expected_national_classifications_size) { 7 }
          # This patent has "sequences" instead of drawings
          let(:expected_patent_drawings_size) { 0 }

          let(:patent_doc_number) { '06982246' }

          include_context 'a parsed patent'
          it_behaves_like 'a patent grant'
          it_behaves_like 'a patent with abstract'

          context 'applicant' do
            let(:applicant) { patent.applicants.first }
            let(:expected_applicant_last_name) { 'Buelow' }
            let(:expected_applicant_orgname) { nil }

            it_behaves_like 'an applicant'
          end

          context 'assignee' do
            let(:assignee) { patent.assignees.first }
            let(:expected_assignee_last_name) { nil }
            let(:expected_assignee_orgname) { 'SangStat Medical Corporation' }

            it_behaves_like 'an assignee'
          end
        end
      end
    end

    context 'from version 4.5' do
      before(:all) do 
        @cpc_metadata = {
          include_cpc_metadata: false
        }
        @file_name = 'test_45.xml'
      end

      let(:expected_patent_count) { 130 }

      include_context 'parsed patents'
      include_context 'a parsed patent grant file'

      describe 'patent' do
        let(:expected_version) { '4.5' }
        let(:expected_descr_fragment) { '' }
        let(:expected_national_classifications_size) { 0 }

        context 'patent 1' do
          let(:expected_invention_title) { 'Authenticating a user device to access services based on a device ID' }
          let(:expected_pub_ref_hash) do
            {
              'doc-number' => '09537659',
              'country' => 'US',
              'kind' => 'B2',
              'date' => '20170103'
            }
          end
          let(:expected_abstract_doc) do
            '<abstract id="abstract"><p id="p-0001" num="0000">A first device may receive a first session token from a second device; determine that the first session token is expired or invalid; provide a security input to the second device to cause the second device to generate a first hash value of the security input using a key corresponding to a key identifier (ID); receive the key ID and the first hash value from the second device; generate a second hash value using the key corresponding to the key ID; determine that the first hash value matches the second hash value; and establish a session with the second device based on determining that the first hash value matches the second hash value.</p></abstract>'
          end
          let(:expected_abstract_text) do
            'A first device may receive a first session token from a second device; determine that the first session token is expired or invalid; provide a security input to the second device to cause the second device to generate a first hash value of the security input using a key corresponding to a key identifier (ID); receive the key ID and the first hash value from the second device; generate a second hash value using the key corresponding to the key ID; determine that the first hash value matches the second hash value; and establish a session with the second device based on determining that the first hash value matches the second hash value.'
          end
          let(:expected_claim_refs_array) { [[], ['CLM-00001'], ['CLM-00001'], ['CLM-00001'], ['CLM-00001'], ['CLM-00001'], ['CLM-00001'], ['CLM-00001'], [], ['CLM-00009'], ['CLM-00009'], ['CLM-00009'], ['CLM-00009'], ['CLM-00009'], ['CLM-00009'], [], ['CLM-00016'], ['CLM-00016'], ['CLM-00016'], ['CLM-00016']] }
          let(:expected_inventors_size) { 1 }
          let(:expected_patent_citations_size) { 6 }
          let(:expected_patent_claims_size) { 20 }
          let(:expected_classifications_size) { 4 }
          let(:expected_cpc_classifications_size) { 2 }
          let(:expected_ipc_classifications_size) { 2 }
          let(:expected_patent_drawings_size) { 9 }

          let(:patent_doc_number) { '09537659' }
          
          include_context 'a parsed patent'
          it_behaves_like 'a patent grant'
          it_behaves_like 'a patent with abstract'

          context 'citation' do
            let(:citation) do
              patent.citations.first
            end
            let(:expected_document_id) do
              {
                'doc-number' => '8607306',
                'country' => 'US',
                'kind' => 'B1',
                'name' => 'Bridge',
                'date' => '20131200'
              }
            end
            let(:expected_citation_national_class) { 'US' }
    
            it_behaves_like 'a citation'
          end
        end

        context 'patent 2' do
          let(:expected_descr_fragment) do
            'Computer program code for carrying out operations for aspects of the present inventive subject matter may be written in any combination of one or more programming languages, including an object oriented programming language such as Java, Smalltalk, C++ or the like and conventional procedural programming languages, such as the “C” programming language or similar programming languages.'
          end
          let(:expected_abstract_doc) do
            '<abstract id="abstract"><p id="p-0001" num="0000">A master network device determines to transmit data from the master network device to a plurality of client network devices of a network. In one example, the master network device can generate a data frame including a payload with a plurality of symbols. The payload may include at least one symbol allocated for each of the client network devices. The plurality of symbols may be arranged in a predefined pattern in the payload. In another example, the master network device may generate a data frame including a payload with one or more symbols. Each symbol may include a plurality of frequency carriers, and may include at least one frequency carrier allocated for each of the client network devices. The plurality of frequency carriers can be allotted to the client network devices according to a partitioning pattern. The master network device then transmits the data frame to the client network devices.</p></abstract>'
          end
          let(:expected_abstract_text) do
            'A master network device determines to transmit data from the master network device to a plurality of client network devices of a network. In one example, the master network device can generate a data frame including a payload with a plurality of symbols. The payload may include at least one symbol allocated for each of the client network devices. The plurality of symbols may be arranged in a predefined pattern in the payload. In another example, the master network device may generate a data frame including a payload with one or more symbols. Each symbol may include a plurality of frequency carriers, and may include at least one frequency carrier allocated for each of the client network devices. The plurality of frequency carriers can be allotted to the client network devices according to a partitioning pattern. The master network device then transmits the data frame to the client network devices.'
          end
          let(:expected_invention_title) { 'Channel loading for one-to-many communications in a network' }
          let(:expected_patent_drawings_size) { 10 }
          let(:expected_inventors_size) { 3 }
          let(:expected_pub_ref_hash) do
            {
              'doc-number' => '09537792',
              'country' => 'US',
              'kind' => 'B2',
              'date' => '20170103'
            }
          end
          let(:expected_patent_citations_size) { 15 }
          let(:expected_patent_claims_size) { 21 }
          let(:expected_claim_refs_array) do
            [
              [],
              ['CLM-00001'],
              ['CLM-00002'],
              ['CLM-00001'],
              ['CLM-00004'],
              ['CLM-00001'],
              ['CLM-00006'],
              ['CLM-00001'],
              ['CLM-00001'],
              ['CLM-00001'],
              ['CLM-00001'],
              [],
              ['CLM-00012'],
              ['CLM-00012'],
              ['CLM-00014'],
              ['CLM-00012'],
              ['CLM-00012'],
              ['CLM-00012'],
              [],
              ['CLM-00019'],
              ['CLM-00019']
            ]
          end
          let(:expected_classifications_size) { 11 }
          let(:expected_cpc_classifications_size) { 7 }
          let(:expected_ipc_classifications_size) { 4 }

          let(:patent_doc_number) { '09537792' }
          
          include_context 'a parsed patent'
          it_behaves_like 'a patent grant'
          it_behaves_like 'a patent with abstract'

          context 'applicant' do
            let(:applicant) { patent.applicants.first }
            let(:expected_applicant_last_name) { nil }
            let(:expected_applicant_orgname) { 'QUALCOMM Incorporated' }

            it_behaves_like 'an applicant'
          end

          context 'assignee' do
            let(:assignee) { patent.assignees.first }
            let(:expected_assignee_last_name) { nil }
            let(:expected_assignee_orgname) { 'QUALCOMM Incorporated' }

            it_behaves_like 'an assignee'
          end

          context 'drawing' do
            let(:drawing) { patent.drawings.first }
            let(:expected_drawing_id) { 'Fig-EMI-D00000' }
            let(:expected_drawing_doc) do
              '<figure id="Fig-EMI-D00000" num="00000"><img id="EMI-D00000" he="171.45mm" wi="267.04mm" file="US09537792-20170103-D00000.TIF" alt="embedded image" img-content="drawing" img-format="tif"></img></figure>'
            end
    
            it_behaves_like 'a drawing'
          end

          context 'inventor' do
            let(:inventor) { patent.inventors.first }
            let(:expected_inventor_last_name) { 'Rouhana' }
    
            it_behaves_like 'an inventor'
          end

          context 'claim' do
            let(:claim) { patent.claims.first }
            let(:expected_claim_id) { 'CLM-00001' }
            let(:expected_claim_doc) do
              '<claim id="CLM-00001" num="00001"><claim-text>1. A method for data transmission, the method comprising: <claim-text>determining, by a master network device, to transmit data from the master network device to a plurality of client network devices;</claim-text><claim-text>generating, by the master network device, a data frame including a payload, the payload including a first plurality of symbols arranged in a pattern that is known to the plurality of client network devices; and</claim-text><claim-text>allocating, by the master network device, at least one symbol of the first plurality of symbols to each of the plurality of client network devices, wherein at least a first symbol of the first plurality of symbols is allocated only to a first client network device of the plurality of client network devices.</claim-text></claim-text></claim>'
            end
    
            it_behaves_like 'a claim'
          end
        end

        context 'patent 3' do
          let(:expected_invention_title) { 'Manipulation and restoration of authentication challenge parameters in network authentication procedures' }
          let(:expected_inventors_size) { 3 }
          let(:expected_abstract_doc) do
            '<abstract id="abstract"><p id="p-0001" num="0000">A challenge manipulation and restoration capability is provided for use during network authentication. A mobile device (MD) and a subscriber server (SS) each have provisioned therein a binding key (B-KEY) that is associated with a subscriber identity of a network authentication module (NAM) of the MD. The SS obtains an authentication vector (AV) in response to a request from a Radio Access Network (RAN) when the MD attempts to attach to the RAN. The AV includes an original authentication challenge parameter (ACP). The SS encrypts the original ACP based on its B-KEY, and updates the AV by replacing the original ACP with the encrypted ACP. The MD receives the encrypted ACP, and decrypts the encrypted ACP based on its B-KEY to recover the original ACP. The MD provides the original ACP to the NAM for use in computing an authentication response for validation by the RAN.</p></abstract>'
          end
          let(:expected_abstract_text) do
            'A challenge manipulation and restoration capability is provided for use during network authentication. A mobile device (MD) and a subscriber server (SS) each have provisioned therein a binding key (B-KEY) that is associated with a subscriber identity of a network authentication module (NAM) of the MD. The SS obtains an authentication vector (AV) in response to a request from a Radio Access Network (RAN) when the MD attempts to attach to the RAN. The AV includes an original authentication challenge parameter (ACP). The SS encrypts the original ACP based on its B-KEY, and updates the AV by replacing the original ACP with the encrypted ACP. The MD receives the encrypted ACP, and decrypts the encrypted ACP based on its B-KEY to recover the original ACP. The MD provides the original ACP to the NAM for use in computing an authentication response for validation by the RAN.'
          end
          let(:expected_pub_ref_hash) do
            {
              'doc-number' => '09537663',
              'country' => 'US',
              'kind' => 'B2',
              'date' => '20170103'
            }
          end
          let(:expected_claim_refs_array) do
            [[], [], ['CLM-00001'], ['CLM-00001'], ['CLM-00001'], ['CLM-00001'], ['CLM-00001'], ['CLM-00001']]
          end
          let(:expected_national_classifications_size) { 5 }
          let(:expected_patent_claims_size) { 8 }
          let(:expected_patent_drawings_size) { 5 }
          let(:expected_classifications_size) { 11 }
          let(:expected_cpc_classifications_size) { 3 }
          let(:expected_ipc_classifications_size) { 3 }
          let(:expected_patent_citations_size) { 64 }

          let(:patent_doc_number) { '09537663' }
          
          include_context 'a parsed patent'
          it_behaves_like 'a patent grant'
          it_behaves_like 'a patent with abstract'

          context 'National_classification' do
            let(:national_classification) do
              patent.national_classifications.first
            end
            let(:expected_main_class) { '380277' }
  
            it_behaves_like 'a national classification'
          end
        end

        context 'patent 4' do 
          include_context 'a parsed patent'
          let(:patent_doc_number) { '09537660' }

          let(:assignee) { patent.assignees.first }
          let(:expected_assignee_last_name) { 'Wang' }
          let(:expected_assignee_orgname) { nil }

          it_behaves_like 'an assignee'
        end
      end
    end

    context 'with loading cpc metadata' do
      let(:expected_patent_count) { 130 }

      before(:all) do 
        @cpc_metadata = {
          include_cpc_metadata: true,
          redis_client: Redis.new,
          data_path: ['spec', 'classification_data']
        }
        @file_name = 'test_45.xml'
      end

      include_context 'parsed patents'
      include_context 'a parsed patent grant file'
      
      let(:patent_doc_number) { '09537659' }
          
      include_context 'a parsed patent'

      context 'primary examiner' do
        let(:examiner) { patent.examiners.first }
        let(:expected_examiner_last_name) { 'Najjar' }
        let(:expected_examiner_department) { '2492' }

        it_behaves_like 'an examiner'
      end

      context 'citation' do
        let(:citation) do
          patent.citations.first
        end
        let(:expected_document_id) do
          {
            'doc-number' => '8607306',
            'country' => 'US',
            'kind' => 'B1',
            'name' => 'Bridge',
            'date' => '20131200'
          }
        end
        let(:expected_citation_national_class) { 'US' }

        it_behaves_like 'a citation'
      end

      context 'classifications' do
        context 'CPC Classification' do
          let(:cpc_classification) { patent.cpc_classifications.first }
          let(:expected_cclass) { '04' }
          let(:expected_cpc_title) { 
            {
              "title-part" => { 
                "CPC-specific-text" => { "text"=>"using cryptographic hash functions" } 
              },
              "date-revised" => "2013-01-01"
            } 
          }
          let(:expected_cpc_action_date_year) { 2017 }

          it_behaves_like 'a cpc classification'
        end
      end
    end
  end
end
