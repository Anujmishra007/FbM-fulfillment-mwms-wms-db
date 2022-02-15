CREATE TABLE [PTL].[LightMode]
(
[LightModeNo] [int] NOT NULL,
[Description] [nvarchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_LightMode_Description] DEFAULT (' '),
[L1_Enabled] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_LightMode_L1_Enabled] DEFAULT ('Enabled'),
[L1_Status] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_LightMode_L1_Status] DEFAULT ('On'),
[L1_Color] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_LightMode_L1_Color] DEFAULT ('White'),
[L1_SEG] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_LightMode_L1_SEG] DEFAULT ('On'),
[L1_BUZ] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_LightMode_L1_BUZ] DEFAULT ('Flash'),
[L2_Enabled] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_LightMode_L2_Enabled] DEFAULT ('Disabled'),
[L2_Status] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_LightMode_L2_Status] DEFAULT ('On'),
[L2_Color] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_LightMode_L2_Color] DEFAULT ('White'),
[L2_SEG] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_LightMode_L2_SEG] DEFAULT ('On'),
[L2_BUZ] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_LightMode_L2_BUZ] DEFAULT ('Flash'),
[L3_Enabled] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_LightMode_L3_Enabled] DEFAULT ('Disabled'),
[L3_Status] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_LightMode_L3_Status] DEFAULT ('On'),
[L3_Color] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_LightMode_L3_Color] DEFAULT ('White'),
[L3_SEG] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_LightMode_L3_SEG] DEFAULT ('On'),
[L3_BUZ] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_LightMode_L3_BUZ] DEFAULT ('Flash'),
[L4_Enabled] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_LightMode_L4_Enabled] DEFAULT ('Disabled'),
[L4_FnKeyDecrement] [char] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_LightMode_L4_FnKeyDecrement] DEFAULT ('Use'),
[L4_FnKey] [char] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_LightMode_L4_FnKey] DEFAULT ('Use'),
[L4_ConfirmButton] [char] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_LightMode_L4_ConfirmButton] DEFAULT ('Use'),
[L5_Enabled] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_LightMode_L5_Enabled] DEFAULT ('Disabled'),
[L5_Status] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_LightMode_L5_Status] DEFAULT ('On'),
[L5_Color] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_LightMode_L5_Color] DEFAULT ('White'),
[L5_SEG] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_LightMode_L5_SEG] DEFAULT ('On'),
[L5_BUZ] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_LightMode_L5_BUZ] DEFAULT ('Flash'),
[ma_Enabled] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_LightMode_ma_Enabled] DEFAULT ('Disabled'),
[ma_qty_rvs] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_LightMode_ma_qty_rvs] DEFAULT ('Not used'),
[me_Enabled] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_LightMode_me_Enabled] DEFAULT ('Disabled'),
[me_app_timing] [varchar] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_LightMode_me_app_timing] DEFAULT ('0'),
[me_Digit1] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_LightMode_me_Digit1] DEFAULT ('0'),
[me_Digit2] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_LightMode_me_Digit2] DEFAULT ('0'),
[me_Digit3] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_LightMode_me_Digit3] DEFAULT ('0'),
[me_Digit4] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_LightMode_me_Digit4] DEFAULT ('0'),
[me_Digit5] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_LightMode_me_Digit5] DEFAULT ('0'),
[AddDate] [datetime] NULL CONSTRAINT [DF_LightMode_AddDate] DEFAULT (getdate()),
[AddWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_LightMode_AddWho] DEFAULT (suser_sname()),
[EditDate] [datetime] NULL CONSTRAINT [DF_LightMode_EditDate] DEFAULT (getdate()),
[EditWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_LightMode_EditWho] DEFAULT (suser_sname())
) ON [PRIMARY]
GO
ALTER TABLE [PTL].[LightMode] ADD CONSTRAINT [PK_LightMode] PRIMARY KEY CLUSTERED ([LightModeNo]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
GRANT DELETE ON  [PTL].[LightMode] TO [NSQL]
GO
GRANT INSERT ON  [PTL].[LightMode] TO [NSQL]
GO
GRANT SELECT ON  [PTL].[LightMode] TO [NSQL]
GO
GRANT UPDATE ON  [PTL].[LightMode] TO [NSQL]
GO
