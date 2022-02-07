--rdt_1804ExtUpd05
--execute rdt.rdtdropmsg 119801 - 119850
GO
DECLARE @nFunc INT

SET @nFunc = 1804

execute rdt.rdtAddMsg 119801, 10, '19801^UpdUCCFail',    'us_english',@nFunc





