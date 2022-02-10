--rdt_840ExtInsPack09
execute rdt.rdtdropmsg 150351 , 150400


execute rdt.rdtAddMsg 150351, 10, '50351^UPDLOG FAILED',   'us_english', 840
execute rdt.rdtAddMsg 150352, 10, '50352^INSLOG FAILED',   'us_english', 840
execute rdt.rdtAddMsg 150353, 10, '50353^INSPKHDR FAIL',   'us_english', 840
execute rdt.rdtAddMsg 150354, 10, '50354^UPDPKDET FAIL',   'us_english', 840
execute rdt.rdtAddMsg 150355, 10, '50355^NO TRACKING #',   'us_english', 840
execute rdt.rdtAddMsg 150356, 10, '50356^NO TRACKING #',   'us_english', 840
execute rdt.rdtAddMsg 150357, 10, '50357^ASSIGN TRK# ERR', 'us_english', 840
execute rdt.rdtAddMsg 150358, 10, '50358^GET LABEL Fail',  'us_english', 840
execute rdt.rdtAddMsg 150359, 10, '50359^INS PACK FAIL',   'us_english', 840
execute rdt.rdtAddMsg 150360, 10, '50360^INS PACK FAIL',   'us_english', 840
execute rdt.rdtAddMsg 150361, 10, '50361^UPD CASE FAIL',   'us_english', 840
execute rdt.rdtAddMsg 150362, 10, '50362^UPD CASE FAIL',   'us_english', 840
execute rdt.rdtAddMsg 150363, 10, '50363^GET PDKEY FAIL',  'us_english', 840
execute rdt.rdtAddMsg 150364, 10, '50364^INS PDTL FAIL',   'us_english', 840
execute rdt.rdtAddMsg 150365, 10, '50365^UPD CASE FAIL',   'us_english', 840

select * from rdt.rdtmsg (nolock) where message_id between 150351 AND 150400
