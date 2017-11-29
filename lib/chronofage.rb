require 'active_record'
require 'active_record/version'
require 'active_support/core_ext/module'
require 'active_job/queue_adapters/chronofage_adapter'
require 'chronofage/job'

begin
  require 'rails/engine'
  require 'chronofage/engine'
  rescue LoadError
end

module Chronofage
  extend ActiveSupport::Autoload
end
