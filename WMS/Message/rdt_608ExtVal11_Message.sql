-- rdt_608ExtUpd11
execute rdt.rdtDropMsg 174351, 174400

execute rdt.rdtAddMsg 174351, 10, '174351LocNotInCodeLK', 'us_english', 608
execute rdt.rdtAddMsg 174352, 10, '174352^Invalid LOC  ', 'us_english', 608
execute rdt.rdtAddMsg 174353, 10, '174353^Invalid LOC  ', 'us_english', 608
execute rdt.rdtAddMsg 174354, 10, '174354^NorRec-E Loc ', 'us_english', 608
execute rdt.rdtAddMsg 174355, 10, '174355^OverRec-ToLoc', 'us_english', 608
execute rdt.rdtAddMsg 174356, 10, '74356ISEGMismatchLoc', 'us_english', 608
execute rdt.rdtAddMsg 174357, 10, '74357ExpSku->NorLoc ', 'us_english', 608


select top 10 * from rdt.rdtMsg (nolock) where message_id between 174351 and 174400

