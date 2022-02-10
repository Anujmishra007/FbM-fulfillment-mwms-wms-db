
-- rdtfnc_Move (range 62551 - 62575)
execute rdt.rdtDropMsg 62551, 62575

execute rdt.rdtAddMsg 62551, 10, '62551 LOC needed',     'us_english'
execute rdt.rdtAddMsg 62552, 10, '62552 Invalid LOC',    'us_english'
execute rdt.rdtAddMsg 62553, 10, '62553 Diff facility',  'us_english'
execute rdt.rdtAddMsg 62554, 10, '62554 No record',      'us_english'
execute rdt.rdtAddMsg 62555, 10, '62555 QTY allocated',  'us_english'
execute rdt.rdtAddMsg 62556, 10, '62556 Invalid LOC',    'us_english'
execute rdt.rdtAddMsg 62557, 10, '62557 Diff facility',  'us_english'

-- SOS#137962
execute rdt.rdtAddMsg 62558, 10, '62558 ID on Hold',  'us_english'

execute rdt.rdtAddMsg 62559, 10, '62559^UPD UCC fail', 'us_english'
execute rdt.rdtAddMsg 62560, 10, '62560^UPD UCC fail', 'us_english'

-- SOS276237
execute rdt.rdtAddMsg 62561, 10, '62561^LOC INV STORER', 'us_english'

-- SOS348153
execute rdt.rdtAddMsg 62562, 10, '62562^NotInStorerGrp', 'us_english'
execute rdt.rdtAddMsg 62563, 10, '62563^NotInStorerGrp', 'us_english'
