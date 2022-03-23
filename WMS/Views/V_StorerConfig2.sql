SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

CREATE OR ALTER VIEW [dbo].[V_StorerConfig2]
as Select storerconfig.storerkey, storerconfig.ConfigKey,  Max(Svalue) as Svalue
FROM dbo.storerconfig storerconfig with (NOLOCK)
group by storerconfig.storerkey, storerconfig.ConfigKey


GO
GRANT DELETE ON  [dbo].[V_StorerConfig2] TO [NSQL]
GO
GRANT INSERT ON  [dbo].[V_StorerConfig2] TO [NSQL]
GO
GRANT SELECT ON  [dbo].[V_StorerConfig2] TO [NSQL]
GO
GRANT UPDATE ON  [dbo].[V_StorerConfig2] TO [NSQL]
GO
