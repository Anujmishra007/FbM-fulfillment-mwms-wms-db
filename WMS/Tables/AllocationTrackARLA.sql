SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[AllocationTrackARLA]') AND type in (N'U'))
BEGIN

CREATE TABLE [dbo].[AllocationTrackARLA](
    [Storerkey] [nvarchar](15) NOT NULL  CONSTRAINT  DF_AllocationTrackARLA_StorerKey DEFAULT (''),
    [ConsigneeKey] [nvarchar](15) NOT NULL CONSTRAINT  DF_AllocationTrackARLA_ConsigneeKey DEFAULT (''), 
    [Sku] [nvarchar](20) NOT NULL CONSTRAINT  DF_AllocationTrackARLA_Sku DEFAULT (''),
    [LastBestBeforeDate] [datetime] NOT NULL CONSTRAINT  DF_AllocationTrackARLA_LastBestBeforeDate DEFAULT (getdate()),
 CONSTRAINT [PK_AllocationTrackARLA] PRIMARY KEY CLUSTERED
(
    [Storerkey] ASC,
    [ConsigneeKey] ASC,
    [Sku] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
END
GO

GRANT SELECT ON [dbo].[AllocationTrackARLA] TO [NSQL]
GO
GRANT INSERT ON [dbo].[AllocationTrackARLA] TO [NSQL]
GO
GRANT UPDATE ON [dbo].[AllocationTrackARLA] TO [NSQL]
GO
GRANT DELETE ON [dbo].[AllocationTrackARLA] TO [NSQL]
GO