--rdt_640ExtValid01
rdt.rdtDropMsg 156901 , 156950

execute rdt.rdtAddMsg 156901, 10, 'PICK IN PROGRESS',    'us_english', 640
execute rdt.rdtAddMsg 156902, 10, 'CANNOT ABORT',        'us_english', 640

SELECT * FROM RDT.RDTMSG (NOLOCK) WHERE MESSAGE_ID BETWEEN 156901 AND 156950