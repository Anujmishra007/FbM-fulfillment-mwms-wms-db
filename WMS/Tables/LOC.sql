CREATE TABLE [dbo].[LOC]
(
[Loc] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_LOC_Loc] DEFAULT ('UNKNOWN'),
[Cube] [float] NULL CONSTRAINT [DF_LOC_cube] DEFAULT ((0)),
[Length] [float] NULL CONSTRAINT [DF_LOC_length] DEFAULT ((0)),
[Width] [float] NULL CONSTRAINT [DF_LOC_width] DEFAULT ((0)),
[Height] [float] NULL CONSTRAINT [DF_LOC_height] DEFAULT ((0)),
[LocationType] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_LOC_LocationType] DEFAULT ('OTHER'),
[LocationFlag] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_LOC_LocationFlag] DEFAULT ('NONE'),
[LocationHandling] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_LOC_LocationHandling] DEFAULT ('1'),
[LocationCategory] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_LOC_LocationCategory] DEFAULT ('OTHER'),
[LogicalLocation] [nvarchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_LOC_LogicalLocation] DEFAULT (' '),
[CubicCapacity] [float] NULL CONSTRAINT [DF_LOC_CubicCapacity] DEFAULT ((0)),
[WeightCapacity] [float] NULL CONSTRAINT [DF_LOC_WeightCapacity] DEFAULT ((0)),
[Status] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_LOC_Status] DEFAULT ('OK'),
[LoseId] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_LOC_Loseid] DEFAULT ('0'),
[Facility] [nvarchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_LOC_Facility] DEFAULT ('F1'),
[ABC] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_LOC_ABC] DEFAULT ('B'),
[PickZone] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_LOC_PickZone] DEFAULT (' '),
[PutawayZone] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_LOC_PutAwayZone] DEFAULT ('RACK'),
[SectionKey] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_LOC_SectionKey] DEFAULT ('FACILITY'),
[PickMethod] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_LOC_PickMethod] DEFAULT (' '),
[CommingleSku] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_LOC_CommingleSku] DEFAULT ('1'),
[CommingleLot] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_LOC_CommingleLot] DEFAULT ('1'),
[LocLevel] [int] NOT NULL CONSTRAINT [DF_LOC_LocLevel] DEFAULT ((0)),
[Xcoord] [int] NOT NULL CONSTRAINT [DF_LOC_Xcoord] DEFAULT ((0)),
[Ycoord] [int] NOT NULL CONSTRAINT [DF_LOC_Ycoord] DEFAULT ((0)),
[Zcoord] [int] NOT NULL CONSTRAINT [DF_LOC_Zcoord] DEFAULT ((0)),
[TrafficCop] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ArchiveCop] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MaxPallet] [int] NULL CONSTRAINT [DF_Loc_MaxPallet] DEFAULT ((0)),
[LocAisle] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_LOC_LocAisle] DEFAULT (' '),
[HOSTWHCODE] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CCLogicalLoc] [nvarchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_LOC_CCLogicalLoc] DEFAULT (' '),
[ChargingPallet] [float] NULL CONSTRAINT [DF_LOC_ChargingPallet] DEFAULT ((0)),
[EditWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_LOC_EditWho] DEFAULT (suser_sname()),
[EditDate] [datetime] NULL CONSTRAINT [DF_LOC_EditDate] DEFAULT (getdate()),
[AddWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_LOC_AddWho] DEFAULT (suser_sname()),
[AddDate] [datetime] NULL CONSTRAINT [DF_LOC_AddDate] DEFAULT (getdate()),
[LocCheckDigit] [nvarchar] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_LOC_LocCheckDigit] DEFAULT (''),
[LastCycleCount] [datetime] NULL,
[CycleCountFrequency] [int] NULL,
[LoseUCC] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_LOC_LoseUCC] DEFAULT (''),
[NoMixLottable01] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_LOC_NoMixLottable01] DEFAULT ('0'),
[NoMixLottable02] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_LOC_NoMixLottable02] DEFAULT ('0'),
[NoMixLottable03] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_LOC_NoMixLottable03] DEFAULT ('0'),
[NoMixLottable04] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_LOC_NoMixLottable04] DEFAULT ('0'),
[LocBay] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_LOC_LocBay] DEFAULT (''),
[PALogicalLoc] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_LOC_PALogicalLoc] DEFAULT (''),
[Score] [int] NOT NULL CONSTRAINT [DF_LOC_Score] DEFAULT ((0)),
[LocationRoom] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LocationGroup] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_LOC_LocationGroup] DEFAULT (''),
[NoMixLottable05] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_LOC_NoMixLottable05] DEFAULT ('0'),
[NoMixLottable06] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_LOC_NoMixLottable06] DEFAULT ('0'),
[NoMixLottable07] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_LOC_NoMixLottable07] DEFAULT ('0'),
[NoMixLottable08] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_LOC_NoMixLottable08] DEFAULT ('0'),
[NoMixLottable09] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_LOC_NoMixLottable09] DEFAULT ('0'),
[NoMixLottable10] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_LOC_NoMixLottable10] DEFAULT ('0'),
[NoMixLottable11] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_LOC_NoMixLottable11] DEFAULT ('0'),
[NoMixLottable12] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_LOC_NoMixLottable12] DEFAULT ('0'),
[NoMixLottable13] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_LOC_NoMixLottable13] DEFAULT ('0'),
[NoMixLottable14] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_LOC_NoMixLottable14] DEFAULT ('0'),
[NoMixLottable15] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_LOC_NoMixLottable15] DEFAULT ('0'),
[Floor] [nvarchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_LOC_Floor] DEFAULT (''),
[CycleCounter] [int] NULL CONSTRAINT [DF_LOC_CycleCounter] DEFAULT ((0)),
[Descr] [nvarchar] (60) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_LOC_Descr] DEFAULT (''),
[MaxCarton] [int] NOT NULL CONSTRAINT [DF_LOC_MaxCarton] DEFAULT ((0)),
[MaxSKU] [int] NOT NULL CONSTRAINT [DF_LOC_MaxSKU] DEFAULT ((0))
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO

/************************************************************************/
/* Trigger: ntrLocAdd                                                   */
/* Creation Date:                                                       */
/* Copyright: IDS                                                       */
/* Written by:                                                          */
/*                                                                      */
/* Purpose:                                                             */
/* Version: 5.5                                                         */
/*                                                                      */
/* Data Modifications:                                                  */
/*                                                                      */
/* Updates:                                                             */
/* Date         Author        Purposes                                  */
/* 26-Jun-2010  Shong         Default LocCheckDigit When Loc Added      */
/*                            SOS#179299                                */
/* 11-Mar-2013  TKLim         Fix bug that cause @n_continue = 4 and    */
/*                            skip the LocCheckDigit generation (TK01)  */
/* 09-APR-2013  Shong         Change LocCheckDigit to 2 Numeric Digit   */
/*                            for Voice Implementation                  */
/************************************************************************/
CREATE TRIGGER [dbo].[ntrLocAdd]
ON  [dbo].[LOC]
FOR INSERT
AS
BEGIN
   SET NOCOUNT ON
   SET QUOTED_IDENTIFIER OFF
   SET CONCAT_NULL_YIELDS_NULL OFF

   DECLARE
   @b_Success              int       -- Populated by calls to stored procedures - was the proc successful?
   ,         @n_err        int       -- Error number returned by stored procedure or this trigger
   ,         @n_err2       int       -- For Additional Error Detection
   ,         @c_errmsg     NVARCHAR(250) -- Error message returned by stored procedure or this trigger
   ,         @n_continue   int
   ,         @n_starttcnt  int       -- Holds the current transaction count
   ,         @c_preprocess NVARCHAR(250) -- preprocess
   ,         @c_pstprocess NVARCHAR(250) -- post process
   ,         @n_cnt int
   SELECT @n_continue=1, @n_starttcnt=@@TRANCOUNT
   
   --TK01 - S 
   --Not suppose to check
   --IF UPDATE(TrafficCop)
   --BEGIN
   --   SELECT @n_continue = 4
   --END
   --TK01 - E 
      
   IF EXISTS( SELECT 1 FROM INSERTED WHERE ArchiveCop = '9')
   BEGIN
      SELECT @n_continue = 4
   END
   /* #INCLUDE <TRLU1.SQL> */
   /*--------------->>>>> Checking For Putawayzone <<<<<------------------*/
   /* Author: Shong.                                                      */
   /* Date: 18-Dec-2003                                                   */
   /* Purpose: To Prevend user setup the Loc without PutawayZone exists,  */
   /*          this will cause the allocation fail.                       */
   /*---------------------------------------------------------------------*/
   IF NOT EXISTS(SELECT LOC FROM INSERTED 
                 JOIN PUTAWAYZONE (NOLOCK) ON INSERTED.PutawayZone = PUTAWAYZONE.PutawayZone) 
   BEGIN
    SELECT @n_continue = 3
    SELECT @c_errmsg = CONVERT(CHAR(250),@n_err), @n_err=74907   -- Should Be Set To The SQL Errmessage but I don't know how to do so.
    SELECT @c_errmsg='NSQL'+CONVERT(char(5),@n_err)+': PutawayZone NOT EXISTS in PutawayZone Table. (ntrLOCAdd)' + ' ( ' + ' SQLSvr MESSAGE=' + dbo.fnc_LTrim(dbo.fnc_RTrim(@c_errmsg)) + ' ) '
   END
   IF EXISTS(SELECT LOC FROM INSERTED WHERE INSERTED.PutawayZone = '') 
   BEGIN
    SELECT @n_continue = 3
    SELECT @c_errmsg = CONVERT(CHAR(250),@n_err), @n_err=74907   -- Should Be Set To The SQL Errmessage but I don't know how to do so.
    SELECT @c_errmsg='NSQL'+CONVERT(char(5),@n_err)+': PutawayZone Cannot be BLANK. (ntrLOCAdd)' + ' ( ' + ' SQLSvr MESSAGE=' + dbo.fnc_LTrim(dbo.fnc_RTrim(@c_errmsg)) + ' ) '
   END
   /*--------------->>>>> Start FBRC08 <<<<<---------------*/
   /* Author: Wally M.             */
   /* Date: 03.14.00               */
   /* Purpose: calculate dimension and default to cube  */
   /*------------------------------------------------------*/
   IF @n_continue = 1 or @n_continue = 2
   BEGIN
      UPDATE LOC
         SET LOC.cube = (INSERTED.length * INSERTED.width * INSERTED.height),
             -- Added by SHONG on 26-Jun-2010
             -- SOS#179299
             --LOC.LocCheckDigit = dbo.fnc_GetLocCheckDigit(INSERTED.LOC),
             LOC.LocCheckDigit = dbo.fnc_GetLocCheckDigit2Digit(INSERTED.LOC),
             trafficcop = NULL
      FROM LOC, INSERTED
      WHERE LOC.loc = INSERTED.loc
      IF @@ERROR <> 0
      BEGIN
         SELECT @n_continue = 3
         SELECT @n_err = @@ERROR
         SELECT @c_errmsg='NSQL'+CONVERT(char(5),@n_err)+': Insert Error on Table LOC (ntrLocAdd)'
      END
   END
   /*--------------->>>>> End FBRC08 <<<<<---------------*/
   /* #INCLUDE <TRLU2.SQL> */
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
      execute nsp_logerror @n_err, @c_errmsg, 'ntrLocAdd'
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
SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO

/* 14-Jul-2011  KHLim02    1.2   GetRight for Delete log                */

CREATE TRIGGER [dbo].[ntrLOCDelete]
ON [dbo].[LOC]
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
               ,@c_errmsg = 'ntrLOCDelete' + dbo.fnc_RTrim(@c_errmsg)
      END
      ELSE 
      IF @c_authority = '1'         --    End   (KHLim02)
      BEGIN
         INSERT INTO dbo.LOC_DELLOG ( Loc )
         SELECT Loc FROM DELETED

         SELECT @n_err = @@ERROR, @n_cnt = @@ROWCOUNT
         IF @n_err <> 0
         BEGIN
            SELECT @n_continue = 3
            SELECT @c_errmsg = CONVERT(CHAR(250),@n_err), @n_err = 68101   -- Should Be Set To The SQL Errmessage but I don't know how to do so.
            SELECT @c_errmsg='NSQL'+CONVERT(char(5),@n_err)+': Delete Trigger On Table LOC Failed. (ntrLOCDelete)' + ' ( ' + ' SQLSvr MESSAGE=' + LTrim(RTrim(@c_errmsg)) + ' ) '
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
      EXECUTE nsp_logerror @n_err, @c_errmsg, 'ntrLOCDelete'
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
SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO


/************************************************************************/
/* Trigger: ntrLocUpdate                                                */
/* Creation Date:                                                       */
/* Copyright: IDS                                                       */
/* Written by:                                                          */
/*                                                                      */
/* Purpose:                                                             */
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
/* PVCS Version: 1.7                                                    */
/*                                                                      */
/* Version: 5.4                                                         */
/*                                                                      */
/* Data Modifications:                                                  */
/*                                                                      */
/* Updates:                                                             */
/* Date         Author        Purposes                                  */
/* 17-Oct-2003  YokeBeen      NIKE Regional (NSC) Project (SOS#15352)   */
/*                            - (YokeBeen01)                            */
/* 28-Dec-2004  YokeBeen      For NSC 947-InvAdj - (YokeBeen02)         */
/* 08-Aug-2006  Vicky         Generic Configkey (INVHOLDLOG) for        */
/*                            Inventory Hold Interface                  */
/* 23-Apr-2007	Vicky         SOS#74049 - Fix interface double sending  */
/* 04-May-2007  Vicky         SOS#74919 - Insert direct to Transmitlog3 */
/*                            without checking on uniqueness of         */
/*                            Key1 + Key2  + Key3 for INVHOLDLOG        */  
/* 04-Jul-2007  Vicky         SOS#80373 - Add checking on duplicate     */
/*                            Invholdkey with both status = 0 being     */
/*                            inserted into Transmitlog3                */   
/* 01-Oct-2009  Shong         Only Update LOC.Cube if L/W/H was updated */
/* 26-Jun-2010  Shong         SOS#179299 Default LOCCheckDigit          */
/* 02-May-2012  Shong         Do Not Allow Update LOC Type DynPickP &   */
/*                            DynPickR to LoseID                        */
/* 25 May2012   TLTING01      DM integrity - add update editdate B4     */
/*                            TrafficCop                                */
/* 06-Sep-2012  KHLim         Move up ArchiveCop (KH01)                 */
/* 09-APR-2013  Shong         Change LocCheckDigit to 2 Numeric Digit   */  
/*                            for Voice Implementation                  */  
/* 03-May-2013  Ung           Add DPLOCNotAllowLoseID                   */
/* 28-Oct-2013  TLTING        Review Editdate column update             */
/* 08-Nov-2016  SHONG002      Not allow to change location type if qty  */
/*                            over-allocated                            */
/* 16-Jan-2019  TLTING02      missing nolock                            */
/************************************************************************/

CREATE TRIGGER [dbo].[ntrLocUpdate]
 ON  [dbo].[LOC]
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
    -- SET CONCAT_NULL_YIELDS_NULL OFF

 DECLARE
			  @b_Success            int       -- Populated by calls to stored procedures - was the proc successful?
 ,         @n_err                int       -- Error number returned by stored procedure or this trigger
 ,         @n_err2 					int       -- For Additional Error Detection
 ,         @c_errmsg             NVARCHAR(250) -- Error message returned by stored procedure or this trigger
 ,         @n_continue int                 
 ,         @n_starttcnt int                -- Holds the current transaction count
 ,         @c_preprocess NVARCHAR(250)         -- preprocess
 ,         @c_pstprocess NVARCHAR(250)         -- post process
 ,         @n_cnt int                  

 SELECT 	  @b_Success      = 0 
 ,         @n_err          = 0 
 ,         @n_err2 			= 0 
 ,         @c_errmsg			= '' 
 ,         @n_continue		= 0 
 ,         @n_starttcnt		= 0 
 ,         @c_preprocess	= '' 
 ,         @c_pstprocess	= '' 
 ,         @n_cnt				= 0 

 SELECT @n_continue=1, @n_starttcnt=@@TRANCOUNT
 IF UPDATE(ArchiveCop)     --KH01
 BEGIN
	 SELECT @n_continue = 4 
 END
 
 IF ( @n_continue = 1 OR @n_continue = 2 ) AND NOT UPDATE(EditDate)
 BEGIN
    UPDATE LOC with (ROWLOCK)
    SET EditWho = sUser_sName(),
        EditDate = GetDate(),
        TrafficCop = NULL 
    FROM LOC 
    JOIN INSERTED ON LOC.LOC = INSERTED.LOC 
    IF @@ERROR <> 0
    BEGIN
      SELECT @n_continue = 3
      SELECT @n_err = @@ERROR
      SELECT @c_errmsg='NSQL'+CONVERT(char(5),@n_err)+': Update Error on Table LOC (ntrLocUpdate)'
    END   
 END


 IF UPDATE(TrafficCop)
 BEGIN
	 SELECT @n_continue = 4 
 END

      /* #INCLUDE <TRLU1.SQL> */
 /*--------------->>>>> Start FBRC08 <<<<<---------------*/
 /* Author: Wally M.					*/
 /* Date: 03.14.00					*/
 /* Purpose: calculate dimension and default to cube	*/
 /*------------------------------------------------------*/
 IF @n_continue = 1 or @n_continue = 2
 BEGIN
   IF UPDATE(Length) OR UPDATE(Width) OR UPDATE(Height)
   UPDATE LOC
   SET LOC.cube = (INSERTED.length * INSERTED.width * INSERTED.height),
       trafficcop = NULL,
       EditDate = GETDATE(),
       EditWho = SUSER_SNAME()
   FROM LOC, INSERTED
   WHERE LOC.loc = INSERTED.loc
   IF @@ERROR <> 0
   BEGIN
     SELECT @n_continue = 3
     SELECT @n_err = @@ERROR
     SELECT @c_errmsg='NSQL'+CONVERT(char(5),@n_err)+': Update Error on Table LOC (ntrLocUpdate)'
   END
 END
 /*--------------->>>>> End FBRC08 <<<<<---------------*/
 
 IF @n_continue = 1 or @n_continue = 2
 BEGIN
 	 IF EXISTS(SELECT 1 FROM INSERTED WHERE LocationType IN ('DYNPICKP', 'DYNPICKR') AND LoseID = '1') AND
 	    EXISTS(SELECT 1 
 	      FROM StorerConfig WITH (NOLOCK) 
 	         JOIN INSERTED ON (INSERTED.Facility = StorerConfig.Facility)
 	      WHERE StorerConfig.ConfigKey = 'DPLOCNotAllowLoseID'
 	         AND SValue = '1')
 	 BEGIN
       SELECT @n_continue = 3
       SELECT @n_err = 78502
       SELECT @c_errmsg='NSQL'+CONVERT(CHAR(5),@n_err)+': Dynamic Pick Location Not Allow Lose ID (ntrLocUpdate)' 	 	
 	 END
 END 
 
 IF @n_continue = 1 or @n_continue = 2
 BEGIN
 	 IF EXISTS(SELECT 1 FROM INSERTED WHERE LocationType IN ('DYNPPICK') AND LoseID = '0')
 	 BEGIN
       SELECT @n_continue = 3
       SELECT @n_err = 78504
       SELECT @c_errmsg='NSQL'+CONVERT(CHAR(5),@n_err)+': Dynamic Permanent Pick Location Must Lose ID (ntrLocUpdate)' 	 	
 	 END
 END 
 -- SHONG002
 IF UPDATE(LocationType)
 BEGIN
 	 IF EXISTS ( SELECT INSERTED.LOC 
 	               FROM INSERTED 
 	               JOIN DELETED ON INSERTED.LOC = DELETED.LOC 
 	            WHERE DELETED.LocationType IN ('DYNPPICK', 'DYNPICKP', 'DYNPICKR')
               AND   INSERTED.LocationType NOT IN ("DYNPPICK", 'DYNPICKP', 'DYNPICKR')
               AND   EXISTS(SELECT 1 FROM SKUxLOC AS SL WITH (NOLOCK)
                            WHERE  SL.Loc = INSERTED.LOC 
                            AND    (SL.Qty - ( SL.QtyAllocated + SL.QtyPicked )) < 0 ))
    BEGIN
       SELECT @n_continue = 3
       SELECT @n_err = 78505
       SELECT @c_errmsg='NSQL'+CONVERT(CHAR(5),@n_err)+': Found Over-Allocated Inventory, Not Allow to Change Location Type (ntrLocUpdate)'
    END
 END
 
 IF @n_continue = 1 or @n_continue = 2
 BEGIN
 	IF UPDATE(LOCATIONFLAG)
	BEGIN
		 IF EXISTS(SELECT 1 FROM DELETED,INSERTED,LOTxLOCxID (NOLOCK) --tlting02
					 WHERE DELETED.LOC = INSERTED.LOC
					 AND LOTxLOCxID.LOC = INSERTED.LOC
					 AND LOTxLOCxID.LOC = DELETED.LOC
					 AND (DELETED.LOCATIONFLAG = 'DAMAGE' or DELETED.LOCATIONFLAG = 'HOLD')
					 AND INSERTED.LOCATIONFLAG <> 'DAMAGE'
					 AND INSERTED.LOCATIONFLAG <> 'HOLD'
					 AND LOTxLOCxID.QTY > 0 
					 )
		 BEGIN
			 SELECT @n_continue = 3
			 SELECT @n_err = 78501
			 SELECT @c_errmsg='NSQL'+CONVERT(char(5),@n_err)+': Cannot Change LocationFlag From HOLD/DAMAGE if QTY > 0 . (ntrLocUpdate)'
		 END 

		 IF @n_continue = 1 or @n_continue = 2
		 BEGIN
			 IF EXISTS(SELECT * FROM DELETED,INSERTED,LOTxLOCxID (NOLOCK) -- tlting02
						 WHERE DELETED.LOC = INSERTED.LOC
						 AND LOTxLOCxID.LOC = INSERTED.LOC
						 AND LOTxLOCxID.LOC = DELETED.LOC
						 AND (DELETED.LOCATIONFLAG <> 'DAMAGE' and DELETED.LOCATIONFLAG <> 'HOLD')
						 AND (INSERTED.LOCATIONFLAG = 'DAMAGE' or INSERTED.LOCATIONFLAG = 'HOLD')
						 AND LOTxLOCxID.QTY > 0
						 )
			 BEGIN
				 SELECT @n_continue = 3
				 SELECT @n_err = 78503
				 SELECT @c_errmsg='NSQL'+CONVERT(char(5),@n_err)+': Cannot Change LocationFlag To HOLD/DAMAGE if QTY > 0 . (ntrLocUpdate)'
			 END
 		END
	END
 END

-- (YokeBeen01) - Start
 IF @n_continue = 1 OR @n_continue = 2
 BEGIN
	DECLARE @c_Loc			 NVARCHAR(10)
			, @c_StorerKey  NVARCHAR(15)
			, @c_Sku			 NVARCHAR(20)
			, @c_InsLocFlag NVARCHAR(10)
			, @c_DelLocFlag NVARCHAR(10)
			, @c_InsStatus	 NVARCHAR(10)
			, @c_DelStatus	 NVARCHAR(10)
			, @c_InsFlag	 NVARCHAR(1)
			, @c_DelFlag	 NVARCHAR(1)
			, @c_NIKEREGITF NVARCHAR(1)
         , @c_Invholditf   NVARCHAR(1)
         , @c_InvHoldKey   NVARCHAR(10)
         
   DECLARE @c_transmitlogkey NVARCHAR(10)

	-- SOS#74049 (Start)
	DECLARE @n_IDCnt  int,
	        @n_LotCnt int
	
	SELECT @n_IDCnt = 0,
	       @n_LotCnt = 0
	-- SOS#74049 (End)

	SELECT @c_Loc				= ''
			, @c_StorerKey 	= ''
			, @c_Sku				= ''
			, @c_InsLocFlag	= ''
			, @c_DelLocFlag	= ''
			, @c_InsStatus		= ''
			, @c_DelStatus		= ''
			, @c_InsFlag		= ''
			, @c_DelFlag		= ''
			, @c_NIKEREGITF	= ''
         , @c_Invholditf   = '0'

	IF EXISTS (SELECT INVENTORYHOLD.LOC 
					 FROM INVENTORYHOLD (NOLOCK), INSERTED, DELETED 
               WHERE INSERTED.LOC = DELETED.LOC
                 AND INSERTED.LOC = INVENTORYHOLD.LOC
                 AND INSERTED.STATUS <> DELETED.STATUS)
	BEGIN
		SELECT @c_Storerkey = SKUxLOC.Storerkey FROM SKUxLOC (NOLOCK), INSERTED (NOLOCK)
		 WHERE SKUxLOC.Loc = INSERTED.Loc

		SELECT @b_success = 0
		SELECT @c_NIKEREGITF = '0' 

		EXECUTE nspGetRight 
			NULL,					-- facility
			@c_storerkey, 		-- Storerkey
			NULL,					-- Sku
			'NIKEREGITF',		-- Configkey
			@b_success			OUTPUT,
			@c_NIKEREGITF		OUTPUT, 
			@n_err				OUTPUT,
			@c_errmsg			OUTPUT

		IF @b_success <> 1
		BEGIN
			SELECT @n_continue = 3
			SELECT @c_errmsg = 'ntrLocUpdate' + dbo.fnc_RTrim(@c_errmsg)
		END
		ELSE	
		IF @c_NIKEREGITF = '1'
		BEGIN
			SELECT @c_Loc = INSERTED.Loc, 
					 @c_InsFlag = CASE WHEN ((INSERTED.Locationflag = 'HOLD') OR (INSERTED.Locationflag = 'DAMAGE') 
														OR (INSERTED.Status = 'HOLD')) 
											 THEN '1' ELSE '0' END,
					 @c_DelFlag = CASE WHEN ((DELETED.Locationflag = 'HOLD') OR (DELETED.Locationflag = 'DAMAGE') 
														OR (DELETED.Status = 'HOLD')) 
											 THEN '1' ELSE '0' END
			  FROM DELETED (NOLOCK) 
			  JOIN INSERTED (NOLOCK) ON (DELETED.Loc = INSERTED.Loc)
			 GROUP BY INSERTED.Loc,  
					 	 CASE WHEN ((INSERTED.Locationflag = 'HOLD') OR (INSERTED.Locationflag = 'DAMAGE') 
										OR (INSERTED.Status = 'HOLD')) 
							   THEN '1' ELSE '0' END,
					 	 CASE WHEN ((DELETED.Locationflag = 'HOLD') OR (DELETED.Locationflag = 'DAMAGE') 
										OR (DELETED.Status = 'HOLD')) 
							   THEN '1' ELSE '0' END
		
			-- (YokeBeen02) - Start
			-- When Hold or UnHold
			IF ((@c_InsFlag = 1) AND (@c_DelFlag = 0)) OR ((@c_InsFlag = 0) AND (@c_DelFlag = 1))
			BEGIN
				BEGIN TRAN
					INSERT INTO INVHOLDTRANSLOG 
							(Sku, StorerKey, Facility, SourceKey, SourceType, UserID)
					(SELECT DISTINCT SKUxLOC.Sku, @c_StorerKey, INSERTED.Facility, SKUxLOC.Loc, 'LOC', SUSER_SNAME()
						FROM INSERTED (NOLOCK)
						JOIN SKUxLOC (NOLOCK) ON (INSERTED.Loc = SKUxLOC.Loc)
					  WHERE dbo.fnc_RTrim(SKUxLOC.Loc) = dbo.fnc_RTrim(@c_Loc)
						 AND SKUxLOC.Storerkey = @c_StorerKey
					  GROUP BY SKUxLOC.Sku, INSERTED.Facility, SKUxLOC.Loc) 
				COMMIT TRAN
			-- (YokeBeen02) - End
			END -- when Hold or UnHold
		END -- IF @c_NIKEREGITF = '1'

      -- Generic Configkey (Start)
		SELECT @b_success = 0
		EXECUTE nspGetRight 
			NULL,					-- facility
			@c_storerkey, 		-- Storerkey
			NULL,					-- Sku
			'INVHOLDLOG',		-- Configkey
			@b_success			OUTPUT,
			@c_Invholditf		OUTPUT, 
			@n_err				OUTPUT,
			@c_errmsg			OUTPUT

		IF @b_success <> 1
		BEGIN
			SELECT @n_continue = 3
			SELECT @c_errmsg = 'ntrLocUpdate' + dbo.fnc_RTrim(@c_errmsg)
		END
		ELSE	
		IF @c_Invholditf = '1'
		BEGIN
			SELECT @c_Loc = INSERTED.Loc, 
					 @c_InsFlag = CASE WHEN ((INSERTED.Locationflag = 'HOLD') OR (INSERTED.Status = 'HOLD')) 
											 THEN '1' ELSE '0' END,
					 @c_DelFlag = CASE WHEN ((DELETED.Locationflag = 'HOLD') OR (DELETED.Status = 'HOLD')) 
											 THEN '1' ELSE '0' END
			  FROM DELETED (NOLOCK) 
			  JOIN INSERTED (NOLOCK) ON (DELETED.Loc = INSERTED.Loc)
			 GROUP BY INSERTED.Loc,  
					 	 CASE WHEN ((INSERTED.Locationflag = 'HOLD')	OR (INSERTED.Status = 'HOLD')) 
							   THEN '1' ELSE '0' END,
					 	 CASE WHEN ((DELETED.Locationflag = 'HOLD') OR (DELETED.Status = 'HOLD')) 
							   THEN '1' ELSE '0' END
	
	         SELECT @c_InvHoldKey = INVENTORYHOLD.InventoryHoldKey 
			   FROM   INVENTORYHOLD (NOLOCK), INSERTED 
		      WHERE  INSERTED.LOC = INVENTORYHOLD.LOC
		      AND    INSERTED.LOC = @c_Loc
		
		   -- When Hold or UnHold
			IF ((@c_InsFlag = 1) AND (@c_DelFlag = 0)) OR ((@c_InsFlag = 0) AND (@c_DelFlag = 1))
			BEGIN
				BEGIN TRAN

               IF @c_InsFlag = 1 
               BEGIN
                  SELECT @c_InsLocFlag = 'HOLD'
               END
               ELSE
               IF @c_InsFlag = 0
               BEGIN
                  SELECT @c_InsLocFlag = 'OK'
               END
               -- SOS#74049 - To fix double sending of records (Start)
					SELECT @n_IDCnt = 0,  @n_LotCnt = 0

               SELECT @n_IDCnt = COUNT(*)
               FROM TRANSMITLOG3 T3 (NOLOCK)
               JOIN INVENTORYHOLD IH (NOLOCK) ON (IH.InventoryHoldKey = T3.Key1)
               JOIN LOTxLOCxID LLI (NOLOCK) ON (LLI.ID = IH.ID AND 
                                                LLI.Storerkey = @c_StorerKey AND 
                                                LLI.LOC = @c_Loc)
               WHERE T3.Tablename = 'INVHOLDLOG-ID'
               AND   T3.Transmitflag = '0'
               AND   T3.Key2 = @c_InsLocFlag

               IF @n_IDCnt = 0
               BEGIN
                  SELECT @n_LotCnt = COUNT(*)
                  FROM TRANSMITLOG3 T3 (NOLOCK)
                  JOIN INVENTORYHOLD IH (NOLOCK) ON (IH.InventoryHoldKey = T3.Key1)
                  JOIN LOTxLOCxID LLI (NOLOCK) ON (LLI.LOT = IH.LOT AND 
                                                   LLI.Storerkey = @c_StorerKey AND 
                                                   LLI.LOC = @c_Loc)
                  WHERE T3.Tablename = 'INVHOLDLOG-LOT'
                  AND   T3.Transmitflag = '0'
                  AND   T3.Key2 = @c_InsLocFlag
               END
               
               IF (@n_IDCnt = 0) AND (@n_LotCnt = 0) 
               BEGIN
--                Commented By Vicky for SOS#74919 (Start) 
-- 	               SELECT @b_success = 1                                                             
-- 			         EXEC ispGenTransmitLog3 'INVHOLDLOG-LOC', @c_InvHoldKey, @c_InsLocFlag, @c_Storerkey, ''
-- 			         , @b_success OUTPUT
-- 			         , @n_err OUTPUT
-- 			         , @c_errmsg OUTPUT
-- 	
-- 	               IF @b_success <> 1
-- 			         BEGIN
-- 			            SELECT @n_continue = 3
-- 			            SELECT @c_errmsg = CONVERT(CHAR(250),@n_err), @n_err=63810
-- 			            SELECT @c_errmsg='NSQL'+CONVERT(char(5),@n_err)+': Unable to obtain transmitlogkey (ntrLocUpdate)' + ' ( ' + ' SQLSvr MESSAGE=' + dbo.fnc_LTrim(dbo.fnc_RTrim(@c_errmsg)) + ' ) '
-- 			         END 
--                Commented By Vicky for SOS#74919 (End) 
                    -- SOS#80373 (Start)
                    IF NOT EXISTS ( SELECT 1 FROM TransmitLog3 (NOLOCK) WHERE TableName = 'INVHOLDLOG-LOC'
                                    AND Key1 = @c_InvHoldKey AND Key2 = @c_InsLocFlag 
                                    AND Key3 = @c_Storerkey AND Transmitflag = '0')
                    BEGIN
	--                Added By Vicky for SOS#74919 (Start)
							SELECT @c_transmitlogkey = ''
							SELECT @b_success = 1
							EXECUTE nspg_getkey
		                   'TransmitlogKey3'
		 		             ,10
		 	 	             , @c_transmitlogkey OUTPUT
		 		             , @b_success OUTPUT
		 		             , @n_err OUTPUT
		 		             , @c_errmsg OUTPUT
		
							IF @b_success <> 1
							BEGIN
								SELECT @n_continue=3
							END
	                  ELSE
	                  BEGIN
	   						INSERT INTO TRANSMITLOG3  (Transmitlogkey, Tablename, Key1, Key2, Key3, Transmitflag)
	   						VALUES  (@c_transmitlogkey, 'INVHOLDLOG-LOC', @c_InvHoldKey, @c_InsLocFlag, @c_Storerkey,'0')
	   	
	   						SELECT @n_err= @@Error
	   	
	   						IF NOT @n_err=0
	   						BEGIN
	   							SELECT @n_continue=3 
	   							Select @c_errmsg= CONVERT(char(250), @n_err), @n_err=74562
	   							Select @c_errmsg= 'NSQL' + CONVERT(char(5), @n_err)+ ':Insert failed on TransmitLog3. (ntrLocUpdate)' +'(' + 'SQLSvr MESSAGE=' + dbo.fnc_LTrim(dbo.fnc_RTrim(@c_errmsg)) + ')'
	   						END 
                    END --  Added By Vicky for SOS#74919 (End)
                  END   -- SOS#80373 (End)
              END
               -- SOS#74049 - To fix double sending of records (End)
				COMMIT TRAN
			END -- when Hold or UnHold
		END -- IF @c_Invholditf = '1'
      -- Generic Configkey (End)
	END -- If Record Exists
 END -- IF @n_continue = 1 OR @n_continue = 2
-- (YokeBeen01) - End

-- SOS#179299 Default LocCheckDigit 
IF UPDATE(LOC) 
BEGIN
   UPDATE LOC
   SET LocCheckDigit = dbo.fnc_GetLocCheckDigit2Digit(INSERTED.LOC),   
       --LocCheckDigit = dbo.fnc_GetLocCheckDigit(INSERTED.LOC),   
       LOC.TrafficCop = NULL,
       EditDate = GETDATE(),
       EditWho = SUSER_SNAME() 
   FROM LOC 
   JOIN INSERTED ON LOC.LOC = INSERTED.LOC 
   
END

 /* #INCLUDE <TRLU2.SQL> */
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

	 EXECUTE nsp_logerror @n_err, @c_errmsg, 'ntrLocUpdate'
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
ALTER TABLE [dbo].[LOC] WITH NOCHECK ADD CONSTRAINT [CK_LOC_Loc_01] CHECK ((NOT [Loc]=' '))
GO
ALTER TABLE [dbo].[LOC] ADD CONSTRAINT [PKLOC] PRIMARY KEY CLUSTERED ([Loc]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IDX_LOC_facility2] ON [dbo].[LOC] ([Facility], [LocAisle]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IDX_LOC_facility_LocationFlag] ON [dbo].[LOC] ([Facility], [LocationFlag]) INCLUDE ([PALogicalLoc]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IDX_LOC_LocType] ON [dbo].[LOC] ([Facility], [LocationType], [LocationCategory], [Status], [LogicalLocation]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_LOC] ON [dbo].[LOC] ([LocationFlag], [Status], [HOSTWHCODE]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IDX_LOC_pickzone] ON [dbo].[LOC] ([PickZone]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IDX_LOC_PUTAWAYZONE] ON [dbo].[LOC] ([PutawayZone]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
GRANT SELECT ON  [dbo].[LOC] TO [JReportRole]
GO
GRANT DELETE ON  [dbo].[LOC] TO [NSQL]
GO
GRANT INSERT ON  [dbo].[LOC] TO [NSQL]
GO
GRANT SELECT ON  [dbo].[LOC] TO [NSQL]
GO
GRANT UPDATE ON  [dbo].[LOC] TO [NSQL]
GO
EXEC sp_addextendedproperty N'MS_Description', 'After a product is received, it is stored at a location in the warehouse. The locations will be physically labeled. It can be of any sizes and dimensions.', 'SCHEMA', N'dbo', 'TABLE', N'LOC', NULL, NULL
GO
EXEC sp_addextendedproperty N'MS_Description', 'ABC designation of the fixed locations where A - fast mover, B - average mover, C - slow mover', 'SCHEMA', N'dbo', 'TABLE', N'LOC', 'COLUMN', N'ABC'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Date of the information added. (System date)', 'SCHEMA', N'dbo', 'TABLE', N'LOC', 'COLUMN', N'AddDate'
GO
EXEC sp_addextendedproperty N'MS_Description', 'The username/login ID added the information.', 'SCHEMA', N'dbo', 'TABLE', N'LOC', 'COLUMN', N'AddWho'
GO
EXEC sp_addextendedproperty N'MS_Description', 'This is used for sorting the stock count sheet', 'SCHEMA', N'dbo', 'TABLE', N'LOC', 'COLUMN', N'CCLogicalLoc'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Customized for HK for billing purposes', 'SCHEMA', N'dbo', 'TABLE', N'LOC', 'COLUMN', N'ChargingPallet'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Indicates whether more than one lot can be stored at the location. Options are Y or N', 'SCHEMA', N'dbo', 'TABLE', N'LOC', 'COLUMN', N'CommingleLot'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Indicates whether more than one commodity can be stored at the location. Options are Y or N', 'SCHEMA', N'dbo', 'TABLE', N'LOC', 'COLUMN', N'CommingleSku'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Size of the LocationÆs storage area. (Length * Width * Height) ', 'SCHEMA', N'dbo', 'TABLE', N'LOC', 'COLUMN', N'Cube'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Maximum cubic capacity of the location (length x width x height)', 'SCHEMA', N'dbo', 'TABLE', N'LOC', 'COLUMN', N'CubicCapacity'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Cycle Count Counter', 'SCHEMA', N'dbo', 'TABLE', N'LOC', 'COLUMN', N'CycleCounter'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Date of the information edited/modified/updated. (System date)', 'SCHEMA', N'dbo', 'TABLE', N'LOC', 'COLUMN', N'EditDate'
GO
EXEC sp_addextendedproperty N'MS_Description', 'The username/login ID edited/modified/updated the information.', 'SCHEMA', N'dbo', 'TABLE', N'LOC', 'COLUMN', N'EditWho'
GO
EXEC sp_addextendedproperty N'MS_Description', 'The warehouse or DC in which the location is residing', 'SCHEMA', N'dbo', 'TABLE', N'LOC', 'COLUMN', N'Facility'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Height of the location''s storage area', 'SCHEMA', N'dbo', 'TABLE', N'LOC', 'COLUMN', N'Height'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Stores the host warehouse code which will be used during the interface process', 'SCHEMA', N'dbo', 'TABLE', N'LOC', 'COLUMN', N'HOSTWHCODE'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Length of the location''s storage area', 'SCHEMA', N'dbo', 'TABLE', N'LOC', 'COLUMN', N'Length'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Unique code identifying the physical location in the facility', 'SCHEMA', N'dbo', 'TABLE', N'LOC', 'COLUMN', N'Loc'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Indicates the aisle of the location', 'SCHEMA', N'dbo', 'TABLE', N'LOC', 'COLUMN', N'LocAisle'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Identifies the physical location type, for example Cantilever Rack, Drive Through Rack, Horizontal Carousel, ASRS, Drive In Rack, Double Deep etc.  This can be setup in CODE Look up where LISTNAME = ''LOCCATEGRY''', 'SCHEMA', N'dbo', 'TABLE', N'LOC', 'COLUMN', N'LocationCategory'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Identifies the purpose of the location. Option include: DAMAGE, HOLD , NONE and INACTIVE', 'SCHEMA', N'dbo', 'TABLE', N'LOC', 'COLUMN', N'LocationFlag'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Identifies the type of packaging to be stored in the location. Options include: Pallets only, Cases only, Other', 'SCHEMA', N'dbo', 'TABLE', N'LOC', 'COLUMN', N'LocationHandling'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Identifies how the location is used, for example   PICK-CASE - used as a location from which to pick full cases  OTHER - used for bulk/full pallet storage  Staged - indicates the location used when all the details for an order line have moved to a final', 'SCHEMA', N'dbo', 'TABLE', N'LOC', 'COLUMN', N'LocationType'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Calculate Location Check Digit  Purpose is to facilitate future development of Voice Pick', 'SCHEMA', N'dbo', 'TABLE', N'LOC', 'COLUMN', N'LocCheckDigit'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Indicates the level of the location from the floor', 'SCHEMA', N'dbo', 'TABLE', N'LOC', 'COLUMN', N'LocLevel'
GO
EXEC sp_addextendedproperty N'MS_Description', 'In many facilities, the location field is not sequenced in the order in which picking and putaway should occur. The route sequence field is used to sequence locations for picking and putaway purposes', 'SCHEMA', N'dbo', 'TABLE', N'LOC', 'COLUMN', N'LogicalLocation'
GO
EXEC sp_addextendedproperty N'MS_Description', 'When selected, removes the pallet id from all products moved into the location', 'SCHEMA', N'dbo', 'TABLE', N'LOC', 'COLUMN', N'LoseId'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Store value for Maximum carton 1 Loc can have', 'SCHEMA', N'dbo', 'TABLE', N'LOC', 'COLUMN', N'MaxCarton'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Maximum pallets that the location can store at any one time', 'SCHEMA', N'dbo', 'TABLE', N'LOC', 'COLUMN', N'MaxPallet'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Store value for Maximum SKU 1 Loc can have', 'SCHEMA', N'dbo', 'TABLE', N'LOC', 'COLUMN', N'MaxSKU'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Used by RDT to lock the area for picking i.e. once a picker starts picking at this zone, no other pickers can pick at the same zone', 'SCHEMA', N'dbo', 'TABLE', N'LOC', 'COLUMN', N'PickZone'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Zone to which the location is assigned. Options include DOCK and RACK', 'SCHEMA', N'dbo', 'TABLE', N'LOC', 'COLUMN', N'PutawayZone'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Functional division within the facility', 'SCHEMA', N'dbo', 'TABLE', N'LOC', 'COLUMN', N'SectionKey'
GO
EXEC sp_addextendedproperty N'MS_Description', 'A pre-populated field that notes Location status', 'SCHEMA', N'dbo', 'TABLE', N'LOC', 'COLUMN', N'Status'
GO
EXEC sp_addextendedproperty N'MS_Description', 'When checked, fields updated in this table will not trigger to update other tables that are linked with this table.', 'SCHEMA', N'dbo', 'TABLE', N'LOC', 'COLUMN', N'TrafficCop'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Maximum weight capacity the location can hold', 'SCHEMA', N'dbo', 'TABLE', N'LOC', 'COLUMN', N'WeightCapacity'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Width of the storage area', 'SCHEMA', N'dbo', 'TABLE', N'LOC', 'COLUMN', N'Width'
GO
