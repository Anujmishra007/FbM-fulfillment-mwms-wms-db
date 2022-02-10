--rdt_511ExtValid06
execute rdt.rdtdropmsg 172701 , 172750

execute rdt.rdtAddMsg 172701, 10, '172701DiffLottableID',         'us_english', 511
execute rdt.rdtAddMsg 172702, 10, '172702DiffLottableID',         'us_english', 511
execute rdt.rdtAddMsg 172703, 10, '172703 Diff HOLD Loc',         'us_english', 511
execute rdt.rdtAddMsg 172704, 10, '172704 Diff HOLD Loc',         'us_english', 511

SELECT * FROM rdt.RDTMsg (NOLOCK) WHERE Message_ID BETWEEN 172701 AND 172750
