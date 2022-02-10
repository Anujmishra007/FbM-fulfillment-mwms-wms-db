--rdt_LottableProcess_IMXValidateL04
execute rdt.rdtdropmsg 170801 , 170850

execute rdt.rdtAddMsg 170801, 10, '170801 Lottable04req',    'us_english', 598
execute rdt.rdtAddMsg 170802, 10, '170802 Invalid Lot04',    'us_english', 598

select * from rdt.rdtmsg (nolock) where message_id between 170801 and 170850