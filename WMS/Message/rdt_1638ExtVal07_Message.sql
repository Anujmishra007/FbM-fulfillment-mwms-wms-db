--rdt_1638ExtVal07
execute rdt.rdtDropMsg 149901, 149950

execute rdt.rdtAddMsg 149901, 10, '49901^Diff Load',     'us_english', 1638

SELECT * FROM RDT.RDTMsg WITH (NOLOCK) WHERE Message_ID BETWEEN 149901 AND 149950