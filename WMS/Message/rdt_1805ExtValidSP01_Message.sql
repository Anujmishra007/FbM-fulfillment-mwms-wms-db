
--rdt_1805ExtValidSP01
-- 91651 - 91700

exec rdt.rdtDropMsg 91651 - 91700
-- **********************************************
GO
DECLARE @nFunc INT

SET @nFunc = 1805

execute rdt.rdtAddMsg 91651 ,10, '91651^InvalidDropID', 'us_english',@nFunc
execute rdt.rdtAddMsg 91652 ,10, '91652^InvalidDropID', 'us_english',@nFunc
execute rdt.rdtAddMsg 91653 ,10, '91653^InvalidDropID', 'us_english',@nFunc
