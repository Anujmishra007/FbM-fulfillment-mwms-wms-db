
--rdt_529ExtUpdateSP02
-- 85051 - 85100

exec rdt.rdtDropMsg 85051 , 85100
-- **********************************************
GO
DECLARE @nFunc INT

SET @nFunc = 529

execute rdt.rdtAddMsg 85051 ,10, '85051^GetDetKeyfail', 'us_english',@nFunc
execute rdt.rdtAddMsg 85052 ,10, '85052^UpdPDtlFail', 'us_english',@nFunc
