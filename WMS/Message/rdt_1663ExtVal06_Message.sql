--rdt_1663ExtVal06
--execute rdt.rdtdropmsg 130601 - 130650
GO
DECLARE @nFunc INT

SET @nFunc = 1663

execute rdt.rdtAddMsg 130601, 10, '30601^OrderInDiffPLT',    'us_english',@nFunc
execute rdt.rdtAddMsg 130602, 10, '30602^OrderInDiffPLT',    'us_english',@nFunc
execute rdt.rdtAddMsg 130603, 10, '30603^NotAllScanned',    'us_english',@nFunc
execute rdt.rdtAddMsg 130604, 10, '30604^TrackNoDiffMBOLKey',    'us_english',@nFunc
execute rdt.rdtAddMsg 130605, 10, '30605^DiffShipperKey',    'us_english',@nFunc
execute rdt.rdtAddMsg 130606, 10, '30606^DiffSUSR1',    'us_english',@nFunc



