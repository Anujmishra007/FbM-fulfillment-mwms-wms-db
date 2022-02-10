--rdt_1664ExtUpdSP02
--execute rdt.rdtdropmsg 93551 ,  93600
GO
DECLARE @nFunc INT

SET @nFunc = 1664

execute rdt.rdtAddMsg 93551, 10, '93551^UpdMBOLDetFail',    'us_english',@nFunc


