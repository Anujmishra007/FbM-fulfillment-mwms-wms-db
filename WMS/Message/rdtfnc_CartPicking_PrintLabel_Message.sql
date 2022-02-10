-- rdtfnc_CartPicking_PrintLabel
exec rdt.rdtDropMsg 150601 , 150650

execute rdt.rdtAddMsg 150601, 10, '50601^Need Area',        'us_english', 646
execute rdt.rdtAddMsg 150602, 10, '50602^Invalid Area',     'us_english', 646
execute rdt.rdtAddMsg 150603, 10, '50603^Need Cart ID',     'us_english', 646
execute rdt.rdtAddMsg 150604, 10, '50604^Inv Cart ID',      'us_english', 646
execute rdt.rdtAddMsg 150605, 10, '50605^Need User ID',     'us_english', 646
execute rdt.rdtAddMsg 150606, 10, '50606^Invalid UserID',   'us_english', 646
execute rdt.rdtAddMsg 150607, 10, '50607^Not User Area',    'us_english', 646
execute rdt.rdtAddMsg 150608, 10, '50608^Need Task Type',   'us_english', 646
execute rdt.rdtAddMsg 150609, 10, '50609^No Permission',    'us_english', 646
execute rdt.rdtAddMsg 150610, 10, '50610^Inv # Of Task',    'us_english', 646
execute rdt.rdtAddMsg 150611, 10, '50611^Over Capacity',    'us_english', 646
execute rdt.rdtAddMsg 150612, 10, '50612^Cart In Use',      'us_english', 646

SELECT * FROM RDT.RDTMSG (NOLOCK) WHERE Message_ID BETWEEN 150601 AND 150650

