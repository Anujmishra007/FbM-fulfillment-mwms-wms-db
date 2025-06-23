--rdt_840ExtValid16
execute rdt.rdtdropmsg 198701 , 198750

execute rdt.rdtAddMsg 198701, 10, '198701 Ctn Mix SKU  ',   'us_english', 840
execute rdt.rdtAddMsg 198702, 10, '198702 Invalid COO  ',   'us_english', 840

--WMS-23401
execute rdt.rdtAddMsg 198703, 10, '198703 Max Carton=1 ',   'us_english', 840
execute rdt.rdtAddMsg 198704, 10, '198704 Ctn Mix Style',   'us_english', 840

--WMS-24295
execute rdt.rdtAddMsg 198705, 10, '198705 Invalid SKU  ',   'us_english', 840
execute rdt.rdtAddMsg 198706, 10, '198706 DROPID FINISH',   'us_english', 840
execute rdt.rdtAddMsg 198707, 10, '198707 SKU FINISH   ',   'us_english', 840
execute rdt.rdtAddMsg 198708, 10, '198708 PrinterNeeded',   'us_english', 840
execute rdt.rdtAddMsg 198709, 10, 'Pls Close Drop Id   ',   'us_english', 840
execute rdt.rdtAddMsg 198710, 10, 'Before Continue     ',   'us_english', 840
execute rdt.rdtAddMsg 198711, 10, 'Pls Close Drop Id   ',   'us_english', 840
execute rdt.rdtAddMsg 198712, 10, 'Before Exit         ',   'us_english', 840
execute rdt.rdtAddMsg 198713, 10, 'Drop Id             ',   'us_english', 840
execute rdt.rdtAddMsg 198714, 10, 'In Use By Other User',   'us_english', 840
execute rdt.rdtAddMsg 198715, 10, '198715 DropID In Use',   'us_english', 840

SELECT * FROM rdt.RDTMsg (NOLOCK) WHERE Message_ID BETWEEN 198701 AND 198750

