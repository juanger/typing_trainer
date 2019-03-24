# -*- encoding: utf-8 -*-
require File.expand_path('../lib/typing_trainer/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ["Juan Germán Castañeda Echevarría"]
  gem.email         = ["juanger@gmail.com"]
  gem.description   = %q{Ruby typing trainer}
  gem.summary       = %q{Improve your typing skills by completing the tutorial or using your own text or code!}
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
  gem.add_dependency "stty"
  gem.add_development_dependency "rspec"
end
