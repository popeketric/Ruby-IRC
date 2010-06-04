require 'rubygems'

SPEC = Gem::Specification.new do |s|
  s.name     = "Ruby-IRC"
  s.version  = "1.0.13"
  s.author   = "Chris Boyer"
  s.email    = "cboyer@musiciansfriend.com"
  s.homepage = "http://www.pulpreligion.org"
  s.platform = Gem::Platform::RUBY
  s.summary  = "An IRC Client library"
  candidates = Dir.glob("{lib}/**/*")
  s.files    = candidates.delete_if do |item|
                 item.include?("CVS") || item.include?("rdoc")
               end
  s.require_path = "lib"
  s.autorequire  = "IRC"
  s.has_rdoc     = "true"
  s.extra_rdoc_files = ["README"]
end
