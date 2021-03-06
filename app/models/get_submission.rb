class GetSubmission
  @queue = :get_submission

  def self.perform(user_id)
    user = Member.find(user_id)
    admin = Admin.where(:uuid => user.admin_uuid).first
    client = AllPlayers::Client.new(ENV["HOST"])
    client.add_headers({:Authorization => ActionController::HttpAuthentication::Basic.encode_credentials(ENV["ADMIN_EMAIL"], ENV["ADMIN_PASSWORD"])})
    begin
      group = Group.where(:uuid => user.group_uuid).first if user.group_uuid
      group = Group.where(:name => user.group_name).first unless user.group_uuid
      raise 'Group Not Found' unless group
      raise 'No org webform to get submission' unless group.org_webform_uuid
      submission = client.get_submission(group.org_webform_uuid, nil, nil, {'first_name' => user.first_name, 'last_name' => user.last_name, 'birthday' => Date.parse(user.birthday).to_s})
      user.update_attributes(:submission_id => submission['sid'])
    rescue => e
      user.status = 'Error getting user webform submission'
      user.err = e
    else
      unless submission.nil?
        if submission['uuid'] == user.uuid
          user.status = 'Webform assigned'
        else
          user.status = 'Unassigned submission'
        end
      end
      user.err = ''
    end

    user.save
  end

end
