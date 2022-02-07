--rdt_862PickCfm04
exec rdt.rdtDropMsg 117501 , 117550

execute rdt.rdtAddMsg 117501, 10, '17501^Invalid ID',       'us_english', 862
execute rdt.rdtAddMsg 117502, 10, '17502^IDMultiLOT/LOC',   'us_english', 862
execute rdt.rdtAddMsg 117503, 10, '17503^Diff LOCType',     'us_english', 862
execute rdt.rdtAddMsg 117504, 10, '17504^SKU not match',    'us_english', 862
execute rdt.rdtAddMsg 117505, 10, '17505^L05 not match',    'us_english', 862
execute rdt.rdtAddMsg 117506, 10, '17506^PKDtl changed',    'us_english', 862
execute rdt.rdtAddMsg 117507, 10, '17507^GetDetKey Fail',   'us_english', 862
execute rdt.rdtAddMsg 117508, 10, '17508^INS PDtl Fail',    'us_english', 862
execute rdt.rdtAddMsg 117509, 10, '17509^InsRefKLupFail',   'us_english', 862
execute rdt.rdtAddMsg 117510, 10, '17510^UPD PDtl Fail',    'us_english', 862
execute rdt.rdtAddMsg 117511, 10, '17511^GetDetKey Fail',   'us_english', 862
execute rdt.rdtAddMsg 117512, 10, '17512^INS PDtl Fail',    'us_english', 862
execute rdt.rdtAddMsg 117513, 10, '17513^InsRefKLupFail',   'us_english', 862
execute rdt.rdtAddMsg 117514, 10, '17514^UPD PDtl Fail',    'us_english', 862
execute rdt.rdtAddMsg 117515, 10, '17515^Invalid ID',       'us_english', 862
execute rdt.rdtAddMsg 117516, 10, '17516^IDMultiLOT/LOC',   'us_english', 862
execute rdt.rdtAddMsg 117517, 10, '17517^LOC X Match',      'us_english', 862
execute rdt.rdtAddMsg 117518, 10, '17518^SKU not match',    'us_english', 862
execute rdt.rdtAddMsg 117519, 10, '17519^Pallet Picked',    'us_english', 862
execute rdt.rdtAddMsg 117520, 10, '17520^PKDtl changed',    'us_english', 862
execute rdt.rdtAddMsg 117521, 10, '17521^Qty Not Match',    'us_english', 862
execute rdt.rdtAddMsg 117522, 10, '17522^IDNotFullAlloc',   'us_english', 862
execute rdt.rdtAddMsg 117523, 10, '17523^PKDtl changed',    'us_english', 862
execute rdt.rdtAddMsg 117524, 10, '17524^Multi PKDtl',      'us_english', 862

SELECT * FROM RDT.RDTMSG (NOLOCK) WHERE MESSAGE_ID BETWEEN 117501 AND 117550
