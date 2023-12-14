--rdt_573ExtValidSP10
exec rdt.rdtDropMsg 209251 , 209300

execute rdt.rdtAddMsg 209251, 10, '209251DuplicateUCC',     'us_english', 573
execute rdt.rdtAddMsg 209252, 10, '209252CubicSnReq',     'us_english', 573

SELECT * FROM RDT.RDTMSG (NOLOCK) WHERE Message_ID BETWEEN 209251 AND 209300

