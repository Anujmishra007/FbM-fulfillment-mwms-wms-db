--rdt_512ExtValid03
execute rdt.rdtdropmsg 175551 , 175600

execute rdt.rdtAddMsg 175551, 10, '175551 Diff HOLD Loc',         'us_english', 512
execute rdt.rdtAddMsg 175552, 10, '175552 Diff HOLD Loc',         'us_english', 512

SELECT * FROM rdt.RDTMsg (NOLOCK) WHERE Message_ID BETWEEN 175551 AND 175600
