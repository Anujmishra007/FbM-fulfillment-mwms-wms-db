--rdt_600ExtVal08
execute rdt.rdtDropMsg 144101 , 144150

execute rdt.rdtAddMsg 144101, 10, '44101^ID EXISTS',      'us_english', 600
execute rdt.rdtAddMsg 144102, 10, '44102^> PALLETT CFG',  'us_english', 600

select * from rdt.rdtmsg (nolock) where message_id between 144101 and 144150