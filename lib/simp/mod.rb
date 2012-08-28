
class Mod < SimpObj
  
  def mod_type
    @mod_type
  end
  
  def value
    @value
  end
  
  def initialize(*args)
    @mod_type = args[0]
    @value = args[1]
  end
  
  def self.get(mods, mod_type)
    mods.select { |mod| mod.mod_type == mod_type }.map { |m| m.value }.join(',')
  end
end