-- rdt_1637ExtValid13
--FCR-673
execute rdt.rdtdropmsg 221201, 221250

execute rdt.rdtAddMsg 221201, 10, '221201 ContainerKeyNeeded',    'us_english', 1637, 0, '221201 Container Key is Needed'
execute rdt.rdtAddMsg 221202, 10, '221202 ContainerNoNeeded',     'us_english', 1637, 0, '221202 Container NO is Needed'
execute rdt.rdtAddMsg 221203, 10, '221203 ContainerClosed',       'us_english', 1637, 0, '221203 Container is closed'
execute rdt.rdtAddMsg 221204, 10, '221204 NoMbolKey',             'us_english', 1637, 0, '221204 No MBOL Key'
execute rdt.rdtAddMsg 221205, 10, '221205 InvalidContainer',      'us_english', 1637, 0, '221205 Invalid Container#'
execute rdt.rdtAddMsg 221206, 10, '221206 InvalidPallet',         'us_english', 1637, 0, '221206 Invalid Pallet ID'
execute rdt.rdtAddMsg 221207, 10, '221207 PalletScanned',         'us_english', 1637, 0, '221207 Pallet ID Already Scanned'
execute rdt.rdtAddMsg 221208, 10, '221208 DiffMBolKey',           'us_english', 1637
execute rdt.rdtAddMsg 221209, 10, '221209 DiffCntNo',             'us_english', 1637, 0, '221209 Different Container#'

SELECT * FROM RDT.RDTMsg WITH(NOLOCK) WHERE Message_ID BETWEEN 221201 AND 221250
