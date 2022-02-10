--rdt_834ExtValid02
rdt.rdtDropMsg 139401 , 139450

execute rdt.rdtAddMsg 139401, 10, '39401^UCC NOT EXISTS',   'us_english', 834
execute rdt.rdtAddMsg 139402, 10, '39402^UCC UOM = 6',      'us_english', 834
execute rdt.rdtAddMsg 139403, 10, '39403^UCC NOT EXISTS',   'us_english', 834
execute rdt.rdtAddMsg 139404, 10, '39404^UCC SHIPPED',      'us_english', 834
execute rdt.rdtAddMsg 139405, 10, '39405^UCC SCANNED',      'us_english', 834
execute rdt.rdtAddMsg 139406, 10, '39406^PickSlip req',     'us_english', 834
execute rdt.rdtAddMsg 139407, 10, '39407^OVER PACK',        'us_english', 834

SELECT * FROM RDT.RDTMSG (NOLOCK) WHERE MESSAGE_ID BETWEEN 139401 AND 139450