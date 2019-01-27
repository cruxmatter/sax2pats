require "bundler/gem_tasks"
require "rspec/core/rake_task"
require 'sax2pats'

RSpec::Core::RakeTask.new(:spec)

task :default => :spec

task :generate_cpc_yaml, [:xml_file, :output_yml] do |t, args|
  parser = Sax2pats::CPCParser.new(args.xml_file, args.output_yml)
  parser.parse
  parser.to_yaml
end
