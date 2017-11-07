require 'bundler/setup'
require 'benchmark'
require 'sax2pats'
require 'pry'

Benchmark.bm do |x|
  x.report do
    @patents = []
    patent_handler = Proc.new{|pt| @patents << pt  }
    filename = File.join(File.absolute_path(__FILE__).split(File::SEPARATOR)[0...-2], 'spec', 'test.xml')
    f = File.new(filename)
    h = Sax2pats::Handler.new(f, patent_handler)
    h.parse_patents
  end
end
