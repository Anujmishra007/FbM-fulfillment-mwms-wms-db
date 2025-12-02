-- rdt_1764CreateTask16
-- 252301 - 252350

execute rdt.rdtdropmsg 252301, 252350

execute rdt.rdtAddMsg '252301', 10, '252301^nspg_getkey   ', 'us_english', 1764
execute rdt.rdtAddMsg '252302', 10, '252302^nspg_getkey   ', 'us_english', 1764
execute rdt.rdtAddMsg '252303', 10, '252303^InsTaskDetFail', 'us_english', 1764
execute rdt.rdtAddMsg '252304', 10, '252304^InsTaskDetFail', 'us_english', 1764
execute rdt.rdtAddMsg '252305', 10, '252305^InsTaskDetFail', 'us_english', 1764


select * from rdt.rdtmsg (nolock) where message_id between 252301 and 252350