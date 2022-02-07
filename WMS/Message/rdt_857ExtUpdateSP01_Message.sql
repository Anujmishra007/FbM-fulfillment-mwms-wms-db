
--rdt_857ExtUpdateSP01
-- 84951 - 85000

exec rdt.rdtDropMsg 92451 , 92500
-- **********************************************
GO
DECLARE @nFunc INT

SET @nFunc = 857

execute rdt.rdtAddMsg 92451 ,10, '92451^UpdBookingFail', 'us_english',@nFunc
execute rdt.rdtAddMsg 92452 ,10, '92452^InvalidBookingNo', 'us_english',@nFunc
execute rdt.rdtAddMsg 92453 ,10, '92453^LoadingNotDone', 'us_english',@nFunc
execute rdt.rdtAddMsg 92454 ,10, '92454^CheckInFail', 'us_english',@nFunc

