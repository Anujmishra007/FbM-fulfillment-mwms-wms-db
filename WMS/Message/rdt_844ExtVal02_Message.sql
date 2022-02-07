--rdt_844ExtVal02
execute rdt.rdtdropmsg 133251 , 133300
GO
DECLARE @nFunc INT

SET @nFunc = 844

execute rdt.rdtAddMsg 133251, 10, '33251^ID NotOnStage',    'us_english',@nFunc
execute rdt.rdtAddMsg 133252, 10, '33252^CopackItemKeyInBT',    'us_english',@nFunc
execute rdt.rdtAddMsg 133253, 10, '33253^IDMoreThan1Order',    'us_english',@nFunc


