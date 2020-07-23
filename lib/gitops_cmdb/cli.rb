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
        GitopsCmdb.file_load(
          option[:input],
          prepend_includes: @option.fetch(:include, []),
          override_variables: parse_override_option
        )
      )
    end

    private

    # rubocop:disable Metrics/MethodLength
    def parse_command_line
      Optimist.options do
        version '1.0'
        banner <<~'HELP_BANNER'

          Usage: gitops-yaml-cmdb --input FILE [--format FMT]
                    [--get key ...] [--override key=value ...]
                    [--include FILE ...] [--exec]

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
          :include,
          "Include additional files, as if they\nwere at the top of the include: list of the input file",
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

    def parse_override_option
      variables = {}

      option[:override].each do |string|
        match = string.match(/^(.+?)=(.*)$/)
        if match
          variables[match[1]] = match[2]
        else
          raise(Error, "override must be of the form 'key=value'.  Unable to parse '#{string}'.")
        end
      end

      variables
    end
  end
end
