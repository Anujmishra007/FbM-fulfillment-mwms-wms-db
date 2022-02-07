-- rdt_897ExtValidSP02
execute rdt.rdtDropMsg 118651 , 118700

execute rdt.rdtAddMsg 118651, 10, '18651^CARTON ID DOES', 'us_english', 897
execute rdt.rdtAddMsg 118652, 10, '18652^NOT EXISTS',     'us_english', 897
execute rdt.rdtAddMsg 118653, 10, '18653^CARTON ID',      'us_english', 897
execute rdt.rdtAddMsg 118654, 10, '18654^ALREADY',        'us_english', 897
execute rdt.rdtAddMsg 118655, 10, '18655^RECEIVED',       'us_english', 897
execute rdt.rdtAddMsg 118656, 10, '18656^ASN NOT EXISTS', 'us_english', 897
execute rdt.rdtAddMsg 118657, 10, '18657^ASN NOT EXISTS', 'us_english', 897
execute rdt.rdtAddMsg 118658, 10, '18658^ASN CLOSED',     'us_english', 897

SELECT * FROM RDT.RDTMSG (NOLOCK) WHERE MESSAGE_ID BETWEEN 118651 AND 118700