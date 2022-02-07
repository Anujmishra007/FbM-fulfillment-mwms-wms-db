
--rdt_1809ExtValidSP01
-- 92601 - 92650

exec rdt.rdtDropMsg 92601 , 92650
-- **********************************************
GO
DECLARE @nFunc INT

SET @nFunc = 1809

execute rdt.rdtAddMsg 92601 ,10, '92601^WrongRSNCode', 'us_english',@nFunc
execute rdt.rdtAddMsg 92602 ,10, '92602^WrongRSNCode', 'us_english',@nFunc
execute rdt.rdtAddMsg 92603 ,10, '92603^FromLocReq', 'us_english',@nFunc
execute rdt.rdtAddMsg 92604 ,10, '92604^ToteNoReq', 'us_english',@nFunc
