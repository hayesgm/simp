
class SimpCloud
  
  def self.find_by_name(name)
    get_connection.servers.select { |s| s.tags['Name'] == name.to_s }
  end
  
  def self.all
    get_connection.servers
  end
  
  def self.first
    get_connection.servers.sort { |a,b| a.created_at <=> b.created_at }.first
  end
  
  def self.last
    get_connection.servers.sort { |a,b| a.created_at <=> b.created_at }.last
  end
  
  def self.spawn(name = nil, mods)
    # TODO: Remove ASAP
    
    # Fog.credential = :geoff
    
    # Micro - ami-ef5ff086 - t1.micro
    # Small - ami-0459bc6d - m1.small - with ruby?
    # Small - ami-08f41161
    ami = SimpHelper.select_mod(mods, :ami) || 'ami-ef5ff086'
    size = SimpHelper.select_mod(mods, :size) || 't1.micro'
    
    Simp.log [ 'Spawning New Cloud Server' ]
    server = get_connection.servers.bootstrap(:image_id => ami, :private_key_path => '~/.ssh/id_rsa', :public_key_path => '~/.ssh/id_rsa.pub', :flavor_id => size, :username => 'ec2-user', :tags => { 'Name' => name || get_name } )
    Simp.log [ 'Cloud Server Spawned', server ]
    
    Simp.log [ 'Waiting for server to be "up"' ]
    server.wait_for { ready? }
    
    Simp.log [ 'Server spawned', server ]
    server
  end
  
  private
    
    def self.get_name
      return 'server' + (rand*9999).to_i.to_s
    end
    
    def self.get_connection
      cloud = YAML::load(File.open(File.expand_path('../../../../config.yml', __FILE__)))['clouds']['aws'].inject({}){|memo,(k,v)| memo[k.to_sym] = v; memo}
    
      # cloud = YAML::load(File.open('/Users/geoff/animals/simp/config.yml'))['clouds']['aws'].inject({}){|memo,(k,v)| memo[k.to_sym] = v; memo}
    
      Simp.log [ 'Using cloud', cloud[:provider] ]
      connection = Fog::Compute.new(cloud)
    end
    
end