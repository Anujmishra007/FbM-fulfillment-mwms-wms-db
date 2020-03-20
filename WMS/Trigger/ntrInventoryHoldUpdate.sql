IF EXISTS (SELECT * FROM dbo.sysobjects WHERE id = object_id(N'[dbo].[ntrInventoryHoldUpdate]') and OBJECTPROPERTY(id, N'IsTrigger') = 1)
    DROP TRIGGER [dbo].[ntrInventoryHoldUpdate]
GO

SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
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
/************************************************************************/  
CREATE TRIGGER ntrInventoryHoldUpdate  
ON  InventoryHold  
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