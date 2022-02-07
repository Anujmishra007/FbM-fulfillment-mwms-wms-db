-- rdt_511ExtValid05 
exec rdt.rdtDropMsg 172451, 172500
 
execute rdt.rdtAddMsg 172451, 10, '172451NotAllAGVGoods', 'us_english', 511
execute rdt.rdtAddMsg 172452, 10, '172452 InvalidAGVLoc', 'us_english', 511
execute rdt.rdtAddMsg 172453, 10, '172453 Dup AGV ToID ', 'us_english', 511