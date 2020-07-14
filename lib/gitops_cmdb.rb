class GitopsCmdb
  class Error < StandardError; end

  def self.file_load path
    ProcessVariables.translate(
      ProcessIncludes.recursive_load(path)
    )
  end
end

require 'gitops_cmdb/cli'
require 'gitops_cmdb/output_formatter'
require 'gitops_cmdb/data_loader'
require 'gitops_cmdb/process_includes'
require 'gitops_cmdb/process_variables'