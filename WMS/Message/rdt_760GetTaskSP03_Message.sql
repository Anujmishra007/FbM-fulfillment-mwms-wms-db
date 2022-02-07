
--rdt_760GetTaskSP02
-- 98201 , 98250

exec rdt.rdtDropMsg 98201 , 98250
-- **********************************************
GO
DECLARE @nFunc INT

SET @nFunc = 760

execute rdt.rdtAddMsg 96801 ,10, '96801^NoTask', 'us_english',@nFunc
