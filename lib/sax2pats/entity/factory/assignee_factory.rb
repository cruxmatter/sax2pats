class AssigneeFactory < EntityFactory
  ENTITY_KEY = 'assignee'.freeze

  def entity_class
    Sax2pats::Assignee
  end

  def assignee
    @entity
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
