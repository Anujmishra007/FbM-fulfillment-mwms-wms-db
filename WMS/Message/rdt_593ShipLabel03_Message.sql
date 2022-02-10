-- rdt_593ShipLabel03
execute rdt.rdtDropMsg 102201 , 102250

execute rdt.rdtAddMsg '102201', 10, '02201^TRACKING # REQ', 'us_english'
execute rdt.rdtAddMsg '102202', 10, '02202^NO TRACKING #',  'us_english'
execute rdt.rdtAddMsg '102203', 10, '02203^NO ORDERS',      'us_english'
execute rdt.rdtAddMsg '102204', 10, '02204^NO TERMINAL',    'us_english'
execute rdt.rdtAddMsg '102205', 10, '02205^LABELPRNTERREQ', 'us_english'
execute rdt.rdtAddMsg '102206', 10, '02206^CLOSE ORD ERR',  'us_english'
execute rdt.rdtAddMsg '102207', 10, '02207^EXTORD > 1 ORD', 'us_english'

select * from rdt.rdtmsg (nolock) where message_id between 102201 AND 102250

