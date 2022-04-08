class ApplicationMailer < ActionMailer::Base
  # default from: "noreply@strataenergyservices.com.au"
  default from: "ses.abns@gmail.com"
  # layout "mailer"  # Missing template layouts/mailer with {:locale=>[:en] -> I had the same problem, and it seemed to work for me if I commented out the layout 'mailer' line in application_mailer
  # https://stackoverflow.com/questions/38398611/missing-template-layouts-mailer-with-locale-en-formats-html
end
