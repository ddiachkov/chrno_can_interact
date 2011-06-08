# coding: utf-8
module CanInteract
  extend ActiveSupport::Autoload

  autoload :ARExtension, "can_interact/ar_extension"
  autoload :VERSION,     "can_interact/version"
end

require "can_interact/engine"