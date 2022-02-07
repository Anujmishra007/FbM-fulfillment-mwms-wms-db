-- rdt_IDXPackInfo01
-- EXEC RDT.RDTDROPMSG 85801, 85850

execute rdt.rdtAddMsg '85801', 10, '85801^NO CARTON NO',   'us_english'
execute rdt.rdtAddMsg '85802', 10, '85802^NO PACKINFO',    'us_english'
execute rdt.rdtAddMsg '85803', 10, '85803^UPD WEIGHT ERR', 'us_english'

-- SELECT * FROM RDT.RDTMSG (NOLOCK) WHERE MESSAGE_ID BETWEEN 85801 AND 85850
