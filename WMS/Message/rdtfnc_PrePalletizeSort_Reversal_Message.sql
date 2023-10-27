-- rdtfnc_PrePalletizeSort_Reversal
exec rdt.rdtDropMsg 207351 , 207400

execute rdt.rdtAddMsg 207351, 10, '207351 ASN Required ',   'us_english', 1865
execute rdt.rdtAddMsg 207352, 10, '207352ASN Not Exists',   'us_english', 1865
execute rdt.rdtAddMsg 207353, 10, '207353 Diff Facility',   'us_english', 1865
execute rdt.rdtAddMsg 207354, 10, '207354 Diff Storer  ',   'us_english', 1865
execute rdt.rdtAddMsg 207355, 10, '207355 ASN Closed   ',   'us_english', 1865
execute rdt.rdtAddMsg 207356, 10, '207356 TOID Required',   'us_english', 1865
execute rdt.rdtAddMsg 207357, 10, '207357Invalid Format',   'us_english', 1865
execute rdt.rdtAddMsg 207358, 10, '207358 Invalid ToID ',   'us_english', 1865
execute rdt.rdtAddMsg 207359, 10, '207359 LANE Required',   'us_english', 1865
execute rdt.rdtAddMsg 207360, 10, '207360 Invalid Lane ',   'us_english', 1865
execute rdt.rdtAddMsg 207361, 10, '207361 Invalid Lane ',   'us_english', 1865
execute rdt.rdtAddMsg 207362, 10, '207362 Diff Facility',   'us_english', 1865
execute rdt.rdtAddMsg 207363, 10, '207363 No Record    ',   'us_english', 1865
execute rdt.rdtAddMsg 207364, 10, '207364 UCC Required ',   'us_english', 1865
execute rdt.rdtAddMsg 207365, 10, '207365Invalid Format',   'us_english', 1865
execute rdt.rdtAddMsg 207366, 10, '207366UCC Not Exists',   'us_english', 1865


SELECT * FROM RDT.RDTMSG (NOLOCK) WHERE Message_ID BETWEEN 207351 AND 207400
