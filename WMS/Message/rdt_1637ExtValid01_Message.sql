-- rdt_1637ExtValid01 
execute rdt.rdtDropMsg 98101 , 98150

execute rdt.rdtAddMsg 98101, 10, '98101^ID IN >1 MBOL',  'us_english', 1637
execute rdt.rdtAddMsg 98102, 10, '98102^ID NOT IN MBOL', 'us_english', 1637
execute rdt.rdtAddMsg 98103, 10, '98103^ID NOT IN STG',  'us_english', 1637
execute rdt.rdtAddMsg 98104, 10, '98104^ID NOT IN PLTD', 'us_english', 1637

-- (james02)
execute rdt.rdtAddMsg 98105, 10, '98105^CONTAINER# REQ', 'us_english', 1637
execute rdt.rdtAddMsg 98106, 10, '98106^INV # PALLET',   'us_english', 1637
execute rdt.rdtAddMsg 98107, 10, '98107^NOT ALL PALLET', 'us_english', 1637
execute rdt.rdtAddMsg 98108, 10, '98108^SCANNED.',       'us_english', 1637
execute rdt.rdtAddMsg 98109, 10, '98109^OVER SCANNED.',  'us_english', 1637

-- (james03)
execute rdt.rdtAddMsg 98110, 10, '98110^STAGE LOCATION', 'us_english', 1637
execute rdt.rdtAddMsg 98111, 10, '98111^NOT MATCH!',     'us_english', 1637

-- (james04)
execute rdt.rdtAddMsg 98112, 10, '98112^INVALID QTY',    'us_english', 1637
execute rdt.rdtAddMsg 98113, 10, '98113^INVALID QTY',    'us_english', 1637

select * from rdt.rdtmsg (nolock) where message_id between 98101 and 98150