IF EXISTS (SELECT * FROM DBO.SYSOBJECTS WHERE ID = OBJECT_ID(N'[dbo].[ntrRCMReportDelete]') 
AND OBJECTPROPERTY(id, N'IsTrigger') = 1)
DROP TRIGGER [dbo].ntrRCMReportDelete
GO

SET ANSI_NULLS OFF
GO

SET QUOTED_IDENTIFIER OFF
GO


/*********************************************************************************/  
/* Trigger:  ntrRCMReportDelete                                                  */
/* Creation Date:                                                                */
/* Copyright: IDS                                                                */
/* Written by:                                                                   */
/*                                                                               */
/* Purpose:  Trigger point upon any Delete on the RCMReport                      */
/*                                                                               */
/* Return Status:  None                                                          */
/*                                                                               */
/* Usage:                                                                        */
/*                                                                               */
/* Local Variables:                                                              */
/*                                                                               */
/* Called By: When records Deleted                                               */
/*                                                                               */
/* PVCS Version: 1.0                                                             */
/*                                                                               */
/* Version: 5.4                                                                  */
/*                                                                               */
/* Data Modifications:                                                           */
/*                                                                               */
/* Updates:                                                                      */
/* Date         Author    Ver.  Purposes                                         */
/* 04-Mar-2022  TLTING    1.1   Initial ver. prevent bulk Delete                 */ 
/*********************************************************************************/  
 

CREATE   TRIGGER [dbo].[ntrRCMReportDelete]
 ON [dbo].[RCMReport]
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

   DECLARE @b_Success       INT,       -- Populated by calls to stored procedures - was the proc successful?
   @n_err              INT,       -- Error number returned by stored procedure or this trigger
   @c_errmsg           NVARCHAR(250), -- Error message returned by stored procedure or this trigger
   @n_continue         INT,       -- continuation flag: 1=Continue, 2=failed but continue processsing, 3=failed do not continue processing, 4=successful but skip further processing
   @n_starttcnt        INT,       -- Holds the current transaction count
   @n_cnt              INT,        -- Holds the number of rows affected by the DELETE statement that fired this trigger.
   @c_authority        NVARCHAR(1)  -- KHLim02

   SELECT @n_continue=1, @n_starttcnt=@@TRANCOUNT

      /* #INCLUDE <TRTHD1.SQL> */      

   IF ( (SELECT COUNT(1) FROM   Deleted  ) > 100 ) 
       AND SUSER_SNAME() NOT IN ( 'itadmin', 'alpha\wmsadmingt', 'ALPHA\SRVwmsadminlfl', 'ALPHA\SRVwmsadmincn', 'iml'    )
   BEGIN      
         SELECT @n_continue = 3
         SELECT @c_errmsg = CONVERT(CHAR(250),@n_err), @n_err=68108   -- Should Be Set To The SQL Errmessage but I don't know how to do so.
         SELECT @c_errmsg="NSQL"+CONVERT(CHAR(5),@n_err)+": Delete Failed On Table RCMReport. Batch Delete not allow! (ntrRCMReportDelete)" + " ( " + " SQLSvr MESSAGE=" + LTRIM(RTRIM(@c_errmsg)) + " ) "
   END

      /* #INCLUDE <TRTHD2.SQL> */
   IF @n_continue=3  -- Error Occured - Process And Return
   BEGIN
      IF @@TRANCOUNT = 1 AND @@TRANCOUNT >= @n_starttcnt
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
      EXECUTE nsp_logerror @n_err, @c_errmsg, "ntrRCMReportDelete"
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

ALTER TABLE [dbo].[RCMReport] ENABLE TRIGGER [ntrRCMReportDelete]
GO


