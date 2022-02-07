-- rdt_743ExtPASP03 
execute rdt.rdtDropMsg 114651 , 114700

execute rdt.rdtAddMsg 114651, 10, '14651^ID MIX GRADE',   'us_english', 743
execute rdt.rdtAddMsg 114652, 10, '14652^INV SKU GRADE',  'us_english', 743
execute rdt.rdtAddMsg 114653, 10, '14653^NO HOME LOC',    'us_english', 743

SELECT * FROM RDT.RDTMSG (NOLOCK) WHERE MESSAGE_ID BETWEEN 114651 AND 114700