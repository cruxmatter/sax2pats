class Configuration
  attr_accessor :patent_types, :include_cpc_metadata

  def initialize
    @patent_types = []
    @include_cpc_metadata = true
  end

  def include_cpc_metadata?
    !!include_cpc_metadata
  end
end