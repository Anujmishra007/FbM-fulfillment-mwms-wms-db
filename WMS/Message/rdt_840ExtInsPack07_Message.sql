--rdt_840ExtInsPack07
execute rdt.rdtdropmsg 137501 , 137550


execute rdt.rdtAddMsg 137501, 10, '37501^UPDLOG FAILED',   'us_english', 840
execute rdt.rdtAddMsg 137502, 10, '37502^INSLOG FAILED',   'us_english', 840
execute rdt.rdtAddMsg 137503, 10, '37503^INSPKHDR FAIL',   'us_english', 840
execute rdt.rdtAddMsg 137504, 10, '37504^UPDPKDET FAIL',   'us_english', 840
execute rdt.rdtAddMsg 137505, 10, '37505^NO TRACKING #',   'us_english', 840
execute rdt.rdtAddMsg 137506, 10, '37506^NO TRACKING #',   'us_english', 840
execute rdt.rdtAddMsg 137507, 10, '37507^ASSIGN TRK# ERR', 'us_english', 840
execute rdt.rdtAddMsg 137508, 10, '37508^GET LABEL Fail',  'us_english', 840
execute rdt.rdtAddMsg 137509, 10, '37509^INS PACK FAIL',   'us_english', 840
execute rdt.rdtAddMsg 137510, 10, '37510^INS PACK FAIL',   'us_english', 840
execute rdt.rdtAddMsg 137511, 10, '37511^UPD CASE FAIL',   'us_english', 840
execute rdt.rdtAddMsg 137512, 10, '37512^UPD CASE FAIL',   'us_english', 840
execute rdt.rdtAddMsg 137513, 10, '37513^GET PDKEY FAIL',  'us_english', 840
execute rdt.rdtAddMsg 137514, 10, '37514^INS PDTL FAIL',   'us_english', 840
execute rdt.rdtAddMsg 137515, 10, '37515^UPD CASE FAIL',   'us_english', 840

select * from rdt.rdtmsg (nolock) where message_id between 137501 AND 137550
