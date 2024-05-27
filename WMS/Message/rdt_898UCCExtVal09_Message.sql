-- rdt_898UCCExtVal09
--FCR-236
exec rdt.rdtdropmsg 215301 , 215350

execute rdt.rdtAddMsg 215301, 10, '215301^InvalidSvalue', 'us_english', 898
execute rdt.rdtAddMsg 215302, 10, '215302^InvalidPrefixLen', 'us_english', 898
execute rdt.rdtAddMsg 215303, 10, '215303^SetupCodeLkup', 'us_english', 898
execute rdt.rdtAddMsg 215304, 10, '215304^SKUNotExist', 'us_english', 898
execute rdt.rdtAddMsg 215305, 10, '215305^CartNeedQC', 'us_english', 898
execute rdt.rdtAddMsg 215306, 10, '215306^CartNeedQC,FAI', 'us_english', 898
execute rdt.rdtAddMsg 215307, 10, '215307^UCCNeedQC&FAI,CantRcvID', 'us_english', 898
execute rdt.rdtAddMsg 215308, 10, '215308^UCCNeedQC,CantRcvID', 'us_english', 898
execute rdt.rdtAddMsg 215309, 10, '215309^UCCNeedFAI,CantRcvID', 'us_english', 898
execute rdt.rdtAddMsg 215310, 10, '215310^UpdUCCErr', 'us_english', 898
execute rdt.rdtAddMsg 215311, 10, '215311^UpdSKUErr', 'us_english', 898

select * from rdt.rdtmsg (nolock) where message_id between 215301 AND 215350