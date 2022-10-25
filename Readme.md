# JWT Token Example

### Introduction
4D's crypto class provides all needed technology to create JWT tokens, but it still require skills to do it.
This example provides a wrapper class, making the job quite simple:

```4d
$settings:=New object("type"; "PEM"; "curve"; "prime256v1"; "pem"; $privatekey)
$jwt:=cs.jwt.new($settings)
// create two objects for claim and header and use them to sign the token:
$token:=$jwt.sign($claim; $header)
```

We use Apple WeatherKit as practical example, showing how to go from API documentation to receiving a token.


### Apple WeatherKit

See details for the API itself:
[Introduction](https://developer.apple.com/documentation/weatherkitrestapi/)

The first part of the documentation is "Request authentication":
[Authentication](https://developer.apple.com/documentation/weatherkitrestapi/request_authentication_for_weatherkit_rest_api)

The documentation explains that you need to use your Apple ID account to create a private key (PEM) and a service ID.
The PEM is downloaded as file on disk (in this example I stored it in documents/AuthKey_nameofkey.p8), the service ID can have any chosen name (in this example I used weather.de.4d.com).
Finally you need to note your Apple Team ID.

In the next chapter, Apple describe the content of the token header and claim, read "Generate the web token".

### Produce the token with 4D:

```4d
$path:=System folder(Documents folder)+"keys"+Folder separator+"AuthKey_FYWT8PC3ND.p8"
$privatekey:=Document to text($path)

$teamID:="4789QA2D2W"
$serviceID:="com.4d.de.weather"
$devID:="FYX58PC3ND"


$settings:=New object("type"; "PEM"; "curve"; "prime256v1"; "pem"; $privatekey)
$jwt:=cs.jwt.new($settings)

$header:=New object()
$header.alg:="ES256"
$header.kid:=$devID
$header.id:=$teamID+"."+$serviceID

$claim:=New object()
$claim.iss:=$teamID
$claim.iat:=Unix_Time
$claim.exp:=Unix_Time(Current date+2; ?00:00:00?)  // for this example, token expire time in 2 days, not caring for time zone
$claim.sub:=$serviceID

$token:=$jwt.sign($claim; $header)
```

as you can see, we just follow the Apple documentation.  Reading the key from disk (as text), using local variables for teamID, serviceID and the keyID.

When we create a new instance of the jwt class by passing the private key (which we downloaded from our Apple account), create a claim and header object using the attribute names as specified by Apple and assigning the required data.
Finally executing the sign class method to produce the token.

Should not be too difficult.
The source contains a helper method to calculate the Unix Time (seconds past 1970-1-1:midnight), in GMT time zone, based on the current time (or a given time such as expiration time).

### Using the token:
A token just needs to be set to the HTTP request header, as shown here:

```4D
$url:="https://weatherkit.apple.com/api/v1/weather/en/48.1550543/11.4014089?dataSets=currentWeather&timezone=Europe/Paris"
var $request : 4D.HTTPRequest
$options:=New object()
$options.headers:=New object("Authorization"; "Bearer "+$token)
$request:=4D.HTTPRequest.new($url; $options)
$request.wait()
If (Num($request.response.status)=200)
	$current:=$request.response.body.currentWeather
	ALERT("Temperature: "+String($current.temperature))
Else 
	TRACE
End if 
```

### Comments

All needed code is included in the project. To use it with Apple WeatherKit, you need to replace private key, TeamID, serviceID with your own data (and this requires an Apple account), but the global idea is to show how it works, not specially with Apple WeatherKit.

### Credits

Special thanks to Laurent Esnault and Fabrice Mainguené for developing the jwt class