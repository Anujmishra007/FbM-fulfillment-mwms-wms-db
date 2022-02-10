-- rdt_PreRcvSort01
exec rdt.rdtDropMsg 112501 , 112550

execute rdt.rdtAddMsg 112501, 10, '12501^NO SUGGEST LOC',   'us_english', 1829
execute rdt.rdtAddMsg 112502, 10, '12502^LOC IN USE',       'us_english', 1829
execute rdt.rdtAddMsg 112503, 10, '12503^INS LOG FAIL',     'us_english', 1829
execute rdt.rdtAddMsg 112504, 10, '12504^UPD LOG FAIL',     'us_english', 1829
execute rdt.rdtAddMsg 112505, 10, '12505^REL LOC FAIL',     'us_english', 1829
execute rdt.rdtAddMsg 112506, 10, 'ASN COMPLETE SORTING',   'us_english', 1829
execute rdt.rdtAddMsg 112507, 10, 'LAST SKU IN ASN',        'us_english', 1829

SELECT * FROM RDT.RDTMSG (NOLOCK) WHERE MESSAGE_ID BETWEEN 112501 AND 112550