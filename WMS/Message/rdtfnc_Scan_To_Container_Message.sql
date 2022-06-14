--rdtfnc_Scan_To_Container
execute rdt.rdtdropmsg 95851, 95900

execute rdt.rdtAddMsg 95851, 10, '95851^CONTKEY req   ', 'us_english', 1637
execute rdt.rdtAddMsg 95852, 10, '95852^GETKEY FAILED ', 'us_english', 1637
execute rdt.rdtAddMsg 95853, 10, '95853^INS CONT FAIL ', 'us_english', 1637
execute rdt.rdtAddMsg 95854, 10, '95854^InvalidCONTKEY', 'us_english', 1637
execute rdt.rdtAddMsg 95855, 10, '95855^CONTKEY Done  ', 'us_english', 1637
execute rdt.rdtAddMsg 95856, 10, '95856^No MBOLKEY    ', 'us_english', 1637
execute rdt.rdtAddMsg 95857, 10, '95857^SSCC# req     ', 'us_english', 1637
execute rdt.rdtAddMsg 95858, 10, '95858^SSCC# Exists  ', 'us_english', 1637
execute rdt.rdtAddMsg 95859, 10, '95859^SSCC# Exists  ', 'us_english', 1637
execute rdt.rdtAddMsg 95860, 10, '95860^Invalid SSCC# ', 'us_english', 1637
execute rdt.rdtAddMsg 95861, 10, '95861^SSCC# Scanned ', 'us_english', 1637
execute rdt.rdtAddMsg 95862, 10, '95862^Over Scan     ', 'us_english', 1637
execute rdt.rdtAddMsg 95863, 10, '95863^DEL COND FAIL ', 'us_english', 1637
execute rdt.rdtAddMsg 95864, 10, '95864^INV SECTIONKEY', 'us_english', 1637
execute rdt.rdtAddMsg 95865, 10, '95865^GETKEY FAILED ', 'us_english', 1637
execute rdt.rdtAddMsg 95866, 10, '95866^GETKEY FAILED ', 'us_english', 1637
execute rdt.rdtAddMsg 95867, 10, '95867^GETKEY FAILED ', 'us_english', 1637
execute rdt.rdtAddMsg 95868, 10, '95868^UPD LBL FAIL  ', 'us_english', 1637
execute rdt.rdtAddMsg 95869, 10, '95869^PalletID req  ', 'us_english', 1637
execute rdt.rdtAddMsg 95870, 10, '95870^PL not in Cont', 'us_english', 1637
execute rdt.rdtAddMsg 95871, 10, '95871^InsConDtl Fail', 'us_english', 1637
execute rdt.rdtAddMsg 95872, 10, '95872^PalletID Exist', 'us_english', 1637
execute rdt.rdtAddMsg 95873, 10, '95873^Pallet scanned', 'us_english', 1637
execute rdt.rdtAddMsg 95874, 10, '95874^InsConDtl Fail', 'us_english', 1637
execute rdt.rdtAddMsg 95875, 10, '95875^Track No req  ', 'us_english', 1637
execute rdt.rdtAddMsg 95876, 10, '95876^Inv TrackNo   ', 'us_english', 1637
execute rdt.rdtAddMsg 95877, 10, '95877^Upd Ord Failed', 'us_english', 1637
execute rdt.rdtAddMsg 95878, 10, '95878^Option Req    ', 'us_english', 1637
execute rdt.rdtAddMsg 95879, 10, '95879^Inv Option    ', 'us_english', 1637
execute rdt.rdtAddMsg 95880, 10, '95880^NoLabelPrinter', 'us_english', 1637
execute rdt.rdtAddMsg 95881, 10, '95881^DWNOTSETUP    ', 'us_english', 1637
execute rdt.rdtAddMsg 95882, 10, '95882^TGETDB NOT SET', 'us_english', 1637
execute rdt.rdtAddMsg 95883, 10, '95883^INSERTPRTFAIL ', 'us_english', 1637
execute rdt.rdtAddMsg 95884, 10, '95884^INV CONTAINER#', 'us_english', 1637
execute rdt.rdtAddMsg 95885, 10, '95885^OPTION REQUIRE', 'us_english', 1637
execute rdt.rdtAddMsg 95886, 10, '95886^INVALID OPTION', 'us_english', 1637
execute rdt.rdtAddMsg 95887, 10, '95887^CLOSE ERROR   ', 'us_english', 1637
execute rdt.rdtAddMsg 95888, 10, '95888^Invalid format', 'us_english', 1637
execute rdt.rdtAddMsg 95889, 10, '95889^Invalid format', 'us_english', 1637
execute rdt.rdtAddMsg 95890, 10, '95890^OPTION REQUIRE', 'us_english', 1637
execute rdt.rdtAddMsg 95891, 10, '95891^INVALID OPTION', 'us_english', 1637

-- WMS5460
execute rdt.rdtAddMsg 95892, 10, '95892^Invalid Column', 'us_english', 1637
execute rdt.rdtAddMsg 95893, 10, '95893^InvalidCONTKEY', 'us_english', 1637
execute rdt.rdtAddMsg 95894, 10, '95894^No MBOLKey',     'us_english', 1637

-- WMS2990
execute rdt.rdtAddMsg 95895, 10, '95895^Param NotSetup', 'us_english', 1637
execute rdt.rdtAddMsg 95896, 10, '95896^Param NotSetup', 'us_english', 1637
execute rdt.rdtAddMsg 95897, 10, '95897^Param NotSetup', 'us_english', 1637

-- WMS4673
execute rdt.rdtAddMsg 95898, 10, '95898^Pallet Scanned', 'us_english', 1637

-- WMS11663
execute rdt.rdtAddMsg 95899, 10, '95899^UpdContFail',   'us_english', 1637

--WMS12381
execute rdt.rdtAddMsg 95900, 10, '95900^Inv Format',   'us_english', 1637
execute rdt.rdtAddMsg 149201, 10, '49201^Inv Format',   'us_english', 1637
execute rdt.rdtAddMsg 149202, 10, '49202^Inv Format',   'us_english', 1637
execute rdt.rdtAddMsg 149203, 10, '49203^Inv Format',   'us_english', 1637
execute rdt.rdtAddMsg 149204, 10, '49204^Inv Format',   'us_english', 1637



