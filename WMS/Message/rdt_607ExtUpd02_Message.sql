--rdt_607ExtUpd02
--execute rdt.rdtDropMsg 118001 - 118050

GO
DECLARE @nFunc INT

SET @nFunc = 607

execute rdt.rdtAddMsg 118001 ,10, '18001^NoLoginPrinter', 'us_english',@nFunc




