
--rdt_870DecodeLBL01
-- 93101 , 93150

exec rdt.rdtDropMsg 93101 , 93150
-- **********************************************
GO
DECLARE @nFunc INT

SET @nFunc = 870

execute rdt.rdtAddMsg 93101 ,10, '93101^InvalidSerialNo', 'us_english',@nFunc

