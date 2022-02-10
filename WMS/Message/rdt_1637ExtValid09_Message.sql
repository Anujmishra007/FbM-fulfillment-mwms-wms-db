

SELECT * FROM rdt.rdtmsg (NOLOCK) WHERE Message_ID BETWEEN '180651' AND '180700'

--rdt_1637ExtValid09
EXEC rdt.rdtDropMsg 180651, 180700

execute rdt.rdtAddMsg 180651, 10, '180651 Rec Not Exist',   'us_english', 1637
execute rdt.rdtAddMsg 180652, 10, '180652 MBOL NotExist',   'us_english', 1637
execute rdt.rdtAddMsg 180653, 10, '180653 Ctn# NotExist',   'us_english', 1637
execute rdt.rdtAddMsg 180654, 10, '180654 Invalid Plt #',   'us_english', 1637
execute rdt.rdtAddMsg 180655, 10, '180655PalletID Exist',   'us_english', 1637
execute rdt.rdtAddMsg 180656, 10, '180656PltDtlNotExist',   'us_english', 1637
execute rdt.rdtAddMsg 180657, 10, '180657 Plt >1 Mbol  ',   'us_english', 1637
execute rdt.rdtAddMsg 180658, 10, '180658 Diff MbolKey ',   'us_english', 1637
execute rdt.rdtAddMsg 180659, 10, '180659 Exceed PltCnt',   'us_english', 1637
execute rdt.rdtAddMsg 180660, 10, '180660PltCnt X Match',   'us_english', 1637
