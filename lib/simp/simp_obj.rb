
class SimpObj
  
  def to_param
    Marshal.dump(self)
  end
  
  def self.from_param(param)
    Marshal.load(param)
  end
  
end