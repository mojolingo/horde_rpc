require 'spec_helper'

describe Horde do
  describe "sending requests" do
    before do
      FakeWeb.clean_registry
    end

    it "should hit the specified domain/port" do
      horde = Horde.new 'http://horde.bar.com/rpc/'

      FakeWeb.register_uri :post, "http://horde.bar.com/rpc/",
                           :status => ["200", "OK"],
                           :content_type => "text/xml",
                           :body => <<-RESPONSE
<?xml version="1.0"?>
<methodResponse>
  <params>
    <param>
      <value><string>bar</string></value>
    </param>
  </params>
</methodResponse>
RESPONSE

      horde.request 'foo'
    end

    it "should be formatted as XMLRPC" do
      horde = Horde.new 'http://horde.bar.com/rpc/'

      FakeWeb.register_uri :post, "http://horde.bar.com/rpc/",
                           :status => ["200", "OK"],
                           :content_type => "text/xml",
                           :body => <<-RESPONSE
<?xml version="1.0"?>
<methodResponse>
  <params>
    <param>
      <value><string>bar</string></value>
    </param>
  </params>
</methodResponse>
RESPONSE

      horde.request 'foo'

      FakeWeb.last_request.body.should match(/<methodCall>/)
    end

    it "should invoke the correct method, with the correct parameters, including user/password options" do
      horde = Horde.new 'http://horde.bar.com/rpc/', 'usera', 'passwordb'

      FakeWeb.register_uri :post, "http://usera:passwordb@horde.bar.com/rpc/",
                           :status => ["200", "OK"],
                           :content_type => "text/xml",
                           :body => <<-RESPONSE
<?xml version="1.0"?>
<methodResponse>
  <params>
    <param>
      <value><string>bar</string></value>
    </param>
  </params>
</methodResponse>
RESPONSE

      horde.request 'foo', :foo => 'bar'

      FakeWeb.last_request.body.should be == "<?xml version=\"1.0\" ?><methodCall><methodName>foo</methodName><params><param><value><struct><member><name>foo</name><value><string>bar</string></value></member></struct></value></param></params></methodCall>\n"
    end

    it "should be able to make a request without options" do
      horde = Horde.new 'http://horde.bar.com/rpc/'

      FakeWeb.register_uri :post, "http://horde.bar.com/rpc/",
                           :status => ["200", "OK"],
                           :content_type => "text/xml",
                           :body => <<-RESPONSE
<?xml version="1.0"?>
<methodResponse>
  <params>
    <param>
      <value><string>bar</string></value>
    </param>
  </params>
</methodResponse>
RESPONSE

      horde.request 'foo'

      FakeWeb.last_request.body.should be == "<?xml version=\"1.0\" ?><methodCall><methodName>foo</methodName><params/></methodCall>\n"
    end

    it "should be able to make a request with multiple options" do
      horde = Horde.new 'http://horde.bar.com/rpc/'

      FakeWeb.register_uri :post, "http://horde.bar.com/rpc/",
                           :status => ["200", "OK"],
                           :content_type => "text/xml",
                           :body => <<-RESPONSE
<?xml version="1.0"?>
<methodResponse>
  <params>
    <param>
      <value><string>bar</string></value>
    </param>
  </params>
</methodResponse>
RESPONSE

      horde.request 'foo', 'bar', 'baz'

      FakeWeb.last_request.body.should be == "<?xml version=\"1.0\" ?><methodCall><methodName>foo</methodName><params><param><value><string>bar</string></value></param><param><value><string>baz</string></value></param></params></methodCall>\n"
    end

    it "should return the returned data structure" do
      horde = Horde.new 'http://horde.bar.com/rpc/'

      FakeWeb.register_uri :post, "http://horde.bar.com/rpc/",
                           :status => ["200", "OK"],
                           :content_type => "text/xml",
                           :body => <<-RESPONSE
<?xml version="1.0"?>
<methodResponse>
  <params>
    <param>
      <value><string>bar</string></value>
    </param>
  </params>
</methodResponse>
RESPONSE

      horde.request('foo').should be == 'bar'
    end
  end

  describe "fetching a client by ID" do
    it "should return the fetched client data" do
      horde = Horde.new 'http://horde.bar.com/rpc/'

      id = "uid=foo@bar.com"

      response = {
        "__key"       => "uid=foo@bar.com",
        "__uid"       => "foo@bar.com",
        "firstname"   => "Joe",
        "lastname"    => "Bloggs",
        "name"        => "Joe Bloggs",
        "email"       => "foo@bar.com",
        "homePhone"   => "404 475 4840",
        "workPhone"   => "404 475 4840",
        "cellPhone"   => "404 475 4840",
        "homeAddress" => "Foo Lane, NY",
        "company"     => "Acme",
        "id"          => "uid=foo@bar.com",
        "__type"      => "Object",
        "source"      => "bar_clients"
      }

      horde.expects(:request).once.with('clients.getClient', id).returns response

      client = horde.get_client_by_id id
      client.should be response
    end
  end

  describe "searching for clients" do
    it "should return a set of client data" do
      horde = Horde.new 'http://horde.bar.com/rpc/'

      response = {'Acme' => [
        {
          "__key"       => "uid=foo@bar.com",
          "__uid"       => "foo@bar.com",
          "firstname"   => "Joe",
          "lastname"    => "Bloggs",
          "name"        => "Joe Bloggs",
          "email"       => "foo@bar.com",
          "homePhone"   => "404 475 4840",
          "workPhone"   => "404 475 4840",
          "cellPhone"   => "404 475 4840",
          "homeAddress" => "Foo Lane, NY",
          "company"     => "Acme",
          "id"          => "uid=foo@bar.com",
          "__type"      => "Object",
          "source"      => "bar_clients"
        }]
      }

      horde.expects(:request).once.with('clients.searchClients', ['Acme'], ['company']).returns response

      client = horde.search_clients :company => 'Acme'
      client.should be response
    end
  end

  describe "finding the first client by company name" do
    it "should return the relevant client data" do
      horde = Horde.new 'http://horde.bar.com/rpc/'

      client_data = {
        "__key"       => "uid=foo@bar.com",
        "__uid"       => "foo@bar.com",
        "firstname"   => "Joe",
        "lastname"    => "Bloggs",
        "name"        => "Joe Bloggs",
        "email"       => "foo@bar.com",
        "homePhone"   => "404 475 4840",
        "workPhone"   => "404 475 4840",
        "cellPhone"   => "404 475 4840",
        "homeAddress" => "Foo Lane, NY",
        "company"     => "Acme",
        "id"          => "uid=foo@bar.com",
        "__type"      => "Object",
        "source"      => "bar_clients"
      }
      response = {'Acme' => [client_data]}

      horde.expects(:request).once.with('clients.searchClients', ['Acme'], ['company']).returns response

      client = horde.first_client_for_company 'Acme'
      client.should be == client_data
    end

    context "if no matches are found" do
      it "should return nil" do
        horde = Horde.new 'http://horde.bar.com/rpc/'

        response = {'Acme' => []}

        horde.expects(:request).once.with('clients.searchClients', ['Acme'], ['company']).returns response

        client = horde.first_client_for_company 'Acme'
        client.should be nil
      end
    end
  end

  describe "recording time" do
    it "should record time given the requested parameters" do
      horde = Horde.new 'http://horde.bar.com/rpc/'

      options = {
        :date         => Date.today,
        :client       => 'bob@acme.com',
        :type         => 1,
        :hours        => 1.2,
        :description  => 'Did stuff',
        :employee     => 'foo@bar.com'
      }

      horde.expects(:request).once.with('time.recordTime', options)

      horde.record_time options
    end

    %w{date client type hours description employee}.each do |required_option|
      context "without specifying #{required_option}" do
        it "should raise ArgumentError" do
          horde = Horde.new 'http://horde.bar.com/rpc/'

          options = {
            :date         => Date.today,
            :client       => 'bob@acme.com',
            :type         => 1,
            :hours        => 1.2,
            :description  => 'Did stuff',
            :employee     => 'foo@bar.com'
          }
          options.merge! required_option.to_sym => nil

          horde.expects(:request).never

          lambda { horde.record_time options }.should raise_error(ArgumentError)
        end
      end
    end
  end
end
