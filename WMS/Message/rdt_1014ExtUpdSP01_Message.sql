--rdt_1014ExtUpdSP01
execute rdt.rdtdropmsg 113251 , 113300
GO
DECLARE @nFunc INT

SET @nFunc = 1014

execute rdt.rdtAddMsg 113251, 10, '13251^InsMasterSerialFail',    'us_english',@nFunc
execute rdt.rdtAddMsg 113252, 10, '13252^InsMasterSerialFail',    'us_english',@nFunc
execute rdt.rdtAddMsg 113253, 10, '13253^UpdrdtSerailFail',    'us_english',@nFunc
execute rdt.rdtAddMsg 113254, 10, '13254^InsMasterSerialFail',    'us_english',@nFunc
execute rdt.rdtAddMsg 113255, 10, '13255^InsMasterSerialFail',    'us_english',@nFunc
execute rdt.rdtAddMsg 113256, 10, '13256^UpdrdtSerailFail',    'us_english',@nFunc