--rdt_1813ExtValid03
execute rdt.rdtdropmsg 129101 , 129150

execute rdt.rdtAddMsg 129101, 10, '29101^X MV ASRS PLT',    'us_english', 1813
execute rdt.rdtAddMsg 129102, 10, '29102^KEY/SCAN UPC',     'us_english', 1813
execute rdt.rdtAddMsg 129103, 10, '29103^KEY/SCAN UPC',     'us_english', 1813
execute rdt.rdtAddMsg 129104, 10, '29104^X MV ASRS PLT',    'us_english', 1813
execute rdt.rdtAddMsg 129105, 10, '29105^TO ID X EXISTS',   'us_english', 1813
execute rdt.rdtAddMsg 129106, 10, '29106^SKU NOT ON ID',    'us_english', 1813
execute rdt.rdtAddMsg 129107, 10, '29107^SKU NOT ON ID',    'us_english', 1813
execute rdt.rdtAddMsg 129108, 10, '29108^DIFF PLTID LOC',   'us_english', 1813

select * from rdt.rdtmsg (nolock) where message_id between 129101 and 129150