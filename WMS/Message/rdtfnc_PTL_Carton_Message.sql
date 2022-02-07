
--rdtfnc_PTL_Carton
-- 91201 - 91250

exec rdt.rdtDropMsg 91201 , 91250
-- **********************************************
GO
DECLARE @nFunc INT

SET @nFunc = 809

execute rdt.rdtAddMsg 91201 ,10, '91201^PTSZoneReq', 'us_english',@nFunc
execute rdt.rdtAddMsg 91202 ,10, '91202^InvalidPTSZone', 'us_english',@nFunc
execute rdt.rdtAddMsg 91203 ,10, '91203^UserIDReq', 'us_english',@nFunc
execute rdt.rdtAddMsg 91204 ,10, '91204^InvalidUserID', 'us_english',@nFunc
execute rdt.rdtAddMsg 91205 ,10, '91205^UserIDInUsed', 'us_english',@nFunc
execute rdt.rdtAddMsg 91206 ,10, '91206^WorkLoadNotFound', 'us_english',@nFunc
execute rdt.rdtAddMsg 91207 ,10, '91207^InvalidDropID', 'us_english',@nFunc
execute rdt.rdtAddMsg 91208 ,10, '91208^OptionReq', 'us_english',@nFunc
execute rdt.rdtAddMsg 91209 ,10, '91209^InvOption', 'us_english',@nFunc
execute rdt.rdtAddMsg 91210 ,10, '91210^STLNotSetup', 'us_english',@nFunc
execute rdt.rdtAddMsg 91211 ,10, '91211^DropIDExist', 'us_english',@nFunc
execute rdt.rdtAddMsg 91212 ,10, '91212^LightModeNotSetup', 'us_english',@nFunc
execute rdt.rdtAddMsg 91213 ,10, '91213^MaxDropIDReached', 'us_english',@nFunc
execute rdt.rdtAddMsg 91214 ,10, '91214^DiffWaveKey', 'us_english',@nFunc
execute rdt.rdtAddMsg 91215 ,10, '91215^InvalidDropID', 'us_english',@nFunc
execute rdt.rdtAddMsg 91216 ,10, '91216^UserIDInUsed', 'us_english',@nFunc