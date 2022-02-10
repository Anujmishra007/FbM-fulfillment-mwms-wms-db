-- rdtHnMSwapLot01
EXEC rdt.rdtDropMsg 87051 , 87100

execute rdt.rdtAddMsg '87051', 10, '87051^INVALID ORDER ', 'us_english', 840
execute rdt.rdtAddMsg '87052', 10, '87052^INVALID SKU   ', 'us_english', 840
execute rdt.rdtAddMsg '87053', 10, '87053^INVALID LOT02 ', 'us_english', 840
execute rdt.rdtAddMsg '87054', 10, '87054^INVALID LABEL ', 'us_english', 840
execute rdt.rdtAddMsg '87055', 10, '87055^SKU OVERPACKED', 'us_english', 840
execute rdt.rdtAddMsg '87056', 10, '87056^UPDPKDET Fail ', 'us_english', 840
execute rdt.rdtAddMsg '87057', 10, '87057^NO LOT 2 SWAP ', 'us_english', 840
execute rdt.rdtAddMsg '87058', 10, '87058^NO LOT 2 SWAP ', 'us_english', 840
execute rdt.rdtAddMsg '87059', 10, '87059^SWAP LOT FAIL ', 'us_english', 840
execute rdt.rdtAddMsg '87060', 10, '87060^SWAP LOT FAIL ', 'us_english', 840
execute rdt.rdtAddMsg '87061', 10, '87061^SWAP LOT FAIL ', 'us_english', 840
execute rdt.rdtAddMsg '87062', 10, '87062^NO INV 2 SWAP ', 'us_english', 840
execute rdt.rdtAddMsg '87063', 10, '87063^UpdLog Failed ', 'us_english', 840
execute rdt.rdtAddMsg '87064', 10, '87064^InsLog Failed ', 'us_english', 840
execute rdt.rdtAddMsg '87065', 10, '87065^InsPKHDR Fail ', 'us_english', 840
execute rdt.rdtAddMsg '87066', 10, '87066^UPDPKDET Fail ', 'us_english', 840
execute rdt.rdtAddMsg '87067', 10, '87067^UPDPKDET Fail ', 'us_english', 840
execute rdt.rdtAddMsg '87068', 10, '87068^GET LABEL Fail', 'us_english', 840
execute rdt.rdtAddMsg '87069', 10, '87069^INSPKDET Fail ', 'us_english', 840
execute rdt.rdtAddMsg '87070', 10, '87070^INSPKDET Fail ', 'us_english', 840
execute rdt.rdtAddMsg '87071', 10, '87071^SKU NOT IN ORD', 'us_english', 840
execute rdt.rdtAddMsg '87072', 10, '87072^NO LOT 2 SWAP ', 'us_english', 840
execute rdt.rdtAddMsg '87073', 10, '87073^NO LOT 2 SWAP ', 'us_english', 840

-- WMS-16145
execute rdt.rdtAddMsg 87074, 10, '87074^Upd DropID Err',   'us_english', 840
execute rdt.rdtAddMsg 87075, 10, '87075^Upd DropID Err',   'us_english', 840
execute rdt.rdtAddMsg 87076, 10, '87076^Get PDKey Fail',   'us_english', 840
execute rdt.rdtAddMsg 87077, 10, '87077^Ins PDtl Fail',    'us_english', 840
execute rdt.rdtAddMsg 87078, 10, '87078^Upd DropID Err',   'us_english', 840
execute rdt.rdtAddMsg 87079, 10, '87079^Upd DropID Err',   'us_english', 840

SELECT * FROM rdt.RDTMsg (NOLOCK) WHERE Message_ID BETWEEN 87051 and 87100