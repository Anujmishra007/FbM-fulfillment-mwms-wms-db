--rdtfnc_ECOMM
--execute rdt.rdtdropmsg 101401 , 101450

GO
DECLARE @nFunc INT

SET @nFunc = 842

execute rdt.rdtAddMsg 101401, 10, '01401^DropIDReq',    'us_english',@nFunc
execute rdt.rdtAddMsg 101402, 10, '01402^Invalid SKU',    'us_english',@nFunc
execute rdt.rdtAddMsg 101403, 10, '01403^Invalid SKU',    'us_english',@nFunc
execute rdt.rdtAddMsg 101404, 10, '01404^SKU Req',    'us_english',@nFunc
execute rdt.rdtAddMsg 101405, 10, '01405^TrackNoReq',    'us_english',@nFunc
execute rdt.rdtAddMsg 101406, 10, '01406^TrackNoExist',    'us_english',@nFunc
execute rdt.rdtAddMsg 101407, 10, '01407^CtnTypeReq',    'us_english',@nFunc
execute rdt.rdtAddMsg 101408, 10, '01408^WeightReq',    'us_english',@nFunc
execute rdt.rdtAddMsg 101409, 10, '01409^InvCtnType',    'us_english',@nFunc
execute rdt.rdtAddMsg 101410, 10, '01410^InvalidWeight',    'us_english',@nFunc
execute rdt.rdtAddMsg 101411, 10, '01411^OptionReq',    'us_english',@nFunc
execute rdt.rdtAddMsg 101412, 10, '01412^InvalidOption',    'us_english',@nFunc
execute rdt.rdtAddMsg 101413, 10, '01413^OptionReq',    'us_english',@nFunc
execute rdt.rdtAddMsg 101414, 10, '01414^InvalidOption',    'us_english',@nFunc
execute rdt.rdtAddMsg 101415, 10, '01415^WgtOutOfRange',    'us_english',@nFunc
execute rdt.rdtAddMsg 101416, 10, '01416^SKuNotIntote',    'us_english',@nFunc
execute rdt.rdtAddMsg 101417, 10, '01417^QtyExceeded',    'us_english',@nFunc

--WMS-16541
execute rdt.rdtAddMsg 101418, 10, '01418^Multi Tote Ord',    'us_english',@nFunc