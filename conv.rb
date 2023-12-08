require 'csv'
require 'uri'
require 'net/http'
require 'json'

def jbn(cr,jb)
  cr.filter{_1["job"]==jb}.map{_1["name"]}
end
c=CSV.read 'data.csv'
la=JSON.parse(File.read('langs.json'))
of=File.open 'data2.P','w'
of.write ":- module(data,[m/8,p/4]).\n"
am=[]

c[1..].each{|t,n,_,*m,a|
  p n
  mn=m.map{|l|
    d=l[/\d+/]
    u="https://api.themoviedb.org/3/movie/#{d}?api_key=#{ENV["TMDB_API_KEY"]}&append_to_response=credits"
    r=URI u
    h=Net::HTTP.get r
    j=JSON.parse h
    cr=j["credits"]["crew"] 
    cl='m(%s,"%s","%s","%s",%s,%s,%s,"%s").
'%[
      d,
      j["title"],
      j["release_date"][0,4],
      j["poster_path"] || "",
      jbn(cr,"Director"),
      jbn(cr,"Production Manager"),
      jbn(cr,"Writer"),
      la[j["original_language"]]
    ]
    am.push cl
    puts cl
    d
  }
  pl = 'p("%s","%s",%s,"%s").
'%[
   t.scan(/\d/).join+n.scan(/\w/).join,
   n,
   mn.map(&:to_i),
   (a||"").gsub("\n",'<br>').gsub('"','\"')
  ]
  print pl
  of.write pl
}

am.uniq{_1[/\d+/]}.each{of.write(_1)}
