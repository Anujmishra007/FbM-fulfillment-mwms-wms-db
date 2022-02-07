--rdt_ShortPickHold
execute rdt.rdtDropMsg 153801 , 153850

execute rdt.rdtAddMsg 153801, 10, '53801^Setup QcmdCfg',     'us_english', 0
execute rdt.rdtAddMsg 153802, 10, '53802^ShortPkNoFound',   'us_english', 0

SELECT * FROM RDT.RDTMSG (NOLOCK) WHERE MESSAGE_ID BETWEEN 153801 AND 153850