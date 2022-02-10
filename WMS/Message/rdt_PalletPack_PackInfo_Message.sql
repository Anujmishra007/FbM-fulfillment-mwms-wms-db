--rdt_PalletPack_PackInfo
rdt.rdtDropMsg 175801 , 175850

execute rdt.rdtAddMsg 175801, 10, '175801 INSPackInfErr',   'us_english', 835
execute rdt.rdtAddMsg 175802, 10, '175802 UPDPackInfErr',   'us_english', 835

SELECT * FROM RDT.RDTMSG (NOLOCK) WHERE MESSAGE_ID BETWEEN 175801 AND 175850