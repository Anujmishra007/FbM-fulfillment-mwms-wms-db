--rdt_834ExtValid01
rdt.rdtDropMsg 139251 , 139300

execute rdt.rdtAddMsg 139251, 10, '39251^UCC NOT EXISTS',   'us_english', 834
execute rdt.rdtAddMsg 139252, 10, '39252^UCC NOT READY',    'us_english', 834
execute rdt.rdtAddMsg 139253, 10, '39253^UCC SHIPPED',      'us_english', 834
execute rdt.rdtAddMsg 139254, 10, '39254^UCC SCANNED',      'us_english', 834
execute rdt.rdtAddMsg 139255, 10, '39255^PickSlip req',     'us_english', 834
execute rdt.rdtAddMsg 139256, 10, '39256^OVER PACK',        'us_english', 834
execute rdt.rdtAddMsg 139257, 10, 'NEED PACKINFO',          'us_english', 834
execute rdt.rdtAddMsg 139258, 10, 'CANNOT PRESS ESC',       'us_english', 834

SELECT * FROM RDT.RDTMSG (NOLOCK) WHERE MESSAGE_ID BETWEEN 139251 AND 139300