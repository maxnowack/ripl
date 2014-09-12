request = require 'request'
jf = require 'jsonfile'

Array::unique = ->
  output = {}
  output[@[key]] = @[key] for key in [0...@length]
  value for key, value of output

databases = [{
      url:'http://domains.yougetsignal.com/domains.php',
      method:'POST',
      data:'remoteAddress=%HOST%&key=&_=',
      complete:(data)->
        retVal=[]
        if not JSON.parse(data).domainArray
          return
        JSON.parse(data).domainArray.forEach (val)->
          retVal.push val[0]
        retVal
    }]

host = process.argv[2]
count = databases.length
list = []
addToList = (arr)->
  list = list.concat(arr).unique()


databases.forEach (val)->
  callback = (err,res,data)->
    addToList val.complete(data)
    if not --count
      jf.writeFileSync 'ripl.json', list

  url = val.url.replace '%HOST%',host
  switch val.method
    when 'GET'
      request url,callback
    when 'POST'
      request.post({
        url:url
        form:val.data.replace '%HOST%',host
        },callback)
