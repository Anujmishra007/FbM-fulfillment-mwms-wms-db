--rdt_1796ExtUpdSP01
execute rdt.rdtdropmsg 109151 , 109200
GO
DECLARE @nFunc INT

SET @nFunc = 1796

execute rdt.rdtAddMsg 109151, 10, '109151^UpdTaskDetFail',    'us_english',@nFunc
