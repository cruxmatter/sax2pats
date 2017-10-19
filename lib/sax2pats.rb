require "sax2pats/version"

module Sax2pats

end

require 'saxerator'
require 'ox'

# monkey patch for uspto patent xml
Saxerator::Adapters::Ox.class_eval do
  def error(message, _, _)
    # ignore error messages because DOCTYPE
    # is repeated after entities
  end
end

require 'sax2pats/entity'
require 'sax2pats/citation'
require 'sax2pats/patent'
require 'sax2pats/classification'
require 'sax2pats/inventor'
require 'sax2pats/claim'
require 'sax2pats/drawing'
require 'sax2pats/xml_version'
require 'sax2pats/handler'
