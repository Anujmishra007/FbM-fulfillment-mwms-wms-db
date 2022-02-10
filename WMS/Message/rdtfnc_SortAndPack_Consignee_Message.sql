-- rdtfnc_SortAndPack_Consignee
exec rdt.rdtDropMsg 160451, 160500

execute rdt.rdtAddMsg 160451, 10, '160451Key Either One', 'us_english', 1851
execute rdt.rdtAddMsg 160452, 10, '160452Key Either One', 'us_english', 1851
execute rdt.rdtAddMsg 160453, 10, '60453InvalidBatchKey', 'us_english', 1851
execute rdt.rdtAddMsg 160454, 10, '160454 Diff Facility', 'us_english', 1851
execute rdt.rdtAddMsg 160455, 10, '160455 Diff Storer  ', 'us_english', 1851
execute rdt.rdtAddMsg 160456, 10, '160456InvalidWaveKey', 'us_english', 1851
execute rdt.rdtAddMsg 160457, 10, '160457 Diff Facility', 'us_english', 1851
execute rdt.rdtAddMsg 160458, 10, '160458 Diff Storer  ', 'us_english', 1851
execute rdt.rdtAddMsg 160459, 10, '160459 Need SKU/UCC ', 'us_english', 1851
execute rdt.rdtAddMsg 160460, 10, '160460Either SKU/UCC', 'us_english', 1851
execute rdt.rdtAddMsg 160461, 10, '160461 Invalid SKU  ', 'us_english', 1851
execute rdt.rdtAddMsg 160462, 10, '160462SameBarCodeSKU', 'us_english', 1851
execute rdt.rdtAddMsg 160463, 10, '160463InsertLog Fail', 'us_english', 1851
execute rdt.rdtAddMsg 160464, 10, '160464 Over Packed  ', 'us_english', 1851
execute rdt.rdtAddMsg 160465, 10, '160465UpdateLog Fail', 'us_english', 1851
execute rdt.rdtAddMsg 160466, 10, '160466InsertLog Fail', 'us_english', 1851
execute rdt.rdtAddMsg 160467, 10, '160467 Over Packed  ', 'us_english', 1851
execute rdt.rdtAddMsg 160468, 10, '160468UpdateLog Fail', 'us_english', 1851
execute rdt.rdtAddMsg 160469, 10, '160469 GenLabel Fail', 'us_english', 1851
execute rdt.rdtAddMsg 160470, 10, '160470InsertLog Fail', 'us_english', 1851
execute rdt.rdtAddMsg 160471, 10, '160471 Over Packed  ', 'us_english', 1851
execute rdt.rdtAddMsg 160472, 10, '160472UpdateLog Fail', 'us_english', 1851
execute rdt.rdtAddMsg 160473, 10, '160473InsertLog Fail', 'us_english', 1851
execute rdt.rdtAddMsg 160474, 10, '160474 Over Packed  ', 'us_english', 1851
execute rdt.rdtAddMsg 160475, 10, '160475UpdateLog Fail', 'us_english', 1851
execute rdt.rdtAddMsg 160476, 10, '160476 GenLabel Fail', 'us_english', 1851
execute rdt.rdtAddMsg 160477, 10, '160477UpdateLog Fail', 'us_english', 1851
execute rdt.rdtAddMsg 160478, 10, '160478 Carton Closed', 'us_english', 1851
execute rdt.rdtAddMsg 160479, 10, '160479UpdateLog Fail', 'us_english', 1851
execute rdt.rdtAddMsg 160480, 10, '160480UpdateLog Fail', 'us_english', 1851
execute rdt.rdtAddMsg 160481, 10, '160481OptionRequired', 'us_english', 1851
execute rdt.rdtAddMsg 160482, 10, '160482Invalid Option', 'us_english', 1851
execute rdt.rdtAddMsg 160483, 10, '160483InvalidLabelNo', 'us_english', 1851

execute rdt.rdtAddMsg 160484, 10, '160484 Carton Closed', 'us_english', 1851
execute rdt.rdtAddMsg 160485, 10, '160485UpdateLog Fail', 'us_english', 1851
execute rdt.rdtAddMsg 160486, 10, '160486 Over Packed  ', 'us_english', 1851
execute rdt.rdtAddMsg 160487, 10, '160487 Invalid UCC  ', 'us_english', 1851

execute rdt.rdtAddMsg 160488, 10, '160488 Invalid UCC  ', 'us_english', 1851
execute rdt.rdtAddMsg 160489, 10, '160489 UCC > 1 SKU  ', 'us_english', 1851
execute rdt.rdtAddMsg 160490, 10, '160490 Ucc Scanned  ', 'us_english', 1851



SELECT TOP 100 * FROM rdt.rdtMsg (NOLOCK) WHERE message_id BETWEEN 160451 and 160500


