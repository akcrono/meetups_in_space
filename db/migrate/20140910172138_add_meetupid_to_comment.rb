class AddMeetupidToComment < ActiveRecord::Migration
  def change
    add_column :comments, :meetup_id, :integer
  end
end
