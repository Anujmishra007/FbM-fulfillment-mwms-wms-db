--rdt_593UCCLabel04
exec rdt.rdtDropMsg 111851 , 111900

execute rdt.rdtAddMsg 111851, 10, '11851^Input Required',   'us_english', 593
execute rdt.rdtAddMsg 111852, 10, '11852^No Record',        'us_english', 593
execute rdt.rdtAddMsg 111853, 10, '11853^No Record',        'us_english', 593
execute rdt.rdtAddMsg 111854, 10, '11854^LabelPrnterReq',   'us_english', 593
execute rdt.rdtAddMsg 111855, 10, '11855^DWNOTSetup',       'us_english', 593
execute rdt.rdtAddMsg 111856, 10, '11856^TgetDB Not Set',   'us_english', 593
execute rdt.rdtAddMsg 111857, 10, '11857^CARTON LABEL:',    'us_english', 593
execute rdt.rdtAddMsg 111858, 10, '11858^LOAD NO:',         'us_english', 593

SELECT * FROM RDT.RDTMSG (NOLOCK) WHERE MESSAGE_ID BETWEEN 111851 AND 111900