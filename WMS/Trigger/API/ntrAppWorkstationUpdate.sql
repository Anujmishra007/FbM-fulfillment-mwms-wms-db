if exists (select * from dbo.sysobjects where id = object_id(N'[API].[ntrAppWorkstationUpdate]') 
              and OBJECTPROPERTY(id, N'IsTrigger') = 1) 
   drop trigger [API].[ntrAppWorkstationUpdate]
GO

SET ANSI_NULLS OFF
GO

SET QUOTED_IDENTIFIER OFF
GO


/************************************************************************/
/* Trigger: ntrAppWorkstationUpdate                                     */
/* Creation Date:                                                       */
/* Copyright: IDS                                                       */
/* Written by:                                                          */
/*                                                                      */
/* Data Modifications:                                                  */
/*                                                                      */
/* Updates:                                                             */
/* Date         Author    Purposes                                      */
/* 05-05-2020  Chermaine  Review Editdate column update                 */
/************************************************************************/
CREATE TRIGGER [API].[ntrAppWorkstationUpdate] ON [API].[AppWorkstation] 
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
	
   DECLARE @n_continue int
         , @b_success  int       -- Populated by calls to stored procedures - was the proc successful?
		   , @n_err      int       -- Error number returned by stored procedure or this trigger  
		   , @c_errmsg   NVARCHAR(250) -- Error message returned by stored procedure or this trigger 

	

	IF NOT UPDATE(EditDate)
	BEGIN
	 	UPDATE API.AppWorkstation
	 	SET EditDate = GETDATE(),
	 	    EditWho = SUSER_SNAME()
	 	FROM API.AppWorkstation (NOLOCK),	INSERTED
 	  WHERE AppWorkstation.Workstation = INSERTED.Workstation
 	  
	END
   /* Return Statement */  
END

--ALTER TABLE [API].[AppWorkstation]  ENABLE TRIGGER [ntrAppWorkstationUpdate]
GO

ALTER TABLE [API].[AppWorkstation] ENABLE TRIGGER [ntrAppWorkstationUpdate]
GO


