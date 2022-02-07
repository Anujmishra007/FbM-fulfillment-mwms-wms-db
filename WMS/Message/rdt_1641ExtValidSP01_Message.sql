
--rdt_1641ExtValidSP01
-- 85351 - 85400

exec rdt.rdtDropMsg 85351 , 85400
-- **********************************************
GO
DECLARE @nFunc INT

SET @nFunc = 1641

execute rdt.rdtAddMsg 85351 ,10, '85351^DiffConsignee', 'us_english',@nFunc
execute rdt.rdtAddMsg 85352 ,10, '85352^UCC# Exists', 'us_english',@nFunc
execute rdt.rdtAddMsg 85353 ,10, '85353^InvalidCaseID', 'us_english',@nFunc
execute rdt.rdtAddMsg 85354 ,10, '85354^DiffConsignee', 'us_english',@nFunc
execute rdt.rdtAddMsg 85355 ,10, '85355^MultiConsignee', 'us_english',@nFunc
execute rdt.rdtAddMsg 85356 ,10, '85356^DiffConsignee', 'us_english',@nFunc