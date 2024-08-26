--Message file
--execute rdt.rdtdropmsg

execute rdt.rdtAddMsg 217973, 10, 'LPN is in multi locs',     'us_english', 511
execute rdt.rdtAddMsg 217974, 10, '974LPN got active PA',     'us_english', 511
execute rdt.rdtAddMsg 217975, 10, '975LPN is for replen',     'us_english', 511
execute rdt.rdtAddMsg 217976, 10, 'Loc not in HUSQ zone',     'us_english', 511
execute rdt.rdtAddMsg 217977, 10, 'Over max pallet lim',     'us_english', 511
execute rdt.rdtAddMsg 217978, 10, 'Loc on hold or flag',     'us_english', 511
execute rdt.rdtAddMsg 217979, 10, '7979^Move to out loc',     'us_english', 511
execute rdt.rdtAddMsg 217980, 10, 'Sku not set for loc',     'us_english', 511

SELECT * FROM RDT.RDTMSG WITH(NOLOCK) WHERE Message_ID BETWEEN 217973 AND 217980
