class RemoveFromGroupAndSubgroups
  @queue = :remove_from_group_and_subgroups

  def self.perform(user_id)
    user = Member.find(user_id)
    admin = Admin.where(:uuid => user.admin_uuid).first
    client = AllPlayers::Client.new(ENV["HOST"])
    client.add_headers({:Authorization => ActionController::HttpAuthentication::Basic.encode_credentials(ENV["ADMIN_EMAIL"], ENV["ADMIN_PASSWORD"])})
    client.add_headers({:NOTIFICATION_BYPASS => 1, :API_USER_AGENT => 'AllPlayers-Import-Client'})
    begin
      raise 'No group specified.' unless user.group_name
      group = Group.where(:name => user.group_name).first
      raise 'Group not found.' unless group
      @subgroups = []
      self.get_subgroups(group.uuid)
      @subgroups.each do |subgroup|
        user.remove_from_group(subgroup.uuid)
      end
      leave = client.user_leave_group(group.uuid, user.uuid)
    rescue => e
      if e.to_s.include?('removed from')
        user.status = 'User removed from group'
        user.err = ''
      else
        user.err = e.to_s
        user.status = 'Error removing user from group'
      end
    else
      user.status = 'User removed from group'
      user.err = ''
    end

    user.save
  end

  def self.get_subgroups(group_uuid)
    @subgroups ||= []

    subgroups = Group.any_of(:groups_above => group_uuid).entries
    return if subgroups.first.nil?
    subgroups.each do |subgroup|
      @subgroups << subgroup
      self.get_subgroups(subgroup.uuid)
    end
  end

end
