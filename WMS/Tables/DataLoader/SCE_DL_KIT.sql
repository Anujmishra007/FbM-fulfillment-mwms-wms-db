SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*********************************************************************************/
/* Date         Author    Ver.  Purposes                                         */
/* 2026-09-08   Michael   1.1   FCR-15590 - Add new fields (ML01)                */
/*********************************************************************************/
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[SCE_DL_KIT]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[SCE_DL_KIT](
	[RowRefNo] [bigint] IDENTITY(1,1) NOT NULL,
	[Storerkey] [nvarchar](15) NULL,
	[ToStorerkey] [nvarchar](15) NULL,
	[HType] [nvarchar](12) NULL,
	[EffectiveDate] [datetime] NULL,
	[ReasonCode] [nvarchar](10) NULL,
	[CustomerRefNo] [nvarchar](10) NULL,
	[Remarks] [nvarchar](200) NULL,
	[Facility] [nvarchar](5) NULL,
	[HUdef01] [nvarchar](18) NULL,
	[HUdef02] [nvarchar](18) NULL,
	[HUdef03] [nvarchar](18) NULL,
	[ExternKitKey] [nvarchar](20) NULL,
	[DType] [nvarchar](5) NULL,
	[SKU] [nvarchar](20) NULL,
	[Lot] [nvarchar](10) NULL,
	[Loc] [nvarchar](10) NULL,
	[ID] [nvarchar](18) NULL,
	[ExpectedQty] [int] NULL,
	[ExternLineNo] [nvarchar](10) NULL,
	[LOTTABLE01]   [nvarchar](18) NULL,
	[LOTTABLE02]   [nvarchar](18) NULL,
	[LOTTABLE03]   [nvarchar](18) NULL,
	[LOTTABLE04]   [datetime]     NULL,
	[LOTTABLE05]   [datetime]     NULL,
	[LOTTABLE06]   [nvarchar](30) NULL,
	[LOTTABLE07]   [nvarchar](30) NULL,
	[LOTTABLE08]   [nvarchar](30) NULL,
	[LOTTABLE09]   [nvarchar](30) NULL,
	[LOTTABLE10]   [nvarchar](30) NULL,
	[LOTTABLE11]   [nvarchar](30) NULL,
	[LOTTABLE12]   [nvarchar](30) NULL,
	[LOTTABLE13]   [datetime]     NULL,
	[LOTTABLE14]   [datetime]     NULL,
	[LOTTABLE15]   [datetime]     NULL,
	[AddWho]       [nvarchar](128) NOT NULL,
	[AddDate]      [datetime] NOT NULL,
	[Qty]          [int]          NULL,
	[HUdef04]      [nvarchar](30) NULL,
	[HUdef05]      [nvarchar](30) NULL,
	[HUdef06]      [datetime]     NULL,
	[HUdef07]      [datetime]     NULL,
	[HUdef08]      [nvarchar](30) NULL,
	[HUdef09]      [nvarchar](30) NULL,
   --ML01-S       
   [HUdef10]      [nvarchar](30) NULL,
   [HUdef11]      [nvarchar](30) NULL,
   [HUdef12]      [nvarchar](30) NULL,
   [HUdef13]      [nvarchar](30) NULL,
   [HUdef14]      [datetime]     NULL,
   [HUdef15]      [datetime]     NULL,
   [ExternStatus] [nvarchar](30) NULL,
   [GenerateHOCharges]    [nvarchar](10) NULL,
   [GenerateIS_HiCharges] [nvarchar](10) NULL,
   [Channel]      [nvarchar](20) NULL,
   [Channel_ID]   [bigint]       NULL,
   [PalletType]   [nvarchar](10) NULL,
   --ML01-E
 CONSTRAINT [PK_SCE_DL_KIT] PRIMARY KEY CLUSTERED 
(
	[RowRefNo] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
 

IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[DF_SCE_DL_KIT_AddDate]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[SCE_DL_KIT] ADD  CONSTRAINT [DF_SCE_DL_KIT_AddDate]  DEFAULT (getdate()) FOR [AddDate]
END

IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[DF_SCE_DL_KIT_HUdef04]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[SCE_DL_KIT] ADD  CONSTRAINT [DF_SCE_DL_KIT_HUdef04]  DEFAULT ('') FOR [HUdef04]
END
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[DF_SCE_DL_KIT_HUdef05]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[SCE_DL_KIT] ADD  CONSTRAINT [DF_SCE_DL_KIT_HUdef05]  DEFAULT ('') FOR [HUdef05]
END
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[DF_SCE_DL_KIT_HUdef08]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[SCE_DL_KIT] ADD  CONSTRAINT [DF_SCE_DL_KIT_HUdef08]  DEFAULT ('') FOR [HUdef08]
END
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[DF_SCE_DL_KIT_HUdef09]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[SCE_DL_KIT] ADD  CONSTRAINT [DF_SCE_DL_KIT_HUdef09]  DEFAULT ('') FOR [HUdef09]
END
    --ML01-S
    IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[DF_SCE_DL_KIT_HUdef10]') AND type = 'D')
    BEGIN
        ALTER TABLE [dbo].[SCE_DL_KIT] ADD  CONSTRAINT [DF_SCE_DL_KIT_HUdef10]  DEFAULT ('') FOR [HUdef10]
    END
    IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[DF_SCE_DL_KIT_HUdef11]') AND type = 'D')
    BEGIN
        ALTER TABLE [dbo].[SCE_DL_KIT] ADD  CONSTRAINT [DF_SCE_DL_KIT_HUdef11]  DEFAULT ('') FOR [HUdef11]
    END
    IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[DF_SCE_DL_KIT_HUdef12]') AND type = 'D')
    BEGIN
        ALTER TABLE [dbo].[SCE_DL_KIT] ADD  CONSTRAINT [DF_SCE_DL_KIT_HUdef12]  DEFAULT ('') FOR [HUdef12]
    END
    IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[DF_SCE_DL_KIT_HUdef13]') AND type = 'D')
    BEGIN
        ALTER TABLE [dbo].[SCE_DL_KIT] ADD  CONSTRAINT [DF_SCE_DL_KIT_HUdef13]  DEFAULT ('') FOR [HUdef13]
    END
    IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[DF_SCE_DL_KIT_ExternStatus]') AND type = 'D')
    BEGIN
        ALTER TABLE [dbo].[SCE_DL_KIT] ADD  CONSTRAINT [DF_SCE_DL_KIT_ExternStatus]  DEFAULT ('') FOR [ExternStatus]
    END
    IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[DF_SCE_DL_KIT_Channel]') AND type = 'D')
    BEGIN
        ALTER TABLE [dbo].[SCE_DL_KIT] ADD  CONSTRAINT [DF_SCE_DL_KIT_Channel]  DEFAULT ('') FOR [Channel]
    END
    IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[DF_SCE_DL_KIT_Channel_ID]') AND type = 'D')
    BEGIN
        ALTER TABLE [dbo].[SCE_DL_KIT] ADD  CONSTRAINT [DF_SCE_DL_KIT_Channel_ID]  DEFAULT ('') FOR [Channel_ID]
    END
    IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[DF_SCE_DL_KIT_PalletType]') AND type = 'D')
    BEGIN
        ALTER TABLE [dbo].[SCE_DL_KIT] ADD  CONSTRAINT [DF_SCE_DL_KIT_PalletType]  DEFAULT ('') FOR [PalletType]
    END
    --ML01-E
END
ELSE
BEGIN

    IF NOT EXISTS (SELECT 1
                   FROM sys.columns
                   WHERE Name = 'HUdef04' AND Object_ID = Object_ID('SCE_DL_KIT'))
    BEGIN
        ALTER TABLE SCE_DL_KIT ADD HUdef04 NVARCHAR(30)  NULL CONSTRAINT [DF_SCE_DL_KIT_HUdef04]  DEFAULT ('');
    END
    IF NOT EXISTS (SELECT 1
                   FROM sys.columns
                   WHERE Name = 'HUdef05' AND Object_ID = Object_ID('SCE_DL_KIT'))
    BEGIN
        ALTER TABLE SCE_DL_KIT ADD HUdef05 NVARCHAR(30)  NULL CONSTRAINT [DF_SCE_DL_KIT_HUdef05]  DEFAULT ('');
    END

    IF NOT EXISTS (SELECT 1
                   FROM sys.columns
                   WHERE Name = 'HUdef06' AND Object_ID = Object_ID('SCE_DL_KIT'))
    BEGIN
        ALTER TABLE SCE_DL_KIT ADD HUdef06	datetime	  NULL  
    END
    IF NOT EXISTS (SELECT 1
                   FROM sys.columns
                   WHERE Name = 'HUdef07' AND Object_ID = Object_ID('SCE_DL_KIT'))
    BEGIN
        ALTER TABLE SCE_DL_KIT ADD HUdef07	datetime	  NULL  
    END
        
        
    IF NOT EXISTS (SELECT 1
                   FROM sys.columns
                   WHERE Name = 'HUdef08' AND Object_ID = Object_ID('SCE_DL_KIT'))
    BEGIN
        ALTER TABLE SCE_DL_KIT ADD HUdef08 NVARCHAR(30)  NULL CONSTRAINT [DF_SCE_DL_KIT_HUdef08]  DEFAULT ('');
    END  
    IF NOT EXISTS (SELECT 1
                   FROM sys.columns
                   WHERE Name = 'HUdef09' AND Object_ID = Object_ID('SCE_DL_KIT'))
    BEGIN
        ALTER TABLE SCE_DL_KIT ADD HUdef09 NVARCHAR(30)  NULL CONSTRAINT [DF_SCE_DL_KIT_HUdef09]  DEFAULT ('');
    END              	

    --ML01-S
    IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE Name = 'HUdef10' AND Object_ID = Object_ID('SCE_DL_KIT'))
    BEGIN
        ALTER TABLE SCE_DL_KIT ADD HUdef10 NVARCHAR(30)  NULL CONSTRAINT [DF_SCE_DL_KIT_HUdef10]  DEFAULT ('');
    END
    IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE Name = 'HUdef11' AND Object_ID = Object_ID('SCE_DL_KIT'))
    BEGIN
        ALTER TABLE SCE_DL_KIT ADD HUdef11 NVARCHAR(30)  NULL CONSTRAINT [DF_SCE_DL_KIT_HUdef11]  DEFAULT ('');
    END
    IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE Name = 'HUdef12' AND Object_ID = Object_ID('SCE_DL_KIT'))
    BEGIN
        ALTER TABLE SCE_DL_KIT ADD HUdef12 NVARCHAR(30)  NULL CONSTRAINT [DF_SCE_DL_KIT_HUdef12]  DEFAULT ('');
    END
    IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE Name = 'HUdef13' AND Object_ID = Object_ID('SCE_DL_KIT'))
    BEGIN
        ALTER TABLE SCE_DL_KIT ADD HUdef13 NVARCHAR(30)  NULL CONSTRAINT [DF_SCE_DL_KIT_HUdef13]  DEFAULT ('');
    END
    IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE Name = 'HUdef14' AND Object_ID = Object_ID('SCE_DL_KIT'))
    BEGIN
        ALTER TABLE SCE_DL_KIT ADD HUdef14 datetime NULL;
    END
    IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE Name = 'HUdef15' AND Object_ID = Object_ID('SCE_DL_KIT'))
    BEGIN
        ALTER TABLE SCE_DL_KIT ADD HUdef15 datetime NULL;
    END
    IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE Name = 'ExternStatus' AND Object_ID = Object_ID('SCE_DL_KIT'))
    BEGIN
        ALTER TABLE SCE_DL_KIT ADD ExternStatus NVARCHAR(30)  NULL CONSTRAINT [DF_SCE_DL_KIT_ExternStatus]  DEFAULT ('');
    END
    IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE Name = 'GenerateHOCharges' AND Object_ID = Object_ID('SCE_DL_KIT'))
    BEGIN
        ALTER TABLE SCE_DL_KIT ADD GenerateHOCharges NVARCHAR(10) NULL;
    END
    IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE Name = 'GenerateIS_HiCharges' AND Object_ID = Object_ID('SCE_DL_KIT'))
    BEGIN
        ALTER TABLE SCE_DL_KIT ADD GenerateIS_HiCharges NVARCHAR(10) NULL;
    END
    IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE Name = 'Channel' AND Object_ID = Object_ID('SCE_DL_KIT'))
    BEGIN
        ALTER TABLE SCE_DL_KIT ADD Channel NVARCHAR(20)  NULL CONSTRAINT [DF_SCE_DL_KIT_Channel]  DEFAULT ('');
    END
    IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE Name = 'Channel_ID' AND Object_ID = Object_ID('SCE_DL_KIT'))
    BEGIN
        ALTER TABLE SCE_DL_KIT ADD Channel_ID BIGINT NULL CONSTRAINT [DF_SCE_DL_KIT_Channel_ID]  DEFAULT (0);
    END
    IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE Name = 'PalletType' AND Object_ID = Object_ID('SCE_DL_KIT'))
    BEGIN
        ALTER TABLE SCE_DL_KIT ADD PalletType NVARCHAR(10)  NULL CONSTRAINT [DF_SCE_DL_KIT_PalletType]  DEFAULT ('');
    END
    --ML01-E
END
