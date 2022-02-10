-- rdt_1628_DropID01
execute rdt.rdtDropMsg 122401, 122450

execute rdt.rdtAddMsg 122401, 10, '22401^NO RECORD',        'us_english', 1628
execute rdt.rdtAddMsg 122402, 10, '22402^GEN NEW ID ERR',   'us_english', 1628
execute rdt.rdtAddMsg 122403, 10, '22403^DROP ID EXISTS',   'us_english', 1628
execute rdt.rdtAddMsg 122404, 10, '22404^INS DROPID ERR  ', 'us_english', 1628
execute rdt.rdtAddMsg 122405, 10, '22405^INVALID DROPID',   'us_english', 1628
execute rdt.rdtAddMsg 122406, 10, '22406^UPD DROPID ERR',   'us_english', 1628
execute rdt.rdtAddMsg 122407, 10, '22407^INVALID DROPID',   'us_english', 1628
execute rdt.rdtAddMsg 122408, 10, '22408^DEL DROP ID ERR',  'us_english', 1628
execute rdt.rdtAddMsg 122409, 10, '22409^UPD DROPID ERR',   'us_english', 1628

select * from rdt.rdtmsg (nolock) where message_id between 122401 and 122450
