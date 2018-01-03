class RenameStdoutAndStderrToOutput < ActiveRecord::Migration[5.0]
  def change
    remove_column :chronofage_jobs, :stdout
    remove_column :chronofage_jobs, :stderr
    add_column :chronofage_jobs, :output, :string
  end
end
