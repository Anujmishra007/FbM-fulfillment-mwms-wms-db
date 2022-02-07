--rdt_805ExtValidSP01
--execute rdt.rdtdropmsg 102551 , 102600
GO
DECLARE @nFunc INT

SET @nFunc = 805

execute rdt.rdtAddMsg 102551, 10, '02551^PTSNotAssign',    'us_english',@nFunc