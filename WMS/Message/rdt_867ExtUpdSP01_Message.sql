--rdt_867ExtUpdSP01
--execute rdt.rdtdropmsg 94151 - 94200
GO
DECLARE @nFunc INT

SET @nFunc = 867

execute rdt.rdtAddMsg 94151, 10, '94151^GetKeyFail',    'us_english',@nFunc
execute rdt.rdtAddMsg 94152, 10, '94152^InsSerialNoFail',    'us_english',@nFunc
execute rdt.rdtAddMsg 94153, 10, '94153^SerialNoExist',    'us_english',@nFunc
execute rdt.rdtAddMsg 94154, 10, '94154^DelSerialNoFail',    'us_english',@nFunc