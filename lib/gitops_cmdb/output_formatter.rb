require 'json'
require 'yaml'

class GitopsCmdb
  # Given a hash object, serialize
  # to a string representation
  #
  # yaml, json, bash, bash-expot
  #
  # yaml & json are "obvious"
  #
  # bash emits a string that can be eval-ed in bash to
  # set environment variables.
  #
  # bash-export is simmilar to bash, but it adds the
  # 'export' keyword to each bash variable assignment.
  class OutputFormatter
    class Error < StandardError; end

    attr_reader :format

    FORMATTER_MAP = {
      'yaml' => :output_yaml,
      'json' => :output_json,
      'bash' => :output_bash,
      'bash-export' => :output_bash,
      'keys' => :output_keys
    }.freeze

    def self.supported_types
      FORMATTER_MAP.keys
    end

    def initialize format_kind
      @format = format_kind
      raise(Error, help) unless valid?
    end

    def render data
      send(FORMATTER_MAP[format], data)
    end

    private

    def valid?
      FORMATTER_MAP.keys.include?(format)
    end

    def help
      "format '#{format}' invalid must be one of: #{FORMATTER_MAP.keys.join(' ')}"
    end

    def output_yaml data
      data.to_yaml
    end

    def output_json data
      data.to_json
    end

    def output_bash data
      export = format == 'bash-export' ? 'export ' : ''

      data.map do |key, value|
        "#{export}#{escape_key(key)}='#{escape_value(value.to_s)}'"
      end.join("\n")
    end

    def escape_key key
      key.gsub(/[^A-Za-z0-9_]/, '_')
    end

    def escape_value value
      value.gsub(/'/) { |quote| "\\#{quote}" }
    end

    def output_keys data
      data.keys.sort.join("\n")
    end
  end
end
