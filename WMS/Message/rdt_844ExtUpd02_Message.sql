--rdt_844ExtUpd02
execute rdt.rdtdropmsg 133301 - 133350
GO
DECLARE @nFunc INT

SET @nFunc = 844

execute rdt.rdtAddMsg 133301, 10, '33301^QTY not match',    'us_english',@nFunc
execute rdt.rdtAddMsg 133302, 10, '33302^IDMoreThan1Ord',    'us_english',@nFunc
execute rdt.rdtAddMsg 133303, 10, '33303^UpdPPAFail',    'us_english',@nFunc
execute rdt.rdtAddMsg 133304, 10, '33304^CopackItemKeyInBT',    'us_english',@nFunc

