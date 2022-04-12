module PagesHelper
  
  def ABN_export
    @allabns = params[:abns] ? eval(params[:abns]) : [] # :abns parameter is passed when clicking the "Export to Excel" link on the home page
    # https://github.com/caxlsx/caxlsx_rails
    respond_to do |format|
      format.xlsx
    end
    # render xlsx: "ABN_export", disposition: 'inline'
  end
  def ABN_email
    # Doesn't seem to work here, even though ABN_export does. Says it needs to be in PagesController. Copying there.
    # Link to optionally email manually (not the automated one for longer lists)
    email = params[:email]
    splist = params[:splist]
    in_state = params[:state]
    emailthreshold = 0      # No threshold, manual request
    AbnWorker.perform_async(email, "ABN_export",   splist, in_state, emailthreshold)
  end
  def abnlist(list, in_state = "")
  # def self.abnlist(list)
    list.map{|i| i = i[/\d+(?=\D*$)/] if i[/Owners|Trust/i] && i[/\d+/] # Long names including 'The Owners of...' are reduced to just numbers
      prefix_rgx = /^.*?((SP|DP|UP|CTS|SC)|(Strata|Units?|Deposited|Community) *(Plan|Title( Scheme)?|Scheme)) *(?=\d)/i
      suffix_rgx = /^\d+\K.*$/i
      @num = i.gsub(prefix_rgx, '')   # Remove prefixes to get just the number (if it's in one of the above formats)
      @num = @num.gsub(suffix_rgx, '') if i[prefix_rgx] # Remove suffixes after the number (if it matches a prefix format)
      p [i,@num,@url0]
      url2, url3, url4 = nil, nil, nil  # Initialize as nil (means won't be checked unless re-defined below)
      # url is searching for the basic number. url2 searches SP{number}, url3 = PLAN{number}, url4 = STRATAPLAN{number} 
      url = @url0 + @num
      if i[/SP|STRATA|S P /i]
        url2 = @url0 + (@num[/DP|UP/] ? @num.gsub(/DP|UP/,'') : 'SP' + @num)
        url4 = @url0 + (@num[/DP|UP/] ? @num.gsub(/DP|UP/){($&[?D]? 'DEPOSITED': 'UNIT') + 'PLAN'} : 'STRATAPLAN' + @num)
      end
      url3 = @url0 + 'PLAN' + @num if i[/Plan|P(?= *\d)/i]  # only search PLAN{number} if original name implies a plan
        ## .compact will remove the nils (url2, url4) if the site isn't a Strata Plan (saves time).
      p '|| || || || url1-4 vvv || || || ||', [url,url2,url3,url4]
      [url,url2,url3,url4].compact.find{ abnfetch(_1) != [] } # .find( ... != [] ) means stop once any of these formats give a non-empty result
      # SF 220412 - better idea here is to not let abnfetch change @allabns, do it below instead. Then if abnfetch returns nothing for
      # a site, we can put an empty row in its place with the SP number as the first column to show that this one had no results.
      # Could also put a link to the search if desired?
      }
      @allabns.select!{|name,abn,state,pc| state =~ /#{ in_state }/i } unless in_state == ""   # Filter by state unless no state requested
      return @allabns
  end
  def abnfetch(url)
    res = URI.open(url).read  # HTML of all results
    inp = Nokogiri::HTML(res).search('input') # All <input ...> tags
    @abns = []
    #puts inp.inspect,?-*100,inp.size
    #inp = inp[30..]
    #puts res
    #puts inp.map{_1.values.join(' ')}.inspect
    inp.map{|tag| data = tag.values.join(' ').scan(/(\d\d \d{3} \d{3} \d{3}).*?active,([^,]+)\s{3,}.*?y Name,,(\d{4}) +?(\w{3})/).map{_1.map &:rstrip}[0]
    abn, name, pc, state = data
    # puts "\n\n  abn fetch helper debug: --- ",data
    #warn [tag.values.join(' '),abn, name, pc, state].to_s
    @abns << [name,abn,state,pc] }
    # p [@abns+['all']+@allabns]
    @abns -= [[],[[],[]]]
    # p @abns
    # out = @abns.select!{_1&&_1[0]&&_1[0][/(?<!\d)#{@num}(?!\d)/]}
    @allabns += @abns
    @abns
  end
end
