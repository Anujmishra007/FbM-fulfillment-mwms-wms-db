-- rdt_838ExtVal38
execute rdt.rdtDropMsg 257451, 257500

execute rdt.rdtAddMsg 257451, 10, '257451 PPANotComplete', 'us_english', 838, 0, '257451 DropID without PPA at 100%'

SELECT * FROM rdt.rdtMSg WITH(NOLOCK) WHERE Message_ID BETWEEN 257451 AND 257500