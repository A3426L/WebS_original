class CreatePersonRecordsTable < ActiveRecord::Migration[6.1]
  def change
    create_table :person_records do |t|
      t.integer :person_id
      t.string :person_record_id
      
      t.timestamps
    end
  end
end
