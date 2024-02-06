if not exists(select * from rdt.RDTMsg where Message_Type = 'FNC' and Message_ID = 0)
insert into rdt.RDTMsg(Message_ID,Lang_Code,Message_Type,Message_Text,EventType,Func)
values(0,	'ENG',	'FNC',	'Login',		0,	0)
GO
if not exists(select * from rdt.RDTMsg where Message_Type = 'FNC' and Message_ID = 1)
insert into rdt.RDTMsg(Message_ID,Lang_Code,Message_Type,Message_Text,EventType,Func)
values(1,	'ENG',	'FNC',	'Storer-Facility',		0,	0)
GO
if not exists(select * from rdt.RDTMsg where Message_Type = 'FNC' and Message_ID = 2)
insert into rdt.RDTMsg(Message_ID,Lang_Code,Message_Type,Message_Text,EventType,Func)
values(2,	'ENG',	'FNC',	'Resume Screen',		0,	0)
GO

UPdate rdt.rdtmsg
set Message_Text='Scan Pallet To Door',StoredProcName='rdtfnc_scan_pallet_To_door'
where message_Type='FNC'and message_id=1650
GO
if not exists(select 1 from rdt.rdtmsg(nolock) where message_id = 839 and message_type = 'FNC')
insert into rdt.rdtmsg(Message_ID,Lang_Code,Message_Type,Message_Text,StoredProcName,EventType,Func)
   values(839,	'ENG',	    'FNC',	      'Pick Piece',	'RDTfnc_pickpiece',	0,	0	)
GO
if not exists(select 1 from rdt.rdtmsg(nolock) where message_id = 656 and message_type = 'FNC')
insert into rdt.rdtmsg(Message_ID,Lang_Code,Message_Type,Message_Text,StoredProcName,EventType,Func)
   values(656,	'ENG',	    'FNC',	      'OFFSITE REPLEN',	'rdtfnc_NIKEOffSiteReplen',	9,	0)
GO
if not exists(select 1 from rdt.rdtmsg(nolock) where message_id = 657 and message_type = 'FNC')
insert into rdt.rdtmsg(Message_ID,Lang_Code,Message_Type,Message_Text,StoredProcName,EventType,Func)
   values(657,	'ENG',	    'FNC',	      'IKEA ECOM RETURN',	'rdtfnc_IkeaEcomReturn',	2,	0)
GO
if not exists(select 1 from rdt.rdtmsg(nolock) where message_id = 1655 and message_type = 'FNC')
insert into rdt.rdtmsg(Message_ID,Lang_Code,Message_Type,Message_Text,StoredProcName,EventType,Func)
   values(1655,	'ENG',	    'FNC',	      'SORT CTN TO PLT',	'rdtfnc_SortCartonToPallet',	9,	0)
GO
if not exists(select 1 from rdt.rdtmsg(nolock) where message_id = 1865 and message_type = 'FNC')
insert into rdt.rdtmsg(Message_ID,Lang_Code,Message_Type,Message_Text,StoredProcName,EventType,Func)
   values(1865,	'ENG',	    'FNC',	      'PALLET SORT REVERSAL',	'rdtfnc_PrePalletizeSort_Reversal',	9,	0)
GO
if not exists(select 1 from rdt.rdtmsg(nolock) where message_id = 1861 and message_type = 'FNC')
insert into rdt.rdtmsg(Message_ID,Lang_Code,Message_Type,Message_Text,StoredProcName,EventType,Func)
   values(1861,	'ENG',	    'FNC',	      'Mbol ChildCreation',	'rdtfnc_Mbol_ChildCreation',	3,	0)
GO
if not exists(select 1 from rdt.rdtmsg(nolock) where message_id = 1862 and message_type = 'FNC')
insert into rdt.rdtmsg(Message_ID,Lang_Code,Message_Type,Message_Text,StoredProcName,EventType,Func)
   values(1862,	'ENG',	    'FNC',	      'Mbol ChildReverse',	'rdtfnc_Mbol_ChildReverse',	3,	0)
GO
if not exists(select 1 from rdt.rdtmsg(nolock) where message_id = 1770 and message_type = 'FNC')
insert into rdt.rdtmsg(Message_ID,Lang_Code,Message_Type,Message_Text,StoredProcName,EventType,Func)
   values(1770,	'ENG',	    'FNC',	      'TM Pallet Pick',	'rdtfnc_TM_PalletPick',	0,	NULL)
GO
if not exists(select 1 from rdt.rdtmsg(nolock) where message_id = 1797 and message_type = 'FNC')
insert into rdt.RDTMsg(Message_ID,Lang_Code,Message_Type,Message_Text,StoredProcName,EventType,Func)
   values(1797,'ENG',	'FNC',	'TM - Putaway From',	'rdtfnc_TM_PutawayFrom',	0,	0)
GO
if not exists(select 1 from rdt.RDTMsg where Message_ID = 896 and Message_Type = 'FNC' and Lang_Code = 'ENG')
   insert into rdt.RDTMsg(Message_ID,Lang_Code,Message_Type,Message_Text,StoredProcName,EventType)
   values(896,'ENG','FNC','Replenishment To Dynamic','rdtfnc_Replenish_V7',0)
IF EXISTS(select 1 from rdt.RDTMsg where Message_ID = 896 and Message_Type = 'FNC' and Lang_Code = 'ENG' AND StoredProcName <> 'rdtfnc_Replenish_V7')
   UPDATE rdt.RDTMsg SET StoredProcName = 'rdtfnc_Replenish_V7' where Message_ID = 896 and Message_Type = 'FNC' and Lang_Code = 'ENG'
GO
