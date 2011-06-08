# encoding: utf-8
module CanInteract
  class Engine < Rails::Engine
    initializer "chrno_can_interact.initialize" do
      # Загрузка расширения в AR
      ActiveSupport.on_load( :active_record ) do
        puts "--> load can_interact"
        extend CanInteract::ARExtension
      end
    end
  end
end