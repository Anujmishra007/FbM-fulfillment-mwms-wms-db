--rdt_1765SuggLocSP01
exec rdt.rdtDropMsg 168251, 168300

execute rdt.rdtAddMsg 168251, 10, '168251 InvSuggAGVLoc', 'us_english', 1765
execute rdt.rdtAddMsg 168252, 10, '168252 No SuggAGVLoc', 'us_english', 1765

SELECT * FROM RDT.RDTMsg (NOLOCK) WHERE Message_ID BETWEEN 168251 AND 168300



