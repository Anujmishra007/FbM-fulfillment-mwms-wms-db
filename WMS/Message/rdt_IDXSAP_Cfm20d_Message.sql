-- rdt_IDXSAP_Cfm20d
-- EXEC RDT.RDTDROPMSG 88451 , 88500


execute rdt.rdtAddMsg 88451, 10, '88451^LBL MULTI SCAN', 'us_english', 543
execute rdt.rdtAddMsg 88452, 10, '88452^MULTI ORDERKEY', 'us_english', 543
execute rdt.rdtAddMsg 88453, 10, '88453^NO ORDERKEY',    'us_english', 543
execute rdt.rdtAddMsg 88454, 10, '88454^UPD PKDtl Fail', 'us_english', 543
execute rdt.rdtAddMsg 88455, 10, '88455^UPD PKDtl Fail', 'us_english', 543
execute rdt.rdtAddMsg 88456, 10, '88456^GetKey Fail   ', 'us_english', 543
execute rdt.rdtAddMsg 88457, 10, '88457^INS PKDtl Fail', 'us_english', 543
execute rdt.rdtAddMsg 88458, 10, '88458^UPD PKDtl Fail', 'us_english', 543
execute rdt.rdtAddMsg 88459, 10, '88459^UPD PKDtl Fail', 'us_english', 543
execute rdt.rdtAddMsg 88460, 10, '88460^Offset Fail   ', 'us_english', 543
execute rdt.rdtAddMsg 88461, 10, '88461^GetKey Fail   ', 'us_english', 543
execute rdt.rdtAddMsg 88462, 10, '88462^INSPackHdrFail', 'us_english', 543
execute rdt.rdtAddMsg 88463, 10, '88463^UPDPackDtlFail', 'us_english', 543
execute rdt.rdtAddMsg 88464, 10, '88464^INSPackDtlFail', 'us_english', 543
execute rdt.rdtAddMsg 88465, 10, '88465^INSPackDtlFail', 'us_english', 543
execute rdt.rdtAddMsg 88466, 10, '88466^SCANIN FAIL',    'us_english', 543
execute rdt.rdtAddMsg 88467, 10, '88467^Fail PackCfm  ', 'us_english', 543
execute rdt.rdtAddMsg 88468, 10, '88468^SCAN OUT FAIL',  'us_english', 543
execute rdt.rdtAddMsg 88469, 10, '88469^INS PINFO FAIL', 'us_english', 543
execute rdt.rdtAddMsg 88470, 10, '88470^UPD PINFO FAIL', 'us_english', 543
execute rdt.rdtAddMsg 88471, 10, '88471^INV LABEL LEN',  'us_english', 543

-- SELECT * FROM RDT.RDTMSG (NOLOCK) WHERE MESSAGE_ID BETWEEN 88451 AND 88500
