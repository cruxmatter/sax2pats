# frozen_string_literal: true

require 'spec_helper'

describe 'XmlVersion' do
  describe 'XmlVersion4_4' do
    let(:test_file) { 'test_44.xml' }
    subject { Sax2pats::XMLVersion4_4.new }

    describe '#find_all_attribute_paths' do
      it 'collects all nested paths' do
        version_mapper_attr = {
          "addressbook" => ["addressbook", "orgname"],
          "orgname" => "orgname"
        }
        expected_array = [["addressbook", "orgname"], ["orgname"]]
        expect(Sax2pats::XMLVersion4_4.find_all_attribute_paths(version_mapper_attr)).to match_array(expected_array)
      end
    end
  end

  describe 'XmlVersion4_5' do
    let(:test_file) { 'test_45.xml' }
    subject { Sax2pats::XMLVersion4_5.new }

    it 'loads version_mapper' do
      expected_keys = [
        'applicant',
        'assignee',
        'claim',
        'cpc_classification',
        'drawing',
        'examiner',
        'inventor',
        'ipc_classification',
        'national_classification',
        'patent', 
        'xml',
        'other_citation',
        'patent_citation',
        'patent_grant'
      ]
      expect(subject.version_mapper.keys).to match_array(expected_keys)
      expect(subject.version_mapper.fetch('patent_grant').fetch('inventors')).to eq [
        'us-bibliographic-data-grant',
        'us-parties',
        'inventors',
        'inventor'
      ]
    end

    it '#patent_tag' do
      expect(subject.patent_tag(:grant)).to eq 'us-patent-grant'
      expect(subject.patent_tag(:application)).to eq 'us-patent-application'
    end

    context 'having a patent grant data hash' do
      before do
        @patents = []
        full_path = File.join(File.dirname(__FILE__), test_file)
        parser = Saxerator.parser(File.open(full_path, 'r')) do |sax_config|
          sax_config.adapter = :ox
          sax_config.put_attributes_in_hash!
        end
        @patent_grant_hash = parser.for_tag(subject.patent_tag(:grant)).first
      end

      it '#get_entity_data' do
        expected_pub_ref = {
          'document-id' =>
          { 'country' => 'US',
            'doc-number' => '09537659',
            'kind' => 'B2',
            'date' => '20170103'
          }
        }
        subject.transform_attribute_data('patent_grant', 'publication_reference', @patent_grant_hash).each do |k,v|
          expect(v).to eq expected_pub_ref[k]
        end
      end

      it '#transform_attribute_data' do
        expected_pub_ref = {
          'document-id' =>
          { 'country' => 'US',
            'doc-number' => '09537659',
            'kind' => 'B2',
            'date' => '20170103'
          }
        }
        subject.transform_attribute_data('patent_grant', 'publication_reference', @patent_grant_hash).each do |k,v|
          expect(v).to eq expected_pub_ref[k]
        end
      end
    end
  end
end
