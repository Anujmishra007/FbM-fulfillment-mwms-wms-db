SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

CREATE OR ALTER VIEW [dbo].[V_IDS_CODE_001]
as
	select upper(listname) as 'cd_listname',
				upper(code) as 'cd_code',
				description as 'cd_description',
				short as 'cd_short',
				long as 'cd_long',
				replace(rtrim(convert(NVARCHAR(255), notes)), char(13), '') as 'cd_notes',
				replace(rtrim(convert(NVARCHAR(255), notes2)), char(13), '') as 'cd_notes2'
	from codelkup (nolock)




GO
GRANT DELETE ON  [dbo].[V_IDS_CODE_001] TO [NSQL]
GO
GRANT INSERT ON  [dbo].[V_IDS_CODE_001] TO [NSQL]
GO
GRANT SELECT ON  [dbo].[V_IDS_CODE_001] TO [NSQL]
GO
GRANT UPDATE ON  [dbo].[V_IDS_CODE_001] TO [NSQL]
GO
