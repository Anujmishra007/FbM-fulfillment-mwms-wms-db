--rdt_1620ExtValid01
execute rdt.rdtdropmsg 56501 , 56550

execute rdt.rdtAddMsg '56501', 10, '56501^INVALID DROPID',  'us_english'
execute rdt.rdtAddMsg '56502', 10, '56502^DEL DDTL FAIL',   'us_english'
execute rdt.rdtAddMsg '56503', 10, '56503^DEL DID FAIL',    'us_english'
execute rdt.rdtAddMsg '56504', 10, '56504^INS DID FAIL',    'us_english'
execute rdt.rdtAddMsg '56505', 10, '56505^INS DDTL FAIL',   'us_english'
execute rdt.rdtAddMsg '56506', 10, '56506^INS DDTL FAIL',   'us_english'
execute rdt.rdtAddMsg '56507', 10, '56507^INVALID DROPID',  'us_english'
execute rdt.rdtAddMsg '56508', 10, '56508^UPD DID FAIL',    'us_english'
execute rdt.rdtAddMsg '56509', 10, '56509^UPD DID FAIL',    'us_english'
execute rdt.rdtAddMsg '56510', 10, '56510^INVALID DROPID',  'us_english'
execute rdt.rdtAddMsg '56511', 10, '56511^DEL DDTL FAIL',   'us_english'
execute rdt.rdtAddMsg '56512', 10, '56512^DEL DID FAIL',    'us_english'

SELECT * FROM RDT.RDTMSG (NOLOCK) WHERE MESSAGE_ID BETWEEN 56501 AND 56550

