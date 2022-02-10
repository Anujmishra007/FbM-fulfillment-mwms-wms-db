--rdt_1641ExtUpdSP03
execute rdt.rdtdropmsg 110601 , 110650
GO
DECLARE @nFunc INT

SET @nFunc = 1641

execute rdt.rdtAddMsg 110601, 10, '10601^InsPLTFail',    'us_english',@nFunc
execute rdt.rdtAddMsg 110602, 10, '10602^CartonExist',    'us_english',@nFunc
execute rdt.rdtAddMsg 110603, 10, '10603^InsPLTDetFail',    'us_english',@nFunc
execute rdt.rdtAddMsg 110604, 10, '10604^PLTKeyNotFound',    'us_english',@nFunc
execute rdt.rdtAddMsg 110605, 10, '10605^UpdPLTDetFail',    'us_english',@nFunc
execute rdt.rdtAddMsg 110606, 10, '10606^UpdPLTFail',    'us_english',@nFunc
execute rdt.rdtAddMsg 110607, 10, '10607^NoRecordFound',    'us_english',@nFunc
execute rdt.rdtAddMsg 110608, 10, '10608^InsDocStatusFail',    'us_english',@nFunc
