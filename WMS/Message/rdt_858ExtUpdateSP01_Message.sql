
--rdt_857ExtUpdateSP01
-- 84951 - 85000

exec rdt.rdtDropMsg 93401 , 93450
-- **********************************************
GO
DECLARE @nFunc INT

SET @nFunc = 858

execute rdt.rdtAddMsg 93401 ,10, '93401^UpdBookingFail', 'us_english',@nFunc
execute rdt.rdtAddMsg 93402 ,10, '93402^CheckInNotDone', 'us_english',@nFunc
execute rdt.rdtAddMsg 93403 ,10, '93403^LoadingNotStart', 'us_english',@nFunc
