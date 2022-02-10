-- rdt_840ExtInsPack06
execute rdt.rdtdropmsg 135801 , 135850

execute rdt.rdtAddMsg 135801, 10, '35801^UPDLOG FAILED',   'us_english', 840
execute rdt.rdtAddMsg 135802, 10, '35802^INSLOG FAILED',   'us_english', 840
execute rdt.rdtAddMsg 135803, 10, '35803^INSPKHDR FAIL',   'us_english', 840
execute rdt.rdtAddMsg 135804, 10, '35804^UPDPKDET FAIL',   'us_english', 840
execute rdt.rdtAddMsg 135805, 10, '35805^GET LABEL Fail',  'us_english', 840
execute rdt.rdtAddMsg 135806, 10, '35806^INS PACK FAIL',   'us_english', 840
execute rdt.rdtAddMsg 135807, 10, '35807^INS PACK FAIL',   'us_english', 840
execute rdt.rdtAddMsg 135808, 10, '35808^UPD DROPID ERR',  'us_english', 840

select * from rdt.rdtmsg (nolock) where message_id between 135801 AND 135850
