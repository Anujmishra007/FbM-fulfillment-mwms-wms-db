--rdt_1819ExtUpd07
--execute rdt.rdtdropmsg 119451 , 119500
GO
DECLARE @nFunc INT

SET @nFunc = 1819

execute rdt.rdtAddMsg 119451 ,10, '19451^nspg_getkey', 'us_english',@nFunc
execute rdt.rdtAddMsg 119452 ,10, '19452^InsTaskDetFail', 'us_english',@nFunc 
execute rdt.rdtAddMsg 119453 ,10, '19453^nspg_getkey', 'us_english',@nFunc
execute rdt.rdtAddMsg 119454 ,10, '19454^InsTaskDetFail', 'us_english',@nFunc 


