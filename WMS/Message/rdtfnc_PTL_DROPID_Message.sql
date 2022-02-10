
use sgwms

-- rdt_PTL_DROPID _InsertPTLTran
exec rdt.rdtDropMsg 140451   , 140500

execute rdt.rdtAddMsg 140451, 10, '40451^PTSZoneReq',   'us_english', 1834
execute rdt.rdtAddMsg 140452, 10, '40452^InvalidPTSZone',   'us_english', 1834
execute rdt.rdtAddMsg 140453, 10, '40453^UserIDReq',   'us_english', 1834
execute rdt.rdtAddMsg 140454, 10, '40454^DeviceIDReq',   'us_english', 1834
execute rdt.rdtAddMsg 140455, 10, '40455^InvalidUserID',   'us_english', 1834
execute rdt.rdtAddMsg 140456, 10, '40456^InvDeviceID',   'us_english', 1834
execute rdt.rdtAddMsg 140457, 10, '40457^LMNotSetup',   'us_english', 1834
execute rdt.rdtAddMsg 140458, 10, '40458^WLNotFound',   'us_english', 1834
execute rdt.rdtAddMsg 140459, 10, '40459^InvDropID',   'us_english', 1834
execute rdt.rdtAddMsg 140460, 10, '40460^InvDropID',   'us_english', 1834
execute rdt.rdtAddMsg 140461, 10, '40461^OTLNotSetup',   'us_english', 1834
execute rdt.rdtAddMsg 140462, 10, '40462^DiffWaveKey',   'us_english', 1834
execute rdt.rdtAddMsg 140463, 10, '40463^MaxDropID',   'us_english', 1834
execute rdt.rdtAddMsg 140464, 10, '40464^OptionReq',   'us_english', 1834
execute rdt.rdtAddMsg 140465, 10, '40465^InvOption',   'us_english', 1834
execute rdt.rdtAddMsg 140466, 10, '40466^DeviceInUse',   'us_english', 1834
execute rdt.rdtAddMsg 140467, 10, '40467^InvFormat',   'us_english', 1834

select * from rdt.rdtmsg with (nolock) where message_id between 140451 and 140500