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
end
