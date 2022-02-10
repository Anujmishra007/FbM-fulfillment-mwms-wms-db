--rdt_840ExtInsPack01
execute rdt.rdtdropmsg 110951 , 111000


execute rdt.rdtAddMsg 110951, 10, '10951^UPDLOG FAILED',   'us_english', 840
execute rdt.rdtAddMsg 110952, 10, '10952^INSLOG FAILED',   'us_english', 840
execute rdt.rdtAddMsg 110953, 10, '10953^INSPKHDR FAIL',   'us_english', 840
execute rdt.rdtAddMsg 110954, 10, '10954^UPDPKDET FAIL',   'us_english', 840
execute rdt.rdtAddMsg 110955, 10, '10955^NO TRACKING #',   'us_english', 840
execute rdt.rdtAddMsg 110956, 10, '10956^NO TRACKING #',   'us_english', 840
execute rdt.rdtAddMsg 110957, 10, '10957^ASSIGN TRK# ERR', 'us_english', 840
execute rdt.rdtAddMsg 110958, 10, '10958^GET LABEL Fail',  'us_english', 840
execute rdt.rdtAddMsg 110959, 10, '10959^INS PACK FAIL',   'us_english', 840
execute rdt.rdtAddMsg 110960, 10, '10960^INS PACK FAIL',   'us_english', 840
execute rdt.rdtAddMsg 110961, 10, '10961^UPD CASE FAIL',   'us_english', 840
execute rdt.rdtAddMsg 110962, 10, '10962^UPD CASE FAIL',   'us_english', 840
execute rdt.rdtAddMsg 110963, 10, '10963^GET PDKEY FAIL',  'us_english', 840
execute rdt.rdtAddMsg 110964, 10, '10964^INS PDTL FAIL',   'us_english', 840
execute rdt.rdtAddMsg 110965, 10, '10965^UPD CASE FAIL',   'us_english', 840
execute rdt.rdtAddMsg 110966, 10, '10966^NoPaperPrinter',  'us_english', 840
execute rdt.rdtAddMsg 110967, 10, '10967^DWNOTSetup',      'us_english', 840
execute rdt.rdtAddMsg 110968, 10, '10968^TgetDB Not Set',  'us_english', 840
execute rdt.rdtAddMsg 110969, 10, '10969^NoLabelPrinter',  'us_english', 840
execute rdt.rdtAddMsg 110970, 10, '10970^DWNOTSetup',      'us_english', 840
execute rdt.rdtAddMsg 110971, 10, '10971^TgetDB Not Set',  'us_english', 840

select * from rdt.rdtmsg (nolock) where message_id between 110951 AND 111000
