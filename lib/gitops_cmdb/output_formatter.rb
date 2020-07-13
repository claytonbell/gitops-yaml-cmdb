require 'json'
require 'yaml'

class GitopsCmdb::OutputFormatter
  class Error < StandardError; end

  attr_reader :format

  def initialize format_kind
    @format = format_kind
    raise Error.new(help) unless valid?
  end

  def as_string data
    self.send(formatter_map[format], data)
  end

  private

  def valid?
    formatter_map.keys.include?(format)
  end

  def help
    "format '#{format}' invalid must be one of: #{formatter_map.keys.join(' ')}"
  end

  def formatter_map
    {
      "yaml" => :output_yaml,
      "json" => :output_json,
      "bash" => :output_bash,
      "bash-export" => :output_bash
    }
  end

  def output_yaml data
    data.to_yaml
  end

  def output_json data
    data.to_json
  end

  def output_bash data
    export = format=='bash-export' ? 'export ' : ''

    data.each.map do |key,value|
      "#{ export }#{ escape_key(key) }='#{ escape_value(value) }'"
    end.join("\n")
  end

  def escape_key key
    key.gsub(/[^A-Za-z0-9_]/,'_')
  end

  def escape_value value
    value.gsub(/'/) { |quote| "\\#{quote}" }
  end
end