
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
    
    get_cookbook(server, 'git://github.com/37signals/37s_cookbooks.git', true)
    
    install_cookbooks(server, build[:recipes])
    
  end
  
  def get_cookbook(server, repo, here = false)
    server.run("mkdir -p ~/chef/cookbooks")
    server.run("cd ~/chef/cookbooks && git clone #{repo} #{ here ? '.' : '' }")
    
  end
  
  def install_cookbooks(server, cookbooks)
    server.upload(File.expand_path("../../../../data/chef/solo.rb", __FILE__), '/home/ec2-user/chef/solo.rb')
    
    solo_json = Erubis::Eruby.new(File.read(File.expand_path("../../../../data/chef/solo.json.erb", __FILE__))).result(recipes)
    
    server.run("cat > ~/chef/solo.json <<EOF\n#{solo_json}\nEOF\n")
    
    Simp.log server.run("chef-solo -c ~/chef.solo.rb -j ~/chef/solo.json")
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