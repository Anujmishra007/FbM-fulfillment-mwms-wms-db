IF EXISTS (SELECT name FROM dbo.sysobjects WHERE name = 'ntrWaveDetailUpdate' AND type = 'TR')
   DROP TRIGGER ntrWaveDetailUpdate
GO
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

/************************************************************************/
/* Trigger: ntrWaveDetailUpdate                                         */
/* Creation Date:                                                       */
/* Copyright: IDS                                                       */
/* Written by:                                                          */
/*                                                                      */
/* Purpose:  WAVE Update Transaction                                    */
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
/* Called By: When update records                                       */
/*                                                                      */
/* PVCS Version: 1.0                                                    */
/*                                                                      */
/* Version: 6.0                                                         */
/*                                                                      */
/* Data Modifications:                                                  */
/*                                                                      */
/* Updates:                                                             */
/* Date         Author    Purposes                                      */
/* 25 May 2012  TLTING01  DM integrity - add update editdate B4         */
/*                        TrafficCop                                    */ 
/* 28-Oct-2013  TLTING    Review Editdate column update                 */
/************************************************************************/

CREATE TRIGGER ntrWaveDetailUpdate  
 ON  WaveDetail  
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
 @b_Success            int       -- Populated by calls to stored procedures - was the proc successful?  
 ,         @n_err                int       -- Error number returned by stored procedure or this trigger  
 ,         @n_err2 int              -- For Additional Error Detection  
 ,         @c_errmsg             NVARCHAR(250) -- Error message returned by stored procedure or this trigger  
 ,         @n_continue int                   
 ,         @n_starttcnt int                -- Holds the current transaction count  
 ,         @c_preprocess NVARCHAR(250)         -- preprocess  
 ,         @c_pstprocess NVARCHAR(250)         -- post process  
 ,         @n_cnt int                    
 ,  @c_wavekey NVARCHAR(10)   
 SELECT @n_continue=1, @n_starttcnt=@@TRANCOUNT  
      /* #INCLUDE <TROHA1.SQL> */ 
      
 IF UPDATE(ArchiveCop)
 BEGIN
 SELECT @n_continue = 4 
 END      
 --tlting01
 IF ( @n_continue = 1 or @n_continue=2 ) AND NOT UPDATE(EditDate)
 BEGIN 
	 UPDATE WAVEDetail
	 SET EditDate = GETDATE(),
	     EditWho  = SUSER_SNAME(),
	     TrafficCop = NULL
	 FROM WAVEDetail (NOLOCK), INSERTED (NOLOCK)
    WHERE WAVEDetail.WaveDetailKey = INSERTED.WaveDetailKey
	 SELECT @n_err = @@ERROR, @n_cnt = @@ROWCOUNT

	 IF @n_err <> 0
	 BEGIN
  		SELECT @n_continue = 3
		SELECT @c_errmsg = CONVERT(CHAR(250),@n_err), @n_err=69701   -- Should Be Set To The SQL Errmessage but I don't know how to do so.
		SELECT @c_errmsg='NSQL'+CONVERT(char(5),@n_err)+': Update Failed On Table WAVE. (ntrWaveHeaderUpdate)' + ' ( ' + ' SQLSvr MESSAGE=' + dbo.fnc_LTrim(dbo.fnc_RTrim(@c_errmsg)) + ' ) '
	 END
 END            

 IF UPDATE(TrafficCop)
 BEGIN
 SELECT @n_continue = 4 
 END
 /* 2001/10/12 CS IDSHK071 Prevent wavedetail from being modified if the orders have been pciked - start */   
 IF @n_continue = 1 OR @n_continue = 2  
 BEGIN  
    IF EXISTS (SELECT 1 FROM PICKDETAIL, DELETED  WHERE PICKDETAIL.OrderKey = DELETED.OrderKey   
                AND  PICKDETAIL.Status >= '3')  
    BEGIN  
      SELECT @n_continue = 3  
      SELECT @c_errmsg = CONVERT(CHAR(250),@n_err), @n_err=121003   -- Should Be Set To The SQL Errmessage but I don't know how to do so.  
      SELECT @c_errmsg="NSQL"+CONVERT(char(5),@n_err)+": Picking in progress for the orders. (ntrWaveDetailUpdate)" + " ( " + " SQLSvr MESSAGE=" + dbo.fnc_LTrim(dbo.fnc_RTrim(@c_errmsg)) + " ) "  
    END  
 END
 -- reject manual type orders ('M'): SOS 4565
 IF @n_continue = 1 OR @n_continue = 2
 BEGIN
 	IF EXISTS (SELECT 1 FROM INSERTED, ORDERS (NOLOCK)
 	WHERE ORDERS.Orderkey = INSERTED.Orderkey
 	AND ORDERS.type = 'M' ) 
 	BEGIN
 		SELECT @n_continue = 3
 		SELECT @c_errmsg = CONVERT(CHAR(250),@n_err), @n_err=62301   -- Should Be Set To The SQL Errmessage but I don't know how to do so.
 		SELECT @c_errmsg="NSQL"+CONVERT(char(5),@n_err)+": Manual Orders cannot be waved.(ntrWaveDetailAdd)" + " ( " + " SQLSvr MESSAGE=" + dbo.fnc_LTrim(dbo.fnc_RTrim(@c_errmsg)) + " ) "	
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
    execute nsp_logerror @n_err, @c_errmsg, "ntrWaveDetailUpdate"  
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
