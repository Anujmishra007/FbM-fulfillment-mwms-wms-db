-- rdt_840ExtInsPack08
execute rdt.rdtdropmsg 149701 , 149750

execute rdt.rdtAddMsg 149701, 10, '49701^UPDLOG FAILED',   'us_english', 840
execute rdt.rdtAddMsg 149702, 10, '49702^INSLOG FAILED',   'us_english', 840
execute rdt.rdtAddMsg 149703, 10, '49703^INSPKHDR FAIL',   'us_english', 840
execute rdt.rdtAddMsg 149704, 10, '49704^UPDPKDET FAIL',   'us_english', 840
execute rdt.rdtAddMsg 149705, 10, '49705^NO TRACKING #',   'us_english', 840
execute rdt.rdtAddMsg 149706, 10, '49706^NOT PREPAID',     'us_english', 840
execute rdt.rdtAddMsg 149707, 10, '49707^NO TRACKING #',   'us_english', 840
execute rdt.rdtAddMsg 149708, 10, '49708^ASSIGN TRK# ERR', 'us_english', 840
execute rdt.rdtAddMsg 149709, 10, '49709^GET LABEL Fail',  'us_english', 840
execute rdt.rdtAddMsg 149710, 10, '49710^INS PACK FAIL',   'us_english', 840
execute rdt.rdtAddMsg 149711, 10, '49711^INS PACK FAIL',   'us_english', 840
execute rdt.rdtAddMsg 149712, 10, '49712^UPD CASE FAIL',   'us_english', 840
execute rdt.rdtAddMsg 149713, 10, '49713^UPD CASE FAIL',   'us_english', 840
execute rdt.rdtAddMsg 149714, 10, '49714^GET PDKEY FAIL',  'us_english', 840
execute rdt.rdtAddMsg 149715, 10, '49715^INS PDTL FAIL',   'us_english', 840
execute rdt.rdtAddMsg 149716, 10, '49716^UPD CASE FAIL',   'us_english', 840

select * from rdt.rdtmsg (nolock) where message_id between 149701 AND 149750
