
module SimpHelper
  
  def self.camel_case(string)
    return string if string !~ /_/ && string =~ /[A-Z]+.*/
    string.split('_').map { |e| e.capitalize }.join
  end
  
  def self.select_mod(mods, mod_type)
    mod_results = mods.select { |mod| mod.mod_type.to_sym == mod_type.to_sym }
    raise "Multiple matches for #{mod_type}" if mod_results.count > 1
    return mod_results.first.value if mod_results.count == 1
    nil
  end
  
  def self.conf(route)
    @@conf ||= YAML::load(File.open(File.expand_path('../../../simp.yml', __FILE__))) rescue {}
    p @@conf
    SimpHelper.get_config(@@conf, route)
  end
  
  def self.set_config(config, routes, value)
    cur_level = config
    
    routes.each_with_index do |route, i|
      if i != routes.length - 1
        h = Hash.new
        cur_level[route] ||= h
        cur_level = cur_level[route]
      else
        cur_level[route] = value
      end
    end
  end
  
  def self.get_config(config, routes)
    return config if routes.nil?
    # p [ 'Get Config a', config, routes ]
    routes = routes.clone # To be safe
    nxt = routes.shift
    # p [ 'Get Config b', nxt, routes ]
    return config[nxt] if routes.length == 0
    # p [ 'Get Config c', config, nxt, config[nxt]]
    return nil if config[nxt].nil?
    SimpHelper.get_config(config[nxt], routes)
  end
end