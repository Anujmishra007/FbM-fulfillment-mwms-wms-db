--rdt_1667ExtVal01
execute rdt.rdtdropmsg 192001 , 192050

execute rdt.rdtAddMsg 192001, 10, '192001 MBOL SHIPPED ',   'us_english', 1667
execute rdt.rdtAddMsg 192002, 10, 'PALLETIZED CUSTOMER ',   'us_english', 1667
execute rdt.rdtAddMsg 192003, 10, 'NOT ALLOW TO OPEN   ',   'us_english', 1667
execute rdt.rdtAddMsg 192004, 10, 'CLOSED PALLET       ',   'us_english', 1667

select * from rdt.rdtmsg (nolock) where message_id between 192001 AND 192050
