--rdt_1804ExtValidSP03
execute rdt.rdtdropmsg 108701 , 108750
GO
DECLARE @nFunc INT

SET @nFunc = 1804

execute rdt.rdtAddMsg 107501, 10, '07501^SKULot04Diff',    'us_english',@nFunc
