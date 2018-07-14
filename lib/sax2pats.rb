require "sax2pats/version"

module Sax2pats

end

require 'saxerator'
require 'ox'

require 'sax2pats/entity/entity'
require 'sax2pats/entity/citation'
require 'sax2pats/entity/patent'
require 'sax2pats/entity/classification'
require 'sax2pats/entity/inventor'
require 'sax2pats/entity/claim'
require 'sax2pats/entity/drawing'
require 'sax2pats/xml-version/xml_version'
require 'sax2pats/xml-version/xml_version4_5'
require 'sax2pats/split_handler'
require 'sax2pats/handler'
