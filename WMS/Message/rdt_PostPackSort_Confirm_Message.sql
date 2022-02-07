--rdt_PostPackSort_Confirm
rdt.rdtDropMsg 144451 , 144500

execute rdt.rdtAddMsg 144451, 10, '44451^Assign Loc Err',   'us_english', 1837
execute rdt.rdtAddMsg 144452, 10, '44452^Close Plt Fail',   'us_english', 1837

SELECT * FROM RDT.RDTMSG (NOLOCK) WHERE MESSAGE_ID BETWEEN 144451 AND 144500

