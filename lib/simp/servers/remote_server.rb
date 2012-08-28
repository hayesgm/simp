require 'net/ssh'
require 'net/scp'

class RemoteServer
  
  def initialize(server = nil)
    @server = server
    @server.username = 'ec2-user' # TODO Aye!
  end
  
  def run(command, *args)
    # .map { |a| '"' + a + '"'}
    Simp.log [ 'Remote Server', 'Running', "#{command} #{args.join(' ')}" ]
    
    @server.ssh("#{command} #{args.join(' ')}")[0].stdout
    
    #Net::SSH.start(@host, 'root') do |ssh|
    #  ssh.exec! 
    #end    
  end
  
  def upload(local, remote)
    #Net::SCP.upload!@host, 'root', local, remote)
    Simp.log [ 'Remote Server', 'Uploading', local, remote ]
    @server.scp(local, remote)
  end
  
end