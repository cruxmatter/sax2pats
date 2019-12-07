require "bundler/gem_tasks"
require "rspec/core/rake_task"
require 'sax2pats'

RSpec::Core::RakeTask.new(:spec)

task :default => :spec

task :generate_cpc_yaml, [:xml_directory, :titles_directory, :output_yml] do |_t, args|
  transformer = Sax2pats::CPC::Transformer.new(
    args.xml_directory,
    args.titles_directory,
    args.output_yml
  )
  transformer.process
  transformer.to_yaml
end
