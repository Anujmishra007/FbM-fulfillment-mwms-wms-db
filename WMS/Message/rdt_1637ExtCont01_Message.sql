--rdt_1637ExtCont01
execute rdt.rdtDropMsg 215601 , 215650

execute rdt.rdtAddMsg 215601, 10, '215601 GETKEY FAILED',   'us_english', 1637
execute rdt.rdtAddMsg 215602, 10, '215602 INS CONT FAIL',   'us_english', 1637

SELECT * FROM RDT.RDTMsg (NOLOCK) WHERE Message_ID BETWEEN 215601 AND 215650