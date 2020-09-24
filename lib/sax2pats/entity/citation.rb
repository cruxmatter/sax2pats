module Citation
  include Entity
  attr_accessor :id
end

class PatentCitation
  include Citation
  attr_accessor :category,
                :document_id,
                :classification_cpc_text,
                :classification_national,
                :us_field_of_classification_search
end

class OtherCitation
  include Citation
  attr_accessor :citation_value
end
