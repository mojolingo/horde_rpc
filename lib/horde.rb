require 'horde/version'
require 'xmlrpc/client'

class Horde
  def initialize(uri, username = nil, password = nil)
    @xmlrpc_client = XMLRPC::Client.new2 uri
    @xmlrpc_client.user     = username
    @xmlrpc_client.password = password
  end

  def request(method, *options)
    @xmlrpc_client.call method, *options
  end
end
