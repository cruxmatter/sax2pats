
class Configuration
  attr_accessor :included_patent_types,
                :included_patent_states,
                :include_cpc_metadata,
                :cpc_client_config,
                :cpc_metadata # TODO: rename to client and move

  def initialize(
    included_patent_types: %i[utility design plant],
    included_patent_states: ['us-patent-grant'],
    cpc_metadata_config: {}
  )
    @included_patent_types = included_patent_types
    @included_patent_states = included_patent_states

    set_cpc_config(cpc_metadata_config)
    
    @loaded_xml_version_adaptors = {}
  end

  def set_cpc_config(cpc_metadata_config)
    @include_cpc_metadata = cpc_metadata_config.dig(
      :include_cpc_metadata
    )

    return unless include_cpc_metadata?

    @cpc_client_config = cpc_metadata_config.slice(
      :redis_host,
      :redis_port,
      :redis_password
    )
  end

  def include_cpc_metadata?
    include_cpc_metadata
  end

  def load_cpc_metadata
    return unless include_cpc_metadata?
    
    cpc_loader = Sax2pats::CPC::Loader.new(
      **cpc_client_config
    )

    unless cpc_loader.loaded?
      cpc_loader.process_all_versions!
    end

    @cpc_metadata = cpc_loader 
  end

  def xml_version_adaptor(version)
    @loaded_xml_version_adaptors[version] ||= version_adaptor_class(version).new
    @loaded_xml_version_adaptors[version]
  end

  private

  def version_adaptor_class(version)
    case version
    when '4.5'
      Sax2pats::XMLVersion4_5
    when '4.1'
      Sax2pats::XMLVersion4_1
    end
  end
end
