require 'gitops_cmdb/output_formatter'
require 'gitops_cmdb/data_loader'
require 'gitops_cmdb/process_includes'
require 'gitops_cmdb/process_variables'

# the public interface for humans and automation to use
#
# see spec/gitops_cmdb_spec.rb for examples
# with descriptions
class GitopsCmdb
  class Error < StandardError; end

  def self.file_load path, options = {}
    new(path, options).load
  end

  def self.hash_load hash, options = {}
    file_load(hash, options)
  end

  def initialize subject, options
    @subject = subject
    @prepend_includes = options.fetch(:prepend_includes, [])
    # @override_variables = options.fetch(:override_variables, [])
  end

  def load
    ProcessVariables.translate(
      ProcessIncludes.recursive_load(@subject, @prepend_includes)
    )
  end
end
