-- rdt_608RefNoLKUP04
execute rdt.rdtDropMsg 121551 , 121600

execute rdt.rdtAddMsg 121551, 10, '21551^Max 2 RefField',   'us_english', 608
execute rdt.rdtAddMsg 121552, 10, '21552^Invalid RefNo',    'us_english', 608
execute rdt.rdtAddMsg 121553, 10, '21553^Multi ASN',        'us_english', 608
execute rdt.rdtAddMsg 121554, 10, '21554^ASN NotFound',     'us_english', 608

select * from rdt.rdtmsg (nolock) where message_id between 121551 AND 121600