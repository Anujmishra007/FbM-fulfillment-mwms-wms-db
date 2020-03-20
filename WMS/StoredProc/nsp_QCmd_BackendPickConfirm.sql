
IF EXISTS ( SELECT * FROM dbo.sysobjects WHERE  id = OBJECT_ID(N'[dbo].[nsp_QCmd_BackendPickConfirm]') 
AND OBJECTPROPERTY(id ,N'IsProcedure') = 1 ) 
   DROP PROCEDURE [dbo].[nsp_QCmd_BackendPickConfirm]
GO

SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS OFF 
GO


/************************************************************************/  
/* Stored Procedure: nsp_QCmd_BackendPickConfirm                        */  
/* Purpose: Update PickDetail to Status 5 from Q-Cmd                    */  
/* Return Status: None                                                  */  
/* Called By: SQL Schedule Job BEJ - Backend Pick (All Storers)         */  
/* Updates:                                                             */  
/* Date         Author       Purposes                                   */  
/************************************************************************/  
CREATE PROCEDURE [dbo].[nsp_QCmd_BackendPickConfirm] 
   @c_PickDetailKey  NVARCHAR (10)  
  ,@b_Debug          INT=0  
AS
BEGIN
    SET NOCOUNT ON  
    SET ANSI_NULLS OFF
    SET QUOTED_IDENTIFIER OFF  
    SET CONCAT_NULL_YIELDS_NULL OFF  
    
    DECLARE @n_Continue          INT
           ,@n_cnt               INT
           ,@n_err               INT
           ,@c_ErrMsg            NVARCHAR(255)
           ,@n_RowCnt            INT
           ,@b_success           INT
           ,@f_Status            INT
           ,@c_AlertKey          NVARCHAR(18) --KH01
           ,@n_ErrSeverity       INT
           ,@d_Begin             DATETIME
           ,@n_ErrState          INT
           ,@c_Host              NVARCHAR(128)
           ,@c_Module            NVARCHAR(128)
           ,@c_SQL               NVARCHAR(4000)
           ,@c_Value             NVARCHAR(30)
    
   SELECT @n_continue = 1 

   SELECT @c_ErrMsg = '', @n_Err = 0, @n_cnt = 0, @n_ErrSeverity=0   --KH01
   BEGIN TRY
      SET @d_Begin = GETDATE()
         
      IF @b_debug = 1   -- KHLim01  
      BEGIN  
         PRINT 'Updating PickDetail with PickDetailKey: ' + @c_PickDetailKey  
      END  
  
      SET @c_SQL = N' UPDATE PICKDETAIL WITH (ROWLOCK) ' + 
         + ' SET Status = 5, EditDate = EditDate ' +   
         + ' WHERE PickDetailKey = ''' + @c_PickDetailKey + ''' ' + 
         + ' AND PICKDETAIL.Status < ''4'' ' + 
         + ' AND ShipFlag = ''P'''

      BEGIN TRAN 
                  
      UPDATE PICKDETAIL WITH (ROWLOCK)  
            SET Status = '5', EditDate = EditDate   
      WHERE PickDetailKey = @c_PickDetailKey
         AND   PICKDETAIL.Status < '4'
         AND   ShipFlag = 'P'
         
      SELECT @n_err = @@ERROR, @n_cnt = @@ROWCOUNT
   END TRY
   BEGIN CATCH
      SET @n_Err        = ERROR_NUMBER()
      SET @c_ErrMsg     = ERROR_MESSAGE();
      SET @n_ErrSeverity = ERROR_SEVERITY();
      SET @n_ErrState    = ERROR_STATE();
   END CATCH

     
   IF @n_err <> 0  
   BEGIN  
      SELECT @n_continue = 3 
      SELECT @c_errmsg='NSQL72806: Update Failed On Table PICKDETAIL. ('+@c_Module+')' + ' ( SQLSvr MESSAGE=' + LTrim(RTrim(@c_errmsg)) + ' ) ' 
      ROLLBACK TRAN  
   END  
   ELSE  
   BEGIN  
      WHILE @@TRANCOUNT > 0  
      COMMIT TRAN  
      IF @b_debug = 1   -- KHLim01  
      BEGIN  
         PRINT 'Updating PickDetail with PickDetailKey: ' + @c_PickDetailKey   + ' Start at ' 
               + CONVERT(CHAR(10), @d_Begin, 108) + ' End at ' + CONVERT(CHAR(10), Getdate(), 108)  
      END  
   END  
  
   IF OBJECT_ID('ALERT','u') IS NOT NULL  
   BEGIN
      IF @c_Value = '1' OR @n_err <> 0      
      BEGIN
         EXECUTE nspg_getkey 'LogEvent', 18, @c_AlertKey OUTPUT, '', '', ''
         INSERT ALERT(AlertKey,ModuleName,AlertMessage,Severity,NotifyId,Status,ResolveDate,Resolution,Storerkey,Qty, Lot,Loc,ID,TaskDetailKey) 
         VALUES (@c_AlertKey,@c_Module,@c_ErrMsg,@n_ErrSeverity,@c_Host,@n_err,@d_Begin,@c_SQL,'',@n_cnt,'','','',@c_PickDetailKey)
      END
   END
  
             
    /* #INCLUDE <SPTPA01_2.SQL> */  
    IF @n_continue=3 -- Error Occured - Process And Return
    BEGIN
        SELECT @b_success = 0  
        EXECUTE nsp_logerror @n_err,
             @c_errmsg,
             @c_Module
        
        RAISERROR (@c_errmsg ,16 ,1) WITH SETERROR
        RETURN
    END
END -- PROCEDURE
GO


GRANT EXECUTE ON [dbo].[nsp_QCmd_BackendPickConfirm] TO NSQL
GO


