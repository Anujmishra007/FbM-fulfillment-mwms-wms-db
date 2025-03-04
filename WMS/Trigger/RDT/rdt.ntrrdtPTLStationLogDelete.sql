SET ANSI_NULLS OFF
GO

SET QUOTED_IDENTIFIER OFF
GO

/************************************************************************/
/* Trigger: ntrrdtPTLStationLogDelete                                   */
/* Creation Date: 14 July 2016                                          */
/* Copyright: LF                                                        */
/* Written by: ChewKP                                                   */
/*                                                                      */
/* Purpose:                                                             */
/*                                                                      */
/* Usage:                                                               */
/*                                                                      */
/* Called By: When records removed from rdt.rdtPTLStationLog            */
/*                                                                      */
/* PVCS Version: 1.0                                                    */
/*                                                                      */
/* Version: 5.4                                                         */
/*                                                                      */
/* Modifications:                                                       */
/* Date         Author     Ver  Purposes                                */
/* 14 July 2016 ChewKP     1.0  Initial version                         */
/* 03-Feb-2025  kelvinong  1.2  restructure rdtPTLStationLog_dellog to  */
/*                              rdtPTLStationLog_DEL table (kocy01)     */
/************************************************************************/

CREATE OR ALTER TRIGGER [RDT].[ntrrdtPTLStationLogDelete]
ON [RDT].[rdtPTLStationLog]
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
            @n_cnt         int,       -- Holds the number of rows affected by the DELETE statement that fired this trigger.
            @c_authority   NVARCHAR(1)
   SELECT @n_continue=1, @n_starttcnt=@@TRANCOUNT

   --IF (SELECT COUNT(*) FROM DELETED) = (SELECT COUNT(*) FROM DELETED WHERE DELETED.ArchiveCop = '9')
   --BEGIN
   --   SELECT @n_continue = 4
   --END

      /* #INCLUDE <TRCONHD1.SQL> */     
   IF @n_continue = 1 or @n_continue = 2
   BEGIN
      SELECT @b_success = 0
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
               ,@c_errmsg = 'ntrrdtPTLStationLogDelete' + dbo.fnc_RTrim(@c_errmsg)
      END
      ELSE 
		IF @c_authority = '1'         --    End   (KHLim02)
      BEGIN
		   --kocy01
         INSERT INTO rdt.rdtPTLStationLog_DELLOG ( RowRefSource )
         SELECT RowRef FROM DELETED WITH (NOLOCK)

         SELECT @n_err = @@ERROR, @n_cnt = @@ROWCOUNT
         IF @n_err <> 0
         BEGIN
            SELECT @n_continue = 3
            SELECT @c_errmsg = CONVERT(CHAR(250),@n_err), @n_err = 60713   -- Should Be Set To The SQL Errmessage but I don't know how to do so.
            SELECT @c_errmsg='NSQL'+CONVERT(char(5),@n_err)+': Delete Trigger On Table rdtPTLStationLog Failed. (ntrrdtPTLStationLogDelete)' 
				                + ' ( ' + ' SQLSvr MESSAGE=' + LTrim(RTrim(@c_errmsg)) + ' ) '
         END
      END

		IF @n_continue = 1 or @n_continue = 2
      BEGIN
		   --kocy01
         INSERT INTO rdt.rdtPTLStationLog_DEL
               ( Station, IPAddress, Position, LOC, Method, CartonID, OrderKey, LoadKey, WaveKey, PickSlipNo, BatchKey, ConsigneeKey, ShipTo,  StorerKey, 
                 MaxTask, UserDefine01, UserDefine02, UserDefine03, SourceKey, SourceType, AddWho,  AddDate, EditWho, EditDate, CreatedPTLTran, SKU, ItemClass )
         SELECT  Station, IPAddress, Position, LOC, Method, CartonID, OrderKey, LoadKey, WaveKey, PickSlipNo, BatchKey, ConsigneeKey, ShipTo,  StorerKey, 
                 MaxTask, UserDefine01, UserDefine02, UserDefine03, SourceKey, SourceType, AddWho,  Adddate, EditWho, EditDate, CreatedPTLTran, SKU, ItemClass
         FROM DELETED

         SELECT @n_err = @@ERROR, @n_cnt = @@ROWCOUNT
         IF @n_err <> 0
         BEGIN
            SELECT @n_continue = 3
            SELECT @c_errmsg = CONVERT(CHAR(250),@n_err), @n_err = 60714   -- Should Be Set To The SQL Errmessage but I don't know how to do so.
            SELECT @c_errmsg='NSQL'+CONVERT(char(5),@n_err)+': Delete Trigger On Table rdtPTLStationLog Failed. (ntrrdtPTLStationLogDelete)' 
				                + ' ( ' + ' SQLSvr MESSAGE=' + LTrim(RTrim(@c_errmsg)) + ' ) '
         END
      END
   END

QUIT:  
  
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
         execute nsp_logerror @n_err, @c_errmsg, "ntrrdtPTLStationLogDelete"  
         RAISERROR (@c_errmsg, 16, 1) WITH SETERROR -- SQL 2012 (Jay01)  
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

ALTER TABLE [RDT].[rdtPTLStationLog] ENABLE TRIGGER [ntrrdtPTLStationLogDelete]
GO


