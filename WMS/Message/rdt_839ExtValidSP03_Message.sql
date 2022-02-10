--rdt_839ExtValidSP03
execute rdt.rdtdropmsg 148851 , 148900

execute rdt.rdtAddMsg 148851, 10, '48851^InvalidDropID',    'us_english', 839
execute rdt.rdtAddMsg 148852, 10, '48852^DropIDInUse',      'us_english', 839
execute rdt.rdtAddMsg 148853, 10, '48853^DropIDInUse',      'us_english', 839
execute rdt.rdtAddMsg 148854, 10, '48854^DropIDInUse',      'us_english', 839

SELECT * FROM RDT.RDTMSG (NOLOCK) WHERE Message_ID BETWEEN 148851 AND 148900



