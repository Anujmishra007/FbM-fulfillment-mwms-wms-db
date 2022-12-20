--rdtfnc_SplitUCC
exec rdt.rdtDropMsg 87251 , 87300

execute rdt.rdtAddMsg 87251 ,10, '87251^FromUCC Req   ',    'us_english', 535
execute rdt.rdtAddMsg 87252 ,10, '87252^InvalidUCC    ',    'us_english', 535
execute rdt.rdtAddMsg 87253 ,10, '87253^ToUCC Req     ',    'us_english', 535
execute rdt.rdtAddMsg 87254 ,10, '87254^Option Req    ',    'us_english', 535
execute rdt.rdtAddMsg 87255 ,10, '87255^InvalidOption ',    'us_english', 535
execute rdt.rdtAddMsg 87256 ,10, '87256^SKU Req       ',    'us_english', 535
execute rdt.rdtAddMsg 87257 ,10, '87257^Invalid SKU   ',    'us_english', 535
execute rdt.rdtAddMsg 87258 ,10, '87258^Invalid SKU   ',    'us_english', 535
execute rdt.rdtAddMsg 87259 ,10, '87259^Invalid SKU   ',    'us_english', 535
execute rdt.rdtAddMsg 87260 ,10, '87260^Invalid Qty   ',    'us_english', 535
execute rdt.rdtAddMsg 87261 ,10, '87263^Qty Not Enuf  ',    'us_english', 535
execute rdt.rdtAddMsg 87262 ,10, '87262^ToID Req      ',    'us_english', 535
execute rdt.rdtAddMsg 87263 ,10, '87263^Invalid Option',    'us_english', 535

SELECT * FROM rdt.rdtMsg (NOLOCK) WHERE Message_Id BETWEEN 87251 AND 87300