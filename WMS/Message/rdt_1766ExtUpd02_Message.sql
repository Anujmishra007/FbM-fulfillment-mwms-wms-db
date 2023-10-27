--rdt_1766ExtUpd02
exec rdt.rdtDropMsg 207751 , 207800

execute rdt.rdtAddMsg 207751, 10, '207751 Ins CCDtl Err',   'us_english', 1766
execute rdt.rdtAddMsg 207752, 10, '207752ReleaseTaskErr',   'us_english', 1766
execute rdt.rdtAddMsg 207753, 10, '207753ReleaseTaskErr',   'us_english', 1766

select * from rdt.rdtmsg (nolock) where message_id between 207751 AND 207800