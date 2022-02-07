
-- rdt_608ExtUpd02 97701 - 97750

exec rdt.rdtDropMsg 97701 - 97750
-- **********************************************
GO
DECLARE @nFunc INT

SET @nFunc = 608

execute rdt.rdtAddMsg 97701 ,10, '97701^InsRFPAFail', 'us_english',@nFunc
execute rdt.rdtAddMsg 97702 ,10, '97702^InsRFPAFail', 'us_english',@nFunc
execute rdt.rdtAddMsg 97703 ,10, '97703^NoLocFound', 'us_english',@nFunc




