--rdt_1764ExtValid04
-- FCR-7730
EXECUTE rdt.rdtDropMsg 246601 , 246650

EXECUTE rdt.rdtAddMsg 246601, 10, '246601^LocNotPND',       'us_english', 1764, 0, '246601 Location is not PND'
EXECUTE rdt.rdtAddMsg 246602, 10, '246602^DiffToLoc',       'us_english', 1764, 0, '246602 ToLoc is different as suggested Loc'

SELECT * FROM RDT.RDTMSG WITH(NOLOCK) WHERE MESSAGE_ID BETWEEN 246601 AND 246650