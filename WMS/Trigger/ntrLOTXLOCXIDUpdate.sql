if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[ntrLOTXLOCXIDUpdate]') and OBJECTPROPERTY(id, N'IsTrigger') = 1)
drop trigger [dbo].[ntrLOTXLOCXIDUpdate]
GO

SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO


/************************************************************************/
/* Trigger: ntrLOTXLOCXIDUpdate                                         */
/* Creation Date:                                                       */
/* Copyright: IDS                                                       */
/* Written by:  TLTING                                                  */
/*                                                                      */
/* Purpose:  LOTXLOCXID Update                                          */
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
/* 23 May 2012  TLTING01  DM integrity - add update editdate B4         */
/*                        TrafficCop                                    */ 
/* 28-Oct-2013  TLTING    Review Editdate column update                 */
/* 28-Sep-2018  TLTING    remove row lock                               */
/* 09-Oct-2025  SPC040  1.0  Replace SUSER_SNAME with fnc_GetUserName   */
/************************************************************************/

CREATE TRIGGER [dbo].[ntrLOTXLOCXIDUpdate]
ON  [dbo].[LOTxLOCxID] FOR UPDATE
AS
BEGIN
	IF @@ROWCOUNT = 0
	BEGIN
		RETURN
	END

/* ---- WMS-MIGRATION GUARD (FN839 Phase 2 dual-run) - codegen-managed, do not hand-edit. ----
   Skip this trigger's body ONLY when the request is from the MODERN app AND this trigger is
   already migrated to Java (its wms.skip.<name> flag is set for the session). Every other case
   - legacy caller, or trigger not yet migrated - falls through and runs the body as today.
   Placed AFTER the @@ROWCOUNT check so that check still sees the row count untouched.
   Signals are set once per connection by WM.lsp_SetTriggerOwner. See memory dual-run-trigger-routing. */
IF CONVERT(NVARCHAR(20), SESSION_CONTEXT(N'wms.app_source')) = N'MODERN'
   AND CONVERT(INT, ISNULL(SESSION_CONTEXT(CONCAT(N'wms.skip.', OBJECT_NAME(@@PROCID))), 0)) = 1
BEGIN
   RETURN
END
/* ---- END WMS-MIGRATION GUARD ---- */
   SET NOCOUNT ON
   SET ANSI_NULLS OFF
   SET QUOTED_IDENTIFIER OFF
   SET CONCAT_NULL_YIELDS_NULL OFF

	DECLARE @b_Success    int       -- Populated by calls to stored procedures - was the proc successful?
			, @n_err        int       -- Error number returned by stored procedure or this trigger
			, @n_err2       int       -- For Additional Error Detection
			, @c_errmsg     NVARCHAR(250) -- Error message returned by stored procedure or this trigger
			, @n_continue   int                 
			, @n_starttcnt  int       -- Holds the current transaction count
			, @c_preprocess NVARCHAR(250) -- preprocess
			, @c_pstprocess NVARCHAR(250) -- post process
			, @n_cnt        int                  

	SELECT @n_continue=1, @n_starttcnt=@@TRANCOUNT

	IF UPDATE(ArchiveCop)
	BEGIN
		SELECT @n_continue = 4 
	END
	
   -- tlting01
	IF ( @n_continue = 1 or @n_continue=2 ) AND NOT UPDATE(EditDate)
	BEGIN
		UPDATE LOTXLOCXID  
		SET EditDate = dbo.fnc_GetDate(),
		    EditWho = dbo.fnc_GetUserName(),
		    TrafficCop = NULL
		FROM LOTXLOCXID , INSERTED (NOLOCK)
		WHERE LOTXLOCXID.LOT = INSERTED.LOT
		AND LOTXLOCXID.LOC = INSERTED.LOC
		AND LOTXLOCXID.ID = INSERTED.ID
		SELECT @n_err = @@ERROR, @n_cnt = @@ROWCOUNT
		IF @n_err <> 0
		BEGIN
			SELECT @n_continue = 3
			SELECT @c_errmsg = CONVERT(CHAR(250),@n_err), @n_err=69701   -- Should Be Set To The SQL Errmessage but I don't know how to do so.
			SELECT @c_errmsg='NSQL'+CONVERT(char(5),@n_err)+': Update Failed On Table LOTXLOCXID. (ntrLOTXLOCXIDUpdate)' + ' ( ' + ' SQLSvr MESSAGE=' + dbo.fnc_LTrim(dbo.fnc_RTrim(@c_errmsg)) + ' ) '
		END
	END

	IF UPDATE(TrafficCop)
	BEGIN
		SELECT @n_continue = 4 
	END
	   /* #INCLUDE <TRTHU1.SQL> */     

      /* #INCLUDE <TRTHU2.SQL> */
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
		execute nsp_logerror @n_err, @c_errmsg, 'ntrLOTXLOCXIDUpdate'
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


