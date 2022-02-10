--rdtfnc_DTC_Dispatch
execute rdt.rdtdropmsg 90451 , 90500
execute rdt.rdtdropmsg 172051, 172100

GO
DECLARE @nFunc INT

SET @nFunc = 841

execute rdt.rdtAddMsg 90451, 10, '90451^Printer ID req',    'us_english',@nFunc
execute rdt.rdtAddMsg 90452, 10, '90452^NoPaperPrinter',    'us_english',@nFunc
execute rdt.rdtAddMsg 90453, 10, '90453^Tote req',    'us_english',@nFunc
execute rdt.rdtAddMsg 90454, 10, '90454^Tote not exists',    'us_english',@nFunc
execute rdt.rdtAddMsg 90455, 10, '90455^ShortPickFound',    'us_english',@nFunc
execute rdt.rdtAddMsg 90456, 10, '90456^Tote Not Picked',    'us_english',@nFunc

execute rdt.rdtAddMsg 90457, 10, '90457^NoRecToProcess',    'us_english',@nFunc
execute rdt.rdtAddMsg 90458, 10, '90458^Ins EcommFail',    'us_english',@nFunc

execute rdt.rdtAddMsg 90459, 10, '90459^INVALID SKU',    'us_english',@nFunc
execute rdt.rdtAddMsg 90460, 10, '90460^MultiSKUBarCod',    'us_english',@nFunc
execute rdt.rdtAddMsg 90461, 10, '90461^INVALID SKU',    'us_english',@nFunc

execute rdt.rdtAddMsg 90462, 10, '90462^UpdDropIdFail',    'us_english',@nFunc
execute rdt.rdtAddMsg 90463, 10, '90463^Reason Req',    'us_english',@nFunc
execute rdt.rdtAddMsg 90464, 10, '90464^Invalid Reason',    'us_english',@nFunc
execute rdt.rdtAddMsg 90465, 10, '90465^Invalid Reason',    'us_english',@nFunc
execute rdt.rdtAddMsg 90466, 10, '90466^UPDECOMLOGFail',    'us_english',@nFunc
execute rdt.rdtAddMsg 90467, 10, '90467^ReversePACFail',    'us_english',@nFunc
execute rdt.rdtAddMsg 90468, 10, '90468^UPDECOMLOGFail',    'us_english',@nFunc

execute rdt.rdtAddMsg 90469, 10, '90469^Option Req',    'us_english',@nFunc
execute rdt.rdtAddMsg 90470, 10, '90470^Invalid Option',    'us_english',@nFunc
execute rdt.rdtAddMsg 90471, 10, '90471^NoRecToProcess',    'us_english',@nFunc
execute rdt.rdtAddMsg 90472, 10, '90472^Ins EcommFail',    'us_english',@nFunc


execute rdt.rdtAddMsg 90473, 10, '90473^TrackNoReq',    'us_english',@nFunc
execute rdt.rdtAddMsg 90474, 10, '90474^Inv TrackNo',    'us_english',@nFunc
execute rdt.rdtAddMsg 90475, 10, '90475^TrackNoInUsed',    'us_english',@nFunc
execute rdt.rdtAddMsg 90476, 10, '90476^Inv TrackNo',    'us_english',@nFunc
execute rdt.rdtAddMsg 90477, 10, '90477^DelEcommLogFail',    'us_english',@nFunc  
execute rdt.rdtAddMsg 90478, 10, '90478^DelEcommLogFail',    'us_english',@nFunc

execute rdt.rdtAddMsg 90479, 10, '90479^ShortPickFound',    'us_english',@nFunc  
execute rdt.rdtAddMsg 90480, 10, '90480^Tote Not Picked',    'us_english',@nFunc

-- (ChewKP01) 
execute rdt.rdtAddMsg 90481, 10, '90481^NoRecToProcess',    'us_english',@nFunc
execute rdt.rdtAddMsg 90482, 10, '90482^Ins EcommFail',    'us_english',@nFunc
execute rdt.rdtAddMsg 90483, 10, '90483^InvalidOrderKey',    'us_english',@nFunc
execute rdt.rdtAddMsg 90484, 10, '90484^InvalidWaveKey',    'us_english',@nFunc
execute rdt.rdtAddMsg 90485, 10, '90485^InvalidLoadKey',    'us_english',@nFunc

execute rdt.rdtAddMsg 90486, 10, '90486^DelEcommLogFail',    'us_english',@nFunc
execute rdt.rdtAddMsg 90487, 10, '90487^DelEcommLogFail',    'us_english',@nFunc

-- (ChewKP05)
execute rdt.rdtAddMsg 90488, 10, '90488^OrdPENDCANC',    'us_english',@nFunc
execute rdt.rdtAddMsg 90489, 10, '90489^OrdPENDPACK',    'us_english',@nFunc
execute rdt.rdtAddMsg 90490, 10, '90490^OrdHOLD',    'us_english',@nFunc

execute rdt.rdtAddMsg 90491, 10, '90491^ShortPickFound',    'us_english',@nFunc
execute rdt.rdtAddMsg 90492, 10, '90492^Tote NotPicked',    'us_english',@nFunc
execute rdt.rdtAddMsg 90493, 10, '90493^CartontypeBlank',    'us_english',@nFunc
execute rdt.rdtAddMsg 90494, 10, '90494^InvalidCarton',    'us_english',@nFunc
execute rdt.rdtAddMsg 90495, 10, '90495^UpdDropIdFail',    'us_english',@nFunc
execute rdt.rdtAddMsg 90496, 10, '90496^DelEcommLogFail',    'us_english',@nFunc
execute rdt.rdtAddMsg 90497, 10, '90497^DelEcommLogFail',    'us_english',@nFunc
execute rdt.rdtAddMsg 90498, 10, '90498^DelEcommLogFail',    'us_english',@nFunc

--WMS-17410
execute rdt.rdtAddMsg 90499, 10, '90499^Need Weight   ',    'us_english',@nFunc
execute rdt.rdtAddMsg 90500, 10, '90500^Invalid Weight',    'us_english',@nFunc
execute rdt.rdtAddMsg 172051, 10, '172051^Need Cube   ',    'us_english',@nFunc
execute rdt.rdtAddMsg 172052, 10, '172052^Invalid cube',    'us_english',@nFunc

select * from rdt.rdtMsg (nolock) where message_id between 90451 and 90500
select * from rdt.rdtMsg (nolock) where message_id between 172051 and 172100
