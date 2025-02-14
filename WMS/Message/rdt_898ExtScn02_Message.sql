--rdt_898ExtScn02
execute rdt.rdtdropmsg 229151 , 229200

execute rdt.rdtAddMsg 229151, 10, '229151^UCC Already Exists',   'us_english', 898
execute rdt.rdtAddMsg 229152, 10, '229152^Multi SKU/UCC',   'us_english', 898
--execute rdt.rdtAddMsg 229153, 10, '229153^UpdUDF01Fail',   'us_english', 898 --Move to rdt_898RcvCfm
execute rdt.rdtAddMsg 229154, 10, '229154^UCC Required',   'us_english', 898