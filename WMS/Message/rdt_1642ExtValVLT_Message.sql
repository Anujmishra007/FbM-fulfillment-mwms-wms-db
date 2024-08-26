--Message file
--execute rdt.rdtdropmsg

execute rdt.rdtAddMsg 217992, 10, 'Non-numeric sequence',     'us_english', 1642
execute rdt.rdtAddMsg 217993, 10, '993^Missing sequence',     'us_english', 1642
execute rdt.rdtAddMsg 217994, 10, 'Duplicated sequence',     'us_english', 1642
execute rdt.rdtAddMsg 217995, 10, 'Loc is not a door',     'us_english', 1642
execute rdt.rdtAddMsg 217996, 10, 'Not all items picked',     'us_english', 1642
execute rdt.rdtAddMsg 217997, 10, 'Not fully staged',     'us_english', 1642
execute rdt.rdtAddMsg 217998, 10, 'Not all items packed',     'us_english', 1642
execute rdt.rdtAddMsg 217999, 10, '7999^Out of Sequence',     'us_english', 1642

SELECT * FROM RDT.RDTMSG WITH(NOLOCK) WHERE Message_ID BETWEEN 217992 AND 217999
