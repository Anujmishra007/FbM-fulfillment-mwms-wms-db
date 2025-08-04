
-- isp_VNAActionConfirm_Wrapper
execute rdt.rdtDropMsg 212501 , 212550

execute rdt.rdtAddMsg 212501, 10, '212501^Invalid Device ID',                          'us_english'
execute rdt.rdtAddMsg 212502, 10, '212502^Not VNAIN Task',                             'us_english'
execute rdt.rdtAddMsg 212503, 10, '212503^VNAIN - No From Loc',                        'us_english'
execute rdt.rdtAddMsg 212504, 10, '212504^VNAIN - No To Loc',                          'us_english'
execute rdt.rdtAddMsg 212505, 10, '212505^VNAIN - No ID',                              'us_english'
execute rdt.rdtAddMsg 212506, 10, '212506^VNAIN - No Putaway Confirm SP',              'us_english'
execute rdt.rdtAddMsg 212507, 10, '212507^VNA Confrim Fail',                           'us_english'
execute rdt.rdtAddMsg 212508, 10, '212508^Invalid Task detail key',                    'us_english'
execute rdt.rdtAddMsg 212509, 10, '212509^VNAIN Update Task Detail Fail',              'us_english'
execute rdt.rdtAddMsg 212510, 10, '212510^VNAIN - Invalid Task Status',                'us_english'
execute rdt.rdtAddMsg 212511, 10, '212511^Task was closed',                            'us_english'
execute rdt.rdtAddMsg 212512, 10, '212512^VNA Confirm SP Not Setup',                  'us_english'
execute rdt.rdtAddMsg 212513, 10, '212513^VNA Confirm SP Not Exists',                  'us_english'
execute rdt.rdtAddMsg 212514, 10, '212514^VNAOUTFPK Confrim Fail',                     'us_english'
execute rdt.rdtAddMsg 212515, 10, '212515^VNAOUTFPK - Not VNAOUTFPK Task',             'us_english'
execute rdt.rdtAddMsg 212516, 10, '212516^VNAIN - Unlock VNA Loc Fail',                'us_english'
execute rdt.rdtAddMsg 212517, 10, '212517^VNAOUTFPK - No new task was found',          'us_english'
execute rdt.rdtAddMsg 212518, 10, '212518^VNAOUTFPK - Update new task fail',           'us_english'
execute rdt.rdtAddMsg 212519, 10, '212519^VNAOUTFPK - Update Task Detail Fail',        'us_english'
execute rdt.rdtAddMsg 212520, 10, '212520^VNAOUTFPK - Update Task Detail Fail',        'us_english'
execute rdt.rdtAddMsg 212521, 10, '212521^VNAOUTFPK - Update Task Detail Fail',        'us_english'

execute rdt.rdtAddMsg 212522, 10, '212522^VNAOUTFPK - Get Detail Key Fail',            'us_english'
execute rdt.rdtAddMsg 212523, 10, '212523^VNAOUTFPK - Insert Pick Detail Fail',        'us_english'
execute rdt.rdtAddMsg 212524, 10, '212524^VNAOUTFPK - Insert RefKey Fail',             'us_english'
execute rdt.rdtAddMsg 212525, 10, '212525^VNAOUTFPK - Update Pick Detail Fail',        'us_english'

execute rdt.rdtAddMsg 212526, 10, '212526^VNAOUTFPK - Update Pick Detail Fail',        'us_english'
execute rdt.rdtAddMsg 212527, 10, '212527^VNAOUTFPK - Update Pick Detail Fail',        'us_english'
execute rdt.rdtAddMsg 212528, 10, '212528^VNAOUTFPK - Offset error',                   'us_english'
execute rdt.rdtAddMsg 212529, 10, '212529^VNAOUTFPK - Update Task Detail Fail',        'us_english'
execute rdt.rdtAddMsg 212530, 10, '212530^VNAOUTFPK - Invalid Task Status',            'us_english'
execute rdt.rdtAddMsg 212531, 10, '212531^VNAOUTFPK - Update PendingMoveIn Fail',      'us_english'
execute rdt.rdtAddMsg 212532, 10, '212532^VNAOUTFPK - LoadKey is missing in Task Detail',     'us_english'

execute rdt.rdtAddMsg 212533, 10, '212533^VNAOUTRPF - Lock Order Fail',                'us_english'
execute rdt.rdtAddMsg 212534, 10, '212534^VNAOUTRPF - Update LOTxLOCxID Fail',         'us_english'
execute rdt.rdtAddMsg 212535, 10, '212535^VNAOUTRPF - Update Pick Detail Fail',        'us_english'
execute rdt.rdtAddMsg 212536, 10, '212536^VNAOUTRPF - Invalid Task Status',            'us_english'
execute rdt.rdtAddMsg 212537, 10, '212537^VNAOUTRPF - Not VNAOUTRPF Task',             'us_english'
execute rdt.rdtAddMsg 212538, 10, '212538^VNAOUTRPF - No New Task',                    'us_english'


execute rdt.rdtAddMsg 212539, 10, '212539^VNAIN - Move Inentory Fail, details: ',      'us_english'
execute rdt.rdtAddMsg 212540, 10, '212540^VNAOUTFPK - Move Inentory Fail, details: ',  'us_english'
execute rdt.rdtAddMsg 212541, 10, '212541^VNAOUTRPF - Move Inentory Fail, details: ',  'us_english'
execute rdt.rdtAddMsg 212542, 10, '212542^VNAOUTFPK - Create 2nd task Fail, details: ',  'us_english'
execute rdt.rdtAddMsg 212543, 10, '212543^VNAOUTRPF - Create 2nd task Fail, details: ',  'us_english'
execute rdt.rdtAddMsg 212544, 10, '212544^VNAOUTRPF - Unlock Loc Fail, details: ',     'us_english'
execute rdt.rdtAddMsg 212545, 10, '212545^VNAOUTRPF - Update new task fail',           'us_english'
execute rdt.rdtAddMsg 212546, 10, '212546^VNAOUTRPF - Final Loc is missing',           'us_english'
execute rdt.rdtAddMsg 212547, 10, '212547^VNAOUTFPK - Remove Putaway Record Fail',     'us_english'
execute rdt.rdtAddMsg 212548, 10, '212548^VNAOUTRPF - Remove Putaway Record Fail',     'us_english'
execute rdt.rdtAddMsg 212549, 10, '212549^VNAOUTRPF - Loc PF Loc Fail, details: ',     'us_english'
execute rdt.rdtAddMsg 212550, 10, '212550^VNAOUTRPF - Unlock Loc Fail, details: ',     'us_english'
execute rdt.rdtAddMsg 212551, 10, '212551^VNAOUTRPF - Update TaskDetail Fail',         'us_english'
execute rdt.rdtAddMsg 212552, 10, '212552^VNAOUTRPF - Update TaskDetail Fail',         'us_english'


select * from rdt.rdtmsg (nolock) where message_id between 212501 and 212550
