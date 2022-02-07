-- rdt_DPRPL01, 81601 - 81650
--execute rdt.rdtDropMsg 81601,  81650

GO
DECLARE @nFunc INT

SET @nFunc = 941

execute rdt.rdtAddMsg 81601 ,10, '81601^InvalidVFCOO', 'us_english',@nFunc


