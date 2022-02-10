
--rdt_810ExtValidSP01
-- 85351 - 85400

exec rdt.rdtDropMsg 87851 , 87900
-- **********************************************
GO
DECLARE @nFunc INT

SET @nFunc = 1810

execute rdt.rdtAddMsg 87851 ,10, '87851^UCCNotExist', 'us_english',@nFunc
execute rdt.rdtAddMsg 87852 ,10, '87852^InvalidTote', 'us_english',@nFunc
execute rdt.rdtAddMsg 87853 ,10, '87853^UpdWCSRoutingFail', 'us_english',@nFunc
execute rdt.rdtAddMsg 87854 ,10, '87854^UpdWCSRoutingDetFail', 'us_english',@nFunc

