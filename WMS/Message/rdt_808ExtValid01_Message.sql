--rdt_808ExtValid01
rdt.rdtDropMsg 146401 , 146450

execute rdt.rdtAddMsg 146401, 10, '46401^ToteID In Used',  'us_english', 808
execute rdt.rdtAddMsg 146402, 10, '46402^ToteID Used',     'us_english', 808
execute rdt.rdtAddMsg 146403, 10, '46403^ToteID In Used',  'us_english', 808
execute rdt.rdtAddMsg 146404, 10, '46404^ToteID Used',     'us_english', 808

SELECT * FROM RDT.RDTMSG (NOLOCK) WHERE MESSAGE_ID BETWEEN 146401 AND 146450