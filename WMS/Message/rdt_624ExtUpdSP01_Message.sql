--rdt_624ExtUpdSP01
execute rdt.rdtdropmsg 115751 , 115800
GO
DECLARE @nFunc INT

SET @nFunc = 624

execute rdt.rdtAddMsg 115751, 10, '15751^UpdUCCFail',    'us_english',@nFunc

