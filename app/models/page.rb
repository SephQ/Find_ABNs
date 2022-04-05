class Page < ActiveRecord::Base
  # http://axlsx.blog.randym.net/2012/08/excel-on-rails-like-pro-with-axlsxrails.html
  acts_as_xlsx
end