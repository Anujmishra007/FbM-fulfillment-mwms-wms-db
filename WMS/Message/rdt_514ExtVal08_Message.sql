--rdt_514ExtVal08
execute rdt.rdtdropmsg 172751 , 172800

execute rdt.rdtAddMsg 172751, 10, '172751DifLottableUCC',         'us_english', 514
execute rdt.rdtAddMsg 172752, 10, '172752DifLottableUCC',         'us_english', 514
execute rdt.rdtAddMsg 172753, 10, '172753 Diff HOLD Loc',         'us_english', 514
execute rdt.rdtAddMsg 172754, 10, '172754 Diff HOLD Loc',         'us_english', 514

SELECT * FROM rdt.RDTMsg (NOLOCK) WHERE Message_ID BETWEEN 172751 AND 172800
