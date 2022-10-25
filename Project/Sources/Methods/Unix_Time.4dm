//%attributes = {}
#DECLARE($today : Date; $time : Time)->$result : Real

$start:=!1970-01-01!

If (Count parameters:C259=0)
	$now:=Timestamp:C1445
	$now:=Substring:C12($now; 1; Length:C16($now)-5)  // remove milliseconds and Z 
	$today:=Date:C102($now)  // date in UTC
	$time:=Time:C179($now)  // returns now time in UTC
End if 

$days:=$today-$start
$result:=($days*86400)+($time+0)  // convert in seconds