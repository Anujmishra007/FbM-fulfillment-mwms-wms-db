-- rdtfnc_ChangeASNStorer
execute rdt.rdtdropmsg 86301, 86350    

execute rdt.rdtAddMsg 86301, 10, '86301^NeedReceiptKey', 'us_english', 546
execute rdt.rdtAddMsg 86302, 10, '86302^Bad ReceiptKey', 'us_english', 546
execute rdt.rdtAddMsg 86303, 10, '86303^ASN finalized ', 'us_english', 546
execute rdt.rdtAddMsg 86304, 10, '86304^Invalid Storer', 'us_english', 546
execute rdt.rdtAddMsg 86305, 10, '86305^NoNeedToUpdate', 'us_english', 546
execute rdt.rdtAddMsg 86306, 10, '86306^UDF01 NotBlank', 'us_english', 546
execute rdt.rdtAddMsg 86307, 10, '86307^UPDReceiptFail', 'us_english', 546
