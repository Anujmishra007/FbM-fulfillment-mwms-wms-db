-- 270601 - 270650

execute rdt.rdtDropMsg 270601, 270650

execute rdt.rdtAddMsg 270601, 10, '270601^Error updating MIN DOT', 'us_english', 600

select * from rdt.RDTMSG where Message_ID between 270601 and 270650

