--rdtfnc_Scan_To_Pallet
execute rdt.rdtdropmsg 68866, 68890

execute rdt.rdtAddMsg 68866, 10, '68866^PLT# required ', 'us_english', 1638
execute rdt.rdtAddMsg 68867, 10, '68867^Ins PLT Fail  ', 'us_english', 1638
execute rdt.rdtAddMsg 68868, 10, '68868^Invalid Storer', 'us_english', 1638
execute rdt.rdtAddMsg 68869, 10, '68869^Case ID req   ', 'us_english', 1638
execute rdt.rdtAddMsg 68870, 10, '68870^Case ID exists', 'us_english', 1638
execute rdt.rdtAddMsg 68871, 10, '68871^Invalid Storer', 'us_english', 1638
execute rdt.rdtAddMsg 68872, 10, '68872^Ship To Diff  ', 'us_english', 1638
execute rdt.rdtAddMsg 68873, 10, '68873^Ins PLTDt Fail', 'us_english', 1638
execute rdt.rdtAddMsg 68874, 10, '68874^Invalid Option', 'us_english', 1638
execute rdt.rdtAddMsg 68875, 10, '68875^NoLoginPrinter', 'us_english', 1638
execute rdt.rdtAddMsg 68876, 10, '68876^DWNOTSetup    ', 'us_english', 1638
execute rdt.rdtAddMsg 68877, 10, '68877^TgetDB Not Set', 'us_english', 1638
execute rdt.rdtAddMsg 68878, 10, '68878^InsertPRTFail ', 'us_english', 1638
execute rdt.rdtAddMsg 68879, 10, '68879^NeedCartonType', 'us_english', 1638
execute rdt.rdtAddMsg 68880, 10, '68880^Bad CartonType', 'us_english', 1638
execute rdt.rdtAddMsg 68881, 10, '68881^INSPackInfFail', 'us_english', 1638
execute rdt.rdtAddMsg 68882, 10, '68882^InvalidValue  ', 'us_english', 1638
execute rdt.rdtAddMsg 68883, 10, '68883^InvalidValue  ', 'us_english', 1638
execute rdt.rdtAddMsg 68884, 10, '68884^InvalidValue  ', 'us_english', 1638
execute rdt.rdtAddMsg 68885, 10, '68885^InvalidValue  ', 'us_english', 1638
execute rdt.rdtAddMsg 68886, 10, '68886^InsPalletFail ', 'us_english', 1638
execute rdt.rdtAddMsg 68887, 10, '68887^LOC required  ', 'us_english', 1638
execute rdt.rdtAddMsg 68888, 10, '68888^Invalid LOC   ', 'us_english', 1638
execute rdt.rdtAddMsg 68889, 10, '68889^Invalid Format', 'us_english', 1638
execute rdt.rdtAddMsg 68890, 10, '68890^NeedCartonType', 'us_english', 1638

execute rdt.rdtdropmsg 155051, 155100

execute rdt.rdtAddMsg 155051, 10, '155051Bad CTN TYPE  ', 'us_english', 1638
execute rdt.rdtAddMsg 155052, 10, '155052Need Weight   ', 'us_english', 1638
execute rdt.rdtAddMsg 155053, 10, '155053Invalid weight', 'us_english', 1638
execute rdt.rdtAddMsg 155054, 10, '155054Need Cube     ', 'us_english', 1638
execute rdt.rdtAddMsg 155055, 10, '155055Invalid Cube  ', 'us_english', 1638
execute rdt.rdtAddMsg 155056, 10, '155056Invalid Format', 'us_english', 1638

-- WMS-15913
execute rdt.rdtAddMsg 155057, 10, '155057Option Req    ', 'us_english', 1638
execute rdt.rdtAddMsg 155058, 10, '155058Invalid Option', 'us_english', 1638
execute rdt.rdtAddMsg 155059, 10, '155059Pallet closed', 'us_english', 1638
execute rdt.rdtAddMsg 155060, 10, '155060UPD PalletFail', 'us_english', 1638
execute rdt.rdtAddMsg 155061, 10, '155061UPD MBOL Fail', 'us_english', 1638
