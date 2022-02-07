-- rdt_IDXSAP_Cfm16d
-- EXEC RDT.RDTDROPMSG 88401 , 88450

execute rdt.rdtAddMsg 88401, 10, '88401^LBL MULTI SCAN', 'us_english', 543
execute rdt.rdtAddMsg 88402, 10, '88402^MULTI ORDERKEY', 'us_english', 543
execute rdt.rdtAddMsg 88403, 10, '88403^NO ORDERKEY',    'us_english', 543
execute rdt.rdtAddMsg 88404, 10, '88404^UPD PKDtl Fail', 'us_english', 543
execute rdt.rdtAddMsg 88405, 10, '88405^UPD PKDtl Fail', 'us_english', 543
execute rdt.rdtAddMsg 88406, 10, '88406^GetKey Fail   ', 'us_english', 543
execute rdt.rdtAddMsg 88407, 10, '88407^INS PKDtl Fail', 'us_english', 543
execute rdt.rdtAddMsg 88408, 10, '88408^UPD PKDtl Fail', 'us_english', 543
execute rdt.rdtAddMsg 88409, 10, '88409^UPD PKDtl Fail', 'us_english', 543
execute rdt.rdtAddMsg 88410, 10, '88410^Offset Fail   ', 'us_english', 543
execute rdt.rdtAddMsg 88411, 10, '88411^GetKey Fail   ', 'us_english', 543
execute rdt.rdtAddMsg 88412, 10, '88412^INSPackHdrFail', 'us_english', 543
execute rdt.rdtAddMsg 88413, 10, '88413^UPDPackDtlFail', 'us_english', 543
execute rdt.rdtAddMsg 88414, 10, '88414^INSPackDtlFail', 'us_english', 543
execute rdt.rdtAddMsg 88415, 10, '88415^INSPackDtlFail', 'us_english', 543
execute rdt.rdtAddMsg 88416, 10, '88416^SCANIN FAIL',    'us_english', 543
execute rdt.rdtAddMsg 88417, 10, '88417^Fail PackCfm  ', 'us_english', 543
execute rdt.rdtAddMsg 88418, 10, '88418^SCAN OUT FAIL',  'us_english', 543
execute rdt.rdtAddMsg 88419, 10, '88419^INS PINFO FAIL', 'us_english', 543
execute rdt.rdtAddMsg 88420, 10, '88420^UPD PINFO FAIL', 'us_english', 543
execute rdt.rdtAddMsg 88421, 10, '88421^INV LABEL LEN',  'us_english', 543

-- SELECT * FROM RDT.RDTMSG (NOLOCK) WHERE MESSAGE_ID BETWEEN 88401 AND 88450
