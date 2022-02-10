-- rdt_638ExtUpd01
-- 146451 - 146500	
rdt.rdtDropMsg 146451 , 146500

execute rdt.rdtAddMsg 146451, 10, '46351^Line Finalized',   'us_english', 638

-- WMS-15363
execute rdt.rdtAddMsg 146452, 10, '46352^No ToLoc',         'us_english', 638

SELECT * FROM RDT.RDTMSG (NOLOCK) WHERE MESSAGE_ID BETWEEN 146451 AND 146500