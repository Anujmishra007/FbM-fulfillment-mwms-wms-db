
--rdt_600DecodeSP02
-- 104851 - 104900

exec rdt.rdtDropMsg 104851 , 104900
-- **********************************************
GO
DECLARE @nFunc INT

SET @nFunc = 600 

execute rdt.rdtAddMsg 104851 ,10, '04851^InvalidBarcode', 'us_english',@nFunc
execute rdt.rdtAddMsg 104852 ,10, '04852^BarcodeExist', 'us_english',@nFunc
execute rdt.rdtAddMsg 104853 ,10, '04853^BarcodeExist', 'us_english',@nFunc

