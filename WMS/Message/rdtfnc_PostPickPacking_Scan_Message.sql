/*
   60701 - 60750, 67101 - 67200  rdtfnc_PostPickPacking
*/

-- rdtfnc_PostPickPacking (range 60701 - 60750)
-- continue for rdtfnc_PostPickPacking (range 67101 - 67200)

-- Pallet
execute rdt.rdtAddMsg 60701, 10, '60701 WKSTA required', 'us_english'
execute rdt.rdtAddMsg 60702, 10, '60702 Store required', 'us_english'
execute rdt.rdtAddMsg 60703, 10, '60703 Invalid store',  'us_english'
execute rdt.rdtAddMsg 60704, 10, '60704 No open order',  'us_english'
execute rdt.rdtAddMsg 60705, 10, '60705 PalletID req',   'us_english'
execute rdt.rdtAddMsg 60706, 10, '60706 PL/T StillOpen', 'us_english'
execute rdt.rdtAddMsg 60707, 10, '60707 CaseID require', 'us_english'
execute rdt.rdtAddMsg 60708, 10, '60708 Add QTY fail',   'us_english'
execute rdt.rdtAddMsg 60709, 10, '60709 Double scan',    'us_english'
execute rdt.rdtAddMsg 60710, 10, '60710 Upd QTY fail',   'us_english'
execute rdt.rdtAddMsg 60711, 10, '60711 Diff stor''s CS','us_english'
execute rdt.rdtAddMsg 60712, 10, '60712 Not scan out',   'us_english'
execute rdt.rdtAddMsg 60713, 10, '60713 Not a CaseID',   'us_english'
execute rdt.rdtAddMsg 60714, 10, '60714 NoOpenedBatch',  'us_english'
execute rdt.rdtAddMsg 60715, 10, '60715 ScanToDiffStor', 'us_english'
execute rdt.rdtAddMsg 60716, 10, '60716 ScanToDiffWKSt', 'us_english'
execute rdt.rdtAddMsg 60717, 10, '60717 Call IT number', 'us_english'
execute rdt.rdtAddMsg 60718, 10, '60718 Invalid WKSTA',  'us_english'
execute rdt.rdtAddMsg 60719, 10, '60719 Invalid WKSTA',  'us_english'
-- SOS137578
execute rdt.rdtAddMsg 60720, 10, '60720 Batch required', 'us_english'
execute rdt.rdtAddMsg 60721, 10, '60721 Invalid Batch',  'us_english'
execute rdt.rdtAddMsg 60722, 10, '60722 BatchIsClosed',  'us_english'
execute rdt.rdtAddMsg 60723, 10, '60723 MisMatchStorer', 'us_english'
execute rdt.rdtAddMsg 60724, 10, '60724 Diff stor''s CS','us_english'

-- Case
execute rdt.rdtAddMsg 60725, 10, '60725 WKSTA required', 'us_english'
execute rdt.rdtAddMsg 60726, 10, '60726 Store required', 'us_english'
execute rdt.rdtAddMsg 60727, 10, '60727 Invalid store',  'us_english'
execute rdt.rdtAddMsg 60728, 10, '60728 No open order',  'us_english'
execute rdt.rdtAddMsg 60729, 10, '60729 CaseID require', 'us_english'
execute rdt.rdtAddMsg 60730, 10, '60730 PL/T StillOpen', 'us_english'
execute rdt.rdtAddMsg 60731, 10, '60731 QTY required',   'us_english'
execute rdt.rdtAddMsg 60732, 10, '60732 Invalid QTY',    'us_english'
execute rdt.rdtAddMsg 60733, 10, '60733 Invalid QTY',    'us_english'
execute rdt.rdtAddMsg 60734, 10, '60734 QTY must > 0',   'us_english'
execute rdt.rdtAddMsg 60735, 10, '60735 SKU required',   'us_english'
execute rdt.rdtAddMsg 60736, 10, '60736 Invalid SKU',    'us_english'
execute rdt.rdtAddMsg 60737, 10, '60737 SKU NotInOrder', 'us_english'
execute rdt.rdtAddMsg 60738, 10, '60738 OverPick',       'us_english'
execute rdt.rdtAddMsg 60739, 10, '60739 Invalid option', 'us_english'
execute rdt.rdtAddMsg 60740, 10, '60740 Not scan out',   'us_english'
execute rdt.rdtAddMsg 60741, 10, '60741 NoOpenedBatch',  'us_english'
execute rdt.rdtAddMsg 60742, 10, '60742 ScanToDiffStor', 'us_english'
execute rdt.rdtAddMsg 60743, 10, '60743 ScanToDiffWKSt', 'us_english'
execute rdt.rdtAddMsg 60744, 10, '60744 Double scan',    'us_english'
execute rdt.rdtAddMsg 60745, 10, '60745 Double scan',    'us_english'

--SOS93437
execute rdt.rdtAddMsg 60746, 10, '60746^WrongRefno',     'us_english'

-- SOS137578
execute rdt.rdtAddMsg 60747, 10, '60747 Not a CaseID',   'us_english'
execute rdt.rdtAddMsg 60748, 10, '60748 No Open Record', 'us_english'
execute rdt.rdtAddMsg 60749, 10, '60749 Batch required', 'us_english'
execute rdt.rdtAddMsg 60750, 10, '60750 Invalid Batch',  'us_english'

execute rdt.rdtAddMsg 67101, 10, '67101 BatchIsClosed',  'us_english'
execute rdt.rdtAddMsg 67102, 10, '67102 MisMatchStorer', 'us_english'

-- (Vicky01)
execute rdt.rdtAddMsg 67103, 10, '67103 Double Scan', 'us_english'
execute rdt.rdtAddMsg 67104, 10, '67104 Double Scan', 'us_english'

--execute rdt.rdtDropMsg 60740
--execute rdt.rdtDropMsg 60741
--execute rdt.rdtDropMsg 60742
--execute rdt.rdtDropMsg 60743
--execute rdt.rdtDropMsg 60744
--execute rdt.rdtDropMsg 60745
--execute rdt.rdtDropMsg 60747