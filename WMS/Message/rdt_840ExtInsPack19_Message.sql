--rdt_840ExtInsPack19
execute rdt.rdtdropmsg 198751 , 198800	

execute rdt.rdtAddMsg 198751, 10, '198751 UPDLOG FAILED',   'us_english', 840
execute rdt.rdtAddMsg 198752, 10, '198752 INSLOG FAILED',   'us_english', 840
execute rdt.rdtAddMsg 198753, 10, '198753 INSPKHDR FAIL',   'us_english', 840
execute rdt.rdtAddMsg 198754, 10, '198754 UPDPKDET FAIL',   'us_english', 840
execute rdt.rdtAddMsg 198755, 10, '198755GET LABEL FAIL',   'us_english', 840
execute rdt.rdtAddMsg 198756, 10, '198756GET LABEL FAIL',   'us_english', 840
execute rdt.rdtAddMsg 198757, 10, '198757 NO LABEL     ',   'us_english', 840
execute rdt.rdtAddMsg 198758, 10, '198758 INS PACK FAIL',   'us_english', 840
execute rdt.rdtAddMsg 198759, 10, '198759 Exec ITF Fail',   'us_english', 840
execute rdt.rdtAddMsg 198760, 10, '198760 INS PACK FAIL',   'us_english', 840
execute rdt.rdtAddMsg 198761, 10, 'PACK IN 1 CARTON    ',   'us_english', 840
execute rdt.rdtAddMsg 198762, 10, '198762 PACK IN 1 CTN',   'us_english', 840
execute rdt.rdtAddMsg 198763, 10, '198763 Ins CtnTrk Er',   'us_english', 840
execute rdt.rdtAddMsg 198764, 10, '198764 UPD TRK# FAIL',   'us_english', 840

select * from rdt.rdtmsg (nolock) where message_id between 198751 AND 198800	
