-- rdt_607ExcessStockToPO01
execute rdt.rdtDropMsg 113901, 113950

execute rdt.rdtAddMsg 113901, 10, '113901GetKey Fail   ',   'us_english', 607
execute rdt.rdtAddMsg 113902, 10, '113902INS PO Fail   ',   'us_english', 607
execute rdt.rdtAddMsg 113903, 10, '113903INS PODtl Fail',   'us_english', 607
execute rdt.rdtAddMsg 113904, 10, '113904UPD PODtl Fail',   'us_english', 607
