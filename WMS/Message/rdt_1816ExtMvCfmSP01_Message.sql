--rdt_1816ExtMvCfmSP01
execute rdt.rdtdropmsg 169201, 169250

execute rdt.rdtAddMsg 169201, 10, '169201 UPD Task Fail', 'us_english', 1816

SELECT * FROM rdt.RDTMsg (NOLOCK) WHERE Message_ID BETWEEN 169201 AND 169250