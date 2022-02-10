--rdt_819ExtVal01
execute rdt.rdtdropmsg 104101 , 104150

execute rdt.rdtAddMsg '104101', 10, '04101^NO ORDs 2 PICK', 'us_english', 819

select * from rdt.rdtmsg (nolock) where message_id between 104101 and 104150
