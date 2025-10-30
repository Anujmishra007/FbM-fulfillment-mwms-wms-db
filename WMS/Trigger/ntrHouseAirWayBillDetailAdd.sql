
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS OFF 
GO

/************************************************************************/
/* Trigger: ntrHouseAirWayBillDetailAdd                                 */
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
/* Called By: When records inserted                                     */
/*                                                                      */
/* PVCS Version: 1.0                                                    */
/*                                                                      */
/* Version: 5.4                                                         */
/*                                                                      */
/* Data Modifications:                                                  */
/*                                                                      */
/* Updates:                                                             */
/* Date        Author  Ver.  Purposes                                   */
/* 06-OCT-2025 AK01    1.1   UWP-42143 Data Audit                       */
/************************************************************************/
CREATE OR ALTER TRIGGER ntrHouseAirWayBillDetailAdd
 ON  HouseAirWayBillDetail
 FOR INSERT
 AS
 BEGIN
    SET NOCOUNT ON
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
      /* #INCLUDE <TRHABDA1.SQL> */     
 IF @n_continue=1 or @n_continue=2
 BEGIN
 IF EXISTS (SELECT * FROM HouseAirWayBill, INSERTED
 WHERE HouseAirWayBill.HAWBKey = INSERTED.HAWBKey
 AND HouseAirWayBill.Status = "9")
 BEGIN
 SELECT @n_continue = 3
 SELECT @n_err=72302
 SELECT @c_errmsg="NSQL"+CONVERT(char(5),@n_err)+": HouseAirWayBill.Status = 'SHIPPED'. DELETE rejected. (ntrHouseAirWayBillDetailAdd)"
 END
 END
 
    --AK01 - S
   IF dbo.fnc_GetUserName() <> sUser_sName() AND @n_Continue IN (1,2) 
   BEGIN
      UPDATE HOUSEAIRWAYBILLDETAIL
        SET AddWho  = dbo.fnc_GetUserName(),
            AddDate = dbo.fnc_GetDate(), 
            EditWho  = dbo.fnc_GetUserName(),
            EditDate = dbo.fnc_GetDate(), 
            TrafficCop = NULL 
      FROM HOUSEAIRWAYBILLDETAIL
      JOIN INSERTED ON HOUSEAIRWAYBILLDETAIL.HAWBKEY = INSERTED.HAWBKEY
      AND HOUSEAIRWAYBILLDETAIL.HAWBLineNumber = INSERTED.HAWBLineNumber
      SELECT @n_err = @@ERROR
      IF @n_err <> 0
      BEGIN
         SELECT @n_continue = 3
         SELECT @c_errmsg = CONVERT(CHAR(250),@n_err), @n_err=72303
         SELECT @c_errmsg='NSQL'+CONVERT(char(5),@n_err)+': Update Failed On Table HOUSEAIRWAYBILLDETAIL. (ntrHOUSEAIRWAYBILLDETAILAdd)' + ' ( ' + ' SQLSvr MESSAGE=' + TRIM(@c_errmsg) + ' ) '
      END
   END
   --AK01 - E
   
      /* #INCLUDE <TRHABDA2.SQL> */
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
 execute nsp_logerror @n_err, @c_errmsg, "ntrHouseAirWayBillDetailAdd"
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

