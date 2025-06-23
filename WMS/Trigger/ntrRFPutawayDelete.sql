SET ANSI_NULLS OFF
GO

SET QUOTED_IDENTIFIER OFF
GO

/********************************************************************************************/  
/* Store Procedure:  ntrRFPutawayDelete                                                     */  
/* Copyright: LF Logistics                                                                  */  
/*                                                                                          */  
/* Purpose:  VFCDC Debugging Script                                                         */  
/*                                                                                          */  
/* Modification log:                                                                        */  
/* Date         Author     Ver   Purposes                                                   */  
/* 25-Sep-2013  Chee       1.0   Created                                                    */  
/* 02-Jan-2013  Ung        1.1   Add RFPutaway_DELLOG for troubleshoot                      */
/* 10-Aug-2015  Ung        1.2   SOS337296 Add TaskDetailKey, Func, PABookingKey            */
/* 19-Mar-2018  TLTING     1.3   bug fix - Avoid 0 line delete trigger                      */  
/* 18-Mar-2022  Ung        1.4   WMS-16328 Add QTYPrinted                                   */
/*                               Add editdate editwho                                       */
/* 04-May-2022  NJOW01     1.5   WMS-16330 Add new columns                                  */
/* 04-May-2022  NJOW01     1.5   DEVOPS combine script                                      */
/* 03-Feb-2025  kelvinong  1.7  restructure RFPutaway_dellog to RFPutaway_DEL table (kocy01)*/
/********************************************************************************************/  
CREATE  OR ALTER  TRIGGER [dbo].[ntrRFPutawayDelete]  
ON  [dbo].[RFPUTAWAY]  
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
  
   DECLARE @b_debug int  
   SELECT @b_debug = 0  
  
   DECLARE  
      @b_Success            int           -- Populated by calls to stored procedures - was the proc successful?  
     ,@n_err                int           -- Error number returned by stored procedure or this trigger  
     ,@n_err2               int           -- For Additional Error Detection  
     ,@c_errmsg             NVARCHAR(250) -- Error message returned by stored procedure or this trigger  
     ,@n_continue           int  
     ,@n_starttcnt          int           -- Holds the current transaction count  
     ,@c_preprocess         NVARCHAR(250) -- preprocess  
     ,@c_pstprocess         NVARCHAR(250) -- post process  
     ,@profiler             NVARCHAR(80)
	  ,@n_cnt                int
     ,@c_authority          NVARCHAR(1)  
  
   SELECT @n_continue=1, @n_starttcnt=@@TRANCOUNT  
  
   IF (SELECT COUNT(*) FROM DELETED) = (SELECT COUNT(*) FROM DELETED WHERE DELETED.ArchiveCop = '9')  
   BEGIN  
    SELECT @n_continue = 4  
   END 
	
	--kocy01 (S)
	IF @n_continue = 1 OR @n_continue=2      
   BEGIN    
      SELECT @b_success = 0         --    Start  
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
               ,@c_errmsg = 'ntrRFPutawayDelete' + RTrim(@c_errmsg)  
      END  
      ELSE   
      IF @c_authority = '1'         
      BEGIN  
         INSERT INTO dbo.RFPutaway_DELLOG ( [RowRefSource])
         SELECT RowRef FROM DELETED WITH (NOLOCK)
  
         SELECT @n_err = @@ERROR, @n_cnt = @@ROWCOUNT  
         IF @n_err <> 0  
         BEGIN  
            SELECT @n_continue = 3  
            SELECT @c_errmsg = CONVERT(CHAR(250),@n_err), @n_err = 68101   -- Should Be Set To The SQL Errmessage but I don't know how to do so.  
            SELECT @c_errmsg='NSQL'+CONVERT(char(5),@n_err)+': Delete Trigger On Table RFPutaway Failed. (ntrRFPutawayDelete)' + ' ( ' + ' SQLSvr MESSAGE=' + LTrim(RTrim(@c_errmsg)) + ' ) '  
         END                    
      END  
   END 
	--kocy01 (E)

   IF @n_continue = 1 OR @n_continue=2      
   BEGIN 
      INSERT INTO dbo.RFPutaway_DEL (StorerKey, Sku, Lot, FromLoc, SuggestedLoc, Id, ptcid, qty, AddDate, AddWho, TrafficCop, ArchiveCop, CaseID, FromID, RowRef, TaskDetailKey, 
		                               Func, PABookingKey, QTYPrinted,EditDate,EditWho, Receiptkey, ReceiptLineNumber, UDF01, UDF02, UDF03)  --NJOW01
      SELECT StorerKey, Sku, Lot, FromLoc, SuggestedLoc, Id, ptcid, qty, AddDate, AddWho, TrafficCop, ArchiveCop, CaseID, FromID, RowRef, TaskDetailKey, 
		       Func, PABookingKey, QTYPrinted,EditDate,EditWho, Receiptkey, ReceiptLineNumber, UDF01, UDF02, UDF03 --NJOW01
      FROM DELETED

		SELECT @n_err = @@ERROR, @n_cnt = @@ROWCOUNT  
      IF @n_err <> 0  
      BEGIN  
         SELECT @n_continue = 3  
         SELECT @c_errmsg = CONVERT(CHAR(250),@n_err), @n_err = 68102   -- Should Be Set To The SQL Errmessage but I don't know how to do so.  
         SELECT @c_errmsg='NSQL'+CONVERT(char(5),@n_err)+': Delete Trigger On Table RFPutaway Failed. (ntrRFPutawayDelete)' + ' ( ' + ' SQLSvr MESSAGE=' + LTrim(RTrim(@c_errmsg)) + ' ) '  
      END
	END
    
   IF @n_continue = 1 OR @n_continue=2    
   BEGIN  
      DECLARE   
         @cCaseID    NVARCHAR(40),  
         @cFromID    NVARCHAR(36),  
         @cStorerKey NVARCHAR(15)  
  
      DECLARE CURSOR_DELETED CURSOR FAST_FORWARD READ_ONLY FOR   
      SELECT DELETED.StorerKey, DELETED.CaseID, DELETED.FromID  
      FROM DELETED WITH (NOLOCK)  
  
      OPEN CURSOR_DELETED                 
      FETCH NEXT FROM CURSOR_DELETED INTO @cStorerKey, @cCaseID, @cFromID  
  
      WHILE (@@FETCH_STATUS <> -1)            
      BEGIN   
         IF EXISTS(SELECT 1 FROM TaskDetail WITH (NOLOCK)   
                   WHERE TaskType = 'PAT' AND Status = '0' AND StorerKey = @cStorerKey AND CaseID = @cCaseID AND FromID = @cFromID)  
         BEGIN  
            SELECT @n_continue = 3  
                  ,@n_err = 82153  
            SELECT @c_errmsg = 'CAUGHT SKIP GHOST. (ntrRFPutawayDelete)' +  
                               ' ( SQLSvr MESSAGE=' + CONVERT(NVARCHAR(5),ISNULL(@n_err,0)) + ' )'  
            GOTO QUIT  
         END  
  
         FETCH NEXT FROM CURSOR_DELETED INTO @cStorerKey, @cCaseID, @cFromID        
      END -- END WHILE FOR CURSOR_DELETED               
      CLOSE CURSOR_DELETED            
      DEALLOCATE CURSOR_DELETED  
   END  
  
  
QUIT:  
   IF (SELECT CURSOR_STATUS('LOCAL','CURSOR_DELETED')) >=0   
   BEGIN  
      CLOSE CURSOR_DELETED             
      DEALLOCATE CURSOR_DELETED        
   END    
  
   /* #INCLUDE <TRRDA2.SQL> */  
   IF @n_continue=3  -- Error Occured - Process And Return  
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
         execute nsp_logerror @n_err, @c_errmsg, "ntrRFPutawayDelete"  
         RAISERROR (@n_err, 10, 1) WITH SETERROR
         IF @b_debug = 2  
         BEGIN  
             SELECT @profiler = 'PROFILER,637,00,9,ntrRFPutawayDelete Tigger ,' + CONVERT(char(12), getdate(), 114)  
             PRINT @profiler  
         END  
         RETURN  
      END  
   END  
   ELSE  
   BEGIN  
      WHILE @@TRANCOUNT > @n_starttcnt  
      BEGIN  
         COMMIT TRAN  
      END  
      IF @b_debug = 2  
      BEGIN  
         SELECT @profiler = 'PROFILER,637,00,9,ntrRFPutawayDelete Trigger ,' + CONVERT(char(12), getdate(), 114) PRINT @profiler  
      END  
      RETURN  
   END  
END
GO

ALTER TABLE [dbo].[RFPUTAWAY] ENABLE TRIGGER [ntrRFPutawayDelete]
GO


