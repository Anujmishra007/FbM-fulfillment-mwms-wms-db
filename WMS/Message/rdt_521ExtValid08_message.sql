--rdt_521ExtValid08
--fcr-264
exec rdt.rdtDropMsg 216151, 216200

execute rdt.rdtAddMsg 216151, 10, '216151ToLoc Not exist', 'us_english', 521
execute rdt.rdtAddMsg 216152, 10, '216152ToLocNoPutawayZone', 'us_english', 521
execute rdt.rdtAddMsg 216153, 10, '216153ToLocMissAisle', 'us_english', 521
execute rdt.rdtAddMsg 216154, 10, '216154InvalidLocType', 'us_english', 521
execute rdt.rdtAddMsg 216155, 10, '216155InvalidPutawayZone', 'us_english', 521
execute rdt.rdtAddMsg 216156, 10, '216156ToLocIsFull', 'us_english', 521
execute rdt.rdtAddMsg 216157, 10, '216157ToLocIsBooked', 'us_english', 521
execute rdt.rdtAddMsg 216158, 10, '216158ToLocMustBeOK', 'us_english', 521

SELECT * FROM RDT.RDTMsg (NOLOCK) WHERE Message_ID BETWEEN 216151 AND 216200