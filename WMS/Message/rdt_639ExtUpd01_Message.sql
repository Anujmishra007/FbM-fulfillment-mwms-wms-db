--rdt_639ExtUpd01
execute rdt.rdtdropmsg 148551 , 148600	

execute rdt.rdtAddMsg 148551, 10, '48551^Ins XFER Fail',    'us_english', 639
execute rdt.rdtAddMsg 148552, 10, '48552^Getkey Fail',      'us_english', 639
execute rdt.rdtAddMsg 148553, 10, '48553^Ins XFERD Fail',   'us_english', 639
execute rdt.rdtAddMsg 148554, 10, '48554^Ins XFERD Fail',   'us_english', 639
execute rdt.rdtAddMsg 148555, 10, '48555^UCC Relot Fail',   'us_english', 639
execute rdt.rdtAddMsg 148556, 10, '48556^UCC Relot Fail',   'us_english', 639


SELECT * FROM RDT.RDTMSG (NOLOCK) WHERE MESSAGE_ID BETWEEN 148551 AND 148600