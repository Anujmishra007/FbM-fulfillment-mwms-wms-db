--rdt_830GetTask05
--execute rdt.rdtdropmsg 275351, 275400
execute rdt.rdtdropmsg 275351, 275400

execute rdt.rdtAddMsg 275351, 10, '275351 No More Task', 'us_english', 830
execute rdt.rdtAddMsg 275352, 10, '275352 No More Task', 'us_english', 830
execute rdt.rdtAddMsg 275353, 10, '275353LotCdNotSetup', 'us_english', 830, 0, 'LottableCode Not Found'
execute rdt.rdtAddMsg 275354, 10, '275354LotFldNotCfig', 'us_english', 830, 0, 'Lottable Field Not Configured'
execute rdt.rdtAddMsg 275355, 10, '275355ExecSQLError ', 'us_english', 830, 0, 'Execute GetTask SQL Error'

select * from rdt.rdtmsg (nolock) where message_id between 275351 and 275400
