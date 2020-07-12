class GitopsCmdb
  class Error < StandardError; end

  def self.read path
    raise NotImplementedError
  end
end

require 'gitops_cmdb/cli'
require 'gitops_cmdb/data_loader'
require 'gitops_cmdb/process'
require 'gitops_cmdb/process/includes'
require 'gitops_cmdb/process/variables'