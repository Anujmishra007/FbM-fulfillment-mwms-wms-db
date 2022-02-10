--rdt_1014ExtUpdSP01
execute rdt.rdtdropmsg 113351 , 113400
GO
DECLARE @nFunc INT

SET @nFunc = 1015

execute rdt.rdtAddMsg 113351, 10, '13351^DelMasterSerialFail',    'us_english',@nFunc
execute rdt.rdtAddMsg 113352, 10, '13352^InsMasterSerialFail',    'us_english',@nFunc
execute rdt.rdtAddMsg 113353, 10, '13353^DelMasterSerailFail',    'us_english',@nFunc
execute rdt.rdtAddMsg 113354, 10, '13354^InsMasterSerialFail',    'us_english',@nFunc
execute rdt.rdtAddMsg 113355, 10, '13355^UpdrdtSerailFail',       'us_english',@nFunc
execute rdt.rdtAddMsg 113356, 10, '13356^UpdrdtSerailFail',       'us_english',@nFunc
execute rdt.rdtAddMsg 113357, 10, '13357^DelMasterSerialFail',    'us_english',@nFunc
execute rdt.rdtAddMsg 113358, 10, '13358^InsMasterSerialFail',    'us_english',@nFunc
execute rdt.rdtAddMsg 113359, 10, '13359^DelMasterSerailFail',    'us_english',@nFunc
execute rdt.rdtAddMsg 113360, 10, '13360^InsMasterSerialFail',    'us_english',@nFunc
execute rdt.rdtAddMsg 113361, 10, '13361^UpdrdtSerailFail',       'us_english',@nFunc
execute rdt.rdtAddMsg 113362, 10, '13362^UpdrdtSerailFail',       'us_english',@nFunc
execute rdt.rdtAddMsg 113363, 10, '13363^InvSerialType',       'us_english',@nFunc
execute rdt.rdtAddMsg 113364, 10, '13364^SerialNoNotExist',       'us_english',@nFunc
execute rdt.rdtAddMsg 113365, 10, '13365^InvalidSKU',       'us_english',@nFunc
execute rdt.rdtAddMsg 113366, 10, '13366^InsrdtSerailFail',       'us_english',@nFunc
execute rdt.rdtAddMsg 113367, 10, '13367^UpdrdtSerailFail',       'us_english',@nFunc
execute rdt.rdtAddMsg 113368, 10, '13368^UpdrdtSerailFail',       'us_english',@nFunc
