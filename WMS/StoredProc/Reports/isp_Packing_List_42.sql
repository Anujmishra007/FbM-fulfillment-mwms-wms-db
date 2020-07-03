IF EXISTS (SELECT Name FROM dbo.sysobjects WHERE Name = 'isp_Packing_List_42' AND Type = 'P')
   DROP PROC isp_Packing_List_42  
GO
SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO 
/************************************************************************/
/* Stored Proc: isp_Packing_List_42                                     */
/* Creation Date: 04-MAY-2018                                           */
/* Copyright: LF Logistics                                              */
/* Written by: CSCHONG                                                  */
/*                                                                      */
/* Purpose: WMS-4868 - CN doTERRA _Packing list                         */
/*        :                                                             */
/* Called By: r_dw_packing_list_42                                      */
/*          :                                                           */
/* PVCS Version: 1.0                                                    */
/*                                                                      */
/* Version: 7.0                                                         */
/*                                                                      */
/* Data Modifications:                                                  */
/*                                                                      */
/* Updates:                                                             */
/* Date        Author   Ver   Purposes                                  */
/* 04/09/2018  NJOW01   1.0   WMS-6152 Add orders.notes                 */
/* 14/12/2018  WLCHOOI  1.1   WMS-7277 Combine G6 and G7,               */
/*                            add more text to G6, Remove G7  (WL01)    */
/* 28-Jan-2019  TLTING_ext 1.2  enlarge externorderkey field length     */
/*11/03/2019  CSCHONG   1.3   Fix EcomPacking Print issue CCS           */
/*10/06/2019  WLCHOOI   1.4   WMS-9371 - Add New Fields (WL02)          */
/*18/12/2019  WLChooi   1.5   WMS-11444 - Limit SKU per page (WL03)     */
/*20/02/2020  WLChooi   1.6   WMS-12107 - Modify column logic (WL01)    */
/*05/05/2020  CSCHONG   1.7   WMS-12994 - modify column logic (CS02)    */
/*02/07/2020  WLChooi   1.8   Bug Fix (WL05)                            */
/************************************************************************/
CREATE PROC isp_Packing_List_42
            (@c_Orderkey NVARCHAR(10),
             @c_labelno  NVARCHAR(20) = '')    
AS
BEGIN
   SET NOCOUNT ON
   SET ANSI_NULLS OFF
   SET QUOTED_IDENTIFIER OFF
   SET CONCAT_NULL_YIELDS_NULL OFF

   DECLARE  
           @n_StartTCnt       INT
         , @n_Continue        INT 
         , @c_isOrdKey        NVARCHAR(5)
         , @c_getOrdKey       NVARCHAR(20) 
         , @n_CntRec          INT               --CCS
         , @n_MaxLine         INT = 8 --WL03 
         , @c_ODNotes2        NVARCHAR(500)   --CS02
         , @c_DelimiterSign   NVARCHAR(5)     --CS02
         , @c_ordudf05        NVARCHAR(20)    --CS02
         , @c_ordudf02        NVARCHAR(20)    --CS02
         , @c_ordudf01        NVARCHAR(20)    --CS02
         , @c_ordudf10        NVARCHAR(20)    --CS02
         , @c_ordudf06        NVARCHAR(20)    --CS02
         , @n_OHInvAmt        FLOAT           --CS02
         , @c_ordudf03        NVARCHAR(20)    --CS02
         , @c_ExtConsoOrdKey  NVARCHAR(30)    --CS02
         , @c_GetCSOrdkey     NVARCHAR(20)    --CS02
         , @c_getsku          NVARCHAR(20)    --CS02
         , @n_SeqNo           INT             --CS02
         , @c_ColValue        NVARCHAR(70)    --CS02 


   SET @n_StartTCnt = @@TRANCOUNT
   SET @n_Continue = 1
   SET @c_DelimiterSign = '|'              --CS02

   WHILE @@TRANCOUNT > 0
   BEGIN
      COMMIT TRAN
   END
   
   
   CREATE TABLE #TEMPPACKLIST42(
   ID               INT IDENTITY(1,1) NOT NULL,
   Contact1         NVARCHAR(30)   NULL,
   c_addresses      NVARCHAR(200)   NULL,
   C_Phone1         NVARCHAR(18)   NULL,
   C_Phone2         NVARCHAR(18)   NULL,
   OHNotes2         NVARCHAR(200)  NULL,
   MCompany         NVARCHAR(45)   NULL,
   ExternOrderKey   NVARCHAR(50)   NULL,  --tlting_ext
   Salesman         NVARCHAR(30)   NULL,
   ORDDate          DATETIME       NULL,
   OHGRP            NVARCHAR(20)   NULL,
   ODNotes          NVARCHAR(200)  NULL,
   ordudef01        NVARCHAR(20)   NULL,
   orddetudef01     NVARCHAR(150)   NULL,
   SKU              NVARCHAR(20)   NULL,
   ODQty            INT            NULL,
   ODUnitPrice      FLOAT          NULL,
   ordudef05        NVARCHAR(30)   NULL,
   ordudef02        NVARCHAR(30)   NULL,
   ordudef06        FLOAT          NULL,
   ordudef10        NVARCHAR(30)   NULL,
   Orderkey         NVARCHAR(20)   NULL,
   ordudef03        NVARCHAR(30)   NULL,
   OHInvAmt         FLOAT          NULL, 
   orddetudef02     NVARCHAR(30)   NULL,
   orddetudef05     NVARCHAR(30)   NULL,
   orddetudef06     NVARCHAR(30)   NULL,
   orddetudef08     NVARCHAR(30)   NULL,
   orddetudef09     FLOAT   NULL,
   OHNotes          NVARCHAR(500)  NULL,  --NJOW01
   A1               NVARCHAR(200)  NULL,
   A2               NVARCHAR(200)  NULL,
   A3               NVARCHAR(200)  NULL,
   A4               NVARCHAR(200)  NULL,
   A5               NVARCHAR(200)  NULL,
   A6               NVARCHAR(200)  NULL,
   A7               NVARCHAR(200)  NULL,
   A8               NVARCHAR(200)  NULL,
   A9               NVARCHAR(200)  NULL,
   A10              NVARCHAR(200)  NULL,
   A11              NVARCHAR(200)  NULL,
   A12              NVARCHAR(200)  NULL,
   A14              NVARCHAR(200)  NULL, --NJOW01
   B2               NVARCHAR(200)  NULL,
   C1               NVARCHAR(200)  NULL,
   C2               NVARCHAR(200)  NULL,
   C3               NVARCHAR(200)  NULL,
   C4               NVARCHAR(200)  NULL,
   C5               NVARCHAR(200)  NULL,
   C6               NVARCHAR(200)  NULL,
   C7               NVARCHAR(200)  NULL,
   E1               NVARCHAR(200)  NULL,
   E2               NVARCHAR(200)  NULL,
   E3               NVARCHAR(200)  NULL,
   E4               NVARCHAR(200)  NULL,
   E5               NVARCHAR(200)  NULL,
   E6               NVARCHAR(200)  NULL,
   E7               NVARCHAR(200)  NULL,
   E8               NVARCHAR(200)  NULL,
   E9               NVARCHAR(200)  NULL,
   G1               NVARCHAR(200)  NULL,
   G2               NVARCHAR(200)  NULL,
   G3               NVARCHAR(200)  NULL,
   G4               NVARCHAR(200)  NULL,
   G5               NVARCHAR(200)  NULL,
   G6               NVARCHAR(400)  NULL,
   --G7               NVARCHAR(200)  NULL,  --WL01
   G8               NVARCHAR(200)  NULL,  
   G9               NVARCHAR(200)  NULL, --WL02 
   G10              NVARCHAR(200)  NULL, --WL02 
   A15              NVARCHAR(200)  NULL, --CS02
   ExtrnPOKEY       NVARCHAR(20)   NULL, --CS02
   ExtrnConsoOrdKey NVARCHAR(30)   NULL  --CS02
   )
   
   
    CREATE TABLE #TEMP_ORDERKEY42
    ( 
     OrderKey    NVARCHAR(10)   NOT NULL
    )

       IF EXISTS (SELECT 1 FROM ORDERS WITH (NOLOCK)
              WHERE Orderkey = @c_Orderkey)
      BEGIN
         INSERT INTO #TEMP_ORDERKEY42 (ORDERKEY)
         VALUES( @c_Orderkey)
      
         SET @c_isOrdKey = '1'
      END
                 
      ELSE IF EXISTS (SELECT 1 FROM PickDetail WITH (NOLOCK)
              WHERE PickDetail.PickSlipNo = @c_Orderkey)
      BEGIN
      INSERT INTO #TEMP_ORDERKEY42 (ORDERKEY)                                 
      SELECT DISTINCT OrderKey
      FROM PickDetail AS PD WITH (NOLOCK)
      WHERE PD.PickSlipNo=@c_Orderkey
         
      END   
      ELSE IF EXISTS (SELECT 1 FROM LOADPLANDETAIL WITH (NOLOCK)
              WHERE LOADPLANDETAIL.LOADKEY = @c_Orderkey)
      BEGIN
      INSERT INTO #TEMP_ORDERKEY42 (ORDERKEY)
      SELECT DISTINCT OrderKey
      FROM LOADPLANDETAIL AS LPD WITH (NOLOCK)
      WHERE LPD.LOADKEY=@c_Orderkey
      
      END
      ELSE IF EXISTS (SELECT 1 FROM Packheader WITH (NOLOCK)    --CCS Start
              WHERE Packheader.PickSlipNo = @c_Orderkey)  
      BEGIN  
      SET @n_CntRec = 0

      SELECT @n_CntRec = COUNT(1)
      FROM #TEMP_ORDERKEY42 (nolock)

      -- select '1',@n_CntRec '@n_CntRec'
         IF @n_CntRec = 0
         BEGIN
            INSERT INTO #TEMP_ORDERKEY42 (ORDERKEY)             
            SELECT DISTINCT OrderKey  
            FROM Packheader AS PD WITH (NOLOCK)  
            WHERE PD.PickSlipNo=@c_Orderkey    
         END 
      END             --CCS END
      
    DECLARE CUR_ORDKEY CURSOR LOCAL FAST_FORWARD READ_ONLY FOR
      SELECT Orderkey
      FROM #TEMP_ORDERKEY42
      ORDER BY Orderkey

     OPEN CUR_ORDKEY

      FETCH NEXT FROM CUR_ORDKEY INTO @c_getOrdKey
      WHILE @@FETCH_STATUS = 0
      BEGIN
            INSERT INTO #TEMPPACKLIST42
            (
               -- ID -- this column value is auto-generated
               Contact1,
               c_addresses,
               C_Phone1,
               C_Phone2,
               OHNotes2,
               MCompany,
               ExternOrderKey,
               salesman,
               ORDDate,
               OHGRP,
               ODNotes,
               ordudef01,
               orddetudef01,
               SKU,
               ODQty,
               ODUnitPrice,
               ordudef05,
               ordudef02,
               ordudef06,
               ordudef10,
               Orderkey,
               ordudef03,
               OHInvAmt,
               orddetudef02,
               orddetudef05,
               orddetudef06,
               orddetudef08,
               orddetudef09,
               OHNotes, --NJOW01
               A1,
               A2,
               A3,
               A4,
               A5,
               A6,
               A7,
               A8,
               A9,
               A10,
               A11,
               A12,
               A14, --NJOW01
               B2,
               C1,
               C2,
               C3,
               C4,
               C5,
               C6,
               C7,
               E1,
               E2,
               E3,
               E4,
               E5,
               E6,
               E7,
               E8,
               E9,
               G1,
               G2,
               G3,
               G4,
               G5,
               G6,
               --G7,  -WL01
               G8,
               G9,  --WL02
               G10, --WL02
               A15,              --CS02
               ExtrnPOKEY,       --CS02
               ExtrnConsoOrdKey  --CS02   
            )
   
            SELECT  Contact1   =  ISNULL(RTRIM(o.c_Contact1), '')
              ,   c_addresses = ( ISNULL(RTRIM(o.c_state), '')+ ISNULL(RTRIM(o.c_city), '') + ISNULL(RTRIM(o.c_Address1), '') 
                             +  ISNULL(RTRIM(o.c_Address2), '') +  ISNULL(RTRIM(o.c_Address3), '') +  ISNULL(RTRIM(o.c_Address4), '') )
              ,   C_Phone1    = ISNULL(RTRIM(O.C_Phone1), '') 
              ,   C_Phone2    = ISNULL(RTRIM(O.C_Phone2), '') 
              ,   OHNotes2    = ISNULL(RTRIM(O.c_company), '') 
              ,   MCompany    =  ISNULL(RTRIM(O.m_Company), '')
              ,   ExternOrderKey = ISNULL(RTRIM(o.ExternOrderkey), '') 
              ,   Salesman       =  ISNULL(RTRIM(o.Salesman), '')                                
              ,   ORDDate        =  CASE WHEN ISDATE(OD.userdefine10) = 1 AND ISNULL(OD.userdefine10,'') <> '' AND ISNULL(OD.externconsoorderkey,'') <> ''
                                    THEN CAST(OD.userdefine10 as DATETIME) ELSE O.Orderdate END         --CS02
              ,   OHGRP          =  CASE WHEN ISNULL(OD.userdefine03,'') <> '' AND ISNULL(OD.externconsoorderkey,'') <> '' THEN OD.userdefine03
                                    ELSE ISNULL(RTRIM(o.PmtTerm), '') END               --CS02                        
              ,   ODNotes        =  ISNULL(RTRIM(OD.notes), '')                            
              ,   ordudef01      = ISNULL(RTRIM(O.userdefine02), '')                            
              --,   orddetudef01   = ISNULL(RTRIM(S.notes1), '')--ISNULL(RTRIM(OD.userdefine01), '')    
              ,   orddetudef01   = ISNULL(LTRIM(RTRIM(S.DESCR)), '') + ' ' + ISNULL(LTRIM(RTRIM(S.notes1)), '')   --WL04                    
              ,   SKU            = OD.Sku
              ,   ODQty          = sum(OD.originalQty)                       
              ,   ODUnitPrice    = (OD.Unitprice) 
              ,   ordudef05      = ISNULL(RTRIM(OI.orderinfo03), '')
              ,   ordudef02      = ISNULL(RTRIM(OI.orderinfo01), '')
              ,   ordudef06      = ISNULL(RTRIM(OI.orderinfo04), '')
              ,   ordudef10      = ISNULL(RTRIM(O.userdefine10), '')
              ,   Orderkey       = O.Orderkey 
              ,   ordudef03      = ISNULL(RTRIM(OI.orderinfo02), '')
              ,   OHInvAmt       = O.invoiceamount
              ,   orddetudef02   = ISNULL(RTRIM(OD.userdefine02), '')     
              ,   orddetudef05   = ISNULL(RTRIM(OD.userdefine05), '')
              ,   orddetudef06   = CASE WHEN ISNULL(RTRIM(OD.userdefine06), '') <> '' THEN CAST(ISNULL(RTRIM(OD.userdefine06), '0.00') AS DECIMAL(10,2)) 
                                   ELSE '0.00' END --CS02
              ,   orddetudef08   = ISNULL(RTRIM(OD.userdefine08), '')
              ,   orddetudef09   = CASE WHEN ISNULL(RTRIM(OD.userdefine09), '') <> '' THEN CAST(ISNULL(RTRIM(OD.userdefine09), '0.00') AS DECIMAL(10,2)) 
                                   ELSE '0.00' END --CS02                 
              ,   OHNotes        = ISNULL(RTRIM(O.Notes), '')   --NJOW01                     
              ,   A1 = lbl.A1                                   
              ,   A2 = lbl.A2
              ,   A3 = lbl.A3
              ,   A4 = lbl.A4
              ,   A5 = lbl.A5
              ,   A6 = lbl.A6
              ,   A7 = lbl.A7
              ,   A8 = lbl.A8
              ,   A9 = lbl.A9
              ,   A10 = lbl.A10
              ,   A11 = lbl.A11
              ,   A12 = lbl.A12
              ,   A14 = lbl.A14 --NJOW01
              ,   B2 = lbl.B2
              ,   C1 = lbl.C1
              ,   C2 = lbl.C2
              ,   C3 = lbl.C3
              ,   C4 = lbl.C4
              ,   C5 = lbl.C5
              ,   C6 = lbl.C6 
              ,   C7 = lbl.C7
              ,   E1 = lbl.E1
              ,   E2 = lbl.E2
              ,   E3 = lbl.E3
              ,   E4 = lbl.E4
              ,   E5 = lbl.E5 
              ,   E6 = lbl.E6
              ,   E7 = lbl.E7
              ,   E8 = lbl.E8   
              ,   E9 = lbl.E9     
              ,   G1 = lbl.G1
              ,   G2 = lbl.G2 
              ,   G3 = lbl.G3  
              ,   G4 = lbl.G4      
              ,   G5 = lbl.G5
              ,   G6 = lbl.G6
              --,   G7 = lbl.G7 --WL01
              ,   G8 = lbl.G8
              ,   G9 = lbl.G9    --WL02
              ,   G10 = lbl.G10  --WL02
              ,   A15 = lbl.A15  --CS02
              ,   ExtPOKEY = O.ExternPOKEy --CS02
              ,   ExtConsoOrdkey = OD.ExternConsoOrderkey --CS02
            FROM ORDERS     O  WITH (NOLOCK)
            JOIN ORDERDETAIL OD WITH (NOLOCK) ON OD.OrderKey=O.OrderKey
            LEFT JOIN ORDERINFO OI WITH (NOLOCK) ON OI.OrderKey=O.OrderKey 
            JOIN STORER     ST WITH (NOLOCK) ON (ST.StorerKey = O.Storerkey)
            JOIN SKU         S WITH (NOLOCK) ON (S.Storerkey = OD.Storerkey)
                                             AND(S.Sku = OD.Sku)
            LEFT JOIN STORER C WITH (NOLOCK) ON (C.StorerKey = O.storerkey)
            LEFT JOIN fnc_PackingList42 (@c_getOrdKey) lbl ON (lbl.orderkey = O.Orderkey)
            WHERE  O.Orderkey = @c_getOrdKey 
         -- AND convert(float,OD.userdefine07) > '0.00'
            AND OD.userdefine04 in ('0','1')
            GROUP BY O.Orderkey 
                 ,ISNULL(RTRIM(o.c_Contact1), '')
                 ,( ISNULL(RTRIM(o.c_state), '')+ ISNULL(RTRIM(o.c_city), '') + ISNULL(RTRIM(o.c_Address1), '') 
                 +  ISNULL(RTRIM(o.c_Address2), '') +  ISNULL(RTRIM(o.c_Address3), '') +  ISNULL(RTRIM(o.c_Address4), '') )
                 ,ISNULL(RTRIM(O.C_Phone1), '')  ,ISNULL(RTRIM(O.C_Phone2), '') 
                 ,ISNULL(RTRIM(O.c_company), '') 
                 ,ISNULL(RTRIM(O.m_Company), ''),ISNULL(RTRIM(o.ExternOrderkey), '') 
                 ,ISNULL(RTRIM(O.Salesman), '')
                 --,O.Orderdate                --CS02
                 ,CASE WHEN ISDATE(OD.userdefine10) = 1 AND ISNULL(OD.userdefine10,'') <> '' AND ISNULL(OD.externconsoorderkey,'') <> ''
                                    THEN CAST(OD.userdefine10 as DATETIME) ELSE O.Orderdate END                      --CS02
                 --,ISNULL(RTRIM(o.PmtTerm), '')    --CS02 
                 ,CASE WHEN ISNULL(OD.userdefine03,'') <> '' AND ISNULL(OD.externconsoorderkey,'') <> '' THEN OD.userdefine03
                                    ELSE ISNULL(RTRIM(o.PmtTerm), '') END               --CS02      
                 ,ISNULL(RTRIM(OD.notes), '')        
                 ,ISNULL(RTRIM(O.userdefine02), '') --, ISNULL(RTRIM(S.notes1), '')--ISNULL(RTRIM(OD.userdefine01), '')   
                 ,ISNULL(LTRIM(RTRIM(S.DESCR)), '') + ' ' + ISNULL(LTRIM(RTRIM(S.notes1)), '')   --WL04
                 ,OD.Sku
                 ,OD.Unitprice
                 ,ISNULL(RTRIM(OI.orderinfo03), '')
                 ,ISNULL(RTRIM(OI.orderinfo01), '')
                 ,ISNULL(RTRIM(OI.orderinfo04), '')
                 ,ISNULL(RTRIM(O.userdefine10), '')
                 ,ISNULL(RTRIM(OI.orderinfo02), '')
                 ,O.invoiceamount
                 ,ISNULL(RTRIM(OD.userdefine02), '')   
                 ,ISNULL(RTRIM(OD.userdefine05), '')   
                 ,CASE WHEN ISNULL(RTRIM(OD.userdefine06), '') <> '' THEN CAST(ISNULL(RTRIM(OD.userdefine06), '0.00') AS DECIMAL(10,2)) ELSE '0.00' END    --CS02
                 ,ISNULL(RTRIM(OD.userdefine08), '')   
                 ,CASE WHEN ISNULL(RTRIM(OD.userdefine09), '') <> '' THEN CAST(ISNULL(RTRIM(OD.userdefine09), '0.00') AS DECIMAL(10,2)) ELSE '0.00' END     --CS02
                 ,ISNULL(RTRIM(O.Notes), '')   --NJOW01
                 ,lbl.A1
                 ,lbl.A2
                 ,lbl.A3
                 ,lbl.A4
                 ,lbl.A5
                 ,lbl.A6
                 ,lbl.A7
                 ,lbl.A8
                 ,lbl.A9
                 ,lbl.A10
                 ,lbl.A11
                 ,lbl.A12
                 ,lbl.A14 --NJOW01
                 ,lbl.B2
                 ,lbl.C1
                 ,lbl.C2
                 ,lbl.C3
                 ,lbl.C4
                 ,lbl.C5
                 ,lbl.C6
                 ,lbl.C7
                 ,lbl.E1
                 ,lbl.E2
                 ,lbl.E3
                 ,lbl.E4
                 ,lbl.E5
                 ,lbl.E6
                 ,lbl.E7
                 ,lbl.E8
                 ,lbl.E9
                 ,lbl.G1 
                 ,lbl.G2
                 ,lbl.G3
                 ,lbl.G4
                 ,lbl.G5
                 ,lbl.G6
                -- ,lbl.G7 --WL01
                 ,lbl.G8     
                 ,lbl.G9  --WL02
                 ,lbl.G10 --WL02
                 ,lbl.A15  --CS02
                 ,O.ExternPOKEy --CS02
                 ,OD.ExternConsoOrderkey --CS02
       
      FETCH NEXT FROM CUR_ORDKEY INTO @c_getOrdKey
      END
/*CS02 START*/
 DECLARE CUR_ExtConsoORDKEY CURSOR LOCAL FAST_FORWARD READ_ONLY FOR
      SELECT Orderkey,sku,ExtrnConsoOrdKey
      FROM #TEMPPACKLIST42
      WHERE ISNULL(ExtrnConsoOrdKey,'') <> ''
      ORDER BY Orderkey,sku,ExtrnConsoOrdKey

     OPEN CUR_ExtConsoORDKEY

      FETCH NEXT FROM CUR_ExtConsoORDKEY INTO @c_GetCSOrdkey,@c_getsku,@c_extconsoordkey
      WHILE @@FETCH_STATUS = 0
      BEGIN

          SET    @c_ordudf05  = ''
          SET    @c_ordudf02  = ''
          SET    @c_ordudf01  = ''
          SET    @c_ordudf10  = ''
          SET    @c_ordudf06  = ''
          SET    @n_OHInvAmt  = 0
          SET    @c_ordudf03  = ''
          SET    @c_ODNotes2 = ''

          SELECT @c_ODNotes2 = OD.notes2
          FROM ORDERDETAIL OD (nolock)
          where OD.orderkey = @c_GetCSOrdkey
          AND OD.ExternConsoOrderKey = @c_extconsoordkey
          AND OD.sku =@c_getsku
        
   -- select @c_ODNotes2 '@c_ODNotes2'

       DECLARE C_DelimSplit CURSOR LOCAL FAST_FORWARD READ_ONLY FOR
	     SELECT SeqNo, ColValue 
         FROM dbo.fnc_DelimSplit(@c_DelimiterSign,@c_ODNotes2)

         OPEN C_DelimSplit
         FETCH NEXT FROM C_DelimSplit INTO @n_SeqNo, @c_ColValue

        WHILE (@@FETCH_STATUS=0) 
        BEGIN
           
            IF @n_SeqNo = 1
            BEGIN
              SET @c_ordudf05 = @c_ColValue
            END
            ELSE IF @n_SeqNo = 2
            BEGIN
              SET @c_ordudf02 = @c_ColValue
            END
            ELSE IF @n_SeqNo = 3
            BEGIN
              SET @c_ordudf01 = @c_ColValue
            END
            ELSE IF @n_SeqNo = 4
            BEGIN
              SET @c_ordudf10 = @c_ColValue
            END
            ELSE IF @n_SeqNo = 5
            BEGIN
              SET @c_ordudf06 = @c_ColValue
            END
            ELSE IF @n_SeqNo = 6
            BEGIN
              SET @n_OHInvAmt = CAST(@c_ColValue AS FLOAT)
            END
            ELSE IF @n_SeqNo = 7
            BEGIN
              SET @c_ordudf03 = @c_ColValue
            END    
       

         FETCH NEXT FROM C_DelimSplit INTO @n_SeqNo, @c_ColValue
         END -- WHILE (@@FETCH_STATUS <> -1) AND @n_Continue <> 3

         CLOSE C_DelimSplit
         DEALLOCATE C_DelimSplit
     

         UPDATE #TEMPPACKLIST42
         SET ordudef05 = @c_ordudf05
            ,ordudef02 = @c_ordudf02
            ,ordudef01 = @c_ordudf01
            ,ordudef10 = @c_ordudf10 
            ,ordudef06 = @c_ordudf06
            ,OHInvAmt = @n_OHInvAmt
            ,ordudef03 = @c_ordudf03
         WHERE Orderkey = @c_GetCSOrdkey 
         AND   SKU = @c_getsku
         AND ExtrnConsoOrdKey = @c_extconsoordkey
    
     FETCH NEXT FROM CUR_ExtConsoORDKEY INTO @c_GetCSOrdkey,@c_getsku,@c_extconsoordkey
     END

     CLOSE CUR_ExtConsoORDKEY
     DEALLOCATE CUR_ExtConsoORDKEY

/*CS02 END*/     
      SELECT
         t.Contact1,
         t.c_addresses,
         t.C_Phone1,
         t.C_Phone2,
         t.OHNotes2,
         t.MCompany,
         t.ExternOrderKey ,   
         t.Salesman,
         t.ORDDate,
         t.OHGRP,
         t.ODNotes,
         t.ordudef01,
         t.orddetudef01,
         t.SKU,
         t.ODQty,
         t.ODUnitPrice,
         t.ordudef05,
         t.ordudef02,
         t.ordudef06,
         t.ordudef10,
         t.Orderkey,
         t.ordudef03,
         t.OHInvAmt,
         t.orddetudef02,
         t.orddetudef05,
         t.orddetudef06,
         t.orddetudef08,
         t.orddetudef09,
         t.ohnotes, --NJOW01
         t.A1,
         t.A2,
         t.A3,
         t.A4,
         t.A5,
         t.A6,
         t.A7,
         t.A8,
         t.A9,
         t.A10,
         t.A11,
         t.A12,
         t.A14,  --NJOW01
         t.B2,
         t.C1,
         t.C2,
         t.C3,
         t.C4,
         t.C5,
         t.C6,
         t.C7,
         t.E1,
         t.E2,
         t.E3,
         t.E4,
         t.E5,
         t.E6,
         t.E7,
         t.E8,
         t.E9,
         t.G1,
         t.G2,
         t.G3,
         t.G4,
         t.G5,
         t.G6,
      --t.G7, --WL01
         t.G8,
         t.G9, --WL02
         t.G10, --WL02
         (Row_Number() OVER (PARTITION BY ExtrnConsoOrdKey, Orderkey Order By ExtrnConsoOrdKey, Orderkey Asc) ) / @n_MaxLine AS PageNo --WL03  --CS02   --WL05
        ,t.A15                   --CS02
        ,t.ExtrnPOKEY            --CS02
        ,t.ExtrnConsoOrdKey      --CS02
      FROM
         #TEMPPACKLIST42 AS t
      ORDER BY orderkey

   WHILE @@TRANCOUNT < @n_StartTCnt
   BEGIN
      BEGIN TRAN
   END

END -- procedure

GO
GRANT EXECUTE ON isp_Packing_List_42 TO NSQL
GO   

