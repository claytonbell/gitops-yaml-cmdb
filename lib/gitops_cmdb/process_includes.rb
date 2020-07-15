require 'active_support/core_ext/hash'
require 'pathname'

class GitopsCmdb
  # Sample config
  #
  # ```yaml
  # include:
  #   - file1.yaml
  #   - file2.yaml
  #
  # key: value
  # ```
  #
  # This class handles
  # - recursive loading of files from the include: key
  # - each yaml file must be a hash at the root
  # - files are hash deep merged
  # - keys in the current file override keys in the included files
  # - keys in the first include override keys further down the list
  #
  # include: key is removed from the final result
  class ProcessIncludes
    class Error < StandardError; end

    INCLUDE_KEY_NAME = 'include'.freeze

    def self.recursive_load path
      data = GitopsCmdb::DataLoader.file path
      include_list = data.delete(INCLUDE_KEY_NAME)

      return data unless include_list

      include_list.each do |included_path|
        follow_this_path = path_relative_to(path, included_path)
        data = recursive_load(follow_this_path).deep_merge(data)
      end

      data
    end

    def self.path_relative_to(reference_file, relative_file)
      if Pathname.new(relative_file).absolute?
        message = [
          'Include paths must not be absolute.',
          "Path '#{relative_file}' invalid.",
          "Found in file '#{reference_file}'"
        ].join(' ')

        raise(Error, message)
      end

      dirname = File.dirname(reference_file)
      File.join(dirname, relative_file)
    end
  end
end
