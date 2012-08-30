
require 'simp/venue'
require 'simp/venues/bash'
require 'simp/venues/chef'
require 'readline'

module SimpCLIFunctions
  VENUES = {
    :bash => { :class => Bash },
    :chef => { :class => Chef }
  }
  
  BUILD_MAP = {
    :mysql => { :venue => :chef, :recipes => [ 'http://github.com/opscode-cookbooks/mysql' ] },
    :rails => { :venue => :chef, :recipes => [ 'rails' ], :cookbooks => [ "git://github.com/opscode/cookbooks.git" ], :cookbooks_in_place => true },
    :nodejs => { :venue => :chef, :recipes => [ 'cookbook-node' ], :cookbooks => [ "git://github.com/digitalbutter/cookbook-node.git" ] },
    :rcrails => { :venue => :chef, :recipes => [ 'main'], :cookbooks => [ { :repo => 'https://github.com/railscasts/339-chef-solo-basics', :subdir => 'chef/cookbooks' } ] },
    :ruby => '/build/ruby',
    :nginx => '/build/nginx',
    :echo => { :venue => :bash, :cmd => '/bin/echo' },
    :cat => { :venue => :bash, :cmd => '/bin/cat' }
  }
  
  def self.add(*args)
    return args.inject(0) { |sum, x| sum += SimpProcessor.evaluate(x) }
  end
  
  def self.join(*args)
    return args.map { |x| SimpProcessor.evaluate(x) }.join(', ')
  end
  
  def self.joinc(*args)
    return args.map { |x| SimpProcessor.evaluate(x) }.join('~')
  end
  
  # spawn
  # Spawns a blank server
  # args: [ name?, *args ]
  def self.spawn(*args)
    args = args.map { |x| SimpProcessor.evaluate(x) }
    
    Simp.log [ 'Spawning...', args ]
    
    name = args[0] ? args[0].to_s : nil
    Simp.log [ 'Creating Server...', name ]
    
    if !ENV['REMOTE']
      server = LocalServer.new
    else
      server = RemoteServer.new(SimpCloud.spawn(name))
    end
    
    return server
  end
  
  # getr
  # Gets remote server(s) matching the arguments passed in
  def self.getr(*args)
    args = args.map { |x| SimpProcessor.evaluate(x) }
    
    Simp.log [ 'Getting...', args ]
    
    servers = nil
    
    # Parse args for what to get
    if args[0].is_a?(Symbol)
      case args[0]
      when :all
        servers = SimpCloud.all.map { |s| RemoteServer.new(s) }
      when :first
        servers = [ RemoteServer.new(SimpCloud.first) ]
      when :last
        servers = [ RemoteServer.new(SimpCloud.last) ]
      end
    end
    
    if servers.nil? && ( args[0].is_a?(String) || args[0].is_a?(Symbol) )
      servers = SimpCloud.find_by_name(args[0]).map { |s| RemoteServer.new(s) }
    end
    
    if servers.nil?
      raise "Don't know how to get #{args}"
    end
    
    if servers.count == 0
      raise "Didn't find any servers matching #{args}"
    end
    
    Simp.log [ 'Got servers', servers ]
    
    return servers
  end
  
  # build
  # Builds a server
  # args: [ buildtype, *mods ]
  def self.build(*args)
    args = args.map { |x| SimpProcessor.evaluate(x) }
    Simp.log [ 'Building...', args ]
    
    server_name = args[1].is_a?(String) ? args[1].to_s : nil
    mods = get_mods(*args)
    
    Simp.log [ 'Creating Server...', server_name, mods ]
    
    if ENV['HARD_REMOTES'].to_i == 1 && !ENV['REMOTE']
      server = LocalServer.new
    else
      server = RemoteServer.new(SimpCloud.spawn(server_name, mods))
    end
    
    # venue = Venue.new(args[0], )
    # Now, we need to bootstrap the server
    # For now, we'll be running bash-type scripts
    build_type = args.shift
    install_code(server, build_type, *mods)
    
    return nil
  end
  
  # install
  # Installs software on a server
  # args: [ server, buildtype, *mods ]
  def self.install(*args)
    args = args.map { |x| SimpProcessor.evaluate(x) }
    Simp.log [ 'Installing...', args ]
    
    servers = args.shift
    servers = [ servers ] if !servers.is_a?(Array)
    build_type = args.shift
    mods = get_mods(*args)
    
    # Install on each server
    servers.each do |server|
      Simp.log [ 'Install on server', server ]
      install_code(server, build_type, *mods)
    end
    
    Simp.log 'end'
    return nil
  end
  
  def self.+(*args)
    args = args.map { |x| SimpProcessor.evaluate(x) }
    p [ 'Adding...', args ]
    
    # TODO: + additions
    return nil # install(*args)
  end
  
  def self.mod(*args)
    args = args.map { |x| SimpProcessor.evaluate(x) }
    p [ 'Modding...', args ]
    
    return build_args(*args)
  end
  
  def self.lb(*args)
    args = args.map { |x| SimpProcessor.evaluate(x) }
    return [ 'LB', args ]
  end
  
  # bake
  # Bakes a server after completing a build
  def self.bake(*args)
    args = args.map { |x| SimpProcessor.evaluate(x) }
    return [ 'Baking', args ]
  end
  
  # launch
  # Launches a baked AMI
  def self.launch(*args)
    args = args.map { |x| SimpProcessor.evaluate(x) }
    return [ 'Launching', args ]
  end
  
  def self.tasks(*args)
    args = args.map { |x| SimpProcessor.evaluate(x) }
    return [ 'Tasks', args ]
    # Eh
  end
  
  # ring
  # Switches global scope to ring specified
  # args: [ ring_name, chain, ... ]
  def self.ring(*args)
    ring = args.shift.to_sym
    SimpProcessor.set_env(:ring, ring)
    
    args = args.map { |x| SimpProcessor.evaluate(x) }
    
    Simp.log [ 'Using Ring', ring, 'Chaining', args ]
    
    if args.length > 0
      command = args.shift
      Simp.log [ 'Chaining', ["ring-#{command.to_s}", ring] + args ]
      SimpProcessor.evaluate(["ring-#{command.to_s}", ring] + args)
    else
      return "@#{ring}"
    end
  end
  
  # build-type
  # Create a new build-type
  def self.buildtype(*args)
    args = args.map { |x| SimpProcessor.evaluate(x) }
    return [ 'Build Type', args ]
  end
  
  # get
  # Gets a server (in current ring)
  # args: [ name ]
  def self.get(*args)
    args = args.map { |x| SimpProcessor.evaluate(x) }
    Simp.log [ 'Get', args ]
    Simp.log [ 'Processor Env Ring', SimpProcessor.get_env(:ring)]
    
    SimpRing.find_server(SimpProcessor.get_env(:ring), args[0])
  end
  
  # Load Balance
  module Lb
    def self.add(*args)
      args = args.map { |x| SimpProcessor.evaluate(x) }
      return [ 'LB adding', args ]
    end
  end
  
  # Rings
  module Ring
    
    # ring-all
    # Lists all rings
    # args: [ ]
    def self.all(*args)
      args = args.map { |x| SimpProcessor.evaluate(x) }
      Simp.log [ 'List rings', args ]
      
      return SimpRing.list_rings.join(' ')
    end
    
    # ring-list
    # Lists all servers in a ring
    # args: [ ring ]
    def self.list(*args)
      args = args.map { |x| SimpProcessor.evaluate(x) }
      ring = args.shift
      Simp.log [ 'Listing servers in ring', ring ]
      
      SimpRing.list_servers(ring)
    end
    
    # ring-info
    # Get detailed information about a ring
    # args: [ ]
    def self.info(*args)
      args = args.map { |x| SimpProcessor.evaluate(x) }
      Simp.log [ 'Info on ring', args ]
      
      return SimpRing.get_ring(args.pop)
    end
    
    def self.create(*args)
      args = args.map { |x| SimpProcessor.evaluate(x) }
      return [ 'Creating ring', args ]
    end
    
    # ring-add
    # Add server to a ring
    # args [ ring, server1, server2, ... ]
    def self.add(*args)
      args = args.map { |x| SimpProcessor.evaluate(x) }
      ring = args.shift
      
      # We can accept servers or strings
      server_names = args.inject([]) { |total,a| total + ( a.is_a?(String) ? a.to_s.split(',') : [ a ] ) }
      servers = server_names.map { |s| s.is_a?(String) || s.is_a?(Symbol) ? SimpRing.get_server(s) : s }
      
      Simp.log [ 'Adding to ring', ring, servers ]
      
      servers.each do |server|
        SimpRing.add(ring, server)
      end
    end
    
    def self.rem(*args)
      args = args.map { |x| SimpProcessor.evaluate(x) }
      ring = args.shift
      
      # We can accept servers or strings
      server_names = args.inject([]) { |total,a| total + ( a.is_a?(SimpArray) ? a.value : [ a ] ) }
      servers = server_names.map { |s| s.is_a?(String) || s.is_a?(Symbol) ? SimpRing.get_server(s) : s }
      
      Simp.log [ 'Removing from ring', ring, servers ]
      
      servers.each do |server|
        SimpRing.rem(ring, server)
      end
    end
  end
  
  # Configures simp (generates simp.yml)
  # Can be set by options or the command-line
  def self.config(*args)
    if args.length == 0
      config = YAML::load(File.open(File.expand_path('../../../../simp.yml', __FILE__))) rescue {}
      Simp.config_options.each do |option|
        
        cur = SimpHelper.get_config(config, option[:route])
        p [ 'Setting', option[:route], 'currently', cur ]
        line = nil
        while line.nil? || !(line =~ option[:options]) || ( option[:ignore] == :non_nil && line.length == 0 && cur.nil? )
          puts "Invalid response." if !line.nil?
          line = Readline.readline(option[:prompt] + ' ', true)
        end
        
        if option[:ignore] != :non_nil || line.length > 0
          SimpHelper.set_config(config, option[:route], option[:map] ? option[:map][line.intern] : line)
        end
      end
      
      # p config
      # p SimpHelper.get_config(config, [:cloud, :provider])
      File.open(File.expand_path('../../../../simp.yml', __FILE__), 'w') {|f| f.write(config.to_yaml) }
    end
    
    p SimpHelper.conf([:cloud, :provider])
    p SimpHelper.conf([:cloud, :provider])
    return nil
  end
  
  private
  
    def self.install_code(*args)
      server = args.shift
      build_type = args.shift
      build = BUILD_MAP[build_type.to_sym]
      venue_type = VENUES[build[:venue]]
      raise "Don't know how to build #{build_type}" if build.nil?
      p [ 'Building', build, venue_type, args ]
      venue = venue_type[:class].new(server, build, *args)
      
      return build
    end
    
    def self.build_args(*args)
      p [ 'Build Args', args ]
      return Mod.new(*args).to_param
    end
    
    def self.get_mods(*args)
      args.inject([]) { |res, k| v = SimpObj.from_param(k) rescue nil; v.is_a?(Mod) ? res + [v] : res }
    end
end

