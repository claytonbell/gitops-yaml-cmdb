require 'active_support'
require 'active_support/core_ext/object/blank'

class GitopsCmdb::ProcessVariables
  class Error < StandardError; end

  attr_reader :data, :variables

  # root key name for variable definitions
  VARIABLES_KEY = 'variables'

  VALID_VARIABLE_NAME = /[A-Za-z0-9_]+/

  def self.translate data
    self.new(data).translate
  end

  def initialize data
    @data = data
    @variables = @data.delete(VARIABLES_KEY) || {}
    validate_variable_names!
    environment_variables_replace!
  end

  def translate
    data.transform_values { |value| mustache_replace(value) }
  end

  private

  def validate_variable_names!
    variables.keys.reject { |name| variable_name_ok?(name) }.each do |name|
      raise Error.new("variable name '#{name}' invalid must only contain [A-Za-z0-9_] can not be _")
    end
  end

  def environment_variables_replace!
    # @variables.transform_values do |value|
    #   if match = value.match(/^\s*\$\{(#{VALID_VARIABLE_NAME})\}\s*$/)
    #     get_os_environment_variable_value(match[1])
    #   else
    #     value
    #   end
    # end
    variables.keys.each do |name|
      value = variables[name]

      if match = value.match(/^\s*\$\{(#{VALID_VARIABLE_NAME})\}\s*$/)
        os_env_name = match[1]
        variables[name] = get_os_environment_variable_value(os_env_name)
      end
    end
  end

  def variable_name_ok? name
    return false if name == '_'  # see man bash _ not valid env variable name
    return true if name.match(/^#{VALID_VARIABLE_NAME}$/)
    false
  end

  def mustache_replace value
    regex = /(\{\{#{VALID_VARIABLE_NAME}\}\})/

    value.split(regex).map do |part|
      match = part.match(/^\{\{(#{VALID_VARIABLE_NAME})\}\}$/)
      match ? mustache_get_variable_value(match[1]) : part
    end.join
  end

  def mustache_get_variable_value name
    return variables[name] if variables.has_key?(name)

    raise Error.new("variable name '#{name}' not defined")
  end

  def get_os_environment_variable_value os_env_name
    return ENV[os_env_name] if ENV.has_key?(os_env_name)

    raise Error.new("OS Environment variable '#{os_env_name}' not defined/set")
  end

end