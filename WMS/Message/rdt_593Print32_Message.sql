--rdt_593Print32
--execute rdt.rdtDropMsg 164451, 164500

execute rdt.rdtAddMsg 164451, 10, '64451^LOCMultiCarton', 'us_english', 593
execute rdt.rdtAddMsg 164452, 10, '64452^LOC No Carton ', 'us_english', 593

select * from rdt.rdtMsg (nolock) where message_id between 164451 and 164500