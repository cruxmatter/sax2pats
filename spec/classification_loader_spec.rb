# frozen_string_literal: true

require 'spec_helper'

describe 'CPC::Loader' do
  let(:spec_data_path) { ['spec', 'classification_data'] }
  let(:redis_host) { nil }
  let(:redis_port) { nil }
  let(:redis_password) { nil }
  let(:loader) do
    Sax2pats::CPC::Loader.new(
      redis_host: redis_host,
      redis_port: redis_port,
      redis_password: redis_password,
      data_path: spec_data_path
    ) 
  end

  it 'initializes' do
    expect(loader).to be
  end

  context 'versions processed' do
    
    before do
      loader.process_all_versions!
    end

    after do 
      loader.clear_data!
    end

    it { expect(loader.loaded?).to eq true }

    it 'keys exist and are accessible' do
      expect(loader.title('A01B63/22', cpc_release_date: '201309').fetch('parent'))
        .to eq 'A01B63/16'
    end

    it { expect { loader.clear_data! }.to change { loader.key_size }.to(0) }

    it 'invalid version date raises error' do
      expect { loader.title('A01B63/22', cpc_release_date: '190001') }.to raise_error(Sax2pats::CPC::LoadingError)
    end
  end
end