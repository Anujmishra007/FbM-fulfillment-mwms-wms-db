
--rdt_638RefNoLKUP01
exec rdt.rdtDropMsg 149551 , 149600

--Ecom return reference no for ASN 
execute rdt.rdtaddmsg 149551, 10, '49551^RefNoNotInASN','us_english'
execute rdt.rdtaddmsg 149552, 10, '49552^RefNoMultiASN','us_english'
