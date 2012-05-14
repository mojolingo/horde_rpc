require 'horde/version'
require 'xmlrpc/client'

class Horde
  ##
  # Create a new instance of the Horde connection
  #
  # @param [String] uri XML-RPC URI for the horde instance
  # @param [String, Optional] username
  # @param [String, Optional] password
  #
  def initialize(uri, username = nil, password = nil)
    @xmlrpc_client = XMLRPC::Client.new2 uri
    @xmlrpc_client.user     = username
    @xmlrpc_client.password = password
  end

  ##
  # Make an RPC request against the Horde instance
  #
  # @param [String] method the method name to execute
  # @param [Object, Optional] options
  #
  # @return [Object] response to the RPC
  #
  def request(method, *options)
    @xmlrpc_client.call method, *options
  end

  ##
  # Return data for a client by its ID
  #
  # @param [String] id the clients ID
  #
  # @return [Hash,nil] client data
  #
  def get_client_by_id(id)
    request 'clients.getClient', id
  end

  ##
  # Search clients by KV-pairs
  #
  # @param [Hash<#to_s, String>] search_params
  #
  # @return [Hash] map of search terms to results
  #
  # @example Search for clients by first name
  #
  #   horde.search_clients :firstname => 'Bob'
  #   # => {'Acme' => [
  #          {
  #           "__key"       => "uid=foo@bar.com",
  #           "__uid"       => "foo@bar.com",
  #           "firstname"   => "Joe",
  #           "lastname"    => "Bloggs",
  #           "name"        => "Joe Bloggs",
  #           "email"       => "foo@bar.com",
  #           "homePhone"   => "404 475 4840",
  #           "workPhone"   => "404 475 4840",
  #           "cellPhone"   => "404 475 4840",
  #           "homeAddress" => "Foo Lane, NY",
  #           "company"     => "Acme",
  #           "id"          => "uid=foo@bar.com",
  #           "__type"      => "Object",
  #           "source"      => "bar_clients"
  #          }]
  #        }
  #
  def search_clients(search_params = {})
    # searchClients takes two arrays as params:
    # * list of search strings
    # * list of search fields
    request 'clients.searchClients', search_params.values, search_params.keys.map(&:to_s)
  end

  ##
  # Find the first client record for a particular company name
  #
  # @param [String] name the name of the Company
  #
  # @return [Hash,nil] data for the client associated with the requested company
  #
  def first_client_for_company(name)
    results = search_clients :company => name
    results[name].first
  end

  ##
  # Record time against a project
  #
  # @params [Hash] options
  # @option options [Date] :date the date of the billable activity
  # @option options [String] :client the ID of the client to bill
  # @option options [Integer] :type the type of billable activity
  # @option options [Float] :hours the number of hours to bill
  # @option options [String] :description a description of the billable activity
  # @option options [String] :employee the username of the employee performing the billable activity
  #
  def record_time(options)
    raise ArgumentError unless options.values_at(:date, :client, :type, :hours, :description, :employee).all?
    request 'time.recordTime', options
  end
end
