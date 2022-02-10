-- rdtfnc_PostPackAudit_CloseBatch (range 62941, 62966)
execute rdt.rdtAddMsg 62941, 10, '62941^Batch needed', 'us_english'
execute rdt.rdtAddMsg 62944, 10, '62944^Fail To UPD', 'us_english'
execute rdt.rdtAddMsg 62945, 10, '62945^Option needed', 'us_english'
execute rdt.rdtAddMsg 62946, 10, '62946^NoOpenedBatch', 'us_english'
execute rdt.rdtAddMsg 62947, 10, '62947^OpenTaskFound', 'us_english'

-- SOS#137534 - Add Batch screen
execute rdt.rdtAddMsg 62952, 10, '62952^Batch needed', 'us_english'
execute rdt.rdtAddMsg 62953, 10, '62953^BatchNotFound', 'us_english'
execute rdt.rdtAddMsg 62954, 10, '62954^BatchAlrdyClosed', 'us_english'