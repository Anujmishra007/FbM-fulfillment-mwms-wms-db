
--rdt_PTL_Carton_InsertPTLTran
-- 91251 - 91300

exec rdt.rdtDropMsg 91251 , 91300
-- **********************************************
GO
DECLARE @nFunc INT

SET @nFunc = 809

execute rdt.rdtAddMsg 91251 ,10, '91251^UpdDropIDFail', 'us_english',@nFunc
execute rdt.rdtAddMsg 91252 ,10, '91252^InsPTLTranFail', 'us_english',@nFunc
execute rdt.rdtAddMsg 91253 ,10, '91253^NoPackTask', 'us_english',@nFunc
execute rdt.rdtAddMsg 91254 ,10, '91254^InsPTLTranFail', 'us_english',@nFunc
