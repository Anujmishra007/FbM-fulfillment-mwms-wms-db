--rdt_732ExtVal01
execute rdt.rdtDropMsg 125601 , 125650

execute rdt.rdtAddMsg 125601, 10, '25601^SKU Not In Loc',   'us_english', 732
execute rdt.rdtAddMsg 125602, 10, '25602^Over Count',       'us_english', 732


select * from rdt.rdtmsg (nolock) where message_id between 125601 and 125650