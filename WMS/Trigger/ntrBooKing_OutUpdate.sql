if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[ntrBooking_OutUpdate]') and OBJECTPROPERTY(id, N'IsTrigger') = 1)
drop trigger [dbo].[ntrBooking_OutUpdate]
GO

SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO

/************************************************************************/
/* Trigger: ntrBooking_OutUpdate                                        */
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
/* Called By: When records Updated                                      */
/*                                                                      */
/* PVCS Version: 1.0                                                    */
/*                                                                      */
/* Version: 5.4                                                         */
/*                                                                      */
/* Data Modifications:                                                  */
/*                                                                      */
/* Updates:                                                             */
/* Date         Author    Ver.    Purposes                              */
/* 25-SEP-2013 NJOW01  1.0   288370-Create booking audit record         */   
/* 28-Oct-2013  TLTING    1.1     Review Editdate column update         */
/************************************************************************/

CREATE TRIGGER ntrBooking_OutUpdate
ON  Booking_Out
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
   IF UPDATE(TrafficCop)
   BEGIN
      SELECT @n_continue = 4
   END
   IF UPDATE(ArchiveCop)
   BEGIN
      SELECT @n_continue = 4
   END

   IF @n_continue = 1 OR @n_continue = 2   
   BEGIN  
      --NJOW01  
      INSERT INTO Booking_Audit (BookingNo, BookingType, RouteAuth, Facility, BookingDate, EndTime, Duration, Loc, Type,  
                                SCAC, DriverName, LicenseNo, LoadKey, MbolKey, CBOLKey, Status, ALTReference,  
                                VehicleContainer, UserDefine01, UserDefine02, UserDefine03, UserDefine04,  
                                UserDefine05, UserDefine06, UserDefine07, UserDefine08, UserDefine09,  
                                UserDefine10, ArrivedTime, SignInTime, UnloadTime, DepartTime)  
      SELECT BookingNo, 'OUT', RouteAuth, Facility, BookingDate, EndTime, Duration, Loc, Type,                                  
             SCAC, DriverName, LicenseNo, LoadKey, MbolKey, CBOLKey, Status, ALTReference,                        
             VehicleContainer, UserDefine01, UserDefine02, UserDefine03, UserDefine04,         
             UserDefine05, UserDefine06, UserDefine07, UserDefine08, UserDefine09,             
             UserDefine10, ArrivedTime, SignInTime, UnloadTime, DepartTime  
      FROM INSERTED          
   END  
      
   IF ( @n_continue = 1 OR @n_continue = 2 ) AND NOT UPDATE(EditDate)
   BEGIN
      UPDATE BOOKING_OUT with (ROWLOCK)
      SET EditWho = sUser_sName(),
          EditDate = GetDate()
      FROM BOOKING_OUT 
      JOIN INSERTED ON BOOKING_OUT.BookingNo = INSERTED.BookingNo
		SELECT @n_err = @@ERROR, @n_cnt = @@ROWCOUNT

		IF @n_err <> 0
		BEGIN
			SELECT @n_continue = 3
			SELECT @c_errmsg = CONVERT(CHAR(250),@n_err), @n_err=69701   -- Should Be Set To The SQL Errmessage but I don't know how to do so.
			SELECT @c_errmsg='NSQL'+CONVERT(char(5),@n_err)+': Update Failed On Table BOOKING_OUT. (ntrBooking_OutUpdate)' + ' ( ' + ' SQLSvr MESSAGE=' + dbo.fnc_LTrim(dbo.fnc_RTrim(@c_errmsg)) + ' ) '
		END      
   END
   
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
   
	   EXECUTE nsp_logerror @n_err, @c_errmsg, "ntrBooking_OutUpdate"
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
