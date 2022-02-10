-- rdtfnc_UCCVerify
execute rdt.rdtDropMsg 59601, 59650

execute rdt.rdtAddMsg 59601, 10, '59601 UCC needed    ', 'us_english', 539
execute rdt.rdtAddMsg 59602, 10, '59602 UCC SKU/UPC   ', 'us_english', 539
execute rdt.rdtAddMsg 59603, 10, '59603 Invalid SKU   ', 'us_english', 539
execute rdt.rdtAddMsg 59604, 10, '59604 SKU not in UCC', 'us_english', 539
