# encoding: utf-8

Gem::Specification.new do |s|
  s.name = "requests"
  s.version = "1.0.3"
  s.summary = "Requests: HTTP for Humans (Ruby port)"
  s.description = "Because Requests for Python is awesome"
  s.authors = ["Cyril David"]
  s.email= ["cyx@cyx.is"]
  s.homepage = "http://github.com/cyx/requests"
  s.files = Dir[
    "LICENSE",
    "README",
    "makefile",
    "lib/**/*.rb",
    "lib/cacert.pem",
    "tests/*.rb",
    "*.gemspec"
  ]

  s.license = "MIT"
  s.require_paths = ["lib"]
  s.add_development_dependency "cutest"
end
