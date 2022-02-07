--rdt_1819ExtUpd05
--execute rdt.rdtdropmsg 113051 - 113100
GO
DECLARE @nFunc INT

SET @nFunc = 1819

execute rdt.rdtAddMsg 113051 ,10, '13051^nspg_getkey', 'us_english',@nFunc
execute rdt.rdtAddMsg 113052 ,10, '13052^InsTaskDetFail', 'us_english',@nFunc 
execute rdt.rdtAddMsg 113053 ,10, '13053^UpdTaskDetFail', 'us_english',@nFunc 



