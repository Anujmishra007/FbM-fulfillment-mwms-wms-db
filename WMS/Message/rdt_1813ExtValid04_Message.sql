--rdt_1637ExtValid02
execute rdt.rdtdropmsg 133201 , 133250
GO
DECLARE @nFunc INT

SET @nFunc = 1813

execute rdt.rdtAddMsg 133201, 10, '33201^OrderIDnotmatch',    'us_english',@nFunc
execute rdt.rdtAddMsg 133202, 10, '33202^X Mv ASRS PLT',    'us_english',@nFunc
execute rdt.rdtAddMsg 133203, 10, '33203^SKU NOT ON ID',    'us_english',@nFunc
execute rdt.rdtAddMsg 133204, 10, '33204^Key/Scan UPC',    'us_english',@nFunc
execute rdt.rdtAddMsg 133205, 10, '33205^Key/Scan UPC',    'us_english',@nFunc
execute rdt.rdtAddMsg 133206, 10, '33206^X Mv ASRS PLT',    'us_english',@nFunc
execute rdt.rdtAddMsg 133207, 10, '33207^TO ID X EXISTS',    'us_english',@nFunc
execute rdt.rdtAddMsg 133208, 10, '33208^DIFF PLTID LOC',    'us_english',@nFunc
execute rdt.rdtAddMsg 133209, 10, '33209^SKU NOT ON ID',    'us_english',@nFunc
execute rdt.rdtAddMsg 133210, 10, '33210^CopackItemKeyInBT',    'us_english',@nFunc
execute rdt.rdtAddMsg 133211, 10, '33211^InvalidID',    'us_english',@nFunc

--WMS-10688
execute rdt.rdtAddMsg 133212, 10, '33212^NEED STAGING',    'us_english',@nFunc
execute rdt.rdtAddMsg 133213, 10, '33213^NEED STAGING',    'us_english',@nFunc
execute rdt.rdtAddMsg 133214, 10, '33214^ToID Not Empty',  'us_english',@nFunc
execute rdt.rdtAddMsg 133215, 10, '33215^ToID Has Pick',   'us_english',@nFunc