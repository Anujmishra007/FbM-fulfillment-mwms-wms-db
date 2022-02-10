--rdtfnc_Tore_ConveyerMove
--execute rdt.rdtdropmsg 71116, 71140

execute rdt.rdtAddMsg 71116, 10, '71116^CASE/TOTE req',  'us_english'
execute rdt.rdtAddMsg 71117, 10, '71117^CASE/TOTE ONLY', 'us_english'
execute rdt.rdtAddMsg 71118, 10, '71118^INVALID TOTENO',  'us_english'
execute rdt.rdtAddMsg 71119, 10, '71119^INVALID TOTENO', 'us_english'
execute rdt.rdtAddMsg 71120, 10, '71120^INVALID TOTENO',  'us_english'
execute rdt.rdtAddMsg 71121, 10, '71121^INVALID TOTENO', 'us_english'
execute rdt.rdtAddMsg 71122, 10, '71122^Station Req',    'us_english'
execute rdt.rdtAddMsg 71123, 10, '71123^BAD Station',    'us_english'
execute rdt.rdtAddMsg 71124, 10, '71124^CANNOT >7 STAT', 'us_english'
execute rdt.rdtAddMsg 71125, 10, '71125^Option Req',     'us_english'
execute rdt.rdtAddMsg 71126, 10, '71126^Invalid Opt',    'us_english'
execute rdt.rdtAddMsg 71127, 10, '71127^GetWCSKey Fail', 'us_english'
execute rdt.rdtAddMsg 71128, 10, '71128^CrtRouteFail',   'us_english'
execute rdt.rdtAddMsg 71129, 10, '71129^UpdRouteFail',   'us_english'
execute rdt.rdtAddMsg 71130, 10, '71130^CrtWCSRECFail',  'us_english'
execute rdt.rdtAddMsg 71131, 10, '71131^BAD Station',    'us_english'
execute rdt.rdtAddMsg 71132, 10, '71132^GetWCSKey Fail', 'us_english'
execute rdt.rdtAddMsg 71133, 10, '71133^CrtRouteFail',   'us_english'
execute rdt.rdtAddMsg 71134, 10, '71134^CrtRouteFaild',  'us_english'
execute rdt.rdtAddMsg 71135, 10, '71135^CrtWCSRECFail',  'us_english'



SELECT * FROM RDT.RDTMSG (NOLOCK) WHERE MESSAGE_ID BETWEEN 71116 AND 71140