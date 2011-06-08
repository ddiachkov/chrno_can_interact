# encoding: utf-8
module CanInteract
  ##
  # Сущность "взаимодействие"
  #
  class Interaction < ActiveRecord::Base
    # Инициатор взаимодействия
    belongs_to :initiator, :polymorphic => true
    # Цель
    belongs_to :target, :polymorphic => true
    # Параметры
    serialize :params

    # Взаимодействия опредённого типа
    scope :with_action, -> name { where( action: name ) }

    # Проверка на сущестование таблицы
    raise "Run `rails g can_interact:install`" unless table_exists?
  end
end