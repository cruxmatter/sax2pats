module Sax2pats
  class Classification
    include Entity
  end

  class NationalClassification < Classification
    attr_accessor :country, :main_classification, :further_classification
  end

  class IPCClassification < Classification
    attr_accessor :version_date,
                  :classification_level,
                  :section,
                  :cclass,
                  :subclass,
                  :main_group,
                  :subgroup,
                  :symbol_position,
                  :action_date,
                  :generating_office_country,
                  :classification_status,
                  :classification_data_source
  end

  class CPCClassification < Classification
    attr_accessor :version_date,
                  :section,
                  :cclass,
                  :subclass,
                  :main_group,
                  :subgroup,
                  :symbol_position,
                  :action_date,
                  :generating_office_country,
                  :classification_status,
                  :classification_data_source
  end

  class LocarnoClassification < Classification
    attr_accessor :edition, :main_classification
  end
end
