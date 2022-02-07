--rdt_593ShipLabel08
 exec rdt.rdtDropMsg 112901 , 112950

execute rdt.rdtAddMsg 112901, 10, '12901^Label No Req',     'us_english', 593
execute rdt.rdtAddMsg 112902, 10, '12902^Invalid Label',    'us_english', 593

SELECT * FROM RDT.RDTMSG (NOLOCK) WHERE MESSAGE_ID BETWEEN 112901 AND 112950