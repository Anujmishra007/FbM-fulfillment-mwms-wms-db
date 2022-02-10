--rdt_1580RcptCfm16
execute rdt.rdtDropMsg 151551, 151600

execute rdt.rdtAddMsg 151551, 10, '51551^INS UCC FAIL', 'us_english', 1580
execute rdt.rdtAddMsg 151552, 10, '51552^INS UCC FAIL', 'us_english', 1580
execute rdt.rdtAddMsg 151553, 10, '51553^UPD UCC FAIL', 'us_english', 1580
execute rdt.rdtAddMsg 151554, 10, '51554^UPD L01 FAIL', 'us_english', 1580

SELECT * FROM RDT.RDTMsg (NOLOCK) WHERE Message_ID BETWEEN 151551 AND 151600