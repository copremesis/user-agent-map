

#a = Mechanize.new
#url = 'http://www-st.cars.com/for-sale/searchresults.action?stkTyp=U&tracktype=usedcc&rd=30&zc=60016&searchSource=QUICK_FORM&enableSeo=1'
#@p = a.get(url)

#@p.methods
#ap @p.links


#http://www-st.cars.com/go/search/detail.jsp?tracktype=usedcc&csDlId=&csDgId=&listingId=60969884&listingRecNum=2&criteria=sf1Dir%3DDESC%26stkTyp%3DU%26rd%3D30%26crSrtFlds%3DstkTypId-feedSegId%26zc%3D60016%26rn%3D0%26PMmt%3D0-0-0%26stkTypId%3D28881%26sf2Dir%3DASC%26sf1Nm%3Dprice%26sf2Nm%3Dmiles%26isDealerGrouping%3Dfalse%26rpp%3D50%26feedSegId%3D28705&aff=national&listType=1


#<div class="YmmHeader"><a name="&amp;lid=md-ymmt" rel="nofollow" href="/go/search/detail.jsp?tracktype=usedcc&amp;csDlId=&amp;csDgId=&amp;listingId=84195056&amp;listingRecNum=0&amp;criteria=sf1Dir%3DDESC%26stkTyp%3DU%26rd%3D30%26crSrtFlds%3DstkTypId-feedSegId%26zc%3D60016%26rn%3D0%26PMmt%3D0-0-0%26stkTypId%3D28881%26sf2Dir%3DASC%26sf1Nm%3Dprice%26sf2Nm%3Dmiles%26isDealerGrouping%3Dfalse%26rpp%3D50%26feedSegId%3D28705&amp;aff=national&amp;listType=3" onclick="s_objectID=&quot;2008 Alfa Romeo 8c Competizione_1&quot;;return this.s_oc?this.s_oc(e):true"><span class="modelYearSort">2008</span> <span class="mmtSort">Alfa Romeo 8c Competizione </span></a></div>





Rails.cache.clear
require 'open-uri'
 %w(794219 838653 794228 952955 794422 70530 794424 70531 794230 794229 70532).map {|pid|
  ["http://172.31.20.36:4444/ghostbuster?duration=month", "property_id=#{pid}"].join('&') 
}.each {|url|
  open(url);
}


