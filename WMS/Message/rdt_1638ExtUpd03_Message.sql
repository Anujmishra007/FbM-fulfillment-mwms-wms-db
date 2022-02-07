--rdt_1638ExtUpd03
execute rdt.rdtDropMsg 162251 , 162300

execute rdt.rdtAddMsg 162251, 10, '62251^No OrderKey',      'us_english', 1638
execute rdt.rdtAddMsg 162252, 10, '62252^NO ORDERKEY',      'us_english', 1638
execute rdt.rdtAddMsg 162253, 10, '62253^INS MBOL Fail',    'us_english', 1638
execute rdt.rdtAddMsg 162254, 10, '62254^MBOL shipped',     'us_english', 1638
execute rdt.rdtAddMsg 162255, 10, '62255^MBOL FAC Diff',    'us_english', 1638
execute rdt.rdtAddMsg 162256, 10, '62256^INS MBDtl Fail',   'us_english', 1638
execute rdt.rdtAddMsg 162257, 10, '62257^UPD MBDtl Fail',   'us_english', 1638

SELECT * FROM RDT.RDTMSG (NOLOCK) WHERE Message_ID BETWEEN 162251 AND 162300

