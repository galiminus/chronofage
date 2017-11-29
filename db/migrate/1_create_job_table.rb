class CreateJobTable < ActiveRecord::Migration[5.0]
  def change
    create_table :chronofage_jobs do |t|
      t.string     :job_class
      t.string     :job_id
      t.string     :queue_name
      t.text       :arguments
      t.integer    :priority

      t.string     :host
      t.text       :stdout
      t.text       :stderr

      t.datetime   :started_at
      t.datetime   :completed_at
      t.datetime   :failed_at

      t.timestamps
    end
  end
end
