-- rdt_1641ExtUpdSP15
execute rdt.rdtDropMsg 200901, 200950

execute rdt.rdtAddMsg 200901, 10, '200901Ins Plt Fail ',  'us_english', 1641
execute rdt.rdtAddMsg 200902, 10, '200902Ctn Exists   ',  'us_english', 1641
execute rdt.rdtAddMsg 200903, 10, '200903Ins Pltdt Fail',  'us_english', 1641
execute rdt.rdtAddMsg 200904, 10, '200904Ins Pltdt Fail',  'us_english', 1641
execute rdt.rdtAddMsg 200905, 10, '200905Pkey Not Found',  'us_english', 1641
execute rdt.rdtAddMsg 200906, 10, '200906Short scan   ',  'us_english', 1641
execute rdt.rdtAddMsg 200907, 10, '200907Upd Pltdt Fail',  'us_english', 1641
execute rdt.rdtAddMsg 200908, 10, '200908Upd Plt Fail ',  'us_english', 1641

select * from rdt.rdtmsg (nolock) where message_id between 200901 AND 200950	