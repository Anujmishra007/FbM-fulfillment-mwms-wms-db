--rdtfnc_SerialNo_Serialize_Master
execute rdt.rdtdropmsg 113201 , 113250
GO
DECLARE @nFunc INT

SET @nFunc = 1014

execute rdt.rdtAddMsg 113201, 10, '13201^WorkOrdeRNoReq',    'us_english',@nFunc
execute rdt.rdtAddMsg 113202, 10, '13202^InvdWorkOrder',    'us_english',@nFunc 
execute rdt.rdtAddMsg 113203, 10, '13203^SKUReq',    'us_english',@nFunc 
execute rdt.rdtAddMsg 113204, 10, '13204^InvalidSKU',    'us_english',@nFunc 
execute rdt.rdtAddMsg 113205, 10, '13205^MultiSKUBarCod',    'us_english',@nFunc 
execute rdt.rdtAddMsg 113206, 10, '13206^InvalidSKU',    'us_english',@nFunc 
execute rdt.rdtAddMsg 113206, 10, '13206^InvalidSKU',    'us_english',@nFunc 
execute rdt.rdtAddMsg 113207, 10, '13207^InvSerialType',    'us_english',@nFunc 
execute rdt.rdtAddMsg 113208, 10, '13208^SerialNoNotExist',    'us_english',@nFunc 
execute rdt.rdtAddMsg 113209, 10, '13209^InvSerialNo',    'us_english',@nFunc 
execute rdt.rdtAddMsg 113210, 10, '13210^GetKeyFail',    'us_english',@nFunc 
execute rdt.rdtAddMsg 113211, 10, '13211^UpdSerialLogFail',    'us_english',@nFunc 
execute rdt.rdtAddMsg 113212, 10, '13212^ParentSerialReq',    'us_english',@nFunc 
execute rdt.rdtAddMsg 113213, 10, '13213^InvSerialType',    'us_english',@nFunc 
execute rdt.rdtAddMsg 113214, 10, '13214^InvSerialNo',    'us_english',@nFunc 
execute rdt.rdtAddMsg 113215, 10, '13215^SerialNoScanned',    'us_english',@nFunc 
execute rdt.rdtAddMsg 113216, 10, '13216^InsMasterSerialFail',    'us_english',@nFunc 
execute rdt.rdtAddMsg 113217, 10, '13217^InsMasterSerialFail',    'us_english',@nFunc 
execute rdt.rdtAddMsg 113218, 10, '13218^UpdrdtSerailFail',    'us_english',@nFunc 
execute rdt.rdtAddMsg 113219, 10, '13219^DelrdtSerailFail',    'us_english',@nFunc 
execute rdt.rdtAddMsg 113220, 10, '13220^SerialNoScanned',    'us_english',@nFunc 
execute rdt.rdtAddMsg 113221, 10, '13221^OptionReq',    'us_english',@nFunc 
execute rdt.rdtAddMsg 113222, 10, '13222^InvalidOption',    'us_english',@nFunc 
execute rdt.rdtAddMsg 113223, 10, '13223^SKUReq',    'us_english',@nFunc 
execute rdt.rdtAddMsg 113224, 10, '13224^InvalidSKU',    'us_english',@nFunc 
execute rdt.rdtAddMsg 113225, 10, '13225^MultiSKUBarCod',    'us_english',@nFunc 
execute rdt.rdtAddMsg 113226, 10, '13226^WrongSKU',    'us_english',@nFunc 
execute rdt.rdtAddMsg 113227, 10, '13227^OverScanned',    'us_english',@nFunc 
execute rdt.rdtAddMsg 113228, 10, '13228^InvSerialNo',    'us_english',@nFunc 
execute rdt.rdtAddMsg 113229, 10, '13229^InvSerialNo',    'us_english',@nFunc 
execute rdt.rdtAddMsg 113230, 10, '13230^InvSerialNo',    'us_english',@nFunc 
execute rdt.rdtAddMsg 113231, 10, '13231^InvSerialNo',    'us_english',@nFunc 
execute rdt.rdtAddMsg 113232, 10, '13232^InvSerialNo',    'us_english',@nFunc 
execute rdt.rdtAddMsg 113233, 10, '13233^InvSerialNo',    'us_english',@nFunc 

