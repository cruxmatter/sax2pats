module Sax2pats
  class Classification
    include Entity
  end

  class IPCClassification < Classification
    attr_accessor :version_date,
                  :classification_level,
                  :section,
                  :class,
                  :subclass,
                  :main_group,
                  :subgroup,
                  :symbol_position,
                  :action_date,
                  :generating_country,
                  :classification_status,
                  :classification_data_source
  end

  class CPCClassification < Classification

  end

  class LocarnoClassification < Classification
    attr_accessor :edition, :main_classification
  end
end
