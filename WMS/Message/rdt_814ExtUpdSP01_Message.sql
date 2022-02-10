
--rdt_814ExtUpdSP01
-- 991951 , 92000

exec rdt.rdtDropMsg 91951 , 92000
-- **********************************************
GO
DECLARE @nFunc INT

SET @nFunc = 814

execute rdt.rdtAddMsg 91951 ,10, '91951^MaintenanceComplete', 'us_english',@nFunc
execute rdt.rdtAddMsg 91952 ,10, '91952^LightUpFail', 'us_english',@nFunc
execute rdt.rdtAddMsg 91953 ,10, '91953^LightUpFail', 'us_english',@nFunc
execute rdt.rdtAddMsg 91954 ,10, '91954^PlsRestartUser', 'us_english',@nFunc
execute rdt.rdtAddMsg 91955 ,10, '91955^LightUpFail', 'us_english',@nFunc