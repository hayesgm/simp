
module SimpRing
  
  def self.get_config(routes = nil)
    @@conf ||= YAML::load(File.open(File.expand_path('../../../servers.yml', __FILE__))) rescue {}
    SimpHelper.get_config(@@conf, routes)
  end
  
  def self.list_rings
    rings = SimpRing.get_config([:rings])
    return rings.map { |k,v| k.to_s }
  end
  
  def self.get_ring(ring)
    SimpRing.get_config([:rings, ring.to_s])
  end
  
  def self.get_server(server_name)
    server_info = nil
    raise "Server #{server_name} not found" if ( server_info = SimpRing.get_config([:servers, server_name.to_s]) ).nil?
    SimpServer.new( server_info )
  end
  
  def self.add(ring, server)
    raise "Ring not found" if SimpRing.get_ring(ring).nil?
    raise "Server not found" if SimpRing.get_server(server.name).nil?
    conf = SimpRing.get_config
    # We're going to add the server to new ring
    conf[:rings][ring.to_s][:server_refs].push(server.name) if !conf[:rings][ring.to_s][:server_refs].include?(server.name)
    
    # Remove it from an old ring if it exists there
    old_ring = conf[:servers][server.name.to_s][:ring]
    conf[:rings][old_ring][:server_refs] -= [ server.name.to_s ] if !old_ring.nil? && old_ring.to_s != ring.to_s && conf[:rings][old_ring]
    # And change it's local ring knowledge
    conf[:servers][server.name.to_s][:ring] = ring.to_s
    server.ring = ring.to_s
    p conf
    File.open(File.expand_path('../../../servers.yml', __FILE__), 'w') {|f| f.write(conf.to_yaml) }
  end
  
  def self.rem(ring, server)
    raise "Ring #{ring} not found" if SimpRing.get_ring(ring).nil?
    raise "Server #{server.name} not found" if SimpRing.get_server(server.name).nil?
    conf = SimpRing.get_config
    
    # Remove it from an old ring if it exists there
    old_ring = conf[:servers][server.name.to_s][:ring]
    raise "Server #{server.name} not in ring #{ring} (in #{old_ring})" if old_ring.to_s != ring.to_s
    
    conf[:rings][old_ring][:server_refs] -= [ server.name.to_s ] if !old_ring.nil? && conf[:rings][old_ring]
    # And change it's local ring knowledge
    conf[:servers][server.name.to_s][:ring] = nil
    server.ring = nil
    File.open(File.expand_path('../../../servers.yml', __FILE__), 'w') {|f| f.write(conf.to_yaml) }
  end
  
  def self.list_servers(ring)
    ring = SimpRing.get_ring(ring)
    raise "Ring not found" if ring.nil?
    raise "Ring misconfigured" if ring[:server_refs].nil?
    SimpArray.new( ring[:server_refs].map { |sn| SimpRing.get_server(sn) } )
  end
  
  def self.find_server(ring, server_name)
    server = SimpRing.get_server(server_name)
    raise "Server not found" if server.nil?
    
    server
  end
end