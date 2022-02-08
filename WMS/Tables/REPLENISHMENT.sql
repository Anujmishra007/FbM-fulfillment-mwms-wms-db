CREATE TABLE [dbo].[REPLENISHMENT]
(
[ReplenishmentKey] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ReplenishmentGroup] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Storerkey] [nvarchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Sku] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[FromLoc] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ToLoc] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Lot] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Id] [nvarchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Qty] [int] NOT NULL,
[QtyMoved] [int] NULL CONSTRAINT [DF_REPLENISHMENT_QtyMoved] DEFAULT ((0)),
[QtyInPickLoc] [int] NULL CONSTRAINT [DF_REPLENISHMENT_QtyInPickLoc] DEFAULT ((0)),
[Priority] [nvarchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_REPLENISHMENT_Priority] DEFAULT ('99999'),
[UOM] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[PackKey] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ArchiveCop] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Confirmed] [nvarchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ReplenNo] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_REPLENISHMENT_ReplenNo] DEFAULT (' '),
[Remark] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[AddDate] [datetime] NOT NULL CONSTRAINT [DF_REPLENISHMENT_AddDate] DEFAULT (getdate()),
[AddWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_REPLENISHMENT_AddWho] DEFAULT (suser_sname()),
[EditDate] [datetime] NOT NULL CONSTRAINT [DF_REPLENISHMENT_EditDate] DEFAULT (getdate()),
[EditWho] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_REPLENISHMENT_EditWho] DEFAULT (suser_sname()),
[RefNo] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_REPLENISHMENT_RefNo] DEFAULT (' '),
[DropID] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_REPLENISHMENT_DropID] DEFAULT (''),
[LoadKey] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_REPLENISHMENT_LoadKey] DEFAULT (' '),
[Wavekey] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_REPLENISHMENT_Wavekey] DEFAULT (''),
[OriginalFromLoc] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_REPLENISHMENT_OriginalFromLoc] DEFAULT (''),
[OriginalQty] [int] NULL CONSTRAINT [DF_REPLENISHMENT_OriginalQty] DEFAULT ((0)),
[ToID] [nvarchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_REPLENISHMENT_ToID] DEFAULT (''),
[MoveRefKey] [nvarchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF_Replenishment_MoveRefKey] DEFAULT (''),
[PendingMoveIn] [int] NULL CONSTRAINT [DF_REPLENISHMENT_PendingMoveIn] DEFAULT ((0)),
[QtyReplen] [int] NULL CONSTRAINT [DF_REPLENISHMENT_QtyReplen] DEFAULT ((0))
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO
/************************************************************************/
/* Trigger: ntrReplenishmentAdd                                         */
/* Creation Date:                                                       */
/* Copyright: IDS                                                       */
/* Written by:                                                          */
/*                                                                      */
/* Purpose:                                                             */
/*                                                                      */
/* Called By:                                                           */
/*                                                                      */
/* PVCS Version: 1.3                                                    */
/*                                                                      */
/* Version: 5.4                                                         */
/*                                                                      */
/* Data Modifications:                                                  */
/*                                                                      */
/* Updates:                                                             */
/* Date         Ver     Author   Purposes                               */
/* 12-Jul-2017  1.0     Shong    Created                                */
/************************************************************************/
CREATE TRIGGER [dbo].[ntrReplenishmentAdd]
ON [dbo].[REPLENISHMENT]
FOR  INSERT
AS
BEGIN
    SET NOCOUNT ON
    SET ANSI_NULLS OFF  
    SET QUOTED_IDENTIFIER OFF
    SET CONCAT_NULL_YIELDS_NULL OFF

    DECLARE @b_Success       INT -- Populated by calls to stored procedures - was the proc successful?
           ,@n_Err           INT -- Error number returned by stored procedure or this trigger
           ,@n_Err2          INT -- For Additional Error Detection
           ,@c_Errmsg        NVARCHAR(250) -- Error message returned by stored procedure or this trigger
           ,@n_Continue      INT
           ,@n_Starttcnt     INT -- Holds the current transaction count
           ,@c_Preprocess    NVARCHAR(250) -- preprocess
           ,@c_Pstprocess    NVARCHAR(250) -- post process
           ,@n_Cnt           INT
           ,@n_PendingMoveIn INT 
           ,@n_QtyReplen     INT 

   
   DECLARE @c_SourceType     NVARCHAR(10)

   DECLARE @n_IsRDT INT

   SET @c_SourceType    = ''

    SELECT @n_Continue = 1
          ,@n_starttcnt = @@TRANCOUNT
    /* #INCLUDE <TRTASKDA1.SQL> */

   IF @n_Continue = 1 OR @n_Continue = 2      
      BEGIN      
      IF EXISTS (SELECT 1 FROM INSERTED WHERE ArchiveCop = '9')      
      BEGIN      
         SELECT @n_Continue = 4      
      END      
   END   

    IF @n_Continue=1 OR  @n_Continue=2
    BEGIN
        DECLARE @c_Replenishmentkey     NVARCHAR(10)

        DECLARE @c_FromLoc           NVARCHAR(10)
               ,@c_FromID            NVARCHAR(18)
               ,@c_ToLoc             NVARCHAR(10)
               ,@c_ToID              NVARCHAR(18)
               ,@c_LOT               NVARCHAR(10)
               ,@n_Qty               INT
               ,@c_PackKey           NVARCHAR(10)
               ,@c_UOM               NVARCHAR(5)
               ,@c_CaseID            NVARCHAR(10)
               ,@c_SourceKey         NVARCHAR(30)
               ,@c_Status            NVARCHAR(10)
               ,@c_ReasonKey         NVARCHAR(10)
               ,@n_UOMQty            INT
               ,@c_Storerkey         NVARCHAR(15)
               ,@c_SKU               NVARCHAR(20) 

        SELECT @c_Replenishmentkey = ''
        WHILE (1=1)
        BEGIN
            SELECT TOP 1
                   @c_Replenishmentkey = Replenishmentkey
                  ,@c_LOT = Lot
                  ,@c_FromID = Id
                  ,@c_FromLoc = FromLoc
                  ,@c_ToLoc = ToLoc
                  ,@c_ToID = ISNULL(ToID, ISNULL(ID,'') )
                  ,@n_QtyReplen = QtyReplen           
                  ,@n_PendingMoveIn = PendingMoveIn 
                  ,@c_Storerkey = StorerKey 
                  ,@c_SKU = SKU                    
            FROM   INSERTED
            WHERE  Replenishmentkey > @c_Replenishmentkey
            ORDER BY Replenishmentkey

            IF @@ROWCOUNT=0
            BEGIN
                BREAK
            END
            
            IF @n_Continue IN(1,2)  
            BEGIN
            	 IF @n_QtyReplen > 0 AND ISNULL(@c_LOT,'') <> '' AND ISNULL(@c_FromLoc,'') <> '' 
            	 BEGIN
                  IF EXISTS(SELECT 1 FROM LOTxLOCxID (NOLOCK)                                                         
                            WHERE LOT = @c_LOT                                                                        
                            AND LOC = @c_FromLoc                                                                      
                            AND ID = @c_FromID)                                                                       
                  BEGIN                                                                                               
                  	UPDATE LOTxLOCxID WITH (ROWLOCK)                                                                 
                  	   SET QtyReplen = ISNULL(QtyReplen,0) + @n_QtyReplen                                                  
                     WHERE LOT = @c_LOT                                                                               
                     AND LOC = @c_FromLoc                                                                             
                     AND ID = @c_FromID                                                                               
                                                                                                                      
                     SET @n_err = @@ERROR                                                                             
                                                                                                                      
                     IF @n_err <> 0                                                                                   
                     BEGIN                                                                                            
                        SELECT @n_Continue = 3
                              ,@n_err = 67993 
                        SELECT @c_Errmsg = 'NSQL'+CONVERT(CHAR(5) ,@n_err)+
                               ':  Update LOTxLOCxID Failed! (ntrReplenishmentAdd)'
                     END                                                                                              
                  END                                                                                                 
            	 END
            	 IF @n_PendingMoveIn > 0 AND ISNULL(@c_LOT,'') <> '' AND ISNULL(@c_ToLoc,'') <> '' 
            	 BEGIN
                  IF EXISTS(SELECT 1 FROM LOTxLOCxID (NOLOCK)                                                         
                            WHERE LOT = @c_LOT                                                                        
                            AND LOC = @c_ToLoc                                                                      
                            AND ID = @c_ToID)                                                                       
                  BEGIN                                                                                               
                  	UPDATE LOTxLOCxID WITH (ROWLOCK)                                                                 
                  	   SET PendingMoveIn = ISNULL(PendingMoveIn,0) + @n_PendingMoveIn                                                  
                     WHERE LOT = @c_LOT                                                                               
                     AND LOC = @c_ToLoc                                                                             
                     AND ID = @c_ToID                                                                               
                                                                                                                      
                     SET @n_err = @@ERROR                                                                                                                                                                                                   
                     IF @n_err <> 0                                                                                   
                     BEGIN                                                                                            
                        SELECT @n_Continue = 3
                              ,@n_err = 67993 
                        SELECT @c_Errmsg = 'NSQL'+CONVERT(CHAR(5) ,@n_err)+
                               ':  Update LOTxLOCxID Failed! (ntrReplenishmentAdd)'
                     END                                                                                              
                  END
                  ELSE 
                  BEGIN
                  	INSERT INTO LOTxLOCxID (Lot, Loc, Id, StorerKey, Sku, Qty,
                  	            QtyAllocated, QtyPicked, QtyExpected,
                  	            PendingMoveIN, QtyReplen)
                  	VALUES (@c_LOT, @c_ToLoc, @c_ToID, @c_Storerkey, @c_SKU, 0,
                  	        0, 0, 0, @n_PendingMoveIn, 0)
                  	        
                     SET @n_err = @@ERROR                                                                                                                                                                                                   
                     IF @n_err <> 0                                                                                   
                     BEGIN                                                                                            
                        SELECT @n_Continue = 3
                              ,@n_err = 67994 
                        SELECT @c_Errmsg = 'NSQL'+CONVERT(CHAR(5) ,@n_err)+
                               ':  INSERT LOTxLOCxID Failed! (ntrReplenishmentAdd)'
                     END                       	        
                  END                                                                                                 
            	 END            	 
            END
        END -- WHILE 1=1
    END
    /* #INCLUDE <TRTASKDA2.SQL> */
    IF @n_Continue=3 -- Error Occured - Process And Return
    BEGIN
        -- To support RDT - start
        EXECUTE RDT.rdtIsRDT @n_IsRDT OUTPUT

        IF @n_IsRDT=1
        BEGIN
            -- RDT cannot handle rollback (blank XML will generate). So we are not going to issue a rollback here
            -- Instead we commit and raise an error back to parent, let the parent decide

            -- Commit until the level we begin with
            WHILE @@TRANCOUNT>@n_starttcnt
                  COMMIT TRAN

            -- Raise error with severity = 10, instead of the default severity 16.
            -- RDT cannot handle error with severity > 10, which stop the processing after executed this trigger
            RAISERROR (@n_err ,10 ,1) WITH SETERROR

            -- The RAISERROR has to be last line, to ensure @@ERROR is not getting overwritten
        END
        ELSE
        BEGIN
            IF @@TRANCOUNT=1 AND
               @@TRANCOUNT>=@n_starttcnt
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
            EXECUTE nsp_logerror @n_err, @c_Errmsg, 'ntrReplenishmentAdd'
            RAISERROR (@c_Errmsg, 16, 1) WITH SETERROR    -- SQL2012
            RETURN
        END
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
SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO


/************************************************************************/  
/* Trigger:  ntrReplenishmentDelete                                     */  
/* Creation Date:                                                       */  
/* Copyright: IDS                                                       */  
/* Written by:                                                          */  
/*                                                                      */  
/* Purpose:  Trigger Inventory Move when Confirm Replenishment          */  
/*                                                                      */  
/*                                                                      */  
/*                                                                      */  
/*                                                                      */  
/* Usage:                                                               */  
/*                                                                      */  
/* Called By: Replenishment Record Delete                               */  
/*                                                                      */  
/* PVCS Version: 1.0                                                    */  
/*                                                                      */  
/* Version: 5.4                                                         */  
/*                                                                      */  
/* Data Modifications:                                                  */  
/*                                                                      */  
/* Updates:                                                             */  
/* Date         Author    Purposes                                      */  
/* 14-Jul-2011  KHLim02    1.2   GetRight for Delete log                */
/* 19-May-2017  SHONG     Include MoveRefNo when Calling Itrn Move      */
/* 07-JUL-2017  SHONG     Update QtyReplen and Double 11                */
/*                        PendingMoveIn to LotXLocXId (SWT01)           */ 
/************************************************************************/  
CREATE TRIGGER [dbo].[ntrReplenishmentDelete]
ON [dbo].[REPLENISHMENT]
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
        @n_continue    int,       -- continuation flag: 
                                  -- 1=Continue, 
                                  -- 2=failed but continue processsing, 
                                  -- 3=failed do not continue processing, 
                                  -- 4=successful but skip further processing
        @n_starttcnt   int,       -- Holds the current transaction count
        @n_cnt         int        -- Holds the number of rows affected by the DELETE statement that fired this trigger.
      , @c_authority   NVARCHAR(1)  -- KHLim02

                                    
   SELECT @n_continue=1, @n_starttcnt=@@TRANCOUNT
   
   IF (SELECT count(*) FROM DELETED) =
      (SELECT count(*) FROM DELETED WHERE DELETED.ArchiveCop = '9')
   BEGIN
      SELECT @n_continue = 4
   END

   IF @n_continue = 1 or @n_continue = 2
   BEGIN
      IF EXISTS(  
         SELECT 1  
         FROM NSQLCONFIG WITH (NOLOCK)  
         WHERE ConfigKey = 'RepleDelLog' AND  
               NSQLValue = '1'  
       )  
      BEGIN  
         INSERT INTO DEL_Replenishment 
               (ReplenishmentKey, ReplenishmentGroup, Storerkey, Sku, FromLoc, ToLoc, Lot, Id, Qty, QtyMoved, 
               QtyInPickLoc, Priority, UOM, PackKey, ArchiveCop, Confirmed, ReplenNo, Remark, AddDate, AddWho, 
               EditDate, EditWho, RefNo, DropID, LoadKey, Wavekey, OriginalFromLoc, OriginalQty, [ToID], 
               DeleteDate, DeleteWho, SourceType, [MoveRefKey], PendingMoveIn,
               QtyReplen )  
         SELECT ReplenishmentKey, ReplenishmentGroup, Storerkey, Sku, FromLoc, ToLoc, Lot, Id, Qty, QtyMoved, 
               QtyInPickLoc, Priority, UOM, PackKey, ArchiveCop, Confirmed, ReplenNo, Remark, AddDate, AddWho,
               EditDate, EditWho, RefNo, DropID, LoadKey, Wavekey, OriginalFromLoc, OriginalQty, [ToID], 
               getdate(), suser_sname(), 'delete', MoveRefKey, PendingMoveIn,
               QtyReplen
         FROM DELETED  
         SELECT @n_err = @@ERROR, @n_cnt = @@ROWCOUNT
         IF @n_err <> 0
         BEGIN
            SELECT @n_continue = 3
            SELECT @c_errmsg = CONVERT(CHAR(250),@n_err), @n_err = 68100   -- Should Be Set To The SQL Errmessage but I don't know how to do so.
            SELECT @c_errmsg='NSQL'+CONVERT(char(5),@n_err)+': Delete Trigger On Table REPLENISHMENT Failed. (ntrReplenishmentDelete)' + ' ( ' + ' SQLSvr MESSAGE=' + LTrim(RTrim(@c_errmsg)) + ' ) '
         END
      END
   END 
   
   DECLARE @c_ReplenishmentKey     NVARCHAR(10),
           @c_Storerkey            NVARCHAR(15),
           @c_Sku                  NVARCHAR(20),
           @c_FromLoc              NVARCHAR(10),
           @c_Lot                  NVARCHAR(10),
           @c_Id                   NVARCHAR(18),
           @n_Qty                  INT,
           @c_MoveRefKey           NVARCHAR(10),
           @c_PickDetailKey        NVARCHAR(18),
           @c_TaskDetailKey        NVARCHAR(10),
           @n_PickDetQty           INT          
         , @n_PendingMoveIn        INT --SWT01
         , @n_QtyReplen            INT --SWT01
         , @c_Confirmed            NVARCHAR(1) --SWT01 
         , @c_ToLoc                NVARCHAR(10)
         , @c_ToId                 NVARCHAR(18)
           
   IF @n_continue = 1 or @n_continue = 2
   BEGIN   	   
      DECLARE cur_Del_Replenishment CURSOR LOCAL FAST_FORWARD READ_ONLY FOR
      SELECT ReplenishmentKey, Storerkey, Sku, FromLoc, Lot, Id, Qty, 
             ISNULL(MoveRefKey,''), ISNULL(PendingMoveIn,0), ISNULL(QtyReplen, 0), 
             Confirmed, ToLoc, ISNULL(ToID, ISNULL(ID,'')) 
      FROM DELETED
   
      OPEN cur_Del_Replenishment
   
      FETCH FROM cur_Del_Replenishment INTO 
         @c_ReplenishmentKey, @c_Storerkey, @c_Sku,
         @c_FromLoc, @c_Lot, @c_Id, @n_Qty, @c_MoveRefKey, @n_PendingMoveIn, 
         @n_QtyReplen, @c_Confirmed, @c_ToLoc, @c_ToID  
   
      WHILE @@FETCH_STATUS = 0
      BEGIN
   	   IF @c_MoveRefKey <> ''
   	   BEGIN
   		   DECLARE cur_PickDetail CURSOR LOCAL FAST_FORWARD READ_ONLY FOR
   		   SELECT PickDetailKey, MoveRefKey 
   		   FROM PICKDETAIL WITH (NOLOCK) 
   		   WHERE Storerkey = @c_Storerkey
   		   AND   Sku = @c_Sku 
   		   AND   Lot = @c_Lot 
   		   AND   Loc = @c_FromLoc 
   		   AND   [Status] < '5'  
   		   AND  (MoveRefKey IS NOT NULL AND MoveRefKey <> '') 
   		
   		   OPEN cur_PickDetail
   		
   		   FETCH FROM cur_PickDetail INTO @c_PickDetailKey, @c_MoveRefKey
   		
   		   WHILE @@FETCH_STATUS = 0
   		   BEGIN
   			   UPDATE PICKDETAIL WITH (ROWLOCK)
   			   SET MoveRefKey = '', 
   			       TrafficCop = NULL,
   			       EditDate   = GETDATE(), 
   			       EditWho    = SUSER_SNAME()
   			   WHERE PickDetailKey = @c_PickDetailKey  
   		
   			   FETCH FROM cur_PickDetail INTO @c_PickDetailKey, @c_MoveRefKey
   		   END
   		   CLOSE cur_PickDetail
   		   DEALLOCATE cur_PickDetail
   	   END

         IF @n_QtyReplen > 0 AND ISNULL(@c_Lot,'') <> '' AND ISNULL(@c_FromLoc,'') <> '' AND @c_Confirmed  <> 'Y'
         BEGIN
            IF EXISTS(SELECT 1 FROM LOTXLOCXID (NOLOCK)                                                         
                      WHERE Lot = @c_Lot                                                                        
                      AND Loc = @c_FromLoc                                                                      
                      AND ID = @c_Id)                                                                       
            BEGIN                                                                                               
         	   UPDATE LOTXLOCXID WITH (ROWLOCK)                                                                 
               SET QtyReplen = CASE WHEN (QtyReplen - @n_QtyReplen) < 0 THEN 0 ELSE QtyReplen - @n_QtyReplen END,                                                   
                   EditWho = SUSER_SNAME(),
                   EditDate = GETDATE()
               WHERE Lot = @c_Lot                                                                               
               AND Loc = @c_FromLoc                                                                             
               AND ID = @c_Id                                                                               
                                                                                                             
               SET @n_err = @@ERROR                                                                             
                                                                                                             
               IF @n_err <> 0                                                                                   
               BEGIN                                                                                            
                  SELECT @n_continue = 3
                        ,@n_err = 68000 
                  SELECT @c_errmsg = 'NSQL'+CONVERT(CHAR(5) ,@n_err)+
                         ':  Update LOTXLOCXID Failed! (ntrReplenishmentDelete)'
               END                                                                                              
            END                                                                                                 
         END -- IF @n_QtyReplen > 0
        IF @n_PendingMoveIn > 0 AND ISNULL(@c_Lot,'') <> '' AND ISNULL(@c_ToLoc,'') <> '' AND @c_Confirmed  <> 'Y'
        BEGIN
           IF EXISTS(SELECT 1 FROM LOTXLOCXID (NOLOCK)                                                         
                     WHERE Lot = @c_Lot                                                                        
                     AND Loc = @c_ToLoc                                                                      
                     AND ID = @c_ToID)                                                                       
           BEGIN                                                                                               
       	 	  UPDATE LOTxLOCxID 
       	 	         SET PendingMoveIn = CASE WHEN (PendingMoveIn - @n_PendingMoveIn) < 0 THEN 0 
       	 	                                 ELSE PendingMoveIn - @n_PendingMoveIn 
       	 	                           END,
                        EditDate = GETDATE(),   
                        EditWho = SUSER_SNAME()       	 	         
       	 	  WHERE Lot = @c_LOT 
                AND LOC = @c_ToLoc      
                AND ID  = @c_ToID     
                                                                                                               
              SET @n_err = @@ERROR                                                                             
                                                                                                               
              IF @n_err <> 0                                                                                   
              BEGIN                                                                                            
                 SELECT @n_continue = 3
                       ,@n_err = 68001 
                 SELECT @c_errmsg = 'NSQL'+CONVERT(CHAR(5) ,@n_err)+
                        ':  Execute rdt.rdt_Putaway_PendingMoveIn Failed! (ntrTaskDetailDelete)'
              END                                                                                              
           END                                                                                                 
        END   
                        
         FETCH FROM cur_Del_Replenishment INTO 
                  @c_ReplenishmentKey, @c_Storerkey, @c_Sku,
                  @c_FromLoc, @c_Lot, @c_Id, @n_Qty, @c_MoveRefKey, @n_PendingMoveIn, 
                  @n_QtyReplen, @c_Confirmed, @c_ToLoc, @c_ToID   
      END
   
      CLOSE cur_Del_Replenishment
      DEALLOCATE cur_Del_Replenishment
   END -- IF @n_continue = 1 or @n_continue = 2   
   

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
               ,@c_errmsg = 'ntrReplenishmentDelete' + dbo.fnc_RTrim(@c_errmsg)
      END
      ELSE 
      IF @c_authority = '1'         --    End   (KHLim02)
      BEGIN
         INSERT INTO dbo.REPLENISHMENT_DELLOG ( ReplenishmentKey )
         SELECT ReplenishmentKey FROM DELETED

         SELECT @n_err = @@ERROR, @n_cnt = @@ROWCOUNT
         IF @n_err <> 0
         BEGIN
            SELECT @n_continue = 3
            SELECT @c_errmsg = CONVERT(CHAR(250),@n_err), @n_err = 68101   -- Should Be Set To The SQL Errmessage but I don't know how to do so.
            SELECT @c_errmsg='NSQL'+CONVERT(char(5),@n_err)+': Delete Trigger On Table REPLENISHMENT Failed. (ntrReplenishmentDelete)' + ' ( ' + ' SQLSvr MESSAGE=' + LTrim(RTrim(@c_errmsg)) + ' ) '
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
      EXECUTE nsp_logerror @n_err, @c_errmsg, 'ntrReplenishmentDelete'
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
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
/************************************************************************/
/* Trigger:  ntrReplenishmentUpdate                                     */
/* Creation Date:                                                       */
/* Copyright: IDS                                                       */
/* Written by:                                                          */
/*                                                                      */
/* Purpose:  Trigger Inventory Move when Confirm Replenishment          */
/*                                                                      */
/*                                                                      */
/*                                                                      */
/*                                                                      */
/* Usage:                                                               */
/*                                                                      */
/* Called By: Replenishment Record Update                               */
/*                                                                      */
/* PVCS Version: 1.0                                                    */
/*                                                                      */
/* Version: 5.4                                                         */
/*                                                                      */
/* Data Modifications:                                                  */
/*                                                                      */
/* Updates:                                                             */
/* Date         Author    Purposes                                      */
/* 17-Jun-2008  Shong     Change for RDT Dynamic Pick                   */
/* 22-Apr-2010  Shong     SOS#162281 RDT Dynamic Pick to Store          */
/* 04-Sep-2011  Shong     Update QtyReplen for Paper Base Dynamic       */
/*                        Replenishment (SHONG01) --SOS#224731          */
/* 02-JAN-2012  Shong     Add new Column TOID for RDT Dynamic Replen    */
/* 25 May 2012  TLTING01  DM integrity - add update editdate B4         */
/*                        TrafficCop                                    */
/* 28-Oct-2013  TLTING    Review Editdate column update                 */
/* 27-Nov-2013  SHONG     Added New StorerConfig to copy Replenihsment  */
/*                        Group to Lottable01 SOS#296373                */
/* 30-Jul-2014  CSCHONG   Add Lottable06-15 (CS01)                      */
/* 20-Sep-2016  TLTING    Change SetROWCOUNT 1 to Top 1                 */
/* 13-Nov-2016  SHONG     Update QtyReplen If Move Failed               */
/* 19-May-2017  SHONG     Include MoveRefNo when Calling Itrn Move      */
/* 07-JUL-2017  SHONG     Update QtyReplen and Double 11                */
/*                        PendingMoveIn to LotXLocXId (SWT01)           */
/* 09-NOV-2017  SWT02     Not allow to change Qty more then Avaible Qty */
/* 05-JUL-2018  Ung       WMS-5195 To support RDT                       */
/* 02-NOV-2018  Leong     INC0368977 - Allow edit Replenishment.Qty.    */
/* 20-AUG-2019  NJOW01    WMS-9826 Post confirm replenishment call custom*/
/*                        stored proc                                   */
/************************************************************************/

CREATE TRIGGER [dbo].[ntrReplenishmentUpdate]
ON  [dbo].[REPLENISHMENT]
FOR UPDATE AS
BEGIN
   IF @@ROWCOUNT = 0
   BEGIN
      RETURN
   END

   SET NOCOUNT ON
   SET ANSI_NULLS OFF
   SET QUOTED_IDENTIFIER OFF
   SET CONCAT_NULL_YIELDS_NULL OFF

   DECLARE
        @b_Success    INT       -- Populated by calls to stored procedures - was the proc successful?
      , @n_Err        INT       -- Error number returned by stored procedure OR this trigger
      , @n_Err2       INT       -- For Additional Error Detection
      , @c_ErrMsg     NVARCHAR(250) -- Error message returned by stored procedure OR this trigger
      , @n_Continue   INT
      , @n_StartTCnt  INT       -- Holds the current transaction count
      , @c_Preprocess NVARCHAR(250) -- preprocess
      , @c_Pstprocess NVARCHAR(250) -- post process
      , @n_Cnt        INT
      , @n_PendingMoveIn        INT --SWT01
      , @n_deletedPendingMoveIn INT --SWT01
      , @n_QtyReplen            INT --SWT01
      , @n_deletedQtyReplen     INT --SWT01
      , @n_deletedQty           INT --SWT01

   -- To support RDT
   DECLARE @n_IsRDT INT
   EXECUTE RDT.rdtIsRDT @n_IsRDT OUTPUT

   SELECT @n_Continue = 1, @n_StartTCnt=@@TRANCOUNT

   IF UPDATE(ArchiveCop)
   BEGIN
      SELECT @n_Continue = 4
   END

   -- TLTING01
   IF ( @n_Continue = 1 OR @n_Continue = 2 ) AND NOT UPDATE(EditDate)
   BEGIN
      UPDATE Replenishment
      SET ArchiveCop = NULL
         ,EditDate = GetDate()
         ,EditWho = SUSER_SNAME()
      FROM Replenishment, INSERTED (NOLOCK)
      WHERE Replenishment.ReplenishmentKey = INSERTED.ReplenishmentKey

      IF @@ERROR <> 0
      BEGIN
         SELECT @n_Continue = 3
         SELECT @n_Err = 63501
         SELECT @c_ErrMsg='NSQL'+CONVERT(varchar(5),@n_Err)+': UPDATE Replenishment Failed (ntrReplenishmentUpdate)'
      END
   END

   /* #INCLUDE <TRMBOA1.SQL> */
   IF @n_Continue = 1 OR @n_Continue = 2
   BEGIN
      DECLARE
         @c_StorerKey           NVARCHAR(15),
         @c_SKU                 NVARCHAR(20),
         @c_LOT                 NVARCHAR(10),
         @c_ID                  NVARCHAR(18),
         @c_LOC                 NVARCHAR(10),
         @c_ToLoc               NVARCHAR(10),
         @n_Qty                 INT,
         @c_PackKey             NVARCHAR(10),
         @c_UOM                 NVARCHAR(10),
         @c_ReplenishmentKey    NVARCHAR(10),
         @n_InvQty              INT,
         @c_ReplenType          NVARCHAR(1),
         @c_UCCNo               NVARCHAR(20),
         @c_DropID              NVARCHAR(20),
         @c_ReplenishmentGroup  NVARCHAR(10), -- SHONG01
         @c_TOID                NVARCHAR(18),
         @c_CopyRplenGrptoLot01 NVARCHAR(1),  -- SHONG02
         @c_LOTtable01          NVARCHAR(18), -- SHONG02
         @c_MoveRefKey          NVARCHAR(10),
         @n_MoveAllocQty        INT,
         @c_AllowMove           CHAR(1),
         @c_Confirmed           NVARCHAR(1)

      SELECT @c_ReplenishmentKey = SPACE(10)
      WHILE 1=1
      BEGIN
         SELECT TOP 1
               @c_ReplenishmentKey = INSERTED.ReplenishmentKey,
               @c_StorerKey = INSERTED.StorerKey,
               @c_SKU       = INSERTED.Sku,
               @c_LOT       = INSERTED.Lot,
               @c_ID        = INSERTED.Id,
               @c_LOC       = INSERTED.FromLoc,
               @c_ToLoc     = INSERTED.ToLoc,
               @n_Qty       = INSERTED.Qty,
               @c_PackKey   = INSERTED.Packkey,
               @c_UOM       = INSERTED.Uom,
               @c_ReplenType = CASE WHEN INSERTED.ReplenishmentGroup = 'DYNAMIC'
                               THEN DELETED.Confirmed
                               ELSE INSERTED.Confirmed
                               END, --SHONG01
               @c_UCCNo      = INSERTED.RefNo,
               @c_DropID     = INSERTED.DropId,
               @c_ReplenishmentGroup = INSERTED.ReplenishmentGroup,  -- SHONG01
               @c_TOID        = INSERTED.TOID,
               @c_MoveRefKey  = ISNULL(INSERTED.[MoveRefKey], ''),
               @n_QtyReplen    = ISNULL(INSERTED.QtyReplen,0),      --SWT01
               @n_PendingMoveIn = ISNULL(INSERTED.PendingMoveIn,0), --SWT01
               @n_deletedQtyReplen = ISNULL(DELETED.QtyReplen,0),   --SWT01
               @n_deletedPendingMoveIn = ISNULL(DELETED.PendingMoveIn,0),  --SWT01
               @c_Confirmed = ISNULL(INSERTED.Confirmed,'N'), --SWT01
               @n_deletedQty = DELETED.Qty --SWT01
         FROM DELETED, INSERTED
         WHERE DELETED.ReplenishmentKey = INSERTED.ReplenishmentKey
         AND ( DELETED.Confirmed IS NULL OR
               DELETED.Confirmed = 'N' OR
               DELETED.Confirmed = 'S' OR
               DELETED.Confirmed = 'L' )
         -- AND INSERTED.Confirmed  = 'Y' --SWT01
         AND INSERTED.ReplenishmentKey > @c_ReplenishmentKey
         AND INSERTED.Qty >= 0 -- INC0368977
         ORDER BY INSERTED.ReplenishmentKey

         IF @@ROWCOUNT = 0
         BEGIN
            BREAK
         END

         IF @c_Confirmed = 'Y' AND @n_Qty > 0 -- INC0368977
         BEGIN
            SELECT @b_Success = 0

            -- for ucc tracking
            IF EXISTS (
                        SELECT 1
                        FROM   StorerConfig(NOLOCK)
                        WHERE  StorerKey = @c_StorerKey
                        AND    ConfigKey = 'UCCTracking'
                        AND    SValue = '1' )
            BEGIN
               UPDATE Replenishment WITH (ROWLOCK)
               SET Remark = 'Success - UCC Replen!'
                 , ArchiveCop = NULL
                 , EditDate = GETDATE()
                 , EditWho = SUSER_SNAME()
               WHERE  ReplenishmentKey = @c_ReplenishmentKey

               IF @@ERROR <> 0
               BEGIN
                  SELECT @n_Continue = 3
                  SELECT @n_Err = 63502
                  SELECT @c_ErrMsg = 'NSQL' + CONVERT(CHAR(5) ,@n_Err) + ': UPDATE Replenishment Failed (ntrReplenishmentUpdate)'
                  GOTO EXIT_SP -- SHONG01
               END
               ELSE
                  CONTINUE
            END

            SET @n_InvQty = 0

            SELECT @n_InvQty = SUM(Qty - QtyPicked - QtyAllocated)
            FROM   LOTxLOCxID (NOLOCK)
            WHERE  LOT = @c_LOT
            AND    LOC = @c_LOC
            AND    ID  = @c_ID

            -- If Qty Available to move less than Replenishment Qty
            IF @n_InvQty < @n_Qty
            BEGIN
               SET @c_AllowMove = 'N'

               -- Getting allocated qty by move reference key
               SET @n_MoveAllocQty = 0

               SELECT @n_MoveAllocQty = SUM(p.Qty)
               FROM PICKDETAIL AS p WITH(NOLOCK)
               WHERE p.Lot = @c_LOT
               AND   p.Loc = @c_LOC
               AND   p.ID = @c_ID
               AND   p.MoveRefKey = @c_MoveRefKey
               AND   p.[Status] = '0'

               -- System allow to move allocated qty if MoveRefKey link to replenishment
               IF @n_InvQty + @n_MoveAllocQty >= @n_Qty
               BEGIN
                  SET @c_AllowMove = 'Y'
               END
            END
            ELSE
            BEGIN
               SET @c_AllowMove = 'Y'
            END

            IF @c_AllowMove = 'Y'
            BEGIN
               IF NOT EXISTS(SELECT 1 FROM StorerConfig sc WITH (NOLOCK) WHERE sc.StorerKey = @c_StorerKey
                             AND sc.ConfigKey = 'DynReplenToStore' AND sc.SValue = '1')
               BEGIN
                  SET @c_DropID = ''
               END

               -- SHONG02
               SET @c_CopyRplenGrptoLot01 = '0'
               SET @c_LOTtable01 = ''

               SELECT @c_CopyRplenGrptoLot01 = ISNULL(sc.SValue,'0')
               FROM StorerConfig sc WITH (NOLOCK) WHERE sc.StorerKey = @c_StorerKey
               AND sc.ConfigKey = 'CopyRplenGrptoLot01'

               IF @c_CopyRplenGrptoLot01 = '1'
                  SET @c_LOTtable01 = @c_ReplenishmentGroup

               -- 02-JAN-2012  Shong
               IF ISNULL(RTRIM(@c_TOID),'') <> ''
                  SET @c_DropID = @c_TOID

               EXECUTE nspItrnAddMove
                  @n_ItrnSysId  = null,
                  @c_StorerKey  = @c_StorerKey,
                  @c_SKU        = @c_SKU,
                  @c_LOT        = @c_LOT,
                  @c_FromLoc    = @c_LOC,
                  @c_FromID     = @c_ID,
                  @c_ToLoc      = @c_ToLoc,
                  @c_ToID       = @c_DropID,
                  @c_Status     = '',
                  @c_LOTtable01 = @c_LOTtable01, -- SHONG02
                  @c_LOTtable02 = '',
                  @c_LOTtable03 = '',
                  @d_lottable04 = null,
                  @d_lottable05 = null,
                  @c_LOTtable06 = '',             --CS01
                  @c_LOTtable07 = '',             --CS01
                  @c_LOTtable08 = '',             --CS01
                  @c_LOTtable09 = '',             --CS01
                  @c_LOTtable10 = '',             --CS01
                  @c_LOTtable11 = '',             --CS01
                  @c_LOTtable12 = '',             --CS01
                  @d_lottable13 = null,           --CS01
                  @d_lottable14 = null,           --CS01
                  @d_lottable15 = null,           --CS01
                  @n_casecnt    = 0,
                  @n_innerpack  = 0,
                  @n_Qty        = @n_Qty,
                  @n_pallet     = 0,
                  @f_cube       = 0,
                  @f_grosswgt   = 0,
                  @f_netwgt     = 0,
                  @f_otherunit1 = 0,
                  @f_otherunit2 = 0,
                  @c_SourceKey  = @c_ReplenishmentKey,
                  @c_SourceType = 'ntrReplenishmentUpdate',
                  @c_PackKey    = @c_PackKey,
                  @c_UOM        = @c_UOM,
                  @b_UOMCalc    = 1,
                  @d_EffectiveDate = NULL,
                  @c_itrnkey = '',
                  @b_Success = @b_Success OUTPUT,
                  @n_Err = @n_Err OUTPUT,
                  @c_ErrMsg = @c_ErrMsg OUTPUT,
                  @c_MoveRefKey = @c_MoveRefKey

               IF @b_Success = 1
               BEGIN
                  -- SHONG01
                  IF @c_ReplenishmentGroup = 'DYNAMIC' AND @c_ReplenType = 'N'
                  BEGIN
                     UPDATE dbo.LOTxLOCxID WITH (ROWLOCK)
                     SET QtyReplen = CASE WHEN QtyReplen > @n_Qty THEN QtyReplen - @n_Qty
                                          ELSE 0
                                     END,
                         EditDate = GETDATE(),   --tlting
                         EditWho = SUSER_SNAME()
                     WHERE  LOT = @c_LOT
                     AND  LOC = @c_LOC
                     AND  ID  = @c_ID

                     IF @@ERROR <> 0
                     BEGIN
                        SELECT @n_Continue = 3
                        SELECT @n_Err = 63503
                        SELECT @c_ErrMsg='NSQL'+CONVERT(char(5),@n_Err)+': UPDATE LOTxLOCxID Failed (ntrReplenishmentUpdate)'
                        GOTO EXIT_SP
                     END
                  END

                  IF @n_QtyReplen > 0
                  BEGIN
                     IF UPDATE(Qty) AND @n_Qty <> @n_QtyReplen
                        SET @n_QtyReplen = @n_Qty

                     UPDATE LOTxLOCxID WITH (ROWLOCK)
                         SET QtyReplen = CASE WHEN (QtyReplen - @n_QtyReplen) < 0 THEN 0 ELSE QtyReplen - @n_QtyReplen END,
                             EditDate = GETDATE(),
                             EditWho = SUSER_SNAME()
                     WHERE Lot = @c_LOT
                       AND LOC = @c_LOC
                       AND ID  = @c_ID
                     IF @@ERROR <> 0
                     BEGIN
                        SELECT @n_Continue = 3
                        SELECT @n_Err = 63504
                        SELECT @c_ErrMsg='NSQL'+CONVERT(varchar(5),@n_Err)+': UPDATE LOTxLOCxID Failed (ntrReplenishmentUpdate)'
                     END
                  END

                  IF UPDATE(Qty) AND @n_Qty <> @n_PendingMoveIn
                     SET @n_PendingMoveIn = @n_Qty

                  IF @n_PendingMoveIn > 0
                  BEGIN
                     UPDATE LOTxLOCxID WITH (ROWLOCK)
                         SET PendingMoveIn = CASE WHEN (PendingMoveIn - @n_PendingMoveIn) < 0 THEN 0
                                                  ELSE PendingMoveIn - @n_PendingMoveIn
                                             END,
                             EditDate = GETDATE(),
                             EditWho = SUSER_SNAME()
                     WHERE Lot = @c_LOT
                       AND LOC = @c_ToLoc
                       AND ID  = @c_DropID
                     IF @@ERROR <> 0
                     BEGIN
                        SELECT @n_Continue = 3
                        SELECT @n_Err = 63505
                        SELECT @c_ErrMsg='NSQL'+CONVERT(varchar(5),@n_Err)+': UPDATE LOTxLOCxID Failed (ntrReplenishmentUpdate)'
                     END
                  END

                  UPDATE Replenishment WITH (ROWLOCK)
                  SET Remark = 'Perfect ! '
                     ,ArchiveCop = NULL
                     ,EditDate  = GetDate()
                     ,EditWho   = SUSER_SNAME()
                     ,DropID    = CASE WHEN @c_ReplenType = 'L' THEN @c_ReplenType ELSE DropID END
                     ,QtyReplen = 0
                  WHERE ReplenishmentKey = @c_ReplenishmentKey

                  IF @@ERROR <> 0
                  BEGIN
                     SELECT @n_Continue = 3
                     SELECT @n_Err = 63506
                     SELECT @c_ErrMsg='NSQL'+CONVERT(char(5),@n_Err)+': UPDATE Replenishment Failed (ntrReplenishmentUpdate)'
                     GOTO EXIT_SP -- SHONG01
                  END
                  
                  --NJOW01
                  IF @n_continue IN(1,2)
                  BEGIN
                  	 EXEC isp_PostReplenishment_Wrapper 
                  	      @c_Replenishmentkey = @c_Replenishmentkey,
                          @b_Success = @b_Success OUTPUT,
                          @n_Err = @n_Err OUTPUT, 
                          @c_ErrMsg = @c_ErrMsg OUTPUT
                     
                     IF @b_Success <> 1
                     BEGIN
                        SELECT @n_continue = 3
                     END     
                  END                  
               END -- IF @b_Success = 1
               ELSE
               BEGIN
                  IF @n_IsRDT = 1
                  BEGIN
                     SET @n_Continue = 3
                     GOTO EXIT_SP
                  END

                  UPDATE Replenishment WITH (ROWLOCK)
                  SET Remark = 'Failed ! '
                     ,ArchiveCop = NULL
                     ,EditDate = GetDate()
                     ,EditWho = SUSER_SNAME()
                     ,DropID    = CASE WHEN @c_ReplenType = 'L' THEN @c_ReplenType ELSE DropID END
                  WHERE ReplenishmentKey = @c_ReplenishmentKey

                  IF @@ERROR <> 0
                  BEGIN
                     SELECT @n_Continue = 3
                     SELECT @n_Err = 63507
                     SELECT @c_ErrMsg='NSQL'+CONVERT(char(5),@n_Err)+': UPDATE Replenishment Failed (ntrReplenishmentUpdate)'
                     GOTO EXIT_SP -- SHONG01
                  END

                  IF @c_ReplenishmentGroup = 'DYNAMIC' AND @c_ReplenType = 'N'
                  BEGIN
                     UPDATE dbo.LOTxLOCxID WITH (ROWLOCK)
                     SET QtyReplen = CASE WHEN QtyReplen > @n_Qty THEN QtyReplen - @n_Qty
                                          ELSE 0
                                       END,
                           EditDate = GETDATE(),   --tlting
                           EditWho = SUSER_SNAME()
                     WHERE  LOT = @c_LOT
                        AND  LOC = @c_LOC
                        AND  ID  = @c_ID
                     IF @@ERROR <> 0
                     BEGIN
                        SELECT @n_Continue = 3
                        SELECT @n_Err = 63508
                        SELECT @c_ErrMsg='NSQL'+CONVERT(char(5),@n_Err)+': UPDATE LOTxLOCxID Failed (ntrReplenishmentUpdate)'
                        GOTO EXIT_SP
                     END
                  END
               END
            END -- IF @c_AllowMove = 'Y'
            ELSE
            BEGIN
               UPDATE Replenishment WITH (ROWLOCK)
                     SET Remark = 'Failed ! Quantity - (Qty Picked + Qty Allocated) < Qty to Move'
                        ,ArchiveCop = NULL
                        ,EditDate   = GetDate()
                        ,EditWho    = SUSER_SNAME()
                        ,DropID    = CASE WHEN @c_ReplenType = 'L' THEN 'Y' ELSE DropID END
                     WHERE ReplenishmentKey = @c_ReplenishmentKey

               IF @@ERROR <> 0
               BEGIN
                  SELECT @n_Continue = 3
                  SELECT @n_Err = 63509
                  SELECT @c_ErrMsg='NSQL'+CONVERT(char(5),@n_Err)+': UPDATE Replenishment Failed (ntrReplenishmentUpdate)'
                  GOTO EXIT_SP -- SHONG01
               END

               IF @c_ReplenishmentGroup = 'DYNAMIC' AND @c_ReplenType = 'N'
               BEGIN
                  UPDATE dbo.LOTxLOCxID WITH (ROWLOCK)
                  SET QtyReplen = CASE WHEN QtyReplen > @n_Qty THEN QtyReplen - @n_Qty
                                       ELSE 0
                                    END,
                        EditDate = GETDATE(),   --tlting
                        EditWho = SUSER_SNAME()
                  WHERE  LOT = @c_LOT
                     AND  LOC = @c_LOC
                     AND  ID  = @c_ID
                  IF @@ERROR <> 0
                  BEGIN
                     SELECT @n_Continue = 3
                     SELECT @n_Err = 63510
                     SELECT @c_ErrMsg='NSQL'+CONVERT(char(5),@n_Err)+': UPDATE LOTxLOCxID Failed (ntrReplenishmentUpdate)'
                     GOTO EXIT_SP
                  END
               END

               IF @c_ReplenType = 'L'
               BEGIN
                  UPDATE UCC
                     SET STATUS = '1', EditDate = GETDATE(), EditWho = SUSER_SNAME()
                  WHERE Storerkey = @c_StorerKey
                  AND UCCNo = @c_UCCNo

                  IF @@ERROR <> 0
                  BEGIN
                  SELECT @n_Continue = 3
                     SELECT @n_Err = 63511
                     SELECT @c_ErrMsg='NSQL'+CONVERT(char(5),@n_Err)+': UPDATE UCC Failed (ntrReplenishmentUpdate)'
                     GOTO EXIT_SP -- SHONG01
                  END
               END
            END  -- IF @c_AllowMove <> 'Y'
         END -- IF @c_Confirmed = 'Y'
         ELSE -- (SWT01)
         BEGIN
            -- (SWT02)
            IF UPDATE(Qty) AND @n_Qty > 0
            BEGIN
               SET @n_InvQty = 0

               SELECT @n_InvQty = SUM(Qty - QtyPicked - QtyAllocated)
               FROM   LOTxLOCxID (NOLOCK)
               WHERE  LOT = @c_LOT
               AND    LOC = @c_LOC
               AND    ID  = @c_ID

               -- If Qty Available to move less than Replenishment Qty
               IF @n_InvQty < @n_Qty
               BEGIN
                  SELECT @n_Continue = 3
                  SELECT @n_Err = 63518
                  SELECT @c_ErrMsg='NSQL'+CONVERT(char(5),@n_Err)+': UPDATE Replenishment Failed, Qty > Qty Available (ntrReplenishmentUpdate)'
                  GOTO EXIT_SP
               END
            END

            IF UPDATE(QtyReplen) AND (@n_deletedQtyReplen <> @n_QtyReplen)
            BEGIN
               UPDATE LOTxLOCxID WITH (ROWLOCK)
                  SET QtyReplen = QtyReplen - @n_deletedQtyReplen + @n_QtyReplen,
                      EditDate = GETDATE(),
                      EditWho = SUSER_SNAME()
               WHERE Lot = @c_LOT
                 AND LOC = @c_LOC
                 AND ID  = @c_ID

               IF @@ERROR <> 0
               BEGIN
                  SELECT @n_Continue = 3
                  SELECT @n_Err = 63512
                  SELECT @c_ErrMsg='NSQL'+CONVERT(varchar(5),@n_Err)+': UPDATE LOTxLOCxID Failed (ntrReplenishmentUpdate)'
               END
            END

            IF UPDATE(PendingMoveIN) AND (@n_deletedPendingMoveIn <> @n_PendingMoveIn)
            BEGIN
               UPDATE LOTxLOCxID WITH (ROWLOCK)
                  SET PendingMoveIN = PendingMoveIN - @n_deletedPendingMoveIn + @n_PendingMoveIn,
                      EditDate = GETDATE(),
                      EditWho = SUSER_SNAME()
                WHERE Lot = @c_LOT
                  AND LOC = @c_ToLOC
                  AND ID  = @c_ToID
               IF @@ERROR <> 0
               BEGIN
                  SELECT @n_Continue = 3
                  SELECT @n_Err = 63513
                  SELECT @c_ErrMsg='NSQL'+CONVERT(varchar(5),@n_Err)+': UPDATE LOTxLOCxID Failed (ntrReplenishmentUpdate)'
               END
            END

            IF UPDATE(Qty)
               AND NOT UPDATE(QtyReplen)
               AND @n_Qty <> @n_deletedQty
               AND @n_QtyReplen > 0
            BEGIN
               UPDATE LOTxLOCxID  WITH (ROWLOCK)
               SET QtyReplen = QtyReplen - @n_deletedQty  + @n_Qty,
                   EditDate = GETDATE(),
                   EditWho = SUSER_SNAME()
               WHERE Lot = @c_LOT
                 AND LOC = @c_LOC
                 AND ID  = @c_ID

               IF @@ERROR <> 0
               BEGIN
                  SELECT @n_Continue = 3
                  SELECT @n_Err = 63514
                  SELECT @c_ErrMsg='NSQL'+CONVERT(varchar(5),@n_Err)+': UPDATE LOTxLOCxID Failed (ntrReplenishmentUpdate)'
               END

               UPDATE Replenishment  WITH (ROWLOCK)
                  SET QtyReplen = QtyReplen - @n_deletedQty  + @n_Qty,
                      ArchiveCop = NULL,
                      EditDate = GETDATE(),
                      EditWho = SUSER_SNAME()
                WHERE ReplenishmentKey = @c_ReplenishmentKey

               IF @@ERROR <> 0
               BEGIN
                  SELECT @n_Continue = 3
                  SELECT @n_Err = 63515
                  SELECT @c_ErrMsg='NSQL'+CONVERT(varchar(5),@n_Err)+': UPDATE Replenishment Failed (ntrReplenishmentUpdate)'
               END
            END

            IF UPDATE(Qty)
               AND NOT UPDATE(PendingMoveIN)
               AND @n_Qty <> @n_deletedQty
               AND @n_PendingMoveIN > 0
            BEGIN
               UPDATE LOTxLOCxID WITH (ROWLOCK)
                  SET PendingMoveIN = PendingMoveIN - @n_deletedQty + @n_Qty,
                      EditDate = GETDATE(),
                      EditWho = SUSER_SNAME()
               WHERE Lot = @c_LOT
                 AND LOC = @c_ToLOC
                 AND ID  = @c_ToID

               IF @@ERROR <> 0
               BEGIN
                  SELECT @n_Continue = 3
                  SELECT @n_Err = 63516
                  SELECT @c_ErrMsg='NSQL'+CONVERT(varchar(5),@n_Err)+': UPDATE LOTxLOCxID Failed (ntrReplenishmentUpdate)'
               END

               UPDATE Replenishment WITH (ROWLOCK)
               SET PendingMoveIN = PendingMoveIN - @n_deletedQty  + @n_Qty,
                   ArchiveCop = NULL,
                   EditDate = GETDATE(),
                   EditWho = SUSER_SNAME()
               WHERE ReplenishmentKey = @c_ReplenishmentKey

               IF @@ERROR <> 0
               BEGIN
                  SELECT @n_Continue = 3
                  SELECT @n_Err = 63517
                  SELECT @c_ErrMsg='NSQL'+CONVERT(varchar(5),@n_Err)+': UPDATE Replenishment Failed (ntrReplenishmentUpdate)'
               END
            END
         END
      END -- While
   END

EXIT_SP:
   /* #INCLUDE <TRMBOHA2.SQL> */
   IF @n_Continue = 3  -- Error Occured - Process And Return
   BEGIN
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
         IF @@TRANCOUNT = 1 AND @@TRANCOUNT >= @n_StartTCnt
         BEGIN
            ROLLBACK TRAN
         END
         ELSE
         BEGIN
            WHILE @@TRANCOUNT > @n_StartTCnt
            BEGIN
               COMMIT TRAN
            END
         END
         EXECUTE nsp_logerror @n_Err, @c_ErrMsg, 'ntrReplenishmentUpdate'
         RAISERROR (@c_ErrMsg, 16, 1) WITH SETERROR    -- SQL2012
         RETURN
      END
   END
   ELSE
   BEGIN
      WHILE @@TRANCOUNT > @n_StartTCnt
      BEGIN
         COMMIT TRAN
      END
      RETURN
   END
END
GO
ALTER TABLE [dbo].[REPLENISHMENT] ADD CONSTRAINT [PK_REPLENISHMENT] PRIMARY KEY CLUSTERED ([ReplenishmentKey]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_REPLENISHMENT_RefNo] ON [dbo].[REPLENISHMENT] ([RefNo]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_REPLENISHMENT_Group] ON [dbo].[REPLENISHMENT] ([ReplenishmentGroup], [Storerkey]) INCLUDE ([Confirmed]) ON [PRIMARY]
GO
GRANT SELECT ON  [dbo].[REPLENISHMENT] TO [JReportRole]
GO
GRANT DELETE ON  [dbo].[REPLENISHMENT] TO [NSQL]
GO
GRANT INSERT ON  [dbo].[REPLENISHMENT] TO [NSQL]
GO
GRANT SELECT ON  [dbo].[REPLENISHMENT] TO [NSQL]
GO
GRANT UPDATE ON  [dbo].[REPLENISHMENT] TO [NSQL]
GO
EXEC sp_addextendedproperty N'MS_Description', 'Replenishment is the function in which fixed pick locations are refilled to capacity with reserve stock from bulk locations. If pick locations are used in the warehouse, the locations must be refilled regularly based upon the total capacity of the pick location and the quantity of the Commodity picked from location.', 'SCHEMA', N'dbo', 'TABLE', N'REPLENISHMENT', NULL, NULL
GO
EXEC sp_addextendedproperty N'MS_Description', 'Date of the information added. (System date)', 'SCHEMA', N'dbo', 'TABLE', N'REPLENISHMENT', 'COLUMN', N'AddDate'
GO
EXEC sp_addextendedproperty N'MS_Description', 'The username/login ID added the information.', 'SCHEMA', N'dbo', 'TABLE', N'REPLENISHMENT', 'COLUMN', N'AddWho'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Date of the information edited/modified/updated. (System date)', 'SCHEMA', N'dbo', 'TABLE', N'REPLENISHMENT', 'COLUMN', N'EditDate'
GO
EXEC sp_addextendedproperty N'MS_Description', 'The username/login ID edited/modified/updated the information.', 'SCHEMA', N'dbo', 'TABLE', N'REPLENISHMENT', 'COLUMN', N'EditWho'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Current location of the Commodity to be moved.', 'SCHEMA', N'dbo', 'TABLE', N'REPLENISHMENT', 'COLUMN', N'FromLoc'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Movable unit /pallet ID. An MUID needs to be applied during receiving, picking or shipping of product. It provides a reference number that facilitates movement of product throughout the facility.', 'SCHEMA', N'dbo', 'TABLE', N'REPLENISHMENT', 'COLUMN', N'Id'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Unique pre-populated numeric values associated with a specific product. A unique combination.', 'SCHEMA', N'dbo', 'TABLE', N'REPLENISHMENT', 'COLUMN', N'Lot'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Move Reference Key', 'SCHEMA', N'dbo', 'TABLE', N'REPLENISHMENT', 'COLUMN', N'MoveRefKey'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Name of the pack code.', 'SCHEMA', N'dbo', 'TABLE', N'REPLENISHMENT', 'COLUMN', N'PackKey'
GO
EXEC sp_addextendedproperty N'MS_Description', N'PendingMoveIn Quantity', 'SCHEMA', N'dbo', 'TABLE', N'REPLENISHMENT', 'COLUMN', N'PendingMoveIn'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Priority of the task. (1-highest through 9-lowest)', 'SCHEMA', N'dbo', 'TABLE', N'REPLENISHMENT', 'COLUMN', N'Priority'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Quantity of the product associated.', 'SCHEMA', N'dbo', 'TABLE', N'REPLENISHMENT', 'COLUMN', N'Qty'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Quantity of product currently in the Pick Location.', 'SCHEMA', N'dbo', 'TABLE', N'REPLENISHMENT', 'COLUMN', N'QtyInPickLoc'
GO
EXEC sp_addextendedproperty N'MS_Description', N'Replenishment Quantity', 'SCHEMA', N'dbo', 'TABLE', N'REPLENISHMENT', 'COLUMN', N'QtyReplen'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Unique code identifying replenishment.', 'SCHEMA', N'dbo', 'TABLE', N'REPLENISHMENT', 'COLUMN', N'ReplenishmentKey'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Unique number identifying replenishment.', 'SCHEMA', N'dbo', 'TABLE', N'REPLENISHMENT', 'COLUMN', N'ReplenNo'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Unique code identifying the product.', 'SCHEMA', N'dbo', 'TABLE', N'REPLENISHMENT', 'COLUMN', N'Sku'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Unique key to the Storer record.', 'SCHEMA', N'dbo', 'TABLE', N'REPLENISHMENT', 'COLUMN', N'Storerkey'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Destination (location) for the Commodity to be moved.', 'SCHEMA', N'dbo', 'TABLE', N'REPLENISHMENT', 'COLUMN', N'ToLoc'
GO
EXEC sp_addextendedproperty N'MS_Description', 'Unit of measure for the product.', 'SCHEMA', N'dbo', 'TABLE', N'REPLENISHMENT', 'COLUMN', N'UOM'
GO
