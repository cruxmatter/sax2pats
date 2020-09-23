class Drawing
  include Entity
  include DocEntity
  attr_accessor :id, :img, :description

  def initialize(from_version)
    super(from_version)
    @img = {}
  end
end
