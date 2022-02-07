--rdt_1831GetTask01
exec rdt.rdtDropMsg 124601 , 124650

execute rdt.rdtAddMsg 124601, 10, '24601^No Task',          'us_english', 1831
execute rdt.rdtAddMsg 124602, 10, '24602^UpdateLog Fail',   'us_english', 1831
execute rdt.rdtAddMsg 124603, 10, '24603^UpdateLog Fail',   'us_english', 1831
execute rdt.rdtAddMsg 124604, 10, '24604^UpdateLog Fail',   'us_english', 1831
execute rdt.rdtAddMsg 124605, 10, '24605^UpdateLog Fail',   'us_english', 1831

SELECT * FROM RDT.RDTMSG (NOLOCK) WHERE MESSAGE_ID BETWEEN 124601 AND 124650