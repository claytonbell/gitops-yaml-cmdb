require 'yaml'

class GitopsCmdb
  # read and parse a yaml file
  class DataLoader
    class Error < StandardError; end

    def self.file path
      unless path.end_with?('.yml') || path.end_with?('.yaml')
        raise(
          Error,
          "File name '#{path} error.  Files must be YAML and have extension of .yaml or .yml"
        )
      end

      YAML.safe_load(
        File.readlines(path).join("\n")
      )
    end
  end
end
