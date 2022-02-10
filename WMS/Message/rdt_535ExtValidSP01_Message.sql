
--rdt_535ExtValidSP01
exec rdt.rdtDropMsg 87351 , 87400

execute rdt.rdtaddmsg 87301, 10,'87351^>1 SKU'   ,'us_english'
execute rdt.rdtaddmsg 87301, 10,'87352^>1 SKU'   ,'us_english'
execute rdt.rdtaddmsg 87301, 10,'87353^Invalid SKU','us_english'

