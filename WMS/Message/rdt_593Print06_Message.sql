--rdt_593Print06
--execute rdt.rdtDropMsg 97851 - 97900

GO
DECLARE @nFunc INT

SET @nFunc = 593

execute rdt.rdtAddMsg 97851 ,10, '97851^LabelPrnterReq', 'us_english',@nFunc
execute rdt.rdtAddMsg 97852 ,10, '97852^InputReq', 'us_english',@nFunc
execute rdt.rdtAddMsg 97853 ,10, '97853^OrderDateReq', 'us_english',@nFunc
execute rdt.rdtAddMsg 97854 ,10, '97854^InvalidDate', 'us_english',@nFunc
execute rdt.rdtAddMsg 97855 ,10, '97855^ExternOrderKeyReq', 'us_english',@nFunc
execute rdt.rdtAddMsg 97856 ,10, '97856^InvalidExtOrderKey', 'us_english',@nFunc
execute rdt.rdtAddMsg 97857 ,10, '97857^InvalidDate', 'us_english',@nFunc
execute rdt.rdtAddMsg 97858 ,10, '97858^PrintErr', 'us_english',@nFunc
execute rdt.rdtAddMsg 97859 ,10, '97859^DateIsDefaultWhenBlank', 'us_english',@nFunc









