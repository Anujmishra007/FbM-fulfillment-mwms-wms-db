-- rdt_LottableProcess_CheckValueInASN
exec rdt.rdtdropmsg 161801, 161850

execute rdt.rdtAddMsg 161801, 10, '161801^Need Lot07   ', 'us_english', 600
execute rdt.rdtAddMsg 161802, 10, '161802^Need Lot08   ', 'us_english', 600
execute rdt.rdtAddMsg 161803, 10, '161803^Need Lot09   ', 'us_english', 600
execute rdt.rdtAddMsg 161804, 10, '161804^Invalid Lot07', 'us_english', 600
execute rdt.rdtAddMsg 161805, 10, '161805^Invalid Lot03', 'us_english', 600

select top 10 * from rdt.rdtmsg (NOLOCK) WHERE Message_ID BETWEEN 161801 and 161850