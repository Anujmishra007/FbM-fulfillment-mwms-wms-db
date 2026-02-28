-- rdtfnc_Pack
-- FCR-9200
execute rdt.rdtDropMsg 251651, 251700

execute rdt.rdtAddMsg 251651, 10, '251651 OrdKeyNeeded ',         'us_english', 777, 0, '251651 Order Key is required'
execute rdt.rdtAddMsg 251652, 10, '251652 InvalidOrder ',         'us_english', 777, 0, '251652 Invalid Order'
execute rdt.rdtAddMsg 251653, 10, '251653 PackCompleted ',        'us_english', 777, 0, '251653 Pack Completed'
execute rdt.rdtAddMsg 251654, 10, '251654 GetPickSlipNoFail ',    'us_english', 777, 0, '251654 Get PickSlipNo Failed'
execute rdt.rdtAddMsg 251655, 10, '251655 PackCompelted ',        'us_english', 777, 0, '251655 Pack Completed'
execute rdt.rdtAddMsg 251656, 10, '251656 Scan-In Fail  ',        'us_english', 777
execute rdt.rdtAddMsg 251657, 10, '251657 Scan-In Fail  ',        'us_english', 777
execute rdt.rdtAddMsg 251658, 10, '251658 Not Scan-In   ',        'us_english', 777
execute rdt.rdtAddMsg 251659, 10, '251659 InvalidOption',         'us_english', 777, 0, '251659 Invalid Option'
execute rdt.rdtAddMsg 251660, 10, '251660 DisableOption',         'us_english', 777, 0, '251660 Disable Option'
execute rdt.rdtAddMsg 251661, 10, '251661 Pack confirmed',        'us_english', 777, 0, '251661 Pack confirmed'
execute rdt.rdtAddMsg 251662, 10, '251662 No carton    ',         'us_english', 777, 0, '251662 No carton'

SELECT * FROM rdt.rdtmsg (NOLOCK) WHERE Message_ID BETWEEN 251651 AND 251700