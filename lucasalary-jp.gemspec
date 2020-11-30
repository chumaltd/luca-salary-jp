
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'luca_salary/jp/version'

Gem::Specification.new do |spec|
  spec.name          = 'lucasalary-jp'
  spec.version       = LucaSalaryJp::VERSION
  spec.license       = 'GPL'
  spec.authors       = ['Chuma Takahiro']
  spec.email         = ['co.chuma@gmail.com']

  spec.required_ruby_version = '>= 2.6.0'

  spec.summary       = %q{LucaSalary calculation molule for Japan}
  spec.description   = <<~DESC
   LucaSalary calculation module for Japan
  DESC
  spec.homepage      = 'https://github.com/chumaltd/luca-salary-jp'

  if spec.respond_to?(:metadata)
    spec.metadata['homepage_uri'] = spec.homepage
    spec.metadata['source_code_uri'] = 'https://github.com/chumaltd/luca-salary-jp'
    spec.metadata['changelog_uri'] = 'https://github.com/chumaltd/luca-salary-jp/CHANGELOG.md'
  else
    raise 'RubyGems 2.0 or newer is required to protect against ' \
      'public gem pushes.'
  end

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files         = Dir["LICENSE", "lib/**/{*,.[a-z]*}"]
  spec.require_paths = ['lib']

  spec.add_dependency 'lucasalary', '>= 0.1.14'

  spec.add_development_dependency 'bundler', '~> 1.17'
  spec.add_development_dependency 'rake', '~> 12.3.3'
  spec.add_development_dependency 'minitest', '~> 5.0'
end
