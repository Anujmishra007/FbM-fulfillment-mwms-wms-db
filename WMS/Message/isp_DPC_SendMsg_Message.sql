
--isp_DPC_SendMsg
-- 80451 - 80500

exec rdt.rdtDropMsg 80451 , 80500
-- **********************************************
GO
DECLARE @nFunc INT

SET @nFunc = 0

execute rdt.rdtAddMsg 80451 ,10, '80451UDF01NotSetup', 'us_english',@nFunc
execute rdt.rdtAddMsg 80452 ,10, '80452IPPortNoSetup', 'us_english',@nFunc
execute rdt.rdtAddMsg 80453 ,10, '80453ConnectionFail', 'us_english',@nFunc
execute rdt.rdtAddMsg 80454 ,10, '80454LightLinkTaskFail', 'us_english',@nFunc







