--rdt_513SuggID02
execute rdt.rdtDropMsg 184651,184700	

GO
DECLARE @nFunc INT

SET @nFunc = 513

execute rdt.rdtAddMsg 184651  ,10, '184651SUGGESTED ID:', 'us_english',@nFunc
execute rdt.rdtAddMsg 184652  ,10, '184652SUGGESTED LOC:', 'us_english',@nFunc


