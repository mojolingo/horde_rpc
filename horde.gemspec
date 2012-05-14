# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "horde_rpc/version"

Gem::Specification.new do |s|
  s.name        = "horde_rpc"
  s.version     = HordeRPC::VERSION
  s.authors     = ["Ben Langfeld"]
  s.email       = ["ben@langfeld.me"]
  s.homepage    = "http://github.com/mojolingo/horde_rpc"
  s.summary     = %q{A Horde XML-RPC client library in Ruby}
  s.description = %q{horde_rpc is a client library for accessing the Horde XML-RPC interface from Ruby.}

  s.rubyforge_project = "horde_rpc"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.add_development_dependency 'bundler', ["~> 1.0"]
  s.add_development_dependency 'rspec', ["~> 2.8"]
  s.add_development_dependency 'yard', ["~> 0.6"]
  s.add_development_dependency 'rake', [">= 0"]
  s.add_development_dependency 'fakeweb', [">= 0"]
  s.add_development_dependency 'mocha', [">= 0"]
  s.add_development_dependency 'guard-rspec'
end
