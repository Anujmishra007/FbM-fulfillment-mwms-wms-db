--rdt_PalletInquiry_GetNextCarton
exec rdt.rdtDropMsg 191801 , 191850

execute rdt.rdtAddMsg 191801, 10, '191801 NO MORE REC  ',   'us_english', 1667


SELECT * FROM RDT.RDTMSG (NOLOCK) WHERE Message_ID BETWEEN 191801 AND 191850

