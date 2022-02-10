
--rdt_608ExtUpd04
-- 103851 , 103900

exec rdt.rdtDropMsg 103851 , 103900
-- **********************************************
GO
DECLARE @nFunc INT

SET @nFunc = 608

execute rdt.rdtAddMsg 103851 ,10, '103851^TruckID req', 'us_english',@nFunc





