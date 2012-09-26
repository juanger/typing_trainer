# -*- encoding: utf-8 -*-
require File.expand_path('../lib/typing_trainer/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ["Juan Germán Castañeda Echevarría"]
  gem.email         = ["juanger@gmail.com"]
  gem.description   = %q{TODO: Write a gem description}
  gem.summary       = %q{TODO: Write a gem summary}
  gem.homepage      = ""

  gem.files         = `git ls-files`.split($\)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.name          = "typing_trainer"
  gem.require_paths = ["lib"]
  gem.version       = TypingTrainer::VERSION
  gem.add_dependency "highline", "~> 1.6.13"
  gem.add_dependency "ffi-ncurses"
  gem.add_dependency "ruby-termios"
end
