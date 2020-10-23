require 'bundler/setup'
require 'benchmark'
require 'sax2pats'

Benchmark.bm do |x|
  x.report do
    @patents = []
    patent_handler = Proc.new{|pt| @patents << pt  }
    filename = File.join(
      File.absolute_path(__FILE__).split(File::SEPARATOR)[0...-2],
      'spec',
      'test_45.xml'
    )
    h = Sax2pats::SplitProcessor.new(File.open(filename), patent_handler)
    h.parse_patents
  end
end
