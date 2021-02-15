IF EXISTS ( SELECT * FROM dbo.sysobjects WHERE  id = OBJECT_ID(N'[WM].[lsp_DuplicateReceiptLine]') 
AND OBJECTPROPERTY(id ,N'IsProcedure') = 1 ) 
DROP PROCEDURE [WM].[lsp_DuplicateReceiptLine]
GO

SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
/************************************************************************/
/* Store procedure: WMS                                                 */
/* Copyright      : LFLogistics                                         */
/* Copyright: LFL                                                       */                                                                                  
/* Written by: Wan                                                      */                                                                                  
/*                                                                      */                                                                                  
/* Purpose: Duplicate Receipt Line Number                               */
/*                                                                      */                                                                                  
/* Called By: SCE                                                       */                                                                                  
/*          :                                                           */                                                                                  
/* PVCS Version: 1.1                                                    */                                                                                  
/*                                                                      */                                                                                  
/* Version: 8.0                                                         */                                                                                  
/*                                                                      */                                                                           
/* Updates:                                                             */  
/* Purpose: Duplicate Receipt Line Number                               */
/*                                                                      */
/* Date        Author   Rev   Purposes                                  */
/* 28-Dec-2020 SWT01    1.0   Adding Begin Try/Catch                    */
/* 15-Jan-2021 Wan01    1.1   Execute Login if @c_UserName<>SUSER_SNAME()*/
/************************************************************************/
CREATE PROCEDURE [WM].[lsp_DuplicateReceiptLine]
    @c_ReceiptKey             NVARCHAR(10)
   ,@c_OriginalLineNumber     NVARCHAR(5) 
   ,@c_NewLineNumber          NVARCHAR(5) OUTPUT 
   ,@c_IncludeFinalizedItem   CHAR(1) = 'N'
   ,@b_Success                INT=1 OUTPUT 
   ,@n_Err                    INT=0 OUTPUT
   ,@c_ErrMsg                 NVARCHAR(250)='' OUTPUT
   ,@c_UserName               NVARCHAR(128)=''
AS
BEGIN
   SET NOCOUNT ON
   SET QUOTED_IDENTIFIER OFF
   SET ANSI_NULLS OFF
   SET CONCAT_NULL_YIELDS_NULL OFF
    
   SET @b_Success = 1
   SET @c_ErrMsg = ''

   SET @n_Err = 0 
    
   IF SUSER_SNAME() <> @c_UserName       --(Wan01) - START
   BEGIN
      EXEC [WM].[lsp_SetUser] @c_UserName = @c_UserName OUTPUT, @n_Err = @n_Err OUTPUT, @c_ErrMsg = @c_ErrMsg OUTPUT        

      IF @n_Err <> 0 
      BEGIN
      GOTO EXIT_SP
      END
       
      EXECUTE AS LOGIN = @c_UserName
   END                                   --(Wan01) - END
    
   BEGIN TRY -- SWT01 - Begin Outer Begin Try
    
      IF NOT EXISTS(
      SELECT 1 FROM RECEIPTDETAIL RD WITH (NOLOCK)
      WHERE ReceiptKey = @c_ReceiptKey 
      AND   RD.ReceiptLineNumber = @c_OriginalLineNumber
      AND   RD.FinalizeFlag = CASE WHEN @c_IncludeFinalizedItem = 'Y' 
                                       THEN RD.FinalizeFlag 
                                    ELSE 'N' 
                              END    
      AND   RD.QtyExpected > RD.BeforeReceivedQty )   
      BEGIN
         SET @b_Success = 0
         SET @n_Err = 550701
         SET @c_ErrMsg = 'Cannot duplicate from Receipt# ' + @c_ReceiptKey + 
               ': No receipt line items with more Quantity Expected than Quantity Received.'
         GOTO EXIT_SP
      END                               
    
       DECLARE @c_StorerKey             NVARCHAR(15) = ''
              ,@c_Sku                   NVARCHAR(20) = ''
              ,@c_UOM                   NVARCHAR(10) = ''
              ,@c_PackKey               NVARCHAR(10) = ''
              ,@n_BeforeReceivedQty     INT          = 0
              ,@n_QtyExpected           INT          = 0
              ,@c_Facility              NVARCHAR(15) = ''
              ,@c_CustomisedSplitLine   NVARCHAR(30) = ''
              ,@n_PalletCnt             INT = 0 
              ,@b_ZeroExpected          BIT = 0 
              ,@b_ByExpected            BIT = 0 
              ,@n_QtyToBeSplitted       INT = 0 
              ,@n_RemainQty             INT = 0
              ,@c_LastReceiveLineNo     NVARCHAR(5) = ''
              ,@c_NextReceiveLineNo     NVARCHAR(5) = ''
              ,@n_RemainingQtyExpected  INT = 0 
              ,@n_RemainQtyReceived     INT = 0 
              ,@n_InsertBeforeReceivedQty INT = 0 
              ,@n_InsertQtyExpected       INT = 0
              ,@c_ReceiptLineNumber       NVARCHAR(5)=''   
           --,@c_NewReceiptKey           NVARCHAR(10) = ''
    
      
      SET @c_LastReceiveLineNo = ''
      SELECT @c_LastReceiveLineNo = MAX(RD.ReceiptLineNumber) 
      FROM RECEIPTDETAIL AS RD WITH(NOLOCK) 
      WHERE RD.ReceiptKey = @c_ReceiptKey
      
      IF @c_LastReceiveLineNo <> '' 
      BEGIN
         SET @c_NewLineNumber = RIGHT('0000' + 
                                            CONVERT(VARCHAR(5), CAST(@c_LastReceiveLineNo AS INT) + 1), 
                                            5)


           INSERT INTO RECEIPTDETAIL
           (
            ReceiptKey,          ReceiptLineNumber,      ExternReceiptKey,
            ExternLineNo,        StorerKey,              POKey,
            Sku,                 AltSku,                 Id,
            [Status],            DateReceived,           QtyExpected,
            QtyAdjusted,         QtyReceived,            UOM,
            PackKey,             VesselKey,              VoyageKey,
            XdockKey,            ContainerKey,           ToLoc,
            ToLot,               ToId,                   ConditionCode,
            Lottable01,          Lottable02,             Lottable03,
            Lottable04,          Lottable05,             CaseCnt,
            InnerPack,           Pallet,                 [Cube],
            GrossWgt,            NetWgt,                 OtherUnit1,
            OtherUnit2,          UnitPrice,              ExtendedPrice,
            TariffKey,           FreeGoodQtyExpected,    FreeGoodQtyReceived,
            SubReasonCode,       FinalizeFlag,           DuplicateFrom,
            BeforeReceivedQty,   PutawayLoc,             ExportStatus,
            SplitPalletFlag,     POLineNumber,           LoadKey,
            ExternPoKey,         UserDefine01,           UserDefine02,
            UserDefine03,        UserDefine04,           UserDefine05,
            UserDefine06,        UserDefine07,           UserDefine08,
            UserDefine09,        UserDefine10,           Lottable06,
            Lottable07,          Lottable08,             Lottable09,
            Lottable10,          Lottable11,             Lottable12,
            Lottable13,          Lottable14,             Lottable15, 
            AddWho,              EditWho
           )
           SELECT 
            @c_ReceiptKey,       @c_NewLineNumber,      ExternReceiptKey,
            ExternLineNo,        StorerKey,              POKey,
            Sku,                 AltSku,                 Id,
            [Status]='0',        DateReceived,           [QtyExpected]=(QtyExpected - BeforeReceivedQty),
            QtyAdjusted=0,       QtyReceived=0,          UOM,
            PackKey,             VesselKey,              VoyageKey,
            XdockKey,            ContainerKey,           ToLoc,
            ToLot='',            ToId='',                ConditionCode='OK',
            Lottable01,          Lottable02,             Lottable03,
            Lottable04,          Lottable05,             CaseCnt,
            InnerPack,           Pallet,                 [Cube],
            GrossWgt,            NetWgt,                 OtherUnit1,
            OtherUnit2,          UnitPrice,              ExtendedPrice,
            TariffKey,           FreeGoodQtyExpected,    FreeGoodQtyReceived,
            SubReasonCode='',    FinalizeFlag='N',       DuplicateFrom='',
            BeforeReceivedQty=0, PutawayLoc='',          ExportStatus,
            SplitPalletFlag,     POLineNumber,           LoadKey='',
            ExternPoKey,         UserDefine01,           UserDefine02,
            UserDefine03,        UserDefine04,           UserDefine05,
            UserDefine06,        UserDefine07,           UserDefine08,
            UserDefine09,        UserDefine10,           Lottable06,
            Lottable07,          Lottable08,             Lottable09,
            Lottable10,          Lottable11,             Lottable12,
            Lottable13,          Lottable14,             Lottable15, 
            @c_UserName,         @c_UserName
           FROM RECEIPTDETAIL AS r WITH(NOLOCK) 
           WHERE r.ReceiptKey = @c_ReceiptKey 
           AND   r.ReceiptLineNumber = @c_OriginalLineNumber
           AND  r.QtyExpected > r.QtyReceived            
           AND  r.FinalizeFlag = 
                              CASE WHEN @c_IncludeFinalizedItem = 'Y' 
                                       THEN FinalizeFlag 
                                   ELSE 'N' 
                              END
                  
      END -- IF @c_LastReceiveLineNo <> ''                

      IF @@ROWCOUNT > 0
      BEGIN
         SET @b_Success = 1
         SET @c_ErrMsg = 'New Duplicated ReceiptLine added'
      END
      ELSE
      BEGIN

         SET @b_Success = 0
         SET @c_ErrMsg = 'Failed to Duplicates the ReceiptLine: ' + @c_OriginalLineNumber
      END
   END TRY  
  
   BEGIN CATCH
      SET @b_Success = 0                  --(Wan01)
      SET @c_ErrMsg = ERROR_MESSAGE()     --(Wan01)
      GOTO EXIT_SP  
   END CATCH -- (SWT01) - End Big Outer Begin try.. end Try Begin Catch.. End Catch  

   EXIT_SP: 
   REVERT
END
GO
GRANT EXECUTE ON [WM].[lsp_DuplicateReceiptLine] TO nSQL 
GO
