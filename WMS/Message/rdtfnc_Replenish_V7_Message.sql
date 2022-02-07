-- rdtfnc_Replenish_V7
execute rdt.rdtDropMsg 136651 , 136700	

execute rdt.rdtAddMsg 136651, 10, '36651^LOC/ID/RPLKEY',  'us_english', 896
execute rdt.rdtAddMsg 136652, 10, '36652^Invalid LOC',    'us_english', 896
execute rdt.rdtAddMsg 136653, 10, '36653^Diff Facility',  'us_english', 896
execute rdt.rdtAddMsg 136654, 10, '36654^No Task in LOC', 'us_english', 896
execute rdt.rdtAddMsg 136655, 10, '36655^ID not in RPL',  'us_english', 896
execute rdt.rdtAddMsg 136656, 10, '36656^SKU/UPC needed', 'us_english', 896
execute rdt.rdtAddMsg 136657, 10, '36657^Invalid SKU',    'us_english', 896
execute rdt.rdtAddMsg 136658, 10, '36658^SameBarCodeSKU', 'us_english', 896
execute rdt.rdtAddMsg 136659, 10, '36659^SKU Not in RPL', 'us_english', 896
execute rdt.rdtAddMsg 136660, 10, '36660^LOC/ID/RPLKEY',  'us_english', 896
execute rdt.rdtAddMsg 136661, 10, '36661^Invalid QTY',    'us_english', 896
execute rdt.rdtAddMsg 136662, 10, '36662^Invalid QTY',    'us_english', 896
execute rdt.rdtAddMsg 136663, 10, '36663^QTY needed',     'us_english', 896
execute rdt.rdtAddMsg 136664, 10, '36664^QTYAvalNotEnuf', 'us_english', 896
execute rdt.rdtAddMsg 136665, 10, '36665^TO LOC needed',  'us_english', 896
execute rdt.rdtAddMsg 136666, 10, '36666^Invalid LOC',    'us_english', 896
execute rdt.rdtAddMsg 136667, 10, '36667^Diff facility',  'us_english', 896
execute rdt.rdtAddMsg 136668, 10, '36668^Invalid RPLKey', 'us_english', 896
execute rdt.rdtAddMsg 136669, 10, '36669^Option needed',  'us_english', 896
execute rdt.rdtAddMsg 136670, 10, '36670^Invalid option', 'us_english', 896
execute rdt.rdtAddMsg 136671, 10, '36671^RPLKey done',    'us_english', 896
execute rdt.rdtAddMsg 136672, 10, '36672^LOC needed',     'us_english', 896
execute rdt.rdtAddMsg 136673, 10, '36673^ID needed',      'us_english', 896
execute rdt.rdtAddMsg 136674, 10, '36674^Invalid LOC',    'us_english', 896
execute rdt.rdtAddMsg 136675, 10, '36675^Diff facility',  'us_english', 896
execute rdt.rdtAddMsg 136676, 10, '36676^No Task in LOC', 'us_english', 896
execute rdt.rdtAddMsg 136677, 10, '36677^TO ID REQUIRED', 'us_english', 896

SELECT * FROM RDT.RDTMSG (NOLOCK) WHERE MESSAGE_ID BETWEEN 136651 AND 136700	

