require "sax2pats/version"

module Sax2pats

end

require 'saxerator'
require 'ox'
require 'pry'

require 'sax2pats/entity/factory/entity_factory'
require 'sax2pats/entity/factory/patent_factory'
require 'sax2pats/entity/factory/inventor_factory'
require 'sax2pats/entity/factory/claim_factory'
require 'sax2pats/entity/factory/drawing_factory'
require 'sax2pats/entity/factory/citation_factory'
require 'sax2pats/entity/factory/cpc_classification_factory'
require 'sax2pats/entity/factory/ipc_classification_factory'
require 'sax2pats/entity/factory/national_classification_factory'
require 'sax2pats/entity/entity'
require 'sax2pats/entity/doc_entity'
require 'sax2pats/entity/citation'
require 'sax2pats/entity/patent'
require 'sax2pats/entity/classification'
require 'sax2pats/entity/inventor'
require 'sax2pats/entity/claim'
require 'sax2pats/entity/drawing'
require 'sax2pats/xml_version_adaptors/xml_version'
require 'sax2pats/xml_version_adaptors/xml_version4_1'
require 'sax2pats/xml_version_adaptors/xml_version4_5'
require 'sax2pats/configuration'
require 'sax2pats/processor'
require 'sax2pats/split_processor'
require 'sax2pats/single_processor'
require 'sax2pats/classifications/cpc_metadata'
require 'sax2pats/classifications/transformer'
