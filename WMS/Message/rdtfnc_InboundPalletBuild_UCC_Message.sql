-- rdtfnc_InboundPalletBuild_UCC
exec rdt.rdtDropMsg 174201, 174250

execute rdt.rdtAddMsg 174201, 10, '174201^Need PalletID', 'us_english', 1858
execute rdt.rdtAddMsg 174202, 10, '174202^ID Exists    ', 'us_english', 1858
execute rdt.rdtAddMsg 174203, 10, '174203^Need UccNo   ', 'us_english', 1858
execute rdt.rdtAddMsg 174204, 10, '174204^Invalid UccNo', 'us_english', 1858
execute rdt.rdtAddMsg 174205, 10, '174205^InvalidStatus', 'us_english', 1858
execute rdt.rdtAddMsg 174206, 10, '174206^Duplicate UCC', 'us_english', 1858
execute rdt.rdtAddMsg 174207, 10, '174207^Option Req   ', 'us_english', 1858
execute rdt.rdtAddMsg 174208, 10, '174208^InvalidOption', 'us_english', 1858
execute rdt.rdtAddMsg 174209, 10, '174209^UPD UCC Fail ', 'us_english', 1858
execute rdt.rdtAddMsg 174210, 10, '174210^UPD Log Fail ', 'us_english', 1858
execute rdt.rdtAddMsg 174211, 10, '174211^InvalidFormat', 'us_english', 1858
execute rdt.rdtAddMsg 174212, 10, '174212^UCC Exists   ', 'us_english', 1858
execute rdt.rdtAddMsg 174213, 10, '174213^UPD LLI FAIL ', 'us_english', 1858
execute rdt.rdtAddMsg 174214, 10, '174214^Duplicate UCC', 'us_english', 1858

SELECT * FROM rdt.rdtmsg (NOLOCK) WHERE Message_ID BETWEEN 174201 and 174250
