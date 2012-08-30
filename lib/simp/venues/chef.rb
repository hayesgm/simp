
class Chef < Venue
  
  def initialize(server, build, *mods)
    Simp.log [ 'Install', build, mods ]
    
    # TODO: Install ruby-gems
    # server.run("sudo #{package :install} zlib")
    
    if !installed?(server, 'ruby')
      Simp.log(['Installing ruby'])
      
    end
    
    if !installed?(server, 'gem')
      Simp.log(['Installing rubygems'])
      
    end
    
    if !installed?(server, 'chef-solo')
      Simp.log(['Installing chef-solo'])
      
      server.run('gem install chef --no-ri --no-rdoc')
    end
    
    if !installed?(server, 'git')
      Simp.log(['Installing git'])
      
      server.run("sudo #{package :install} git-core")
    end
    
    Simp.log server.run("whoami")
    Simp.log server.run("mkdir -p ~/chef")
    
    # server.upload(File.expand_path("../../../../data/chef/solo.json", __FILE__), '/home/ec2-user/chef/solo.json')
    
    # Simp.log server.run('ruby /tmp/boot.rb')
    
    build[:cookbooks].each do |cookbook|
      get_cookbook(server, cookbook)
    end
    
    
    install_recipes(server, build[:recipes])
    
  end
  
  def get_cookbook(server, cookbook)
    server.run("mkdir -p ~/chef/cookbooks")
    o =  [('a'..'z'),('A'..'Z')].map{|i| i.to_a}.flatten
    tmp_name = (0..10).map{ o[rand(o.length)] }.join
    
    server.run("mkdir -p /tmp/#{tmp_name}")
    server.run("cd /tmp/#{tmp_name} && git clone #{cookbook[:repo]} .")
    server.run("cd /tmp/#{tmp_name} && cp -r #{ cookbook[:subdir] || '.'} ~/chef/cookbooks")
  end
  
  def install_recipes(server, recipes)
    server.upload(File.expand_path("../../../../data/chef/solo.rb", __FILE__), '/home/ec2-user/chef/solo.rb')
    
    Simp.log server.run("mkdir -p ~/chef/roles")
    server.upload(File.expand_path("../../../../data/chef/roles/server.rb", __FILE__), '/home/ec2-user/chef/roles/server.rb')
    
    solo_json = Erubis::Eruby.new(File.read(File.expand_path("../../../../data/chef/solo.json.erb", __FILE__))).result(:recipes => recipes)
    
    server.run("cat > ~/chef/solo.json <<EOF\n#{solo_json}\nEOF\n")
    
    Simp.log server.run("rvmsudo chef-solo -c ~/chef/solo.rb -j ~/chef/solo.json")
  end
  
  def installed?(server, app)
    res = server.run("which #{app} 2> /dev/null")
    Simp.log([ 'Installed res', res ])
    return res.length > 0
  end
  
  # TODO: Make this right
  def package(type)
    "yum -y install"
  end
end