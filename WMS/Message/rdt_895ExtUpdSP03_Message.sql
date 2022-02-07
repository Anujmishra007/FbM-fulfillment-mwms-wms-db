--rdt_895ExtUpdSP03
execute rdt.rdtdropmsg 163951 , 164000

execute rdt.rdtAddMsg 163951, 10, '163951^Upd RPL Fail',    'us_english',895
execute rdt.rdtAddMsg 163952, 10, '163952^UpdPickDetFail',  'us_english',895
execute rdt.rdtAddMsg 163953, 10, '163953^UpdUCCFail',      'us_english',895
execute rdt.rdtAddMsg 163954, 10, '163954^CreatePHdrFail',  'us_english',895
execute rdt.rdtAddMsg 163955, 10, '163955^PackCompleted',   'us_english',895
execute rdt.rdtAddMsg 163956, 10, '163956^NoLabelNoGen',    'us_english',895
execute rdt.rdtAddMsg 163957, 10, '163957^InsPackDetFail',  'us_english',895
execute rdt.rdtAddMsg 163958, 10, '163958^UpdReplenLogFail','us_english',895
execute rdt.rdtAddMsg 163959, 10, '163959^UpdRPLogFail',    'us_english',895
execute rdt.rdtAddMsg 163960, 10, '163960^UpdRPLogFail',    'us_english',895
execute rdt.rdtAddMsg 163961, 10, '163961^UpdPickDetFail',  'us_english',895
execute rdt.rdtAddMsg 163962, 10, '163962^UpdPickDetFail',  'us_english',895
execute rdt.rdtAddMsg 163963, 10, '163963^UpdPickDetFail',  'us_english',895
execute rdt.rdtAddMsg 163964, 10, '163964^GetDetKeyFail',   'us_english',895
execute rdt.rdtAddMsg 163965, 10, '163965^Ins PDtl Fail',   'us_english',895
execute rdt.rdtAddMsg 163966, 10, '163966^UpdPickDetFail',  'us_english',895
execute rdt.rdtAddMsg 163967, 10, '163967^UpdPickDetFail',  'us_english',895
execute rdt.rdtAddMsg 163968, 10, '163968^UpdReplenLogFail','us_english',895
execute rdt.rdtAddMsg 163969, 10, '163969^UpdPackHdrFail',  'us_english',895
execute rdt.rdtAddMsg 163970, 10, '163970^UpdRPLogFail',    'us_english',895
execute rdt.rdtAddMsg 163971, 10, '163971^UpdReplenLogFail','us_english',895
execute rdt.rdtAddMsg 163972, 10, '163972^InsPackInfoFail', 'us_english',895
execute rdt.rdtAddMsg 163973, 10, '163973^UpdPackInfoFail', 'us_english',895
execute rdt.rdtAddMsg 163974, 10, '163974^UpdRPLogFail',    'us_english',895
execute rdt.rdtAddMsg 163975, 10, '163975^UpdRPLogFail',    'us_english',895
execute rdt.rdtAddMsg 163976, 10, '163976^UpdRPLogFail',    'us_english',895
execute rdt.rdtAddMsg 163977, 10, '163977^UpdPickDetFail',  'us_english',895
execute rdt.rdtAddMsg 163978, 10, '163978^UpdPickDetFail',  'us_english',895
execute rdt.rdtAddMsg 163979, 10, '163979^GetDetKeyFail',   'us_english',895
execute rdt.rdtAddMsg 163980, 10, '163980^Ins PDtl Fail',   'us_english',895
execute rdt.rdtAddMsg 163981, 10, '163981^UpdPickDetFail',  'us_english',895
execute rdt.rdtAddMsg 163982, 10, '163982^UpdPickDetFail',  'us_english',895

SELECT * FROM RDT.RDTMsg (NOLOCK) WHERE Message_ID BETWEEN 163951 AND 164000