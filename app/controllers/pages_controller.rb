class PagesController < ApplicationController
  def home
    # if params[:list] && params[:list] == "DONE"
    #   #Skip - already taken in data and have now finished getting ABNS into @allabns
    # else
    @emailthreshold = 21    # If the input list is 21 sites or longer, results are emailed.
    @sptext = params[:list] ? params[:list] : ""
    @splist = @sptext.split(/[\r\n]+/)    # An array of line-separated strings from input
    @email = params[:email] && params[:email][/^[\w\.]+@[^\.]+\..+$/] ?
      params[:email] : "operations@strataenergyservices.com.au" # Use default email if none given or improper email given
    @state = params[:state] && params[:state][/^(NSW|QLD|SA|NT|ACT|VIC|TAS|WA)$/i] ?
      params[:state].upcase : "" # Use all states if none given or improper state given
    p @splist   # Print to stdout for debugging if errors occur.
    
    @email_sent = !!(params[:commit] && @splist.size >= @emailthreshold)  # Email was sent. Need to tell user to wait, not re-submit
    
    @url0 = "https://abr.business.gov.au/Search/ResultsActive?SearchText="
    @allabns = []
    p ['debug #SP,  SP =   ', @splist.size, @splist]
    @allabns = helpers.abnlist(@splist, @state) if @splist != [] && @splist.size < @emailthreshold    # If the list is too long, then we will email from within the view - after GETting the page first (to avoid Heroku timeouts)
    # https://stackoverflow.com/questions/12956661/controller-action-to-delayed-job
    # PagesController.delay.abnlist(@splist) if @splist != []
    # https://github.com/caxlsx/caxlsx_rails
    # respond_to do |format|
    #   format.xlsx {
    #     send_data Page.to_xlsx.to_stream.read, :filename => 'pages.xlsx', :type => "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet"
    # }
    # end
    # root_path(format: "xlsx")
    # end

    # Mailing tests
    # AbnMailer.welcome('sfreer@strataenergyservices.com.au','test email for sfreer ABN','').deliver_now
    # AbnMailer.email_abns( @email,'test email for ABN', @allabns).deliver_now if @allabns != [] && @splist.size >= @emailthreshold
    # TaskLoggerJob.email_job(@email,@splist,@state,@emailthreshold)#.perform
    # AbnMailer.email_abns( @email,'', @allabns = helpers.abnlist(@splist, @state)).deliver_now if @splist != [] && @splist.size >= @emailthreshold
    AbnWorker.perform_async(@email,@splist,@state,@emailthreshold) if @splist.size >= @emailthreshold
  end
  def ABN_email
    # Link to optionally email manually (not the automated one for longer lists)
    email = params[:email]
    if params[:splist]
      splist = params[:splist]
    else
      @sptext = params[:list] ? params[:list] : ""
      splist = @sptext.split(/[\r\n]+/)    # An array of line-separated strings from input
    end
    in_state = params[:state]
    emailthreshold = 0      # No threshold, manual request
    AbnWorker.perform_async(email, splist, in_state, emailthreshold)
    redirect_to root_path(params.permit(:list,:email,:splist,:state,:emailthreshold,:abns,:commit)) # Take them back home with the params they had
  end
  def index
    # https://medium.com/@igor_marques/exporting-data-to-a-xlsx-spreadsheet-on-rails-7322d1c2c0e7
    @users =  User.all

    respond_to do |format|
      format.html
      format.xlsx
    end
  end
  # Commenting these out and moving them all to pages_helper.rb since they are helper methods really
  # def ABN_export
  #   @allabns = params[:abns] ? eval(params[:abns]) : [] # :abns parameter is passed when clicking the "Export to Excel" link on the home page
  #   # https://github.com/caxlsx/caxlsx_rails
  #   respond_to do |format|
  #     format.xlsx
  #   end
  #   # render xlsx: "ABN_export", disposition: 'inline'
  # end
  # def abnlist(list)
  # # def self.abnlist(list)
  #   list.map{|i| i = i[/\d+/] if i[/Owners|Trust/i] && i[/\d+/] # Long names including 'The Owners of...' are reduced to just numbers
  #     prefix_rgx = /^((SP|DP|UP|CTS|SC)|(Strata|Units?|Deposited|Community) *(Plan|Title( Scheme)?|Scheme)) *(?=\d)/i
  #     @num = i.gsub(prefix_rgx, '')
  #     p [i,@num,@url0]
  #     url = @url0 + @num
  #     if i[/SP|STRATA|S P /i]
  #       url2 = @url0 + (@num[/DP|UP/] ? @num.gsub(/DP|UP/,'') : 'SP' + @num)
  #       url4 = @url0 + (@num[/DP|UP/] ? @num.gsub(/DP|UP/){($&[?D]? 'DEPOSITED': 'UNIT') + 'PLAN'} : 'STRATAPLAN' + @num)
  #     else
  #       url2, url4 = nil, nil
  #     end
  #     url3 = @url0 + 'PLAN' + @num
  #       ## .compact will remove the nils (url2, url4) if the site isn't a Strata Plan (saves time).
  #     [url,url2,url3,url4].compact.find{ abnfetch(_1) != [] }
  #     }
  #     @allabns
  # end
  # def abnfetch(url)
  #   res = URI.open(url).read  # HTML of all results
  #   inp = Nokogiri::HTML(res).search('input') # All <input ...> tags
  #   @abns = []
  #   #puts inp.inspect,?-*100,inp.size
  #   #inp = inp[30..]
  #   #puts res
  #   #puts inp.map{_1.values.join(' ')}.inspect
  #   inp.map{|tag| data = tag.values.join(' ').scan(/(\d\d \d{3} \d{3} \d{3}).*?active,([^,]+)\s{3,}.*?y Name,,(\d{4}) +?(\w{3})/).map{_1.map &:rstrip}[0]
  #   abn, name, pc, state = data
  #   #warn [tag.values.join(' '),abn, name, pc, state].to_s
  #   @abns << [name,abn,state,pc] }
  #   # p [@abns+['all']+@allabns]
  #   @abns -= [[],[[],[]]]
  #   #p @abns
  #   out = @abns.select!{_1&&_1[0]&&_1[0][/(?<!\d)#{@num}(?!\d)/]}
  #   @allabns += @abns
  #   @abns
  # end
end