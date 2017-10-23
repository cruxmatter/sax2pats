module Sax2pats
  module EntityVersion
    attr_reader :entity

    def read_hash(entity_hash)
      raise NotImplementedError
    end
  end

  module XMLVersion
    def patent_tag(mode)
      raise NotImplementedError
    end

    def process_patent_grant(patent_grant_hash)
      raise NotImplementedError
    end
  end

  class XMLVersion4_5
    include XMLVersion

    def patent_tag(type)
      case
      when type == :grant
        :'us-patent-grant'
      else
        :'us-patent-application'
      end
    end

    def process_patent_grant(patent_grant_hash)
      pv = PatentGrantVersion.new
      pv.read_hash(patent_grant_hash)
      pv.entity
    end

    class PatentGrantVersion
      include EntityVersion

      def assign(patent_hash)
        biblio = patent_hash['us-bibliographic-data-grant']
        @entity.publication_reference = biblio['publication-reference']
        @entity.application_reference = biblio['application-reference']
        @entity.invention_title = biblio.fetch('invention-title').detect do |t|
          t.kind_of?(Saxerator::Builder::StringElement)
        end
        @entity.number_of_claims = biblio['number-of-claims']
        @entity.abstract = patent_hash.fetch('abstract').to_s
        @entity.description = patent_hash.fetch('description')
        unless biblio.dig('us-field-of-classification-search', 'classification-national').nil?
          national = NationalClassificationVersion.new
          national.read_hash(biblio.dig('us-field-of-classification-search', 'classification-national'))
          @entity.classification_national = national.entity
        end
      end

      def handle_entities(entities, entity_version_class, entity_list)
        read_and_assign_entity = Proc.new do |e|
          entity_version = entity_version_class.new
          entity_version.read_hash(e)
          @entity.send("#{entity_list}").send("<<", entity_version.entity)
        end

        if entities.kind_of?(Saxerator::Builder::HashElement)
          read_and_assign_entity.call(entities)
        elsif entities.kind_of?(Saxerator::Builder::ArrayElement)
          entities.each do |entities_hash|
            read_and_assign_entity.call(entities_hash)
          end
        end
      end

      def citations(citations)
        citation_version = Proc.new do |tag|
          if tag == 'patcit'
            PatentCitationVersion.new
          elsif tag == 'nplcit'
            OtherCitationVersion.new
          end
        end

        if citations.kind_of?(Saxerator::Builder::HashElement)
          cv = citation_version.call(citations_hash.keys.first)
          cv.read_hash(citations)
          @entity.citations << cv.entity
        elsif citations.kind_of?(Saxerator::Builder::ArrayElement)
          citations.each do |citations_hash|
            cv = citation_version.call(citations_hash.keys.first)
            cv.read_hash(citations_hash)
            @entity.citations << cv.entity
          end
        end
      end

      def read_hash(patent_hash)
        @entity = Sax2pats::Patent.new
        assign(patent_hash)
        biblio = patent_hash['us-bibliographic-data-grant']
        unless biblio.dig('us-references-cited', 'us-citation').nil?
          citations(biblio.dig('us-references-cited', 'us-citation'))
        end
        unless biblio.dig('us-parties', 'inventors', 'inventor').nil?
          handle_entities(biblio.dig('us-parties', 'inventors', 'inventor'), InventorVersion, :inventors)
        end
        unless patent_hash["claims"]['claim'].nil?
          handle_entities(patent_hash["claims"]['claim'], ClaimVersion, :claims)
        end
        unless patent_hash.dig('drawings', 'figure').nil?
          handle_entities(patent_hash.dig('drawings', 'figure'), DrawingVersion, :drawings)
        end
        unless biblio.dig('classifications-ipcr', 'classification-ipcr').nil?
          handle_entities(biblio.dig('classifications-ipcr', 'classification-ipcr'), IPCClassificationVersion, :classifications)
        end
        unless biblio.dig('classifications-cpc').nil?
          unless biblio.dig('classifications-cpc', 'main-cpc').nil?
            handle_entities(biblio.dig('classifications-cpc', 'main-cpc', 'classification-cpc'), CPCClassificationVersion, :classifications)
          end
          unless biblio.dig('classifications-cpc', 'further-cpc').nil?
            handle_entities(biblio.dig('classifications-cpc', 'further-cpc', 'classification-cpc'), CPCClassificationVersion, :classifications)
          end
        end
      end
    end

    class PatentCitationVersion
      include EntityVersion

      def assign(citation_hash)
        @entity.category = citation_hash["category"]
        @entity.document_id = citation_hash["patcit"]["document-id"]
        @entity.classification_cpc_text = citation_hash["classification-cpc-text"]
        unless citation_hash["classification-national"].nil?
          national = NationalClassificationVersion.new
          national.read_hash(citation_hash["classification-national"])
          @entity.classification_national = national.entity
        end
      end

      def read_hash(citation)
        @entity = Sax2pats::PatentCitation.new
        assign(citation)
      end
    end

    class OtherCitationVersion
      include EntityVersion

      def assign(citation_hash)
        @entity.citation_value = citation_hash.fetch('othercit')
      end

      def read_hash(citation)
        @entity = Sax2pats::OtherCitation.new
        assign(citation.fetch('nplcit'))
      end
    end

    class InventorVersion
      include EntityVersion

      def assign(inventor_hash)
        @entity.address = inventor_hash["addressbook"]["address"]
        @entity.first_name = inventor_hash["addressbook"]["first-name"]
        @entity.last_name = inventor_hash["addressbook"]["last-name"]
      end

      def read_hash(inventor)
        @entity = Sax2pats::Inventor.new
        assign(inventor)
      end
    end

    class ClaimVersion
      include EntityVersion

      def assign(claim)
        @entity.claim_id = claim['id']
      end

      def read_hash(claim_hash)
        @entity = Sax2pats::Claim.new
        assign(claim_hash)
      end
    end

    class DrawingVersion
      include EntityVersion

      def assign(drawing_hash)
        @entity.img = drawing_hash.delete('img')
        @entity.figure = drawing_hash
      end

      def read_hash(drawings)
        @entity = Sax2pats::Drawing.new
        if drawings.kind_of?(Saxerator::Builder::HashElement)
          assign(drawings)
        elsif drawings.kind_of?(Saxerator::Builder::ArrayElement)
          drawings.each do |drawing_hash|
            assign(drawing_hash)
          end
        end
      end
    end

    class ClassificationVersion
      include EntityVersion

      def assign(classification)
        @entity.generating_office_country = classification.dig('generating-office', 'country')
        @entity.section = classification['section']
        @entity.cclass = classification['class']
        @entity.subclass = classification['subclass']
        @entity.main_group = classification['main-group']
        @entity.subgroup = classification['subgroup']
        @entity.symbol_position = classification['symbol-position']
        @entity.action_date = classification.dig('action-date', 'date')
        @entity.classification_status = classification['classification-status']
        @entity.classification_data_source = classification['classification-data-source']
      end
    end

    class IPCClassificationVersion < ClassificationVersion
      include EntityVersion

      def assign(ipc)
        @entity.version_date = ipc.fetch('ipc-version-indicator', 'date')
        @entity.classification_level = ipc['classification-level']
        super(ipc)
      end

      def read_hash(ipc_classifications)
        @entity = Sax2pats::IPCClassification.new
        if ipc_classifications.kind_of?(Saxerator::Builder::HashElement)
          assign(ipc_classifications)
        elsif ipc_classifications.kind_of?(Saxerator::Builder::ArrayElement)
          ipc_classifications.each do |ipc_classification_hash|
            assign(ipc_classification_hash)
          end
        end
      end
    end

    class CPCClassificationVersion < ClassificationVersion
      include EntityVersion

      def assign(cpc)
        @entity.version_date = cpc.fetch('cpc-version-indicator', 'date')
        @entity.classification_value = cpc['classification-value']
        super(cpc)
      end

      def read_hash(cpc_classifications)
        @entity = Sax2pats::CPCClassification.new
        if cpc_classifications.kind_of?(Saxerator::Builder::HashElement)
          assign(cpc_classifications)
        elsif cpc_classifications.kind_of?(Saxerator::Builder::ArrayElement)
          cpc_classifications.each do |cpc_classification_hash|
            assign(cpc_classification_hash)
          end
        end
      end
    end

    class LocarnoClassificationVersion
      include EntityVersion
    end

    class NationalClassificationVersion
      include EntityVersion

      def assign(classification)
        @entity.country = classification['country']
        @entity.main_classification = classification['main-classification']
      end

      def read_hash(classification)
        @entity = Sax2pats::NationalClassification.new
        if classification.kind_of?(Saxerator::Builder::HashElement)
          assign(classification)
        elsif classification.kind_of?(Saxerator::Builder::ArrayElement)
          classification.each do |classification_hash|
            assign(classification_hash)
          end
        end
      end
    end
  end
end
