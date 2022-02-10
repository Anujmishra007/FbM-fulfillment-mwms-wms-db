--rdt_1580RcptCfm18
execute rdt.rdtDropMsg 151801 , 151850

execute rdt.rdtAddMsg 151801, 10, '51801^Need Lottable2',      'us_english', 1580
execute rdt.rdtAddMsg 151802, 10, '51802^L02 not in ASN',      'us_english', 1580
execute rdt.rdtAddMsg 151803, 10, '51803^L02 full Recv',       'us_english', 1580
execute rdt.rdtAddMsg 151804, 10, '51804^USKUL02NotInASN',     'us_english', 1580
execute rdt.rdtAddMsg 151805, 10, '51805^SKUL02OverRecv',      'us_english', 1580
execute rdt.rdtAddMsg 151806, 10, '51806^SNO not in ASN',      'us_english', 1580
execute rdt.rdtAddMsg 151807, 10, '51807^SNO dup in ASN',      'us_english', 1580
execute rdt.rdtAddMsg 151808, 10, '51808^SNO diff SKU',        'us_english', 1580
execute rdt.rdtAddMsg 151809, 10, '51809^SNO received',        'us_english', 1580
execute rdt.rdtAddMsg 142210, 10, '42210^SNO received',        'us_english', 1580
execute rdt.rdtAddMsg 142211, 10, '42211^Diff batch',          'us_english', 1580

SELECT * FROM RDT.RDTMSG (NOLOCK) WHERE MESSAGE_ID BETWEEN 151801 AND 151850	

