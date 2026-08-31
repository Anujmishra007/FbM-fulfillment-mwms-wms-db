--rdt_573ExtScn01
--FCR-11254
execute rdt.rdtdropmsg 262801, 262850

execute rdt.rdtAddMsg 262801, 10, '262801 Bad ReasonCode',      'us_english', 573, 0, '262801 Bad ReasonCode'
execute rdt.rdtAddMsg 262802, 10, '262802 UPD RCDtl Fail',      'us_english', 573, 0, '262802 Update condcode Fail'


SELECT * FROM RDT.RDTMsg WITH(NOLOCK) WHERE Message_ID BETWEEN 262801 AND 262850
