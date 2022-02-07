--rdt_1831CfmTask01
exec rdt.rdtDropMsg 124551 , 124600

execute rdt.rdtAddMsg 124551, 10, '24551^UPD PKDtl Fail',   'us_english', 1831
execute rdt.rdtAddMsg 124552, 10, '24552^UPD PKDtl Fail',   'us_english', 1831
execute rdt.rdtAddMsg 124553, 10, '24553^GetKey Fail',      'us_english', 1831
execute rdt.rdtAddMsg 124554, 10, '24554^INS PKDtl Fail',   'us_english', 1831
execute rdt.rdtAddMsg 124555, 10, '24555^INS RefKeyFail',   'us_english', 1831
execute rdt.rdtAddMsg 124556, 10, '24556^UPD PKDtl Fail',   'us_english', 1831
execute rdt.rdtAddMsg 124557, 10, '24557^UPD PKDtl Fail',   'us_english', 1831
execute rdt.rdtAddMsg 124558, 10, '24558^Offset Fail',      'us_english', 1831
execute rdt.rdtAddMsg 124559, 10, '24559^Updatelog Fail',   'us_english', 1831

SELECT * FROM RDT.RDTMSG (NOLOCK) WHERE MESSAGE_ID BETWEEN 124551 AND 124600