
execute rdt.rdtdropmsg 256951 , 257000

execute rdt.rdtAddMsg 256951, 10, '256951^PickingNotComplete',       'us_english',1837, 0, '256951: Picking Not Complete'
execute rdt.rdtAddMsg 256952, 10, '256952^PPSLocNotFound',       'us_english',1837, 0, ''
execute rdt.rdtAddMsg 256953, 10, '256953^ScanAnotherID',       'us_english',1837, 0, ''
execute rdt.rdtAddMsg 256954, 10, '256954^InvalidInput',       'us_english',1837, 0, ''
execute rdt.rdtAddMsg 256955, 10, '256955^NoAvailableQCLoc',       'us_english',1837, 0, ''

select * from rdt.rdtmsg (nolock) where message_id between 256951 and 257000