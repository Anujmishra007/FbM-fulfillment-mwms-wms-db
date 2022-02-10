
--rdt_1036ExtValidSP01
-- 112151 - 112200

exec rdt.rdtDropMsg 112151 , 112200
-- **********************************************
GO
DECLARE @nFunc INT

SET @nFunc = 1036

execute rdt.rdtAddMsg 112151 ,10, '12151^InvalidDropID', 'us_english',@nFunc
execute rdt.rdtAddMsg 112152 ,10, '12152^ToteClose', 'us_english',@nFunc
execute rdt.rdtAddMsg 112153 ,10, '12153^WrongFormat', 'us_english',@nFunc
execute rdt.rdtAddMsg 112154 ,10, '12154^WrongFormat', 'us_english',@nFunc
execute rdt.rdtAddMsg 112155 ,10, '12155^NewToteReq', 'us_english',@nFunc
execute rdt.rdtAddMsg 112156 ,10, '12156^FullReq', 'us_english',@nFunc
execute rdt.rdtAddMsg 112157 ,10, '12157^InvalidDPKey', 'us_english',@nFunc
execute rdt.rdtAddMsg 112158 ,10, '12158^InvalidDropID', 'us_english',@nFunc




