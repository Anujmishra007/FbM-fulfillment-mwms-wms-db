
--rdt_1819ExtValSP02
-- 104451 , 104500

exec rdt.rdtDropMsg 104451 , 104500
-- **********************************************
GO
DECLARE @nFunc INT

SET @nFunc = 1819 

execute rdt.rdtAddMsg 104451 ,10, '04451^DiffPAZone', 'us_english',@nFunc

