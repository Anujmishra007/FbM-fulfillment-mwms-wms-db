--rdt_593Print04
--95601 – 95650

exec rdt.rdtDropMsg 95601 , 95650
-- **********************************************
GO
DECLARE @nFunc INT

SET @nFunc = 593

execute rdt.rdtAddMsg 95601 ,10, '95601^LabelPrnterReq', 'us_english',@nFunc
execute rdt.rdtAddMsg 95602 ,10, '95602^CartonIDReq', 'us_english',@nFunc
execute rdt.rdtAddMsg 95603 ,10, '95603^InvdCartonID', 'us_english',@nFunc
execute rdt.rdtAddMsg 95604 ,10, '95604^InvalidStatus', 'us_english',@nFunc


