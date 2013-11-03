# Filters

iso3166tw = {
  "CHA":"彰化縣",
  "CYI":"嘉義市",
  "CYQ":"嘉義縣",
  "HSQ":"新竹縣",
  "HSZ":"新竹市",
  "HUA":"花蓮縣",
  "ILA":"宜蘭縣",
  "KEE":"基隆市",
  "KHH":"高雄市",
  "KHQ":"高雄市",
  "MIA":"苗栗縣",
  "NAN":"南投縣",
  "PEN":"澎湖縣",
  "PIF":"屏東縣",
  "TAO":"桃園縣",
  "TNN":"台南市",
  "TNQ":"台南市",
  "TPE":"台北市",
  "TPQ":"新北市",
  "TTT":"台東縣",
  "TXG":"台中市",
  "TXQ":"台中市",
  "YUN":"雲林縣",
  "JME":"金門縣",
  "LJF":"連江縣"
}

committees = do
    IAD: \內政
    FND: \外交及國防
    ECO: \經濟
    FIN: \財政
    EDU: \教育及文化
    TRA: \交通
    JUD: \司法及法制
    SWE: \社會福利及衛生環境
    PRO: \程序
format-title = ->
  console.log it
  if it=="YS" => return "現場實況直播"
  console.log it
  it = it.split \-
  name = "#{committees[it.2] or ''}#{(committees[it.3] and '聯席') or ''}"
  "第#{it.0}屆第#{it.1}會期#{name}第#{it.4 or it.3}次會議"


angular.module 'app.filters' []
.filter \interpolate <[version]> ++ (version) ->
    (text) -> String(text)replace /\%VERSION\%/mg version

.filter \showConstituency -> ->
  if it.0 is \proportional
    '全國不分區'
  else if it.0 is \aborigine
    '原住民'
  else
    iso3166tw[it.0]
    # + if it.1 => "第#that選區" else ''

