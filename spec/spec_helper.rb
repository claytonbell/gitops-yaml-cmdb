require 'gitops_cmdb'

RSpec.configure do |config|
  config.mock_with :rspec do |mocks|
    # Prevents you from mocking or stubbing a method that does not exist on
    # a real object. This is generally recommended, and will default to
    # `true` in RSpec 4.
    mocks.verify_partial_doubles = true
  end
end

module SpecHelperGitopsCmdb
  def load_yaml_file path
    YAML.safe_load(
      File.readlines(path).join
    )
  end
end