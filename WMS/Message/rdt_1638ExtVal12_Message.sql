--rdt_1638ExtVal12
execute rdt.rdtDropMsg 161601, 161650

execute rdt.rdtAddMsg 161601, 10, '161601^Diff Load',     'us_english', 1638

SELECT * FROM RDT.RDTMsg WITH (NOLOCK) WHERE Message_ID BETWEEN 161601 AND 161650