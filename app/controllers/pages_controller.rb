class PagesController < ApplicationController
  def home
    # if params[:list] && params[:list] == "DONE"
    #   #Skip - already taken in data and have now finished getting ABNS into @allabns
    # else
    @emailthreshold = 21    # If the input list is 21 sites or longer, results are emailed.
    @sptext = params[:list] ? params[:list] : ""
    @splist = @sptext.split(/[\r\n]+/)    # An array of line-separated strings from input
    @splist = @splist.uniq.select{|i| i[/\S/] } # ignore the duplicates and blank lines (waste of http requests)
    @email = params[:email] && params[:email][/^[\w\.]+@[^\.]+\..+$/] ?
      params[:email] : "operations@strataenergyservices.com.au" # Use default email if none given or improper email given
    @filename = params[:filename] && params[:filename][/^[\w\- ]+$$/] ?
      params[:filename] : "ABN_export" # Use default filename if none given or improper filename given
    @state = params[:state] && params[:state][/^(NSW|QLD|SA|NT|ACT|VIC|TAS|WA)$/i] ?
      params[:state].upcase : "" # Use all states if none given or improper state given
    p @splist   # Print to stdout for debugging if errors occur.
    
    @email_sent = !!(params[:commit] && @splist.size >= @emailthreshold)  # Email was sent. Need to tell user to wait, not re-submit
    
    @url0 = "https://abr.business.gov.au/Search/ResultsActive?SearchText="
    @allabns = []
    p ['debug #SP,  SP =   ', @splist.size, @splist]
    @allabns = helpers.abnlist(@splist, @state) if @splist != [] && @splist.size < @emailthreshold    # If the list is too long, then we will email from within the view - after GETting the page first (to avoid Heroku timeouts)
    # Mailing tests
    # AbnMailer.email_abns( @email,'test email for ABN', @allabns).deliver_now if @allabns != [] && @splist.size >= @emailthreshold
    # TaskLoggerJob.email_job(@email,@splist,@state,@emailthreshold)#.perform
    # AbnMailer.email_abns( @email,'', @allabns = helpers.abnlist(@splist, @state)).deliver_now if @splist != [] && @splist.size >= @emailthreshold
    AbnWorker.perform_async(@email,@filename,@splist,@state,@emailthreshold) if @splist.size >= @emailthreshold
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
    filename = params[:filename] ? params[:filename] : "ABN_export"
    emailthreshold = 0      # No threshold, manual request
    AbnWorker.perform_async(email, filename, splist, in_state, emailthreshold)
    redirect_to root_path(params.permit(:list,:email,:splist,:state,:emailthreshold,:abns,:commit,:filename)) # Take them back home with the params they had
  end
  def index
    # https://medium.com/@igor_marques/exporting-data-to-a-xlsx-spreadsheet-on-rails-7322d1c2c0e7
    @users = User.all

    respond_to do |format|
      format.html
      format.xlsx
    end
  end
  def dummyemail
    # Debugging test. Send a dummyemail without background job and include the environment it was sent in
    prod = Rails.env.production? ? 'Production' : 'Local/Development'
    p prod
    AbnMailer.email_test('sfreer@strataenergyservices.com.au',"", "Test email sent in #{prod} for debugging.").deliver_now
  end
end