# frozen_string_literal: true

require 'spec_helper'

describe 'CPC::Loader' do
  let(:redis_host) { nil }
  let(:redis_port) { nil }
  let(:redis_password) { nil }
  let(:loader) do
    Sax2pats::CPC::Loader.new(
      redis_host: redis_host,
      redis_port: redis_port,
      redis_password: redis_password
    ) 
  end

  it 'initializes' do
    expect(loader).to be
  end

  context 'versions processed' do
    before(:all) do
      @loader = Sax2pats::CPC::Loader.new
      @loader.clear_data!
      @loader.process_all_versions!
    end

    it { expect(@loader.loaded?).to eq true }

    it 'keys exist and are accessible' do 
      expect(@loader.title('C12Y603/02024', cpc_release_date: '201309').parent)
        .to eq 'C12Y603/02'
    end

    it { expect { @loader.clear_data! }.to change { @loader.key_size }.to(0) }
  end
end