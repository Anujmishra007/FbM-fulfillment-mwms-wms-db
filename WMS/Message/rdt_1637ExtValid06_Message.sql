--rdt_1637ExtValid06
execute rdt.rdtdropmsg 156651 , 156700

execute rdt.rdtAddMsg 156651, 10, '56651^PalletNotClose',   'us_english', 1637

select * from rdt.rdtmsg (nolock) where message_id between 156651 AND 156700
