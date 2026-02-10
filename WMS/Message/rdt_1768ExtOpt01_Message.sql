-- FCR-6059
-- rdt_1768ExtOpt01
exec rdt.rdtDropMsg 241501 , 241550

execute rdt.rdtAddMsg 241501, 10, '241501 GetKey Fail  ',   'us_english', 1768
execute rdt.rdtAddMsg 241502, 10, '241502 Ins AdjHdr Er',   'us_english', 1768
execute rdt.rdtAddMsg 241503, 10, '241503 Ins AdjDtl Er',   'us_english', 1768
execute rdt.rdtAddMsg 241504, 10, '241504 UpdTaskDetErr',   'us_english', 1768
execute rdt.rdtAddMsg 241505, 10, '241505 Upd LastCC Er',   'us_english', 1768
execute rdt.rdtAddMsg 241506, 10, '241506 CloseAlertErr',   'us_english', 1768
execute rdt.rdtAddMsg 241507, 10, '241507 FinalizeAdJEr',   'us_english', 1768

--FCR-8158
execute rdt.rdtAddMsg 241508, 10, '241508 FinalizeAdJEr',   'us_english', 1768, 0, '241508 Finalized Adj SQL Error'
execute rdt.rdtAddMsg 241509, 10, '241509 SQL Exception',   'us_english', 1768, 0, '241509 SQL exception occured while generating key'
execute rdt.rdtAddMsg 241510, 10, '241510 GetKey Fail  ',   'us_english', 1768, 0, '241510 Generate Adjustment Key Failed'
execute rdt.rdtAddMsg 241511, 10, '241511 SQL Exception',   'us_english', 1768, 0, '241511 SQL exception occured while inserting Adjustment'
execute rdt.rdtAddMsg 241512, 10, '241512 SQL Exception',   'us_english', 1768, 0, '241512 SQL exception occured while inserting Adjustment Detail'

SELECT * FROM RDT.RDTMSG (NOLOCK) WHERE MESSAGE_ID BETWEEN 241501 AND 241550

