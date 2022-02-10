--rdt_1819ExtPASP28
rdt.rdtDropMsg 149301 , 149350

execute rdt.rdtAddMsg 149301, 10, '49301^NotFull Pallet',   'us_english', 1819
execute rdt.rdtAddMsg 149302, 10, '49302^No Sugg Loc',      'us_english', 1819


SELECT * FROM RDT.RDTMSG (NOLOCK) WHERE MESSAGE_ID BETWEEN 149301 AND 149350