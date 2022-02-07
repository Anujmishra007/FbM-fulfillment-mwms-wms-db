--rdt_895ExtUpdSP02
execute rdt.rdtdropmsg 159351 , 159400

execute rdt.rdtAddMsg 159351, 10, '159351^Upd RPL Fail',    'us_english',895
execute rdt.rdtAddMsg 159352, 10, '159352^UpdPickDetFail',  'us_english',895
execute rdt.rdtAddMsg 159353, 10, '159353^UpdUCCFail',      'us_english',895
execute rdt.rdtAddMsg 159354, 10, '159354^CreatePHdrFail',  'us_english',895
execute rdt.rdtAddMsg 159355, 10, '159355^PackCompleted',   'us_english',895
execute rdt.rdtAddMsg 159356, 10, '159356^NoLabelNoGen',    'us_english',895
execute rdt.rdtAddMsg 159357, 10, '159357^InsPackDetFail',  'us_english',895
execute rdt.rdtAddMsg 159358, 10, '159358^UpdReplenLogFail','us_english',895
execute rdt.rdtAddMsg 159359, 10, '159359^UpdRPLogFail',    'us_english',895
execute rdt.rdtAddMsg 159360, 10, '159360^UpdRPLogFail',    'us_english',895
execute rdt.rdtAddMsg 159361, 10, '159361^UpdPickDetFail',  'us_english',895
execute rdt.rdtAddMsg 159362, 10, '159362^UpdPickDetFail',  'us_english',895
execute rdt.rdtAddMsg 159363, 10, '159363^UpdPickDetFail',  'us_english',895
execute rdt.rdtAddMsg 159364, 10, '159364^GetDetKeyFail',   'us_english',895
execute rdt.rdtAddMsg 159365, 10, '159365^Ins PDtl Fail',   'us_english',895
execute rdt.rdtAddMsg 159366, 10, '159366^UpdPickDetFail',  'us_english',895
execute rdt.rdtAddMsg 159367, 10, '159367^UpdPickDetFail',  'us_english',895
execute rdt.rdtAddMsg 159368, 10, '159368^UpdReplenLogFail','us_english',895
execute rdt.rdtAddMsg 159369, 10, '159369^UpdPackHdrFail',  'us_english',895
execute rdt.rdtAddMsg 159370, 10, '159370^UpdRPLogFail',    'us_english',895
execute rdt.rdtAddMsg 159371, 10, '159371^UpdReplenLogFail','us_english',895
execute rdt.rdtAddMsg 159372, 10, '159372^InsPackInfoFail', 'us_english',895
execute rdt.rdtAddMsg 159373, 10, '159373^UpdPackInfoFail', 'us_english',895
execute rdt.rdtAddMsg 159374, 10, '159374^UpdRPLogFail',    'us_english',895
execute rdt.rdtAddMsg 159375, 10, '159375^UpdRPLogFail',    'us_english',895
execute rdt.rdtAddMsg 159376, 10, '159376^UpdRPLogFail',    'us_english',895
execute rdt.rdtAddMsg 159377, 10, '159377^UpdPickDetFail',  'us_english',895
execute rdt.rdtAddMsg 159378, 10, '159378^UpdPickDetFail',  'us_english',895
execute rdt.rdtAddMsg 159379, 10, '159379^GetDetKeyFail',   'us_english',895
execute rdt.rdtAddMsg 159380, 10, '159380^Ins PDtl Fail',   'us_english',895
execute rdt.rdtAddMsg 159381, 10, '159381^UpdPickDetFail',  'us_english',895
execute rdt.rdtAddMsg 159382, 10, '159382^UpdPickDetFail',  'us_english',895

SELECT * FROM RDT.RDTMsg (NOLOCK) WHERE Message_ID BETWEEN 159351 AND 159400