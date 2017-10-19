module Sax2pats
  module EntityVersion
    attr_accessor :entity

    def assign(entity_hash)
      raise NotImplementedError
    end

    def read_hash(entity_hash)
      raise NotImplementedError
    end
  end

  module XMLVersion
    def patent_tag(mode)
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
      PatentVersion.new.read_hash(patent_grant_hash)
    end

    class PatentVersion
      include EntityVersion

      def assign(patent_hash)
        biblio = patent_hash['us-bibliographic-data-grant']
        @entity.publication_reference = biblio['publication-reference']
        @entity.application_reference = biblio['application-reference']
        @entity.invention_title = biblio.fetch('invention-title')
        @entity.number_of_claims = biblio['number-of-claims']
      end

      def read_hash(patent_hash)
        @entity = Sax2pats::Patent.new
        assign(patent_hash)

        biblio = patent_hash['us-bibliographic-data-grant']

        biblio["us-references-cited"]["us-citation"].each do |citation_hash|
          cv = CitationVersion.new
          cv.read_hash(citation_hash)
          @entity.citations << cv.entity
        end

        iv = InventorVersion.new
        iv.read_hash(biblio.dig('us-parties', 'inventors', 'inventor'))

        patent_hash["claims"]['claim'].each do |claim_hash|
          cv = ClaimVersion.new
          cv.read_hash(claim_hash)
          @entity.claims << cv.entity
        end

        dv = DrawingVersion.new
        dv.read_hash(patent_hash.dig('drawings'))
      end
    end

    class CitationVersion
      include EntityVersion

      def read_hash(citation_hash)
        @entity = Sax2pats::Citation.new
        if citation_hash.has_key?('patcit')
          @entity.category = citation_hash["patcit"]["category"]
          @entity.document_id = citation_hash["patcit"]["document-id"]
          @entity.classification_cpc_text = citation_hash["patcit"]["classification-cpc-text"]
        end
      end
    end

    class InventorVersion
      include EntityVersion

      def assign(inventor_hash)
        @entity.location_address = inventor_hash["addressbook"]["address"]
        @entity.first_name = inventor_hash["addressbook"]["first-name"]
        @entity.last_name = inventor_hash["addressbook"]["last-name"]
      end

      def read_hash(inventors)
        @entity = Sax2pats::Inventor.new
        if inventors.kind_of?(Saxerator::Builder::HashElement)
          assign(inventors)
        elsif inventors.kind_of?(Saxerator::Builder::ArrayElement)
          inventors.each do |inventor_hash|
            assign(inventor_hash)
          end
        end
      end
    end

    class ClaimVersion
      include EntityVersion

      def read_hash(claim_hash)
        @entity = Sax2pats::Claim.new
        @entity.claim_id = claim_hash['id']
      end
    end

    class DrawingVersion
      include EntityVersion

      def assign(drawing_hash)
        binding.pry
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
  end
end
