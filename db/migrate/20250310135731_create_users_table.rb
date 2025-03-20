class CreateUsersTable < ActiveRecord::Migration[6.1]
  def change
    create_table :users do |t|
      t.string :google_id
      t.string :name
      t.string :email
      t.string :avatar_url
      t.integer :person_id
      
      t.timestamps
    end
  end
end
