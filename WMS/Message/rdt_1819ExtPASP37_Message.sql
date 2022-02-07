--rdt_1819ExtPASP37
rdt.rdtDropMsg 177951, 178000

execute rdt.rdtAddMsg 177951, 10, '177951^NoSuitableLoc',   'us_english', 1819
execute rdt.rdtAddMsg 177952, 10, '177952^HostWHCodeErr',   'us_english', 1819

SELECT * FROM RDT.RDTMSG (NOLOCK) WHERE MESSAGE_ID BETWEEN 177951 AND 178000