require 'active_support'
require 'active_support/core_ext/object/blank'

class GitopsCmdb
  # Sample config
  #
  # ```yaml
  # variables:
  #   STATIC: blah
  #   OS_ENV: ${OS_ENV}
  # key1: The value of STATIC is {{STATIC}}
  # key2: The value of OS_ENV is {{OS_ENV}}
  # ```
  #
  # This class handles
  # - registering variable names (the keys of variables:)
  # - substituting ${} environment variables with the OS environment value
  # - replacing {{ }} mustache variables in the data keys
  #
  # variables: key is removed from the final result
  class ProcessVariables
    class Error < StandardError; end

    attr_reader :data, :variables

    # root key name for variable definitions
    VARIABLES_KEY = 'variables'.freeze

    VALID_VARIABLE_NAME = /[A-Za-z_][A-Za-z0-9_]*/.freeze

    def self.translate data, override_variables = {}
      new(data, override_variables).translate
    end

    def initialize data, override_variables
      @data = data
      @variables = @data.delete(VARIABLES_KEY) || {}
      prepare_variables(override_variables)
    end

    def translate
      deep_translate(data)
    end

    private

    # recursively traverse hash and replace values with
    # mustache evaluated values
    def deep_translate(a_hash)
      a_hash.transform_values do |value|
        case value
        when Hash
          deep_translate(value)
        when String
          mustache_replace(value)
        else
          value.to_s
        end
      end
    end

    def prepare_variables(override_variables)
      raise(Error, "variables '#{VARIABLES_KEY}' must be a hash, got #{@variables.class}") unless @variables.is_a?(Hash)

      @variables.merge!(override_variables)
      convert_variables_to_string_type
      validate_variable_names!
      substitute_os_environment_variables!
    end

    def convert_variables_to_string_type
      @variables = @variables.map do |key, value|
        [key.to_s, value.to_s]
      end.to_h
    end

    def validate_variable_names!
      variables.keys.reject { |name| variable_name_ok?(name) }.each do |name|
        raise(Error, "variable name '#{name}' invalid must only contain [A-Za-z0-9_] can not be _")
      end
    end

    def variable_name_ok? name
      return false if name == '_' # see man bash _ not valid env variable name

      return true if name.match(/^#{VALID_VARIABLE_NAME}$/)

      false
    end

    def substitute_os_environment_variables!
      @variables.transform_values! do |value|
        replace_match_with(value, regex_environment_variable_name) do |env_var_name|
          get_os_environment_variable_value(env_var_name)
        end
      end
    end

    def mustache_replace value
      value.split(regex_mustache).map do |part|
        replace_match_with(part, regex_mustache_variable_name) do |variable_name|
          get_variable_value(variable_name)
        end
      end.join
    end

    def replace_match_with string, regex
      # TODO: assumption that regex contains at least one capture group ()
      match = string.match(regex)
      match ? yield(match[1]) : string
    end

    def get_variable_value name
      return variables[name] if variables.key?(name)

      raise(Error, "variable name '#{name}' not defined")
    end

    def get_os_environment_variable_value os_env_name
      return ENV[os_env_name] if ENV.key?(os_env_name)

      raise(Error, "OS Environment variable '#{os_env_name}' not defined/set")
    end

    def regex_mustache
      /(\{\{\s*#{VALID_VARIABLE_NAME}\s*\}\})/.freeze
    end

    def regex_mustache_variable_name
      /^\{\{\s*(#{VALID_VARIABLE_NAME})\s*\}\}$/.freeze
    end

    def regex_environment_variable_name
      /\$\{\s*(#{VALID_VARIABLE_NAME})\s*\}/.freeze
    end
  end
end
