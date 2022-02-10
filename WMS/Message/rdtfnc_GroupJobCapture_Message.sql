

-- rdtfnc_groupjobcapture_message
exec rdt.rdtDropMsg 139101, 139150

execute rdt.rdtAddMsg 139101, 10, '139101^UserID Needed',   'us_english', 707
execute rdt.rdtAddMsg 139102, 10, '139102^Inv UserID',    'us_english', 707
execute rdt.rdtAddMsg 139103, 10, '139103^Inactive User',   'us_english', 707
execute rdt.rdtAddMsg 139104, 10, '139104^UserID Needed',   'us_english', 707
execute rdt.rdtAddMsg 139105, 10, '139105^User DoubScan',     'us_english', 707
execute rdt.rdtAddMsg 139106, 10, '139106^JobNotSetup',     'us_english', 707
execute rdt.rdtAddMsg 139107, 10, '139107^SimilarUser',     'us_english', 707
execute rdt.rdtAddMsg 139108, 10, '139108^Inv UserID',     'us_english', 707
execute rdt.rdtAddMsg 139109, 10, '139109^Inv Option',     'us_english', 707
execute rdt.rdtAddMsg 139110, 10, '139110^Inv Option',     'us_english', 707
execute rdt.rdtAddMsg 139111, 10, '139111^Inv Option',     'us_english', 707


select * from rdt.rdtmsg (nolock) where message_id between '139101' and '139150'







