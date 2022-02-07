
--rdt_514ExtValidSP01
-- 92551 - 92600

exec rdt.rdtDropMsg 92551 - 92600
-- **********************************************
GO
DECLARE @nFunc INT

SET @nFunc = 514

execute rdt.rdtAddMsg 92551 ,10, '92551^UCConHOLD', 'us_english',@nFunc
execute rdt.rdtAddMsg 92552 ,10, '92552^UCConHOLD', 'us_english',@nFunc
execute rdt.rdtAddMsg 92553 ,10, '92553^UCConHOLD', 'us_english',@nFunc
execute rdt.rdtAddMsg 92554 ,10, '92554^UCConHOLD', 'us_english',@nFunc


