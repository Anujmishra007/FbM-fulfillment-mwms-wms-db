--rdt_840ExtValid16
execute rdt.rdtdropmsg 198701 , 198750

execute rdt.rdtAddMsg 198701, 10, '198701 Ctn Mix SKU  ',   'us_english', 840
execute rdt.rdtAddMsg 198702, 10, '198702 Invalid COO  ',   'us_english', 840

--WMS-23401
execute rdt.rdtAddMsg 198703, 10, '198703 Max Carton=1 ',   'us_english', 840
execute rdt.rdtAddMsg 198704, 10, '198704 Ctn Mix Style',   'us_english', 840

SELECT * FROM rdt.RDTMsg (NOLOCK) WHERE Message_ID BETWEEN 198701 AND 198750