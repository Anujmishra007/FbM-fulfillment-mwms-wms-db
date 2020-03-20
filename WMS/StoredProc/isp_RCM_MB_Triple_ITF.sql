IF EXISTS (SELECT name FROM dbo.sysobjects WHERE name = 'isp_RCM_MB_Triple_ITF' AND type = 'P')
   DROP PROC isp_RCM_MB_Triple_ITF
GO

SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS OFF 
GO

/************************************************************************/
/* Stored Procedure: isp_RCM_MB_Triple_ITF                              */
/* Creation Date: 02-MAY-2018                                           */
/* Copyright: LFL                                                       */
/* Written by:                                                          */
/*                                                                      */
/* Purpose: WMS-4895-MBOL RCM trigger SG Triple Interface               */
/*                                                                      */
/* Called By: MBOL Dymaic RCM configure at listname 'RCMConfig'         */ 
/*                                                                      */
/* Parameters:                                                          */
/*                                                                      */
/* PVCS Version: 1.0	                                                */
/*                                                                      */
/* Version: 7.0                                                         */
/*                                                                      */
/* Data Modifications:                                                  */
/*                                                                      */
/* Updates:                                                             */
/* Date         Author    Ver.  Purposes                                */
/************************************************************************/

CREATE  PROCEDURE isp_RCM_MB_Triple_ITF
   @c_Mbolkey NVARCHAR(10),   
   @b_success  int OUTPUT,
   @n_err      int OUTPUT,
   @c_errmsg   NVARCHAR(225) OUTPUT,
   @c_code     NVARCHAR(30)=''
AS
BEGIN 
   SET NOCOUNT ON
   SET ANSI_DEFAULTS OFF  
   SET QUOTED_IDENTIFIER OFF
   SET CONCAT_NULL_YIELDS_NULL OFF

   DECLARE @n_continue int,
           @n_cnt int,
           @n_starttcnt int
           
   DECLARE @c_Facility NVARCHAR(5),
           @c_storerkey NVARCHAR(15)
              
   SELECT @n_Continue = 1, @b_success = 1, @n_starttcnt=@@TRANCOUNT, @c_errmsg='', @n_err=0 
   
   SELECT TOP 1 @c_Facility = Facility,
                @c_Storerkey = Storerkey
   FROM ORDERS (NOLOCK)
   WHERE Mbolkey = @c_Mbolkey    

   EXEC dbo.ispGenTransmitLog3 'MBOLTNLOG', @c_Mbolkey, '', @c_StorerKey, ''  
        , @b_success OUTPUT  
        , @n_err OUTPUT  
        , @c_errmsg OUTPUT  
        
   IF @b_success = 0
       SELECT @n_continue = 3, @n_err = 60098, @c_errmsg = 'isp_RCM_MB_Triple_ITF: ' + rtrim(@c_errmsg)
     
ENDPROC: 
 
   IF @n_continue=3  -- Error Occured - Process And Return
	 BEGIN
	    SELECT @b_success = 0
	    IF @@TRANCOUNT = 1 and @@TRANCOUNT > @n_starttcnt
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
  	  execute nsp_logerror @n_err, @c_errmsg, 'isp_RCM_MB_Triple_ITF'
	    RAISERROR (@c_errmsg, 16, 1) WITH SETERROR    -- SQL2012
	    RETURN
	 END
	 ELSE
	    BEGIN
	       SELECT @b_success = 1
	       WHILE @@TRANCOUNT > @n_starttcnt
	       BEGIN
	          COMMIT TRAN
	       END
	       RETURN
	    END	   
END -- End PROC
GO 

GRANT EXECUTE ON isp_RCM_MB_Triple_ITF TO NSQL 
GO

SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS OFF
GO
