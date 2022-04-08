module PagesHelper
  
  def ABN_export
    @allabns = params[:abns] ? eval(params[:abns]) : [] # :abns parameter is passed when clicking the "Export to Excel" link on the home page
    # https://github.com/caxlsx/caxlsx_rails
    respond_to do |format|
      format.xlsx
    end
    # render xlsx: "ABN_export", disposition: 'inline'
  end
  def abnlist(list)
  # def self.abnlist(list)
    list.map{|i| i = i[/\d+/] if i[/Owners|Trust/i] && i[/\d+/] # Long names including 'The Owners of...' are reduced to just numbers
      prefix_rgx = /^((SP|DP|UP|CTS|SC)|(Strata|Units?|Deposited|Community) *(Plan|Title( Scheme)?|Scheme)) *(?=\d)/i
      @num = i.gsub(prefix_rgx, '')
      p [i,@num,@url0]
      url = @url0 + @num
      if i[/SP|STRATA|S P /i]
        url2 = @url0 + (@num[/DP|UP/] ? @num.gsub(/DP|UP/,'') : 'SP' + @num)
        url4 = @url0 + (@num[/DP|UP/] ? @num.gsub(/DP|UP/){($&[?D]? 'DEPOSITED': 'UNIT') + 'PLAN'} : 'STRATAPLAN' + @num)
      else
        url2, url4 = nil, nil
      end
      url3 = @url0 + 'PLAN' + @num
        ## .compact will remove the nils (url2, url4) if the site isn't a Strata Plan (saves time).
      [url,url2,url3,url4].compact.find{ abnfetch(_1) != [] }
      }
      @allabns
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
    #warn [tag.values.join(' '),abn, name, pc, state].to_s
    @abns << [name,abn,state,pc] }
    # p [@abns+['all']+@allabns]
    @abns -= [[],[[],[]]]
    #p @abns
    out = @abns.select!{_1&&_1[0]&&_1[0][/(?<!\d)#{@num}(?!\d)/]}
    @allabns += @abns
    @abns
  end
end
