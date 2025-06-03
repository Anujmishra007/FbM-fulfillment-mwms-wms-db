/********************************************************
rdt_BuildPalletToKit_Confirm
********************************************************/
--234901 - 234950

EXECUTE rdt.rdtDropMsg 234901, 234950

EXECUTE rdt.rdtAddMsg 234901 ,10, '234901NeedStorer',       'us_english', 663, 0, '234901: Need storer'
EXECUTE rdt.rdtAddMsg 234902 ,10, '234902NeedFacility',     'us_english', 663, 0, '234902: Need facility'
EXECUTE rdt.rdtAddMsg 234903 ,10, '234903NeedKitKey',       'us_english', 663, 0, '234903: Need Kit Key'
EXECUTE rdt.rdtAddMsg 234904 ,10, '234904KitNotFound',      'us_english', 663, 0, '234904: KitKey not found'
EXECUTE rdt.rdtAddMsg 234905 ,10, '234905DiffFacility',     'us_english', 663, 0, '234905: Different facility'
EXECUTE rdt.rdtAddMsg 234906 ,10, '234906DiffStorer',       'us_english', 663, 0, '234906: Different storer'
EXECUTE rdt.rdtAddMsg 234907 ,10, '234907InvalidLoc',       'us_english', 663, 0, '234907: Invalid Location'
EXECUTE rdt.rdtAddMsg 234908 ,10, '234908LocNotInFac',      'us_english', 663, 0, '234908: Loc is not in the facility'
EXECUTE rdt.rdtAddMsg 234909 ,10, '234909NeedSKU',          'us_english', 663, 0, '234909: Need SKU'
EXECUTE rdt.rdtAddMsg 234910 ,10, '234910IDInUse',          'us_english', 663, 0, '234910: ID is in use'
EXECUTE rdt.rdtAddMsg 234911 ,10, '234911InvalidSKU',       'us_english', 663, 0, '234911: Invalid SKU'
EXECUTE rdt.rdtAddMsg 234912 ,10, '234912InvalidQty',       'us_english', 663, 0, '234912: Invalid Quantity'
EXECUTE rdt.rdtAddMsg 234913 ,10, '234913NeedUOM',          'us_english', 663, 0, '234913: Need UOM'
EXECUTE rdt.rdtAddMsg 234914 ,10, '234914InvalidUOM',       'us_english', 663, 0, '234914: Invalid UOM'
EXECUTE rdt.rdtAddMsg 234915 ,10, '234915NeedLottable',     'us_english', 663, 0, '234915: Need Lottable'
EXECUTE rdt.rdtAddMsg 234916 ,10, '234916NeedPaltType',     'us_english', 663, 0, '234916: Need pallet type'
EXECUTE rdt.rdtAddMsg 234917 ,10, '234917InvPaltType',      'us_english', 663, 0, '234917: Invalid pallet type'
EXECUTE rdt.rdtAddMsg 234918 ,10, '234918PaltTypeNoMatch',  'us_english', 663, 0, '234918: Pallet quantity not match'
EXECUTE rdt.rdtAddMsg 234919 ,10, '234919UpdKITDtlErr',     'us_english', 663, 0, '234919: Update KITDetail Error'
EXECUTE rdt.rdtAddMsg 234920 ,10, '234920InsKITDtlErr',     'us_english', 663, 0, '234920: Insert KITDetail Error'

SELECT * FROM rdt.rdtMsg WITH (NOLOCK) WHERE Message_ID BETWEEN  234901 AND 234950
