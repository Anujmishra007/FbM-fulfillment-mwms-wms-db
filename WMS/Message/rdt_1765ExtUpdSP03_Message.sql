--rdt_1765ExtUpdSP03
execute rdt.rdtdropmsg 107501 , 107550
GO
DECLARE @nFunc INT

SET @nFunc = 1765

execute rdt.rdtAddMsg 107501, 10, '07501^UpdTaskDetFail',    'us_english',@nFunc
execute rdt.rdtAddMsg 107501, 10, '07502^UpdTaskDetFail',    'us_english',@nFunc 