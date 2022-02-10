
--rdt_529ExtValidateSP01
-- 84051 , 84100

exec rdt.rdtDropMsg 84901 , 84950
-- **********************************************
GO
DECLARE @nFunc INT

SET @nFunc = 529

execute rdt.rdtAddMsg 84901 ,10, '84901^DiffConsignee', 'us_english',@nFunc
execute rdt.rdtAddMsg 84902 ,10, '84902^DiffBuyerPO', 'us_english',@nFunc
execute rdt.rdtAddMsg 84903 ,10, '84903^DiffGender', 'us_english',@nFunc
