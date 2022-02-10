
--rdt_595ExtValidSP01
-- 92401 - 92450

exec rdt.rdtDropMsg 92401 - 92450
-- **********************************************
GO
DECLARE @nFunc INT

SET @nFunc = 595

execute rdt.rdtAddMsg 92401 ,10, '92401^UCCNotFound', 'us_english',@nFunc
execute rdt.rdtAddMsg 92402 ,10, '92402^MultiASNFound', 'us_english',@nFunc


