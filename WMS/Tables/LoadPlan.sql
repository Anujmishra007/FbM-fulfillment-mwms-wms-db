CREATE TABLE [dbo].[LoadPlan]
(
[LoadKey] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[CaseCnt] [int] NULL CONSTRAINT [DF_LoadPlan_CaseCnt] DEFAULT ((0)),
[PalletCnt] [int] NULL CONSTRAINT [DF_LoadPlan_PalletCnt] DEFAULT ((0)),
[Weight] [float] NULL CONSTRAINT [DF_LoadPlan_Weight] DEFAULT ((0)),
[Cube] [float] NULL CONSTRAINT [DF_LoadPlan_Cube] DEFAULT ((0)),
[CustCnt] [int] NULL CONSTRAINT [DF_LoadPlan_CustCnt] DEFAULT ((0)),
[AddDate] [datetime] NULL CONSTRAINT [DF_LoadPlan_AddDate] DEFAULT (getdate()),
[AddWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_LoadPlan_AddWho] DEFAULT (suser_sname()),
[EditDate] [datetime] NULL CONSTRAINT [DF_LoadPlan_EditDate] DEFAULT (getdate()),
[EditWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_LoadPlan_EditWho] DEFAULT (suser_sname()),
[TrafficCop] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ArchiveCop] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Status] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_LoadPlan_Status] DEFAULT ('0'),
[TruckSize] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SuperOrderFlag] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SectionKey] [nvarchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CarrierKey] [nvarchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Route] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TrfRoom] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DummyRoute] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MBOLKey] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[OrderCnt] [int] NULL CONSTRAINT [DF_LoadPlan_OrderCnt] DEFAULT ((0)),
[facility] [nvarchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_LoadPlan_Facility] DEFAULT ('F1'),
[PROCESSFLAG] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_LoadPlan_ProcessFlag] DEFAULT ('N'),
[Return_Weight] [float] NULL CONSTRAINT [DF_LoadPlan_Return_Weight] DEFAULT ((0)),
[Return_Cube] [float] NULL CONSTRAINT [DF_LoadPlan_Return_Cube] DEFAULT ((0)),
[Vehicle_Type] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Driver] [nvarchar] (45) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Delivery_Zone] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Truck_Type] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Load_Userdef1] [nvarchar] (4000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Load_Userdef2] [nvarchar] (4000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[weightlimit] [float] NULL CONSTRAINT [DF_LoadPlan_weightlimit] DEFAULT ((0.0)),
[volumelimit] [float] NULL CONSTRAINT [DF_LoadPlan_volumelimit] DEFAULT ((0.0)),
[AllocatedCube] [float] NULL CONSTRAINT [DF_LoadPlan_AllocatedCube] DEFAULT ((0.0)),
[AllocatedWeight] [float] NULL CONSTRAINT [DF_LoadPlan_AllocatedWeight] DEFAULT ((0.0)),
[AllocatedCaseCnt] [int] NULL CONSTRAINT [DF_LoadPlan_AllocatedCaseCnt] DEFAULT ((0)),
[AllocatedPalletCnt] [int] NULL CONSTRAINT [DF_LoadPlan_AllocatedPalletCnt] DEFAULT ((0)),
[AllocatedOrderCnt] [int] NULL CONSTRAINT [DF_LoadPlan_AllocatedOrderCnt] DEFAULT ((0)),
[AllocatedCustCnt] [int] NULL CONSTRAINT [DF_LoadPlan_AllocatedCustCnt] DEFAULT ((0)),
[lpuserdefdate01] [datetime] NULL,
[FinalizeFlag] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_LoadPlan_FinalizeFlag] DEFAULT ('N'),
[UserDefine01] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_LOADPLAN_UserDefine01] DEFAULT (' '),
[UserDefine02] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_LOADPLAN_UserDefine02] DEFAULT (' '),
[UserDefine03] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_LOADPLAN_UserDefine03] DEFAULT (' '),
[UserDefine04] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_LOADPLAN_UserDefine04] DEFAULT (' '),
[UserDefine05] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_LOADPLAN_UserDefine05] DEFAULT (' '),
[UserDefine06] [datetime] NULL,
[UserDefine07] [datetime] NULL,
[UserDefine08] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_LOADPLAN_UserDefine08] DEFAULT ('N'),
[UserDefine09] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_LOADPLAN_UserDefine09] DEFAULT (' '),
[UserDefine10] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_LOADPLAN_UserDefine10] DEFAULT (' '),
[ExternLoadKey] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_LoadPlan_ExternLoadKey] DEFAULT (' '),
[CtnTyp1] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_Loadplan_CtnTyp1] DEFAULT ((0)),
[CtnTyp2] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_Loadplan_CtnTyp2] DEFAULT ((0)),
[CtnTyp3] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_Loadplan_CtnTyp3] DEFAULT ((0)),
[CtnTyp4] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_Loadplan_CtnTyp4] DEFAULT ((0)),
[CtnTyp5] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_Loadplan_CtnTyp5] DEFAULT ((0)),
[CtnCnt1] [int] NULL CONSTRAINT [DF_Loadplan_CtnCnt1] DEFAULT ((0)),
[CtnCnt2] [int] NULL CONSTRAINT [DF_Loadplan_CtnCnt2] DEFAULT ((0)),
[CtnCnt3] [int] NULL CONSTRAINT [DF_Loadplan_CtnCnt3] DEFAULT ((0)),
[CtnCnt4] [int] NULL CONSTRAINT [DF_Loadplan_CtnCnt4] DEFAULT ((0)),
[CtnCnt5] [int] NULL CONSTRAINT [DF_Loadplan_CtnCnt5] DEFAULT ((0)),
[TotCtnWeight] [float] NULL CONSTRAINT [DF_Loadplan_TotCtnWeight] DEFAULT ((0)),
[TotCtnCube] [float] NULL CONSTRAINT [DF_Loadplan_TotCtnCube] DEFAULT ((0)),
[CartonGroup] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_Loadplan_CartonGroup] DEFAULT (''),
[Priority] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_loadplan_Priority] DEFAULT ('9'),
[DispatchPalletPickMethod] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_LoadPlan_DispatchPalletPickMethod] DEFAULT ('1'),
[DispatchCasePickMethod] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_LoadPlan_DispatchCasePickMethod] DEFAULT ('1'),
[DispatchPiecePickMethod] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_LoadPlan_DispatchPiecePickMethod] DEFAULT ('1'),
[LoadPickMethod] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_LoadPlan_LoadPickMethod] DEFAULT (''),
[MBOLGroupMethod] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DefaultStrategykey] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[BookingNo] [int] NULL,
[OTM_DispatchDate] [datetime] NOT NULL CONSTRAINT [DF_LoadPlan_OTM_DispatchDate] DEFAULT ('')
) ON [PRIMARY]
GO

ALTER TABLE [dbo].[LoadPlan] WITH NOCHECK ADD CONSTRAINT [CK_LoadPlan_Loadkey_Numeric] CHECK ((isnumeric([Loadkey])=(1)))
GO
ALTER TABLE [dbo].[LoadPlan] ADD CONSTRAINT [PK_LoadPlan] PRIMARY KEY CLUSTERED ([LoadKey]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_LoadPlan_UserDefine10] ON [dbo].[LoadPlan] ([UserDefine10], [LoadKey]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
GRANT SELECT ON  [dbo].[LoadPlan] TO [JReportRole]
GO
GRANT DELETE ON  [dbo].[LoadPlan] TO [NSQL]
GO
GRANT INSERT ON  [dbo].[LoadPlan] TO [NSQL]
GO
GRANT SELECT ON  [dbo].[LoadPlan] TO [NSQL]
GO
GRANT UPDATE ON  [dbo].[LoadPlan] TO [NSQL]
GO
EXEC sp_addextendedproperty N'MS_Description', 'Load Plan Header consists of load details with reference to the load size, transporter information, route to be taken, truck size, allocation method', 'SCHEMA', N'dbo', 'TABLE', N'LoadPlan', NULL, NULL
GO
EXEC sp_addextendedproperty N'MS_Description', 'The date in which the load is created', 'SCHEMA', N'dbo', 'TABLE', N'LoadPlan', 'COLUMN', N'AddDate'
GO
EXEC sp_addextendedproperty N'MS_Description', 'The username/login ID added the information.', 'SCHEMA', N'dbo', 'TABLE', N'LoadPlan', 'COLUMN', N'AddWho'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Total allocated case count for the load', 'SCHEMA', N'dbo', 'TABLE', N'LoadPlan', 'COLUMN', N'AllocatedCaseCnt'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Total allocated cubic for the load', 'SCHEMA', N'dbo', 'TABLE', N'LoadPlan', 'COLUMN', N'AllocatedCube'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Total allocated customers for the load', 'SCHEMA', N'dbo', 'TABLE', N'LoadPlan', 'COLUMN', N'AllocatedCustCnt'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Total allocated orders for the load', 'SCHEMA', N'dbo', 'TABLE', N'LoadPlan', 'COLUMN', N'AllocatedOrderCnt'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Total allocated pallet count for the load', 'SCHEMA', N'dbo', 'TABLE', N'LoadPlan', 'COLUMN', N'AllocatedPalletCnt'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Total allocated weight for the load', 'SCHEMA', N'dbo', 'TABLE', N'LoadPlan', 'COLUMN', N'AllocatedWeight'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Transporter code. Vendor which performs the transportation', 'SCHEMA', N'dbo', 'TABLE', N'LoadPlan', 'COLUMN', N'CarrierKey'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Total case count for the load', 'SCHEMA', N'dbo', 'TABLE', N'LoadPlan', 'COLUMN', N'CaseCnt'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Total cubic count for the load', 'SCHEMA', N'dbo', 'TABLE', N'LoadPlan', 'COLUMN', N'Cube'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Total  orders count for the load', 'SCHEMA', N'dbo', 'TABLE', N'LoadPlan', 'COLUMN', N'CustCnt'
GO
EXEC sp_addextendedproperty N'MS_Description', 'An area where the goods for an order will be moved to before shipment', 'SCHEMA', N'dbo', 'TABLE', N'LoadPlan', 'COLUMN', N'Delivery_Zone'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Case Pick Task Dispatch Method', 'SCHEMA', N'dbo', 'TABLE', N'LoadPlan', 'COLUMN', N'DispatchCasePickMethod'
GO
EXEC sp_addextendedproperty N'MS_Description', 'dispatchpalletpickmethod', 'SCHEMA', N'dbo', 'TABLE', N'LoadPlan', 'COLUMN', N'DispatchPalletPickMethod'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Piece Pick Task Dispatch Method', 'SCHEMA', N'dbo', 'TABLE', N'LoadPlan', 'COLUMN', N'DispatchPiecePickMethod'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Free text - user notes', 'SCHEMA', N'dbo', 'TABLE', N'LoadPlan', 'COLUMN', N'Driver'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Not being used', 'SCHEMA', N'dbo', 'TABLE', N'LoadPlan', 'COLUMN', N'DummyRoute'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Date of the information edited/modified/updated. (System date)', 'SCHEMA', N'dbo', 'TABLE', N'LoadPlan', 'COLUMN', N'EditDate'
GO
EXEC sp_addextendedproperty N'MS_Description', 'The username/login ID edited/modified/updated the information.', 'SCHEMA', N'dbo', 'TABLE', N'LoadPlan', 'COLUMN', N'EditWho'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Load customer reference number', 'SCHEMA', N'dbo', 'TABLE', N'LoadPlan', 'COLUMN', N'ExternLoadKey'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Warehouse for the order to withdraw the stock', 'SCHEMA', N'dbo', 'TABLE', N'LoadPlan', 'COLUMN', N'facility'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Based on storer set-up. If configured, user will not be able to do other tasks after the load is finalized', 'SCHEMA', N'dbo', 'TABLE', N'LoadPlan', 'COLUMN', N'FinalizeFlag'
GO
EXEC sp_addextendedproperty N'MS_Description', 'User Defined #1:', 'SCHEMA', N'dbo', 'TABLE', N'LoadPlan', 'COLUMN', N'Load_Userdef1'
GO
EXEC sp_addextendedproperty N'MS_Description', 'User Defined #2:', 'SCHEMA', N'dbo', 'TABLE', N'LoadPlan', 'COLUMN', N'Load_Userdef2'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Load plan unique key. It''s used to identify a specific load plan record. Automatically generated.', 'SCHEMA', N'dbo', 'TABLE', N'LoadPlan', 'COLUMN', N'LoadKey'
GO
EXEC sp_addextendedproperty N'MS_Description', 'It consists of Consolidate & Discrete pick method', 'SCHEMA', N'dbo', 'TABLE', N'LoadPlan', 'COLUMN', N'LoadPickMethod'
GO
EXEC sp_addextendedproperty N'MS_Description', 'The MBOL unique key', 'SCHEMA', N'dbo', 'TABLE', N'LoadPlan', 'COLUMN', N'MBOLKey'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Total orders count for the load', 'SCHEMA', N'dbo', 'TABLE', N'LoadPlan', 'COLUMN', N'OrderCnt'
GO
EXEC sp_addextendedproperty N'MS_Description', N'OTM Dispatch Date', 'SCHEMA', N'dbo', 'TABLE', N'LoadPlan', 'COLUMN', N'OTM_DispatchDate'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Total pallet count for the load', 'SCHEMA', N'dbo', 'TABLE', N'LoadPlan', 'COLUMN', N'PalletCnt'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Release the tasks to RF', 'SCHEMA', N'dbo', 'TABLE', N'LoadPlan', 'COLUMN', N'PROCESSFLAG'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Expected cubic - to be collected', 'SCHEMA', N'dbo', 'TABLE', N'LoadPlan', 'COLUMN', N'Return_Cube'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Expected weight - to be collected', 'SCHEMA', N'dbo', 'TABLE', N'LoadPlan', 'COLUMN', N'Return_Weight'
GO
EXEC sp_addextendedproperty N'MS_Description', 'The route in which the load will be delivered to', 'SCHEMA', N'dbo', 'TABLE', N'LoadPlan', 'COLUMN', N'Route'
GO
EXEC sp_addextendedproperty N'MS_Description', 'The name of the section in the warehouse.', 'SCHEMA', N'dbo', 'TABLE', N'LoadPlan', 'COLUMN', N'SectionKey'
GO
EXEC sp_addextendedproperty N'MS_Description', 'The stauts of loadplan progress : Fully Allocated, Pick in progress, Pick slip printed, Picked, Checked, Closed', 'SCHEMA', N'dbo', 'TABLE', N'LoadPlan', 'COLUMN', N'Status'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Flag to indicate whether the orders in the load will be batched for allocation processing i.e. all orders will be consolidated and pick by items', 'SCHEMA', N'dbo', 'TABLE', N'LoadPlan', 'COLUMN', N'SuperOrderFlag'
GO
EXEC sp_addextendedproperty N'MS_Description', 'When checked, fields updated in this table will not trigger to update other tables that are linked with this table.', 'SCHEMA', N'dbo', 'TABLE', N'LoadPlan', 'COLUMN', N'TrafficCop'
GO
EXEC sp_addextendedproperty N'MS_Description', 'A room reference or room number where the goods will be transferred to before truck loading', 'SCHEMA', N'dbo', 'TABLE', N'LoadPlan', 'COLUMN', N'TrfRoom'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Truck Type will be ordered for the load', 'SCHEMA', N'dbo', 'TABLE', N'LoadPlan', 'COLUMN', N'Truck_Type'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Truck Size', 'SCHEMA', N'dbo', 'TABLE', N'LoadPlan', 'COLUMN', N'TruckSize'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Vehicle Type', 'SCHEMA', N'dbo', 'TABLE', N'LoadPlan', 'COLUMN', N'Vehicle_Type'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Maximum volume for the load - calculated in batch planning only', 'SCHEMA', N'dbo', 'TABLE', N'LoadPlan', 'COLUMN', N'volumelimit'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Total weight count for the load', 'SCHEMA', N'dbo', 'TABLE', N'LoadPlan', 'COLUMN', N'Weight'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Maximum weight for the load - calculated in batch planning only', 'SCHEMA', N'dbo', 'TABLE', N'LoadPlan', 'COLUMN', N'weightlimit'
GO
