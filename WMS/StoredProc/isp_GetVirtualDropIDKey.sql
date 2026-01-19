SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS OFF 
GO


/************************************************************************/  
/* Stored Procedure:  isp_GetVirtualDropIDKey                           */  
/* Creation Date:  16-Jan-2026                                          */  
/* Copyright: MAERSK                                                    */  
/* Written by:                                                          */  
/*                                                                      */  
/* Purpose:  Generate Virtual Drop ID (QC-VirtualXXX) using nCounter    */  
/*                                                                      */ 
/* Date         Author     Version  Description                         */ 
/* 16-Jan-2026  NYE018     1.0      FCR-10039 Created                   */
/************************************************************************/ 

CREATE OR ALTER PROC [dbo].[isp_GetVirtualDropIDKey]
(   @n_FieldLength  INT
  , @c_KeyString    NVARCHAR(25)  OUTPUT
  , @b_Success      INT           OUTPUT
  , @n_Err          INT           OUTPUT
  , @c_ErrMsg       NVARCHAR(250) OUTPUT
)
AS
BEGIN
   SET NOCOUNT ON
   SET ANSI_NULLS OFF
   SET QUOTED_IDENTIFIER OFF
   SET CONCAT_NULL_YIELDS_NULL OFF

   DECLARE @n_Key       INT
   DECLARE @n_count     INT /* next key */
   DECLARE @n_ncnt      int
   DECLARE @n_starttcnt int /* Holds the current transaction count */
   DECLARE @n_continue  int /* Continuation flag: 1=Continue, 2=failed but continue processsing, 3=failed do not continue processing, 4=successful but skip furthur processing */
   DECLARE @n_cnt       int /* Variable to record if @@ROWCOUNT=0 after UPDATE */
   
   SELECT  @n_starttcnt=@@TRANCOUNT, @n_continue=1, @b_success=0, @n_err=0, @c_errmsg=''

   BEGIN TRANSACTION

   -- Try to update and increment/reset the counter
   -- Logic: If KeyCount >= 999, reset to 1, else increment by 1
   UPDATE nCounter WITH (ROWLOCK)
   SET @n_Key = KeyCount = CASE WHEN KeyCount >= 999 THEN 1 ELSE KeyCount + 1 END,
       EditDate = GETDATE()
   WHERE KeyName = 'VIRTUALDROPID'

   SELECT @n_Err = @@ERROR, @n_cnt = @@ROWCOUNT
   
   IF @n_Err <> 0
   BEGIN
       SET @n_continue = 3
       SET @c_ErrMsg = 'Error updating nCounter for VIRTUALDROPID'
   END

   -- If no row was updated, it means the key doesn't exist. Insert it.
   IF @n_continue = 1 AND @n_cnt = 0
   BEGIN
       INSERT INTO nCounter (KeyName, KeyCount, EditDate) 
       VALUES ('VIRTUALDROPID', 1, GETDATE())
       
       SELECT @n_Err = @@ERROR, @n_Key = 1 -- Initialize key to 1 on insert
       
       IF @n_Err <> 0
       BEGIN
           SET @n_continue = 3
           SET @c_ErrMsg = 'Error inserting into nCounter for VIRTUALDROPID'
       END
   END

   IF @n_continue = 1 OR @n_continue = 2
   BEGIN
       -- Format: QC-VIRTUALXXX
       SELECT @c_KeyString = 'QC-VIRTUAL' + RIGHT('000' + CAST(@n_Key AS NVARCHAR(10)), 3)
   END
   ELSE
   BEGIN
       SELECT @c_KeyString = ''
   END

   IF @n_continue=3  -- Error Occured - Process And Return
   BEGIN
      SELECT @b_success = 0
      IF @@TRANCOUNT = 1 AND @@TRANCOUNT > @n_starttcnt
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
      EXECUTE nsp_logerror @n_err, @c_errmsg, 'isp_GetVirtualDropIDKey'
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
END
GO
GRANT EXECUTE ON [dbo].[isp_GetVirtualDropIDKey] TO [NSQL]
GO