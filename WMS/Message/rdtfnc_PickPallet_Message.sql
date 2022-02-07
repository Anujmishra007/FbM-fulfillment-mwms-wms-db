-- Message range 169151 - 169200 (rdtfnc_PickPallet)
execute rdt.rdtDropMsg 169151, 169200

execute rdt.rdtAddMsg 169151, 10, '69151 CantPickUCC PL', 'us_english', 1854
execute rdt.rdtAddMsg 169152, 10, '69152 PSNO required ', 'us_english', 1854
execute rdt.rdtAddMsg 169153, 10, '69153 Invalid PSNO  ', 'us_english', 1854
execute rdt.rdtAddMsg 169154, 10, '69154 OrderShipped  ', 'us_english', 1854
execute rdt.rdtAddMsg 169155, 10, '69155 Diff storer   ', 'us_english', 1854
execute rdt.rdtAddMsg 169156, 10, '69156 OrderShipped  ', 'us_english', 1854
execute rdt.rdtAddMsg 169157, 10, '69157 Diff storer   ', 'us_english', 1854
execute rdt.rdtAddMsg 169158, 10, '69158 OrderShipped  ', 'us_english', 1854
execute rdt.rdtAddMsg 169159, 10, '69159 Diff storer   ', 'us_english', 1854
execute rdt.rdtAddMsg 169160, 10, '69160 Scan-In Fail  ', 'us_english', 1854
execute rdt.rdtAddMsg 169161, 10, '69161 Scan-In Fail  ', 'us_english', 1854
execute rdt.rdtAddMsg 169162, 10, '69162 PS not scan in', 'us_english', 1854
execute rdt.rdtAddMsg 169163, 10, '69163 PS scanned out', 'us_english', 1854
execute rdt.rdtAddMsg 169164, 10, '69164 LOC needed    ', 'us_english', 1854
execute rdt.rdtAddMsg 169165, 10, '69165 Invalid LOC   ', 'us_english', 1854
execute rdt.rdtAddMsg 169166, 10, '69166 Diff facility ', 'us_english', 1854
execute rdt.rdtAddMsg 169167, 10, '69167 Invalid Format', 'us_english', 1854
execute rdt.rdtAddMsg 169168, 10, '69168 Invalid Loc   ', 'us_english', 1854
execute rdt.rdtAddMsg 169169, 10, '69169 No task in LOC', 'us_english', 1854
execute rdt.rdtAddMsg 169170, 10, '69170 Wrong ID      ', 'us_english', 1854
execute rdt.rdtAddMsg 169171, 10, '69171 Option needed ', 'us_english', 1854
execute rdt.rdtAddMsg 169172, 10, '69172 Invalid Option', 'us_english', 1854
execute rdt.rdtAddMsg 169173, 10, '69173 Option needed ', 'us_english', 1854
execute rdt.rdtAddMsg 169174, 10, '69174 Invalid Option', 'us_english', 1854
execute rdt.rdtAddMsg 169175, 10, '69175 Del UCC fail  ', 'us_english', 1854
execute rdt.rdtAddMsg 169176, 10, '69176 Option needed ', 'us_english', 1854
execute rdt.rdtAddMsg 169177, 10, '69177 Invalid Option', 'us_english', 1854
execute rdt.rdtAddMsg 169178, 10, '69178 Del UCC fail  ', 'us_english', 1854
execute rdt.rdtAddMsg 169179, 10, '69179 OptionRequired', 'us_english', 1854
execute rdt.rdtAddMsg 169180, 10, '69180 Invalid Option', 'us_english', 1854



SELECT * FROM rdt.rdtMsg (NOLOCK) WHERE Message_ID BETWEEN 169151 and 169200