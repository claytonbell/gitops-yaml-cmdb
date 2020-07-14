class GitopsCmdb
  class Error < StandardError; end

  def self.file_load path
    Process::Variables.translate(
      Process::Includes.recursive_load(path)
    )
  end
end

require 'gitops_cmdb/cli'
require 'gitops_cmdb/output_formatter'
require 'gitops_cmdb/data_loader'
require 'gitops_cmdb/process'
require 'gitops_cmdb/process/includes'
require 'gitops_cmdb/process/variables'