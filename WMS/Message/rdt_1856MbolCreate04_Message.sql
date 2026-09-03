-- rdt_1856MbolCreate04
-- FCR-15446

execute rdt.rdtdropmsg 279651, 279700

execute rdt.rdtAddMsg 279651, 10, '279651Invalid Pallet',   'us_english', 1856, 0, '279651 DropID not found in PICKDETAIL or no eligible orders (Status=5)'
execute rdt.rdtAddMsg 279652, 10, '279652Key Gen Fail',     'us_english', 1856, 0, '279652 nspg_getkey failed to generate MBOL key (ECOM)'
execute rdt.rdtAddMsg 279653, 10, '279653Ins MBOL Err',     'us_english', 1856, 0, '279653 INSERT into dbo.MBOL failed (ECOM)'
execute rdt.rdtAddMsg 279654, 10, '279654Ins Dtl Err',      'us_english', 1856, 0, '279654 INSERT into dbo.MBOLDETAIL failed (ECOM)'
execute rdt.rdtAddMsg 279655, 10, '279655No Load Found',    'us_english', 1856, 0, '279655 No LoadKey found in LOADPLANDETAIL for scanned RTL/WHSLE pallet'
execute rdt.rdtAddMsg 279656, 10, '279656Key Gen Fail',     'us_english', 1856, 0, '279656 nspg_getkey failed to generate MBOL key (RTL/WHSLE)'
execute rdt.rdtAddMsg 279657, 10, '279657Ins MBOL Err',     'us_english', 1856, 0, '279657 INSERT into dbo.MBOL failed (RTL/WHSLE)'
execute rdt.rdtAddMsg 279658, 10, '279658Ins Dtl Err',      'us_english', 1856, 0, '279658 INSERT into dbo.MBOLDETAIL failed (RTL/WHSLE)'
execute rdt.rdtAddMsg 279659, 10, '279659Diff Wave Type',   'us_english', 1856, 0, 'ERR: 279659 Different wave type. MBOL is {1}'
execute rdt.rdtAddMsg 279660, 10, '279660Wrong Carrier',    'us_english', 1856, 0, 'ERR: 279660 Wrong Carrier. MBOL is for {1}'
execute rdt.rdtAddMsg 279661, 10, '279661Different Wave',   'us_english', 1856, 0, 'ERR: 279661 Different Wave. MBOL is for {1}'
execute rdt.rdtAddMsg 279662, 10, '279662Wrong Carrier',    'us_english', 1856, 0, 'ERR: 279662 Wrong Carrier. MBOL is for {1}'
execute rdt.rdtAddMsg 279663, 10, '279663In Other MBOL',    'us_english', 1856, 0, 'ERR: 279663 Pallet belongs to another MBOL. MBOL is {1}'
execute rdt.rdtAddMsg 279664, 10, '279664Ins Dtl Err',      'us_english', 1856, 0, '279664 INSERT into dbo.MBOLDETAIL failed (C4a ECOM)'
execute rdt.rdtAddMsg 279665, 10, '279665Ins Dtl Err',      'us_english', 1856, 0, '279665 INSERT into dbo.MBOLDETAIL failed (C4b RTL/WHSLE)'
execute rdt.rdtAddMsg 279666, 10, '279666Multi DropID',     'us_english', 1856, 0, '279666 ECOM order exists in multiple DropIDs'

SELECT * FROM rdt.RDTMsg WITH(NOLOCK) WHERE Message_ID BETWEEN 279651 AND 279700
