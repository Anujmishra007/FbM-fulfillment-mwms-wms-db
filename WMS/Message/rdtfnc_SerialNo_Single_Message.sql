--rdtfnc_SerialNo_Single
execute rdt.rdtdropmsg 114401 , 114450
GO
DECLARE @nFunc INT

SET @nFunc = 1016


execute rdt.rdtAddMsg 114401, 10, '14401^WorkOrdeRNoReq',    'us_english',@nFunc
execute rdt.rdtAddMsg 114402, 10, '14402^InvdWorkOrder',    'us_english',@nFunc
execute rdt.rdtAddMsg 114403, 10, '14403^InvalidSKU',    'us_english',@nFunc
execute rdt.rdtAddMsg 114404, 10, '14404^MasterSerialReq',    'us_english',@nFunc
execute rdt.rdtAddMsg 114405, 10, '14405^ChildSerialReq',    'us_english',@nFunc
execute rdt.rdtAddMsg 114406, 10, '14406^InsrdtSerailFail',    'us_english',@nFunc
execute rdt.rdtAddMsg 114407, 10, '14407^DelrdtSerailFail',    'us_english',@nFunc
execute rdt.rdtAddMsg 114408, 10, '14408^OptionReq',    'us_english',@nFunc
execute rdt.rdtAddMsg 114409, 10, '14409^InvalidOption',    'us_english',@nFunc
execute rdt.rdtAddMsg 114410, 10, '14410^InvalidLabel',    'us_english',@nFunc
