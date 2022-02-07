-- rdtfnc_PrintPackingListAndGS1_GS1
exec rdt.rdtDropMsg 74951, 75000
 
execute rdt.rdtAddMsg 74951, 10, '74951^ID needed     ', 'us_english', 1790
execute rdt.rdtAddMsg 74952, 10, '74952^Invalid ID    ', 'us_english', 1790
execute rdt.rdtAddMsg 74953, 10, '74953^Invalid option', 'us_english', 1790
execute rdt.rdtAddMsg 74954, 10, '74954^Invalid option', 'us_english', 1790
execute rdt.rdtAddMsg 74955, 10, '74955^PrintOptionReq', 'us_english', 1790
execute rdt.rdtAddMsg 74956, 10, '74956^LabelPrnterReq', 'us_english', 1790
execute rdt.rdtAddMsg 74957, 10, '74957^LabelPrinted  ', 'us_english', 1790
execute rdt.rdtAddMsg 74958, 10, '74958^InsDropIDFail ', 'us_english', 1790
execute rdt.rdtAddMsg 74959, 10, '74959^PaperPrnterReq', 'us_english', 1790
execute rdt.rdtAddMsg 74960, 10, '74960^PackLstPrinted', 'us_english', 1790
execute rdt.rdtAddMsg 74961, 10, '74961^DWNOTSetup    ', 'us_english', 1790
execute rdt.rdtAddMsg 74962, 10, '74962^TgetDB Not Set', 'us_english', 1790
execute rdt.rdtAddMsg 74963, 10, '74963^UpdPackHdrFail', 'us_english', 1790
execute rdt.rdtAddMsg 74964, 10, '74964^Option needed ', 'us_english', 1790
execute rdt.rdtAddMsg 74965, 10, '74965^Invalid option', 'us_english', 1790
execute rdt.rdtAddMsg 74966, 10, '74966^DWNOTSetup    ', 'us_english', 1790
execute rdt.rdtAddMsg 74967, 10, '74967^TgetDB Not Set', 'us_english', 1790
execute rdt.rdtAddMsg 74968, 10, '74968^Option needed ', 'us_english', 1790
execute rdt.rdtAddMsg 74969, 10, '74969^Invalid option', 'us_english', 1790
execute rdt.rdtAddMsg 74970, 10, 'Pack list printed   ', 'us_english', 1790
execute rdt.rdtAddMsg 74971, 10, 'Apply to cartons    ', 'us_english', 1790
execute rdt.rdtAddMsg 74972, 10, '74972^PrintEitherOne', 'us_english', 1790
execute rdt.rdtAddMsg 74973, 10, '74973^Print GS1 Fail', 'us_english', 1790
execute rdt.rdtAddMsg 74974, 10, '74974^Print GS1 Fail', 'us_english', 1790
execute rdt.rdtAddMsg 74975, 10, '74975^NeedDropIDRec ', 'us_english', 1790
execute rdt.rdtAddMsg 74976, 10, '74976^Invalid weight', 'us_english', 1790
execute rdt.rdtAddMsg 74977, 10, '74977^InsPKInfoFail ', 'us_english', 1790
execute rdt.rdtAddMsg 74978, 10, '74978^NotMeetPrnReq ', 'us_english', 1790
execute rdt.rdtAddMsg 74979, 10, '74979^ID Shipped    ', 'us_english', 1790

-- (ChewKP01)
execute rdt.rdtAddMsg 74980, 10, '74980^UpdDDEtFail', 'us_english', 1790
execute rdt.rdtAddMsg 74981, 10, '74981^UpdDDEtFail', 'us_english', 1790

