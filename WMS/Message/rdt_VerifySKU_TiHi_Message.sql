--rdt_VerifySKU_TiHi
execute rdt.rdtDropMsg 55651, 55700

execute rdt.rdtAddMsg 55651, 10, '55651 Need Ti x Hi  ',   'us_english'
execute rdt.rdtAddMsg 55652, 10, '55652 Invalid format',   'us_english'
execute rdt.rdtAddMsg 55653, 10, '55653 Need Ti       ',   'us_english'
execute rdt.rdtAddMsg 55654, 10, '55654 Need Hi       ',   'us_english'
execute rdt.rdtAddMsg 55655, 10, '55655 Invalid Ti    ',   'us_english'
execute rdt.rdtAddMsg 55656, 10, '55656 Invalid Hi    ',   'us_english'
