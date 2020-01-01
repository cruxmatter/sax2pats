class CPCMetadata
  def initialize
    @metadata = {}
  end

  VERSION_FILE_MAPPER = {
    '201908' => 'cpc_201908.yml.gz'
  }

  def version(version)
    @metadata[version] ||= load(version)
    @metadata[version] || {}
  end

  def title(version_date, symbol)
    version(version_date).dig(symbol, 'title')
  end

  private

  def load(version)
    root = File.expand_path ''

    return unless VERSION_FILE_MAPPER.key?(version)

    Zlib::GzipReader.open(
      File.join(
        root,
        'lib',
        'sax2pats',
        'classifications',
        'data',
        VERSION_FILE_MAPPER[version]
      )
    ) { |f| YAML.safe_load(f) }
  end
end