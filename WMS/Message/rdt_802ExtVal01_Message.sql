--rdt_802ExtVal01
execute rdt.rdtdropmsg 123451 , 123500
GO
DECLARE @nFunc INT

SET @nFunc = 802

execute rdt.rdtAddMsg 123451, 10, '23451^WaveInProgress',    'us_english',@nFunc




