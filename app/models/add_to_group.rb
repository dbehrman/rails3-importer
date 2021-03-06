class AddToGroup
  @queue = :add_to_group

  def self.perform(user_id, group_uuid = nil)
    user = Member.find(user_id)
    client = AllPlayers::Client.new(ENV["HOST"])
    client.add_headers({:Authorization => ActionController::HttpAuthentication::Basic.encode_credentials(ENV["ADMIN_EMAIL"], ENV["ADMIN_PASSWORD"])})
    client.add_headers({:NOTIFICATION_BYPASS => 1, :API_USER_AGENT => 'AllPlayers-Import-Client'})
    begin
      raise 'No group specified.' unless user.group_name
      group = Group.where(:uuid => user.group_uuid).first if user.group_uuid
      group = Group.where(:name => user.group_name).first unless user.group_uuid
      raise 'Group not found.' unless group
      raise 'No role specified.' unless (user.roles && !user.roles.empty?)
      group_uuid ||= group.uuid
      user.roles.each do |role|
        client.user_join_group(group_uuid, user.uuid, role.strip, {:should_pay => 0})
      end
      user.assign_submission
    rescue => e
      user.err = e.to_s
      user.status = 'Error adding user to group.'
    else
      user.status = 'User added to group.'
      user.err = ''
    end

    user.save
  end

end
