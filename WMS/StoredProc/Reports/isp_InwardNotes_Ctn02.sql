 if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[isp_InwardNotes_Ctn02]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
 drop procedure [dbo].[isp_InwardNotes_Ctn02]
 GO
 SET QUOTED_IDENTIFIER OFF 
 GO
 SET ANSI_NULLS OFF 
 GO
 
 /************************************************************************/
 /* Store Procedure: isp_InwardNotes_Ctn02                               */
 /* Creation Date: 08 May 2017                                           */
 /* Copyright: LF                                                        */
 /* Written by: CSCHONG                                                  */
 /*                                                                      */
 /* Purpose: WMS-1790 - Sort by lottable02                               */
 /*                                                                      */
 /* Called By:                                                           */
 /*                                                                      */
 /* PVCS Version: 1.1                                                    */
 /*                                                                      */
 /* Version: 5.4                                                         */
 /*                                                                      */
 /* Data Modifications:                                                  */
 /*                                                                      */
 /* Updates:                                                             */
 /* Date         Author    Ver.  Purposes                                */
 /* 29-MAY-2017  CSCHONG   1.0   WMS-1996 - new report config (CS01)     */
 /* 01-AUG-2017  CSCHONG   1.1   WMS-2454 - Add new report config (CS02) */
 /* 26-JUN-2017  CSCHONG   1.2   WMS-5388 - Add new report config (CS01) */
 /************************************************************************/
 
 CREATE PROC dbo.isp_InwardNotes_Ctn02 (@c_ReceiptKeyStart NVARCHAR(10)
                                        ,@c_ReceiptkeyEnd  NVARCHAR(10)
                                        ,@c_Storerkey     NVARCHAR(10))
  AS
  BEGIN
    SET NOCOUNT ON 
    SET ANSI_NULLS OFF
    SET QUOTED_IDENTIFIER OFF 
    SET CONCAT_NULL_YIELDS_NULL OFF
    
     DECLARE @c_pickheaderkey  NVARCHAR(10),
       @n_continue         		int,
       @c_errmsg           		NVARCHAR(255),
       @b_success          		int,
       @n_err              		int,
       @n_pickslips_required	INT,
       @n_SortBySkuLoc         INT   --CS01     
 
     CREATE TABLE #InwardNotesCtn02
        ( Company             NVARCHAR(45),
          ReceiptKey          NVARCHAR(20) NULL,
          CarrierReference    NVARCHAR(18) NULL,
          StorerKey           NVARCHAR(15) NULL,
          CarrierName         NVARCHAR(30) NULL,
          AddWho              NVARCHAR(18) NULL,
          ReceiptDate         DATETIME NULL, 
          Sku                 NVARCHAR(20)  NULL, 
          Lottable02          NVARCHAR(18) NULL,
          DESCR               NVARCHAR(60) NULL,
          Lottable04          DATETIME NULL,
          UOM					   NVARCHAR(10) NULL,
          QtyExp              int,
          QtyRec              int,
          STDCUBE             FLOAT,
          RECNOTES            NVARCHAR(60) NULL,
          CarrierAddress1     NVARCHAR(45) NULL,
          POkey               NVARCHAR(18) NULL,
          CaseCnt             INT,
          Lottable03          NVARCHAR(18) NULL,
          RHSignatory         NVARCHAR(18) NULL,
          Userdefine01        NVARCHAR(30) NULL,
          Facility            NVARCHAR(15) NULL,
          Externreceiptkey    NVARCHAR(20) NULL,  
          lottable01          NVARCHAR(18) NULL,     
          Containerkey        NVARCHAR(18) NULL,		
 			 conditiondesc  	   NVARCHAR(250) NULL,		
          containertype       NVARCHAR(250) NULL,     
          Signatory           NVARCHAR(30) NULL, 
          SortByLOTT02        INT        NULL,
          ShowLot15           INT NULL,
          Lottable15          DATETIME NULL,          --CS01    
          SortByLOTT01       INT      NULL,           --CS02
			 Showlogo           INT )            --CS03
                          
         
    
    
    SELECT Storerkey,
           SortByLOTT02  = ISNULL(MAX(CASE WHEN Code = 'SORTBYLOTT02'  THEN 1 ELSE 0 END),0)
           ,ShowLot15    =  ISNULL(MAX(CASE WHEN Code = 'SHOWLOT15'  THEN 1 ELSE 0 END),0)    --CS01
           ,SortByLOTT01  = ISNULL(MAX(CASE WHEN Code = 'SORTBYLOTT01'  THEN 1 ELSE 0 END),0) --CS02
			  ,Showlogo     = ISNULL(MAX(CASE WHEN Code = 'SHOWLOGO'  THEN 1 ELSE 0 END),0) --CS03
    INTO #TMP_RPTCFG
    FROM CODELKUP WITH (NOLOCK)
    WHERE ListName = 'REPORTCFG'
    AND Long      = 'r_dw_goods_inward_notes_ctn02'
    AND (Short IS NULL OR Short <> 'N')
    GROUP BY Storerkey
                   
                          
        INSERT INTO #InwardNotesCtn02
             ( Company,             ReceiptKey,            CarrierReference,            StorerKey,
              CarrierName,          AddWho,         ReceiptDate,
              Sku,          Lottable02,          DESCR,           Lottable04,
              UOM,              QtyExp,              QtyRec,
              STDCUBE,             RECNOTES,              CarrierAddress1,
              POkey,            CaseCnt,      Lottable03,
              RHSignatory,                 Userdefine01,       Facility,        Externreceiptkey,
              lottable01,          Containerkey,       conditiondesc,       containertype,      
              Signatory,      SortByLOTT02,ShowLot15,Lottable15,SortByLOTT01,showlogo)         --CS01    --Cs02  --CS03
       SELECT STORER.Company,   
          RECEIPT.ReceiptKey,   
          ISNULL(RECEIPT.CarrierReference,''),   
          RECEIPT.StorerKey,   
          ISNULL(RECEIPT.CarrierName,''),   
          RECEIPT.AddWho,   
          RECEIPT.ReceiptDate,   
          RECEIPTDETAIL.Sku,   
          ISNULL(RECEIPTDETAIL.Lottable02,''),   
          SKU.DESCR,   
          RECEIPTDETAIL.Lottable04,   
          RECEIPTDETAIL.UOM,   
          SUM(RECEIPTDETAIL.QtyExpected) AS QtyExp,   
          SUM(RECEIPTDETAIL.QtyReceived) AS QtyRec,   
          SKU.STDCUBE, 
 			ISNULL(CONVERT(NVARCHAR(60), RECEIPT.NOTES),'') AS RECNOTES , 
 			ISNULL(RECEIPT.CarrierAddress1,''),
 			ISNULL(RECEIPT.POkey,''),
 			PACK.CaseCnt,
 			ISNULL(RECEIPTDETAIL.Lottable03,''),
          ISNULL(RECEIPT.Signatory,'') AS RHSignatory,
          ISNULL(RECEIPT.Userdefine01,''),
          RECEIPT.Facility,
          RECEIPTDETAIL.Externreceiptkey,
          ISNULL(RECEIPTDETAIL.lottable01,''),
          ISNULL(RECEIPT.Containerkey,''),
          (SELECT ISNULL(CODELKUP.Description,'') FROM CODELKUP (nolock) WHERE CODELKUP.listname='ASNREASON' AND CODELKUP.code = RECEIPTDETAIL.Conditioncode) AS conditiondesc,
          ISNULL((SELECT ISNULL(CODELKUP.Description,'') FROM CODELKUP (nolock) WHERE CODELKUP.listname='CONTAINERT' AND CODELKUP.code = RECEIPT.ContainerType),'') AS containertype
   			, Signatory = CASE WHEN ISNULL(RTRIM(ST.Contact2),'') = '' THEN 'LF Logistics' ELSE ST.Contact2 END
   			,SortByLOTT02 = ISNULL(#TMP_RPTCFG.SortByLOTT02,0)
   			,ShowLot15 = ISNULL(#TMP_RPTCFG.ShowLot15,0)                             --CS01
   			, RECEIPTDETAIL.Lottable15                                               --CS01
   			,SortByLOTT01 = ISNULL(#TMP_RPTCFG.SortByLOTT01,0)                       --CS02
				,showlogo = ISNULL(#TMP_RPTCFG.Showlogo,0)                               --CS03
     FROM RECEIPT 			WITH (nolock)   
     JOIN RECEIPTDETAIL 	WITH (nolock) 	ON ( RECEIPT.ReceiptKey = RECEIPTDETAIL.ReceiptKey )   
     JOIN STORER 			WITH (nolock)  ON ( RECEIPTDETAIL.StorerKey = STORER.StorerKey ) 
     JOIN SKU 				WITH (nolock)  ON ( RECEIPTDETAIL.StorerKey = SKU.StorerKey ) and  
          											( RECEIPTDETAIL.Sku = SKU.Sku )    
 	 JOIN PACK 				WITH (nolock)  ON ( SKU.PackKey = PACK.PackKey )
 	 LEFT JOIN STORER ST WITH (NOLOCK)  ON ( ST.Storerkey = 'IDS' )
 	 LEFT JOIN #TMP_RPTCFG WITH (NOLOCK) ON #TMP_RPTCFG.storerkey = RECEIPT.StorerKey
    WHERE ( RECEIPT.ReceiptKey >= @c_ReceiptKeyStart ) AND  
 		   ( REceipt.receiptkey <= @c_ReceiptKeyEnd) AND
 			( RECEIPT.Storerkey = @c_storerkey )
    GROUP BY STORER.Company,   
          RECEIPT.ReceiptKey,   
          RECEIPT.CarrierReference,   
          RECEIPT.StorerKey,   
          RECEIPT.CarrierName,   
          RECEIPT.AddWho,   
          RECEIPT.ReceiptDate,   
          RECEIPTDETAIL.Sku,   
          RECEIPTDETAIL.Lottable02,   
          SKU.DESCR,   
          RECEIPTDETAIL.Lottable04,   
          RECEIPTDETAIL.UOM,   
          SKU.STDCUBE, 
 			CONVERT(NVARCHAR(60), RECEIPT.NOTES) , 
 			RECEIPT.CarrierAddress1,
 			RECEIPT.POkey,
 			PACK.CaseCnt,
 			RECEIPTDETAIL.Lottable03,
          RECEIPT.Signatory,
          RECEIPT.Userdefine01,
          RECEIPT.Facility,
          RECEIPTDETAIL.Externreceiptkey,
          RECEIPTDETAIL.lottable01,
          RECEIPT.Containerkey,
 			RECEIPTDETAIL.Conditioncode,
 			RECEIPT.ContainerType,
 			CASE WHEN ISNULL(RTRIM(ST.Contact2),'') = '' THEN 'LF Logistics' ELSE ST.Contact2 END,
 			#TMP_RPTCFG.SortByLOTT02,ISNULL(#TMP_RPTCFG.ShowLot15,0), RECEIPTDETAIL.Lottable15          --CS01
 			,ISNULL(#TMP_RPTCFG.SortByLOTT01,0)                       --CS02
			,ISNULL(#TMP_RPTCFG.Showlogo,0)                           --CS03
         
    
      GOTO SUCCESS
   FAILURE:
      DELETE FROM #InwardNotesCtn02
   SUCCESS:
      SELECT * FROM #InwardNotesCtn02  
       --(CS01) - START
    ORDER BY CASE WHEN SortByLOTT02 = 1 THEN lottable02 ELSE '' END
          ,  CASE WHEN SortByLOTT01 = 1 THEN lottable01 ELSE '' END              --CS02
          ,  ReceiptKey
          ,  Sku
          ,  CASE WHEN SortByLOTT02 = 1 THEN '' ELSE lottable02 END 

      
      DROP Table #InwardNotesCtn02  
  END
 GO
 
 GRANT EXECUTE ON isp_InwardNotes_Ctn02 TO Nsql
 GO
 
