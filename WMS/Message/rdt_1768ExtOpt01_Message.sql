-- rdt_1768ExtOpt01
exec rdt.rdtDropMsg 241501 , 241550

execute rdt.rdtAddMsg 241501, 10, '241501 GetKey Fail  ',   'us_english', 1768
execute rdt.rdtAddMsg 241502, 10, '241502 Ins AdjHdr Er',   'us_english', 1768
execute rdt.rdtAddMsg 241503, 10, '241503 Ins AdjDtl Er',   'us_english', 1768
execute rdt.rdtAddMsg 241504, 10, '241504 FinalizeAdJEr',   'us_english', 1768

SELECT * FROM RDT.RDTMSG (NOLOCK) WHERE MESSAGE_ID BETWEEN 241501 AND 241550

