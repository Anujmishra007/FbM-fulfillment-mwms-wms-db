-- rdt_GENERATEIDGen_Message


exec rdt.rdtDropMsg 224951, 225000

execute rdt.rdtAddMsg 224951 ,10, '224951^NoCodelistConfiguration'      , 'us_english', 1812, 0,'224951 No Codelist Configuration'
execute rdt.rdtAddMsg 224952 ,10, '224952^Code2 Error'                  , 'us_english', 1812, 0,'224952 Code2 (Length of Sequence) Error'
execute rdt.rdtAddMsg 224953 ,10, '224953^UDF03/UDF04 Error'            , 'us_english', 1812, 0,'224953 UDF03 (Min Sequence)/UDF04(Max Sequence) Error'
execute rdt.rdtAddMsg 224954 ,10, '224954^ResetNCounterFailed'          , 'us_english', 1812, 0,'224954 Reset NCounter Failed'
execute rdt.rdtAddMsg 224955 ,10, '224955^Getkey Error'                 , 'us_english', 1812, 0,'224955 Getkey Error'
execute rdt.rdtAddMsg 224956 ,10, '224956^No IDType'                    , 'us_english', 1812, 0,'224956 No IDType'


SELECT * FROM RDT.RDTMsg (NOLOCK) WHERE Message_ID BETWEEN 224951 AND 225000

 