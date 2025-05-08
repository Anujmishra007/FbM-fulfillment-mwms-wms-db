-- rdt_511ExtUpd13
--233351 - 233400

exec rdt.rdtdropmsg 233351, 233400

execute rdt.rdtAddMsg 233351, 10, '233351ID not allocated to Kit',  'us_english', 511, 0 , '233351 ID not allocated to Kit'
execute rdt.rdtAddMsg 233352, 10, '233352NoProductionLine',         'us_english', 511, 0 , '233352 No production line'
execute rdt.rdtAddMsg 233353, 10, '233353InsTaskFail',              'us_english', 511, 0 , '233353 Insert task failed'
execute rdt.rdtAddMsg 233354, 10, '233354InvProdLine',              'us_english', 511, 0 , '233354 KIT {} does not have valid production line location'
execute rdt.rdtAddMsg 233355, 10, '233355nspg_getkey',              'us_english', 511, 0 , '233355 nspg_getkey failed'



select * from rdt.RDTMsg (NOLOCK) where Message_ID between 233351 and 233400
