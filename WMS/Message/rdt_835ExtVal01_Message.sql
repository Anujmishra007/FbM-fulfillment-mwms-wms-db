-- rdt_835ExtVal01
rdt.rdtDropMsg 139051 , 139100

execute rdt.rdtAddMsg 139051, 10, '39051^Invalid PS#',         'us_english', 835
execute rdt.rdtAddMsg 139052, 10, '39052^Pack Confirm',        'us_english', 835
execute rdt.rdtAddMsg 139053, 10, '39053^OVER PACK',           'us_english', 835
execute rdt.rdtAddMsg 139054, 10, '39054^ID NOT IN PSNO',      'us_english', 835
execute rdt.rdtAddMsg 139055, 10, '39055^OVER PACK',           'us_english', 835


SELECT * FROM RDT.RDTMSG (NOLOCK) WHERE MESSAGE_ID BETWEEN 139051 AND 139100