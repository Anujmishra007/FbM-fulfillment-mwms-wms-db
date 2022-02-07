--rdt_VerifySKU_AltSKU02
execute rdt.rdtdropmsg 164701 , 164750

execute rdt.rdtAddMsg 164701, 10, '164701NeedAltSKU',    'us_english',537
execute rdt.rdtAddMsg 164702, 10, '164702InvalidAltSKU',    'us_english',537

