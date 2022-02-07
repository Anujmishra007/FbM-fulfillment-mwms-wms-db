-- rdtfnc_PicktoDropID (range 67326 - 67350)
-- rdtfnc_PicktoDropID (range 102651 - 102700)
execute rdt.rdtDropMsg 67326 , 67350
execute rdt.rdtDropMsg 102651 , 102700

execute rdt.rdtAddMsg 67326, 10, '67326 MUID required', 'us_english'
execute rdt.rdtAddMsg 67327, 10, '67327 Invalid MUID', 'us_english'
execute rdt.rdtAddMsg 67328, 10, '67328 Diff storer', 'us_english'
execute rdt.rdtAddMsg 67329, 10, '67329 Diff facility', 'us_english'
execute rdt.rdtAddMsg 67330, 10, '67330 Multi LOC', 'us_english'
execute rdt.rdtAddMsg 67331, 10, '67331 MUID on Hold', 'us_english'
execute rdt.rdtAddMsg 67332, 10, '67332 UpdOrdersFail', 'us_english'
execute rdt.rdtAddMsg 67333, 10, '67333 UpdOdrDtlFail', 'us_english'
execute rdt.rdtAddMsg 67334, 10, '67334 Orders Status>3', 'us_english'
execute rdt.rdtAddMsg 67335, 10, '67335 UpdLdPlanFail', 'us_english'
execute rdt.rdtAddMsg 67336, 10, '67336 UpdLPDtlFail', 'us_english'
execute rdt.rdtAddMsg 67337, 10, '67337 LoadPlan Sts>3', 'us_english'
execute rdt.rdtAddMsg 67338, 10, '67338 STOR needed', 'us_english'
execute rdt.rdtAddMsg 67339, 10, '67339 Invalid STOR', 'us_english'
execute rdt.rdtAddMsg 67340, 10, '67340 Invalid PackQTY', 'us_english'
execute rdt.rdtAddMsg 67341, 10, '67341 Invalid QTY', 'us_english'
execute rdt.rdtAddMsg 67342, 10, '67342 Over pick', 'us_english'
execute rdt.rdtAddMsg 67343, 10, '67343 Drop ID req', 'us_english'
execute rdt.rdtAddMsg 67344, 10, '67344 Drop ID used', 'us_english'
execute rdt.rdtAddMsg 67345, 10, '67345 UpdPickDtlFail', 'us_english'
execute rdt.rdtAddMsg 67346, 10, '67346 GetPDtlKeyFail', 'us_english'
execute rdt.rdtAddMsg 67347, 10, '67347 InsPickDtlFail', 'us_english'
execute rdt.rdtAddMsg 67348, 10, '67348 Option needed', 'us_english'
execute rdt.rdtAddMsg 67349, 10, '67349 Invalid Option', 'us_english'

--SOS 156663
execute rdt.rdtAddMsg 67350, 10, '67350^Invalid DropID', 'us_english'

--SOS 372493
execute rdt.rdtAddMsg 102651, 10, '02651^Invalid Format', 'us_english'
execute rdt.rdtAddMsg 102652, 10, '02652^Invalid Format', 'us_english'
execute rdt.rdtAddMsg 102653, 10, '02653^Invalid Format', 'us_english'
execute rdt.rdtAddMsg 102654, 10, '02654^UPC/SKU Needed', 'us_english'
execute rdt.rdtAddMsg 102655, 10, '02655^Invalid SKU',    'us_english'
execute rdt.rdtAddMsg 102656, 10, '02656^SameBarcodeSKU', 'us_english'
execute rdt.rdtAddMsg 102657, 10, '02657^Nothing 2 Pick', 'us_english'
execute rdt.rdtAddMsg 102658, 10, '02658^Inv PackQTY',    'us_english'