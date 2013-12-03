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
  if it=="YS" => return "現場實況直播"
  [ad, session, ...c, sitting] = it.split \-
  name = c.map (committees.) .join \、
  name += '聯席' if c.length > 1
  "第#{ad}屆第#{session}會期#{name}第#{sitting}次會議"

angular.module 'app.filters' []
.filter \interpolate <[version]> ++ (version) ->
    (text) -> String(text)replace /\%VERSION\%/mg version

.filter \showConstituency ->
  ->
    if it.0 is \proportional
      '全國不分區'
    else if it.0 is \aborigine
      '原住民'
    else if it.0 is \foreign
      '僑居國外國民'
    else
      iso3166tw[it.0]

.filter \sittingName -> ->
  format-title it
