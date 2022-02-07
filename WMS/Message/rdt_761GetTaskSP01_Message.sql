
--rdt_761GetTaskSP01
-- 96801 , 96850

exec rdt.rdtDropMsg 96801 , 96850
-- **********************************************
GO
DECLARE @nFunc INT

SET @nFunc = 760

execute rdt.rdtAddMsg 96801 ,10, '96801^NoTask', 'us_english',@nFunc
