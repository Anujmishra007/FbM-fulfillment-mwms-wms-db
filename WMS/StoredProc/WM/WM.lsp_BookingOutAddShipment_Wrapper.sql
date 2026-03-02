SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO   
/************************************************************************/                                                                                  
/* Store Procedure: WM.lsp_BookingOutAddShipment_Wrapper                */                                                                                  
/* Creation Date: 2022-03-02                                            */                                                                                  
/* Copyright: LFL                                                       */                                                                                  
/* Written by: Wan                                                      */                                                                                  
/*                                                                      */                                                                                  
/* Purpose: LFWM-3336 - Door Booking SPsDB queries clarification        */
/*                                                                      */                                                                                  
/* Called By: SCE                                                       */                                                                                  
/*          :                                                           */                                                                                  
/* PVCS Version: 1.0                                                    */                                                                                  
/*                                                                      */                                                                                  
/* Version: 8.0                                                         */                                                                                  
/*                                                                      */                                                                                  
/* Data Modifications:                                                  */                                                                                  
/*                                                                      */                                                                                  
/* Updates:                                                             */                                                                                  
/* Date        Author   Ver.  Purposes                                  */ 
/* 2022-03-02  Wan01    1.0   Created.                                  */
/* 2022-03-02  Wan01    1.0   DevOps Combine Script.                    */
/* 2025-09-02  SWT01    1.1   Enhanced session management and cleanup.  */
/* 2025-10-10  AK01     1.2   UWP-41151 - Replace SUSER_SNAME with      */
/*                            fnc_GetUserName & GETDATE() to fnc_GetDate()*/
/* 2025-02-26  YGO050   1.3   fCR-10661                               */
/************************************************************************/                                                                                  
CREATE OR ALTER PROC [WM].[lsp_BookingOutAddShipment_Wrapper]                                                                                                                     
      @n_BookingNo            INT 
   ,  @c_ShipmentGIDs         NVARCHAR(1000)                -- Multiple ShipmentGID Seperated by '|' 
   ,  @b_Success              INT = 1           OUTPUT  
   ,  @n_err                  INT = 0           OUTPUT                                                                                                             
   ,  @c_ErrMsg               NVARCHAR(255)= '' OUTPUT 
   ,  @c_UserName             NVARCHAR(128)= ''                                                                                                                         
AS  
BEGIN                                                                                                                                                        
   SET NOCOUNT ON                                                                                                                                           
   SET ANSI_NULLS OFF                                                                                                                                       
   SET QUOTED_IDENTIFIER OFF                                                                                                                                
   SET CONCAT_NULL_YIELDS_NULL OFF       

   DECLARE  @n_StartTCnt            INT = @@TRANCOUNT  
         ,  @n_Continue             INT = 1
         ,  @b_ExecuteAs            BIT = 0

   DECLARE @t_Shipment     TABLE
         (  RowRef         INT             PRIMARY KEY
         ,  ShipmentGID    NVARCHAR(50)    NOT NULL DEFAULT('')
         ,  BookingNo      INT             NOT NULL  -- YGO050
         )

   SET @b_Success = 1
   SET @n_Err     = 0
   
   SET @n_Err = 0 
 
   IF SUSER_SNAME() <> @c_UserName
   BEGIN
      EXEC [WM].[lsp_SetUser] 
            @c_UserName = @c_UserName  OUTPUT
         ,  @b_ExecuteAs = @b_ExecuteAs OUTPUT
         ,  @n_Err      = @n_Err       OUTPUT
         ,  @c_ErrMsg   = @c_ErrMsg    OUTPUT
                
      IF @n_Err <> 0 
      BEGIN
         GOTO EXIT_SP
      END
    
      IF @b_ExecuteAs = 1
      BEGIN
         EXECUTE AS LOGIN = @c_UserName
      END
   END

BEGIN TRAN
BEGIN TRY
INSERT INTO @t_Shipment (RowRef, ShipmentGID )  -- YGO050
SELECT ts.Rowref, ts.ShipmentGID             -- YGO050
FROM STRING_SPLIT(@c_ShipmentGIDs,'|') AS ss
         JOIN dbo.TMS_Shipment AS ts WITH (NOLOCK) ON ts.ShipmentGID = ss.[value]
WHERE (ts.BookingNo = 0 OR ts.BookingNo IS NULL)

UPDATE ts WITH (ROWLOCK)
SET BookingNo = @n_BookingNo
FROM @t_Shipment AS ts2
    JOIN dbo.TMS_Shipment AS ts ON ts.RowRef = ts2.RowRef

    IF @@ERROR <> 0
BEGIN
         SET @n_Continue = 3
         SET @n_Err = 560451
         SET @c_ErrMsg = 'MSQL' + CONVERT(CHAR(6),@n_Err) + ': Update TMS_Shipment fail. (lsp_BookingOutAddShipment_Wrapper)'
         GOTO EXIT_SP
      END
      
      IF EXISTS (SELECT 1 FROM dbo.Booking_Out AS bo WITH (NOLOCK) WHERE bo.BookingNo = @n_BookingNo AND bo.[Status] = 'R')
      BEGIN
         UPDATE dbo.Booking_Out WITH (ROWLOCK)
            SET [Status] = '0'
               ,EditWho = dbo.fnc_GetUserName()
               ,EditDate = dbo.fnc_GetDate()
         WHERE BookingNo = @n_BookingNo
         AND [Status] = 'R'
         
         IF @@ERROR <> 0 
         BEGIN
            SET @n_Continue = 3
            SET @n_Err = 560452
            SET @c_ErrMsg = 'MSQL' + CONVERT(CHAR(6),@n_Err) + ': Update Booking_Out fail. (lsp_BookingOutAddShipment_Wrapper)'
            GOTO EXIT_SP
END
END
   --YGO050 - START
      -- Update RECEIPT.Appointment_No for outbound booking using WHERE IN statement instead of cursor
      UPDATE dbo.RECEIPT WITH (ROWLOCK)
      SET Appointment_No = ts.BookingNo
      FROM @t_Shipment AS ts
      WHERE dbo.RECEIPT.ExternReceiptKey = ts.ShipmentGID

      IF @@ERROR <> 0
      BEGIN
            SET @n_Continue = 3
            SET @n_Err = 560453
            SET @c_ErrMsg = 'MSQL' + CONVERT(CHAR(6),@n_Err) + ': Update RECEIPT fail. (lsp_BookingOutAddShipment_Wrapper)'
            GOTO EXIT_SP
      END
--YGO050 - END
END TRY

BEGIN CATCH
SET @n_Continue = 3
      SET @c_ErrMsg = ERROR_MESSAGE()
      GOTO EXIT_SP
   END CATCH

EXIT_SP:
   IF (XACT_STATE()) = -1                                     
   BEGIN
      SET @n_Continue = 3
      ROLLBACK TRAN
   END 

   IF @n_Continue=3  -- Error Occured - Process And Return
   BEGIN
      SET @b_Success = 0
      IF @n_StartTCnt = 0 AND @@TRANCOUNT > @n_StartTCnt      
      BEGIN
         ROLLBACK TRAN
      END
      ELSE
      BEGIN
         WHILE @@TRANCOUNT > @n_StartTCnt
         BEGIN
            COMMIT TRAN
         END
      END
      EXECUTE nsp_logerror @n_err, @c_ErrMsg, 'lsp_BookingOutAddShipment_Wrapper'
   END
   ELSE
   BEGIN
      SET @b_Success = 1
      WHILE @@TRANCOUNT > @n_StartTCnt
      BEGIN
         COMMIT TRAN
      END
   END
   
   IF @@TRANCOUNT < @n_StartTCnt
   BEGIN
      BEGIN TRAN 
   END

   IF @b_ExecuteAs = 1
   BEGIN
      REVERT
      EXEC [WM].[lsp_ResetUser]
   END
END
GO
GRANT EXECUTE ON [WM].[lsp_BookingOutAddShipment_Wrapper] TO nSQL 
GO  
