-- rdtfnc_JobCapture 
execute rdt.rdtDropMsg 128501, 128550

execute rdt.rdtAddMsg 128501, 10, '128501Need UserID   ', 'us_english', 705
execute rdt.rdtAddMsg 128502, 10, '128502Invalid UserID', 'us_english', 705
execute rdt.rdtAddMsg 128503, 10, '128503Inactive user ', 'us_english', 705
execute rdt.rdtAddMsg 128504, 10, '128504Need JobType  ', 'us_english', 705
execute rdt.rdtAddMsg 128505, 10, '128505InvalidJobType', 'us_english', 705
execute rdt.rdtAddMsg 128506, 10, '128506Need LOC      ', 'us_english', 705
execute rdt.rdtAddMsg 128507, 10, '128507Invalid LOC   ', 'us_english', 705
execute rdt.rdtAddMsg 128508, 10, '128508Need QTY      ', 'us_english', 705
execute rdt.rdtAddMsg 128509, 10, '128509Invalid QTY   ', 'us_english', 705
execute rdt.rdtAddMsg 128510, 10, '28510^Setup Column',   'us_english', 705
execute rdt.rdtAddMsg 128511, 10, '28511^Value Required', 'us_english', 705

--wms-17049
execute rdt.rdtAddMsg 128512, 10, '28512^Need data     ', 'us_english', 705

SELECT * FROM rdt.rdtMsg (NOLOCK) WHERE Message_ID BETWEEN 128501 and 128550
