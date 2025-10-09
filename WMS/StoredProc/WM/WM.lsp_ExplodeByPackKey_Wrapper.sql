SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
/************************************************************************/  
/* Stored Procedure: lsp_ExplodeByPackKey_Wrapper                       */  
/* Creation Date: 11-Apr-2018                                           */  
/* Copyright: LFLogistics                                               */  
/* Written by:                                                          */  
/*                                                                      */  
/* Purpose: ASN item explode by packkey                                 */  
/*                                                                      */  
/* Called By: ASN/Receipt                                               */  
/*                                                                      */  
/* PVCS Version: 1.2                                                    */  
/*                                                                      */  
/* Version: 8.0                                                         */  
/*                                                                      */  
/* Data Modifications:                                                  */  
/*                                                                      */  
/* Updates:                                                             */  
/* Date        Author   Ver   Purposes                                  */  
/* 28-Dec-2020 SWT01    1.0   Adding Begin Try/Catch                    */
/* 15-Jan-2021 Wan01    1.1   Execute Login if @c_UserName<>SUSER_SNAME()*/
/* 09-Feb-2021 Wan02    1.2   LFWM-2467 - UAT - TW  Duplicated Moveable */
/*                            Unit populated when Explode by Packkey in */
/*                            ASNReceipt Module                         */
/* 19-Mar-2024 Wan03    1.3   LFWM-4787SCE| PROD| SG| ASN Explode By    */
/*                            Packkey -The Loose Pallet ReceptDetail    */
/*                            Line Should be Assigned the smallest      */
/*                            Movable Unit                              */
/* 21-May-2025 AYD01    1.4   UWP-30411: add new storerconfig           */
/*                            ASNExplodeByPackkeySP and using Svalue    */
/*                            to call sub-script and get a customized ID*/
/* 05-Jun-2025 AYD02    1.5   Fix: Increase length of @c_ToID to 25     */
/* 2025-05-26  SWT01    1.6   Setting Session Context for user name     */
/************************************************************************/
CREATE OR ALTER PROCEDURE [WM].[lsp_ExplodeByPackKey_Wrapper]
    @c_ReceiptKey NVARCHAR(10) 
   ,@c_ReceiptLineNumber NVARCHAR(5)=''  
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
    
   BEGIN TRY -- SWT01 - Begin Outer Begin Try
      DECLARE @c_StorerKey                  NVARCHAR(15) = ''
               ,@c_Sku                        NVARCHAR(20) = ''
               ,@c_UOM                        NVARCHAR(10) = ''
               ,@c_PackKey                    NVARCHAR(10) = ''
               ,@n_BeforeReceivedQty          INT          = 0
               ,@n_QtyExpected                INT          = 0
               ,@c_Facility                   NVARCHAR(15) = ''
               ,@c_CustomisedSplitLine        NVARCHAR(30) = ''
               ,@n_PalletCnt                  INT = 0 
               --,@b_ZeroExpected               BIT = 0 
               --,@b_ByExpected                 BIT = 0 
               --,@n_QtyToBeSplitted            INT = 0 
               ,@n_RemainQty                  INT = 0
               ,@c_LastReceiveLineNo          NVARCHAR(5) = ''
               ,@c_NextReceiveLineNo          NVARCHAR(5) = ''
               ,@n_RemainingQtyExpected       INT = 0 
               ,@n_RemainQtyReceived          INT = 0 
               ,@n_InsertBeforeReceivedQty    INT = 0 
               ,@n_InsertQtyExpected          INT = 0 
               ,@c_GenID                      NVARCHAR(10) =''
               ,@C_GEN_ID_DURING_EXPLODE_PACK NVARCHAR(10) = ''
               ,@c_ToID                       NVARCHAR(25) = ''   --AYD02
               ,@cSQL                         NVARCHAR(MAX)       --AYD01
               ,@cSQLParam                    NVARCHAR(MAX)       --AYD01
               ,@c_GenIdSP                    NVARCHAR(30) = ''   --AYD01
    
      SET @b_Success = 1
      SET @c_ErrMsg =''
    
      SELECT @c_Storerkey = Storerkey,
            @c_Facility = Facility
      FROM RECEIPT(NOLOCK)
      WHERE Receiptkey = @c_Receiptkey
    
      IF @c_ReceiptLineNumber<>''
      BEGIN
         DECLARE CUR_RECEIPT_LINES CURSOR LOCAL FAST_FORWARD READ_ONLY 
         FOR
            SELECT RD.ReceiptKey
                  ,RD.ReceiptLineNumber
                  ,RD.StorerKey
                  ,RD.Sku
                  ,RD.UOM
                  ,RD.PackKey
                  ,RD.BeforeReceivedQty
                  ,RD.QtyExpected
                  ,RH.Facility 
            FROM   RECEIPTDETAIL RD WITH (NOLOCK) 
            JOIN   RECEIPT AS RH WITH(NOLOCK) ON RH.ReceiptKey = RD.ReceiptKey 
            WHERE  RD.ReceiptKey = @c_ReceiptKey
                     AND RD.ReceiptLineNumber = @c_ReceiptLineNumber
                     AND RD.FinalizeFlag <> 'Y'
      END
      ELSE
      BEGIN
         DECLARE CUR_RECEIPT_LINES CURSOR LOCAL FAST_FORWARD READ_ONLY 
         FOR
            SELECT RD.ReceiptKey
                  ,RD.ReceiptLineNumber
                  ,RD.StorerKey
                  ,RD.Sku
                  ,RD.UOM
                  ,RD.PackKey
                  ,RD.BeforeReceivedQty
                  ,RD.QtyExpected
                  ,RH.Facility 
            FROM   RECEIPTDETAIL RD WITH (NOLOCK) 
            JOIN   RECEIPT AS RH WITH(NOLOCK) ON RH.ReceiptKey = RD.ReceiptKey 
            WHERE  RD.ReceiptKey = @c_ReceiptKey
                     AND RD.FinalizeFlag <> 'Y'
      END
    
      OPEN CUR_RECEIPT_LINES
    
      FETCH FROM CUR_RECEIPT_LINES INTO @c_ReceiptKey, @c_ReceiptLineNumber, @c_StorerKey,
                                       @c_Sku, @c_UOM, @c_PackKey, @n_BeforeReceivedQty, @n_QtyExpected, @c_Facility
    
      WHILE @@FETCH_STATUS = 0
      BEGIN
         SET @c_CustomisedSplitLine = '0'
         --SET @b_ZeroExpected = 0 
         --SET @n_QtyToBeSplitted = 0 
         --SET @b_ByExpected = 0 
             
         --SELECT @c_CustomisedSplitLine =  ISNULL(sValue, '0')
         --FROM   STORERCONFIG (NOLOCK)
         --WHERE  StorerKey = @c_StorerKey
         --AND    ConfigKey = 'CustomisedSplitLine'       
       
         SELECT @c_CustomisedSplitLine = dbo.fnc_GetRight(@c_Facility, @c_Storerkey, '', 'CustomisedSplitLine')
       
         IF @c_CustomisedSplitLine = '1'
         BEGIN
            SELECT @n_PalletCnt = 
                  CASE SC.SValue 
                     WHEN Pack.PackUOM5 
                           THEN Pack.Cube
                        WHEN Pack.PackUOM6 
                           THEN Pack.GrossWgt
                        WHEN Pack.PackUOM7
                           THEN Pack.NetWgt
                        WHEN Pack.PackUOM8
                           THEN Pack.OtherUnit1
                        WHEN Pack.PackUOM9
                           THEN Pack.OtherUnit2
                        ELSE PACK.Pallet 
                  END            
            FROM PACK (NOLOCK) 
            LEFT JOIN StorerConfig SC (NOLOCK) ON (SC.StorerKey = @c_StorerKey
                        AND SC.Facility  = @c_Facility
                              AND SC.ConfigKey = 'DefaultPalletUOM') 
            WHERE PACK.PackKey = @c_PackKey          
         END 
         ELSE 
         BEGIN
            SELECT @n_PalletCnt = PACK.Pallet  
            FROM PACK (NOLOCK) 
            WHERE PACK.PackKey = @c_PackKey                         
         END
       
         IF @n_PalletCnt = 0 
            GOTO FETCH_NEXT
          
         SET @n_RemainingQtyExpected = @n_QtyExpected   
         SET @n_RemainQtyReceived = @n_BeforeReceivedQty
       
         IF @n_RemainQtyReceived = 0
            SET @n_RemainQty = @n_RemainingQtyExpected 
         ELSE IF @n_RemainQtyReceived > @n_RemainingQtyExpected
            SET @n_RemainQty = @n_RemainQtyReceived
         ELSE 
            SET @n_RemainQty = @n_RemainingQtyExpected 
          
         IF @n_RemainQty <= @n_PalletCnt
            GOTO FETCH_NEXT

         --remove qty of first pallet at original line
         SET @n_RemainQty = @n_RemainQty - @n_PalletCnt  
         SET @n_RemainingQtyExpected = @n_RemainingQtyExpected - @n_PalletCnt  
         SET @n_RemainQtyReceived = @n_RemainQtyReceived - @n_PalletCnt                               
       
         IF @n_RemainingQtyExpected < 0
            SET @n_RemainingQtyExpected = 0          

         IF @n_RemainQtyReceived < 0
            SET @n_RemainQtyReceived = 0          
          
         WHILE @n_RemainQty > 0 
         BEGIN 
            SET @c_LastReceiveLineNo = ''
              
            SELECT TOP 1 @c_LastReceiveLineNo = r.ReceiptLineNumber  
            FROM RECEIPTDETAIL AS r WITH(NOLOCK) 
            WHERE r.ReceiptKey = @c_ReceiptKey 
            ORDER BY r.ReceiptLineNumber DESC
              
            IF @c_LastReceiveLineNo = ''
               SET @c_NextReceiveLineNo = '00001'
            ELSE 
            BEGIN
            IF ISNUMERIC(@c_LastReceiveLineNo) = 1             
               SET @c_NextReceiveLineNo = RIGHT( '0000' + CONVERT(varchar(5), CAST(@c_LastReceiveLineNo AS INT) + 1) , 5)
            ELSE 
               GOTO FETCH_NEXT 
            END                              
              
            If @n_RemainQty - @n_PalletCnt > 0           
            BEGIN
               SET @n_RemainQty = @n_RemainQty - @n_PalletCnt               
               
               IF @n_RemainingQtyExpected >= @n_PalletCnt
                  SET @n_InsertQtyExpected = @n_PalletCnt
               ELSE    
                  SET @n_InsertQtyExpected = @n_RemainingQtyExpected

               IF @n_RemainQtyReceived >= @n_PalletCnt
                  SET @n_InsertBeforeReceivedQty = @n_PalletCnt
               ELSE    
                  SET @n_InsertBeforeReceivedQty = @n_RemainQtyReceived                 
            END
            ELSE
            BEGIN
               SET @n_RemainQty = 0 
               --(Wan03) - START  -- Update original line with remainingqty
               IF @n_RemainingQtyExpected > 0                                       
                  SET @n_InsertQtyExpected = @n_PalletCnt
               ELSE
                  SET @n_InsertQtyExpected = @n_RemainingQtyExpected

               IF @n_RemainQtyReceived > 0
                  SET @n_InsertBeforeReceivedQty = @n_PalletCnt
               ELSE                                                                  
                  SET @n_InsertBeforeReceivedQty = @n_RemainQtyReceived 
               --(Wan03) - END   
            END
            SET @n_RemainingQtyExpected = @n_RemainingQtyExpected - @n_InsertQtyExpected  
            SET @n_RemainQtyReceived = @n_RemainQtyReceived - @n_InsertBeforeReceivedQty  
            
            INSERT INTO RECEIPTDETAIL
            (
            ReceiptKey,          ReceiptLineNumber,           ExternReceiptKey,
            ExternLineNo,        StorerKey,                   POKey,
            Sku,                 AltSku,                      Id,
            [Status],            DateReceived,                QtyExpected,
            QtyAdjusted,         QtyReceived,                 UOM,
            PackKey,             VesselKey,                   VoyageKey,
            XdockKey,            ContainerKey,                ToLoc,
            ToLot,               ToId,                        ConditionCode,
            Lottable01,          Lottable02,                  Lottable03,
            Lottable04,          Lottable05,                  CaseCnt,
            InnerPack,           Pallet,                      [Cube],
            GrossWgt,            NetWgt,                      OtherUnit1,
            OtherUnit2,          UnitPrice,                   ExtendedPrice,
            EffectiveDate,       TariffKey,                   FreeGoodQtyExpected,
            FreeGoodQtyReceived, SubReasonCode,               FinalizeFlag,
            DuplicateFrom,       BeforeReceivedQty,           PutawayLoc,
            ExportStatus,        SplitPalletFlag,             POLineNumber,
            LoadKey,             ExternPoKey,                 UserDefine01,
            UserDefine02,        UserDefine03,                UserDefine04,
            UserDefine05,        UserDefine06,                UserDefine07,
            UserDefine08,        UserDefine09,                UserDefine10,
            Lottable06,          Lottable07,                  Lottable08,
            Lottable09,          Lottable10,                  Lottable11,
            Lottable12,          Lottable13,                  Lottable14,
            Lottable15         )
            SELECT 
            ReceiptKey,          @c_NextReceiveLineNo,        ExternReceiptKey,
            ExternLineNo,        StorerKey,                   POKey,
            Sku,                 AltSku,                      Id,
            [Status],            DateReceived,                @n_InsertQtyExpected, 
            0,                   QtyReceived,                 UOM,
            PackKey,             VesselKey,                   VoyageKey,
            XdockKey,            ContainerKey,                ToLoc,
            ToLot,               '',                          ConditionCode,       -- (Wan02) Do Not duplicate Pallet ID
            Lottable01,          Lottable02,                  Lottable03,
            Lottable04,          Lottable05,                  CaseCnt,
            InnerPack,           Pallet,                      [Cube],
            GrossWgt,            NetWgt,                      OtherUnit1,
            OtherUnit2,          UnitPrice,                   ExtendedPrice,
            EffectiveDate,       TariffKey,                   FreeGoodQtyExpected,
            FreeGoodQtyReceived, SubReasonCode,               FinalizeFlag,
            DuplicateFrom,       @n_InsertBeforeReceivedQty,  PutawayLoc,
            ExportStatus,        SplitPalletFlag,             POLineNumber,
            LoadKey,             ExternPoKey,                 UserDefine01,
            UserDefine02,        UserDefine03,                UserDefine04,
            UserDefine05,        UserDefine06,                UserDefine07,
            UserDefine08,        UserDefine09,                UserDefine10,
            Lottable06,          Lottable07,                  Lottable08,
            Lottable09,          Lottable10,                  Lottable11,
            Lottable12,          Lottable13,                  Lottable14,
            Lottable15            
            FROM RECEIPTDETAIL AS r WITH(NOLOCK)
            WHERE r.ReceiptKey = @c_ReceiptKey 
            AND   r.ReceiptLineNumber = @c_ReceiptLineNumber 

       -- Update Original Line
            UPDATE RECEIPTDETAIL 
            SET QtyExpected = QtyExpected - @n_InsertQtyExpected, 
                  BeforeReceivedQty = BeforeReceivedQty - @n_InsertBeforeReceivedQty, 
                  EditDate = GETDATE(), 
                  EditWho = @c_UserName 
            WHERE ReceiptKey = @c_ReceiptKey
            AND   ReceiptLineNumber = @c_ReceiptLineNumber        
         END 
           
          /*
          IF @n_QtyExpected = 0 
          BEGIN
             SET @n_RemainingQtyExpected = @n_BeforeReceivedQty 
             SET @b_ZeroExpected = 1 
          END
       
            IF @n_BeforeReceivedQty > 0 
            BEGIN
               SET @b_ZeroExpected = 0
               SET @b_ByExpected   = 0 
               SET @n_QtyToBeSplitted = @n_QtyExpected - @n_BeforeReceivedQty
               SET @n_RemainingQtyExpected = @n_QtyExpected - @n_BeforeReceivedQty
            END                  
            ELSE
            BEGIN
                SET @b_ByExpected = 1
                SET @n_QtyToBeSplitted = @n_QtyExpected - @n_PalletCnt
            END
       
            SET @n_RemainQty = @n_QtyToBeSplitted      
            SET @n_RemainQtyReceived = @n_RemainQty

          IF @n_RemainQty < @n_PalletCnt
          BEGIN
                --SET @b_Success = 0
                --SET @n_Err = 550801
                --SET @c_ErrMsg = 'RemainQty Less Than or Equal to Pallet Count. not allowed for Explode By Packkey'
                GOTO FETCH_NEXT
          END
     
            WHILE @n_RemainQty > 0 -->= @n_PalletCnt
            BEGIN 
                SET @c_LastReceiveLineNo = ''
             
                SELECT TOP 1 
                     @c_LastReceiveLineNo = r.ReceiptLineNumber  
                FROM RECEIPTDETAIL AS r WITH(NOLOCK) 
                WHERE r.ReceiptKey = @c_ReceiptKey 
                ORDER BY r.ReceiptLineNumber DESC
             
                IF @c_LastReceiveLineNo = ''
                  SET @c_NextReceiveLineNo = '00001'
                ELSE 
                BEGIN
                   IF ISNUMERIC(@c_LastReceiveLineNo) = 1             
                     SET @c_NextReceiveLineNo = RIGHT( '0000' + CONVERT(varchar(5), CAST(@c_LastReceiveLineNo AS INT) + 1) , 5)
                   ELSE 
                     GOTO FETCH_NEXT 
                END
       
                IF @b_ByExpected = 0 
                BEGIN
                   SET @n_InsertBeforeReceivedQty = @n_PalletCnt 
                   SET @n_RemainQtyReceived = @n_RemainQtyReceived - @n_PalletCnt
                END 
                      
                IF @b_ZeroExpected = 0 
                BEGIN
                   IF @n_RemainingQtyExpected >= @n_PalletCnt 
                   BEGIN
                      SET @n_InsertQtyExpected = @n_PalletCnt
                      SET @n_RemainingQtyExpected = @n_RemainingQtyExpected - @n_PalletCnt
                   END              
                   ELSE IF @n_RemainingQtyExpected <= 0 
                     SET @n_InsertQtyExpected = 0 
                   ELSE 
                   BEGIN
                      SET @n_InsertQtyExpected = @n_RemainingQtyExpected
                      SET @n_RemainingQtyExpected = 0
                   END               
                END
                ELSE 
                  SET @n_InsertQtyExpected = 0 
                      
                --SET @n_RemainQty = @n_RemainQty - @n_PalletCnt
       
               If @n_RemainQty - @n_PalletCnt >0           
               BEGIN
                    SET @n_RemainQty = @n_RemainQty - @n_PalletCnt               
                    SET @n_InsertQtyExpected = @n_PalletCnt
               END
               ELSE
               BEGIN
                    SET @n_InsertQtyExpected = @n_RemainQty               
                    SET @n_RemainQty =0               
               END
       
               IF @n_InsertQtyExpected <= 0 BREAK
             
                INSERT INTO RECEIPTDETAIL
                (
                  ReceiptKey,          ReceiptLineNumber,   ExternReceiptKey,
                  ExternLineNo,        StorerKey,           POKey,
                  Sku,                 AltSku,              Id,
                  [Status],            DateReceived,        QtyExpected,
                  QtyAdjusted,         QtyReceived,         UOM,
                  PackKey,             VesselKey,           VoyageKey,
                  XdockKey,            ContainerKey,        ToLoc,
                  ToLot,               ToId,                ConditionCode,
                  Lottable01,          Lottable02,          Lottable03,
                  Lottable04,          Lottable05,          CaseCnt,
                  InnerPack,           Pallet,              [Cube],
                  GrossWgt,            NetWgt,              OtherUnit1,
                  OtherUnit2,          UnitPrice,           ExtendedPrice,
                  EffectiveDate,       TariffKey,           FreeGoodQtyExpected,
                  FreeGoodQtyReceived, SubReasonCode,       FinalizeFlag,
                  DuplicateFrom,       BeforeReceivedQty,   PutawayLoc,
                  ExportStatus,        SplitPalletFlag,     POLineNumber,
                  LoadKey,             ExternPoKey,         UserDefine01,
                  UserDefine02,        UserDefine03,        UserDefine04,
                  UserDefine05,        UserDefine06,        UserDefine07,
                  UserDefine08,        UserDefine09,        UserDefine10,
                  Lottable06,          Lottable07,          Lottable08,
                  Lottable09,          Lottable10,          Lottable11,
                  Lottable12,          Lottable13,          Lottable14,
                  Lottable15         )
                SELECT 
                 ReceiptKey,           @c_NextReceiveLineNo,   ExternReceiptKey,
                  ExternLineNo,        StorerKey,              POKey,
                  Sku,                 AltSku,                 Id,
                  [Status],            DateReceived,           @n_InsertQtyExpected, 
                  0,       QtyReceived,            UOM,
                  PackKey,             VesselKey,              VoyageKey,
                  XdockKey,            ContainerKey,           ToLoc,
                  ToLot,               ToId,                   ConditionCode,
                  Lottable01,          Lottable02,             Lottable03,
                  Lottable04,          Lottable05,             CaseCnt,
                  InnerPack,           Pallet,                 [Cube],
                  GrossWgt,            NetWgt,                 OtherUnit1,
                  OtherUnit2,          UnitPrice,              ExtendedPrice,
                  EffectiveDate,       TariffKey,              FreeGoodQtyExpected,
                  FreeGoodQtyReceived, SubReasonCode,          FinalizeFlag,
                  DuplicateFrom,       0,                      PutawayLoc,
                  ExportStatus,        SplitPalletFlag,        POLineNumber,
                  LoadKey,             ExternPoKey,            UserDefine01,
                  UserDefine02,        UserDefine03,           UserDefine04,
                  UserDefine05,        UserDefine06,           UserDefine07,
                  UserDefine08,        UserDefine09,           UserDefine10,
                  Lottable06,          Lottable07,             Lottable08,
                  Lottable09,          Lottable10,             Lottable11,
                  Lottable12,          Lottable13,             Lottable14,
                  Lottable15            
                FROM RECEIPTDETAIL AS r WITH(NOLOCK)
                WHERE r.ReceiptKey = @c_ReceiptKey 
                AND   r.ReceiptLineNumber = @c_ReceiptLineNumber 
       
               -- Update Original Line
               UPDATE RECEIPTDETAIL 
                 SET QtyExpected = QtyExpected -  @n_InsertQtyExpected, 
                     --BeforeReceivedQty = @n_RemainQtyReceived, 
                     EditDate = GETDATE(), 
                     EditWho = @c_UserName 
               WHERE ReceiptKey = @c_ReceiptKey
               AND   ReceiptLineNumber = @c_ReceiptLineNumber 
       
            END -- @n_RemainQty >= @n_PalletCnt
            */
                         
         FETCH_NEXT:          
                   
         FETCH FROM CUR_RECEIPT_LINES INTO @c_ReceiptKey, @c_ReceiptLineNumber, @c_StorerKey,
                                          @c_Sku, @c_UOM, @c_PackKey, @n_BeforeReceivedQty, @n_QtyExpected, @c_Facility
      END    
      CLOSE CUR_RECEIPT_LINES
      DEALLOCATE CUR_RECEIPT_LINES         
    
      SELECT @c_GenID = dbo.fnc_GetRight(@c_Facility, @c_Storerkey, '', 'GenID')
    
      IF @c_GenID = '1'
      BEGIN
         SELECT @c_GEN_ID_DURING_EXPLODE_PACK = dbo.fnc_GetRight(@c_Facility, @c_Storerkey, '', 'GEN_ID_DURING_EXPLODE_PACK') --Get from NSQLConfig
       
         IF @c_GEN_ID_DURING_EXPLODE_PACK = '1'
         BEGIN
            --AYD01 START
            SELECT @c_GenIdSP = dbo.fnc_GetRight(@c_Facility, @c_Storerkey, '', 'ASNExplodeByPackkeySP') 
            IF @c_GenIdSP <> '0' AND NOT EXISTS(SELECT 1 FROM dbo.SYSOBJECTS WHERE NAME = RTRIM(@c_GenIdSP) AND [TYPE] = 'P') 
            BEGIN                                                                                                                                                                                                                                  
               SELECT @c_ErrMsg = CONVERT(CHAR(250), @n_Err),                                                                                                                                                                                     
                      @n_Err = 31012 -- Should Be Set To The SQL Errmessage but I don't know how to do so.                                                                                                                                        
               SELECT @c_ErrMsg = 'NSQL' + CONVERT(CHAR(5), @n_Err) +                                                                                                                                                                             
                         ': Stored Proc name invalid ('+RTRIM(ISNULL(@c_GenIdSP,'')) + ') (lsp_ExplodeByPackKey_Wrapper)'                                                                                  
               GOTO EXIT_SP                                                                                                                                                                                                                       
            END   
            --AYD01 END
                     	
            DECLARE CUR_RECEIPTDETAIL CURSOR LOCAL FAST_FORWARD READ_ONLY FOR 
               SELECT RD.ReceiptLineNumber
               FROM   RECEIPTDETAIL RD WITH (NOLOCK) 
               JOIN   RECEIPT AS RH WITH(NOLOCK) ON RH.ReceiptKey = RD.ReceiptKey 
               WHERE  RD.ReceiptKey = @c_ReceiptKey
               AND    RD.FinalizeFlag <> 'Y'
               AND    ISNULL(RD.ToID,'') = ''
               ORDER  BY RD.ReceiptLineNumber                                       --(Wan03)
     
            OPEN CUR_RECEIPTDETAIL
          
            FETCH FROM CUR_RECEIPTDETAIL INTO @c_ReceiptLineNumber
          
            WHILE @@FETCH_STATUS = 0
            BEGIN
							 --AYD01 START
               IF @c_GenIdSP <> '0'
               BEGIN    
                  SET @cSQL = N'EXEC dbo.' + RTRIM(@c_GenIdSP)   
                            + ' @c_StorerKey = @c_StorerKey,          '      
                            + ' @c_IDKey     = @c_IDKey        OUTPUT,'   
                            + ' @b_Success   = @b_Success      OUTPUT,'  
                            + ' @n_ErrNo     = @n_ErrNo        OUTPUT,'      
                            + ' @c_ErrMsg    = @c_ErrMsg       OUTPUT'     

                  SET @cSQLParam = N'@c_StorerKey  NVARCHAR(15),'
                                 + ' @c_IDKey      NVARCHAR(20)    OUTPUT,'
                                 + ' @b_Success    INT             OUTPUT,'
                                 + ' @n_ErrNo      INT             OUTPUT,'
                                 + ' @c_ErrMsg     NVARCHAR(250)   OUTPUT'    
                                      
                  EXEC sp_ExecuteSQL @cSQL, @cSQLParam, 
                        @c_StorerKey, 
                        @c_ToID        OUTPUT, 
                        @b_Success     OUTPUT,
                        @n_Err         OUTPUT, 
                        @c_ErrMsg      OUTPUT  

                  IF @n_Err <> 0  
                  BEGIN
                     SET @b_Success = 0
                     SET @c_ErrMsg = 'Error in Execute SQL: ' + @c_GenIdSP + ' (lsp_ExplodeByPackKey_Wrapper).'
                     GOTO EXIT_SP
                  END  
               END   
               --AYD01 END
               ELSE
               BEGIN
                  EXEC dbo.nspg_GetKey               
                     @KeyName = 'ID'    
                  ,@fieldlength = 10
                  ,@keystring = @c_ToID OUTPUT    
                  ,@b_Success = @b_Success OUTPUT    
                  ,@n_err     = @n_err OUTPUT    
                  ,@c_errmsg  = @c_errmsg OUTPUT                     
               END                

               UPDATE RECEIPTDETAIL 
                  SET ToId = @c_ToID ,
                     EditDate = GETDATE(), 
                     EditWho = @c_UserName 
               WHERE ReceiptKey = @c_ReceiptKey
               AND   ReceiptLineNumber = @c_ReceiptLineNumber        
            
               FETCH FROM CUR_RECEIPTDETAIL INTO @c_ReceiptLineNumber
            END
            CLOSE CUR_RECEIPTDETAIL
            DEALLOCATE CUR_RECEIPTDETAIL
         END              
      END
   END TRY  
  
   BEGIN CATCH   
      SET @b_Success = 0                  --(Wan01) 
      SET @c_ErrMsg = ERROR_MESSAGE()     --(Wan01) 
      GOTO EXIT_SP  
   END CATCH -- (SWT01) - End Big Outer Begin try.. end Try Begin Catch.. End Catch  
                          
    EXIT_SP: 
    IF @b_ExecuteAs = 1              -- (SWT01)
       REVERT                        

    EXEC [WM].[lsp_ResetUser] -- (SWT01)
END
GO
GRANT EXECUTE ON [WM].[lsp_ExplodeByPackKey_Wrapper] TO nSQL 
GO
