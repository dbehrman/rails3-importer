class GetSubgroupsMembers
  @queue = :get_subgroups_members

  def self.perform(group_id)
    group = Group.find(group_id)
    group_admin = Admin.where(:uuid => group.user_uuid).first
    client = AllPlayers::Client.new(ENV["HOST"])
    client.prepare_access_token(group_admin.token, group_admin.secret, ENV["OMNIAUTH_PROVIDER_KEY"], ENV["OMNIAUTH_PROVIDER_SECRET"])
    admin_client = AllPlayers::Client.new(ENV["HOST"])
    admin_client.add_headers({:Authorization => ActionController::HttpAuthentication::Basic.encode_credentials(ENV["ADMIN_EMAIL"], ENV["ADMIN_PASSWORD"])})
    begin
      members = client.group_members_list(group.uuid, nil, {:limit => 0})
      members.each do |member|
        u = admin_client.user_get(member['uuid'])
        m = Member.find_or_create_by({:admin_uuid => group_admin.uuid, :email => u['email'], :uuid => member['uuid'], :gender => u['gender'], :first_name => u['firstname'], :last_name => u['lastname'], :birthday => u['birthday'], :group_name => group.name, :group_uuid => group.uuid, :status => 'AllPlayers'})
        if group.org_webform_uuid
          m.get_submission(group.org_webform_uuid)
        end
      end
      @subgroups = []
      self.get_subgroups(group.uuid)
      @subgroups.each do |subgroup|
        subgroup.get_group_members
      end
    rescue => e
      group.err = e.to_s
      group.status = 'Error getting members'
    else
      group.err = nil
      group.status = 'Members synched'
    end

    group.save
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
