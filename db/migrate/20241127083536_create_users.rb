# frozen_string_literal: true

class CreateUsers < ActiveRecord::Migration[7.0]
  def change
    create_table :users do |t|
      t.string :name
      t.string :email
      t.string :password_digest
      t.string :phone_number
      t.integer :role
      t.integer :status
      t.string :provider
      t.string :uid

      t.timestamps
    end
    add_index :users, :email, unique: true
  end
end