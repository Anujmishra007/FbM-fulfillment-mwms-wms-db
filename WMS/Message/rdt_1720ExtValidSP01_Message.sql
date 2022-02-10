--rdt_1720ExtValidSP01
--execute rdt.rdtdropmsg 99101 - 99150
GO
DECLARE @nFunc INT

SET @nFunc = 1720

execute rdt.rdtAddMsg 99101 ,10, '99101^DiffConsignee', 'us_english',@nFunc




