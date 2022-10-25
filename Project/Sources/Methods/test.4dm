//%attributes = {}
// https://developer.apple.com/documentation/weatherkitrestapi/request_authentication_for_weatherkit_rest_api


$path:=System folder:C487(Documents folder:K41:18)+"keys"+Folder separator:K24:12+"AuthKey_FYWT8PC3ND.p8"
$privatekey:=Document to text:C1236($path)

$teamID:="4789QA2D2W"
$serviceID:="com.4d.de.weather"
$devID:="FYX58PC3ND"



$settings:=New object:C1471("type"; "PEM"; "curve"; "prime256v1"; "pem"; $privatekey)
$jwt:=cs:C1710.jwt.new($settings)

$header:=New object:C1471()
$header.alg:="ES256"
$header.kid:=$devID
$header.id:=$teamID+"."+$serviceID

$claim:=New object:C1471()
$claim.iss:=$teamID
$claim.iat:=Unix_Time
$claim.exp:=Unix_Time(Current date:C33+2; ?00:00:00?)  // for this example, token expire time in 2 days, not caring for time zone
$claim.sub:=$serviceID

$token:=$jwt.sign($claim; $header)



$url:="https://weatherkit.apple.com/api/v1/weather/en/48.1550543/11.4014089?dataSets=currentWeather&timezone=Europe/Paris"
var $request : 4D:C1709.HTTPRequest
$options:=New object:C1471()
$options.headers:=New object:C1471("Authorization"; "Bearer "+$token)
$request:=4D:C1709.HTTPRequest.new($url; $options)
$request.wait()
If (Num:C11($request.response.status)=200)
	$current:=$request.response.body.currentWeather
	ALERT:C41("Temperature: "+String:C10($current.temperature))
Else 
	TRACE:C157
End if 

