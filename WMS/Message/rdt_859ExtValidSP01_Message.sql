--rdt_859ExtValidSP01
execute rdt.rdtdropmsg 111201 , 111250
GO
DECLARE @nFunc INT

SET @nFunc = 859

execute rdt.rdtAddMsg 111201, 10, '11201^InvalidEventcode',    'us_english',@nFunc
execute rdt.rdtAddMsg 111202, 10, '11202^PreEventNotDone',    'us_english',@nFunc
execute rdt.rdtAddMsg 111203, 10, '11203^InvalidCarrier',    'us_english',@nFunc
execute rdt.rdtAddMsg 111204, 10, '11204^EventExists',    'us_english',@nFunc 