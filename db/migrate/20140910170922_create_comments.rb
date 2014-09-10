class CreateComments < ActiveRecord::Migration
  def change
    create_table :comments do |table|
      table.integer :user_id, null: false
      table.text :comment_body, null: false

      table.timestamps
    end
  end
end
