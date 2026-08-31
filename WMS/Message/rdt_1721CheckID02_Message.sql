execute rdt.rdtDropMsg 277201, 277250


execute rdt.rdtAddMsg 277201, 10, '277201 Need ID',      'us_english', 1721
execute rdt.rdtAddMsg 277202, 10, '277202 Invalid ID',   'us_english', 1721

SELECT * FROM rdt.RDTMSG WITH(NOLOCK) WHERE Message_ID BETWEEN 277201 AND 277250
