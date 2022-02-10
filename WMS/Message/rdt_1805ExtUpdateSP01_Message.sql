
--rdt_1805ExtUpdSP01
-- 91701 - 91750

exec rdt.rdtDropMsg 91701 , 91750
-- **********************************************
GO
DECLARE @nFunc INT

SET @nFunc = 1805

execute rdt.rdtAddMsg 91701 ,10, '91701^UpdDropIDFail', 'us_english',@nFunc
execute rdt.rdtAddMsg 91702 ,10, '91702^UpdPTLFail', 'us_english',@nFunc
execute rdt.rdtAddMsg 91703 ,10, '91703^InsDPLogFail', 'us_english',@nFunc
execute rdt.rdtAddMsg 91704 ,10, '91704^InsDropIDFail', 'us_english',@nFunc
execute rdt.rdtAddMsg 91705 ,10, '91705^UpdDPLogFail', 'us_english',@nFunc
execute rdt.rdtAddMsg 91706 ,10, '91706^CloseToteDone', 'us_english',@nFunc
execute rdt.rdtAddMsg 91707 ,10, '91707^UpdDeviceProfileFail', 'us_english',@nFunc
execute rdt.rdtAddMsg 91708 ,10, '91708^UpdDeviceProfileLogFail', 'us_english',@nFunc
execute rdt.rdtAddMsg 91709 ,10, '91709^InvalidDropID', 'us_english',@nFunc
execute rdt.rdtAddMsg 91710 ,10, '91710^UpdDPLogFail', 'us_english',@nFunc
execute rdt.rdtAddMsg 91711 ,10, '91711^UpdDeviceProfileFail', 'us_english',@nFunc
execute rdt.rdtAddMsg 91712 ,10, '91712^InvalidDPKey', 'us_english',@nFunc
execute rdt.rdtAddMsg 91713 ,10, '91713^UpdPTSLogFail', 'us_english',@nFunc