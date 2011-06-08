# encoding: utf-8
$:.push File.expand_path( "../lib", __FILE__ )
require "can_interact/version"

Gem::Specification.new do |s|
  s.name        = "chrno_can_interact"
  s.version     = CanInteract::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = [ "Denis Diachkov" ]
  s.email       = [ "d.diachkov@gmail.com" ]
  s.homepage    = "http://larkit.ru"
  s.summary     = "Adds interactions AR models"

  s.files         = Dir[ "*", "lib/**/*" ]
  s.require_paths = [ "lib" ]

  s.add_runtime_dependency "chrno_core_ext", ">= 1.1.2"
  s.add_runtime_dependency "rails", ">= 3.0"
  s.add_runtime_dependency "activerecord", ">= 3.0"
end