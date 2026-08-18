--FCR-12996
exec rdt.rdtdropmsg 272551, 272600

execute rdt.rdtAddMsg 272551, 10, '272551 Invalid Location', 'us_english', 1721
execute rdt.rdtAddMsg 272552, 10, '272552 Upd DropID Failed', 'us_english', 1721
execute rdt.rdtAddMsg 272553, 10, '272553 ChildID Not Found', 'us_english', 1721
execute rdt.rdtAddMsg 272554, 10, '272554 Inventory Not Found', 'us_english', 1721
execute rdt.rdtAddMsg 272555, 10, '272555 rdt_Move Failed', 'us_english', 1721


select * from rdt.rdtmsg (nolock) where message_id between 272551 AND 272600
