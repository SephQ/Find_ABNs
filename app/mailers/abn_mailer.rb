class AbnMailer < ApplicationMailer
  # https://www.mailgun.com/blog/tips-tricks-avoiding-gmail-spam-filtering-when-using-ruby-on-rails-action-mailer/
  default "Message-ID"=>"<#{Digest::SHA2.hexdigest(Time.now.to_i.to_s)}@mail.gmail.com>"
  # For mailing ABN results to users (Heroku timeout has forced me to think of another way to get the
  # ABNs to users when the list is too long - and without daemonizing the process (#Windows dev issues))
  def email_abns(recipient, filename = "ABN_export", allabns)
    # https://stackoverflow.com/questions/5145870/rails-actionmailer-how-to-send-an-attachment-that-you-create
    # https://guides.rubyonrails.org/v3.0/action_mailer_basics.html
    @allabns = allabns
    # p @allabns, allabns
    xlsx = render_to_string handlers: [:axlsx], formats: [:xlsx], template: "pages/ABN_export"#, locals: {users: users}
    # attachments['ABN_export.xlsx'] = {mime_type: Mime::XLSX, content: xlsx}
    attachments["#{filename}.xlsx"] = {mime_type: Mime[:xlsx], content: xlsx}  # https://github.com/caxlsx/caxlsx_rails/issues/85
    mail(:to => recipient, :subject => "ABN Search Result | Strata Energy Services", :content => "ABN search output")
  end
  def email_test(recipient, content, attachment = "")
    # https://stackoverflow.com/questions/5145870/rails-actionmailer-how-to-send-an-attachment-that-you-create
    # https://guides.rubyonrails.org/v3.0/action_mailer_basics.html
    p 'test starting - dummy email ? ', recipient
    # attachments['ABN_export.xlsx'] = File.read( attachment ) if attachment != ""
    mail(:to => recipient, :subject => "Test Email for ABN Searcher", :content => content)
  end
  def export_example(users)
    # https://www.rubydoc.info/gems/axlsx_rails/0.2.1
    # xlsx = render_to_string handlers: [:axlsx], formats: [:xlsx], template: "users/export", locals: {users: users}
    # attachments["Users.xlsx"] = {mime_type: Mime::XLSX, content: xlsx}
    # ...
  end
end
