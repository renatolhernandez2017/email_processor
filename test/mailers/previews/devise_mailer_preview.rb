class DeviseMailerPreview < ActionMailer::Preview
  def invitation_instructions
    DeviseMailer.invitation_instructions(User.all.sample, "faketoken")
  end
end
