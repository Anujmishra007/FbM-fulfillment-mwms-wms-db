--rdt_1804ExtUpd04
execute rdt.rdtdropmsg 108751 , 108800
GO
DECLARE @nFunc INT

SET @nFunc = 1804

execute rdt.rdtAddMsg 108751, 10, '08751^InsTaskdetFail',    'us_english',@nFunc
execute rdt.rdtAddMsg 108752, 10, '08752^GetKey Fail',    'us_english',@nFunc
