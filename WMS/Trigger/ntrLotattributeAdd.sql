IF EXISTS (SELECT name 
	   FROM   dbo.sysobjects 
	   WHERE  name = 'ntrlotattributeadd' 
	   AND 	  type = 'TR')
    DROP TRIGGER ntrlotattributeadd
GO
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO


/************************************************************************/
/* Trigger: ntrLOTATTRIBUTEAdd                                          */
/* Creation Date:  09-Sept-2008                                         */
/* Copyright: IDS                                                       */
/* Written by:  TLTING                                                  */
/*                                                                      */
/* Purpose: LOTATTRIBUTE Add Transaction                                */
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
/* Called By: When records Added                                        */
/*                                                                      */
/* PVCS Version: 1.1                                                    */
/*                                                                      */
/* Version: 5.4                                                         */
/*                                                                      */
/* Data Modifications:                                                  */
/*                                                                      */
/* Updates:                                                             */
/* Date         Author   Ver  Purposes                                  */
/* 24-Apr-2014  TLTING   1.1  Add Lottable06-15                         */
/************************************************************************/

CREATE TRIGGER ntrlotattributeadd
ON LOTATTRIBUTE
FOR INSERT
AS 
BEGIN
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
	
	DECLARE	@n_err                int       -- Error number returned by stored procedure or this trigger
	,         @c_errmsg             NVARCHAR(250) -- Error message returned by stored procedure or this trigger
	,         @n_continue int                 
	,         @n_starttcnt int                -- Holds the current transaction count
	,         @n_cnt int                  
	
	SELECT @n_continue=1, @n_starttcnt=@@TRANCOUNT
	
	-- to trim leading and trailing spaces of lotattributes 01, 02, 03
	-- tlting 24Apr14 trim for added lottable06-12
	IF @n_continue=1 or @n_continue=2
	BEGIN
		BEGIN TRAN
		UPDATE lotattribute
		SET lottable01 = ISNULL(LTrim(RTrim(i.lottable01)), ''),
			 lottable02 = ISNULL(LTrim(RTrim(i.lottable02)), ''),
			 lottable03 = ISNULL(LTrim(RTrim(i.lottable03)), ''),
			 lottable06 = ISNULL(LTrim(RTrim(i.lottable06)), ''), -- tlting
			 lottable07 = ISNULL(LTrim(RTrim(i.lottable07)), ''),
			 lottable08 = ISNULL(LTrim(RTrim(i.lottable08)), ''),
			 lottable09 = ISNULL(LTrim(RTrim(i.lottable09)), ''),			 			 			 			 
			 lottable10 = ISNULL(LTrim(RTrim(i.lottable10)), ''),			 			 			 			 
			 lottable11 = ISNULL(LTrim(RTrim(i.lottable11)), ''),			 			 			 			 
			 lottable12 = ISNULL(LTrim(RTrim(i.lottable12)), '')			 
		FROM lotattribute la JOIN inserted i
			ON la.lot = i.lot

		SELECT @n_err = @@ERROR, @n_cnt = @@ROWCOUNT
		IF @n_err <> 0
		BEGIN
			SELECT @n_continue = 3
			SELECT @c_errmsg = CONVERT(CHAR(250),@n_err), @n_err=62301   -- Should Be Set To The SQL Errmessage but I don't know how to do so.
			SELECT @c_errmsg="NSQL"+CONVERT(char(5),@n_err)+": UPDATE Failed on LOTATTRIBUTE table. (ntrlotattributeadd)" + " ( " + " SQLSvr MESSAGE=" + dbo.fnc_LTrim(dbo.fnc_RTrim(@c_errmsg)) + " ) "
		END
	END
	
	IF @n_continue=3  -- Error Occured - Process And Return
	BEGIN
		IF @@TRANCOUNT = 1 and @@TRANCOUNT >= @n_starttcnt
		BEGIN
			ROLLBACK TRAN
		END
		execute nsp_logerror @n_err, @c_errmsg, "ntrlotattributeadd"
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
