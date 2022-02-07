
--rdt_727Inquiry05

exec rdt.rdtDropMsg 129501 , 129550
-- **********************************************
GO
DECLARE @nFunc INT

SET @nFunc = 727

execute rdt.rdtAddMsg 129501 ,10, '29501^DropIDReq', 'us_english',@nFunc
execute rdt.rdtAddMsg 129502 ,10, '29502^InvalidDropID', 'us_english',@nFunc
execute rdt.rdtAddMsg 129503 ,10, '29503^CartonIDReq', 'us_english',@nFunc
execute rdt.rdtAddMsg 129504 ,10, '29504^InvalidCartonID', 'us_english',@nFunc






