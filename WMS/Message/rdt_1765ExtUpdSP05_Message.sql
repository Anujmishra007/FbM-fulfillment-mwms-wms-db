--rdt_1765ExtUpdSP05
--execute rdt.rdtdropmsg 131001 - 131050
GO
DECLARE @nFunc INT

SET @nFunc = 1765

execute rdt.rdtAddMsg 131001, 10, '31001^UpdTaskDetFail',    'us_english',@nFunc
execute rdt.rdtAddMsg 131002, 10, '31002^UpdTaskDetFail',    'us_english',@nFunc




