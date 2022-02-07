--rdtfnc_SerialNoDelete
execute rdt.rdtDropMsg 63201, 63250
 
execute rdt.rdtAddMsg 63201, 10, '63201^Serial# Required','us_english'
execute rdt.rdtAddMsg 63202, 10, '63202^SN# Not Exists',  'us_english'
execute rdt.rdtAddMsg 63203, 10, '63203^Delete SN# Err',  'us_english'
