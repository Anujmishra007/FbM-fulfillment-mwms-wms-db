--rdt_1644ExtPltCfm01
rdt.rdtDropMsg 136101 , 136150

execute rdt.rdtAddMsg 136101, 10, '36101^Casecnt = 0',      'us_english', 1644
execute rdt.rdtAddMsg 136102, 10, '36102^OffSetPDtlFail',   'us_english', 1644
execute rdt.rdtAddMsg 136103, 10, '36103^OffSetPDtlFail',   'us_english', 1644
execute rdt.rdtAddMsg 136104, 10, '36104^GetDetKeyFail',    'us_english', 1644
execute rdt.rdtAddMsg 136105, 10, '36105^Ins PDtl Fail',    'us_english', 1644
execute rdt.rdtAddMsg 136106, 10, '36106^OffSetPDtlFail',   'us_english', 1644
execute rdt.rdtAddMsg 136107, 10, '36107^Cfm Pick Fail',    'us_english', 1644
execute rdt.rdtAddMsg 136108, 10, '36108^INS RefKeyFail',   'us_english', 1644
execute rdt.rdtAddMsg 136109, 10, '36109^Fully Picked',     'us_english', 1644


SELECT * FROM RDT.RDTMSG (NOLOCK) WHERE MESSAGE_ID BETWEEN 136101 AND 136150