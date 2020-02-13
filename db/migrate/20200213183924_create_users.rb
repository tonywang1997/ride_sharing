class CreateUsers < ActiveRecord::Migration[6.0]
  def change
    create_table :users do |t|
      t.string :username
      t.string :address
      t.int :age
      t.string :gender

      t.timestamps
    end
  end
end