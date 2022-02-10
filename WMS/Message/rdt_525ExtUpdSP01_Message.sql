
--rdt_529ExtUpdateSP01
-- 91301 - 91350

exec rdt.rdtDropMsg 92501 , 92550
-- **********************************************
GO
DECLARE @nFunc INT

SET @nFunc = 525

execute rdt.rdtAddMsg 92501 ,10, '92501^UpdPackDtlFail', 'us_english',@nFunc
execute rdt.rdtAddMsg 92502 ,10, '92502^DelPackDtlFail', 'us_english',@nFunc
execute rdt.rdtAddMsg 92503 ,10, '92503^UpdPackDtlFail', 'us_english',@nFunc
execute rdt.rdtAddMsg 92504 ,10, '92504^UpdPickDetFail', 'us_english',@nFunc
