
--rdt_1180ExtValidSP01
--95301 - 95350

exec rdt.rdtDropMsg 95301 , 95350
-- **********************************************
GO
DECLARE @nFunc INT

SET @nFunc = 1180

execute rdt.rdtAddMsg 95301 ,10, '95301^TruckID Req', 'us_english',@nFunc
execute rdt.rdtAddMsg 95302 ,10, '95302^ShipmentNo Req', 'us_english',@nFunc
execute rdt.rdtAddMsg 95303 ,10, '95303^ShptIDNotExist', 'us_english',@nFunc
execute rdt.rdtAddMsg 95304 ,10, '95304^CartonID Req', 'us_english',@nFunc
execute rdt.rdtAddMsg 95305 ,10, '95305^PltIDScanned', 'us_english',@nFunc



