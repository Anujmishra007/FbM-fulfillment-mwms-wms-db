
execute rdt.rdtdropmsg 256951 , 257000

execute rdt.rdtAddMsg 256951, 10, '256951^PickingNotComplete',       'us_english',1837, 0, '256951: Picking Not Complete'
execute rdt.rdtAddMsg 256952, 10, '256952^PPSLocNotFound',       'us_english',1837, 0, ''
execute rdt.rdtAddMsg 256953, 10, '256953^ScanAnotherID',       'us_english',1837, 0, ''
execute rdt.rdtAddMsg 256954, 10, '256954^InvalidInput',       'us_english',1837, 0, ''
execute rdt.rdtAddMsg 256955, 10, '256955^NoAvailableQCLoc',       'us_english',1837, 0, ''
execute rdt.rdtAddMsg 256956, 10, '256956^Invalid Wave Key',       'us_english',1837, 0, ''
execute rdt.rdtAddMsg 256957, 10, '256957^Invalid LoadKeyOrConsigneeKey',       'us_english',1837, 0, '256957 Invalid LoadKeyOrConsigneeKey'
execute rdt.rdtAddMsg 256958, 10, '256958^PPS not allowed for single',       'us_english',1837, 0, '256958^PPS not allowed for single'

select * from rdt.rdtmsg (nolock) where message_id between 256951 and 257000