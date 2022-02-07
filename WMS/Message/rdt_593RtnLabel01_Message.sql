--rdt_593RtnLabel01
 exec rdt.rdtDropMsg 112651 , 112700

execute rdt.rdtAddMsg 112651, 10, '12651^TrackNo Req',      'us_english', 593
execute rdt.rdtAddMsg 112652, 10, '12652^Invalid Track#',   'us_english', 593
execute rdt.rdtAddMsg 112653, 10, '12653^No OrderKey',      'us_english', 593
execute rdt.rdtAddMsg 112654, 10, '12654^Order Not Pick',   'us_english', 593

SELECT * FROM RDT.RDTMSG (NOLOCK) WHERE MESSAGE_ID BETWEEN 112651 AND 112700