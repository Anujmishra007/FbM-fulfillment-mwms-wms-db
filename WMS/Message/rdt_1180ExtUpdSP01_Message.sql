
--rdt_1180ExtUpdSP01
--95351 - 95400

exec rdt.rdtDropMsg 95351 , 95400
-- **********************************************
GO
DECLARE @nFunc INT

SET @nFunc = 1180

execute rdt.rdtAddMsg 95351 ,10, '95351^CartonNotExist', 'us_english',@nFunc
execute rdt.rdtAddMsg 95352 ,10, '95352^InsCartonFail', 'us_english',@nFunc
execute rdt.rdtAddMsg 95353 ,10, '95353^UpdCartonFail', 'us_english',@nFunc
execute rdt.rdtAddMsg 95354 ,10, '95354^InvalidOption', 'us_english',@nFunc
execute rdt.rdtAddMsg 95355 ,10, '95355^UpdCartonFail', 'us_english',@nFunc
execute rdt.rdtAddMsg 95356 ,10, '95356^UpdePODFail', 'us_english',@nFunc
execute rdt.rdtAddMsg 95357 ,10, '95357^UpdCartonFail', 'us_english',@nFunc
execute rdt.rdtAddMsg 95358 ,10, '95358^PrintLabelFail', 'us_english',@nFunc



