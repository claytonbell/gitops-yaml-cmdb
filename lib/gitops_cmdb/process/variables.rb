require 'active_support'
require 'active_support/core_ext/object/blank'

class GitopsCmdb::Process::Variables
  class Error < StandardError; end

  attr_reader :data, :variables

  # root kety name for variable definitions
  VARIABLES_KEY = 'variables'

  VALID_VARIABLE_NAME = /[A-Za-z0-9_]+/

  def self.translate data
    self.new(data).translate
  end

  def initialize data
    @data = data
    @variables = @data.delete(VARIABLES_KEY)
    validate_variable_names!
    environment_variables_replace!
  end

  def translate
    return data if variables.nil?

    data.map do |key,value|
      [ key, mustache_replace(value) ]
    end.to_h
  end

  private

  def validate_variable_names!
    return if variables.nil?

    variables.keys.reject { |name| variable_name_ok?(name) }.each do |name|
      raise Error.new("variable name '#{name}' invalid must only contain [A-Za-z0-9_] can not be _")
    end
  end

  def environment_variables_replace!
    return if variables.nil?

    variables.keys.each do |name|
      value = variables[name]

      match = value.match(/^\s*\$\{(#{VALID_VARIABLE_NAME})\}\s*$/)

      if match
        os_env_name = match[1]
        variables[name] = get_os_environment_variable_value(match[1])
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

    r = value.split(regex).map do |part|
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