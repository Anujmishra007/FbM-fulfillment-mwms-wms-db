-- rdt_840ExtDelPack02 
execute rdt.rdtDropMsg 101351 , 101400

execute rdt.rdtAddMsg 101351, 10, '01351^UPD CTNTRK ERR',   'us_english'
execute rdt.rdtAddMsg 101352, 10, '01352^CLR CASE FAIL',    'us_english'

select * from rdt.rdtmsg (nolock) where message_id between 101351 and 101400
