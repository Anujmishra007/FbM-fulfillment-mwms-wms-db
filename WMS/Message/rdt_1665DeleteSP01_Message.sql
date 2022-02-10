--rdt_1665DeleteSP01
rdt.rdtDropMsg 160001 , 160050

execute rdt.rdtAddMsg 160001, 10, '60001^UPD PLDtl Fail',    'us_english', 1665
execute rdt.rdtAddMsg 160002, 10, '60002^UPD PLDtl Fail',    'us_english', 1665
execute rdt.rdtAddMsg 160003, 10, '60003^DEL PLDtl Fail',    'us_english', 1665
execute rdt.rdtAddMsg 160004, 10, '60004^UPD PLDtl Fail',    'us_english', 1665
execute rdt.rdtAddMsg 160005, 10, '60005^DEL MBDtl Fail',    'us_english', 1665

SELECT * FROM RDT.RDTMSG (NOLOCK) WHERE MESSAGE_ID BETWEEN 160001 AND 160050