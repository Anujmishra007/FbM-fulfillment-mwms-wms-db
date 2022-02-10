
--rdt_870ExtValidSP01
-- 93001 - 93050

exec rdt.rdtDropMsg 93001 , 93050
-- **********************************************
GO
DECLARE @nFunc INT

SET @nFunc = 870

execute rdt.rdtAddMsg 93001 ,10, '93001^InvalidSerialNo', 'us_english',@nFunc

