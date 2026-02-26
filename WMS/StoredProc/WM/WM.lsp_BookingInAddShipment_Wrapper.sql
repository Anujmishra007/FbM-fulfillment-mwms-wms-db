SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO   
/************************************************************************/                                                                                  
/* Store Procedure: WM.lsp_BookingInAddShipment_Wrapper                 */                                                                                  
/* Creation Date: 2023-12-19                                            */                                                                                  
/* Copyright: Maersk                                                    */                                                                                  
/* Written by: Wan                                                      */                                                                                  
/*                                                                      */                                                                                  
/* Purpose: 3899 - SCE RG  Inbound Door booking v1.4                    */
/*                                                                      */                                                                                  
/* Called By: SCE                                                       */                                                                                  
/*          :                                                           */                                                                                  
/* PVCS Version: 1.1                                                    */
/*                                                                      */                                                                                  
/* Version: 8.0                                                         */                                                                                  
/*                                                                      */                                                                                  
/* Data Modifications:                                                  */
/*                                                                      */                                                                                  
/* Updates:                                                             */                                                                                  
/* Date        Author   Ver.  Purposes                                  */ 
/* 2023-12-19  Wan01-v0 1.0   Created.                                  */
/* 2023-12-19  Wan01-v0 1.0   DevOps Combine Script.                    */
/* 2024-07-02  Inv Team 1.1   UWP-17135 - Migrate Inbound Door booking  */
/* 2025-05-21  SSA01    1.2   FCR-3921 - Upadated ASN Custom Fields     */
/* 2025-05-26  SSA02    1.3   FCR-3921 -Added extrenReceiptkey condition*/
/* 2025-05-26  SWT01    1.4   Setting Session Context for user name     */
/* 2025-02-26  YGO050   1.3   fCR-10661                               */
/************************************************************************/                                                                                  
CREATE OR ALTER PROC [WM].[lsp_BookingInAddShipment_Wrapper]                                                                                                                     
      @n_BookingNo            INT                           --Booking In's Booking No
   ,  @c_ShipmentGIDs         NVARCHAR(MAX)                -- Multiple ShipmentGID Seperated by '|' 
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

   DECLARE  @n_StartTCnt                  INT = @@TRANCOUNT  
         ,  @n_Continue                   INT = 1
         
         ,  @dt_ShipmentPlannedStartDate  DATETIME = NULL    
         ,  @dt_ShipmentPlannedEndDate    DATETIME = NULL    
         
   DECLARE @t_Shipment     TABLE 
         (  RowRef         INT         PRIMARY KEY
         ,  ShipmentGID    NVARCHAR(50)   NOT NULL DEFAULT('')
         ,  BookingNo      INT            NOT NULL  --YGO050
         )

   SET @b_Success = 1
   SET @n_Err     = 0
   
   SET @n_Err = 0 
 
   -- (SWT01) - START
   DECLARE @b_ExecuteAs BIT = 0
   IF SUSER_SNAME() <> @c_UserName
   BEGIN 

      EXEC [WM].[lsp_SetUser] 
            @c_UserName = @c_UserName  OUTPUT
         ,  @n_Err      = @n_Err       OUTPUT
         ,  @c_ErrMsg   = @c_ErrMsg    OUTPUT
         ,  @b_ExecuteAs = @b_ExecuteAs OUTPUT
         
      IF @n_Err <> 0 
      BEGIN
         GOTO EXIT_SP
      END

      IF @b_ExecuteAs = 1                    
         EXECUTE AS LOGIN = @c_UserName
   END
   -- (SWT01) - END

    BEGIN TRAN
    BEGIN TRY
        INSERT INTO @t_Shipment (RowRef, ShipmentGID, BookingNo)   --YGO050
        SELECT ts.Rowref, ts.ShipmentGID, @n_BookingNo             --YGO050
        FROM STRING_SPLIT(@c_ShipmentGIDs,'|') AS ss
        JOIN dbo.TMS_Shipment AS ts WITH (NOLOCK) ON ts.ShipmentGID = ss.[value]
        WHERE ts.BookingNo IN (0, NULL)

      SELECT @dt_ShipmentPlannedStartDate = bi.BookingDate
            ,@dt_ShipmentPlannedEndDate   = bi.EndTime
      FROM dbo.Booking_In AS bi (NOLOCK) 
      WHERE bi.BookingNo = @n_BookingNo
   
      UPDATE ts WITH (ROWLOCK)
      SET ts.BookingNo = @n_BookingNo
         ,ts.ShipmentPlannedStartDate = @dt_ShipmentPlannedStartDate
         ,ts.ShipmentPlannedEndDate   = @dt_ShipmentPlannedEndDate  
      FROM @t_Shipment AS ts2 
      JOIN dbo.TMS_Shipment AS ts ON ts.RowRef = ts2.RowRef
          
      IF @@ERROR <> 0 
      BEGIN
         SET @n_Continue = 3
         SET @n_Err = 562001
         SET @c_ErrMsg = 'MSQL' + CONVERT(CHAR(6),@n_Err) + ': Update TMS_Shipment fail. (lsp_BookingInAddShipment_Wrapper)'
         GOTO EXIT_SP
      END

      -- (SSA01) start --
      DECLARE @c_ASNCustomFieldsSP NVARCHAR(30)
           , @c_SQL NVARCHAR( MAX)
           , @c_SQLParam NVARCHAR( MAX)
           , @c_StorerKey NVARCHAR(30)
           , @c_Facility NVARCHAR(15)
           , @c_ShipmentGID NVARCHAR(50) --(SSA02)

           SET @c_ASNCustomFieldsSP = ''
           SET @c_StorerKey = ''
           SET @c_Facility  = ''
           SET @c_ShipmentGID = ''  --(SSA02)
      --(SSA02)
      SELECT TOP 1 @c_ShipmentGID = ShipmentGID
      FROM TMS_Shipment WITH(NOLOCK)
      WHERE BookingNo = @n_BookingNo

      SELECT TOP 1 @c_StorerKey = R.Storerkey, @c_Facility = R.Facility
      FROM RECEIPT R WITH (NOLOCK)
      WHERE (ReceiptKey = @c_ShipmentGID  --(SSA02)
      OR ExternReceiptKey = @c_ShipmentGID) --(SSA02)
      AND ISNULL(@c_ShipmentGID, '') <> ''

	   EXECUTE nspGetRight
         @c_Facility,
         @c_StorerKey,
         '',  --Sku
         'ASNCustomFieldsSP', -- Configkey
         @b_success    OUTPUT,
         @c_ASNCustomFieldsSP     OUTPUT,
         @n_err        OUTPUT,
         @c_errmsg     OUTPUT

      IF @b_success <> 1
      BEGIN
          SET @n_continue = 3
          SET @n_Err = 562002
          SET @c_ErrMsg = RTRIM(ISNULL(@c_Errmsg,'')) + ' (lsp_BookingInAddShipment_Wrapper)'
          GOTO EXIT_SP
      END

      IF ISNULL(RTRIM(@c_ASNCustomFieldsSP),'') IN ('','0','1')
      BEGIN
          SET @c_ASNCustomFieldsSP = ''
      END

      IF @c_ASNCustomFieldsSP <> ''
      BEGIN
         IF EXISTS( SELECT 1 FROM sys.objects WHERE name = @c_ASNCustomFieldsSP AND type = 'P')
            BEGIN

               SET @c_SQL = N'EXEC dbo.' + RTRIM( @c_ASNCustomFieldsSP) +
               ' @n_BookingNo = @n_BookingNo'

               SET @c_SQLParam = N'@n_BookingNo INT'

               EXEC sp_ExecuteSQL @c_SQL, @c_SQLParam, @n_BookingNo

               IF @@ERROR <> 0
               GOTO EXIT_SP
            END
      END
     -- (SSA01) End --
--YGO050 - START
      -- Update RECEIPT.Appointment_No for inbound booking using cursor over @t_Shipment
      DECLARE @cur_ShipmentGID NVARCHAR(50), @cur_BookingNo INT
      DECLARE curShipIn CURSOR LOCAL FAST_FORWARD FOR
SELECT ShipmentGID, BookingNo FROM @t_Shipment

    OPEN curShipIn
      FETCH NEXT FROM curShipIn INTO @cur_ShipmentGID, @cur_BookingNo
    WHILE @@FETCH_STATUS = 0
BEGIN
UPDATE dbo.RECEIPT WITH (ROWLOCK)
SET Appointment_No = @cur_BookingNo
WHERE ExternReceiptKey = @cur_ShipmentGID

    IF @@ERROR <> 0
BEGIN
            SET @n_Continue = 3
            SET @n_Err = 562003
            SET @c_ErrMsg = 'MSQL' + CONVERT(CHAR(6),@n_Err) + ': Update RECEIPT fail. (lsp_BookingInAddShipment_Wrapper)'
            CLOSE curShipIn
            DEALLOCATE curShipIn
            GOTO EXIT_SP
END

FETCH NEXT FROM curShipIn INTO @cur_ShipmentGID, @cur_BookingNo
END
CLOSE curShipIn
    DEALLOCATE curShipIn
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
      EXECUTE nsp_logerror @n_err, @c_ErrMsg, 'lsp_BookingInAddShipment_Wrapper'
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
         
   IF @b_ExecuteAs = 1              -- (SWT01)
      REVERT                        

   EXEC [WM].[lsp_ResetUser] -- (SWT01)
END
GO
GRANT EXECUTE ON [WM].[lsp_BookingInAddShipment_Wrapper] TO nSQL 
GO  
