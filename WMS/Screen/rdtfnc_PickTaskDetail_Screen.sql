IF	NOT EXISTS(	SELECT 1	FROM RDT.RDTMsg (NOLOCK) WHERE Message_ID	= 836 AND Lang_Code = 'ENG' AND Message_Type	= 'FNC')
	INSERT INTO	RDT.RDTMsg (Message_ID,	Lang_Code, Message_Type, Message_Text,	StoredProcName, Eventtype)
	VALUES (836, 'ENG', 'FNC',	'Pick	By	TaskDetail', 'rdtfnc_PickTaskDetail', '0')
GO

DELETE rdt.RDTScn	WHERE	Scn =	5160 AND	Lang_Code =	'ENG'
EXECUTE rdt.rdtAddScn 5160, 'ENG'
	,@cLine01 =	'USER	ID:'
	,@cLine02 =	'%18i01'
	,@cLine03 =	'AREA	KEY:'
	,@cLine04 =	'%10i02'
	,@cLine05 =	'TASK	TYPE:'
	,@cLine06 =	'%10i03'
	,@cLine07 =	'CART ID:'
	,@cLine08 =	'%10i04'
	,@cLine14 =	'%e'
	,@nFunc = 836

DELETE rdt.RDTScn	WHERE	Scn =	5161 AND	Lang_Code =	'ENG'
EXECUTE rdt.rdtAddScn 5161, 'ENG'
	,@cLine01 =	'AREA	KEY: %10d01'
	,@cLine02 =	'TASK	TYPE:	%10d02'
	,@cLine03 =	''
	,@cLine04 =	'OPEN	TASK:	%10d03'
	,@cLine05 =	''
	,@cLine06 =	'1	= PRINT TASK LABEL'
	,@cLine07 =	'OPTION:	%01i04' 
	,@cLine14 =	'%e'
	,@nFunc = 836

DELETE rdt.RDTScn	WHERE	Scn =	5162 AND	Lang_Code =	'ENG'
EXECUTE rdt.rdtAddScn 5162, 'ENG'
	,@cLine01 =	'AREA	KEY: %10d01'
	,@cLine02 =	'TASK	TYPE:	%10d02'
	,@cLine03 =	''
	,@cLine04 =	'OPEN	TASK:	%05d03'
	,@cLine05 =	'GET	TASK:	%05d04'
	,@cLine14 =	'%e'
	,@nFunc = 836