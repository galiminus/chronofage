class CreateRunnerTable < ActiveRecord::Migration[5.0]
  def change
    create_table :chronofage_runners do |t|
      t.string   :queue_name
      t.string   :host

      t.timestamps
    end
  end
end
