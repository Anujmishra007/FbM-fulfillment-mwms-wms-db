--Message file
--execute rdt.rdtdropmsg

execute rdt.rdtDropMsg 218019, 218019
execute rdt.rdtDropMsg 218004, 218005
execute rdt.rdtDropMsg 218035, 218035
execute rdt.rdtDropMsg 218038, 218039

execute rdt.rdtAddMsg 218019, 10, '218019Over cart capacity',     'us_english', 600, 0, '218019O ver cart capacity'
execute rdt.rdtAddMsg 218004, 10, '218004Receive to trolley',     'us_english', 600, 0, '218004 Receive to trolley'
execute rdt.rdtAddMsg 218005, 10, '218005Receive to INB stage',   'us_english', 600, 0, '218005 Receive to INB stage'
execute rdt.rdtAddMsg 218035, 10, '218035Cannot receive cons',    'us_english', 600, 0, '218035 Cannot receive cons'
execute rdt.rdtAddMsg 218038, 10, '218038No loc or big/heavy',    'us_english', 600, 0, '218038 No loc or big/heavy'
execute rdt.rdtAddMsg 218039, 10, '218039No shelfpick loc set',   'us_english', 600, 0, '218039 No shelfpick loc set'

SELECT * FROM RDT.RDTMSG WITH(NOLOCK) WHERE Message_ID IN( 218004, 218005, 218019, 218035, 218038, 218039)