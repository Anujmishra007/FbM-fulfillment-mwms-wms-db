-- rdt_1637ExtValid07
execute rdt.rdtDropMsg 162751, 162800

execute rdt.rdtAddMsg 162751, 10, '162751Pallet Mix Coo',  'us_english', 1637
execute rdt.rdtAddMsg 162752, 10, '62752ContainerMixCoo',  'us_english', 1637

SELECT TOP 10 * FROM rdt.rdtMsg (NOLOCK) WHERE Message_ID BETWEEN 162751 and 162800
