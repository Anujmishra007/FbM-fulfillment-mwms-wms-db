-- message ids 259401 - 259450
-- rdt_1868UnpackVal01 (NYE018)

execute rdt.rdtDropMsg 259401, 259450

execute rdt.rdtAddMsg 259401, 10, '259401^Sn Invalid   ',         'us_english', 1868, 0, '259401^SerialNo is not valid'
execute rdt.rdtAddMsg 259402, 10, '259402^SnNotExsists ',         'us_english', 1868, 0, '259402^SerialNo is not valid'
execute rdt.rdtAddMsg 259403, 10, '259403^Not packed   ',         'us_english', 1868, 0, '259403^Serial number not yet packed'
execute rdt.rdtAddMsg 259404, 10, '259404^Serial No not for SKU', 'us_english', 1868, 0, '259404^Serial No not for SKU'

SELECT * FROM RDT.RDTMSG (NOLOCK) WHERE MESSAGE_ID BETWEEN 259401 AND 259450
