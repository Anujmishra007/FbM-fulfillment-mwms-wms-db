-- rdt_1829ExtValid01
exec rdt.rdtDropMsg 112451 , 112500

execute rdt.rdtAddMsg 112451, 10, '12451^Need RecGrp',      'us_english', 1829
execute rdt.rdtAddMsg 112452, 10, '12452^Invalid RecGrp',   'us_english', 1829
execute rdt.rdtAddMsg 112453, 10, '12453^RecGrp Sorted',    'us_english', 1829
execute rdt.rdtAddMsg 112454, 10, '12454^UCC Not Exists',   'us_english', 1829
execute rdt.rdtAddMsg 112455, 10, '12455^UCC Scanned',      'us_english', 1829
execute rdt.rdtAddMsg 112456, 10, '12456^Nothing 2 End',    'us_english', 1829

SELECT * FROM RDT.RDTMSG (NOLOCK) WHERE MESSAGE_ID BETWEEN 112451 AND 112500