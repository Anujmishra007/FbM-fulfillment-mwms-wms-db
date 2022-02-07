--rdtfnc_MbolCreation
rdt.rdtDropMsg 172101  , 172150	

execute rdt.rdtAddMsg 172101, 10, '172101 Need Facility',   'us_english', 1856
execute rdt.rdtAddMsg 172102, 10, '172102 Inv Facility ',   'us_english', 1856
execute rdt.rdtAddMsg 172103, 10, '172103 Value req    ',   'us_english', 1856
execute rdt.rdtAddMsg 172104, 10, '172104Invalid Orders',   'us_english', 1856
execute rdt.rdtAddMsg 172105, 10, '172105 Invalid Load ',   'us_english', 1856
execute rdt.rdtAddMsg 172106, 10, '172106Invalid Column',   'us_english', 1856
execute rdt.rdtAddMsg 172107, 10, '172107 ColumnNoIndex',   'us_english', 1856
execute rdt.rdtAddMsg 172108, 10, '172108 Need Option ',    'us_english', 1856
execute rdt.rdtAddMsg 172109, 10, '172109Invalid Option',   'us_english', 1856

--WMS17621
execute rdt.rdtAddMsg 172110, 10, '172110 No MBOLKey',      'us_english', 1856
execute rdt.rdtAddMsg 172111, 10, '172111 CloseMBOLFail',   'us_english', 1856

--WMS17494
execute rdt.rdtAddMsg 172112, 10, '172112Either 1 Value',   'us_english', 1856



SELECT * FROM RDT.RDTMSG (NOLOCK) WHERE MESSAGE_ID BETWEEN 172101 AND 172150	