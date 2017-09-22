$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "tok_access/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "tok_access"
  s.version     = TokAccess::VERSION
  s.authors     = ["Yonga9121"]
  s.email       = ["jorgeggayon@gmail.com"]
  s.homepage    = "https://yonga9121.github.io/tok_access/"
  s.summary     = "Handle authentication of your users using tokens."
  s.description = "Handle authentication of your users using tokens."
  s.license     = "MIT"

  s.files = Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.md"]

  s.add_dependency "rails", "~> 5.1.0"
  s.add_dependency "bcrypt", "~> 3.1.7"

  s.add_development_dependency "sqlite3"
end
