class ExaminerFactory < EntityFactory
  ENTITY_KEY = 'examiner'.freeze

  def entity_class
    Sax2pats::Examiner
  end

  def examiner
    @entity
  end

  def attribute_keys
    %w[
      department
      first_name
      last_name
    ]
  end
end
