CREATE TABLE [dbo].[PutawayStrategyDetail]
(
[PutawayStrategyKey] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[PutawayStrategyLineNumber] [nvarchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[PAType] [nvarchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_PutawayStrategyDetail_PAType] DEFAULT (' '),
[FROMLOC] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_PutawayStrategyDetail_FROMLOC] DEFAULT (' '),
[TOLOC] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_PutawayStrategyDetail_TOLOC] DEFAULT (' '),
[AreaKey] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_PutawayStrategyDetail_AreaKey] DEFAULT (' '),
[Zone] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_PutawayStrategyDetail_Zone] DEFAULT (' '),
[LocType] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_PutawayStrategyDetail_LocType] DEFAULT (' '),
[LocSearchType] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_PutawayStrategyDetail_LocSearchType] DEFAULT ('1'),
[DimensionRestriction01] [nvarchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_PutawayStrategyDetail_DimensionRestriction01] DEFAULT ('0'),
[DimensionRestriction02] [nvarchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_PutawayStrategyDetail_DimensionRestriction02] DEFAULT ('0'),
[DimensionRestriction03] [nvarchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_PutawayStrategyDetail_DimensionRestriction03] DEFAULT ('0'),
[DimensionRestriction04] [nvarchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_PutawayStrategyDetail_DimensionRestriction04] DEFAULT ('0'),
[DimensionRestriction05] [nvarchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_PutawayStrategyDetail_DimensionRestriction05] DEFAULT ('0'),
[DimensionRestriction06] [nvarchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_PutawayStrategyDetail_DimensionRestriction06] DEFAULT ('0'),
[LocationTypeExclude01] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_PutawayStrategyDetail_LocationTypeExclude01] DEFAULT (' '),
[LocationTypeExclude02] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_PutawayStrategyDetail_LocationTypeExclude02] DEFAULT (' '),
[LocationTypeExclude03] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_PutawayStrategyDetail_LocationTypeExclude03] DEFAULT (' '),
[LocationTypeExclude04] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_PutawayStrategyDetail_LocationTypeExclude04] DEFAULT (' '),
[LocationTypeExclude05] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_PutawayStrategyDetail_LocationTypeExclude05] DEFAULT (' '),
[LocationFlagExclude01] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_PutawayStrategyDetail_LocationFlagExclude01] DEFAULT (' '),
[LocationFlagExclude02] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_PutawayStrategyDetail_LocationFlagExclude02] DEFAULT (' '),
[LocationFlagExclude03] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_PutawayStrategyDetail_LocationFlagExclude03] DEFAULT (' '),
[LocationFlagInclude01] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_PutawayStrategyDetail_LocationFlagInclude01] DEFAULT (' '),
[LocationFlagInclude02] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_PutawayStrategyDetail_LocationFlagInclude02] DEFAULT (' '),
[LocationFlagInclude03] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_PutawayStrategyDetail_LocationFlagInclude03] DEFAULT (' '),
[LocationHandlingExclude01] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_PutawayStrategyDetail_LocationHandlingExclude01] DEFAULT (' '),
[LocationHandlingExclude02] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_PutawayStrategyDetail_LocationHandlingExclude02] DEFAULT (' '),
[LocationHandlingExclude03] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_PutawayStrategyDetail_LocationHandlingExclude03] DEFAULT (' '),
[LocationHandlingInclude01] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_PutawayStrategyDetail_LocationHandlingInclude01] DEFAULT (' '),
[LocationHandlingInclude02] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_PutawayStrategyDetail_LocationHandlingInclude02] DEFAULT (' '),
[LocationHandlingInclude03] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_PutawayStrategyDetail_LocationHandlingInclude03] DEFAULT (' '),
[LocationCategoryInclude01] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_PutawayStrategyDetail_LocationCategoryInclude01] DEFAULT (' '),
[LocationCategoryInclude02] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_PutawayStrategyDetail_LocationCategoryInclude02] DEFAULT (' '),
[LocationCategoryInclude03] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_PutawayStrategyDetail_LocationCategoryInclude03] DEFAULT (' '),
[LocationCategoryExclude01] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_PutawayStrategyDetail_LocationCategoryExclude01] DEFAULT (' '),
[LocationCategoryExclude02] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_PutawayStrategyDetail_LocationCategoryExclude02] DEFAULT (' '),
[LocationCategoryExclude03] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_PutawayStrategyDetail_LocationCategoryExclude03] DEFAULT (' '),
[AreaTypeExclude01] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_PutawayStrategyDetail_AreaTypeExclude01] DEFAULT (' '),
[AreaTypeExclude02] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_PutawayStrategyDetail_AreaTypeExclude02] DEFAULT (' '),
[AreaTypeExclude03] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_PutawayStrategyDetail_AreaTypeExclude03] DEFAULT (' '),
[LocationTypeRestriction01] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_PutawayStrategyDetail_LocationTypeRestriction01] DEFAULT (' '),
[LocationTypeRestriction02] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_PutawayStrategyDetail_LocationTypeRestriction02] DEFAULT (' '),
[LocationTypeRestriction03] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_PutawayStrategyDetail_LocationTypeRestriction03] DEFAULT (' '),
[FitFullReceipt] [nvarchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_PutawayStrategyDetail_FitFullReceipt] DEFAULT ('N'),
[OrderType] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_PutawayStrategyDetail_OrderType] DEFAULT (' '),
[NumberofDaysOffSet] [int] NOT NULL CONSTRAINT [DF_PutawayStrategyDetail_NumberofDaysOffSet] DEFAULT ((0)),
[LocationStateRestriction01] [nvarchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_PutawayStrategyDetail_LocationStateRestriction01] DEFAULT ('0'),
[LocationStateRestriction02] [nvarchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_PutawayStrategyDetail_LocationStateRestriction02] DEFAULT ('0'),
[LocationStateRestriction03] [nvarchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_PutawayStrategyDetail_LocationStateRestriction03] DEFAULT ('0'),
[AllowFullPallets] [nvarchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_PutawayStrategyDetail_AllowFullPallets] DEFAULT ('Y'),
[AllowFullCases] [nvarchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_PutawayStrategyDetail_AllowFullCases] DEFAULT ('Y'),
[AllowPieces] [nvarchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_PutawayStrategyDetail_AllowPieces] DEFAULT ('Y'),
[CheckEquipmentProfileKey] [nvarchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_PutawayStrategyDetail_CheckEquipmentProfileKey] DEFAULT ('N'),
[CheckRestrictions] [nvarchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_PutawayStrategyDetail_CheckRestrictions] DEFAULT ('Y'),
[AddDate] [datetime] NOT NULL CONSTRAINT [DF_PutawayStrategyDetail_AddDate] DEFAULT (getdate()),
[AddWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_PutawayStrategyDetail_AddWho] DEFAULT (suser_sname()),
[EditDate] [datetime] NOT NULL CONSTRAINT [DF_PutawayStrategyDetail_EditDate] DEFAULT (getdate()),
[EditWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_PutawayStrategyDetail_EditWho] DEFAULT (suser_sname()),
[TrafficCop] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ArchiveCop] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Timestamp] [timestamp] NOT NULL,
[LocLevelInclude01] [int] NOT NULL CONSTRAINT [DF_PutawayStrategyDetail_LocLevelInclude01] DEFAULT ((0)),
[LocLevelInclude02] [int] NOT NULL CONSTRAINT [DF_PutawayStrategyDetail_LocLevelInclude02] DEFAULT ((0)),
[LocLevelInclude03] [int] NOT NULL CONSTRAINT [DF_PutawayStrategyDetail_LocLevelInclude03] DEFAULT ((0)),
[LocLevelInclude04] [int] NOT NULL CONSTRAINT [DF_PutawayStrategyDetail_LocLevelInclude04] DEFAULT ((0)),
[LocLevelInclude05] [int] NOT NULL CONSTRAINT [DF_PutawayStrategyDetail_LocLevelInclude05] DEFAULT ((0)),
[LocLevelInclude06] [int] NOT NULL CONSTRAINT [DF_PutawayStrategyDetail_LocLevelInclude06] DEFAULT ((0)),
[LocLevelExclude01] [int] NOT NULL CONSTRAINT [DF_PutawayStrategyDetail_LocLevelExclude01] DEFAULT ((0)),
[LocLevelExclude02] [int] NOT NULL CONSTRAINT [DF_PutawayStrategyDetail_LocLevelExclude02] DEFAULT ((0)),
[LocLevelExclude03] [int] NOT NULL CONSTRAINT [DF_PutawayStrategyDetail_LocLevelExclude03] DEFAULT ((0)),
[LocLevelExclude04] [int] NOT NULL CONSTRAINT [DF_PutawayStrategyDetail_LocLevelExclude04] DEFAULT ((0)),
[LocLevelExclude05] [int] NOT NULL CONSTRAINT [DF_PutawayStrategyDetail_LocLevelExclude05] DEFAULT ((0)),
[LocLevelExclude06] [int] NOT NULL CONSTRAINT [DF_PutawayStrategyDetail_LocLevelExclude06] DEFAULT ((0)),
[LocAisleInclude01] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_PutawayStrategyDetail_LocAisleInclude01] DEFAULT (''),
[LocAisleInclude02] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_PutawayStrategyDetail_LocAisleInclude02] DEFAULT (''),
[LocAisleInclude03] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_PutawayStrategyDetail_LocAisleInclude03] DEFAULT (''),
[LocAisleInclude04] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_PutawayStrategyDetail_LocAisleInclude04] DEFAULT (''),
[LocAisleInclude05] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_PutawayStrategyDetail_LocAisleInclude05] DEFAULT (''),
[LocAisleInclude06] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_PutawayStrategyDetail_LocAisleInclude06] DEFAULT (''),
[LocAisleExclude01] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_PutawayStrategyDetail_LocAisleExclude01] DEFAULT (''),
[LocAisleExclude02] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_PutawayStrategyDetail_LocAisleExclude02] DEFAULT (''),
[LocAisleExclude03] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_PutawayStrategyDetail_LocAisleExclude03] DEFAULT (''),
[LocAisleExclude04] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_PutawayStrategyDetail_LocAisleExclude04] DEFAULT (''),
[LocAisleExclude05] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_PutawayStrategyDetail_LocAisleExclude05] DEFAULT (''),
[LocAisleExclude06] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_PutawayStrategyDetail_LocAisleExclude06] DEFAULT (''),
[PutawayZone01] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_PutawayStrategyDetail_PutawayZone01] DEFAULT (''),
[PutawayZone02] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_PutawayStrategyDetail_PutawayZone02] DEFAULT (''),
[PutawayZone03] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_PutawayStrategyDetail_PutawayZone03] DEFAULT (''),
[PutawayZone04] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_PutawayStrategyDetail_PutawayZone04] DEFAULT (''),
[PutawayZone05] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_PutawayStrategyDetail_PutawayZone05] DEFAULT (''),
[PutCode] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_PutawayStrategyDetail_PutCode] DEFAULT (' ')
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO

/************************************************************************/  
/* Trigger: ntrPutawayStrategyDetailUpdate                              */  
/* Creation Date:  09-Sept-2008                                         */  
/* Copyright: IDS                                                       */  
/* Written by:  TLTING                                                  */  
/*                                                                      */  
/* Purpose: PutawayStrategyDetail Update                                */  
/*                                                                      */  
/* Input Parameters:                                                    */  
/*                                                                      */  
/* Output Parameters:                                                   */  
/*                                                                      */  
/* Return Status:                                                       */  
/*                                                                      */  
/* Usage:                                                               */  
/*                                                                      */  
/* Local Variables:                                                     */  
/*                                                                      */  
/* Called By: When records updated                                      */  
/*                                                                      */  
/* PVCS Version: 1.5                                                    */  
/*                                                                      */  
/* Version: 5.4                                                         */  
/*                                                                      */  
/* Data Modifications:                                                  */  
/*                                                                      */  
/* Updates:                                                             */  
/* Date         Author   Ver  Purposes                                  */  
/************************************************************************/  
  
CREATE TRIGGER [dbo].[ntrPutawayStrategyDetailUpdate]  
ON [dbo].[PutawayStrategyDetail]  
FOR UPDATE  
AS   
BEGIN  
IF @@ROWCOUNT = 0  
BEGIN  
   RETURN  
END     
   SET NOCOUNT ON  
   SET ANSI_NULLS OFF  
   SET QUOTED_IDENTIFIER OFF  
 SET CONCAT_NULL_YIELDS_NULL OFF  
   
 DECLARE @n_err                int       -- Error number returned by stored procedure or this trigger  
 ,         @c_errmsg             NVARCHAR(250) -- Error message returned by stored procedure or this trigger  
 ,         @n_continue int                   
 ,         @n_starttcnt int                -- Holds the current transaction count  
 ,         @n_cnt int                    
   
 SELECT @n_continue=1, @n_starttcnt=@@TRANCOUNT  
  
   IF UPDATE(ArchiveCop)  
   BEGIN  
    SELECT @n_continue = 4   
   END  
     
   -- TLTING01  
 IF ( @n_continue = 1 or @n_continue=2 ) AND NOT UPDATE(EditDate)  
 BEGIN  
  UPDATE PutawayStrategyDetail WITH (ROWLOCK)  
  SET EditDate = GETDATE(),  
      EditWho  = SUSER_SNAME(),  
      TrafficCop = NULL   
  FROM PutawayStrategyDetail , INSERTED WITH (NOLOCK)  
  WHERE PutawayStrategyDetail.PutawayStrategyKey = INSERTED.PutawayStrategyKey  
  AND PutawayStrategyDetail.PutawayStrategyLineNumber = INSERTED.PutawayStrategyLineNumber  
  SELECT @n_err = @@ERROR, @n_cnt = @@ROWCOUNT  
  IF @n_err <> 0  
  BEGIN  
   SELECT @n_continue = 3  
   SELECT @c_errmsg = CONVERT(CHAR(250),@n_err), @n_err=62303   -- Should Be Set To The SQL Errmessage but I don't know how to do so.  
   SELECT @c_errmsg="NSQL"+CONVERT(char(5),@n_err)+": UPDATE Failed on PutawayStrategyDetail table. (ntrPutawayStrategyDetailupdate)"   
            + " ( " + " SQLSvr MESSAGE=" + LTrim(RTrim(@c_errmsg)) + " ) "  
  END  
 END  
  
   IF UPDATE(TrafficCop)  
   BEGIN  
    SELECT @n_continue = 4   
   END     
      
   
 IF @n_continue=3  -- Error Occured - Process And Return  
 BEGIN  
  IF @@TRANCOUNT = 1 and @@TRANCOUNT >= @n_starttcnt  
  BEGIN  
   ROLLBACK TRAN  
  END  
  execute nsp_logerror @n_err, @c_errmsg, "ntrPutawayStrategyDetailUpdate"  
  RAISERROR (@c_errmsg, 16, 1) WITH SETERROR    -- SQL2012  
  RETURN  
 END  
 ELSE  
 BEGIN  
  WHILE @@TRANCOUNT > @n_starttcnt  
  BEGIN  
   COMMIT TRAN  
  END  
  RETURN  
 END  
END  
GO
ALTER TABLE [dbo].[PutawayStrategyDetail] ADD CONSTRAINT [PKPutawayStrategyDetail] PRIMARY KEY CLUSTERED ([PutawayStrategyKey], [PutawayStrategyLineNumber]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
GRANT SELECT ON  [dbo].[PutawayStrategyDetail] TO [JReportRole]
GO
GRANT DELETE ON  [dbo].[PutawayStrategyDetail] TO [NSQL]
GO
GRANT INSERT ON  [dbo].[PutawayStrategyDetail] TO [NSQL]
GO
GRANT SELECT ON  [dbo].[PutawayStrategyDetail] TO [NSQL]
GO
GRANT UPDATE ON  [dbo].[PutawayStrategyDetail] TO [NSQL]
GO
EXEC sp_addextendedproperty N'MS_Description', 'Each detail row contains a putaway type that tells the system how to evaluate the data on the row and a series of details indicating which checks the system should perform once the system has a candidate location to evaluate. The system evaluates each row in step number order.', 'SCHEMA', N'dbo', 'TABLE', N'PutawayStrategyDetail', NULL, NULL
GO
EXEC sp_addextendedproperty N'MS_Description', 'Date of the information added. (System date)', 'SCHEMA', N'dbo', 'TABLE', N'PutawayStrategyDetail', 'COLUMN', N'AddDate'
GO
EXEC sp_addextendedproperty N'MS_Description', 'The username/login ID added the information.', 'SCHEMA', N'dbo', 'TABLE', N'PutawayStrategyDetail', 'COLUMN', N'AddWho'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Unique code identifying Area.', 'SCHEMA', N'dbo', 'TABLE', N'PutawayStrategyDetail', 'COLUMN', N'AreaKey'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Specify area types in which the candidate locations must not be located', 'SCHEMA', N'dbo', 'TABLE', N'PutawayStrategyDetail', 'COLUMN', N'AreaTypeExclude01'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Specify area types in which the candidate locations must not be located', 'SCHEMA', N'dbo', 'TABLE', N'PutawayStrategyDetail', 'COLUMN', N'AreaTypeExclude02'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Specify area types in which the candidate locations must not be located', 'SCHEMA', N'dbo', 'TABLE', N'PutawayStrategyDetail', 'COLUMN', N'AreaTypeExclude03'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Unique code identifying check equipment profile.', 'SCHEMA', N'dbo', 'TABLE', N'PutawayStrategyDetail', 'COLUMN', N'CheckEquipmentProfileKey'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Indicates whether the system should check restrictions on each candidate location', 'SCHEMA', N'dbo', 'TABLE', N'PutawayStrategyDetail', 'COLUMN', N'CheckRestrictions'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Specify dimension requirements for each candidate location', 'SCHEMA', N'dbo', 'TABLE', N'PutawayStrategyDetail', 'COLUMN', N'DimensionRestriction01'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Specify dimension requirements for each candidate location', 'SCHEMA', N'dbo', 'TABLE', N'PutawayStrategyDetail', 'COLUMN', N'DimensionRestriction02'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Specify dimension requirements for each candidate location', 'SCHEMA', N'dbo', 'TABLE', N'PutawayStrategyDetail', 'COLUMN', N'DimensionRestriction03'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Specify dimension requirements for each candidate location', 'SCHEMA', N'dbo', 'TABLE', N'PutawayStrategyDetail', 'COLUMN', N'DimensionRestriction04'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Specify dimension requirements for each candidate location', 'SCHEMA', N'dbo', 'TABLE', N'PutawayStrategyDetail', 'COLUMN', N'DimensionRestriction05'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Specify dimension requirements for each candidate location', 'SCHEMA', N'dbo', 'TABLE', N'PutawayStrategyDetail', 'COLUMN', N'DimensionRestriction06'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Date of the information edited/modified/updated. (System date)', 'SCHEMA', N'dbo', 'TABLE', N'PutawayStrategyDetail', 'COLUMN', N'EditDate'
GO
EXEC sp_addextendedproperty N'MS_Description', 'The username/login ID edited/modified/updated the information.', 'SCHEMA', N'dbo', 'TABLE', N'PutawayStrategyDetail', 'COLUMN', N'EditWho'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Locate the candidates from this set of locations', 'SCHEMA', N'dbo', 'TABLE', N'PutawayStrategyDetail', 'COLUMN', N'FROMLOC'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Specify that the candidate location must not be any of these aisle', 'SCHEMA', N'dbo', 'TABLE', N'PutawayStrategyDetail', 'COLUMN', N'LocAisleExclude01'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Specify that the candidate location must not be any of these aisle', 'SCHEMA', N'dbo', 'TABLE', N'PutawayStrategyDetail', 'COLUMN', N'LocAisleExclude02'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Specify that the candidate location must not be any of these aisle', 'SCHEMA', N'dbo', 'TABLE', N'PutawayStrategyDetail', 'COLUMN', N'LocAisleExclude03'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Specify that the candidate location must not be any of these aisle', 'SCHEMA', N'dbo', 'TABLE', N'PutawayStrategyDetail', 'COLUMN', N'LocAisleExclude04'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Specify that the candidate location must not be any of these aisle', 'SCHEMA', N'dbo', 'TABLE', N'PutawayStrategyDetail', 'COLUMN', N'LocAisleExclude05'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Specify that the candidate location must not be any of these aisle', 'SCHEMA', N'dbo', 'TABLE', N'PutawayStrategyDetail', 'COLUMN', N'LocAisleExclude06'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Specify that the candidate location must be one of these aisle', 'SCHEMA', N'dbo', 'TABLE', N'PutawayStrategyDetail', 'COLUMN', N'LocAisleInclude01'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Specify that the candidate location must be one of these aisle', 'SCHEMA', N'dbo', 'TABLE', N'PutawayStrategyDetail', 'COLUMN', N'LocAisleInclude02'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Specify that the candidate location must be one of these aisle', 'SCHEMA', N'dbo', 'TABLE', N'PutawayStrategyDetail', 'COLUMN', N'LocAisleInclude03'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Specify that the candidate location must be one of these aisle', 'SCHEMA', N'dbo', 'TABLE', N'PutawayStrategyDetail', 'COLUMN', N'LocAisleInclude04'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Specify that the candidate location must be one of these aisle', 'SCHEMA', N'dbo', 'TABLE', N'PutawayStrategyDetail', 'COLUMN', N'LocAisleInclude05'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Specify that the candidate location must be one of these aisle', 'SCHEMA', N'dbo', 'TABLE', N'PutawayStrategyDetail', 'COLUMN', N'LocAisleInclude06'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Specify that the candidate location must not be in one of the specified location categories, such as Drive-Through Rack or Horizontal Carousel', 'SCHEMA', N'dbo', 'TABLE', N'PutawayStrategyDetail', 'COLUMN', N'LocationCategoryExclude01'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Specify that the candidate location must not be in one of the specified location categories, such as Drive-Through Rack or Horizontal Carousel', 'SCHEMA', N'dbo', 'TABLE', N'PutawayStrategyDetail', 'COLUMN', N'LocationCategoryExclude02'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Specify that the candidate location must not be in one of the specified location categories, such as Drive-Through Rack or Horizontal Carousel', 'SCHEMA', N'dbo', 'TABLE', N'PutawayStrategyDetail', 'COLUMN', N'LocationCategoryExclude03'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Specify that the candidate location must be in one of the specified location categories, such as Drive-Through Rack or Horizontal Carousel', 'SCHEMA', N'dbo', 'TABLE', N'PutawayStrategyDetail', 'COLUMN', N'LocationCategoryInclude01'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Specify that the candidate location must be in one of the specified location categories, such as Drive-Through Rack or Horizontal Carousel', 'SCHEMA', N'dbo', 'TABLE', N'PutawayStrategyDetail', 'COLUMN', N'LocationCategoryInclude02'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Specify that the candidate location must be in one of the specified location categories, such as Drive-Through Rack or Horizontal Carousel', 'SCHEMA', N'dbo', 'TABLE', N'PutawayStrategyDetail', 'COLUMN', N'LocationCategoryInclude03'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Specify that the candidate location must not show any of these handling flags. Options include DAMAGE, HOLD and NONE', 'SCHEMA', N'dbo', 'TABLE', N'PutawayStrategyDetail', 'COLUMN', N'LocationFlagExclude01'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Specify that the candidate location must not show any of these handling flags. Options include DAMAGE, HOLD and NONE', 'SCHEMA', N'dbo', 'TABLE', N'PutawayStrategyDetail', 'COLUMN', N'LocationFlagExclude02'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Specify that the candidate location must not show any of these handling flags. Options include DAMAGE, HOLD and NONE', 'SCHEMA', N'dbo', 'TABLE', N'PutawayStrategyDetail', 'COLUMN', N'LocationFlagExclude03'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Specify that the candidate location must show one of these handling flags. Options include DAMAGE, HOLD and NONE', 'SCHEMA', N'dbo', 'TABLE', N'PutawayStrategyDetail', 'COLUMN', N'LocationFlagInclude01'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Specify that the candidate location must show one of these handling flags. Options include DAMAGE, HOLD and NONE', 'SCHEMA', N'dbo', 'TABLE', N'PutawayStrategyDetail', 'COLUMN', N'LocationFlagInclude02'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Specify that the candidate location must show one of these handling flags. Options include DAMAGE, HOLD and NONE', 'SCHEMA', N'dbo', 'TABLE', N'PutawayStrategyDetail', 'COLUMN', N'LocationFlagInclude03'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Specify that the candidate location must not be any of these handling types. Options include Pallets Only, Cases Only or Other', 'SCHEMA', N'dbo', 'TABLE', N'PutawayStrategyDetail', 'COLUMN', N'LocationHandlingExclude01'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Specify that the candidate location must not be any of these handling types. Options include Pallets Only, Cases Only or Other', 'SCHEMA', N'dbo', 'TABLE', N'PutawayStrategyDetail', 'COLUMN', N'LocationHandlingExclude02'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Specify that the candidate location must not be any of these handling types. Options include Pallets Only, Cases Only or Other', 'SCHEMA', N'dbo', 'TABLE', N'PutawayStrategyDetail', 'COLUMN', N'LocationHandlingExclude03'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Specify that the candidate location must be one of these handling types. Options include Pallets Only, Cases Only or Other', 'SCHEMA', N'dbo', 'TABLE', N'PutawayStrategyDetail', 'COLUMN', N'LocationHandlingInclude01'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Specify that the candidate location must be one of these handling types. Options include Pallets Only, Cases Only or Other', 'SCHEMA', N'dbo', 'TABLE', N'PutawayStrategyDetail', 'COLUMN', N'LocationHandlingInclude02'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Specify that the candidate location must be one of these handling types. Options include Pallets Only, Cases Only or Other', 'SCHEMA', N'dbo', 'TABLE', N'PutawayStrategyDetail', 'COLUMN', N'LocationHandlingInclude03'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Specify restrictions that each candidate location type must meet. If a location does not meet all of these restrictions, it will not be included', 'SCHEMA', N'dbo', 'TABLE', N'PutawayStrategyDetail', 'COLUMN', N'LocationStateRestriction01'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Specify restrictions that each candidate location type must meet. If a location does not meet all of these restrictions, it will not be included', 'SCHEMA', N'dbo', 'TABLE', N'PutawayStrategyDetail', 'COLUMN', N'LocationStateRestriction02'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Specify restrictions that each candidate location type must meet. If a location does not meet all of these restrictions, it will not be included', 'SCHEMA', N'dbo', 'TABLE', N'PutawayStrategyDetail', 'COLUMN', N'LocationStateRestriction03'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Specify location types that cannot be included in the candidate locations', 'SCHEMA', N'dbo', 'TABLE', N'PutawayStrategyDetail', 'COLUMN', N'LocationTypeExclude01'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Specify location types that cannot be included in the candidate locations', 'SCHEMA', N'dbo', 'TABLE', N'PutawayStrategyDetail', 'COLUMN', N'LocationTypeExclude02'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Specify location types that cannot be included in the candidate locations', 'SCHEMA', N'dbo', 'TABLE', N'PutawayStrategyDetail', 'COLUMN', N'LocationTypeExclude03'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Specify location types that cannot be included in the candidate locations', 'SCHEMA', N'dbo', 'TABLE', N'PutawayStrategyDetail', 'COLUMN', N'LocationTypeExclude04'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Specify location types that cannot be included in the candidate locations', 'SCHEMA', N'dbo', 'TABLE', N'PutawayStrategyDetail', 'COLUMN', N'LocationTypeExclude05'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Specify location type for each candidate location', 'SCHEMA', N'dbo', 'TABLE', N'PutawayStrategyDetail', 'COLUMN', N'LocationTypeRestriction01'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Specify location type for each candidate location', 'SCHEMA', N'dbo', 'TABLE', N'PutawayStrategyDetail', 'COLUMN', N'LocationTypeRestriction02'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Specify location type for each candidate location', 'SCHEMA', N'dbo', 'TABLE', N'PutawayStrategyDetail', 'COLUMN', N'LocationTypeRestriction03'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Specify that the candidate location must not be any of these level types', 'SCHEMA', N'dbo', 'TABLE', N'PutawayStrategyDetail', 'COLUMN', N'LocLevelExclude01'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Specify that the candidate location must not be any of these level types', 'SCHEMA', N'dbo', 'TABLE', N'PutawayStrategyDetail', 'COLUMN', N'LocLevelExclude02'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Specify that the candidate location must not be any of these level types', 'SCHEMA', N'dbo', 'TABLE', N'PutawayStrategyDetail', 'COLUMN', N'LocLevelExclude03'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Specify that the candidate location must not be any of these level types', 'SCHEMA', N'dbo', 'TABLE', N'PutawayStrategyDetail', 'COLUMN', N'LocLevelExclude04'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Specify that the candidate location must not be any of these level types', 'SCHEMA', N'dbo', 'TABLE', N'PutawayStrategyDetail', 'COLUMN', N'LocLevelExclude05'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Specify that the candidate location must not be any of these level types', 'SCHEMA', N'dbo', 'TABLE', N'PutawayStrategyDetail', 'COLUMN', N'LocLevelExclude06'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Specify that the candidate location must be one of these level types', 'SCHEMA', N'dbo', 'TABLE', N'PutawayStrategyDetail', 'COLUMN', N'LocLevelInclude01'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Specify that the candidate location must be one of these level types', 'SCHEMA', N'dbo', 'TABLE', N'PutawayStrategyDetail', 'COLUMN', N'LocLevelInclude02'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Specify that the candidate location must be one of these level types', 'SCHEMA', N'dbo', 'TABLE', N'PutawayStrategyDetail', 'COLUMN', N'LocLevelInclude03'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Specify that the candidate location must be one of these level types', 'SCHEMA', N'dbo', 'TABLE', N'PutawayStrategyDetail', 'COLUMN', N'LocLevelInclude04'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Specify that the candidate location must be one of these level types', 'SCHEMA', N'dbo', 'TABLE', N'PutawayStrategyDetail', 'COLUMN', N'LocLevelInclude05'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Specify that the candidate location must be one of these level types', 'SCHEMA', N'dbo', 'TABLE', N'PutawayStrategyDetail', 'COLUMN', N'LocLevelInclude06'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Indicates the candidate locations for the current detail row. Candidate locations can be within a specified zone, a hard-coded location, or piece or case pick locations.', 'SCHEMA', N'dbo', 'TABLE', N'PutawayStrategyDetail', 'COLUMN', N'PAType'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Unique code identifying putaway strategy.', 'SCHEMA', N'dbo', 'TABLE', N'PutawayStrategyDetail', 'COLUMN', N'PutawayStrategyKey'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Indicates the record number as the system will search and process the steps in ascending order.', 'SCHEMA', N'dbo', 'TABLE', N'PutawayStrategyDetail', 'COLUMN', N'PutawayStrategyLineNumber'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Specify the zone in which the candidate should be selected', 'SCHEMA', N'dbo', 'TABLE', N'PutawayStrategyDetail', 'COLUMN', N'PutawayZone01'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Specify the zone in which the candidate should be selected', 'SCHEMA', N'dbo', 'TABLE', N'PutawayStrategyDetail', 'COLUMN', N'PutawayZone02'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Specify the zone in which the candidate should be selected', 'SCHEMA', N'dbo', 'TABLE', N'PutawayStrategyDetail', 'COLUMN', N'PutawayZone03'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Specify the zone in which the candidate should be selected', 'SCHEMA', N'dbo', 'TABLE', N'PutawayStrategyDetail', 'COLUMN', N'PutawayZone04'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Specify the zone in which the candidate should be selected', 'SCHEMA', N'dbo', 'TABLE', N'PutawayStrategyDetail', 'COLUMN', N'PutawayZone05'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Locate the candidates from this set of locations', 'SCHEMA', N'dbo', 'TABLE', N'PutawayStrategyDetail', 'COLUMN', N'TOLOC'
GO
EXEC sp_addextendedproperty N'MS_Description', 'When checked, fields updated in this table will not trigger to update other tables that are linked with this table.', 'SCHEMA', N'dbo', 'TABLE', N'PutawayStrategyDetail', 'COLUMN', N'TrafficCop'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Specify the zone in which the candidate should be selected', 'SCHEMA', N'dbo', 'TABLE', N'PutawayStrategyDetail', 'COLUMN', N'Zone'
GO
