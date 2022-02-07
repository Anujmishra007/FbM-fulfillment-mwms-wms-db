--rdt_1664ExtUpdSP03
--execute rdt.rdtdropmsg 94251 - 94300
GO
DECLARE @nFunc INT

SET @nFunc = 1664

execute rdt.rdtAddMsg 94251, 10, '94251^UpdMBOLDetFail',    'us_english',@nFunc
