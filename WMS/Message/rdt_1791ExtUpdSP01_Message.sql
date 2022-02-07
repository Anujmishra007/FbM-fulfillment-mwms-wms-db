
--rdt_1791ExtValidSP01
-- 86151 , 86200

exec rdt.rdtDropMsg 86151 , 86200
-- **********************************************
GO
DECLARE @nFunc INT

SET @nFunc = 1791

execute rdt.rdtAddMsg 86151 ,10, '86151^UpdDROPIDFail', 'us_english',@nFunc
execute rdt.rdtAddMsg 86152 ,10, '86152^UpdLPLaneFail', 'us_english',@nFunc

