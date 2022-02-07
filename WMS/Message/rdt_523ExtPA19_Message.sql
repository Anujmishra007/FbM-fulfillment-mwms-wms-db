--rdt_523ExtPA19
execute rdt.rdtDropMsg 138001, 138050

execute rdt.rdtAddMsg 138001, 10, '38001^No Suggested Loc',   'us_english', 523

select * from rdt.rdtmsg (nolock) where message_id between 138001 and 138050