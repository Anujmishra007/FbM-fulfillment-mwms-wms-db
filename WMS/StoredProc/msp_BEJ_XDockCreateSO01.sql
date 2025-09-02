SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
/************************************************************************/  
/* Stored Procedure: msp_BEJ_XDockCreateSO01                            */
/* Creation Date: 19-May-2025                                           */
/* Copyright: Maersk                                                    */
/* Written by: AYD                                                      */  
/*                                                                      */  
/* Purpose: UWP-30411 - Create backend job to auto trigger SO generation*/
/*          based on ASN import                                         */
/*                                                                      */  
/* Called By: Call by SQL Scheduler Job                                 */
/*                                                                      */  
/* Version: 1.0                                                         */  
/*                                                                      */  
/* Data Modifications:                                                  */  
/*                                                                      */  
/* Updates:                                                             */  
/* Date         Author  Rev   Purposes                                  */  
/* 2025-05-28   AYD01   1.1   Change mapping for OD.OpenQty:            */
/*                            RD.QtyReceived -> RD.QtyExpected          */
/* 2025-05-30   AYD02   1.2   Check ExternOrderKey when inserting OD    */
/* 2025-09-02   CZJ002  1.3   LCL SP Enhancement                        */
/************************************************************************/ 
CREATE   PROC [dbo].[msp_BEJ_XDockCreateSO01]
     @c_StorerKey   NVARCHAR(15)   = ''
   , @c_Facility    NVARCHAR(5)    = ''
   , @c_OtherConfig NVARCHAR(4000)  = ''

AS
BEGIN
   SET NOCOUNT ON
   SET ANSI_NULLS OFF
   SET QUOTED_IDENTIFIER OFF
   SET CONCAT_NULL_YIELDS_NULL OFF

   DECLARE 
            @b_Success           INT            = 1  
         , @n_Err                INT            = '' 
         , @c_ErrMsg             NVARCHAR(255)  = '' 
         , @n_Cnt                INT            = 0
         , @n_Continue           INT            = 1
         , @n_StartTranCount     INT            = @@TRANCOUNT
         , @n_OrderCnt           INT            = 0
         , @c_Receiptkey         NVARCHAR(10)   = ''
         , @c_ASNStatus          NVARCHAR(10)   = '0'
         , @c_DocType            NVARCHAR(1)    = ''
         , @c_OrderKey           NVARCHAR(10)   = ''
         , @c_ExternOrderkey     NVARCHAR(50)   = ''
         , @c_RecType            NVARCHAR(10)   = ''                      
         , @c_OrderLineNumber    NVARCHAR(5)    = ''
         , @c_ExternLineNo       NVARCHAR(20)   = ''
         , @c_Sku                NVARCHAR(20)   = ''
         , @c_Packkey            NVARCHAR(10)   = ''
         , @c_UOM                NVARCHAR(10)   = ''
         , @n_OriginalQty        INT            = 0
         , @n_OpenQty            INT            = 0
         , @c_Lottable02         NVARCHAR(18)   = ''
         , @c_Lottable08         NVARCHAR(30)   = ''
         , @c_Lottable11         NVARCHAR(30)   = ''
         , @c_TariffKey          NVARCHAR(10)   = ''
         , @c_Lottable03         NVARCHAR(18)   = ''
         , @c_POKey              NVARCHAR(10)   = ''
         , @c_POLineNumber       NVARCHAR(10)   = ''
         , @c_ExternReceiptkey   NVARCHAR(50)   = ''           
         , @c_Consigneekey       NVARCHAR(15)  = ''            
         , @c_DeliveryDate       DATETIME
         , @c_Door               NVARCHAR(10)  = ''
         , @c_ExternPOKey        NVARCHAR(20)  = ''            
         , @c_Id                 NVARCHAR(36)      
         --AYD START  
         , @c_B_Contact1         NVARCHAR(50)  = ''
         , @c_B_Company          NVARCHAR(50)  = ''
         , @c_B_Address1         NVARCHAR(50)  = ''
         , @c_BillToKey          NVARCHAR(50)  = ''
         , @c_C_Contact1         NVARCHAR(50)  = ''
         , @c_C_Address1         NVARCHAR(50)  = ''
         , @c_C_Address2         NVARCHAR(50)  = ''
         , @c_C_Address3         NVARCHAR(50)  = ''
         , @c_OHUD01             NVARCHAR(50)  = ''
         , @c_OHUD02             NVARCHAR(50)  = ''
         , @c_OHUD06             NVARCHAR(50)  = ''
         , @c_OHUD07             NVARCHAR(50)  = ''
         , @n_ToDo               INT           = 0
		 , @c_GrossWgt           FLOAT                         --(CZJ002)
         --AYD END
    IF OBJECT_ID('tempdb..#TMP_ORD') IS NOT NULL DROP TABLE #TMP_ORD
    IF OBJECT_ID('tempdb..#TMP_ORDDTL') IS NOT NULL DROP TABLE #TMP_ORDDTL

    SELECT @n_ToDo = COUNT(1) FROM RECEIPT r WITH (nolock)
    INNER JOIN RECEIPTDETAIL rd WITH (nolock) ON r.ReceiptKey = rd.ReceiptKey
    WHERE 
    r.StorerKey = @c_StorerKey
    AND r.Facility = @c_Facility 
    AND r.RECType='XDOCK' AND r.[Status] = '0' AND r.ASNStatus='0' AND RTRIM(r.ExternReceiptKey) <> ''
    AND rd.QtyExpected > 0 AND RTRIM(rd.ExternReceiptKey) <> ''
    AND NOT EXISTS (SELECT 1 FROM ORDERS o WITH (nolock) 
        WHERE r.ExternReceiptKey = o.ExternOrderKey AND r.StorerKey = o.StorerKey
        AND r.RECType='XDOCK' AND r.[Status] = '0' AND r.ASNStatus='0' AND rd.QtyExpected > 0 AND RTRIM(r.ExternReceiptKey) <> '')
    

    IF @n_ToDo = 0
    BEGIN
        GOTO QUIT_SP
    END    



    /* PREPARE_TMP_TABLES START (AYD) */
        IF @n_continue IN(1, 2)
        BEGIN
            CREATE TABLE #TMP_ORD
            (  RowID              INT            NOT NULL IDENTITY(1,1) PRIMARY KEY
            ,  Orderkey           NVARCHAR(10)   NOT NULL   DEFAULT('')
            ,  Receiptkey         NVARCHAR(10)   NOT NULL   DEFAULT('')
            ,  StorerKey          NVARCHAR(15)   NULL
            ,  ExternOrderKey     NVARCHAR(50)   NOT NULL   DEFAULT ('')
            ,  OrderDate          DATETIME       NULL       DEFAULT (GETDATE())
            ,  DeliveryDate       DATETIME       NULL       DEFAULT (GETDATE())
            ,  [Priority]         NVARCHAR(10)   NULL       DEFAULT ('5')
            ,  Consigneekey       NVARCHAR(15)   NULL       DEFAULT ('')
            ,  C_Contact1         NVARCHAR(30)   NULL
            ,  C_Contact2         NVARCHAR(30)   NULL
            ,  C_Company          NVARCHAR(45)   NULL
            ,  C_Address1         NVARCHAR(45)   NULL
            ,  C_Address2         NVARCHAR(45)   NULL
            ,  C_Address3         NVARCHAR(45)   NULL
            ,  C_Address4         NVARCHAR(45)   NULL
            ,  C_City             NVARCHAR(45)   NULL
            ,  C_State            NVARCHAR(45)   NULL
            ,  C_Zip              NVARCHAR(18)   NULL
            ,  C_Country          NVARCHAR(30)   NULL
            ,  C_ISOCntryCode     NVARCHAR(10)   NULL
            ,  C_Phone1           NVARCHAR(18)   NULL
            ,  C_Phone2           NVARCHAR(18)   NULL
            ,  C_Fax1             NVARCHAR(18)   NULL
            ,  C_Fax2             NVARCHAR(18)   NULL
            ,  C_Vat              NVARCHAR(18)   NULL
            ,  BuyerPO            NVARCHAR(20)   NULL
            ,  BillToKey          NVARCHAR(15)   NOT NULL  DEFAULT ('')
            ,  B_contact1         NVARCHAR(30)   NULL
            ,  B_Contact2         NVARCHAR(30)   NULL
            ,  B_Company          NVARCHAR(45)   NULL
            ,  B_Address1         NVARCHAR(45)   NULL
            ,  B_Address2         NVARCHAR(45)   NULL
            ,  B_Address3         NVARCHAR(45)   NULL
            ,  B_Address4         NVARCHAR(45)   NULL
            ,  B_City             NVARCHAR(45)   NULL
            ,  B_State            NVARCHAR(45)   NULL
            ,  B_Zip              NVARCHAR(18)   NULL
            ,  B_Country          NVARCHAR(30)   NULL
            ,  B_ISOCntryCode     NVARCHAR(10)   NULL
            ,  B_Phone1           NVARCHAR(18)   NULL
            ,  B_Phone2           NVARCHAR(18)   NULL
            ,  B_Fax1             NVARCHAR(18)   NULL
            ,  B_Fax2             NVARCHAR(18)   NULL
            ,  B_Vat              NVARCHAR(18)   NULL
            ,  IncoTerm           NVARCHAR(10)   NULL
            ,  PmtTerm            NVARCHAR(10)   NULL
            ,  OpenQty            INT            NULL       DEFAULT (0)
            ,  [Status]           NVARCHAR(10)   NULL       DEFAULT ('0')
            ,  DischargePlace     NVARCHAR(30)   NULL
            ,  DeliveryPlace      NVARCHAR(30)   NULL
            ,  IntermodalVehicle  NVARCHAR(30)   NOT NULL   DEFAULT ('')
            ,  CountryOfOrigin    NVARCHAR(30)   NULL
            ,  CountryDestination NVARCHAR(30)   NULL
            ,  UpdateSource       NVARCHAR(10)   NULL       DEFAULT ('0')
            ,  Type               NVARCHAR(10)   NOT NULL   DEFAULT ('0')
            ,  OrderGroup         NVARCHAR(20)   NULL       DEFAULT ('')
            ,  Door               NVARCHAR(10)   NULL       DEFAULT ('99')
            ,  Route              NVARCHAR(10)   NULL       DEFAULT ('99')
            ,  Stop               NVARCHAR(10)   NULL       DEFAULT ('99')
            ,  Notes              NVARCHAR(4000) NULL
            ,  EffectiveDate      DATETIME       NULL       DEFAULT (GETDATE())
            ,  ContainerType      NVARCHAR(20)   NULL
            ,  ContainerQty       INT            NULL       DEFAULT (0)
            ,  BilledContainerQty INT            NULL       DEFAULT (0)
            ,  SOStatus           NVARCHAR(10)   NULL       DEFAULT ('0')
            ,  MBOLKey            NVARCHAR(10)   NULL       DEFAULT ('')
            ,  InvoiceNo          NVARCHAR(10)   NULL       DEFAULT ('')
            ,  InvoiceAmount      FLOAT          NULL       DEFAULT(0.00)
            ,  Salesman           NVARCHAR(30)   NULL       DEFAULT ('')
            ,  GrossWeight        FLOAT          NULL       DEFAULT(0.00)
            ,  Capacity           FLOAT          NULL       DEFAULT(0.00)
            ,  PrintFlag          NVARCHAR(1)    NULL       DEFAULT ('N')
            ,  LoadKey            NVARCHAR(10)   NULL       DEFAULT ('')
            ,  Rdd                NVARCHAR(30)   NULL       DEFAULT ('')
            ,  Notes2             NVARCHAR(4000) NULL
            ,  SequenceNo         INT            NULL       DEFAULT (99999999)
            ,  Rds                NVARCHAR(1)    NULL       DEFAULT ('N')
            ,  SectionKey         NVARCHAR(10)   NULL
            ,  Facility           NVARCHAR(5)    NULL
            ,  PrintDocDate       DATETIME       NULL
            ,  LabelPrice         NVARCHAR(5)    NULL
            ,  POKey              NVARCHAR(10)   NULL       DEFAULT ('')
            ,  ExternPOKey        NVARCHAR(20)   NULL       DEFAULT ('')
            ,  XDockFlag          NVARCHAR(1)    NULL       DEFAULT ('0')
            ,  UserDefine01       NVARCHAR(20)   NULL       DEFAULT ('')
            ,  UserDefine02       NVARCHAR(20)   NULL       DEFAULT ('')
            ,  UserDefine03       NVARCHAR(20)   NULL       DEFAULT ('')
            ,  UserDefine04       NVARCHAR(20)   NULL       DEFAULT ('')
            ,  UserDefine05       NVARCHAR(20)   NULL       DEFAULT ('')
            ,  UserDefine06       DATETIME       NULL
            ,  UserDefine07       DATETIME       NULL
            ,  UserDefine08       NVARCHAR(10)   NULL       DEFAULT ('N')
            ,  UserDefine09       NVARCHAR(10)   NULL       DEFAULT ('')
            ,  UserDefine10       NVARCHAR(10)   NULL       DEFAULT ('')
            ,  Issued             NVARCHAR(1 )   NULL       DEFAULT ('Y')
            ,  DeliveryNote       NVARCHAR(10)   NULL
            ,  PODCust            DATETIME       NULL
            ,  PODArrive          DATETIME       NULL
            ,  PODReject          DATETIME       NULL
            ,  PODUser            NVARCHAR(18)   NULL       DEFAULT ('')
            ,  XDOCKPOKEY         NVARCHAR(20)   NULL
            ,  SpecialHandling    NVARCHAR(1)    NULL       DEFAULT ('N')
            ,  RoutingTool        NVARCHAR(30)   NULL
            ,  MarkforKey         NVARCHAR(15)   NULL       DEFAULT ('')
            ,  M_Contact1         NVARCHAR(30)   NULL
            ,  M_Contact2         NVARCHAR(30)   NULL
            ,  M_Company          NVARCHAR(45)   NULL
            ,  M_Address1         NVARCHAR(45)   NULL
            ,  M_Address2         NVARCHAR(45)   NULL
            ,  M_Address3         NVARCHAR(45)   NULL
            ,  M_Address4         NVARCHAR(45)   NULL
            ,  M_City             NVARCHAR(45)   NULL
            ,  M_State            NVARCHAR(45)   NULL
            ,  M_Zip              NVARCHAR(18)   NULL
            ,  M_Country          NVARCHAR(30)   NULL
            ,  M_ISOCntryCode     NVARCHAR(10)   NULL
            ,  M_Phone1           NVARCHAR(18)   NULL
            ,  M_Phone2           NVARCHAR(18)   NULL
            ,  M_Fax1             NVARCHAR(18)   NULL
            ,  M_Fax2             NVARCHAR(18)   NULL
            ,  M_Vat              NVARCHAR(18)   NULL
            ,  ShipperKey         NVARCHAR(15)   NULL       DEFAULT ('')
            )
            IF @@ERROR <> 0 
            BEGIN
                SET @n_Continue = 3
                SET @n_Err = 68011
                SET @c_ErrMsg = 'NSQL' + CONVERT(NCHAR(5),@n_Err)
                            + ': CREATE TABLE #TMP_ORD Table Failed. (msp_BEJ_XDockCreateSO01)'
                
                GOTO QUIT_SP
            END

            CREATE TABLE #TMP_ORDDTL
            (  Orderkey          NVARCHAR(10)   NOT NULL   DEFAULT('')     
            ,  Receiptkey        NVARCHAR(10)   NOT NULL
            ,  POkey             NVARCHAR(10)   NULL
            ,  POLineNumber      NVARCHAR(10)   NULL
            ,  ExternOrderkey    NVARCHAR(50)   NULL
            ,  ExternLineNo      NVARCHAR(20)   NULL
            ,  Storerkey         NVARCHAR(15)   NULL
            ,  Sku               NVARCHAR(20)   NULL
            ,  Packkey           NVARCHAR(10)   NULL
            ,  UOM               NVARCHAR(10)   NULL
            ,  OriginalQty       INT            DEFAULT(0)
            ,  OpenQty           INT            DEFAULT(0)
            ,  UnitPrice         FLOAT          DEFAULT(0)
            ,  Lot               NVARCHAR(10)   NULL
            ,  Lottable01        NVARCHAR(18)   NULL
            ,  Lottable02        NVARCHAR(18)   NULL
            ,  Lottable03        NVARCHAR(18)   NULL
            ,  Lottable04        DATETIME       NULL
            ,  Lottable05        DATETIME       NULL
            ,  Lottable08        NVARCHAR(30)   NULL
            ,  Lottable11        NVARCHAR(30)   NULL
            ,  Userdefine02      NVARCHAR(18)   NULL  DEFAULT('')    
            ,  UserDefine06      DATETIME       NULL
            ,  PutawayLoc        NVARCHAR(10)   NULL  DEFAULT('')
            ,  ExternPOKey       NVARCHAR(20)   NULL  DEFAULT('')
            ,  ID                NVARCHAR(36)   NULL                
            )
            IF @@ERROR <> 0
            BEGIN
                SET @n_Continue = 3
                SET @n_Err = 68012
                SET @c_ErrMsg = 'NSQL' + CONVERT(NCHAR(5),@n_Err)
                            + ': CREATE TABLE #TMP_ORDDTL Table Failed. (msp_BEJ_XDockCreateSO01)'
                
                GOTO QUIT_SP
            END
        END
    /* PREPARE_TMP_TABLES END (AYD) */
    /* INSERT_TMP_OH_OD: START (AYD) */
        IF @n_continue IN(1,2)
            BEGIN
                DECLARE CUR_RECDET CURSOR LOCAL FAST_FORWARD READ_ONLY FOR
                    SELECT 
                    RD.ReceiptKey
                    ,ISNULL(RD.POKey,'')
                    ,ISNULL(RD.POLineNumber,'')
                    ,RD.ExternReceiptkey
                    ,RD.ExternLineNo
                    ,RD.Storerkey
                    ,RD.Sku
                    ,RD.Packkey
                    ,RD.UOM
                    ,RD.QtyReceived
                    ,RD.QtyExpected --AYD01
                    ,RD.Lottable03                                   
                    ,RD.Lottable02
                    ,RD.Lottable08
                    ,RD.Lottable11
                    ,Consigneekey = ISNULL(RD.Userdefine02,'')
                    ,DeliveryDate = ISNULL(RD.UserDefine06,'1900-01-01')
                    ,Door         = ISNULL(RD.PutawayLoc  ,'')
                    ,RD.ExternPOKey                                  
                    ,RD.ToId
                    ---AYD START
                    ,B_Contact1   = r.CarrierReference
                    ,B_Company    = r.SellerName         
                    ,B_Address1   = r.SellerAddress1    
                    ,BillToKey    = r.SellerCompany 
                    ,OHUD01       = r.UserDefine01
                    ,OHUD02       = r.RECType
                    ,OHUD06       = r.UserDefine06
                    ,OHUD07       = r.UserDefine07
                    ,c_contact    = rd.UserDefine10
                    ,c_address1   = rd.UserDefine03
                    ,c_address2   = rd.UserDefine04
                    ,c_address3   = rd.UserDefine05
                    ---AYD END
					,RD.GrossWgt                                     --(CZJ002)
                    FROM RECEIPT r WITH (nolock) 
                    INNER JOIN RECEIPTDETAIL rd WITH (nolock) ON r.ReceiptKey = rd.ReceiptKey
                    WHERE 
                    r.StorerKey = @c_StorerKey
                    AND r.Facility = @c_Facility 
                    AND r.RECType='XDOCK' AND r.[Status] = '0' AND r.ASNStatus='0' AND RTRIM(r.ExternReceiptKey) <> ''
                    AND rd.QtyExpected > 0 AND RTRIM(rd.ExternReceiptKey) <> ''
                    AND NOT EXISTS (SELECT 1 FROM ORDERS o WITH (nolock) 
                        WHERE r.ExternReceiptKey = o.ExternOrderKey AND r.StorerKey = o.StorerKey
                        AND r.RECType='XDOCK' AND r.[Status] = '0' AND r.ASNStatus='0' AND rd.QtyExpected > 0 AND RTRIM(r.ExternReceiptKey) <> '')
                    ORDER BY ISNULL(rd.Userdefine02,''), ISNULL(rd.UserDefine06,'1900-01-01'), ISNULL(rd.PutawayLoc  ,''), rd.ReceiptLineNumber

                    OPEN CUR_RECDET

                    FETCH NEXT FROM CUR_RECDET INTO 
                    @c_Receiptkey, @c_POKey, @c_POLineNumber, @c_ExternReceiptkey, @c_ExternLineNo, @c_Storerkey,
                    @c_Sku, @c_Packkey, @c_UOM, @n_OriginalQty, @n_OpenQty, @c_Lottable03, @c_Lottable02, @c_Lottable08, @c_Lottable11, 
                    @c_Consigneekey, @c_DeliveryDate, @c_Door, @c_ExternPOKey, @c_Id
                    --AYD START
                    , @c_B_Contact1         
                    , @c_B_Company          
                    , @c_B_Address1 
                    , @c_BillToKey                 
                    , @c_OHUD01       
                    , @c_OHUD02       
                    , @c_OHUD06       
                    , @c_OHUD07    
                    , @c_C_Contact1
                    , @c_C_Address1
                    , @c_C_Address2
                    , @c_C_Address3 
					, @c_GrossWgt  --(CZJ002)
                    --AYD END

                    WHILE @@FETCH_STATUS <> -1 AND @n_continue IN(1, 2)
                    BEGIN
                        IF EXISTS (SELECT 1 FROM #TMP_ORD WHERE ExternOrderKey = @c_ExternReceiptkey    --AYD02
                        and Consigneekey = @c_Consigneekey and DeliveryDate = @c_DeliveryDate and Door = @c_Door and OH.ExternPOKey = @c_ExternPOKey) --(CZJ002)
                        BEGIN
                            SELECT @c_Orderkey = Orderkey FROM #TMP_ORD WHERE ExternOrderKey = @c_ExternReceiptkey  --AYD02
                            and Consigneekey = @c_Consigneekey and DeliveryDate = @c_DeliveryDate and Door = @c_Door and OH.ExternPOKey = @c_ExternPOKey --(CZJ002)
                        END

                        ELSE
                        BEGIN
                            EXECUTE nspg_GetKey
                                @KeyName = 'ORDER'
                                , @fieldlength = 10
                                , @keystring = @c_Orderkey   OUTPUT
                                , @b_Success = @b_Success    OUTPUT
                                , @n_Err     = @n_Err        OUTPUT
                                , @c_ErrMsg  = @c_ErrMsg     OUTPUT
                                , @n_Batch   = 1                                  
                            IF @b_Success = 0
                            BEGIN
                                SET @n_Continue = 3
                                SET @n_Err = 68013
                                SET @c_ErrMsg = 'NSQL' + CONVERT(NCHAR(5),@n_Err)
                                                + ': nspg_GetKey Failed. (msp_BEJ_XDockCreateSO01)'
                                CLOSE CUR_RECDET
                                DEALLOCATE CUR_RECDET
                                GOTO QUIT_SP
                            END

                            IF @c_Orderkey <> ''
                            BEGIN
                                INSERT INTO #TMP_ORD
                                (  OrderKey
                                ,  Storerkey
                                ,  Type
                                ,  Door
                                ,  DeliveryDate
                                ,  ExternOrderkey
                                ,  Consigneekey
                                ,  C_Contact1
                                ,  C_Contact2
                                ,  C_Company
                                ,  C_Address1
                                ,  C_Address2
                                ,  C_Address3
                                ,  C_Address4
                                ,  C_City
                                ,  C_State
                                ,  C_Zip
                                ,  C_Country
                                ,  C_ISOCntryCode
                                ,  C_Phone1
                                ,  C_Phone2
                                ,  C_Fax1
                                ,  C_Fax2
                                ,  C_Vat
                                ,  Facility
                                ,  Billtokey
                                ,  B_Contact1
                                ,  B_Company
                                ,  B_Address1
                                ,  Userdefine01
                                ,  UserDefine02
                                ,  Userdefine06
                                ,  Userdefine07
                                ,  ExternPOKey
								,  GrossWeight     --(CZJ002)
								,  UpdateSource    --(CZJ002)
                                ) VALUES 
                                (  @c_Orderkey
                                ,  @c_Storerkey
                                ,  'XDOCK'
                                ,  @c_Door
                                ,  @c_DeliveryDate
                                ,  @c_ExternReceiptkey
                                ,  @c_Consigneekey
                                ,  @c_C_Contact1 --AYD
                                ,  ''
                                ,  ''
                                ,  @c_C_Address1 --AYD
                                ,  @c_C_Address2 --AYD
                                ,  @c_C_Address3 --AYD
                                ,  ''
                                ,  ''
                                ,  ''
                                ,  ''
                                ,  ''
                                ,  ''
                                ,  ''
                                ,  ''
                                ,  ''
                                ,  ''
                                ,  ''
                                ,  @c_Facility
                                ,  @c_BillToKey    --AYD
                                ,  @c_B_Contact1   --AYD
                                ,  @c_B_Company    --AYD
                                ,  @c_B_Address1   --AYD
                                ,  @c_OHUD01 --AYD
                                ,  @c_OHUD02 --AYD
                                ,  @c_OHUD06 --AYD
                                ,  @c_OHUD07 --AYD
                                ,  @c_ExternPOKey
								,  @c_GrossWgt    --(CZJ002)
								,  @c_Receiptkey  --(CZJ002)
                                )   
                                IF @@ERROR <> 0
                                BEGIN
                                    SET @n_Continue = 3
                                    SET @n_Err = 68014
                                    SET @c_ErrMsg = 'NSQL' + CONVERT(NCHAR(5),@n_Err)
                                                + ': INSERT INTO #TMP_ORD Table Failed. (msp_BEJ_XDockCreateSO01)'
                                    CLOSE CUR_RECDET
                                    DEALLOCATE CUR_RECDET
                                    GOTO QUIT_SP
                                END
                            END
                        END

                        INSERT INTO #TMP_ORDDTL
                        (  OrderKey
                            ,  ReceiptKey
                        ,  POKey
                        ,  POLineNumber
                        ,  ExternOrderkey
                        ,  ExternLineNo
                        ,  Storerkey
                        ,  Sku
                        ,  Packkey
                        ,  UOM
                        ,  OriginalQty
                        ,  OpenQty
                        ,  Lottable03
                        ,  Lottable02
                        ,  Lottable08
                        ,  Lottable11
                        ,  Userdefine02
                        ,  UserDefine06
                        ,  PutawayLoc
                        ,  ExternPOKey
                        ,  ID                                                                                                                   
                        ) values (@c_Orderkey,@c_Receiptkey, @c_POKey, @c_POLineNumber, @c_ExternReceiptkey,@c_ExternLineNo,@c_Storerkey,
                        @c_Sku, @c_Packkey, @c_UOM, @n_OriginalQty,@n_OpenQty,@c_Lottable03,@c_Lottable02, @c_Lottable08, @c_Lottable11,                      
                        @c_Consigneekey,@c_DeliveryDate,@c_Door,@c_ExternPOKey,@c_Id)     

                        IF @@ERROR <> 0
                        BEGIN
                            SET @n_Continue = 3
                            SET @n_Err = 68015
                            SET @c_ErrMsg = 'NSQL' + CONVERT(NCHAR(5),@n_Err)
                                        + ': INSERT INTO #TMP_ORDDTL Table Failed. (msp_BEJ_XDockCreateSO01)'
                            CLOSE CUR_RECDET
                            DEALLOCATE CUR_RECDET
                            GOTO QUIT_SP
                        END                                                                    

                        FETCH NEXT FROM CUR_RECDET INTO 
                            @c_Receiptkey, @c_POKey, @c_POLineNumber, @c_ExternReceiptkey, @c_ExternLineNo, @c_Storerkey,
                            @c_Sku, @c_Packkey, @c_UOM, @n_OriginalQty, @n_OpenQty, @c_Lottable03, @c_Lottable02, @c_Lottable08, @c_Lottable11, 
                            @c_Consigneekey, @c_DeliveryDate, @c_Door, @c_ExternPOKey, @c_Id
                            --AYD START
                            , @c_B_Contact1         
                            , @c_B_Company          
                            , @c_B_Address1     
                            , @c_BillToKey    
                            , @c_OHUD01       
                            , @c_OHUD02       
                            , @c_OHUD06       
                            , @c_OHUD07    
                            , @c_C_Contact1
                            , @c_C_Address1
                            , @c_C_Address2
                            , @c_C_Address3 
                            --AYD END 
							, @c_GrossWgt  --(CZJ002)
                    END
                    CLOSE CUR_RECDET
                    DEALLOCATE CUR_RECDET
            END
    /* INSERT_TMP_OH_OD: END (AYD) */
    /* INSERT_ORDERS_TABLE: START (AYD) */
        IF @n_continue IN(1, 2)
        BEGIN
            INSERT INTO ORDERS
            (  OrderKey
            ,  StorerKey
            ,  ExternOrderKey
            ,  OrderDate
            ,  DeliveryDate
            ,  Priority
            ,  ConsigneeKey
            ,  C_contact1
            ,  C_Contact2
            ,  C_Company
            ,  C_Address1
            ,  C_Address2
            ,  C_Address3
            ,  C_Address4
            ,  C_City
            ,  C_State
            ,  C_Zip
            ,  C_Country
            ,  C_ISOCntryCode
            ,  C_Phone1
            ,  C_Phone2
            ,  C_Fax1
            ,  C_Fax2
            ,  C_Vat
            ,  BuyerPO
            ,  BillToKey
            ,  B_contact1
            ,  B_Contact2
            ,  B_Company
            ,  B_Address1
            ,  B_Address2
            ,  B_Address3
            ,  B_Address4
            ,  B_City
            ,  B_State
            ,  B_Zip
            ,  B_Country
            ,  B_ISOCntryCode
            ,  B_Phone1
            ,  B_Phone2
            ,  B_Fax1
            ,  B_Fax2
            ,  B_Vat
            ,  IncoTerm
            ,  PmtTerm
            ,  OpenQty
            ,  Status
            ,  DischargePlace
            ,  DeliveryPlace
            ,  IntermodalVehicle
            ,  CountryOfOrigin
            ,  CountryDestination
            ,  UpdateSource
            ,  Type
            ,  OrderGroup
            ,  Door
            ,  Route
            ,  Stop
            ,  Notes
            ,  EffectiveDate
            ,  ContainerType
            ,  ContainerQty
            ,  BilledContainerQty
            ,  SOStatus
            ,  MBOLKey
            ,  InvoiceNo
            ,  InvoiceAmount
            ,  Salesman
            ,  GrossWeight
            ,  Capacity
            ,  PrintFlag
            ,  LoadKey
            ,  Rdd
            ,  Notes2
            ,  SequenceNo
            ,  Rds
            ,  SectionKey
            ,  Facility
            ,  PrintDocDate
            ,  LabelPrice
            ,  POKey
            ,  ExternPOKey
            ,  XDockFlag
            ,  UserDefine01
            ,  UserDefine02
            ,  UserDefine03
            ,  UserDefine04
            ,  UserDefine05
            ,  UserDefine06
            ,  UserDefine07
            ,  UserDefine08
            ,  UserDefine09
            ,  UserDefine10
            ,  Issued
            ,  DeliveryNote
            ,  PODCust
            ,  PODArrive
            ,  PODReject
            ,  PODUser
            ,  xdockpokey
            ,  SpecialHandling
            ,  RoutingTool
            ,  MarkforKey
            ,  M_Contact1
            ,  M_Contact2
            ,  M_Company
            ,  M_Address1
            ,  M_Address2
            ,  M_Address3
            ,  M_Address4
            ,  M_City
            ,  M_State
            ,  M_Zip
            ,  M_Country
            ,  M_ISOCntryCode
            ,  M_Phone1
            ,  M_Phone2
            ,  M_Fax1
            ,  M_Fax2
            ,  M_vat
            ,  ShipperKey
            )
            SELECT
                Orderkey
            ,  StorerKey
            ,  ExternOrderKey
            ,  OrderDate
            ,  DeliveryDate
            ,  Priority
            ,  Consigneekey
            ,  C_contact1
            ,  C_Contact2
            ,  C_Company
            ,  C_Address1
            ,  C_Address2
            ,  C_Address3
            ,  C_Address4
            ,  C_City
            ,  C_State
            ,  C_Zip
            ,  C_Country
            ,  C_ISOCntryCode
            ,  C_Phone1
            ,  C_Phone2
            ,  C_Fax1
            ,  C_Fax2
            ,  C_vat
            ,  BuyerPO
            ,  BillToKey
            ,  B_contact1
            ,  B_Contact2
            ,  B_Company
            ,  B_Address1
            ,  B_Address2
            ,  B_Address3
            ,  B_Address4
            ,  B_City
            ,  B_State
            ,  B_Zip
            ,  B_Country
            ,  B_ISOCntryCode
            ,  B_Phone1
            ,  B_Phone2
            ,  B_Fax1
            ,  B_Fax2
            ,  B_Vat
            ,  IncoTerm
            ,  PmtTerm
            ,  OpenQty
            ,  [Status]
            ,  DischargePlace
            ,  DeliveryPlace
            ,  IntermodalVehicle
            ,  CountryOfOrigin
            ,  CountryDestination
            ,  UpdateSource
            ,  [Type]
            ,  OrderGroup
            ,  Door
            ,  [Route]
            ,  [Stop]
            ,  Notes
            ,  EffectiveDate
            ,  ContainerType
            ,  ContainerQty
            ,  BilledContainerQty
            ,  SOStatus
            ,  MBOLKey
            ,  InvoiceNo
            ,  InvoiceAmount
            ,  Salesman
            ,  GrossWeight
            ,  Capacity
            ,  PrintFlag
            ,  LoadKey
            ,  Rdd
            ,  Notes2
            ,  SequenceNo
            ,  Rds
            ,  SectionKey
            ,  Facility
            ,  PrintDocDate
            ,  LabelPrice
            ,  POKey
            ,  ExternPOKey
            ,  XDockFlag
            ,  UserDefine01
            ,  UserDefine02
            ,  UserDefine03
            ,  UserDefine04
            ,  UserDefine05
            ,  UserDefine06
            ,  UserDefine07
            ,  UserDefine08
            ,  UserDefine09
            ,  UserDefine10
            ,  Issued
            ,  DeliveryNote
            ,  PODCust
            ,  PODArrive
            ,  PODReject
            ,  PODUser
            ,  XDOCKPOKEY
            ,  SpecialHandling
            ,  RoutingTool
            ,  MarkforKey
            ,  M_Contact1
            ,  M_Contact2
            ,  M_Company
            ,  M_Address1
            ,  M_Address2
            ,  M_Address3
            ,  M_Address4
            ,  M_City
            ,  M_State
            ,  M_Zip
            ,  M_Country
            ,  M_ISOCntryCode
            ,  M_Phone1
            ,  M_Phone2
            ,  M_Fax1
            ,  M_Fax2
            ,  M_vat
            ,  ShipperKey
            FROM #TMP_ORD
            ORDER BY RowID

            IF @@ERROR <> 0
            BEGIN
                SET @n_Continue = 3
                SET @n_Err = 68010
                SET @c_ErrMsg = 'NSQL' + CONVERT(NCHAR(5),@n_Err)
                            + ': INSERT INTO ORDERS Table Failed. (msp_BEJ_XDockCreateSO01)'
                
                GOTO QUIT_SP
            END
        END
    /* INSERT_ORDERS_TABLE: END (AYD) */    
    /* INSERT_ORDERDETAIL_TABLE: START (AYD) */
        IF @n_continue IN(1, 2)
        BEGIN
            INSERT INTO ORDERDETAIL
                (  Orderkey
                ,  OrderLineNumber
                ,  ExternOrderKey
                ,  ExternLineNo
                ,  Storerkey
                ,  Sku
                ,  Packkey
                ,  UOM
                ,  OriginalQty
                ,  OpenQty
                ,  Lottable02
                ,  Lottable08
                ,  Lottable11
                ,  Tariffkey
                ,  Lottable03                                                          
                ,  ExternPOKey                                                          
                ,  ID                                                                   
                )
            SELECT td.Orderkey                                                            
                    ,OrderLineNumber =  RIGHT('00000' + CONVERT(NVARCHAR(5),
                                        ROW_NUMBER() OVER ( PARTITION BY td.Orderkey       
                                                        ORDER BY td.ExternLineNo
                                                                    ,td.Sku)),5)
                    ,td.ExternOrderkey
                    ,td.ExternLineNo
                    ,td.Storerkey
                    ,td.Sku
                    ,td.Packkey
                    ,td.UOM
                    ,td.OriginalQty
                    ,td.OpenQty
                    ,td.Lottable02
                    ,td.Lottable08
                    ,td.Lottable11
                    ,Tariffkey =  CASE WHEN tf.Tariffkey NOT IN ('',NULL)
                                THEN tf.Tariffkey ELSE ISNULL(s.Tariffkey,'')
                                END
                    ,td.Lottable03                                                           
                    ,td.ExternPOKey                                                          
                    ,td.ID                                                                   
            FROM #TMP_ORDDTL td
            JOIN dbo.SKU s (NOLOCK) ON  td.Storerkey = s.Storerkey
                                    AND td.Sku = s.Sku
            LEFT OUTER JOIN TARIFFxFACILITY tf (NOLOCK) ON  tf.Facility = @c_Facility       
                                                        AND td.Storerkey = tf.Storerkey
                                                        AND td.Sku = tf.Sku
            ORDER BY td.ExternLineNo
                    ,  td.Sku
            IF @@ERROR <> 0
            BEGIN
                SET @n_Continue = 3
                SET @n_Err = 68020
                SET @c_ErrMsg = 'NSQL' + CONVERT(NCHAR(5),@n_Err)
                            + ': INSERT INTO ORDERDETAIL Table Failed. (msp_BEJ_XDockCreateSO01)'
                
                GOTO QUIT_SP
            END
        END
    /* INSERT_ORDERDETAIL_TABLE: END (AYD) */
    /* UPDATE_CONSIGNEE: Updating the Consignee table START (AYD) */
        IF @n_continue IN (1,2) 
        BEGIN
            DECLARE CUR_ORD CURSOR LOCAL FAST_FORWARD READ_ONLY FOR
            SELECT DISTINCT 
            Storerkey, ConsigneeKey, C_Contact1, C_Address1, C_Address2, C_Address3
            FROM #TMP_ORD
        
            OPEN CUR_ORD
        
            FETCH NEXT FROM CUR_ORD INTO @c_StorerKey, @c_ConsigneeKey, @c_C_Contact1, @c_C_Address1, @c_C_Address2, @c_C_Address3
        
            WHILE @@FETCH_STATUS <> -1 AND @n_continue IN(1,2)
            BEGIN      	
                IF EXISTS (SELECT 1 FROM StorerConfig sc WITH(NOLOCK) WHERE sc.StorerKey = @c_StorerKey AND sc.ConfigKey = 'UpdStorer4Xdock' AND sc.SValue = '1')
                BEGIN
                    IF EXISTS (SELECT 1 FROM Storer s WITH(NOLOCK) WHERE s.StorerKey = @c_ConsigneeKey AND s.[Type] = '2')
                    BEGIN
                        UPDATE Storer WITH(ROWLOCK) SET 
                        Company      = @c_C_Contact1,
                        Address1     = @c_C_Address1,
                        Address2     = @c_C_Address2,
                        Address3     = @c_C_Address3,
                        ConsigneeFor = @c_StorerKey
                        WHERE StorerKey = @c_ConsigneeKey AND [Type] = '2'
                    END
                    ELSE 
                    BEGIN
                        INSERT INTO STORER 
                        (Storerkey, Type, Company, 
                        Address1, Address2, Address3, ConsigneeFor) 
                        VALUES 
                        (@c_ConsigneeKey, '2', @c_C_Contact1,  
                        @c_C_Address1,  @c_C_Address2, @c_C_Address3, @c_StorerKey) 
                    END
                    IF @@ERROR <> 0 
                    BEGIN
                        SET @n_Continue = 3
                        SET @n_Err = 68030
                        SET @c_ErrMsg = 'NSQL' + CONVERT(NCHAR(5),@n_Err)
                                    + ': UPDATE Storer Table Failed. (msp_BEJ_XDockCreateSO01)'
                        CLOSE CUR_ORD
                        DEALLOCATE CUR_ORD 
                        GOTO QUIT_SP
                    END
                END   
                
                FETCH NEXT FROM CUR_ORD INTO @c_StorerKey, @c_ConsigneeKey, @c_C_Contact1, @c_C_Address1, @c_C_Address2, @c_C_Address3
            END
            CLOSE CUR_ORD
            DEALLOCATE CUR_ORD               	
        END
    /* UPDATE_CONSIGNEE: Updating the Consignee table END (AYD) */
    
    QUIT_SP:
        IF OBJECT_ID('tempdb..#TMP_ORD') IS NOT NULL DROP TABLE #TMP_ORD
        IF OBJECT_ID('tempdb..#TMP_ORDDTL') IS NOT NULL DROP TABLE #TMP_ORDDTL
        IF @n_continue = 3
        BEGIN
            SET @b_Success = 0
            IF @@TRANCOUNT = 1 AND @@TRANCOUNT > @n_StartTranCount
            BEGIN
                ROLLBACK TRAN
            END
            ELSE
            BEGIN
                WHILE @@TRANCOUNT > @n_StartTranCount
                BEGIN
                    COMMIT TRAN
                END
            END
            RAISERROR (@c_ErrMsg, 16, 1) WITH SETERROR
        END
        ELSE
        BEGIN
            SET @b_Success = 1
            WHILE @@TRANCOUNT > @n_StartTranCount
            BEGIN
                COMMIT TRAN
            END
        END
END
GO
