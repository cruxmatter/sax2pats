class PatentAbstract
  include DocEntity

  def initialize(element: nil)
    @element = element
  end
end

class PatentDescription
  include DocEntity

  def initialize(element: nil)
    @element = element
  end
end

class Patent
  include Entity
  attr_accessor :inventors,
                :assignees,
                :examiners,
                :applicants,
                :citations,
                :claims,
                :drawings,
                :tables,
                :classifications,
                :invention_title,
                :publication_reference,
                :application_reference,
                :number_of_claims,
                :abstract,
                :description,
                :patent_type
  attr_reader :description_text, :abstract_text

  def initialize(from_version)
    super(from_version)
    @publication_reference = {}
    @application_reference = {}
    @inventors = []
    @assignees = []
    @examiners = []
    @applicants = []
    @citations = []
    @claims = []
    @drawings = []
    @classifications = []
  end

  def ipc_classifications
    @classifications.select do |classification|
      classification.class == IPCClassification
    end
  end

  def cpc_classifications
    @classifications.select do |classification|
      classification.class == CPCClassification
    end
  end

  def national_classifications
    @classifications.select do |classification|
      classification.class == NationalClassification
    end
  end
end
