--rdt_1804ExtValidSP05
--execute rdt.rdtdropmsg 118951 - 119000
GO
DECLARE @nFunc INT

SET @nFunc = 1804

execute rdt.rdtAddMsg 118951, 10, '18951^MultiLot',    'us_english',@nFunc
execute rdt.rdtAddMsg 118952, 10, '18952^MultiLot','us_english',@nFunc




