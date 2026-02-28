--rdt_1637ExtVal03
execute rdt.rdtDropMsg 215651 , 215700

execute rdt.rdtAddMsg 215651, 10, '215651 PltNotClosed ',   'us_english', 1637
execute rdt.rdtAddMsg 215652, 10, '215652 DifferentCarrier ',   'us_english', 1637
execute rdt.rdtAddMsg 215653, 10, '215653 PalletNoCarrierLabel ',   'us_english', 1637
execute rdt.rdtAddMsg 215654, 10, '215654 NotAllPalletsScanned',   'us_english', 1637

SELECT * FROM RDT.RDTMsg (NOLOCK) WHERE Message_ID BETWEEN 215651 AND 215700