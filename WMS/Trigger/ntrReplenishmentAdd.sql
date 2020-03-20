if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[ntrReplenishmentAdd]') 
              and OBJECTPROPERTY(id, N'IsTrigger') = 1) 
drop trigger [dbo].[ntrReplenishmentAdd]
GO
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
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
ON [dbo].[Replenishment]
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
