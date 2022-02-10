
--rdt_PTL_PTS_InsertPTLTran
-- 83900 - 83950

exec rdt.rdtDropMsg 83900 , 83950
-- **********************************************
GO
DECLARE @nFunc INT

SET @nFunc = 816

execute rdt.rdtAddMsg 83900 ,10, '83900^UpdPTLTranFail', 'us_english',@nFunc
execute rdt.rdtAddMsg 83901 ,10, '83901^UpdDeviceProfileFail', 'us_english',@nFunc
execute rdt.rdtAddMsg 83902 ,10, '83902^UpdDeviceProfileLogFail', 'us_english',@nFunc
execute rdt.rdtAddMsg 83903 ,10, '83903^UpdDeviceProfileLogFail', 'us_english',@nFunc
execute rdt.rdtAddMsg 83904 ,10, '83904^UpdDropIDFail', 'us_english',@nFunc
execute rdt.rdtAddMsg 83905 ,10, '83905^NoPackTask', 'us_english',@nFunc
execute rdt.rdtAddMsg 83906 ,10, '83906^PackLightNotMatch', 'us_english',@nFunc
execute rdt.rdtAddMsg 83900 ,10, '83900^UpdPTLTranFail', 'us_english',@nFunc
execute rdt.rdtAddMsg 83900 ,10, '83900^UpdPTLTranFail', 'us_english',@nFunc
