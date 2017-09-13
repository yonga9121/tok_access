$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "tok_access/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "tok_access"
  s.version     = TokAccess::VERSION
  s.authors     = ["Yonga"]
  s.email       = ["jorgeggayon@gmail.com"]
  s.homepage    = "https://github.com/yonga9121/tok_access.git"
  s.summary     = "Handle the authentication of an object (application user) generating tokens for identify devises and provide access to the object "
  s.description = "Handle the authentication of an object (application user) generating tokens for identify devises and provide access to the object "
  s.license     = "MIT"

  s.files = Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.md"]

  s.add_dependency "rails", "~> 5.1.4"
  s.add_dependency "bcrypt", "~> 3.1.7"

  s.add_development_dependency "sqlite3"
end
