--rdt_593ShipLabel07
 exec rdt.rdtDropMsg 112601 , 112650

execute rdt.rdtAddMsg 112601, 10, '12601^TrackNo Req',      'us_english', 593
execute rdt.rdtAddMsg 112602, 10, '12602^Invalid Track#',   'us_english', 593
execute rdt.rdtAddMsg 112603, 10, '12603^No ShipperKey',    'us_english', 593
execute rdt.rdtAddMsg 112604, 10, '12604^Order Not Pick',   'us_english', 593

SELECT * FROM RDT.RDTMSG (NOLOCK) WHERE MESSAGE_ID BETWEEN 112601 AND 112650