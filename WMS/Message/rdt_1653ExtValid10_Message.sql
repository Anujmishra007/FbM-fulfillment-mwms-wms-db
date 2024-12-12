--rdt_1653ExtValid10
--FCR-950
exec rdt.rdtDropMsg 225501 , 225550

execute rdt.rdtAddMsg 225501, 10, '225501CartonNotPacked',     'us_english', 1653
execute rdt.rdtAddMsg 225502, 10, '225502MBOLFinished',        'us_english', 1653

SELECT * FROM RDT.RDTMSG (NOLOCK) WHERE Message_ID BETWEEN 225501 AND 225550

