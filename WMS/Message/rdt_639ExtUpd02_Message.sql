--rdt_639ExtUpd02
execute rdt.rdtdropmsg 167201, 167250

execute rdt.rdtAddMsg 167201, 10, '67201^Ins XFER Fail',    'us_english', 639
execute rdt.rdtAddMsg 167202, 10, '67202^Getkey Fail  ',      'us_english', 639
execute rdt.rdtAddMsg 167203, 10, '67203^Ins XFERD Fail',   'us_english', 639
execute rdt.rdtAddMsg 167204, 10, '67204^Ins XFERD Fail',   'us_english', 639
execute rdt.rdtAddMsg 167205, 10, '67205^UCC Relot Fail',   'us_english', 639
execute rdt.rdtAddMsg 167206, 10, '67206^UCC Relot Fail',   'us_english', 639


SELECT * FROM RDT.RDTMSG (NOLOCK) WHERE MESSAGE_ID BETWEEN 167201 AND 167250