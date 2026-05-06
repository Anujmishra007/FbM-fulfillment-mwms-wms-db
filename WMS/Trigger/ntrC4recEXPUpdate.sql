
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS OFF 
GO

/* 28-Oct-2013  TLTING    1.1     Review Editdate column update         */
/* 08-Oct-2025  AK01      1.2     UWP-42143 - Replace SUSER_SNAME with fnc_GetUserName */

CREATE OR ALTER TRIGGER ntrC4recEXPUpdate
 ON  C4_Rec_Exp
 FOR UPDATE
 AS
 BEGIN
 	IF @@ROWCOUNT = 0
 	BEGIN
 		RETURN
 	END 
   SET NOCOUNT ON
   SET QUOTED_IDENTIFIER OFF
   SET CONCAT_NULL_YIELDS_NULL OFF

 	DECLARE @n_err int, @n_cnt int, @n_continue int, @c_errmsg NVARCHAR(250)
 	
 	IF NOT UPDATE(EditDate)
 	BEGIN
 	   UPDATE c4_rec_exp 
    	   SET EditDate = dbo.fnc_GetDate()
       	       
           FROM C4_rec_exp, INSERTED
          WHERE C4_REC_Exp.DOcumentkey = INSERTED.DOcumentkey
         SELECT @n_err = @@ERROR, @n_cnt = @@ROWCOUNT
 	   IF @n_err <> 0
    	BEGIN
       		SELECT @n_continue = 3
       		SELECT @c_errmsg = CONVERT(CHAR(250),@n_err), @n_err=72804   -- Should Be Set To The SQL Errmessage but I don't know how to do so.
       		SELECT @c_errmsg="NSQL"+CONVERT(char(5),@n_err)+": Update Failed On Table C4_REC_EXP. (ntrC4RECEXPUpdate)" + " ( " + " SQLSvr MESSAGE=" + dbo.fnc_LTrim(dbo.fnc_RTrim(@c_errmsg)) + " ) "
    	END
   END
 END

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS OFF 
GO


