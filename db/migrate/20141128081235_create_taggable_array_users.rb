class CreateTaggableArrayUsers < ActiveRecord::Migration
  def change
    create_table :taggable_array_users do |t|
      t.string :name
      t.string :skills, array: true, default: '{}'

      t.timestamps
    end
    add_index :taggable_array_users, :skills, using: 'gin'
  end
end
