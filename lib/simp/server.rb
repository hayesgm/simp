
class SimpServer < SimpObj
  
  def initialize(*args)
    opts = args.pop
    p [ 'Options', opts ]
    @name = opts[:name].to_s if opts[:name]
    @ring = opts[:ring].to_s if opts[:ring]
    @internal = opts[:internal] if opts[:internal]
    @external = opts[:external] if opts[:external]
    @roles = opts[:roles] if opts[:roles]
    @attr = opts[:attr] if opts[:attr]
  end
  
  def method_missing(method, *args, &block)
    return self.instance_variable_get('@' + method.to_s) if method.to_s =~ /^[a-zA-Z0-9_]+$/ && self.instance_variable_defined?('@' + method.to_s)
    return self.instance_variable_set('@' + $1, args[0]) if method.to_s =~ /^([a-zA-Z0-9_]+)=$/
    super
  end
  
end