--rdt_1841ClosePlt02
exec rdt.rdtDropMsg 165701 , 165750

execute rdt.rdtAddMsg 165701, 10, '65701^Close Plt Fail',   'us_english', 1841

SELECT * FROM RDT.RDTMSG (NOLOCK) WHERE Message_ID BETWEEN 165701 AND 165750


