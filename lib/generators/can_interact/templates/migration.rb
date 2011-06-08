# encoding: utf-8
class CreateInteractions < ActiveRecord::Migration
  def change
    create_table :interactions do |t|
      t.integer :initiator_id,   null: false # Инициатор взаимодействия
      t.string  :initiator_type, null: false
      t.integer :target_id,      null: false # Цель
      t.string  :target_type,    null: false
      t.string  :action,         null: false # Действие
      t.text    :params                      # Параметры
      t.timestamps
    end

    add_index :interactions, [ :initiator_id, :initiator_type ]
    add_index :interactions, [ :target_id, :target_type ]
    add_index :interactions, :action
  end
end