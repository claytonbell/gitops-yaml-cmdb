require 'optimist'

class GitopsCmdb
  # parse command line options
  # - the entire yaml is processed via GitopsCmdb
  # - this CLI code filters the final result
  class CLI
    class Error < StandardError; end

    attr_reader :option

    def initialize options = nil
      @option = options || parse_command_line
      @formatter = GitopsCmdb::OutputFormatter.new(@option[:format])
    end

    def run
      @formatter.render(
        GitopsCmdb.file_load(option[:input])
      )
    end

    private

    # rubocop:disable Metrics/MethodLength
    def parse_command_line
      Optimist.options do
        version '1.0'
        banner <<~'HELP_BANNER'

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
          "Specific data key to get from the YAML file.\nDefaults to all keys",
          required: false, type: :string, multi: true
        )
        opt(
          :override,
          "Override a specific variable value.\nThe variable does not have to be in the variables: list",
          required: false, multi: true, type: :string, short: :none
        )
        opt(
          :format,
          "Output format must be one of:\n#{GitopsCmdb::OutputFormatter.supported_types.join(', ')}",
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
end
