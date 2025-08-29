-- rdtfnc_ScanToTruck_ByLabelNo
exec rdt.rdtDropMsg 79301, 79350

execute rdt.rdtAddMsg 79301, 10, '79301 Key either one', 'us_english', 922
execute rdt.rdtAddMsg 79302, 10, '79302 Value needed  ', 'us_english', 922
execute rdt.rdtAddMsg 79303, 10, '79303 MBOL/LOAD/ORD ', 'us_english', 922
execute rdt.rdtAddMsg 79304, 10, '79304 Bad MBOLKey   ', 'us_english', 922
execute rdt.rdtAddMsg 79305, 10, '79305 MBOL Shipped  ', 'us_english', 922
execute rdt.rdtAddMsg 79306, 10, '79306 Bad LoadKey   ', 'us_english', 922
execute rdt.rdtAddMsg 79307, 10, '79307 Load Not MBOL ', 'us_english', 922
execute rdt.rdtAddMsg 79308, 10, '79308 Bad OrderKey  ', 'us_english', 922
execute rdt.rdtAddMsg 79309, 10, '79309 OrderNotYetLP ', 'us_english', 922
execute rdt.rdtAddMsg 79310, 10, '79310 Order Not MBOL', 'us_english', 922
execute rdt.rdtAddMsg 79311, 10, '79311 Order CANCEL  ', 'us_english', 922
execute rdt.rdtAddMsg 79312, 10, '79312 Need Label No ', 'us_english', 922
execute rdt.rdtAddMsg 79313, 10, '79313 Label Scanned ', 'us_english', 922
execute rdt.rdtAddMsg 79314, 10, '79314 BAD LBNo/DrpID', 'us_english', 922
execute rdt.rdtAddMsg 79315, 10, '79315 NotPickConfirm', 'us_english', 922
execute rdt.rdtAddMsg 79316, 10, '79316 BAD LBNo/DrpID', 'us_english', 922
execute rdt.rdtAddMsg 79317, 10, '79317 NotPackConfirm', 'us_english', 922
execute rdt.rdtAddMsg 79318, 10, '79318 ID NotInMBOL  ', 'us_english', 922
execute rdt.rdtAddMsg 79319, 10, '79319 ID NotInMBOL  ', 'us_english', 922
execute rdt.rdtAddMsg 79320, 10, '79320 ID NotInMBOL  ', 'us_english', 922
execute rdt.rdtAddMsg 79321, 10, '79321 ID NotInLoad  ', 'us_english', 922
execute rdt.rdtAddMsg 79322, 10, '79322 ID NotInLoad  ', 'us_english', 922
execute rdt.rdtAddMsg 79323, 10, '79323 ID NotInLoad  ', 'us_english', 922
execute rdt.rdtAddMsg 79324, 10, '79324 ID NotInOrder ', 'us_english', 922
execute rdt.rdtAddMsg 79325, 10, '79325 ID NotInOrder ', 'us_english', 922
execute rdt.rdtAddMsg 79326, 10, '79326 ID NotInOrder ', 'us_english', 922
execute rdt.rdtAddMsg 79327, 10, '79327 INS Truck Fail', 'us_english', 922
execute rdt.rdtAddMsg 79328, 10, '79328 NotAllScanned ', 'us_english', 922
execute rdt.rdtAddMsg 79329, 10, '79329 Order CANCEL  ', 'us_english', 922
execute rdt.rdtAddMsg 79330, 10, '79330 Bad Weight    ', 'us_english', 922
execute rdt.rdtAddMsg 79331, 10, '79331 Bad Cube      ', 'us_english', 922
execute rdt.rdtAddMsg 79332, 10, '79332 Bad CartonType', 'us_english', 922
execute rdt.rdtAddMsg 79333, 10, '79333 UPDPackInfFail', 'us_english', 922
execute rdt.rdtAddMsg 79334, 10, '79334 INSPackInfFail', 'us_english', 922
execute rdt.rdtAddMsg 79335, 10, '79335 Invalid format', 'us_english', 922
execute rdt.rdtAddMsg 79336, 10, '79336 Invalid format', 'us_english', 922

--WMS-15718
execute rdt.rdtAddMsg 79337, 10, '79337 Invalid RefNo',  'us_english', 922
execute rdt.rdtAddMsg 79338, 10, '79338 RefNoNotInMBOL', 'us_english', 922
execute rdt.rdtAddMsg 79339, 10, '79339 RefNoMultiMBOL', 'us_english', 922

--WMS-15680 (cc01)
execute rdt.rdtAddMsg 79340, 10, '79340 GenOTMLogFail ', 'us_english', 922

--FCR-2901
execute rdt.rdtAddMsg 79341, 10, '79341NeedOption   ', 'us_english', 922
execute rdt.rdtAddMsg 79342, 10, '79342InvOption    ', 'us_english', 922
execute rdt.rdtAddMsg 79343, 10, '79343CloseMbolErr ', 'us_english', 922
