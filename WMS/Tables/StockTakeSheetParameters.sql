CREATE TABLE [dbo].[StockTakeSheetParameters]
(
[StockTakeKey] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Facility] [nvarchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[StorerKey] [nvarchar] (60) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ZoneParm] [nvarchar] (60) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_StockTakeSheetParameters_ZoneParm] DEFAULT ('ALL'),
[AisleParm] [nvarchar] (60) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_StockTakeSheetParameters_AisleParm] DEFAULT ('ALL'),
[LevelParm] [nvarchar] (60) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_StockTakeSheetParameters_LevelParm] DEFAULT ('0 - 99'),
[HostWHCodeParm] [nvarchar] (60) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_StockTakeSheetParameters_HostWHCodeParm] DEFAULT ('ALL'),
[SKUParm] [nvarchar] (125) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_StockTakeSheetParameters_SKUParm] DEFAULT ('ALL'),
[AgencyParm] [nvarchar] (125) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_StockTakeSheetParameters_AgencyParm] DEFAULT ('ALL'),
[ABCParm] [nvarchar] (60) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_StockTakeSheetParameters_ABCParm] DEFAULT ('ALL'),
[Protect] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_StockTakeSheetParameters_Protect] DEFAULT ('N'),
[Password] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_StockTakeSheetParameters_Password] DEFAULT (' '),
[WithQuantity] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_StockTakeSheetParameters_WithQuantity] DEFAULT ('Y'),
[ClearHistory] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_StockTakeSheetParameters_ClearHistory] DEFAULT ('Y'),
[EmptyLocation] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_StockTakeSheetParameters_EmptyLocation] DEFAULT ('Y'),
[LinesPerPage] [int] NULL,
[FinalizeStage] [int] NOT NULL CONSTRAINT [DF_StockTakeSheetParameters_FinalizeStage] DEFAULT ((0)),
[PopulateStage] [int] NOT NULL CONSTRAINT [DF_StockTakeSheetParameters_PopulateStage] DEFAULT ((0)),
[GroupLottable05] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_StockTakeSheetParameters_GroupLottable05] DEFAULT (' '),
[AddDate] [datetime] NOT NULL CONSTRAINT [DF_StockTakeSheetParameters_AddDate] DEFAULT (getdate()),
[AddWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_StockTakeSheetParameters_AddWho] DEFAULT (suser_sname()),
[EditDate] [datetime] NOT NULL CONSTRAINT [DF_StockTakeSheetParameters_EditDate] DEFAULT (getdate()),
[EditWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_StockTakeSheetParameters_EditWho] DEFAULT (suser_sname()),
[AdjReasonCode] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_StockTakeSheetParameters_AdjReasonCode] DEFAULT (' '),
[AdjType] [nvarchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_StockTakeSheetParameters_AdjType] DEFAULT (' '),
[ArchiveCop] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[BlankCSheetHideLoc] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_StockTakeSheetParameters_BlankCSheetHideLoc] DEFAULT ('N'),
[BlankCSheetNoOfPage] [int] NULL CONSTRAINT [DF_StockTakeSheetParameters_BlankCSheetNoOfPage] DEFAULT ((0)),
[SkugroupParm] [nvarchar] (125) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_StockTakeSheetParameters_SkugroupParm] DEFAULT ('ALL'),
[ExcludeQtyPicked] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_StockTakeSheetParameters_ExcludeQtyPicked] DEFAULT ('N'),
[CountType] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_StockTakeSheetParameters_CountType] DEFAULT (''),
[ExtendedParm1Field] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_STOCKTAKESHEETPARAMETERS_ExtendedParm1Field] DEFAULT (''),
[ExtendedParm1] [nvarchar] (125) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_STOCKTAKESHEETPARAMETERS_ExtendedParm1] DEFAULT (''),
[ExtendedParm2Field] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_STOCKTAKESHEETPARAMETERS_ExtendedParm2Field] DEFAULT (''),
[ExtendedParm2] [nvarchar] (125) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_STOCKTAKESHEETPARAMETERS_ExtendedParm2] DEFAULT (''),
[ExtendedParm3Field] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_STOCKTAKESHEETPARAMETERS_ExtendedParm3Field] DEFAULT (''),
[ExtendedParm3] [nvarchar] (125) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_STOCKTAKESHEETPARAMETERS_ExtendedParm3] DEFAULT (''),
[ExcludeQtyAllocated] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_STOCKTAKESHEETPARAMETERS_ExcludeQtyAllocated] DEFAULT ('N'),
[StrategyKey] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_STOCKTAKESHEETPARAMETERS_StrategyKey] DEFAULT (''),
[Parameter01] [nvarchar] (125) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_STOCKTAKESHEETPARAMETERS_Parameter01] DEFAULT (''),
[Parameter02] [nvarchar] (125) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_STOCKTAKESHEETPARAMETERS_Parameter02] DEFAULT (''),
[Parameter03] [nvarchar] (125) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_STOCKTAKESHEETPARAMETERS_Parameter03] DEFAULT (''),
[Parameter04] [nvarchar] (125) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_STOCKTAKESHEETPARAMETERS_Parameter04] DEFAULT (''),
[Parameter05] [nvarchar] (125) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_STOCKTAKESHEETPARAMETERS_Parameter05] DEFAULT (''),
[CountSheetGroupBy01] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_STOCKTAKESHEETPARAMETERS_CountSheetGroupBy01] DEFAULT ('LOC.PutawayZone'),
[CountSheetGroupBy02] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_STOCKTAKESHEETPARAMETERS_CountSheetGroupBy02] DEFAULT ('LOC.LocAisle'),
[CountSheetGroupBy03] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_STOCKTAKESHEETPARAMETERS_CountSheetGroupBy03] DEFAULT ('LOC.LocLevel'),
[CountSheetGroupBy04] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_STOCKTAKESHEETPARAMETERS_CountSheetGroupBy04] DEFAULT (''),
[CountSheetGroupBy05] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_STOCKTAKESHEETPARAMETERS_CountSheetGroupBy05] DEFAULT (''),
[CountSheetSortBy01] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_STOCKTAKESHEETPARAMETERS_CountSheetSortBy01] DEFAULT ('LOC.CCLogicalLoc'),
[CountSheetSortBy02] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_STOCKTAKESHEETPARAMETERS_CountSheetSortBy02] DEFAULT ('LOC.Loc'),
[CountSheetSortBy03] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_STOCKTAKESHEETPARAMETERS_CountSheetSortBy03] DEFAULT ('LOTxLOCxID.ID'),
[CountSheetSortBy04] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_STOCKTAKESHEETPARAMETERS_CountSheetSortBy04] DEFAULT ('LOTxLOCxID.Sku'),
[CountSheetSortBy05] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_STOCKTAKESHEETPARAMETERS_CountSheetSortBy05] DEFAULT ('LOTxLOCxID.Lot'),
[CountSheetSortBy06] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_STOCKTAKESHEETPARAMETERS_CountSheetSortBy06] DEFAULT (''),
[CountSheetSortBy07] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_STOCKTAKESHEETPARAMETERS_CountSheetSortBy07] DEFAULT (''),
[CountSheetSortBy08] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_STOCKTAKESHEETPARAMETERS_CountSheetSortBy08] DEFAULT (''),
[BlankCSheetLineByMaxPLT] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_STOCKTAKESHEETPARAMETERS_BlankCSheetLineByMaxPLT] DEFAULT ('N'),
[BlankCSheetDPTRNOnly] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_STOCKTAKESHEETPARAMETERS_BlankCSheetDPTRNOnly] DEFAULT ('N'),
[QueryinJSON] [nvarchar] (4000) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_StockTakeSheetParameters_QueryinJSON] DEFAULT (''),
[Status] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_StockTakeSheetParameters_Status] DEFAULT (''),
[LocPerPage] [int] NULL CONSTRAINT [DF_StockTakeSheetParameters_LocPerPage] DEFAULT ((0))
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO

/************************************************************************/
/* Trigger: ntrStocktakeparametersUpdate                                */
/* Creation Date:                                                       */
/* Copyright: IDS                                                       */
/* Written by:                                                          */
/*                                                                      */
/* Purpose:                                                             */
/*                                                                      */
/* Called By: When Udpating Stocktakeparameters Record                  */
/*                                                                      */
/* PVCS Version: 1.1                                                    */
/*                                                                      */
/* Version: 5.4                                                         */
/*                                                                      */
/* Data Modifications:                                                  */
/*                                                                      */
/* Updates:                                                             */
/* Date         Author   Ver  Purposes                                  */
/* 14-Dec-2005  Shong    1.0  Include StockTakeParameter into Archive CC*/
/* 07-Nov-2006  June     1.0  SOS55261 - Disallow Change of Stocktake   */
/*                            Parameters when CCDetail exists           */
/* 20-Sep-2010  MC       1.1  SOS187913 - Add STKTAKELOG as Configkey   */
/*                            for Interface (MC01)                      */
/* 28-Oct-2013  TLTING   1.2  Review Editdate column update             */
/************************************************************************/
CREATE TRIGGER [dbo].[ntrStocktakeparametersUpdate]
ON [dbo].[StockTakeSheetParameters]
FOR UPDATE
AS
BEGIN
   IF @@ROWCOUNT = 0
   BEGIN
      RETURN
   END

   SET NOCOUNT ON
   SET QUOTED_IDENTIFIER OFF
   SET CONCAT_NULL_YIELDS_NULL OFF

   DECLARE  @n_continue       int,  
            @n_starttcnt      int,
            @c_pwd            NVARCHAR(10),
            @c_storerkey      NVARCHAR(20),
            @c_cckey          NVARCHAR(10),
            @c_transmitlogkey NVARCHAR(10),
            @c_authority      NVARCHAR(1),
            @b_success        int,
            @n_err            int,
            @c_errmsg         NVARCHAR(250)
         
   SELECT @n_continue=1, @n_starttcnt=@@TRANCOUNT

   IF UPDATE(ArchiveCop)
   BEGIN
      SELECT @n_continue = 4
   END

	-- Start : SOS55261                            
   IF @n_continue = 1 or @n_continue = 2 
   BEGIN   
      SELECT @c_cckey = StockTakeKey
      FROM   INSERTED

		IF  NOT UPDATE(Protect) AND NOT UPDATE(Password)
		AND NOT UPDATE(FinalizeStage) AND NOT UPDATE(PopulateStage) 
		AND NOT UPDATE(AdjReasonCode) AND NOT UPDATE(AdjType)
		BEGIN
			IF EXISTS (SELECT 1 FROM CCDETAIL (NOLOCK) WHERE CCKEY = @c_cckey)
			BEGIN
			   SELECT @n_continue=3
			   SELECT @c_errmsg= CONVERT(char(250), @n_err), @n_err=99701
			   SELECT @c_errmsg= "NSQL"+CONVERT(char(5), @n_err)+":Change Of Stock Take Parameters Not Allow When CCDETAILS Exists. (ntrStocktakeparametersUpdate)"+"("+"SQLSvr MESSAGE="+dbo.fnc_LTrim(dbo.fnc_RTrim(@c_errmsg))+")"
			END
		END
	END
	-- End : SOS55261
	   
   IF @n_continue = 1 or @n_continue = 2 
   BEGIN   

      IF UPDATE(Password)
      BEGIN

         SELECT @c_pwd = Password, 
                @c_Storerkey = Storerkey,
                @c_cckey = StockTakeKey
         FROM   INSERTED

         IF @c_pwd = 'POSTED'
         BEGIN
            Select @b_success = 0      
            Execute nspGetRight null, 
                                @c_StorerKey,   -- Storer
                                null,         -- Sku
                                'TBLHKITF',             -- ConfigKey
                                @b_success          output, 
                                @c_authority        output, 
                                @n_err              output, 
                                @c_errmsg           output
            If @b_success = 1 AND @c_authority = '1'
            Begin
               IF NOT EXISTS (SELECT 1 FROM TransmitLog2 (NOLOCK) WHERE TableName = 'TBLSTOCK' 
                              AND    Key1 = @c_cckey
                              AND    Key3 = @c_Storerkey)
               BEGIN
                  EXECUTE nspg_getkey
                  'TransmitlogKey2'
                  ,10
                  , @c_transmitlogkey OUTPUT
                  , @b_success OUTPUT
                  , @n_err OUTPUT
                  , @c_errmsg OUTPUT
      
                  IF NOT @b_success=1
                  BEGIN
                     SELECT @n_continue=3
                  END
      
                  IF @n_continue = 1 or @n_continue = 2 
                  BEGIN
                     INSERT TransmitLog2 (transmitlogkey,tablename,key1,key2, key3)
                     VALUES (@c_transmitlogkey, 'TBLSTOCK', @c_cckey, '', @c_storerkey)
                     SELECT @n_err= @@Error
                     IF NOT @n_err=0
                     BEGIN
                        SELECT @n_continue=3
                        Select @c_errmsg= CONVERT(char(250), @n_err), @n_err=99701
                        Select @c_errmsg= "NSQL"+CONVERT(char(5), @n_err)+":Insert failed on TransmitLog. (ntrStocktakeparametersUpdate)"+"("+"SQLSvr MESSAGE="+dbo.fnc_LTrim(dbo.fnc_RTrim(@c_errmsg))+")"
                     END 
                  END
               END -- TBLSTOCK
            End -- TBLITF

            -- MC01 Start
            IF @n_continue = 1 or @n_continue = 2 
            BEGIN
               
               Select @b_success = 0      
               Execute nspGetRight null, 
                                   @c_StorerKey,-- Storer
                                   null,        -- Sku
                                   'STKTAKELOG',-- ConfigKey
                                   @b_success   OUTPUT, 
                                   @c_authority OUTPUT, 
                                   @n_err       OUTPUT, 
                                   @c_errmsg    OUTPUT

               IF @b_success = 1 AND @c_authority = '1'
               BEGIN  
                    EXEC ispGenTransmitLog3 'STKTAKELOG', @c_CCKey, '', @c_Storerkey, ''   
                       , @b_success OUTPUT  
                       , @n_err OUTPUT  
                       , @c_errmsg OUTPUT  
               END
            END
            -- MC01 End
         END -- POSTED
      END -- Password
   END 
   


   -- Added by SHONG on 31-OCT-2003
   -- Update the EditDate and EditWho
   IF ( @n_continue = 1 or @n_continue = 2 ) AND NOT UPDATE(EditDate)
   BEGIN
      UPDATE Stocktakesheetparameters
         SET EditDate = GetDate(),
             EditWho  = SUser_SName()
      FROM INSERTED
      WHERE Stocktakesheetparameters.StockTakeKey = INSERTED.StockTakeKey
   
   END
   
   /* Return Statement */
   IF @n_continue=3  -- Error Occured - Process And Return
   BEGIN
       IF @@TRANCOUNT = 1 and @@TRANCOUNT >= @n_starttcnt 
       BEGIN
            ROLLBACK TRAN
       END     
       ELSE
       BEGIN
            WHILE @@TRANCOUNT > @n_starttcnt 
            BEGIN
           COMMIT TRAN
            END                         
       END
       execute nsp_logerror @n_err, @c_errmsg, "ntrStocktakeparametersUpdate"
       RAISERROR (@c_errmsg, 16, 1) WITH SETERROR    -- SQL2012          
       RETURN
   END
   ELSE
   BEGIN
   /* Error Did Not Occur , Return Normally */
       WHILE @@TRANCOUNT > @n_starttcnt 
       BEGIN
            COMMIT TRAN
       END
       RETURN
   END
  /* End Return Statement */
END







GO
SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO

/* 14-Jul-2011  KHLim02       GetRight for Delete log                   */

CREATE TRIGGER [dbo].[ntrStockTakeSheetParametersDelete]
ON [dbo].[StockTakeSheetParameters]
FOR DELETE
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

   DECLARE  @b_Success     int,       -- Populated by calls to stored procedures - was the proc successful?
            @n_err         int,       -- Error number returned by stored procedure or this trigger
            @c_errmsg      NVARCHAR(250), -- Error message returned by stored procedure or this trigger
            @n_continue    int,       -- continuation flag: 1=Continue, 2=failed but continue processsing, 3=failed do not continue processing, 4=successful but skip further processing
            @n_starttcnt   int,       -- Holds the current transaction count
            @n_cnt         int        -- Holds the number of rows affected by the DELETE statement that fired this trigger.
           ,@c_authority   NVARCHAR(1)  -- KHLim02
   SELECT @n_continue=1, @n_starttcnt=@@TRANCOUNT
   IF (SELECT count(*) FROM DELETED) =
   (SELECT count(*) FROM DELETED WHERE DELETED.ArchiveCop = '9')
   BEGIN
      SELECT @n_continue = 4
   END

      /* #INCLUDE <TRCONHD1.SQL> */     
   IF @n_continue = 1 or @n_continue = 2
   BEGIN
      SELECT @b_success = 0         --    Start (KHLim02)
      EXECUTE nspGetRight  NULL,             -- facility  
                           NULL,             -- Storerkey  
                           NULL,             -- Sku  
                           'DataMartDELLOG', -- Configkey  
                           @b_success     OUTPUT, 
                           @c_authority   OUTPUT, 
                           @n_err         OUTPUT, 
                           @c_errmsg      OUTPUT  
      IF @b_success <> 1
      BEGIN
         SELECT @n_continue = 3
               ,@c_errmsg = 'ntrStockTakeSheetParametersDelete' + dbo.fnc_RTrim(@c_errmsg)
      END
      ELSE 
      IF @c_authority = '1'         --    End   (KHLim02)
      BEGIN
         INSERT INTO dbo.StockTakeSheetParameters_DELLOG ( StockTakeKey )
         SELECT StockTakeKey FROM DELETED

         SELECT @n_err = @@ERROR, @n_cnt = @@ROWCOUNT
         IF @n_err <> 0
         BEGIN
            SELECT @n_continue = 3
            SELECT @c_errmsg = CONVERT(CHAR(250),@n_err), @n_err = 68101   -- Should Be Set To The SQL Errmessage but I don't know how to do so.
            SELECT @c_errmsg='NSQL'+CONVERT(char(5),@n_err)+': Delete Trigger On Table StockTakeSheetParameters Failed. (ntrStockTakeSheetParametersDelete)' + ' ( ' + ' SQLSvr MESSAGE=' + LTrim(RTrim(@c_errmsg)) + ' ) '
         END
      END
   END

      /* #INCLUDE <TRCOND2.SQL> */
   IF @n_continue=3  -- Error Occured - Process And Return
   BEGIN
      IF @@TRANCOUNT = 1 and @@TRANCOUNT >= @n_starttcnt
      BEGIN
         ROLLBACK TRAN
      END
      ELSE
      BEGIN
         WHILE @@TRANCOUNT > @n_starttcnt
         BEGIN
            COMMIT TRAN
         END
      END
      EXECUTE nsp_logerror @n_err, @c_errmsg, 'ntrStockTakeSheetParametersDelete'
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
ALTER TABLE [dbo].[StockTakeSheetParameters] ADD CONSTRAINT [PK_StockTakeSheetParameters] PRIMARY KEY CLUSTERED ([StockTakeKey]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
GRANT SELECT ON  [dbo].[StockTakeSheetParameters] TO [JReportRole]
GO
GRANT DELETE ON  [dbo].[StockTakeSheetParameters] TO [NSQL]
GO
GRANT INSERT ON  [dbo].[StockTakeSheetParameters] TO [NSQL]
GO
GRANT SELECT ON  [dbo].[StockTakeSheetParameters] TO [NSQL]
GO
GRANT UPDATE ON  [dbo].[StockTakeSheetParameters] TO [NSQL]
GO
EXEC sp_addextendedproperty N'MS_Description', 'The system will print the stock count blind sheets based on the parameters configuration in Stock Take Parameters window. The WMS will list all the locations in the area/zone specified. Automatic stock quantity withdrawal from these locations will occur once the posting is executed.', 'SCHEMA', N'dbo', 'TABLE', N'StockTakeSheetParameters', NULL, NULL
GO
EXEC sp_addextendedproperty N'MS_Description', 'Date of the information added. (System date)', 'SCHEMA', N'dbo', 'TABLE', N'StockTakeSheetParameters', 'COLUMN', N'AddDate'
GO
EXEC sp_addextendedproperty N'MS_Description', 'The username/login ID added the information.', 'SCHEMA', N'dbo', 'TABLE', N'StockTakeSheetParameters', 'COLUMN', N'AddWho'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Generate Count Sheet Group By Field 1', 'SCHEMA', N'dbo', 'TABLE', N'StockTakeSheetParameters', 'COLUMN', N'CountSheetGroupBy01'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Generate Count Sheet By Group Field 2', 'SCHEMA', N'dbo', 'TABLE', N'StockTakeSheetParameters', 'COLUMN', N'CountSheetGroupBy02'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Generate Count Sheet Group By Field 3', 'SCHEMA', N'dbo', 'TABLE', N'StockTakeSheetParameters', 'COLUMN', N'CountSheetGroupBy03'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Generate Count Sheet By Group Field 4', 'SCHEMA', N'dbo', 'TABLE', N'StockTakeSheetParameters', 'COLUMN', N'CountSheetGroupBy04'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Generate Count Sheet By Group Field 5', 'SCHEMA', N'dbo', 'TABLE', N'StockTakeSheetParameters', 'COLUMN', N'CountSheetGroupBy05'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Count Sheet Sort By Field 1', 'SCHEMA', N'dbo', 'TABLE', N'StockTakeSheetParameters', 'COLUMN', N'CountSheetSortBy01'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Count Sheet Sort By Field 2', 'SCHEMA', N'dbo', 'TABLE', N'StockTakeSheetParameters', 'COLUMN', N'CountSheetSortBy02'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Count Sheet Sort By Field 3', 'SCHEMA', N'dbo', 'TABLE', N'StockTakeSheetParameters', 'COLUMN', N'CountSheetSortBy03'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Count Sheet Sort By Field 4', 'SCHEMA', N'dbo', 'TABLE', N'StockTakeSheetParameters', 'COLUMN', N'CountSheetSortBy04'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Count Sheet Sort By Field 5', 'SCHEMA', N'dbo', 'TABLE', N'StockTakeSheetParameters', 'COLUMN', N'CountSheetSortBy05'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Count Sheet Sort By Field 6', 'SCHEMA', N'dbo', 'TABLE', N'StockTakeSheetParameters', 'COLUMN', N'CountSheetSortBy06'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Count Sheet Sort By Field 7', 'SCHEMA', N'dbo', 'TABLE', N'StockTakeSheetParameters', 'COLUMN', N'CountSheetSortBy07'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Count Sheet Sort By Field 8', 'SCHEMA', N'dbo', 'TABLE', N'StockTakeSheetParameters', 'COLUMN', N'CountSheetSortBy08'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Date of the information edited/modified/updated. (System date)', 'SCHEMA', N'dbo', 'TABLE', N'StockTakeSheetParameters', 'COLUMN', N'EditDate'
GO
EXEC sp_addextendedproperty N'MS_Description', 'The username/login ID edited/modified/updated the information.', 'SCHEMA', N'dbo', 'TABLE', N'StockTakeSheetParameters', 'COLUMN', N'EditWho'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Exclude QtyAllocated Option', 'SCHEMA', N'dbo', 'TABLE', N'StockTakeSheetParameters', 'COLUMN', N'ExcludeQtyAllocated'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Extended Parameters 1', 'SCHEMA', N'dbo', 'TABLE', N'StockTakeSheetParameters', 'COLUMN', N'ExtendedParm1'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Extended Parameters 1', 'SCHEMA', N'dbo', 'TABLE', N'StockTakeSheetParameters', 'COLUMN', N'ExtendedParm1Field'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Extended Parameters 2 Value', 'SCHEMA', N'dbo', 'TABLE', N'StockTakeSheetParameters', 'COLUMN', N'ExtendedParm2'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Extended Parameters 2', 'SCHEMA', N'dbo', 'TABLE', N'StockTakeSheetParameters', 'COLUMN', N'ExtendedParm2Field'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Extended Parameters 3 Value', 'SCHEMA', N'dbo', 'TABLE', N'StockTakeSheetParameters', 'COLUMN', N'ExtendedParm3'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Extended Parameters 3', 'SCHEMA', N'dbo', 'TABLE', N'StockTakeSheetParameters', 'COLUMN', N'ExtendedParm3Field'
GO
EXEC sp_addextendedproperty N'MS_Description', 'A building or place that provide services for effective warehouse management. Identified by unique code.', 'SCHEMA', N'dbo', 'TABLE', N'StockTakeSheetParameters', 'COLUMN', N'Facility'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Loc Per Page', 'SCHEMA', N'dbo', 'TABLE', N'StockTakeSheetParameters', 'COLUMN', N'LocPerPage'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Cycle Count Strategy parameters 01', 'SCHEMA', N'dbo', 'TABLE', N'StockTakeSheetParameters', 'COLUMN', N'Parameter01'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Cycle Count Strategy parameters 02', 'SCHEMA', N'dbo', 'TABLE', N'StockTakeSheetParameters', 'COLUMN', N'Parameter02'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Cycle Count Strategy parameters 03', 'SCHEMA', N'dbo', 'TABLE', N'StockTakeSheetParameters', 'COLUMN', N'Parameter03'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Cycle Count Strategy parameters 04', 'SCHEMA', N'dbo', 'TABLE', N'StockTakeSheetParameters', 'COLUMN', N'Parameter04'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Cycle Count Strategy parameters 05', 'SCHEMA', N'dbo', 'TABLE', N'StockTakeSheetParameters', 'COLUMN', N'Parameter05'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Unique code identifying Stock Take.', 'SCHEMA', N'dbo', 'TABLE', N'StockTakeSheetParameters', 'COLUMN', N'StockTakeKey'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Unique key to the Storer record.', 'SCHEMA', N'dbo', 'TABLE', N'StockTakeSheetParameters', 'COLUMN', N'StorerKey'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Cycle Count Strategy Key', 'SCHEMA', N'dbo', 'TABLE', N'StockTakeSheetParameters', 'COLUMN', N'StrategyKey'
GO
