Gem::Specification.new do |gem|
  gem.name          = 'gitops_cmdb'
  gem.version       = '0.0.1'
  gem.authors       = ['Clayton Bell']
  gem.email         = ['clayton@ii,net']
  gem.homepage      = 'https://github.com/claytonbell/gitops-yaml-cmdb/'
  gem.description   = %q(YAML masher)
  gem.summary       = %q(YAML masher)
  gem.files         = `git ls-files`.split("\n") - ['.gitignore', '.travis.yml']
  gem.test_files    = gem.files.grep(/^spec/)
  gem.require_paths = ['lib']
  gem.licenses      = ['MIT']
  gem.required_ruby_version = '~> 2.6'
  gem.add_development_dependency 'bundler'
  gem.add_development_dependency 'rspec'
  gem.add_development_dependency 'rubocop'
end
