# coding: utf-8
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "multiview/version"

Gem::Specification.new do |spec|
  spec.name          = "multiview"
  spec.version       = Multiview::VERSION
  spec.authors       = ["Jon Xie"]
  spec.email         = ["jon@ekohe.com"]

  spec.summary       = %q{Support multiple versions for Rails view.}
  spec.description   = %q{Support multiple versions for Rails view.}
  spec.homepage      = "https://github.com/xiejiangzhi/multiview"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.15"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.0"
end
