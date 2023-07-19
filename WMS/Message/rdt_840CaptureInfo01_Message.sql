--rdt_840CaptureInfo01
execute rdt.rdtdropmsg 198801 , 198850

execute rdt.rdtAddMsg 198801, 10, '198801 Need Data    ',   'us_english', 840
execute rdt.rdtAddMsg 198802, 10, '198802Invalid Format',   'us_english', 840
execute rdt.rdtAddMsg 198803, 10, '198803 Invalid Value',   'us_english', 840

SELECT * FROM rdt.RDTMsg (NOLOCK) WHERE Message_ID BETWEEN 198801 AND 198850