
-- rdt_1637ExtValid05
execute rdt.rdtDropMsg 149851 , 149900

execute rdt.rdtAddMsg 149851, 10, '149851^ID IN >1 MBOL',  'us_english', 1637
execute rdt.rdtAddMsg 149852, 10, '149852^ID NOT IN MBOL', 'us_english', 1637
execute rdt.rdtAddMsg 149853, 10, '149853^ID NOT IN STG',  'us_english', 1637
execute rdt.rdtAddMsg 149854, 10, '149854^ID NOT IN PLTD', 'us_english', 1637
execute rdt.rdtAddMsg 149855, 10, '149855^CONTAINER# REQ', 'us_english', 1637
execute rdt.rdtAddMsg 149856, 10, '149856^INV # PALLET',   'us_english', 1637
execute rdt.rdtAddMsg 149857, 10, '149857^NOT ALL PALLET', 'us_english', 1637
execute rdt.rdtAddMsg 149858, 10, '149858^SCANNED.',       'us_english', 1637
execute rdt.rdtAddMsg 149859, 10, '149859^OVER SCANNED.',  'us_english', 1637
execute rdt.rdtAddMsg 149860, 10, '149860^STAGE LOCATION', 'us_english', 1637
execute rdt.rdtAddMsg 149861, 10, '149861^NOT MATCH!',     'us_english', 1637
execute rdt.rdtAddMsg 149862, 10, '149862^INVALID QTY',    'us_english', 1637
execute rdt.rdtAddMsg 149863, 10, '149863^INVALID QTY',    'us_english', 1637
execute rdt.rdtAddMsg 149864, 10, '149864^INVALID QTY',    'us_english', 1637

select * from rdt.rdtmsg (nolock) where message_id between 149851 and 149900