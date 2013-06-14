class CreateTasks < ActiveRecord::Migration
  def change
    create_table :tasks do |t|
      t.references :owner, :polymorphic => true
      t.string :identifier
      t.string :name
      t.string :status
      t.hstore :extras

      t.timestamps
    end
    add_index :tasks, [:owner_id, :owner_type]
    add_index :tasks, :identifier
  end
end
