--rdt_Return_V7_CaptureInfo
exec rdt.rdtDropMsg 209051 - 209100	

execute rdt.rdtAddMsg 209051, 10, '209051 Need data    ', 'us_english', 607
execute rdt.rdtAddMsg 209052, 10, '209052Invalid format', 'us_english', 607
execute rdt.rdtAddMsg 209053, 10, '209053 Invalid value', 'us_english', 607

SELECT * FROM rdt.RDTMsg (NOLOCK) WHERE Message_ID BETWEEN 209051 AND 209100


