--rdt_1819ExtPASP09
--execute rdt.rdtdropmsg 113951 , 114000
GO
DECLARE @nFunc INT

SET @nFunc = 1819

execute rdt.rdtAddMsg 113951 ,10, '13951^StrategyNotSet', 'us_english',@nFunc
execute rdt.rdtAddMsg 113952 ,10, '13952^BadStrategyKey', 'us_english',@nFunc 
execute rdt.rdtAddMsg 113953 ,10, '13953^NoSuggLocFound', 'us_english',@nFunc 



