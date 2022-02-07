--rdtfnc_SerialNo_Kitting
execute rdt.rdtdropmsg 113101 , 113150
GO
DECLARE @nFunc INT

SET @nFunc = 1013

execute rdt.rdtAddMsg 113101, 10, '13101^WorkOrdeRNoReq',    'us_english',@nFunc
execute rdt.rdtAddMsg 113102, 10, '13102^InvdWorkOrder',    'us_english',@nFunc 
execute rdt.rdtAddMsg 113103, 10, '13103^OptionReq',    'us_english',@nFunc 
execute rdt.rdtAddMsg 113103, 10, '13104^InvalidOption',    'us_english',@nFunc 
execute rdt.rdtAddMsg 113105, 10, '13105^SKUReq',    'us_english',@nFunc 
execute rdt.rdtAddMsg 113106, 10, '13106^InvalidSKU',    'us_english',@nFunc 
execute rdt.rdtAddMsg 113107, 10, '13107^MultiSKUBarCod',    'us_english',@nFunc 
execute rdt.rdtAddMsg 113108, 10, '13108^QtyReq',    'us_english',@nFunc 
execute rdt.rdtAddMsg 113109, 10, '13109^Invalid QTY',    'us_english',@nFunc 
execute rdt.rdtAddMsg 113110, 10, '13110^InvalidSKU',    'us_english',@nFunc 
execute rdt.rdtAddMsg 113111, 10, '13111^GenSerialNoFail',    'us_english',@nFunc 
execute rdt.rdtAddMsg 113112, 10, '13112^GenSerialNoFail',    'us_english',@nFunc 
execute rdt.rdtAddMsg 113113, 10, '13113^GenSerialNoFail',    'us_english',@nFunc 
execute rdt.rdtAddMsg 113114, 10, '13114^SKUReq',    'us_english',@nFunc 
execute rdt.rdtAddMsg 113115, 10, '13115^InvalidSKU',    'us_english',@nFunc 
execute rdt.rdtAddMsg 113116, 10, '13116^MultiSKUBarCod',    'us_english',@nFunc 
execute rdt.rdtAddMsg 113117, 10, '13117^InvalidSKU',    'us_english',@nFunc 
execute rdt.rdtAddMsg 113118, 10, '13118^GetKeyFail',    'us_english',@nFunc 
execute rdt.rdtAddMsg 113119, 10, '13119^InsrdtSerailFail',    'us_english',@nFunc 
execute rdt.rdtAddMsg 113120, 10, '13120^InvSerialType',    'us_english',@nFunc 
execute rdt.rdtAddMsg 113121, 10, '13121^9LNotCompleted',    'us_english',@nFunc 
execute rdt.rdtAddMsg 113122, 10, '13122^9LNotCompleted',    'us_english',@nFunc 
execute rdt.rdtAddMsg 113123, 10, '13123^UpdrdtSerailFail',    'us_english',@nFunc 
execute rdt.rdtAddMsg 113124, 10, '13124^InvSerialType',    'us_english',@nFunc 
execute rdt.rdtAddMsg 113125, 10, '13125^InvSerialNo',    'us_english',@nFunc 
execute rdt.rdtAddMsg 113126, 10, '13126^SerialNoScanned',    'us_english',@nFunc 
execute rdt.rdtAddMsg 113127, 10, '13127^InvSerialNo',    'us_english',@nFunc 
execute rdt.rdtAddMsg 113128, 10, '13128^SerialNoScanned',    'us_english',@nFunc 
execute rdt.rdtAddMsg 113129, 10, '13129^UpdrdtSerailFail',    'us_english',@nFunc 
execute rdt.rdtAddMsg 113130, 10, '13130^ParentSerialReq',    'us_english',@nFunc 
execute rdt.rdtAddMsg 113131, 10, '13131^InvSerialNo',    'us_english',@nFunc 
execute rdt.rdtAddMsg 113132, 10, '13132^SerialNoScanned',    'us_english',@nFunc 
execute rdt.rdtAddMsg 113133, 10, '13133^InsMasterSerialFail',    'us_english',@nFunc 
execute rdt.rdtAddMsg 113134, 10, '13134^InsMasterSerialFail',    'us_english',@nFunc 
execute rdt.rdtAddMsg 113135, 10, '13135^UpdrdtSerailFail',    'us_english',@nFunc 
execute rdt.rdtAddMsg 113136, 10, '13136^InvSerialType',    'us_english',@nFunc 
execute rdt.rdtAddMsg 113137, 10, '13137^DelMasterSerialFail',    'us_english',@nFunc 
execute rdt.rdtAddMsg 113138, 10, '13138^DelMasterSerialFail',    'us_english',@nFunc 