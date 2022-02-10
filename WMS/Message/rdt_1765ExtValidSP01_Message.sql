--rdt_1765ExtValidSP01
--execute rdt.rdtdropmsg 111551 - 111600
GO
DECLARE @nFunc INT

SET @nFunc = 1765

execute rdt.rdtAddMsg 111551 ,10, '11551^LocReserved', 'us_english',@nFunc
execute rdt.rdtAddMsg 111552 ,10, '11552^LocReserved', 'us_english',@nFunc
execute rdt.rdtAddMsg 111553 ,10, '11553^LocReserved', 'us_english',@nFunc

