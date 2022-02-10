--rdt_876ExtValidSP01
--execute rdt.rdtdropmsg 96401 - 96450
GO
DECLARE @nFunc INT

SET @nFunc = 876

execute rdt.rdtAddMsg 96401 ,10, '96401^OverScanned', 'us_english',@nFunc




