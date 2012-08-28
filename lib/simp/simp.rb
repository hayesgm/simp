
module Simp
  
  
  def self.log(*args)
    p *args
  end
  
  def self.error(*args)
    p *args
  end
  
  def self.config_options
    return [
      { :prompt => 'Would you like to use [a]ws or [r]ackspace?', :route => [ :cloud, :provider ], :options => /^[ar]?$/, :map => { :a => 'AWS', :r => 'Rackspace' }, :ignore => :non_nil },
      { :prompt => 'Please enter your aws access key:', :route => [ :cloud, :aws_access_key_id ], :options => /^[a-zA-Z0-9-]*$/, :if => '', :ignore => :non_nil },
      { :prompt => 'Please enter your aws secret key:', :route => [ :cloud, :aws_secret_access_key ], :options => /^[a-zA-Z0-9-]*$/, :if => '', :ignore => :non_nil }
    ]
  end
end