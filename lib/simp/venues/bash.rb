
class Bash < Venue
  
  def initialize(server, build, *mods)
    Simp.log [ 'Bash Venue', server, build, *mods ]
    
    server.run( build[:cmd], Mod.get(mods, :input) )
  end
  
  
end