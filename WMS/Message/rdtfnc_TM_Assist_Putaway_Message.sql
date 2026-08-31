-- rdtfnc_TM_Assist_Putaway
rdt.rdtDropMsg 51951 , 52000

execute rdt.rdtAddMsg 51951, 10, '51951^LOC needed    ',    'us_english', 1815
execute rdt.rdtAddMsg 51952, 10, '51952^Invalid LOC   ',    'us_english', 1815
execute rdt.rdtAddMsg 51953, 10, '51953^LOC Not Match ',    'us_english', 1815
execute rdt.rdtAddMsg 51954, 10, '51954^Option req    ',    'us_english', 1815
execute rdt.rdtAddMsg 51955, 10, '51955^Invalid Option',    'us_english', 1815
execute rdt.rdtAddMsg 51956, 10, '51956^NextTaskFncErr',    'us_english', 1815
execute rdt.rdtAddMsg 51957, 10, '51957^NextTaskScnErr',    'us_english', 1815

--WMS-17016
execute rdt.rdtAddMsg 51958, 10, '51958^SKU needed    ',    'us_english', 1815
execute rdt.rdtAddMsg 51959, 10, '51959^Invalid SKU   ',    'us_english', 1815
execute rdt.rdtAddMsg 51960, 10, '51960^SameBarCodeSKU',    'us_english', 1815
execute rdt.rdtAddMsg 51961, 10, '51961^SKU Not Match ',    'us_english', 1815
execute rdt.rdtAddMsg 51962, 10, '51962^No QTY to move',    'us_english', 1815
execute rdt.rdtAddMsg 51963, 10, '51963^Invalid QTY   ',    'us_english', 1815
execute rdt.rdtAddMsg 51964, 10, '51964^Invalid QTY   ',    'us_english', 1815
execute rdt.rdtAddMsg 51965, 10, '51965^QTY needed    ',    'us_english', 1815
execute rdt.rdtAddMsg 51966, 10, '51966^QTYAVL NotEnuf',    'us_english', 1815
execute rdt.rdtAddMsg 51967, 10, '51967^ToID needed   ',    'us_english', 1815
execute rdt.rdtAddMsg 51968, 10, '51968^ToID Not Match',    'us_english', 1815
execute rdt.rdtAddMsg 51969, 10, '51969^LOC needed    ',    'us_english', 1815
execute rdt.rdtAddMsg 51970, 10, '51970^Invalid LOC   ',    'us_english', 1815
execute rdt.rdtAddMsg 51971, 10, '51971^LOC Not Match ',    'us_english', 1815
execute rdt.rdtAddMsg 51972, 10, '51972^UPD Task Fail ',    'us_english', 1815
execute rdt.rdtAddMsg 51973, 10, '51973^Option req    ',    'us_english', 1815
execute rdt.rdtAddMsg 51974, 10, '51974^Invalid Option',    'us_english', 1815
execute rdt.rdtAddMsg 51975, 10, '51975^UPD Task Fail ',    'us_english', 1815

SELECT * FROM RDT.RDTMSG (NOLOCK) WHERE MESSAGE_ID BETWEEN 51951 AND 52000