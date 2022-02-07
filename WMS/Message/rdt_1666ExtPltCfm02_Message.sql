--rdt_1666ExtPltCfm02
rdt.rdtDropMsg 178651, 178700

execute rdt.rdtAddMsg 178651, 10, '178651^INS MBOL Fail',     'us_english', 1666
execute rdt.rdtAddMsg 178652, 10, '178652^INS MBDtlFail',     'us_english', 1666

SELECT * FROM RDT.RDTMSG (NOLOCK) WHERE MESSAGE_ID BETWEEN 178651 AND 178700