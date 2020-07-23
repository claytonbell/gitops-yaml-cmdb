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
        filter_data_by_get_keys(file_load)
      )
    end

    def filter_data_by_get_keys data
      return data if option[:get].empty?

      option[:get].each do |get_key|
        get_error!(get_key) unless data.key?(get_key)
      end

      data.slice( *option[:get] )
    end

    def file_load
      GitopsCmdb.file_load(
        option[:input],
        prepend_includes: @option.fetch(:include, []),
        override_variables: parse_override_option
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
          "Specific data keys to get from the YAML file.\nDefaults to all keys",
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
          required: false, type: :boolean, short: :none
        )
      end
    end
    # rubocop:enable Metrics/MethodLength

    def parse_override_option
      option[:override].map do |string|
        match = string.match(/^(.+?)=(.*)$/)
        override_error!(string) unless match
        [match[1], match[2]]
      end.to_h
    end

    def override_error! string
      raise(Error, "override must be of the form 'key=value'.  Unable to parse '#{string}'.")
    end

    def get_error! key_name
      raise(Error, "data key name '#{key_name}' not found when loading file '#{option[:input]}'")
    end
  end
end
