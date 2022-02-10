-- rdt_1641ExtValidSP02
exec rdt.rdtDropMsg 92151, 92200

execute rdt.rdtAddMsg 92151 ,10, '92151^RouteNotMatch ', 'us_english', 1641
execute rdt.rdtAddMsg 92152 ,10, '92152^Diff Discharge', 'us_english', 1641
execute rdt.rdtAddMsg 92153 ,10, '92153^Diff Delivery ', 'us_english', 1641
execute rdt.rdtAddMsg 92154 ,10, '92154^Need Route    ', 'us_english', 1641
execute rdt.rdtAddMsg 92155 ,10, '92155^Invalid date  ', 'us_english', 1641
