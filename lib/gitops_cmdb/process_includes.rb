require 'active_support/core_ext/hash'
require 'pathname'

class GitopsCmdb::ProcessIncludes
  class Error < StandardError; end

  INCLUDE_KEY_NAME = 'include'

  def self.recursive_load path
    data = GitopsCmdb::DataLoader.file path
    include_list = data.delete(INCLUDE_KEY_NAME)

    return data unless include_list

    include_list.each do |included_path|
      follow_this_path = path_relative_to(path,included_path)
      data = recursive_load(follow_this_path).deep_merge(data)
    end

    data
  end

  def self.path_relative_to(reference_file, relative_file)
    if Pathname.new(relative_file).absolute?
      raise Error.new(
        [
          "Include paths must not be absolute.",
          "Path '#{relative_file}' invalid.",
          "Found in file '#{reference_file}'"
        ].join("  ")
      )
    end

    dirname = File.dirname(reference_file)
    File.join(dirname, relative_file)
  end

end