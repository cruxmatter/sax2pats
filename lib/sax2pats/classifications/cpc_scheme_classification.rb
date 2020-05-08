class CPCSchemeClassification
  attr_reader :parent, :symbol, :date, :title

  def initialize(symbol:, parent:, title:)
    @symbol = symbol
    @parent = parent
    @title = title
  end

  def string_title
    #TODO
  end
end
