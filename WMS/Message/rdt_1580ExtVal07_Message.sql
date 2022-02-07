--rdt_1580ExtVal07
execute rdt.rdtdropmsg 119851 - 119900
GO
DECLARE @nFunc INT

SET @nFunc = 1580

execute rdt.rdtAddMsg 119851, 10, '19851^IDReq',    'us_english',@nFunc
execute rdt.rdtAddMsg 119852, 10, '19852^NoMixSKUinID',    'us_english',@nFunc
execute rdt.rdtAddMsg 119853, 10, '19853^NoMixSKUinID',    'us_english',@nFunc
execute rdt.rdtAddMsg 119854, 10, '19854^NoMixSKUinID',    'us_english',@nFunc




