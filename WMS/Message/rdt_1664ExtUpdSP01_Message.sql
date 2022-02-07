--rdt_1664ExtValidSP01
execute rdt.rdtdropmsg 91601,  91650
GO
DECLARE @nFunc INT

SET @nFunc = 1664

execute rdt.rdtAddMsg 91601, 10, '91601^UpdMBOLDetFail',    'us_english',@nFunc




