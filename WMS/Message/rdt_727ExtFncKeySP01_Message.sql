
--rdt_727ExtFuncKeySP01

exec rdt.rdtDropMsg 133351 , 133400
-- **********************************************
GO
DECLARE @nFunc INT

SET @nFunc = 727

execute rdt.rdtAddMsg 133351 ,10, '33351^NotMultiOrder', 'us_english',@nFunc
execute rdt.rdtAddMsg 133352 ,10, '33352^PaperPrinterReq', 'us_english',@nFunc
execute rdt.rdtAddMsg 133353 ,10, '33353^PrintJobSent', 'us_english',@nFunc

--WMS-9394
execute rdt.rdtAddMsg 133354 ,10, '33353^Upd DropID Err', 'us_english',@nFunc








