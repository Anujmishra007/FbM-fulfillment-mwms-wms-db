-- rdt_513ExtVal14
-- Product Division validation for GOO items

exec rdt.rdtDropMsg 268351, 268400

execute rdt.rdtAddMsg 268351, 10, '268351^SKU ProdDiv Empty', 'us_english', 513
execute rdt.rdtAddMsg 268352, 10, '268352^ProdDiv Mismatch', 'us_english', 513
