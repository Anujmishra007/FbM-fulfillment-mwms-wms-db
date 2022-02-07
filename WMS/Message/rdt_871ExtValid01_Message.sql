-- rdt_871ExtValid01
exec rdt.rdtDropMsg 114851 , 114900

execute rdt.rdtAddMsg 114851, 10, '14851^NEED SERIALNO',    'us_english', 871
execute rdt.rdtAddMsg 114852, 10, '14852^NOT BOM SrNo',     'us_english', 871
execute rdt.rdtAddMsg 114853, 10, '14853^NO CHILD SrNo',    'us_english', 871
execute rdt.rdtAddMsg 114854, 10, '14854^INVALID SrNo',     'us_english', 871

SELECT * FROM RDT.RDTMSG (NOLOCK) WHERE MESSAGE_ID BETWEEN 114851 AND 114900