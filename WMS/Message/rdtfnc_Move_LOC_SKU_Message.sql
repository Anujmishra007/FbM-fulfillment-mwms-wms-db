-- rdtfnc_Move_LOC_SKU

execute rdt.rdtDropMsg 77201, 77250

execute rdt.rdtAddMsg 77201, 10, '77201 LOC needed    ', 'us_english'
execute rdt.rdtAddMsg 77202, 10, '77202 Invalid LOC   ', 'us_english'
execute rdt.rdtAddMsg 77203, 10, '77203 Diff facility ', 'us_english'
execute rdt.rdtAddMsg 77204, 10, '77204 LOC have UCC  ', 'us_english'
execute rdt.rdtAddMsg 77205, 10, '77205 SKU needed    ', 'us_english'
execute rdt.rdtAddMsg 77206, 10, '77206 Invalid SKU   ', 'us_english'
execute rdt.rdtAddMsg 77207, 10, '77207 No QTY to move', 'us_english'
execute rdt.rdtAddMsg 77208, 10, '77208 ToLOC needed  ', 'us_english'
execute rdt.rdtAddMsg 77209, 10, '77209 Invalid LOC   ', 'us_english'
execute rdt.rdtAddMsg 77210, 10, '77210 Diff facility ', 'us_english'
execute rdt.rdtAddMsg 77211, 10, '77211 Same FromToLOC', 'us_english'
