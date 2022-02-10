--rdt_840ExtInsPack01
execute rdt.rdtdropmsg 96501 , 96550


execute rdt.rdtAddMsg 96501, 10, '96501^UPDLOG FAILED',   'us_english', 840
execute rdt.rdtAddMsg 96502, 10, '96502^INSLOG FAILED',   'us_english', 840
execute rdt.rdtAddMsg 96503, 10, '96503^INSPKHDR FAIL',   'us_english', 840
execute rdt.rdtAddMsg 96504, 10, '96504^UPDPKDET FAIL',   'us_english', 840
execute rdt.rdtAddMsg 96505, 10, '96505^NO TRACKING #',   'us_english', 840
execute rdt.rdtAddMsg 96506, 10, '96506^NO TRACKING #',   'us_english', 840
execute rdt.rdtAddMsg 96507, 10, '96507^ASSIGN TRK# ERR', 'us_english', 840
execute rdt.rdtAddMsg 96508, 10, '96508^GET LABEL Fail',  'us_english', 840
execute rdt.rdtAddMsg 96509, 10, '96509^INS PACK FAIL',   'us_english', 840
execute rdt.rdtAddMsg 96510, 10, '96510^INS PACK FAIL',   'us_english', 840
execute rdt.rdtAddMsg 96511, 10, '96511^UPD CASE FAIL',   'us_english', 840
execute rdt.rdtAddMsg 96512, 10, '96512^UPD CASE FAIL',   'us_english', 840
execute rdt.rdtAddMsg 96513, 10, '96513^GET PDKEY FAIL',  'us_english', 840
execute rdt.rdtAddMsg 96514, 10, '96514^INS PDTL FAIL',   'us_english', 840
execute rdt.rdtAddMsg 96515, 10, '96515^UPD CASE FAIL',   'us_english', 840
execute rdt.rdtAddMsg 96516, 10, '96516^NoPaperPrinter',  'us_english', 840
execute rdt.rdtAddMsg 96517, 10, '96517^DWNOTSetup',      'us_english', 840
execute rdt.rdtAddMsg 96518, 10, '96518^TgetDB Not Set',  'us_english', 840
execute rdt.rdtAddMsg 96519, 10, '96519^NoLabelPrinter',  'us_english', 840
execute rdt.rdtAddMsg 96520, 10, '96520^DWNOTSetup',      'us_english', 840
execute rdt.rdtAddMsg 96521, 10, '96521^TgetDB Not Set',  'us_english', 840

select * from rdt.rdtmsg (nolock) where message_id between 96501 and 96550
