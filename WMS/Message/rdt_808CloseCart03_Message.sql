--rdt_808CloseCart03
rdt.rdtDropMsg 146901 , 146950

execute rdt.rdtAddMsg 146901, 10, '46901^DEL DPL Fail',  'us_english', 808
execute rdt.rdtAddMsg 146902, 10, '46902^DEL PTL Fail',  'us_english', 808

SELECT * FROM RDT.RDTMSG (NOLOCK) WHERE MESSAGE_ID BETWEEN 146901 AND 146950