# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'ruboty/random_hatenabookmark/version'

Gem::Specification.new do |spec|
  spec.name          = "ruboty-random_hatenabookmark"
  spec.version       = Ruboty::RandomHatenabookmark::VERSION
  spec.authors       = ["r_takaishi"]
  spec.email         = ["ryo.takaishi.0@gmail.com"]

  spec.summary       = 'This randomly display from the hatena bookmark of specified user.'
  spec.description   = 'This randomly display from the hatena bookmark of specified user.'
  spec.homepage      = "http://repl.info/"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.13"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "minitest", "~> 5.0"

  spec.add_runtime_dependency 'ruboty'
  spec.add_dependency 'ruboty-slack_rtm'

  spec.add_dependency 'nokogiri'
  spec.add_dependency 'slack-api'
end
