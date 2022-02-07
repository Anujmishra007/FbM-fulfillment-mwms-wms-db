--rdt_1016ExtValid01
execute rdt.rdtdropmsg 114451 , 114500
GO
DECLARE @nFunc INT

SET @nFunc = 1016

execute rdt.rdtAddMsg 114451, 10, '14451^InvalidCaseCnt',    'us_english',@nFunc
execute rdt.rdtAddMsg 114452, 10, '14452^InvMasterSerialNo',    'us_english',@nFunc
execute rdt.rdtAddMsg 114453, 10, '14453^MasterSerialExist',    'us_english',@nFunc
execute rdt.rdtAddMsg 114454, 10, '14454^ChildSerialExist',    'us_english',@nFunc
execute rdt.rdtAddMsg 114455, 10, '14455^MasterSerialExist',    'us_english',@nFunc
execute rdt.rdtAddMsg 114456, 10, '14456^ChildSerialExist',    'us_english',@nFunc
execute rdt.rdtAddMsg 114457, 10, '14457^ChildSerialExist',    'us_english',@nFunc
execute rdt.rdtAddMsg 114458, 10, '14458^MasterSerialExist',    'us_english',@nFunc
execute rdt.rdtAddMsg 114459, 10, '14459^InvMasterSerialNo',    'us_english',@nFunc
