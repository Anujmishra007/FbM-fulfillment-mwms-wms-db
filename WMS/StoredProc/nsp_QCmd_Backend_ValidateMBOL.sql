
IF exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[nsp_QCmd_Backend_ValidateMBOL]')
              and OBJECTPROPERTY(id, N'IsProcedure') = 1)
   DROP PROCEDURE [dbo].[nsp_QCmd_Backend_ValidateMBOL]
GO
  
/************************************************************************/  
/* Stored Procedure: nsp_QCmd_Backend_ValidateMBOL                      */  
/* Purpose: Update PickDetail to Status 9 from backend                  */  
/* Called By: SQL Schedule Job    BEJ - Backend ValidateMBOL (ALL)      */  
/* Updates:                                                             */  
/* Date         Author       Purposes                                   */  
/* 23-Mar-2020  Shong        Created                                    */
/************************************************************************/  
  
CREATE PROCEDURE [dbo].[nsp_QCmd_Backend_ValidateMBOL]  
      @c_MBOLKey        NVARCHAR(10)   
     ,@c_ValidatedFlag  NVARCHAR(1)
     ,@b_debug          INT = 0     
AS  
BEGIN  
   SET NOCOUNT ON  
   SET ANSI_NULLS OFF  
   SET QUOTED_IDENTIFIER OFF  
   SET CONCAT_NULL_YIELDS_NULL OFF 

   DECLARE @n_Continue        INT = 1,  
           @n_cnt             INT = 0,  
           @n_err             INT = 0,  
           @c_ErrMsg          NVARCHAR (255) = '',    
           @f_status          INT = '',  
           @n_StartTran       INT = 0,  
           @c_ContainerStatus NVARCHAR(10) = '0',  
           @d_EditDate        DATETIME   
   
   DECLARE @n_RowCnt          INT = 0,
           @b_ReturnCode      INT = 0,  
           @b_ReturnErr       INT = 0,  
           @c_ReturnErrMsg    NVARCHAR (255) = '',  
           @b_success         INT = 0   
     
   IF @c_ValidatedFlag = 'Y'  
   BEGIN  
      SET @b_ReturnCode = 0  
   END  
   ELSE  
   BEGIN
      EXEC isp_ValidateMBOL  
      @c_MBOLKey    = @c_MBOLKey,  
      @b_ReturnCode = @b_ReturnCode   OUTPUT, -- 0 = OK, -1 = Error, 1 = Warning  
      @n_err        = @b_ReturnErr    OUTPUT,  
      @c_errmsg     = @c_ReturnErrMsg OUTPUT,  
      @n_CBOLKey    = 0  
  
      IF @b_debug = 1  
      BEGIN  
         PRINT 'Validate Mbol Return Code - ' + CAST(@b_ReturnCode AS VARCHAR )  
         PRINT 'Validate MBOL Return msg - ' + @c_ReturnErrMsg  
      END  
    
      IF @b_ReturnCode <> 0  
      BEGIN  
         SELECT @c_ReturnErrMsg = 'MBOLKey - ' + @c_MBOLKey  
               + '. MBOL Validate Pass# - (' + CAST(@b_ReturnCode AS VARCHAR) + ') '  
               + ISNULL(@c_ReturnErrMsg,'')  
  
         execute nspLogAlert  
         @c_modulename   = 'nsp_QCmd_Backend_ValidateMBOL',  
         @c_alertmessage = @c_ReturnErrMsg ,  
         @n_severity     = 0,  
         @b_success      = @b_success output,  
         @n_err          = @n_err output,  
         @c_errmsg       = @c_errmsg output  
      END  
   END  
  
   IF @b_ReturnCode < 0  
   BEGIN  
      BEGIN TRAN  
      UPDATE MBOL WITH (ROWLOCK)  
         SET ValidatedFlag = 'E',  -- Error  
             ShipCounter = ISNULL(LTRIM(ShipCounter),0)+1 , 
             Editdate = GETDATE(),  
             TrafficCop = NULL   
      WHERE MBOLKEY = @c_MBOLKey  
      SELECT @n_err = @@ERROR  
      IF @n_err <> 0  
      BEGIN  
         ROLLBACK TRAN  
      END  
      ELSE  
      BEGIN  
         WHILE @@TRANCOUNT > 0  
         BEGIN  
            COMMIT TRAN  
         END  
      END  
   END  
   ELSE  
   BEGIN  
      SET @c_ContainerStatus = '0'  
  
      SELECT TOP 1  
         @c_ContainerStatus = ISNULL(C.[Status],'0')  
      FROM CONTAINER C WITH (NOLOCK)  
      JOIN dbo.ContainerDetail CD WITH (NOLOCK) ON C.ContainerKey = CD.ContainerKey  
      JOIN dbo.Mbol M WITH (NOLOCK) ON CD.PalletKey = M.ExternMbolKey  
      WHERE M.MBOLKey = @c_MBOLKey  
      AND C.ContainerType = 'ECOM'  
  
      IF @b_debug = 1  
      BEGIN  
         PRINT 'MBOLKey - ' + @c_MBOLKey  
         PRINT 'Container Status - ' + @c_ContainerStatus  
      END  
  
      IF @c_ContainerStatus = '9'  
      BEGIN  
         IF EXISTS(SELECT 1 FROM MBOL AS m WITH(NOLOCK) WHERE m.MbolKey = @c_MBOLKey AND m.[Status] <> '9')  
         BEGIN          
            EXECUTE dbo.isp_ShipMBOL @c_MBOLKey,  
                        @b_success    output,  
                        @n_err        output,  
                        @c_errmsg     output  
  
            IF @b_success <> 1  
            BEGIN  
               SELECT @n_continue = 3, @c_errmsg = 'isp_ShipMBOL Fail! ' + RTrim(@c_errmsg)  
            END  
         END  
         IF @n_continue = 1 OR @n_continue =2  
         BEGIN  
         IF EXISTS(SELECT 1 FROM MBOL AS m WITH(NOLOCK) WHERE m.MbolKey = @c_MBOLKey AND m.[Status] <> '9')  
         BEGIN  
            BEGIN TRAN               
            UPDATE MBOL WITH (ROWLOCK)  
            SET MBOL.Status = '9',  -- pending ship  
                FinalizeFlag = 'Y',  
                ValidatedFlag = 'Y', 
                ShipCounter = 1, -- reset the counter to 0 for backend ship 
                Editdate = GETDATE()  
            WHERE MBOLKEY = @c_MBOLKey  
            SELECT @n_err = @@ERROR, @n_cnt = @@ROWCOUNT  
            IF @n_err <> 0 OR @n_cnt = 0  
            BEGIN  
               SELECT @n_continue = 3, @c_errmsg = 'Fail to Update MBOL!'  
               ROLLBACK TRAN  
            END  
            ELSE  
            BEGIN  
               WHILE @@TRANCOUNT > 0  
               BEGIN  
                  COMMIT TRAN  
               END  
            END              
         END  
         END  
      END  
      ELSE  
      BEGIN  
         IF ( @n_continue = 1 OR @n_continue =2 )  
         BEGIN  
            BEGIN TRAN  
            
            UPDATE MBOL WITH (ROWLOCK)  
              SET ValidatedFlag = 'Y',
                  ShipCounter = 0, -- reset the counter to 0 for backend ship  
                  Editdate = GETDATE(),  
                  TrafficCop = NULL  
            WHERE MBOLKEY = @c_MBOLKey  
            SELECT @n_err = @@ERROR, @n_cnt = @@ROWCOUNT  
            IF @n_err <> 0 OR @n_cnt = 0  
            BEGIN  
               SELECT @n_continue = 3, @c_errmsg = 'Fail to Update MBOL!'  
               ROLLBACK TRAN  
            END  
            ELSE  
            BEGIN  
               WHILE @@TRANCOUNT > 0  
               BEGIN  
                  COMMIT TRAN  
               END  
            END  
         END  
      END  
  
      IF @b_debug = 1  
      BEGIN  
         PRINT 'Finalize Mbol - ' + @c_MBOLKey  
      END  
   END  
END -- Procedure
GO

GRANT EXECUTE ON [dbo].[nsp_QCmd_Backend_ValidateMBOL]   TO NSQL 
GO
