class AbnWorker
  include Sidekiq::Worker
  sidekiq_options retry: false
  # https://itnext.io/sidekiq-overview-and-how-to-deploy-it-to-heroku-b8811fea9347
  def perform(email,filename="ABN_export",splist,in_state,emailthreshold)
    @url0 = "https://abr.business.gov.au/Search/ResultsActive?SearchText="
    AbnMailer.email_abns( email,filename, @allabns = abnlist(splist, in_state)).deliver_now if splist != [] && splist.size >= emailthreshold
  end
  def self.email_job(email,splist,in_state,emailthreshold)
    # Old attempt from task_logger_job.rb
    AbnMailer.email_abns( email,'', @allabns = abnlist(splist, in_state)).deliver_now if splist != [] && splist.size >= emailthreshold
  end
  # Adding helpers here because not accessible with helpers.function between enqueuing and processing
  def abnlist(list, in_state = "")
    # def self.abnlist(list)
    list.map{|i| i = i[/\d+(?=\D*$)/] if i[/Owners|Trust/i] && i[/\d+/] # Long names including 'The Owners of...' are reduced to just numbers
      prefix_rgx = /^.*?((SP|DP|UP|CTS|SC|BC|OCP|BCPO?|OCSP|PS|RP)|(Strata|Units?|Deposited|Community) *(Plan|Title( Scheme)?|Scheme)) *(?=\d)/i
      suffix_rgx = /^\d+\S*\K.*$/i
      @num = i.gsub(prefix_rgx, '')   # Remove prefixes to get just the number (if it's in one of the above formats)
      @num = @num.gsub(suffix_rgx, '') if i[prefix_rgx] # Remove suffixes after the number (if it matches a prefix format)
      rawnum = @num[/\d+/]
      p [i,@num,rawnum,'i,@num,rawnum<,>@url0',@url0]
      url2, url3, url4 = nil, nil, nil  # Initialize as nil (means won't be checked unless re-defined below)
      # url is searching for the basic number. url2 searches SP{number}, url3 = PLAN{number}, url4 = STRATAPLAN{number} 
      url = @url0 + @num
      if i[/SP|STRATA|S P /i]
        if i[/ /]
          url2 = @url0 + (@num[/DP|UP/] ? @num.gsub(/DP|UP/,'') : 'SP' + @num)
        else
          url2 = @url0 + i    # If there are no spaces in the name already, then search it as is.
        end
        url4 = @url0 + (@num[/DP|UP/] ? @num.gsub(/DP|UP/){($&[?D]? 'DEPOSITED': 'UNIT') + 'PLAN'} : 'STRATAPLAN' + @num)
      else
        # If it's not an SP/UP/DP but it is mostly numbers with a few letters, try it without the letters.
        url2 = @url0 + rawnum if @num.size != @num.scan(/\d/).size && @num.scan(/\d/).size > @num.size/2
        url4 = @url0 + i unless i[/ /] # Search directly if there are no spaces in the given name
      end
      url3 = @url0 + 'PLAN' + @num if i[/Plan|P(?= *\d)/i]  # only search PLAN{number} if original name implies a plan
        ## .compact will remove the nils (url2, url4) if the site isn't a Strata Plan (saves time).
      p '|| || || || url1-4 vvv || || || ||', [url,url2,url3,url4]
      res = [url,url2,url3,url4].uniq.compact.find{ abnfetch(_1) != [] } # .find( ... != [] ) means stop once any of these formats give a non-empty result
      # SF 220412 - better idea here is to not let abnfetch change @allabns, do it below instead. Then if abnfetch returns nothing for
      # a site, we can put an empty row in its place with the SP number as the first column to show that this one had no results.
      # Could also put a link to the search if desired?
      p 'res vvv',res
      @allabns << [i, @url0+i.gsub(' ','%20').gsub(?','%27'), '', ''] if res.nil?   # If no result, then put a blank row with a search link
      }
      @allabns.select!{|name,abn,state,pc| state =~ /#{ in_state }/i || state == '' } unless in_state == ""   # Filter by state unless no state requested
      return @allabns
  end
  def abnfetch(url)
    res = URI.open(url).read  # HTML of all results
    inp = Nokogiri::HTML(res).search('input') # All <input ...> tags
    @abns = []
    inp.map{|tag| data = tag.values.join(' ').scan(/(\d\d \d{3} \d{3} \d{3}).*?active,([^,]+)\s{3,}.*?y Name,,(\d{4}) +?(\w{3})/).map{_1.map &:rstrip}[0]
    abn, name, pc, state = data
    # puts "\n\n  abn fetch helper debug: --- ",data
    #warn [tag.values.join(' '),abn, name, pc, state].to_s
    @abns << [name,abn,state,pc] }
    # p [@abns+['all']+@allabns]
    @abns -= [[],[[],[]]]
    # p @abns
    # out = @abns.select!{_1&&_1[0]&&_1[0][/(?<!\d)#{@num}(?!\d)/]}
    # @allabns += @abns # SF 220412 - becoming more strict, no partial digit matches 10581 !=~ 1058
    rawnum = @num[/\d+/]
    @allabns += @abns.select!{_1&&_1[0]&&_1[0][/(?<!\d)#{rawnum}(?!\d)/]}
    @abns
  end
end