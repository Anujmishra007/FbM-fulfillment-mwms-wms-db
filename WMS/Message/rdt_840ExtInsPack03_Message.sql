-- rdt_840ExtInsPack03
execute rdt.rdtdropmsg 131351 , 131400

execute rdt.rdtAddMsg 131351, 10, '31351^UPDLOG FAILED',   'us_english', 840
execute rdt.rdtAddMsg 131352, 10, '31352^INSLOG FAILED',   'us_english', 840
execute rdt.rdtAddMsg 131353, 10, '31353^INSPKHDR FAIL',   'us_english', 840
execute rdt.rdtAddMsg 131354, 10, '31354^UPDPKDET FAIL',   'us_english', 840
execute rdt.rdtAddMsg 131355, 10, '31355^NO TRACKING #',   'us_english', 840
execute rdt.rdtAddMsg 131356, 10, '31356^NO TRACKING #',   'us_english', 840
execute rdt.rdtAddMsg 131357, 10, '31357^ASSIGN TRK# ERR', 'us_english', 840
execute rdt.rdtAddMsg 131358, 10, '31358^GET LABEL Fail',  'us_english', 840
execute rdt.rdtAddMsg 131359, 10, '31359^INS PACK FAIL',   'us_english', 840
execute rdt.rdtAddMsg 131360, 10, '31360^INS PACK FAIL',   'us_english', 840
execute rdt.rdtAddMsg 131361, 10, '31361^UPD CASE FAIL',   'us_english', 840
execute rdt.rdtAddMsg 131362, 10, '31362^UPD CASE FAIL',   'us_english', 840
execute rdt.rdtAddMsg 131363, 10, '31363^GET PDKEY FAIL',  'us_english', 840
execute rdt.rdtAddMsg 131364, 10, '31364^INS PDTL FAIL',   'us_english', 840
execute rdt.rdtAddMsg 131365, 10, '31365^UPD CASE FAIL',   'us_english', 840

select * from rdt.rdtmsg (nolock) where message_id between 131351 AND 131400
