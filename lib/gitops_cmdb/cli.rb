require 'optimist'

# parse command line options
# - the entire yaml is processed via GitopsCmdb
# - this CLI code filters the final result
class GitopsCmdb::CLI
  class Error < StandardError; end

  attr_reader :option

  def initialize options = nil
    @option = options || parse_command_line
    @formatter = GitopsCmdb::OutputFormatter.new(@option[:format])
  end

  def run
    @formatter.as_string(
      GitopsCmdb.file_load(option[:input])
    )
  end

  private

  # rubocop:disable Metrics/MethodLength
  def parse_command_line
    Optimist.options do
      version '1.0'
      banner <<~'HELP_BANNER'
        gitops-yaml-cmdb

        Usage: gitops-yaml-cmdb --input PATH [--format FMT]
                  [--get key ...] [--override key=value ...]
                  [--exec]

        Options:
        HELP_BANNER

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
        required: false, multi: true, type: :string, short: :none
      )
      opt(
        :format,
        'Output format must be one of: yaml, json, bash, bash-export',
        required: false, default: 'yaml', type: :string, short: :none
      )
      opt(
        :exec,
        'Execute a command with the environment variables setup.',
        required: false, type: :string, short: :none
      )
    end
  end
  # rubocop:enable Metrics/MethodLength
end
