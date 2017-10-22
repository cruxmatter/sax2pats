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
      pv = PatentVersion.new
      pv.read_hash(patent_grant_hash)
      pv.entity
    end

    class PatentVersion
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

      def claims(claims)
        if claims.kind_of?(Saxerator::Builder::HashElement)
          cv = ClaimVersion.new
          cv.read_hash(claims)
          @entity.claims << cv.entity
        elsif claims.kind_of?(Saxerator::Builder::ArrayElement)
          claims.each do |claim_hash|
            cv = ClaimVersion.new
            cv.read_hash(claim_hash)
            @entity.claims << cv.entity
          end
        end
      end

      def inventors(inventors)
        if inventors.kind_of?(Saxerator::Builder::HashElement)
          iv = InventorVersion.new
          iv.read_hash(inventors)
          @entity.inventors << iv.entity
        elsif inventors.kind_of?(Saxerator::Builder::ArrayElement)
          inventors.each do |inventor_hash|
            iv = InventorVersion.new
            iv.read_hash(inventor_hash)
            @entity.inventors << iv.entity
          end
        end
      end

      def drawings(drawings)
        if drawings.kind_of?(Saxerator::Builder::HashElement)
          dv = DrawingVersion.new
          dv.read_hash(drawings)
          @entity.drawings << dv.entity
        elsif drawings.kind_of?(Saxerator::Builder::ArrayElement)
          drawings.each do |drawing_hash|
            dv = DrawingVersion.new
            dv.read_hash(drawing_hash)
            @entity.drawings << dv.entity
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
          inventors(biblio.dig('us-parties', 'inventors', 'inventor'))
        end
        unless patent_hash["claims"]['claim'].nil?
          claims(patent_hash["claims"]['claim'])
        end
        unless patent_hash.dig('drawings', 'figure').nil?
          drawings(patent_hash.dig('drawings', 'figure'))
        end
      end
    end

    class PatentCitationVersion
      include EntityVersion

      def assign(citation_hash)
        @entity.category = citation_hash["category"]
        @entity.document_id = citation_hash["patcit"]["document-id"]
        @entity.classification_cpc_text = citation_hash["classification-cpc-text"]
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
  end
end
