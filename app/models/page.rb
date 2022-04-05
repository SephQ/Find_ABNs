class Page < ActiveRecord::Base
  # http://axlsx.blog.randym.net/2012/08/excel-on-rails-like-pro-with-axlsxrails.html
  # acts_as_xlsx  # Error: 2022-04-05T04:57:08.490342+00:00 app[web.1]: /app/vendor/bundle/ruby/3.1.0/gems/activerecord-7.0.2.3/lib/active_record/dynamic_matchers.rb:22:in `method_missing': undefined local variable or method `acts_as_xlsx' for Page:Class (NameError)
end