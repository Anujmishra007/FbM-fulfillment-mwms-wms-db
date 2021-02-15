IF EXISTS ( SELECT * FROM dbo.sysobjects WHERE  id = OBJECT_ID(N'[WM].[lsp_DuplicateReceipt]')
AND OBJECTPROPERTY(id ,N'IsProcedure') = 1 )
DROP PROCEDURE [WM].[lsp_DuplicateReceipt]
GO

SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
/************************************************************************/
/* Store procedure: WMS                                                 */
/* Copyright      : LFLogistics                                         */
/*                                                                      */
/* Purpose: Dynamic lottable                                            */
/*                                                                      */
/* Date        Rev  Author      Purposes                                */
/* 7-Feb-2018  1.1  SHONG       Bug Fixing                              */
/* 28-Dec-2020 1.2  SWT01       Adding Begin Try/Catch                  */
/************************************************************************/
CREATE PROCEDURE [WM].[lsp_DuplicateReceipt]
   @c_ReceiptKey  NVARCHAR(10)
  ,@c_IncludeFinalizedItem CHAR(1) = 'N'
   ,@c_NewReceiptKey NVARCHAR(10) ='' OUTPUT
   ,@b_Success INT=1 OUTPUT
   ,@n_Err INT=0 OUTPUT
   ,@c_ErrMsg NVARCHAR(250)='' OUTPUT
   ,@c_UserName NVARCHAR(128)=''
AS
BEGIN
    SET NOCOUNT ON
    SET QUOTED_IDENTIFIER OFF
    SET ANSI_NULLS OFF
    SET CONCAT_NULL_YIELDS_NULL OFF

    SET @b_Success = 1

    --EXECUTE AS LOGIN=@c_UserName
    SET @n_Err = 0
    EXEC [WM].[lsp_SetUser] @c_UserName = @c_UserName OUTPUT, @n_Err = @n_Err OUTPUT, @c_ErrMsg = @c_ErrMsg OUTPUT

    IF @n_Err <> 0
    BEGIN
      GOTO EXIT_SP
    END

    EXECUTE AS LOGIN = @c_UserName
    
    BEGIN TRY -- SWT01 - Begin Outer Begin Try

    IF NOT EXISTS(
      SELECT 1 FROM RECEIPTDETAIL RD WITH (NOLOCK)
      WHERE ReceiptKey = @c_ReceiptKey
      AND   ((RD.QtyExpected - RD.QtyReceived) > 0)
      AND   RD.FinalizeFlag = CASE WHEN @c_IncludeFinalizedItem = 'Y'
                                       THEN RD.FinalizeFlag
                                   ELSE 'N'
                              END)
    BEGIN
       SET @b_Success = 0
       SET @n_Err = 550601
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
           ,@c_ReceiptLineNumber NVARCHAR(5)=''
           --,@c_NewReceiptKey           NVARCHAR(10) = ''

    SET @c_NewReceiptKey = ''
    EXEC nspg_GetKey
      @KeyName = 'RECEIPT',
      @fieldlength = 10,
      @keystring = @c_NewReceiptKey OUTPUT,
      @b_Success = @b_Success OUTPUT,
      @n_err = @n_Err,
      @c_errmsg = @c_ErrMsg,
      @b_resultset = 1,
      @n_batch = 1

    IF @c_NewReceiptKey<>''
    BEGIN
       INSERT INTO RECEIPT
       (
        ReceiptKey,     ExternReceiptKey,    ReceiptGroup,
        StorerKey,        ReceiptDate,        POKey,
        CarrierKey,     CarrierName,        CarrierAddress1,
        CarrierAddress2,  CarrierCity,        CarrierState,
        CarrierZip,     CarrierReference,    WarehouseReference,
        OriginCountry,    DestinationCountry,  VehicleNumber,
        VehicleDate,      PlaceOfLoading,     PlaceOfDischarge,
        PlaceofDelivery,  IncoTerms,           TermsNote,
        ContainerKey,     Signatory,           PlaceofIssue,
        OpenQty,        [Status],          Notes,
        ContainerType,    ContainerQty,       BilledContainerQty,
        RECType,        ASNStatus,           ASNReason,
        Facility,       MBOLKey,           Appointment_No,
        LoadKey,        xDockFlag,           UserDefine01,
        PROCESSTYPE,      UserDefine02,       UserDefine03,
        UserDefine04,     UserDefine05,       UserDefine06,
        UserDefine07,     UserDefine08,       UserDefine09,
        UserDefine10,     DOCTYPE,           RoutingTool,
        CTNTYPE1,       CTNTYPE2,          CTNTYPE3,
        CTNTYPE4,       CTNTYPE5,          CTNTYPE6,
        CTNTYPE7,       CTNTYPE8,          CTNTYPE9,
        CTNTYPE10,        PACKTYPE1,           PACKTYPE2,
        PACKTYPE3,        PACKTYPE4,           PACKTYPE5,
        PACKTYPE6,        PACKTYPE7,           PACKTYPE8,
        PACKTYPE9,        PACKTYPE10,       CTNCNT1,
        CTNCNT2,        CTNCNT3,           CTNCNT4,
        CTNCNT5,        CTNCNT6,           CTNCNT7,
        CTNCNT8,        CTNCNT9,           CTNCNT10,
        CTNQTY1,        CTNQTY2,           CTNQTY3,
        CTNQTY4,        CTNQTY5,           CTNQTY6,
        CTNQTY7,        CTNQTY8,           CTNQTY9,
        CTNQTY10,       NoOfMasterCtn,      NoOfTTLUnit,
        NoOfPallet,     [Weight],          WeightUnit,
        [Cube],          CubeUnit,           GIS_ControlNo,
        Cust_ISA_ControlNo,  Cust_GIS_ControlNo,  GIS_ProcessTime,
        Cust_EDIAckTime,      FinalizeDate,       SellerName,
        SellerCompany,      SellerAddress1,     SellerAddress2,
        SellerAddress3,     SellerAddress4,     SellerCity,
        SellerState,        SellerZip,           SellerCountry,
        SellerContact1,     SellerContact2,     SellerPhone1,
        SellerPhone2,       SellerEmail1,       SellerEmail2,
        SellerFax1,       SellerFax2,          AddWho,
        EditWho      )
       SELECT
        @c_NewReceiptKey,    ExternReceiptKey,    ReceiptGroup,
        StorerKey,           ReceiptDate,         POKey,
        CarrierKey,          CarrierName,         CarrierAddress1,
        CarrierAddress2,     CarrierCity,         CarrierState,
        CarrierZip,          CarrierReference,    WarehouseReference,
        OriginCountry,       DestinationCountry,  VehicleNumber,
        VehicleDate,         PlaceOfLoading,      PlaceOfDischarge,
        PlaceofDelivery,     IncoTerms,           TermsNote,
        ContainerKey,        Signatory,           PlaceofIssue,
        OpenQty=0,           [Status]='0',        Notes,
        ContainerType,       ContainerQty,        BilledContainerQty,
        RECType,             ASNStatus='0',       ASNReason='0',
        Facility,            MBOLKey='',          Appointment_No,
        LoadKey='',          xDockFlag,           UserDefine01,
        PROCESSTYPE,         UserDefine02,        UserDefine03,
        UserDefine04,        UserDefine05,        UserDefine06,
        UserDefine07,        UserDefine08,        UserDefine09,
        UserDefine10,        DOCTYPE,             RoutingTool,
        CTNTYPE1,            CTNTYPE2,            CTNTYPE3,
        CTNTYPE4,            CTNTYPE5,            CTNTYPE6,
        CTNTYPE7,            CTNTYPE8,            CTNTYPE9,
        CTNTYPE10,           PACKTYPE1,           PACKTYPE2,
        PACKTYPE3,           PACKTYPE4,           PACKTYPE5,
        PACKTYPE6,           PACKTYPE7,           PACKTYPE8,
        PACKTYPE9,           PACKTYPE10,          CTNCNT1,
        CTNCNT2=0,           CTNCNT3,             CTNCNT4,
        CTNCNT5=0,           CTNCNT6,             CTNCNT7,
        CTNCNT8=0,           CTNCNT9,             CTNCNT10,
        CTNQTY1=0,           CTNQTY2,             CTNQTY3,
        CTNQTY4=0,           CTNQTY5,             CTNQTY6,
        CTNQTY7=0,           CTNQTY8,             CTNQTY9,
        CTNQTY10=0,          NoOfMasterCtn=0,     NoOfTTLUnit=0,
        NoOfPallet=0,        [Weight]=0,          WeightUnit='',
        [Cube]=0,            CubeUnit='',         GIS_ControlNo,
        Cust_ISA_ControlNo,  Cust_GIS_ControlNo,  GIS_ProcessTime,
        Cust_EDIAckTime,     FinalizeDate,        SellerName,
        SellerCompany,       SellerAddress1,      SellerAddress2,
        SellerAddress3,      SellerAddress4,      SellerCity,
        SellerState,         SellerZip,           SellerCountry,
        SellerContact1,      SellerContact2,      SellerPhone1,
        SellerPhone2,        SellerEmail1,        SellerEmail2,
        SellerFax1,          SellerFax2,          @c_UserName,
        @c_UserName
       FROM RECEIPT AS r WITH(NOLOCK)
       WHERE r.ReceiptKey = @c_ReceiptKey

       IF EXISTS(SELECT 1 FROM RECEIPT AS r WITH(NOLOCK)
                 WHERE r.ReceiptKey = @c_NewReceiptKey)
       BEGIN
         -- Renumber Receipt Line
         SET @c_NextReceiveLineNo = '0'

         DECLARE CUR_RECEIPT_DET CURSOR LOCAL FAST_FORWARD READ_ONLY FOR
         SELECT ReceiptLineNumber
         FROM RECEIPTDETAIL WITH (NOLOCK)
         WHERE ReceiptKey = @c_ReceiptKey
         AND   QtyExpected > QtyReceived
         ORDER BY ReceiptLineNumber

         OPEN CUR_RECEIPT_DET

         FETCH FROM CUR_RECEIPT_DET INTO @c_ReceiptLineNumber

         WHILE @@FETCH_STATUS = 0
         BEGIN
            SET @c_NextReceiveLineNo = RIGHT('0000' +
                                      CONVERT(VARCHAR(5), CAST(@c_NextReceiveLineNo AS INT) + 1),
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
               @c_NewReceiptKey,    @c_NextReceiveLineNo,   ExternReceiptKey,
               ExternLineNo,        StorerKey,              POKey,
               Sku,                 AltSku,                 Id,
               [Status]='0',        DateReceived,           [QtyExpected]=(QtyExpected - QtyReceived),
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
              AND   r.ReceiptLineNumber = @c_ReceiptLineNumber
              AND   r.QtyExpected > r.QtyReceived
              AND   r.FinalizeFlag =
                                 CASE WHEN @c_IncludeFinalizedItem = 'Y'
                                          THEN FinalizeFlag
                                      ELSE 'N'
                                 END


            FETCH FROM CUR_RECEIPT_DET INTO @c_ReceiptLineNumber
         END
         CLOSE CUR_RECEIPT_DET
         DEALLOCATE CUR_RECEIPT_DET
       END  -- IF EXISTS
    END -- @c_NewReceiptKey<>''
    END TRY

   BEGIN CATCH
      GOTO EXIT_SP
   END CATCH -- (SWT01) - End Big Outer Begin try.. end Try Begin Catch.. End Catch

   EXIT_SP:
   REVERT
END

GO
GRANT EXECUTE ON [WM].[lsp_DuplicateReceipt] TO nSQL
GO
