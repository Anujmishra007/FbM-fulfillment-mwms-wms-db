-- rdt_839ExtValidSP10
exec rdt.rdtdropmsg 180201, 180250

execute rdt.rdtAddMsg 180201, 10, '180201Cannot ShtPick', 'us_english', 839
execute rdt.rdtAddMsg 180202, 10, '180202Cannot SkipLoc', 'us_english', 839

SELECT * FROM RDT.RDTMsg (NOLOCK) WHERE Message_ID BETWEEN 180201 AND 180250
