--rdt_805MatrixSP11
execute rdt.rdtDropMsg 277701, 277750

execute rdt.rdtAddMsg 277701, 10, '277701NoPack CaseCnt', 'us_english', 805
execute rdt.rdtAddMsg 277702, 10, '277702Not Case Qty  ', 'us_english', 805
execute rdt.rdtAddMsg 277703, 10, '277703InsPosFail',     'us_english', 805

SELECT * FROM RDT.RDTMsg WITH (NOLOCK) WHERE Message_ID BETWEEN 277701 AND 277750
