--rdt_1764ExtScn01
--UWP-31321 
execute rdt.rdtdropmsg 234851 , 234900

execute rdt.rdtAddMsg 234851, 10, '234851 UpdPKTaskFail',   'us_english', 1764

--UWP-34785
execute rdt.rdtAddMsg 234852, 10, '234852 OptionNeeded',    'us_english', 1764
execute rdt.rdtAddMsg 234853, 10, '234853 InvalidOption',   'us_english', 1764

--FCR-7928
execute rdt.rdtAddMsg 234855, 10, '234855 InsPkdFail',      'us_english', 1764, 0, '234855 Insert Into @tPickDetail Failed'
execute rdt.rdtAddMsg 234856, 10, '234856 UpdPKDFail',      'us_english', 1764, 0, '234856 Update PickDetail Failed'
execute rdt.rdtAddMsg 234857, 10, '234857 LogAlertFail',    'us_english', 1764, 0, '234857 Log Alert Failed'
execute rdt.rdtAddMsg 234858, 10, '234858 SubmitQTaskFail', 'us_english', 1764, 0, '234858 Submit QCommanderTask Failed'
execute rdt.rdtAddMsg 234859, 10, '234859 UPD PKDtl Fail',  'us_english', 1764, 0, '234859 Update PickDetail Failed'
execute rdt.rdtAddMsg 234860, 10, '234860 UPD TskDtl Fail', 'us_english', 1764, 0, '234860 Update TaskDetail Failed'
execute rdt.rdtAddMsg 234861, 10, '234861 UpdTaskFail',     'us_english', 1764, 0, '234861 Update Task Failed'
execute rdt.rdtAddMsg 234862, 10, '234862 UpdTaskFail',     'us_english', 1764, 0, '234862 Update Task Failed'
--UWP-43838
execute rdt.rdtAddMsg 234854, 10, '234854 DropIDIsNotClosed',   'us_english', 1764, 0, '234854 DropID is not closed yet'

-- UWP-47931
execute rdt.rdtAddMsg 234863, 10, '234863 HoldUCCFail',     'us_english', 1764, 0, '234863 Hold UCC Failed'

-- FCR-12136
execute rdt.rdtAddMsg 234864, 10, '234864 GenDropIDFail',      'us_english', 1764, 0, '234864 Generate DropID Failed'
execute rdt.rdtAddMsg 234865, 10, '234865 UpdTaskFail',        'us_english', 1764, 0, '234865 Update Task Failed'
execute rdt.rdtAddMsg 234866, 10, '234866 UpdTaskFail',        'us_english', 1764, 0, '234866 Update Task Failed'

SELECT * FROM rdt.RDTMsg (NOLOCK) WHERE Message_ID BETWEEN 234851 AND 234900