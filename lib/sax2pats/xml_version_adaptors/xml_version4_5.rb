module Sax2pats
  class XMLVersion4_5
    VERSION = '4.5'.freeze
    DATA_MAPPER_FILE = '4_5.yml'.freeze

    include Sax2pats::XMLVersion

    # class PatentGrantVersion
    #   ENTITY_VERSION_KEY = 'patent'.freeze
    #
    #   include Sax2pats::XMLVersion::EntityVersion
    # end
    #
    # class InventorVersion
    #   ENTITY_VERSION_KEY = 'inventor'.freeze
    #
    #   include Sax2pats::XMLVersion::EntityVersion
    # end

    # class PatentGrantVersion
    #
    #   include Sax2pats::EntityVersion
    #
    #   # def assign(patent_hash)
    #   #   biblio = patent_hash['us-bibliographic-data-grant']
    #   #   # @entity.publication_reference = biblio['publication-reference']
    #   #   # @entity.application_reference = biblio['application-reference']
    #   #   # @entity.invention_title = biblio.fetch('invention-title').to_s
    #   #   # @entity.number_of_claims = biblio['number-of-claims']
    #   #   @entity.abstract = Sax2pats::PatentAbstract.new(
    #   #     element: patent_hash.fetch('abstract')
    #   #   )
    #   #   @entity.description = Sax2pats::PatentDescription.new(
    #   #     element: patent_hash.fetch('description')
    #   #   )
    #   #   unless biblio.dig('us-field-of-classification-search', 'classification-national').nil?
    #   #     national = NationalClassificationVersion.new
    #   #     national.read_hash(biblio.dig('us-field-of-classification-search', 'classification-national'))
    #   #     @entity.classification_national = national.entity
    #   #   end
    #   # end
    #
    #   def read_and_assign_entity(entity_hash, entity_version_class, entity_list)
    #     entity_version = entity_version_class.new
    #     entity_version.read_hash(entity_hash)
    #     @entity.send("#{entity_list}").send("<<", entity_version.entity)
    #   end
    #
    #   def inventors(patent_hash)
    #     inventors_parent = patent_hash.dig('us-bibliographic-data-grant', 'us-parties', 'inventors', 'inventor')
    #     unless inventors_parent.nil?
    #       find_entities(inventors_parent, basic_handler(InventorVersion, :inventors))
    #     end
    #   end
    #
    #   def citations(patent_hash)
    #     citations_parent = patent_hash.dig('us-bibliographic-data-grant', 'us-references-cited', 'us-citation')
    #     unless citations_parent.nil?
    #       citation_handler = Proc.new do |citation_hash|
    #         if citation_hash.has_key?('patcit')
    #           read_and_assign_entity(citation_hash, PatentCitationVersion, :citations)
    #         elsif citation_hash.has_key?('nplcit')
    #           read_and_assign_entity(citation_hash, OtherCitationVersion, :citations)
    #         end
    #       end
    #       find_entities(citations_parent, citation_handler)
    #     end
    #   end
    #
    #   def claims(patent_hash)
    #     claims_parent = patent_hash.dig('claims', 'claim')
    #     unless claims_parent.nil?
    #       find_entities(claims_parent, basic_handler(ClaimVersion, :claims))
    #     end
    #   end
    #
    #   def classifications(patent_hash)
    #     ipcr_parent = patent_hash.dig('us-bibliographic-data-grant', 'classifications-ipcr', 'classification-ipcr')
    #     unless ipcr_parent.nil?
    #       find_entities(ipcr_parent, basic_handler(IPCClassificationVersion, :classifications))
    #     end
    #
    #     cpc_parent = patent_hash.dig('us-bibliographic-data-grant', 'classifications-cpc')
    #     unless cpc_parent.nil?
    #       unless cpc_parent.dig('main-cpc', 'classification-cpc').nil?
    #         find_entities(cpc_parent.dig('main-cpc', 'classification-cpc'), basic_handler(CPCClassificationVersion, :classifications))
    #       end
    #       unless cpc_parent.dig('further-cpc', 'classification-cpc').nil?
    #         find_entities(cpc_parent.dig('further-cpc', 'classification-cpc'), basic_handler(CPCClassificationVersion, :classifications))
    #       end
    #     end
    #   end
    #
    #   def drawings(patent_hash)
    #     drawing_parent = patent_hash.dig('drawings', 'figure')
    #     unless drawing_parent.nil?
    #       find_entities(drawing_parent, basic_handler(DrawingVersion, :drawings))
    #     end
    #   end
    #
    #   def read_hash(patent_hash)
    #     @entity = Sax2pats::Patent.new('4.5')
    #     assign(patent_hash)
    #     citations(patent_hash)
    #     inventors(patent_hash)
    #     claims(patent_hash)
    #     drawings(patent_hash)
    #     classifications(patent_hash)
    #   end
    # end
    #
    # class PatentCitationVersion
    #   include Sax2pats::EntityVersion
    #
    #   def assign(citation_hash)
    #     @entity.category = citation_hash["category"]
    #     @entity.document_id = citation_hash["patcit"]["document-id"]
    #     @entity.classification_cpc_text = citation_hash["classification-cpc-text"]
    #     unless citation_hash["classification-national"].nil?
    #       national = NationalClassificationVersion.new
    #       national.read_hash(citation_hash["classification-national"])
    #       @entity.classification_national = national.entity
    #     end
    #   end
    #
    #   def read_hash(citation)
    #     @entity = Sax2pats::PatentCitation.new('4.5')
    #     assign(citation)
    #   end
    # end
    #
    # class OtherCitationVersion
    #   include Sax2pats::EntityVersion
    #
    #   def assign(citation_hash)
    #     @entity.citation_value = citation_hash.fetch('othercit')
    #   end
    #
    #   def read_hash(citation)
    #     @entity = Sax2pats::OtherCitation.new('4.5')
    #     assign(citation.fetch('nplcit'))
    #   end
    # end
    #
    # # class InventorVersion
    # #   include Sax2pats::EntityVersion
    # #
    # #   def assign(inventor_hash)
    # #     @entity.address = inventor_hash["addressbook"]["address"]
    # #     @entity.first_name = inventor_hash["addressbook"]["first-name"]
    # #     @entity.last_name = inventor_hash["addressbook"]["last-name"]
    # #   end
    # #
    # #   def read_hash(inventor)
    # #     @entity = Sax2pats::Inventor.new('4.5')
    # #     assign(inventor)
    # #   end
    # # end
    #
    # class ClaimVersion
    #   include Sax2pats::EntityVersion
    #
    #   def assign(claim)
    #     @entity.claim_id = claim['id']
    #     @entity.element = claim
    #   end
    #
    #   def read_hash(claim_hash)
    #     @entity = Sax2pats::Claim.new('4.5')
    #     assign(claim_hash)
    #   end
    # end
    #
    # class DrawingVersion
    #   include Sax2pats::EntityVersion
    #
    #   def assign(drawing_element)
    #     @entity.element = drawing_element
    #     @entity.img = drawing_element['img']
    #     @entity.id = drawing_element.attributes['id']
    #   end
    #
    #   def read_hash(drawings)
    #     @entity = Sax2pats::Drawing.new('4.5')
    #     if drawings.kind_of?(Saxerator::Builder::HashElement)
    #       assign(drawings)
    #     elsif drawings.kind_of?(Saxerator::Builder::ArrayElement)
    #       drawings.each do |drawing|
    #         assign(drawing)
    #       end
    #     end
    #   end
    # end
    #
    # class ClassificationVersion
    #   include Sax2pats::EntityVersion
    #
    #   def assign(classification)
    #     @entity.generating_office_country = classification.dig('generating-office', 'country')
    #     @entity.section = classification['section']
    #     @entity.cclass = classification['class']
    #     @entity.subclass = classification['subclass']
    #     @entity.main_group = classification['main-group']
    #     @entity.subgroup = classification['subgroup']
    #     @entity.symbol_position = classification['symbol-position']
    #     @entity.action_date = classification.dig('action-date', 'date')
    #     @entity.classification_status = classification['classification-status']
    #     @entity.classification_data_source = classification['classification-data-source']
    #   end
    # end
    #
    # class IPCClassificationVersion < ClassificationVersion
    #   include Sax2pats::EntityVersion
    #
    #   def assign(ipc)
    #     @entity.version_date = ipc.fetch('ipc-version-indicator', 'date')
    #     @entity.classification_level = ipc['classification-level']
    #     super(ipc)
    #   end
    #
    #   def read_hash(ipc_classifications)
    #     @entity = Sax2pats::IPCClassification.new('4.5')
    #     if ipc_classifications.kind_of?(Saxerator::Builder::HashElement)
    #       assign(ipc_classifications)
    #     elsif ipc_classifications.kind_of?(Saxerator::Builder::ArrayElement)
    #       ipc_classifications.each do |ipc_classification_hash|
    #         assign(ipc_classification_hash)
    #       end
    #     end
    #   end
    # end
    #
    # class CPCClassificationVersion < ClassificationVersion
    #   include Sax2pats::EntityVersion
    #
    #   def assign(cpc)
    #     @entity.version_date = cpc.fetch('cpc-version-indicator', 'date')
    #     @entity.classification_value = cpc['classification-value']
    #     super(cpc)
    #   end
    #
    #   def read_hash(cpc_classifications)
    #     @entity = Sax2pats::CPCClassification.new('4.5')
    #     if cpc_classifications.kind_of?(Saxerator::Builder::HashElement)
    #       assign(cpc_classifications)
    #     elsif cpc_classifications.kind_of?(Saxerator::Builder::ArrayElement)
    #       cpc_classifications.each do |cpc_classification_hash|
    #         assign(cpc_classification_hash)
    #       end
    #     end
    #   end
    # end
    #
    # class LocarnoClassificationVersion
    #   include Sax2pats::EntityVersion
    # end
    #
    # class NationalClassificationVersion
    #   include Sax2pats::EntityVersion
    #
    #   def assign(classification)
    #     @entity.country = classification['country']
    #     @entity.main_classification = classification['main-classification']
    #   end
    #
    #   def read_hash(classification)
    #     @entity = Sax2pats::NationalClassification.new('4.5')
    #     if classification.kind_of?(Saxerator::Builder::HashElement)
    #       assign(classification)
    #     elsif classification.kind_of?(Saxerator::Builder::ArrayElement)
    #       classification.each do |classification_hash|
    #         assign(classification_hash)
    #       end
    #     end
    #   end
    # end
  end
end
