
-- rdtfnc_Pick_SKULottable_Message 71466 - 71515
-- **********************************************

-- Setup RDT Message
INSERT INTO RDT.RDTMsg (Message_ID, Lang_Code, Message_Type, Message_Text, StoredProcName, Eventtype)
VALUES ('866', 'ENG', 'FNC', 'Pick SKU Lottable', 'rdtfnc_Pick_SKULottable', '3')

execute rdt.rdtAddMsg 68500, 10, '68500^Bad SKU', 'us_english' -- FOR RDT.GET_SKU

execute rdt.rdtAddMsg 71466, 10, '71466^PSNO req', 'us_english'
execute rdt.rdtAddMsg 71467, 10, '71467^Invalid PSNO', 'us_english'
execute rdt.rdtAddMsg 71468, 10, '71468^PSTypeNotSupport', 'us_english'
execute rdt.rdtAddMsg 71469, 10, '71469^Diff storer', 'us_english'
execute rdt.rdtAddMsg 71470, 10, '71470^PS not scan in', 'us_english'
execute rdt.rdtAddMsg 71471, 10, '71471^PS scanned out', 'us_english'

execute rdt.rdtAddMsg 71472, 10, '71472^LOC req', 'us_english'
execute rdt.rdtAddMsg 71473, 10, '71473^Invalid LOC', 'us_english'
execute rdt.rdtAddMsg 71474, 10, '71474^Diff facility', 'us_english'
execute rdt.rdtAddMsg 71475, 10, '71475^SKU Req', 'us_english'
execute rdt.rdtAddMsg 71476, 10, '71476^Invalid SKU', 'us_english'
execute rdt.rdtAddMsg 71477, 10, '71477^Invalid Loc', 'us_english'

execute rdt.rdtAddMsg 71478, 10, '71478^Lottable01 req', 'us_english'
execute rdt.rdtAddMsg 71479, 10, '71479^Lottable02 req', 'us_english'
execute rdt.rdtAddMsg 71480, 10, '71480^Lottable03 req', 'us_english'
execute rdt.rdtAddMsg 71481, 10, '71481^Lottable04 req', 'us_english'

execute rdt.rdtAddMsg 71482, 10, '71482^Invalid date', 'us_english'
execute rdt.rdtAddMsg 71483, 10, '71483^Lottable05 req', 'us_english'
execute rdt.rdtAddMsg 71484, 10, '71484^Invalid date', 'us_english'

execute rdt.rdtAddMsg 71485, 10, '71485^Invalid QTY', 'us_english'
execute rdt.rdtAddMsg 71486, 10, '71486^Invalid QTY', 'us_english'
execute rdt.rdtAddMsg 71487, 10, '71487^QTY > Suggest', 'us_english'
execute rdt.rdtAddMsg 71488, 10, '71488^SKU Picked', 'us_english'

execute rdt.rdtAddMsg 71489, 10, '71489^Inv Lottable01', 'us_english'
execute rdt.rdtAddMsg 71490, 10, '71490^Inv Lottable02', 'us_english'
execute rdt.rdtAddMsg 71491, 10, '71491^Inv Lottable03', 'us_english'
execute rdt.rdtAddMsg 71492, 10, '71492^Inv Lottable04', 'us_english'

execute rdt.rdtAddMsg 71493, 10, '71493^Bad Location', 'us_english'


















