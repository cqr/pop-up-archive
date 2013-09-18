class ChangeTimeToTimestamp < ActiveRecord::Migration
  def up
    # time_to_timestamp(:audio_files, :deleted_at)
    time_to_timestamp(:items, :deleted_at)
    time_to_timestamp(:collections, :deleted_at)
    time_to_timestamp(:audio_files, :transcoded_at)
  end

  def down
    change_column :audio_files, :deleted_at, :time
    change_column :items,       :deleted_at, :time
    change_column :collections, :deleted_at, :time

    change_column :audio_files, :transcoded_at, :time
  end

  def time_to_timestamp(tbl, col)
    add_column tbl, "#{col}_t2t_tmp", :timestamp
    execute "update #{tbl} set #{col}_t2t_tmp = (date '2013-09-01 ' + #{col}) where #{col} is not null"
    remove_column tbl, col
    rename_column tbl, "#{col}_t2t_tmp", col
  end

end
