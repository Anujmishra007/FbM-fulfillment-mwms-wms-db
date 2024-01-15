--rdt_706Event08
rdt.rdtDropMsg 209801 , 209850		

execute rdt.rdtAddMsg 209801, 10, '209801InvalidReceipt',    'us_english', 706
execute rdt.rdtAddMsg 209802, 10, '209802InvalidReceipt',    'us_english', 706
execute rdt.rdtAddMsg 209803, 10, '209803PlsScanSKU',    'us_english', 706
execute rdt.rdtAddMsg 209804, 10, '209804PlsScanSKU',    'us_english', 706
execute rdt.rdtAddMsg 209805, 10, '209805PlsScanSNO',    'us_english', 706
execute rdt.rdtAddMsg 209806, 10, '209806SNONOTEXISTS',    'us_english', 706
execute rdt.rdtAddMsg 209807, 10, '209807SNOScanned',    'us_english', 706
execute rdt.rdtAddMsg 209808, 10, '209808SKUNOTREQSCN',    'us_english', 706
execute rdt.rdtAddMsg 209809, 10, '209809ExceedQTY',    'us_english', 706
execute rdt.rdtAddMsg 209810, 10, '209810ScanCompleted',    'us_english', 706
execute rdt.rdtAddMsg 209811, 10, '209811InvalidReceipt',    'us_english', 706
execute rdt.rdtAddMsg 209812, 10, '209812InvalidSKU',    'us_english', 706
execute rdt.rdtAddMsg 209813, 10, '209813SerialNoScan',    'us_english', 706
execute rdt.rdtAddMsg 209814, 10, '209814Complete',    'us_english', 706
execute rdt.rdtAddMsg 209815, 10, '209815SerialNoNot',    'us_english', 706
execute rdt.rdtAddMsg 209816, 10, '209816ScanComplete',    'us_english', 706

SELECT * FROM RDT.RDTMsg (NOLOCK) WHERE Message_ID BETWEEN 209801 AND 209850	