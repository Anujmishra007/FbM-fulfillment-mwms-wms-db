-- rdtfnc_ReceiveByUCC 
execute rdt.rdtDropMsg 99451 , 99500

execute rdt.rdtAddMsg 99451, 10, '99451^VALUE REQUIRED', 'us_english', 897
execute rdt.rdtAddMsg 99452, 10, '99452^CARTON ID DOES', 'us_english', 897
execute rdt.rdtAddMsg 99453, 10, '99453^NOT EXISTS',     'us_english', 897
execute rdt.rdtAddMsg 99454, 10, '99454^CARTON ID',      'us_english', 897
execute rdt.rdtAddMsg 99455, 10, '99455^ALREADY',        'us_english', 897
execute rdt.rdtAddMsg 99456, 10, '99456^RECEIVED',       'us_english', 897
execute rdt.rdtAddMsg 99457, 10, '99457^ASN NOT EXISTS', 'us_english', 897
execute rdt.rdtAddMsg 99458, 10, '99458^ASN CLOSED',     'us_english', 897
execute rdt.rdtAddMsg 99459, 10, '99459^RECEIPT FAIL',   'us_english', 897
execute rdt.rdtAddMsg 99460, 10, '99460^NO ASN FOUND',   'us_english', 897
execute rdt.rdtAddMsg 99461, 10, '99461^NO ASN FOUND',   'us_english', 897
execute rdt.rdtAddMsg 99462, 10, '99462^GET UCC FAIL',   'us_english', 897
execute rdt.rdtAddMsg 99463, 10, '99463^SPLIT UCC FAIL', 'us_english', 897
execute rdt.rdtAddMsg 99464, 10, '99464^UPD UCC FAIL',   'us_english', 897
execute rdt.rdtAddMsg 99465, 10, '99465^RCV CTN FAIL',   'us_english', 897
execute rdt.rdtAddMsg 99466, 10, '99466^LabelPrnterReq', 'us_english', 897
execute rdt.rdtAddMsg 99467, 10, '99467^DWNOTSETUP',     'us_english', 897
execute rdt.rdtAddMsg 99468, 10, '99468^TGETDB NOT SET', 'us_english', 897


SELECT * FROM RDT.RDTMSG (NOLOCK) WHERE MESSAGE_ID BETWEEN 99451 AND 99500