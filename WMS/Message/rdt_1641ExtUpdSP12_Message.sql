-- rdt_1641ExtUpdSP12
execute rdt.rdtDropMsg 178551, 178600

execute rdt.rdtAddMsg 178551, 10, '178551^Ins Plt Fail ',  'us_english', 1641
execute rdt.rdtAddMsg 178552, 10, '178552^Ctn Exists   ',  'us_english', 1641
execute rdt.rdtAddMsg 178553, 10, '178553Ins Pltdt Fail',  'us_english', 1641
execute rdt.rdtAddMsg 178554, 10, '178554Ins Pltdt Fail',  'us_english', 1641
execute rdt.rdtAddMsg 178555, 10, '178555Pkey Not Found',  'us_english', 1641
execute rdt.rdtAddMsg 178556, 10, '178556^Short scan   ',  'us_english', 1641
execute rdt.rdtAddMsg 178557, 10, '178557Upd Pltdt Fail',  'us_english', 1641
execute rdt.rdtAddMsg 178558, 10, '178558^Upd Plt Fail ',  'us_english', 1641

select * from rdt.rdtmsg (nolock) where message_id between 178551 AND 178600	