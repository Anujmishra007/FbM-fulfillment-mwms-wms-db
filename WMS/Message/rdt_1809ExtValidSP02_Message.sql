
--rdt_1809ExtValidSP02
-- 101101 - 101150

exec rdt.rdtDropMsg 101101 - 101150
-- **********************************************
GO
DECLARE @nFunc INT

SET @nFunc = 1809

execute rdt.rdtAddMsg 101101 ,10, '01101^WrongRSNCode', 'us_english',@nFunc
execute rdt.rdtAddMsg 101102 ,10, '01102^WrongRSNCode', 'us_english',@nFunc
execute rdt.rdtAddMsg 101103 ,10, '01103^FromLocReq', 'us_english',@nFunc
execute rdt.rdtAddMsg 101104 ,10, '01104^ToteNoReq', 'us_english',@nFunc
execute rdt.rdtAddMsg 101105 ,10, '01105^-ToteInUsed', 'us_english',@nFunc
execute rdt.rdtAddMsg 101106 ,10, '01106^-ToteInUsed', 'us_english',@nFunc
execute rdt.rdtAddMsg 101107 ,10, '01107^-ToteInUsed', 'us_english',@nFunc
execute rdt.rdtAddMsg 101108 ,10, '01108^-ToteInUsed', 'us_english',@nFunc