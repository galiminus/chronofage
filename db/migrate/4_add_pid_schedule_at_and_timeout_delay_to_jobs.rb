class AddPidScheduleAtAndTimeoutDelayToJobs < ActiveRecord::Migration[5.0]
  def change
    add_column :chronofage_jobs, :pid, :string
    add_column :chronofage_jobs, :scheduled_at, :datetime
    add_column :chronofage_jobs, :timeout_delay, :integer
  end
end
