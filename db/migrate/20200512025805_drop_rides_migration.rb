class DropRidesMigration < ActiveRecord::Migration[6.0]
  def up
    drop_table :rides
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
