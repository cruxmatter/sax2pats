class ExaminerFactory < EntityFactory
  def entity_class
    Sax2pats::Examiner
  end

  def examiner
    @entity
  end

  def entity_version_adaptor_class(xml_version_adaptor_class)
    xml_version_adaptor_class::ExaminerVersion
  end

  def attribute_keys
    %w[
      department
      first_name
      last_name
    ]
  end
end
