
--isp_DPC_LightUpLoc
-- 80451 - 80500

exec rdt.rdtDropMsg 90951 , 91000
-- **********************************************
GO
DECLARE @nFunc INT

SET @nFunc = 0

execute rdt.rdtAddMsg 90951 ,10, '90951^PTLKeyReq', 'us_english',@nFunc
execute rdt.rdtAddMsg 90952 ,10, '90952^NoRecordFound', 'us_english',@nFunc
execute rdt.rdtAddMsg 90953 ,10, '90953^DeviceIDNotFound', 'us_english',@nFunc
execute rdt.rdtAddMsg 90954 ,10, '90954^UpdPTLTranFail', 'us_english',@nFunc







