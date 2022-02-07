
-- rdtfnc_ScanToTruck_DropID_Message 77301, 77350

exec rdt.rdtDropMsg 77301, 77350
-- **********************************************
GO
DECLARE @nFunc INT

SET @nFunc = 1716

execute rdt.rdtAddMsg 77301 ,10, '77301^MBOLKey req', 'us_english',@nFunc
execute rdt.rdtAddMsg 77302 ,10, '77302^Invalid MBOL#', 'us_english',@nFunc
execute rdt.rdtAddMsg 77303 ,10, '77303^MBOL Shipped', 'us_english',@nFunc
execute rdt.rdtAddMsg 77304 ,10, '77304^Consginee Req', 'us_english',@nFunc
execute rdt.rdtAddMsg 77305 ,10, '77305^Inv Consignee', 'us_english',@nFunc
execute rdt.rdtAddMsg 77306 ,10, '77306^DropID Req', 'us_english',@nFunc
execute rdt.rdtAddMsg 77307 ,10, '77307^Inv DropID', 'us_english',@nFunc
execute rdt.rdtAddMsg 77308 ,10, '77308^Inv Consignee', 'us_english',@nFunc
execute rdt.rdtAddMsg 77309 ,10, '77309^DropID Process', 'us_english',@nFunc
execute rdt.rdtAddMsg 77310 ,10, '77310^Option needed', 'us_english',@nFunc
execute rdt.rdtAddMsg 77311 ,10, '77311^Invalid Option', 'us_english',@nFunc
execute rdt.rdtAddMsg 77312 ,10, '77312^Ins Scan2Truck Fail', 'us_english',@nFunc
execute rdt.rdtAddMsg 77313 ,10, '77313^DropID Scanned', 'us_english',@nFunc
execute rdt.rdtAddMsg 77314 ,10, '77314^Ins Scan2Truck Fail', 'us_english',@nFunc
execute rdt.rdtAddMsg 77315 ,10, '77315^Del Scan2Truck Fail', 'us_english',@nFunc



