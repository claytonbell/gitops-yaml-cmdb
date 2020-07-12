require 'optimist'
require 'yaml'
require 'json'

class GitopsCmdb::CLI
  class Error < StandardError; end

  attr_reader :option

  def initialize options = nil
    @option = options || parse_command_line
  end

  def run
    valid_command_line?
    @result = GitopsCmdb.file_load(option[:input])

    self.send(format_map[format])
  end

  private

  def parse_command_line
    Optimist::options do
      version '1.0'
      banner <<-HelpBanner
gitops-yaml-cmdb

Usage
  gitops-yaml-cmdb --input PATH [--get key ...] [--override key=value ...]
     [--format FMT]

HelpBanner

      opt(
        :input,
        'YAML file to load',
        required: true, type: :string, short: :none
      )
      opt(
        :get,
        'Specific key to from the YAML file.  Defaults to all keys',
        required: false, type: :string, multi: true
      )
      opt(
        :override,
        'Override a specific value',
        required: false, multi: true, short: :none
      )
      opt(
        :format,
        'Output format must be one of: yaml, json, bash, bash-export',
        required: false, default: 'yaml', type: :string, short: :none
      )
      opt(
        :exec,
        'Execute a command with the environment variables setup.',
        required: false, type: :boolean, short: :none
      )
    end
  end

  def valid_command_line?
    raise Error.new(format_help) unless format_valid?
  end

  def format_valid?
    format_map.keys.include?(format)
  end

  def format_help
    "format '#{format} invalid must be one of: #{format_map.keys.join(' ')}"
  end

  def format
    @option[:format]
  end

  def format_map
    {
      "yaml" => :format_to_yaml,
      "json" => :format_to_json,
      "bash" => :format_to_bash,
      "bash-export" => :format_to_bash
    }
  end

  def format_to_yaml
    @result.to_yaml
  end

  def format_to_json
    @result.to_json
  end

  def format_to_bash
    export = format=='bash-export' ? 'export ' : ''
    @result.each.map do |key,value|
      key = key.gsub(/[^A-Za-z0-9_]/,'_')
      value = value.gsub(/\'/, '\\\'')
      "#{export}#{key}='#{value}'"
    end.join("\n")
  end

end
