--rdt_513SuggID02
--execute rdt.rdtDropMsg 180011 £¬ 180020

GO
DECLARE @nFunc INT

SET @nFunc = 513

execute rdt.rdtAddMsg 180011 ,10, '180011^SUGGESTED ID:', 'us_english',@nFunc
execute rdt.rdtAddMsg 180012 ,10, '180012^SUGGESTED LOC:      ', 'us_english',@nFunc


