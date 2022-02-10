--rdt_895ExtUpdSP01
--execute rdt.rdtdropmsg 93851 - 93900
GO
DECLARE @nFunc INT

SET @nFunc = 895

execute rdt.rdtAddMsg 93851, 10, '93851^Upd RPL Fail',    'us_english',@nFunc
execute rdt.rdtAddMsg 93852, 10, '93852^UpdPickDetFail',    'us_english',@nFunc
execute rdt.rdtAddMsg 93853, 10, '93853^UpdUCCFail',    'us_english',@nFunc
execute rdt.rdtAddMsg 93854, 10, '93854^CreatePHdrFail',    'us_english',@nFunc
execute rdt.rdtAddMsg 93855, 10, '93855^PackCompleted',    'us_english',@nFunc
execute rdt.rdtAddMsg 93856, 10, '93856^NoLabelNoGen',    'us_english',@nFunc
execute rdt.rdtAddMsg 93857, 10, '93857^InsPackDetFail',    'us_english',@nFunc
execute rdt.rdtAddMsg 93858, 10, '93858^UpdReplenLogFail',    'us_english',@nFunc
execute rdt.rdtAddMsg 93859, 10, '93859^UpdRPLogFail',    'us_english',@nFunc
execute rdt.rdtAddMsg 93860, 10, '93860^UpdRPLogFail',    'us_english',@nFunc
execute rdt.rdtAddMsg 93861, 10, '93861^UpdPickDetFail',    'us_english',@nFunc
execute rdt.rdtAddMsg 93862, 10, '93862^UpdPickDetFail',    'us_english',@nFunc
execute rdt.rdtAddMsg 93863, 10, '93863^UpdPickDetFail',    'us_english',@nFunc
execute rdt.rdtAddMsg 93864, 10, '93864^GetDetKeyFail',    'us_english',@nFunc
execute rdt.rdtAddMsg 93865, 10, '93865^Ins PDtl Fail',    'us_english',@nFunc
execute rdt.rdtAddMsg 93866, 10, '93866^UpdPickDetFail',    'us_english',@nFunc
execute rdt.rdtAddMsg 93867, 10, '93867^UpdPickDetFail',    'us_english',@nFunc
execute rdt.rdtAddMsg 93868, 10, '93868^UpdReplenLogFail',    'us_english',@nFunc
execute rdt.rdtAddMsg 93869, 10, '93869^UpdPackHdrFail',    'us_english',@nFunc
execute rdt.rdtAddMsg 93870, 10, '93870^UpdRPLogFail',    'us_english',@nFunc
execute rdt.rdtAddMsg 93871, 10, '93871^UpdReplenLogFail',    'us_english',@nFunc
execute rdt.rdtAddMsg 93872, 10, '93872^InsPackInfoFail',    'us_english',@nFunc
execute rdt.rdtAddMsg 93873, 10, '93873^UpdPackInfoFail',    'us_english',@nFunc
execute rdt.rdtAddMsg 93874, 10, '93874^UpdRPLogFail',    'us_english',@nFunc
execute rdt.rdtAddMsg 93875, 10, '93875^UpdRPLogFail',    'us_english',@nFunc
execute rdt.rdtAddMsg 93876, 10, '93876^UpdRPLogFail',    'us_english',@nFunc

--(ChewKP04) 
execute rdt.rdtAddMsg 93877, 10, '93877^UpdPickDetFail',    'us_english',@nFunc
execute rdt.rdtAddMsg 93878, 10, '93878^UpdPickDetFail',    'us_english',@nFunc
execute rdt.rdtAddMsg 93879, 10, '93879^GetDetKeyFail',    'us_english',@nFunc
execute rdt.rdtAddMsg 93880, 10, '93880^Ins PDtl Fail',    'us_english',@nFunc
execute rdt.rdtAddMsg 93881, 10, '93881^UpdPickDetFail',    'us_english',@nFunc
execute rdt.rdtAddMsg 93882, 10, '93882^UpdPickDetFail',    'us_english',@nFunc

--WMS-14885
execute rdt.rdtAddMsg 93883, 10, '93883^Insert TL3 Err',    'us_english',@nFunc
