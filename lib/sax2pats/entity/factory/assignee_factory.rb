class AssigneeFactory < EntityFactory
  def entity_class
    Assignee
  end

  def assignee
    @entity
  end

  def entity_version_adaptor_class(xml_version_adaptor_class)
    xml_version_adaptor_class::AssigneeVersion
  end

  def attribute_keys
    %w[
      address
      first_name
      last_name
      orgname
      role
    ]
  end
end
