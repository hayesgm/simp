
class LocalServer
  
  def initialize(*args)
    
  end
  
  def run(command, *args)
    # .map { |a| '"' + a + '"'}
    Simp.log [ 'Local Server', 'Running', "#{command} #{args.join(' ')}" ]
    `#{command} #{args.join(' ')}`
  end
  
  def upload(local, remote)
    FileUtils.copy(local, remote)
  end
  
end