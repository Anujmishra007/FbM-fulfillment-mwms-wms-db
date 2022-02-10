--rdt_573ExtValidSP01
execute rdt.rdtdropmsg 109351 , 109400
GO
DECLARE @nFunc INT

SET @nFunc = 573

execute rdt.rdtAddMsg 109351, 10, '09351^IDTypeNotMatch',    'us_english',@nFunc
