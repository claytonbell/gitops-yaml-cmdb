require 'yaml'
require 'uri/file'

class GitopsCmdb::DataLoader
  class Error < StandardError; end

  def self.file path
    raise Error unless file_extension_supported?(path)

    YAML.safe_load(
      File.readlines(path).join("\n")
    )
  end

  def self.uri uri_string
    uri = URI(uri_string)

    raise Error unless uri.scheme == 'file'

    file(uri.host + uri.path)
  end

  private_class_method

  def self.file_extension_supported? path
    path.end_with?('.yml') || path.end_with?('.yaml')
  end
end