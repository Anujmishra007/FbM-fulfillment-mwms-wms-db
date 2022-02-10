--rdt_593PrintSackID01
execute rdt.rdtdropmsg 101551 , 101600

execute rdt.rdtAddMsg 101551, 10, '01551^VALUE REQUIRED',   'us_english'
execute rdt.rdtAddMsg 101552, 10, '01552^INVALID NO',       'us_english'
execute rdt.rdtAddMsg 101553, 10, '01553^LabelPrnterReq',   'us_english'
execute rdt.rdtAddMsg 101554, 10, '01554^DWNOTSetup',       'us_english'
execute rdt.rdtAddMsg 101555, 10, '01555^TgetDB Not Set',   'us_english'
execute rdt.rdtAddMsg 101556, 10, '01556^NOT WITHIN',       'us_english'
execute rdt.rdtAddMsg 101557, 10, '01557^DEFAULT SACK#',    'us_english'
execute rdt.rdtAddMsg 101558, 10, '01558^RANGE',            'us_english'
execute rdt.rdtAddMsg 101559, 10, '01559^SEND ALERT ERR',   'us_english'


select * from rdt.rdtmsg (nolock) where message_id between 101551 and 101600