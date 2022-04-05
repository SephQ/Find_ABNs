class PagesController < ApplicationController
  def home
    # if params[:list] && params[:list] == "DONE"
    #   #Skip - already taken in data and have now finished getting ABNS into @allabns
    # else
    @sptext = params[:list] ? params[:list] : ""
    @splist = @sptext.split(/[\r\n]+/)    # An array of line-separated strings from input
    p @splist
    @url0 = "https://abr.business.gov.au/Search/ResultsActive?SearchText="
    @allabns = []
    abnlist(@splist) if @splist != []
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
  end
  def ABN_export
    @allabns = params[:abns] ? eval(params[:abns]) : []
    # https://github.com/caxlsx/caxlsx_rails
    respond_to do |format|
      format.xlsx
    end
  end
  def index
    # https://medium.com/@igor_marques/exporting-data-to-a-xlsx-spreadsheet-on-rails-7322d1c2c0e7
    @users =  User.all
  
    respond_to do |format|
      format.html
      format.xlsx
    end
  end
  def abnlist(list)
  # def self.abnlist(list)
    list.map{|i| i = i[/\d+/] if i[/Owners|Trust/i] && i[/\d+/] # Long names including 'The Owners of...' are reduced to just numbers
      prefix_rgx = /^((SP|DP|UP|CTS|SC)|(Strata|Units?|Deposited|Community) *(Plan|Title( Scheme)?|Scheme)) *(?=\d)/i
      @num = i.gsub(prefix_rgx, '')
      p [i,@num,@url0]
      url = @url0 + @num
      url2 = @url0 + (@num[/DP|UP/] ? @num.gsub(/DP|UP/,'') : 'SP' + @num)
      url3 = @url0 + 'PLAN' + @num
      url4 = @url0 + (@num[/DP|UP/] ? @num.gsub(/DP|UP/){($&[?D]? 'DEPOSITED': 'UNIT')              +'PLAN'} : 'STRATAPLAN' + @num)
      ## Then hit ▷ Run up top to get the output.
      ## Use CTRL+SHIFT+C to copy the text (need SHIFT)
      [url,url2,url3,url4].find{ abnfetch(_1) != [] }
      }
      # p @allabns
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