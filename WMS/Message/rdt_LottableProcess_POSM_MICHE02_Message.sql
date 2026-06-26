-- 270501 - 270550
exec rdt.rdtDropMsg 270501, 270550

execute rdt.rdtAddMsg 270501 ,10, '270501^Invalid input, must be 4-digit',         'us_english',600
execute rdt.rdtAddMsg 270502 ,10, '270502^Invalid week, must be between 1 and 52', 'us_english',600
execute rdt.rdtAddMsg 270503 ,10, '270503^Invalid input, must be 4-digit numeric', 'us_english',600
execute rdt.rdtAddMsg 270504, 10, '270504^Long life > REXLOG',                     'us_english', 600
execute rdt.rdtAddMsg 270505, 10, '270505^DOT year mismatch',                      'us_english', 600
execute rdt.rdtAddMsg 270506, 10, '270506^DOT 8-week rule error',                  'us_english', 600 