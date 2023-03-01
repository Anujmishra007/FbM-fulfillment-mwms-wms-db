-- rdt_840ExtUpd26
execute rdt.rdtdropmsg 193851 , 193900

execute rdt.rdtAddMsg 193851, 10, '193851 UPDTL2 FAILED',   'us_english', 840
execute rdt.rdtAddMsg 193852, 10, '193852 UPD PACK ERR ',   'us_english', 840
execute rdt.rdtAddMsg 193853, 10, '193853 UPD PICK ERR ',   'us_english', 840
execute rdt.rdtAddMsg 193854, 10, '193854 UPD CTNTK ERR',   'us_english', 840
execute rdt.rdtAddMsg 193855, 10, '193855 UPD PCKIF ERR',   'us_english', 840
execute rdt.rdtAddMsg 193856, 10, '193856 UPD PACK ERR ',   'us_english', 840
execute rdt.rdtAddMsg 193857, 10, '193857 UPD PCKIF ERR',   'us_english', 840

select * from rdt.rdtmsg (nolock) where message_id between 193851 AND 193900
