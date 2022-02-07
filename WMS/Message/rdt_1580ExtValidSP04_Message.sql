--rdt_876ExtValidSP01
--execute rdt.rdtdropmsg 96451 - 96500
GO
DECLARE @nFunc INT

SET @nFunc = 1580

execute rdt.rdtAddMsg 96451 ,10, '96451^InsLogFail', 'us_english',@nFunc
execute rdt.rdtAddMsg 96452 ,10, '96452^SKUNotInASN', 'us_english',@nFunc
execute rdt.rdtAddMsg 96453 ,10, '96453^OverReceive', 'us_english',@nFunc
execute rdt.rdtAddMsg 96454 ,10, '96454^InsLogFail', 'us_english',@nFunc
execute rdt.rdtAddMsg 96455 ,10, '96455^UpdLogFail', 'us_english',@nFunc
execute rdt.rdtAddMsg 96456 ,10, '96456^UpdLogFail', 'us_english',@nFunc




