--rdt_1720ExtUpdSP01
--execute rdt.rdtdropmsg 94601 - 94650
GO
DECLARE @nFunc INT

SET @nFunc = 1720

execute rdt.rdtAddMsg 94601, 10, '94601^UpdPalletDetFail',    'us_english',@nFunc
execute rdt.rdtAddMsg 94602, 10, '94602^UpdPalletFail',    'us_english',@nFunc
execute rdt.rdtAddMsg 94603, 10, '94603^UpdPalletDetFail',    'us_english',@nFunc
execute rdt.rdtAddMsg 94604, 10, '94604^UpdPalletFail',    'us_english',@nFunc
execute rdt.rdtAddMsg 94605, 10, '94605^InvalidToPallet',    'us_english',@nFunc
execute rdt.rdtAddMsg 94606, 10, '94606^InvalidToPallet',    'us_english',@nFunc
