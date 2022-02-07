
--rdt_1765ExtUpdSP01
-- 90351 - 90400

exec rdt.rdtDropMsg 90351 , 90400
-- **********************************************
GO
DECLARE @nFunc INT

SET @nFunc = 1765

execute rdt.rdtAddMsg 90351 ,10, '90351^UpdTaskDetFail', 'us_english',@nFunc
execute rdt.rdtAddMsg 90352 ,10, '90352^UpdTransferDetFail', 'us_english',@nFunc
execute rdt.rdtAddMsg 90353 ,10, '90353^FinaLizeTransferFail', 'us_english',@nFunc
execute rdt.rdtAddMsg 90354 ,10, '90354^UCCReq', 'us_english',@nFunc



