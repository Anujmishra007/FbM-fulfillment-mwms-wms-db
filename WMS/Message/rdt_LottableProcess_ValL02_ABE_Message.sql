-- rdt_LottableProcess_ValL02_ABE
--UWP-30670 Merge Code
execute rdt.rdtdropmsg 234101 , 234150

execute rdt.rdtAddMsg 234101, 10, '234101^Invalid Lot02',   'us_english', 607

select * from rdt.rdtmsg (nolock) where message_id between 234101 and 234150
