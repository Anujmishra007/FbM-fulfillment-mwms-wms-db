--rdt_VerifySKU_GrossWgt
execute rdt.rdtDropMsg 56051, 56100

execute rdt.rdtAddMsg 56051, 10, '56051 Need GrossWgt ',   'us_english'
execute rdt.rdtAddMsg 56052, 10, '56052 Invalid Wgt   ',   'us_english'
