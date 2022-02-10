
--rdt_921ExtValidSP01
-- 91901 - 91950

exec rdt.rdtDropMsg 91901 - 91950
-- **********************************************
GO
DECLARE @nFunc INT

SET @nFunc = 921

execute rdt.rdtAddMsg 91901 ,10, '91901^DropIDNotClose', 'us_english',@nFunc
execute rdt.rdtAddMsg 91902 ,10, '91902^DuplicateSealNo', 'us_english',@nFunc

