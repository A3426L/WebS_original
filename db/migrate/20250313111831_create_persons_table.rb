class CreatePersonsTable < ActiveRecord::Migration[6.1]
  def change
    create_table :persons do |t|
      t.string :fullname, null: true
      t.string :given_name, null: true
      t.string :family_name, null: true
      t.string :alternate_names, null: true
      t.string :description, null: true
      t.integer :sex, null: true
      t.date :date_of_birth, null: true
      t.integer :age, null: true
      t.string :home_street, null: true
      t.string :home_neighborhood, null: true
      t.string :home_city, null: true
      t.string :home_state, null: true
      t.integer :home_postal_code, null: true
      t.string :home_country, null: true
      t.string :photo_url, null: true
      t.string :profile_urls,null:true
      t.integer :user_id
      t.timestamps
   
    end
  end
end
