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

  def get_client_by_id(id)
    request 'clients.getClient', id
  end

  def search_clients(search_params = {})
    # searchClients takes two arrays as params:
    # * list of search strings
    # * list of search fields
    request 'clients.searchClients', search_params.values, search_params.keys.map(&:to_s)
  end

  def first_client_for_company(name)
    results = search_clients :company => name
    # The return value is a hash of results.
    # Each search string is the key to an array of records matching the string
    results[name].first
  end
end
