
class SimpContext
  attr_accessor :parent
  
  def initialize(parent = nil)
    @parent = parent
    @table = {}
  end
  
  def find(name)
    return @table[name] if @table.has_key?(name)
    return nil if @parent.nil?
    return @parent.find(name)
  end
  
  def define(name, value)
    @table[name] = value
  end
end