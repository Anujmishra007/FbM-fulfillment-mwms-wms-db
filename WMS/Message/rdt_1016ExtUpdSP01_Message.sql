
--rdt_1016ExtUpd01
-- 114501 - 114550

exec rdt.rdtDropMsg 114501 , 114550
-- **********************************************
GO
DECLARE @nFunc INT

SET @nFunc = 1016

execute rdt.rdtAddMsg 114501 ,10, '14501^InsMasterSerialFail', 'us_english',@nFunc
execute rdt.rdtAddMsg 114502 ,10, '14502^UpdRDTSerialFail', 'us_english',@nFunc
execute rdt.rdtAddMsg 114503 ,10, '14503^InsrdtSerailFail', 'us_english',@nFunc
execute rdt.rdtAddMsg 114504 ,10, '14504^InsMasterSerialFail', 'us_english',@nFunc
execute rdt.rdtAddMsg 114505 ,10, '14505^UpdRDTSerialFail', 'us_english',@nFunc
execute rdt.rdtAddMsg 114506 ,10, '14506^DelRDTSerialFail', 'us_english',@nFunc
execute rdt.rdtAddMsg 114507 ,10, '14507^0Scanned', 'us_english',@nFunc