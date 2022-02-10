--rdtfnc_SerialNo_Capture
execute rdt.rdtdropmsg 111351 , 111400
GO
DECLARE @nFunc INT

SET @nFunc = 824

execute rdt.rdtAddMsg 111351, 10, '11351^ToteIDReq',    'us_english',@nFunc
execute rdt.rdtAddMsg 111352, 10, '11352^SKUReq',    'us_english',@nFunc
execute rdt.rdtAddMsg 111353, 10, '11353^InvalidSKU',    'us_english',@nFunc
execute rdt.rdtAddMsg 111354, 10, '11354^MultiSKUBarCod',    'us_english',@nFunc
execute rdt.rdtAddMsg 111355, 10, '11355^MasterSerialReq',    'us_english',@nFunc
execute rdt.rdtAddMsg 111356, 10, '11356^InvMasterSerialNo',    'us_english',@nFunc
execute rdt.rdtAddMsg 111357, 10, '11357^SerialNoReq',    'us_english',@nFunc
execute rdt.rdtAddMsg 111358, 10, '11358^InvSerialNo',    'us_english',@nFunc
execute rdt.rdtAddMsg 111359, 10, '11359^InsDataCaptureFail',    'us_english',@nFunc
execute rdt.rdtAddMsg 111360, 10, '11360^OptionReq',    'us_english',@nFunc
execute rdt.rdtAddMsg 111361, 10, '11361^InvOption',    'us_english',@nFunc
execute rdt.rdtAddMsg 111362, 10, '11362^SerialNoScanned',    'us_english',@nFunc
