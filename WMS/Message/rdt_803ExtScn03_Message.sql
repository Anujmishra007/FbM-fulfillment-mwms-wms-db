-- FCR-9003
-- FCR-14204
EXECUTE rdt.rdtDropMsg 252851, 252900

EXECUTE rdt.rdtAddMsg 252851, 10, '252851^InvalidCartID',                     'us_english', 803, 0, '252851 Invalid CartID'
EXECUTE rdt.rdtAddMsg 252853, 10, '252853^AssignedToDiffCart',                'us_english', 803, 0, '252853 Station assigned with different cart'
EXECUTE rdt.rdtAddMsg 252854, 10, '252854^AssignedToDiffStation',             'us_english', 803, 0, '252854 Cart assigned to another station'
EXECUTE rdt.rdtAddMsg 252858, 10, '252858Cannot find Order',                  'us_english', 803, 0, '252858 Can not find SKU in DropID'
EXECUTE rdt.rdtAddMsg 252859, 10, '252859HospLocNotFnd',                      'us_english', 803, 0, '252859 Can not find hospital location'
EXECUTE rdt.rdtAddMsg 252860, 10, '252860CartIsNotEpty',                      'us_english', 803, 0, '252860 Cart is not empty'
EXECUTE rdt.rdtAddMsg 252862, 10, '252862InvdReasonCode',                     'us_english', 803, 0, '252862 Incorrect reason code'
EXECUTE rdt.rdtAddMsg 252863, 10, '252863NoItemsToHosp',                      'us_english', 803, 0, '252863 No items to hospitalize'
EXECUTE rdt.rdtAddMsg 252864, 10, '252864BulkLocNotFound',                    'us_english', 803, 0, '252864 Bulk hospital location not found'
EXECUTE rdt.rdtAddMsg 252865, 10, '252865SeqKeyFailed',                       'us_english', 803, 0, '252865 HSBKKSeqKey sequence generation failed'
EXECUTE rdt.rdtAddMsg 252866, 10, '252866InsPickDetailFailed',                'us_english', 803, 0, '252866 Insert into @tPickDetail failed'
EXECUTE rdt.rdtAddMsg 252867, 10, '252867UpdOrderLocFailed',                  'us_english', 803, 0, '252867 Update @tOrderLoc failed'
EXECUTE rdt.rdtAddMsg 252868, 10, '252868UpdPickDetailFailed',                'us_english', 803, 0, '252868 Update PICKDETAIL failed'
EXECUTE rdt.rdtAddMsg 252869, 10, '252869GenKeyFailed',                       'us_english', 803, 0, '252869 Generate HSBK key failed'
EXECUTE rdt.rdtAddMsg 252870, 10, '252870NoHospitalLoc',                      'us_english', 803, 0, '252870 No hospital location found'
EXECUTE rdt.rdtAddMsg 252871, 10, '252871NeedOption',                         'us_english', 803, 0, '252871 Need Option'
EXECUTE rdt.rdtAddMsg 252872, 10, '252872InvalidOption',                      'us_english', 803, 0, '252872 Invalid Option'
EXECUTE rdt.rdtAddMsg 252873, 10, '252873NeedReasonCode',                     'us_english', 803, 0, '252873 Need Reason Code'
EXECUTE rdt.rdtAddMsg 252874, 10, '252874NoReasonCode',                       'us_english', 803, 0, '252874 No reason code configured'
EXECUTE rdt.rdtAddMsg 252875, 10, '252875AddRFPFailed',                       'us_english', 803, 0, '252875 Add RFPutaway failed'

SELECT * FROM rdt.RDTMsg WITH(NOLOCK) WHERE Message_ID BETWEEN 252851 AND 252900