--rdt_513ExtUpdSP01
--execute rdt.rdtdropmsg 93951 , 94000
GO
DECLARE @nFunc INT

SET @nFunc = 513

execute rdt.rdtAddMsg 93951, 10, '93951^UpdUCCFail',    'us_english',@nFunc
