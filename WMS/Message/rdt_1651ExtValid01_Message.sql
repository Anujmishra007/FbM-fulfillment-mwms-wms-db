--rdt_1651ExtValid01
exec rdt.rdtDropMsg 126701 , 126750

execute rdt.rdtAddMsg 126701, 10, '26701^Container# req',   'us_english', 1651
execute rdt.rdtAddMsg 126702, 10, '26702^Inv Container#',   'us_english', 1651
execute rdt.rdtAddMsg 126703, 10, '26703^Inv Container#',   'us_english', 1651
execute rdt.rdtAddMsg 126704, 10, '26704^Inv # pallet',     'us_english', 1651
execute rdt.rdtAddMsg 126705, 10, '26705^ID in >1 mbol',    'us_english', 1651
execute rdt.rdtAddMsg 126706, 10, '26706^ID not in mbol',   'us_english', 1651
execute rdt.rdtAddMsg 126707, 10, '26707^ID not in PLTD',   'us_english', 1651
execute rdt.rdtAddMsg 126708, 10, '26708^Over scanned',     'us_english', 1651
execute rdt.rdtAddMsg 126709, 10, '26709^NotAll PltScan',   'us_english', 1651
execute rdt.rdtAddMsg 126710, 10, '26710^ConStatusNotEq9',   'us_english', 1651

execute rdt.rdtAddMsg 126711, 10, '26711^PltNotInCon',   'us_english', 1651
execute rdt.rdtAddMsg 126712, 10, '26712^PltDoubleScan',   'us_english', 1651


SELECT * FROM RDT.RDTMSG (NOLOCK) WHERE MESSAGE_ID BETWEEN 126701 AND 126750

