--rdt_897ExtUpdSP01
execute rdt.rdtdropmsg 115751 , 115800
GO
DECLARE @nFunc INT

SET @nFunc = 897

execute rdt.rdtAddMsg 115751, 10, '15751^GetUCCKeyFail',    'us_english',@nFunc
execute rdt.rdtAddMsg 115752, 10, '15752^GetUCCKeyFail',    'us_english',@nFunc
execute rdt.rdtAddMsg 115753, 10, '15753^InsUCCFail',    'us_english',@nFunc
execute rdt.rdtAddMsg 115754, 10, '15754^UpdUCCFail',    'us_english',@nFunc
execute rdt.rdtAddMsg 115755, 10, '15755^UpdUCCFail',    'us_english',@nFunc
execute rdt.rdtAddMsg 115756, 10, '15756^LabelPrnterReq',    'us_english',@nFunc
execute rdt.rdtAddMsg 115757, 10, '15757^DWNOTSETUP',    'us_english',@nFunc
execute rdt.rdtAddMsg 115758, 10, '15758^TargetDBNotSet',    'us_english',@nFunc
