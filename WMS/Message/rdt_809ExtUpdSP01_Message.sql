
--rdt_809ExtUpdSP01
-- 91301 - 91350

exec rdt.rdtDropMsg 91301 , 91350
-- **********************************************
GO
DECLARE @nFunc INT

SET @nFunc = 809

execute rdt.rdtAddMsg 91301 ,10, '91301^GetKeyFail', 'us_english',@nFunc
execute rdt.rdtAddMsg 91302 ,10, '91302^UpdDeviceFail', 'us_english',@nFunc
execute rdt.rdtAddMsg 91303 ,10, '91303^UpdPTLFail', 'us_english',@nFunc
execute rdt.rdtAddMsg 91304 ,10, '91304^LightUpFail', 'us_english',@nFunc
execute rdt.rdtAddMsg 91305 ,10, '91305^UpdDeviceFail', 'us_english',@nFunc
execute rdt.rdtAddMsg 91306 ,10, '91306^1stLocInUse', 'us_english',@nFunc
execute rdt.rdtAddMsg 91307 ,10, '91307^1stLocInUse', 'us_english',@nFunc
execute rdt.rdtAddMsg 91308 ,10, '91308^1stLocInUse', 'us_english',@nFunc
execute rdt.rdtAddMsg 91309 ,10, '91309^1stLocInUse', 'us_english',@nFunc
execute rdt.rdtAddMsg 91310 ,10, '91310^1stLocInUse', 'us_english',@nFunc
execute rdt.rdtAddMsg 91311 ,10, '91311^UserOnHold', 'us_english',@nFunc
execute rdt.rdtAddMsg 91312 ,10, '91312^UpdPTLTranFail', 'us_english',@nFunc
execute rdt.rdtAddMsg 91313 ,10, '91313^UpdPTLTranFail', 'us_english',@nFunc
execute rdt.rdtAddMsg 91314 ,10, '91314^UpdPTLTranFail', 'us_english',@nFunc
execute rdt.rdtAddMsg 91315 ,10, '91315^UserIDInUsed', 'us_english',@nFunc
execute rdt.rdtAddMsg 91316 ,10, '91316^DelLockLocFail', 'us_english',@nFunc