-- rdt_1637ExtValid08
execute rdt.rdtDropMsg 167901, 167950

execute rdt.rdtAddMsg 167901, 10, '167901PalletID Exist',  'us_english', 1637

SELECT TOP 10 * FROM rdt.rdtMsg (NOLOCK) WHERE Message_ID BETWEEN 167901 and 167950
