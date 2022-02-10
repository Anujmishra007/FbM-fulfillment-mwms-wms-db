--rdt_897ExtValid01
execute rdt.rdtdropmsg 115701 , 115750
GO
DECLARE @nFunc INT

SET @nFunc = 897

execute rdt.rdtAddMsg 115701, 10, '15701^UCCNotExist',    'us_english',@nFunc
execute rdt.rdtAddMsg 115702, 10, '15702^ASNNotExist',    'us_english',@nFunc
execute rdt.rdtAddMsg 115703, 10, '15703^POKeyNotSetup',    'us_english',@nFunc

