
--rdt_529ExtUpdSP04
-- 95701 - 95750

exec rdt.rdtDropMsg 95701 - 95750
-- **********************************************
GO
DECLARE @nFunc INT

SET @nFunc = 529

execute rdt.rdtAddMsg 95701 ,10, '95701^GetDetKeyfail', 'us_english',@nFunc
execute rdt.rdtAddMsg 95702 ,10, '95702^UpdPDtlFail', 'us_english',@nFunc
