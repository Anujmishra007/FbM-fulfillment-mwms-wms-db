CREATE TABLE [dbo].[INVENTORYHOLD]
(
[InventoryHoldKey] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_INVENTORYHOLD_InventoryHoldKey] DEFAULT (' '),
[Lot] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_INVENTORYHOLD_Lot] DEFAULT (' '),
[Id] [nvarchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_INVENTORYHOLD_Id] DEFAULT (' '),
[Loc] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_INVENTORYHOLD_Loc] DEFAULT (' '),
[Hold] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_INVENTORYHOLD_Hold] DEFAULT (' '),
[Status] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_INVENTORYHOLD_Status] DEFAULT (' '),
[DateOn] [datetime] NOT NULL CONSTRAINT [DF_INVENTORYHOLD_DateOn] DEFAULT (getdate()),
[WhoOn] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_INVENTORYHOLD_WhoOn] DEFAULT (suser_sname()),
[DateOff] [datetime] NOT NULL CONSTRAINT [DF_INVENTORYHOLD_DateOff] DEFAULT (getdate()),
[WhoOff] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_INVENTORYHOLD_WhoOff] DEFAULT (suser_sname()),
[TrafficCop] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ArchiveCop] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SKU] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_INVENTORYHOLD_SKU] DEFAULT (' '),
[Storerkey] [nvarchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_INVENTORYHOLD_Storerkey] DEFAULT (' '),
[Lottable01] [nvarchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Lottable02] [nvarchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Lottable03] [nvarchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Lottable04] [datetime] NULL,
[Lottable05] [datetime] NULL,
[Remark] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Lottable06] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_INVENTORYHOLD_Lottable06] DEFAULT (' '),
[Lottable07] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_INVENTORYHOLD_Lottable07] DEFAULT (' '),
[Lottable08] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_INVENTORYHOLD_Lottable08] DEFAULT (' '),
[Lottable09] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_INVENTORYHOLD_Lottable09] DEFAULT (' '),
[Lottable10] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_INVENTORYHOLD_Lottable10] DEFAULT (' '),
[Lottable11] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_INVENTORYHOLD_Lottable11] DEFAULT (' '),
[Lottable12] [nvarchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_INVENTORYHOLD_Lottable12] DEFAULT (' '),
[Lottable13] [datetime] NULL,
[Lottable14] [datetime] NULL,
[Lottable15] [datetime] NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO

/************************************************************************/
/* Trigger: ntrInventoryHoldAdd                                         */
/* Creation Date:                                                       */
/* Copyright: IDS                                                       */
/* Written by:                                                          */
/*                                                                      */
/* Purpose:                                                             */
/*                                                                      */
/* Usage:                                                               */
/*                                                                      */
/* Called By: When records added into ITRN                              */
/*                                                                      */
/* PVCS Version: 1.1                                                    */
/*                                                                      */
/* Version: 5.4                                                         */
/*                                                                      */
/* Data Modifications:                                                  */
/*                                                                      */
/* Updates:                                                             */
/* Date         Author        Purposes                                  */
/* 07-Sep-2006  MaryVong      Add in RDT compatible error messages      */
/* 09-Aug-2016  TLTING        Change Set ROWCOUNT 1 to Top 1            */
/************************************************************************/

CREATE TRIGGER [dbo].[ntrInventoryHoldAdd]
ON  [dbo].[INVENTORYHOLD]
FOR INSERT
AS
BEGIN
   SET NOCOUNT ON
   SET ANSI_NULLS OFF
   SET QUOTED_IDENTIFIER OFF
   SET CONCAT_NULL_YIELDS_NULL OFF
	
   DECLARE
      @b_Success            int       -- Populated by calls to stored procedures - was the proc successful?
      ,         @n_err                int       -- Error number returned by stored procedure or this trigger
      ,         @n_err2 int              -- For Additional Error Detection
      ,         @c_errmsg             NVARCHAR(250) -- Error message returned by stored procedure or this trigger
      ,         @n_continue int                 
      ,         @n_starttcnt int                -- Holds the current transaction count
      ,         @c_preprocess NVARCHAR(250)         -- preprocess
      ,         @c_pstprocess NVARCHAR(250)         -- post process
      ,         @n_cnt int                  
   SELECT @n_continue=1, @n_starttcnt=@@TRANCOUNT
   /* #INCLUDE <TRADA1.SQL> */     
   /************************************************************************
   *	Add records in TransmitLog to track the QC HOLD		        *
   *************************************************************************/
   DECLARE @c_LOT    NVARCHAR(10),
         @c_LOC    NVARCHAR(10),
         @c_ID     NVARCHAR(18),
         @c_String NVARCHAR(255),
         @c_InventoryHoldKey NVARCHAR(10),
         @c_StorerKey        NVARCHAR(20),
         @c_Hold             NVARCHAR(1),
         @c_SKU              NVARCHAR(20),
         @n_Qty              float,
         @c_WorkOrderNo      NVARCHAR(18),
         @c_BatchNo          NVARCHAR(18)

   /* IDSV5 - Leo */
   Declare @c_primarykey NVARCHAR(10), @b_interface NVARCHAR(1), @c_transmitlogkey NVARCHAR(10), @c_authority NVARCHAR(1)
   Select @c_primarykey = ''
   While 1 = 1
   Begin
     -- Set rowcount 1
      Select TOP 1 @c_primarykey = InventoryHoldKey, 
      @c_hold = Hold, 
      @c_loc = Loc
      From INSERTED
      Where INSERTED.InventoryHoldKey > @c_primarykey
      Order by INSERTED.InventoryHoldKey
      if @@rowcount = 0
      Begin
         set rowcount 0
         break
      End
      Execute nspGetRight null,  -- Facility
         null,  -- Storer
         null,  -- Sku
         'INVENTORY HOLD - INTERFACE',      -- ConfigKey
         @b_success    output, 
         @c_authority  output, 
         @n_err        output, 
         @c_errmsg     output
      If @b_success <> 1
      Begin
         SELECT @n_continue = 3
         SELECT @n_err = 62476
         Select @c_errmsg = 'ntrInventoryHoldAdd: ' + dbo.fnc_RTrim(@c_errmsg)
         Break
      End
      Else 
      Begin
      If @c_authority = '1'
         Select @b_interface = '1'
      Else
         Select @b_interface = '0'
      End

      If @b_interface = '1'
      BEGIN
         If dbo.fnc_RTrim(@c_loc) is not null and @c_hold = '1' 
         Begin
   	      EXECUTE nspg_getkey
   	         'TransmitlogKey'
   	         ,10
   	         , @c_transmitlogkey OUTPUT
   	         , @b_success OUTPUT
   	         , @n_err OUTPUT
   	         , @c_errmsg OUTPUT
   	      IF NOT @b_success=1
   	      BEGIN
   	         SELECT @n_continue=3
   	         SELECT @n_err = 62477
   	         SELECT @c_errmsg = 'ntrInventoryHoldAdd: ' + dbo.fnc_RTrim(@c_errmsg)
   	      END
   	
   	      IF ( @n_continue = 1 or @n_continue = 2 ) 
   	      BEGIN
   	         INSERT TRANSMITLOG  (Transmitlogkey, tablename, key1, key2, key3,  transmitflag)
   	         VALUES  (@c_transmitlogkey, "InventoryHold", @c_primarykey, '', 'HOLD','0')
   	         SELECT @n_err= @@Error
   	         IF NOT @n_err=0
   	         BEGIN
   	            SELECT @n_continue=3 
   	            /* Trap SQL Server Error */
   	            Select @n_err = 62478 -- 99701
   	            Select @c_errmsg= 'NSQL'+CONVERT(char(5), @n_err)+':Insert Into TransmitLog Table (InventoryHold) Failed. (ntrInventoryHoldAdd)'+'('+'SQLSvr MESSAGE='+dbo.fnc_LTrim(dbo.fnc_RTrim(@c_errmsg))+')' 
   	         /* End Trap SQL Server Error */
               END
   	      END   
   	   End
	   End
    End
   /* IDSV5 - Leo */

   /* #INCLUDE <TRADA2.SQL> */
   IF @n_continue = 3  -- Error Occured - Process And Return
   BEGIN
      DECLARE @n_IsRDT INT
      EXECUTE RDT.rdtIsRDT @n_IsRDT OUTPUT
   
      IF @n_IsRDT = 1
      BEGIN
         -- RDT cannot handle rollback (blank XML will generate). So we are not going to issue a rollback here
         -- Instead we commit and raise an error back to parent, let the parent decide
   
         -- Commit until the level we begin with
         WHILE @@TRANCOUNT > @n_starttcnt
            COMMIT TRAN
   
         -- Raise error with severity = 10, instead of the default severity 16. 
         -- RDT cannot handle error with severity > 10, which stop the processing after executed this trigger
         RAISERROR (@n_err, 10, 1) WITH SETERROR 
   
         -- The RAISERROR has to be last line, to ensure @@ERROR is not getting overwritten
      END
      ELSE
      BEGIN
         IF @@TRANCOUNT = 1 AND @@TRANCOUNT >= @n_starttcnt
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
         EXECUTE nsp_logerror @n_err, @c_errmsg, 'ntrInventoryHoldAdd'
         RAISERROR (@c_errmsg, 16, 1) WITH SETERROR    -- SQL2012
         RETURN
      END
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
/* Trigger: ntrInventoryHoldDelete                                      */  
/* Creation Date:                                                       */  
/* Copyright: IDS                                                       */  
/* Written by:                                                          */  
/*                                                                      */  
/* Purpose:                                                             */  
/*                                                                      */  
/* Usage:                                                               */  
/*                                                                      */  
/* Called By: When delete records in Inventoryhold                      */  
/*                                                                      */  
/* PVCS Version: 1.0                                                    */  
/*                                                                      */  
/* Version: 5.4                                                         */  
/*                                                                      */  
/* Data Modifications:                                                  */  
/*                                                                      */  
/* Updates:                                                             */  
/* Date         Author   Ver  Purposes                                  */  
/* 2010-06-18   SHONG    1.1  Insert TableDeleteLog                     */
/* 27-Apr-2011  KHLim01  1.2  Insert Delete log                         */
/* 14-Jul-2011  KHLim02  1.3  GetRight for Delete log                   */
/************************************************************************/  
  
CREATE TRIGGER [dbo].[ntrInventoryHoldDelete]
ON [dbo].[INVENTORYHOLD]
FOR  DELETE
AS
BEGIN
    IF @@ROWCOUNT=0
    BEGIN
        RETURN
    END  

    SET NOCOUNT ON 
    SET ANSI_NULLS OFF  
    SET QUOTED_IDENTIFIER OFF  
    SET CONCAT_NULL_YIELDS_NULL OFF  
        
    DECLARE @b_Success    INT	-- Populated by calls to stored procedures - was the proc successful?
           ,@n_err        INT	-- Error number returned by stored procedure or this trigger
           ,@c_errmsg     NVARCHAR(250)	-- Error message returned by stored procedure or this trigger
           ,@n_continue   INT	-- continuation flag: 1=Continue, 2=failed but continue processsing, 3=failed do not continue processing, 4=successful but skip further processing
           ,@n_starttcnt  INT	-- Holds the current transaction count
           ,@n_cnt        INT -- Holds the number of rows affected by the DELETE statement that fired this trigger.  
           ,@c_authority  NVARCHAR(1)  -- KHLim02
    SELECT @n_continue = 1
          ,@n_starttcnt = @@TRANCOUNT
    
    IF (
           SELECT COUNT(*)
           FROM   DELETED
       )=(
           SELECT COUNT(*)
           FROM   DELETED
           WHERE  DELETED.ArchiveCop = '9'
       )
    BEGIN
        SELECT @n_continue = 4
    END 
    
    /* #INCLUDE <TRWAVEHD1.SQL> */       
    IF @n_continue=1
       OR @n_continue=2
    BEGIN
        IF EXISTS (
               SELECT 1
               FROM   DELETED
               WHERE  Hold = '1'
           )
        BEGIN
            SELECT @n_continue = 3  
            SELECT @n_err = 84502  
            SELECT @c_errmsg = 'NSQL'+CONVERT(CHAR(5) ,@n_err)+
                   ': DELETE rejected. Inventory Still On Hold. (ntrInventoryHoldDelete)'
        END
    END  

    IF @n_continue=1 OR @n_continue=2
    BEGIN
       INSERT INTO TableDeleteLog
       (
          TableName,   Col1,    Col2,    Col3,   Col4,  Col5, Remarks
       )
       SELECT 'INVENTORYHOLD', InventoryHoldKey, LOT, LOC, ID, SKU, ''
       FROM   DELETED       
    END
        
    IF @n_continue=1
       OR @n_continue=2
    BEGIN
        DELETE InventoryHold
        FROM   InventoryHold
              ,DELETED
        WHERE  InventoryHold.InventoryHoldKey = DELETED.InventoryHoldKey  
        
        SELECT @n_err = @@ERROR
              ,@n_cnt = @@ROWCOUNT  
        
        IF @n_err<>0
        BEGIN
            SELECT @n_continue = 3  
            SELECT @c_errmsg = CONVERT(CHAR(250) ,@n_err)
                  ,@n_err = 84501 -- Should Be Set To The SQL Errmessage but I don't know how to do so.  
            SELECT @c_errmsg = 'NSQL'+CONVERT(CHAR(5) ,@n_err)+
                   ': Delete Trigger On Table InventoryHold Failed. (ntrInventoryHoldDelete)' 
                  +' ( '+' SQLSvr MESSAGE='+LTRIM(RTRIM(@c_errmsg))+' ) '
        END
    END 

   -- Start (KHLim01) 
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
               ,@c_errmsg = 'ntrINVENTORYHOLDDelete' + dbo.fnc_RTrim(@c_errmsg)
      END
      ELSE 
      IF @c_authority = '1'         --    End   (KHLim02)
      BEGIN
         INSERT INTO dbo.INVENTORYHOLD_DELLOG ( InventoryHoldKey )
         SELECT InventoryHoldKey FROM DELETED

         SELECT @n_err = @@ERROR, @n_cnt = @@ROWCOUNT
         IF @n_err <> 0
         BEGIN
            SELECT @n_continue = 3
            SELECT @c_errmsg = CONVERT(CHAR(250),@n_err), @n_err = 68101   -- Should Be Set To The SQL Errmessage but I don't know how to do so.
            SELECT @c_errmsg='NSQL'+CONVERT(char(5),@n_err)+': Delete Trigger On Table INVENTORYHOLD Failed. (ntrINVENTORYHOLDDelete)' + ' ( ' + ' SQLSvr MESSAGE=' + LTrim(RTrim(@c_errmsg)) + ' ) '
         END
      END
   END
   -- End (KHLim01) 

    /* #INCLUDE <TRWAVEHD2.SQL> */  
    IF @n_continue=3 -- Error Occured - Process And Return
    BEGIN
        IF @@TRANCOUNT=1
           AND @@TRANCOUNT>=@n_starttcnt
        BEGIN
            ROLLBACK TRAN
        END
        ELSE
        BEGIN
            WHILE @@TRANCOUNT>@n_starttcnt
            BEGIN
                COMMIT TRAN
            END
        END 
        EXECUTE nsp_logerror @n_err, @c_errmsg, 'ntrInventoryHoldDelete' 
        RAISERROR (@c_errmsg, 16, 1) WITH SETERROR    -- SQL2012 
        RETURN
    END
    ELSE
    BEGIN
        WHILE @@TRANCOUNT>@n_starttcnt
        BEGIN
            COMMIT TRAN
        END 
        RETURN
    END
END  
  
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

/************************************************************************/  
/* Trigger:  ntrInventoryHoldUpdate                                     */  
/* Creation Date: 2011-4-11                                             */  
/* Copyright: IDS                                                       */  
/* Written by: KHLim                                                    */  
/*                                                                      */  
/* Purpose:                                                             */  
/*                                                                      */  
/* Input Parameters:                                                    */  
/*                                                                      */  
/* Output Parameters:  None                                             */  
/*                                                                      */  
/* Return Status:  None                                                 */  
/*                                                                      */  
/* Usage:                                                               */  
/*                                                                      */  
/* Local Variables:                                                     */  
/*                                                                      */  
/* Called By: When records updated                                      */  
/*                                                                      */  
/* PVCS Version: 1.0                                                    */  
/*                                                                      */  
/* Version: 5.4                                                         */  
/*                                                                      */  
/* Data Modifications:                                                  */  
/*                                                                      */  
/* Updates:                                                             */  
/* Date         Author    Ver.  Purposes                                */  
/* 2011-06-06   KHLim     1.0   SET WhoOff = WhoOn                      */  
/* 2011-06-24   KHLim01   1.0   add UPDATE(TrafficCop) to allow bypass  */  
/* 2015-09-11   MCTang    1.1   ADD INVHCHGLOG (MC01)                   */ 
/************************************************************************/  
CREATE TRIGGER [dbo].[ntrInventoryHoldUpdate]  
ON  [dbo].[INVENTORYHOLD]  
FOR UPDATE   
AS   
IF @@ROWCOUNT = 0   
BEGIN   
   RETURN   
END   
   SET NOCOUNT ON   
   SET ANSI_NULLS OFF  
   SET QUOTED_IDENTIFIER OFF   
   SET CONCAT_NULL_YIELDS_NULL OFF   
  
DECLARE @b_Success     int       -- Populated by calls to stored procedures - was the proc successful?  
      , @n_err         int       -- Error number returned by stored procedure or this trigger  
      , @n_err2        int       -- For Additional Error Detection  
      , @c_errmsg      Nvarchar(250) -- Error message returned by stored procedure or this trigger  
      , @n_continue    int  
      , @n_starttcnt   int       -- Holds the current transaction count  
      , @c_preprocess  Nvarchar(250) -- preprocess  
      , @c_pstprocess  Nvarchar(250) -- post process  
      , @n_cnt         int  
      , @b_debug       int  

      , @c_InventoryHoldKey   NVARCHAR(10) 
      , @c_TransmitLogKey     NVARCHAR(10) 
      , @c_StorerKey          NVARCHAR(15)
      , @c_Lot                NVARCHAR(10) 
      , @c_ID                 NVARCHAR(18)
      , @c_DelStatus          NVARCHAR(5)
  
SELECT @n_continue=1, @n_starttcnt=@@TRANCOUNT, @b_debug = 0  
  
IF UPDATE(TrafficCop)         -- KHLim01  
BEGIN  
   SELECT @n_continue = 4  
END  
  
IF (@n_continue = 1 OR @n_continue= 2) AND UPDATE(Hold)  
BEGIN  
   IF EXISTS (SELECT 1 FROM INSERTED, DELETED  
              WHERE INSERTED.InventoryHoldKey = DELETED.InventoryHoldKey  
              AND INSERTED.Hold <> DELETED.Hold  
              AND INSERTED.Hold = '1')  
   BEGIN  
      UPDATE InventoryHold  
      SET InventoryHold.DateOff = InventoryHold.DateOn,  
          InventoryHold.WhoOff = InventoryHold.WhoOn  
      FROM InventoryHold, INSERTED ,DELETED   
      WHERE InventoryHold.InventoryHoldKey = INSERTED.InventoryHoldKey  
      AND DELETED.InventoryHoldKey = INSERTED.InventoryHoldKey    
      AND INSERTED.Hold <> DELETED.Hold  
      AND INSERTED.Hold = '1'  
      SELECT @n_err = @@ERROR  
      IF @n_err <> 0  
      BEGIN  
         SELECT @n_continue = 3  
         SELECT @c_errmsg = CONVERT(char(250),@n_err), @n_err = 70001   
         SELECT @c_errmsg = 'NSQL' + CONVERT(char(5),ISNULL(@n_err,0))   
                          + ': Unable to Update InventoryHold table (ntrInventoryHoldUpdate)'   
                          + ' ( SQLSvr MESSAGE=' + dbo.fnc_LTrim(dbo.fnc_RTrim(@c_errmsg)) + ' ) '   
      END  
   END  
END  
  
--(MC01) - S
IF ( @n_Continue = 1 OR @n_Continue = 2 ) AND UPDATE(Status)
BEGIN
   DECLARE INVH_CUR CURSOR LOCAL READ_ONLY FAST_FORWARD FOR  
   SELECT InventoryHoldKey  
   FROM   INSERTED  
  
   OPEN INVH_CUR  
   FETCH NEXT FROM INVH_CUR INTO @c_InventoryHoldKey
  
   WHILE @@FETCH_STATUS <> -1  AND (@n_continue = 1 OR @n_continue = 2)  
   BEGIN 
      IF EXISTS (SELECT 1 FROM INSERTED, DELETED  
                 WHERE INSERTED.InventoryHoldKey = DELETED.InventoryHoldKey  
                 AND   INSERTED.Status <> DELETED.Status
                 AND   INSERTED.InventoryHoldKey = @c_InventoryHoldKey)  
      BEGIN
         SELECT @c_StorerKey = ISNULL(INSERTED.Storerkey, '')
              , @c_Lot = ISNULL(INSERTED.LOT, '')
              , @c_ID = ISNULL(INSERTED.ID, '')
         FROM   INSERTED
         WHERE  InventoryHoldKey = @c_InventoryHoldKey

         IF @c_StorerKey = ''
         BEGIN
            IF @c_Lot <> ''
            BEGIN
               SELECT @c_StorerKey = ISNULL(Storerkey, '')
               FROM   LOT WITH (NOLOCK)
               WHERE  LOT = @c_Lot
            END
            IF @c_ID <> ''
            BEGIN
               SELECT TOP 1 @c_StorerKey = ISNULL(Storerkey, '')
               FROM   LOTXLOCXID WITH (NOLOCK)
               WHERE  ID = @c_ID
            END
         END

         IF @c_StorerKey <> ''
         BEGIN
            IF EXISTS(SELECT 1 FROM StorerConfig (NOLOCK)   
                      WHERE StorerKey = @c_StorerKey   
                      AND   ConfigKey = 'INVHCHGLOG' )   
            BEGIN  

               SELECT @c_DelStatus = ISNULL(DELETED.Status, '')
               FROM  INSERTED, DELETED  
               WHERE INSERTED.InventoryHoldKey = DELETED.InventoryHoldKey  
               AND   INSERTED.InventoryHoldKey = @c_InventoryHoldKey

               SELECT @c_TransmitLogKey = ''  
               SELECT @b_success = 1  
               EXECUTE nspg_getkey  
                      'TransmitlogKey3'  
                    , 10  
                    , @c_TransmitLogKey OUTPUT  
                    , @b_success        OUTPUT  
                    , @n_err            OUTPUT  
                    , @c_errmsg         OUTPUT  

               IF @b_success <> 1  
               BEGIN  
                  SELECT @n_continue = 3  
                  SELECT @c_errmsg = CONVERT(char(250),@n_err), @n_err = 70001   
                  SELECT @c_errmsg = 'NSQL' + CONVERT(char(5),ISNULL(@n_err,0))   
                                   + ': Unable to obtain transmitlogkey. (ntrInventoryHoldUpdate)'   
                                   + ' ( SQLSvr MESSAGE=' + dbo.fnc_LTrim(dbo.fnc_RTrim(@c_errmsg)) + ' ) '  
               END  
               ELSE  
               BEGIN  

                  INSERT INTO TRANSMITLOG3 (Transmitlogkey, Tablename, Key1, Key2, Key3, Transmitflag)  
                  VALUES (@c_TransmitLogKey, 'INVHCHGLOG', @c_InventoryHoldKey, @c_DelStatus, @c_StorerKey, '0')  

                  IF @@ROWCOUNT=0  
                  BEGIN  
                     SELECT @n_continue = 3  
                     SELECT @c_errmsg = CONVERT(char(250),@n_err), @n_err = 70001   
                     SELECT @c_errmsg = 'NSQL' + CONVERT(char(5),ISNULL(@n_err,0))   
                                      + ': Unable insert TRANSMITLOG3 Table. (ntrInventoryHoldUpdate)'   
                                      + ' ( SQLSvr MESSAGE=' + dbo.fnc_LTrim(dbo.fnc_RTrim(@c_errmsg)) + ' ) '     
                  END   
               END  
            END --ConfigKey = 'INVHCHGLOG'
         END --IF @c_StorerKey <> '' 
      END
      FETCH NEXT FROM INVH_CUR INTO @c_InventoryHoldKey
   END -- while orderkey  
   CLOSE INVH_CUR  
   DEALLOCATE INVH_CUR
END
--(MC01) - E

      /* #INCLUDE <TRMBOHU2.SQL> */  
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
   EXECUTE nsp_logerror @n_err, @c_errmsg, 'ntrInventoryHoldUpdate'   
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
GO
ALTER TABLE [dbo].[INVENTORYHOLD] WITH NOCHECK ADD CONSTRAINT [CK_IH_01] CHECK ((NOT ltrim(rtrim([Lot]))='' AND ltrim(rtrim([Loc]))='' AND ltrim(rtrim([id]))='' AND isnull(ltrim(rtrim([lottable01])),' ')=' ' AND isnull(ltrim(rtrim([lottable02])),' ')=' ' AND isnull(ltrim(rtrim([lottable03])),' ')=' ' AND isnull([lottable04],' ')=' ' AND isnull([lottable05],' ')=' ' AND isnull(ltrim(rtrim([lottable06])),' ')=' ' AND isnull(ltrim(rtrim([lottable07])),' ')=' ' AND isnull(ltrim(rtrim([lottable08])),' ')=' ' AND isnull(ltrim(rtrim([lottable09])),' ')=' ' AND isnull(ltrim(rtrim([lottable10])),' ')=' ' AND isnull(ltrim(rtrim([lottable11])),' ')=' ' AND isnull(ltrim(rtrim([lottable12])),' ')=' ' AND isnull([lottable13],' ')=' ' AND isnull([lottable14],' ')=' ' AND isnull([lottable15],' ')=' ' OR ltrim(rtrim([Lot]))='' AND NOT ltrim(rtrim([Loc]))='' AND ltrim(rtrim([id]))='' AND isnull(ltrim(rtrim([lottable01])),' ')=' ' AND isnull(ltrim(rtrim([lottable02])),' ')=' ' AND isnull(ltrim(rtrim([lottable03])),' ')=' ' AND isnull([lottable04],' ')=' ' AND isnull([lottable05],' ')=' ' AND isnull(ltrim(rtrim([lottable06])),' ')=' ' AND isnull(ltrim(rtrim([lottable07])),' ')=' ' AND isnull(ltrim(rtrim([lottable08])),' ')=' ' AND isnull(ltrim(rtrim([lottable09])),' ')=' ' AND isnull(ltrim(rtrim([lottable10])),' ')=' ' AND isnull(ltrim(rtrim([lottable11])),' ')=' ' AND isnull(ltrim(rtrim([lottable12])),' ')=' ' AND isnull([lottable13],' ')=' ' AND isnull([lottable14],' ')=' ' AND isnull([lottable15],' ')=' ' OR ltrim(rtrim([Lot]))='' AND ltrim(rtrim([Loc]))='' AND NOT ltrim(rtrim([id]))='' AND isnull(ltrim(rtrim([lottable01])),' ')=' ' AND isnull(ltrim(rtrim([lottable02])),' ')=' ' AND isnull(ltrim(rtrim([lottable03])),' ')=' ' AND isnull([lottable04],' ')=' ' AND isnull([lottable05],' ')=' ' AND isnull(ltrim(rtrim([lottable06])),' ')=' ' AND isnull(ltrim(rtrim([lottable07])),' ')=' ' AND isnull(ltrim(rtrim([lottable08])),' ')=' ' AND isnull(ltrim(rtrim([lottable09])),' ')=' ' AND isnull(ltrim(rtrim([lottable10])),' ')=' ' AND isnull(ltrim(rtrim([lottable11])),' ')=' ' AND isnull(ltrim(rtrim([lottable12])),' ')=' ' AND isnull([lottable13],' ')=' ' AND isnull([lottable14],' ')=' ' AND isnull([lottable15],' ')=' ' OR ltrim(rtrim([Lot]))='' AND ltrim(rtrim([Loc]))='' AND ltrim(rtrim([id]))='' AND NOT ltrim(rtrim([storerkey]))='' AND NOT ltrim(rtrim([sku]))='' AND (NOT ltrim(rtrim([lottable01]))='' OR NOT ltrim(rtrim([lottable02]))='' OR NOT ltrim(rtrim([lottable03]))='' OR NOT [lottable04]='' OR NOT [lottable05]='' OR NOT ltrim(rtrim([lottable06]))='' OR NOT ltrim(rtrim([lottable07]))='' OR NOT ltrim(rtrim([lottable08]))='' OR NOT ltrim(rtrim([lottable09]))='' OR NOT ltrim(rtrim([lottable10]))='' OR NOT ltrim(rtrim([lottable11]))='' OR NOT ltrim(rtrim([lottable12]))='' OR NOT [lottable13]='' OR NOT [lottable14]='' OR NOT [lottable15]='')))
GO
ALTER TABLE [dbo].[INVENTORYHOLD] ADD CONSTRAINT [PKINVENTORYHOLD] PRIMARY KEY CLUSTERED ([InventoryHoldKey]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_INVENTORYHOLD_ID] ON [dbo].[INVENTORYHOLD] ([Id]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_INVENTORYHOLD_LOC] ON [dbo].[INVENTORYHOLD] ([Loc]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_INVENTORYHOLD_LOT] ON [dbo].[INVENTORYHOLD] ([Lot]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_INVENTORYHOLD_LOTATT] ON [dbo].[INVENTORYHOLD] ([Storerkey], [SKU], [Lottable01], [Lottable02], [Lottable03], [Lottable04], [Lottable06], [Lottable07], [Lottable08], [Lottable09], [Lottable10], [Lottable11], [Lottable12], [Lottable13], [Lottable14], [Lottable15]) ON [PRIMARY]
GO
GRANT SELECT ON  [dbo].[INVENTORYHOLD] TO [JReportRole]
GO
GRANT DELETE ON  [dbo].[INVENTORYHOLD] TO [NSQL]
GO
GRANT INSERT ON  [dbo].[INVENTORYHOLD] TO [NSQL]
GO
GRANT SELECT ON  [dbo].[INVENTORYHOLD] TO [NSQL]
GO
GRANT UPDATE ON  [dbo].[INVENTORYHOLD] TO [NSQL]
GO
EXEC sp_addextendedproperty N'MS_Description', 'In WMS, an Inventory Hold is used to maintain inventory visibility but prevent shipments. User is able to put inventory on hold according to the lot#, pallet id and location via the inventory hold window. Locations can also be put on hold on the location window.', 'SCHEMA', N'dbo', 'TABLE', N'INVENTORYHOLD', NULL, NULL
GO
EXEC sp_addextendedproperty N'MS_Description', 'Date and time the transaction was last entered.', 'SCHEMA', N'dbo', 'TABLE', N'INVENTORYHOLD', 'COLUMN', N'DateOff'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Date and time the transaction was entered.', 'SCHEMA', N'dbo', 'TABLE', N'INVENTORYHOLD', 'COLUMN', N'DateOn'
GO
EXEC sp_addextendedproperty N'MS_Description', 'To hold the item', 'SCHEMA', N'dbo', 'TABLE', N'INVENTORYHOLD', 'COLUMN', N'Hold'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Movable Unit ID for the Commodity being received', 'SCHEMA', N'dbo', 'TABLE', N'INVENTORYHOLD', 'COLUMN', N'Id'
GO
EXEC sp_addextendedproperty N'MS_Description', 'The Inventory Hold unique key', 'SCHEMA', N'dbo', 'TABLE', N'INVENTORYHOLD', 'COLUMN', N'InventoryHoldKey'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Physical location of the Commodity in the warehouse', 'SCHEMA', N'dbo', 'TABLE', N'INVENTORYHOLD', 'COLUMN', N'Loc'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Lot number assigned to the Commodity', 'SCHEMA', N'dbo', 'TABLE', N'INVENTORYHOLD', 'COLUMN', N'Lot'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Lot attribute of the Commodity', 'SCHEMA', N'dbo', 'TABLE', N'INVENTORYHOLD', 'COLUMN', N'Lottable01'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Lot attribute of the Commodity', 'SCHEMA', N'dbo', 'TABLE', N'INVENTORYHOLD', 'COLUMN', N'Lottable02'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Lot attribute of the Commodity', 'SCHEMA', N'dbo', 'TABLE', N'INVENTORYHOLD', 'COLUMN', N'Lottable03'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Expiry Date', 'SCHEMA', N'dbo', 'TABLE', N'INVENTORYHOLD', 'COLUMN', N'Lottable04'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Receipt Date', 'SCHEMA', N'dbo', 'TABLE', N'INVENTORYHOLD', 'COLUMN', N'Lottable05'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Remarks', 'SCHEMA', N'dbo', 'TABLE', N'INVENTORYHOLD', 'COLUMN', N'Remark'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Unique code identifying the product.', 'SCHEMA', N'dbo', 'TABLE', N'INVENTORYHOLD', 'COLUMN', N'SKU'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Reason for the hold', 'SCHEMA', N'dbo', 'TABLE', N'INVENTORYHOLD', 'COLUMN', N'Status'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Unique key to the storer record', 'SCHEMA', N'dbo', 'TABLE', N'INVENTORYHOLD', 'COLUMN', N'Storerkey'
GO
EXEC sp_addextendedproperty N'MS_Description', 'When checked, fields updated in this table will not trigger to update other tables that are linked with this table.', 'SCHEMA', N'dbo', 'TABLE', N'INVENTORYHOLD', 'COLUMN', N'TrafficCop'
GO
EXEC sp_addextendedproperty N'MS_Description', 'User ID of the person signed onto the system when the transaction was last entered.', 'SCHEMA', N'dbo', 'TABLE', N'INVENTORYHOLD', 'COLUMN', N'WhoOff'
GO
EXEC sp_addextendedproperty N'MS_Description', 'User ID of the person signed onto the system when the transaction was entered.', 'SCHEMA', N'dbo', 'TABLE', N'INVENTORYHOLD', 'COLUMN', N'WhoOn'
GO
