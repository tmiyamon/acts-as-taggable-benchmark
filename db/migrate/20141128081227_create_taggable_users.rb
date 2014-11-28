class CreateTaggableUsers < ActiveRecord::Migration
  def change
    create_table :taggable_users do |t|
      t.string :name

      t.timestamps
    end
  end
end
