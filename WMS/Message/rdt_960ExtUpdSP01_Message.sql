
--rdt_960ExtUpdSP01
-- 92001 , 92050

exec rdt.rdtDropMsg 92001 , 92050
-- **********************************************
GO
DECLARE @nFunc INT

SET @nFunc = 960

execute rdt.rdtAddMsg 92001 ,10, '92001^SKU Not Found', 'us_english',@nFunc
execute rdt.rdtAddMsg 92002 ,10, '92002^MultiSKUFound', 'us_english',@nFunc
execute rdt.rdtAddMsg 92003 ,10, '92003^SKUExists', 'us_english',@nFunc
execute rdt.rdtAddMsg 92004 ,10, '92004^InsertSKUFail', 'us_english',@nFunc

