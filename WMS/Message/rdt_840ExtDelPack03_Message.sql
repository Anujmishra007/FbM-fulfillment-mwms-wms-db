-- rdt_840ExtDelPack03 
execute rdt.rdtDropMsg 114151 , 114200

execute rdt.rdtAddMsg 114151, 10, '14151^UPD CTNTRK ERR',   'us_english'
execute rdt.rdtAddMsg 114152, 10, '14152^CLR CASE FAIL',    'us_english'
execute rdt.rdtAddMsg 114153, 10, '14153^UPD SHIPPE ERR',   'us_english'
execute rdt.rdtAddMsg 114154, 10, '14154^UPD SHIPPE ERR',   'us_english'
execute rdt.rdtAddMsg 114155, 10, '14155^ASGN TRK# FAIL',   'us_english'
execute rdt.rdtAddMsg 114156, 10, '14156^UPD ORDTL ERR',    'us_english'
execute rdt.rdtAddMsg 114157, 10, '14157^GET STATUS ERR',   'us_english'
execute rdt.rdtAddMsg 114158, 10, '14158^UPD ORDERS ERR',   'us_english'
execute rdt.rdtAddMsg 114159, 10, '14159^UPD PKINFO ERR',   'us_english'

select * from rdt.rdtmsg (nolock) where message_id between 114151 and 114200
