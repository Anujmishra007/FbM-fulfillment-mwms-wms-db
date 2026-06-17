-- rdt_1868ExtValidSP01.sql - (NYE018 - FCR-12825)
-- 270401 - 270450

execute rdt.rdtDropMsg 270401, 270450

execute rdt.rdtAddMsg 270401, 10, '270401^Unpack not allowed',  'us_english', 1868, 0, '270401^Unpack not allowed'
