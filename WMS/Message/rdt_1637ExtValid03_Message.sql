--rdt_1637ExtValid03
execute rdt.rdtDropMsg 125451 , 125500

execute rdt.rdtAddMsg 125451, 10, '25451^CONTAINER# REQ',   'us_english', 1637
execute rdt.rdtAddMsg 125452, 10, '25452^INV # PALLET',     'us_english', 1637
execute rdt.rdtAddMsg 125453, 10, '25453^ID IN >1 MBOL',    'us_english', 1637
execute rdt.rdtAddMsg 125454, 10, '25454^ID NOT IN MBOL',   'us_english', 1637
execute rdt.rdtAddMsg 125455, 10, '25455^OVER SCANNED',     'us_english', 1637
execute rdt.rdtAddMsg 125456, 10, '25456^STAGE LOCATION',   'us_english', 1637
execute rdt.rdtAddMsg 125457, 10, '25457^NOT MATCH!',       'us_english', 1637
execute rdt.rdtAddMsg 125458, 10, '25458^NOT ALL PALLET',   'us_english', 1637
execute rdt.rdtAddMsg 125459, 10, '25459^SCANNED.',         'us_english', 1637
execute rdt.rdtAddMsg 125460, 10, '25460^INVALID QTY',      'us_english', 1637
execute rdt.rdtAddMsg 125461, 10, '25461^INVALID QTY',      'us_english', 1637
execute rdt.rdtAddMsg 125462, 10, '25462^DUPLICATE PLT',    'us_english', 1637
execute rdt.rdtAddMsg 125463, 10, '25463^ID PER MBOL',      'us_english', 1637

select * from rdt.rdtmsg (nolock) where message_id between 125451 and 125500