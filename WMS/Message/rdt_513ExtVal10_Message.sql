--rdt_513ExtVal10
rdt.rdtDropMsg 165901 , 165950

execute rdt.rdtAddMsg 165901, 10, '65901^Invalid ToLoc',   'us_english', 513
execute rdt.rdtAddMsg 165902, 10, '65902^Invalid ToLOC',   'us_english', 513
execute rdt.rdtAddMsg 165903, 10, '65903^Invalid ToLOC',   'us_english', 513
execute rdt.rdtAddMsg 165904, 10, '65904^Invalid ToLOC',   'us_english', 513
execute rdt.rdtAddMsg 165905, 10, '65905^No Mix Lot02',    'us_english', 513

SELECT * FROM RDT.RDTMSG (NOLOCK) WHERE MESSAGE_ID BETWEEN 165901 AND 165950