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

    # compute paths relative to current working directory
    class RelativePath
      attr_reader :reference_file, :relative_file

      def self.path_relative_to(reference_file, relative_file)
        new(reference_file, relative_file).to_s
      end

      def initialize reference_file, relative_file
        @reference_file = reference_file
        @relative_file = relative_file
        raise(Error, message) if absolute?
      end

      def to_s
        dirname = File.dirname(reference_file)
        File.join(dirname, relative_file)
      end

      private

      def absolute?
        Pathname.new(@relative_file).absolute?
      end

      def message
        [
          'Include paths must not be absolute.',
          "Path '#{relative_file}' invalid.",
          "Found in file '#{reference_file}'"
        ].join(' ')
      end
    end

    INCLUDE_KEY_NAME = 'include'.freeze

    attr_reader :path

    def self.recursive_load path, additional_includes = []
      new(path).recursive_load(additional_includes)
    end

    def initialize path
      @path = path
    end

    def recursive_load additional_includes = []
      data = GitopsCmdb::DataLoader.file path
      include_list = data.delete(INCLUDE_KEY_NAME) || []

      return data if include_list.empty? && additional_includes.empty?

      paths_to_follow(include_list, additional_includes).each do |follow_this_path|
        data = ProcessIncludes.new(follow_this_path).recursive_load.deep_merge(data)
      end

      data
    end

    private

    def paths_to_follow include_list, additional_includes
      [
        additional_includes,
        include_list.map { |included_path| RelativePath.path_relative_to(path, included_path) }
      ].flatten
    end
  end
end
