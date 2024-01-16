--rdt_706Event08
rdt.rdtDropMsg 209801 , 209850		

execute rdt.rdtAddMsg 209801, 10, '209801 InvalidRcpt  ',    'us_english', 706
execute rdt.rdtAddMsg 209802, 10, '209802 InvalidRcpt  ',    'us_english', 706
execute rdt.rdtAddMsg 209803, 10, '209803 Pls Scan SKU ',    'us_english', 706
execute rdt.rdtAddMsg 209804, 10, '209804 Pls Scan SKU ',    'us_english', 706
execute rdt.rdtAddMsg 209805, 10, '209805 Pls Scan SNO ',    'us_english', 706
execute rdt.rdtAddMsg 209806, 10, '209806 SNO NOTEXISTS',    'us_english', 706
execute rdt.rdtAddMsg 209807, 10, '209807 SNO Scanned  ',    'us_english', 706
execute rdt.rdtAddMsg 209808, 10, '209808 SKU NOTREQSCN',    'us_english', 706
execute rdt.rdtAddMsg 209809, 10, '209809 ExceedQTY    ',    'us_english', 706
execute rdt.rdtAddMsg 209810, 10, '209810 ScanCompleted',    'us_english', 706
execute rdt.rdtAddMsg 209811, 10, '209811 ReceiptIsCanc',    'us_english', 706
execute rdt.rdtAddMsg 209812, 10, '209812 SKUNOTExists ',    'us_english', 706
execute rdt.rdtAddMsg 209813, 10, '209813 SerialNoScan ',    'us_english', 706
execute rdt.rdtAddMsg 209814, 10, '209814 Complete     ',    'us_english', 706
execute rdt.rdtAddMsg 209815, 10, '209815 SerialNo Not ',    'us_english', 706
execute rdt.rdtAddMsg 209816, 10, '209816 Scan Complete',    'us_english', 706

SELECT * FROM RDT.RDTMsg (NOLOCK) WHERE Message_ID BETWEEN 209801 AND 209850	
