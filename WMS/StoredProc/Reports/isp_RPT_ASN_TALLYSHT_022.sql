SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO

/************************************************************************/    
/* Stored Procedure: isp_RPT_ASN_TALLYSHT_022                           */    
/* Creation Date: 31-OCT-2022                                           */    
/* Copyright: LF Logistics                                              */    
/* Written by: WZPang                                                   */    
/*                                                                      */    
/* Purpose: WMS-21048 - BSJ Tally Sheet									*/    
/*                                                                      */    
/* Called By: RPT_ASN_TALLYSHT_022                                      */    
/*                                                                      */    
/* GitLab Version: 1.0                                                  */    
/*                                                                      */    
/* Version: 5.4                                                         */    
/*                                                                      */    
/* Data Modifications:                                                  */    
/*                                                                      */    
/* Updates:                                                             */    
/* Date         Author  Ver   Purposes                                  */
/************************************************************************/    
CREATE OR ALTER PROC [dbo].[isp_RPT_ASN_TALLYSHT_022](    
            @c_Receiptkey     NVARCHAR(10)    
   )    
	AS    
	BEGIN    
	   SET NOCOUNT ON    
	   SET ANSI_NULLS OFF    
	   SET QUOTED_IDENTIFIER OFF    
	   SET CONCAT_NULL_YIELDS_NULL OFF    
	    
	   DECLARE @uccno NVARCHAR(10)    
	   SELECT  @UCCNO =COUNT(DISTINCT(UCCNO)) FROM ucc WHERE receiptkey = @c_Receiptkey    
	    
	  IF  @UCCNO <1    
	  BEGIN    
	        
	   SELECT RECEIPT.ReceiptKey   
			, RECEIPT.ExternReceiptKey AS ExternReceiptkey      
			, RECEIPT.ReceiptDate AS ReceiptDate      
			, RECEIPT.Storerkey AS Storerkey    
			, '' AS UCCNo      
			, '-' AS MixCarton      
			, RECEIPTDETAIL.SKU     
			, ISNULL(SKU.IVAS,'') AS IVAS     
			, RECEIPTDETAIL.QtyExpected AS  QtyExpected     
			, CASE WHEN RECEIPTDETAIL.QtyReceived ='0' THEN RECEIPTDETAIL.BeforeReceivedQty ELSE RECEIPTDETAIL.QtyReceived END AS QtyReceived      
			, CASE WHEN RECEIPTDETAIL.QtyReceived ='0' THEN RECEIPTDETAIL.BeforeReceivedQty ELSE RECEIPTDETAIL.QtyReceived END - RECEIPTDETAIL.QtyExpected AS VarianceQty 
			, SUM(RECEIPTDETAIL.QtyExpected) AS TotalExpectedQty
			, SUM(RECEIPTDETAIL.QtyReceived) AS TotalQtyReceived
			, SUM((CASE WHEN RECEIPTDETAIL.QtyReceived ='0' THEN RECEIPTDETAIL.BeforeReceivedQty ELSE RECEIPTDETAIL.QtyReceived END) - RECEIPTDETAIL.QtyExpected ) AS TotalVarianceQty      
			, CASE WHEN RECEIPT.ProcessType = 'F' THEN 'Fully Inspection'   WHEN RECEIPT.ProcessType = 'P' Then 'Partial Inspection' ELSE '' END  AS ProcessType        
			, CODELKUP.Short    
			, RECEIPTDETAIL.ToId    
	   FROM RECEIPT (NOLOCK)          
	   JOIN RECEIPTDETAIL WITH (NOLOCK) ON (RECEIPT.ReceiptKey = RECEIPTDETAIL.Receiptkey)          
	   JOIN SKU WITH (NOLOCK) ON (SKU.SKU = RECEIPTDETAIL.SKU and SKU.Storerkey = RECEIPT.Storerkey )          
	   LEFT JOIN UCC WITH (NOLOCK) ON (SKU.SKU = UCC.SKU and SKU.StorerKey = UCC.Storerkey and ucc.ExternKey=receipt.ExternReceiptKey)         
	   LEFT JOIN CODELKUP WITH(NOLOCK) ON (CODELKUP.ListName = 'BSJPCate' AND CODELKUP.Long = SKU.skugroup         
	           AND CODELKUP.Storerkey = RECEIPT.StorerKey)      
	   WHERE Receipt.RECEIPTKEY = @c_Receiptkey    
	   GROUP BY RECEIPT.ReceiptKey      
			, RECEIPT.ExternReceiptKey      
			, RECEIPT.ReceiptDate      
			, RECEIPT.Storerkey     
			, RECEIPTDETAIL.Sku      
			, SKU.IVAS      
			, RECEIPTDETAIL.QtyExpected  
			, CASE WHEN RECEIPTDETAIL.QtyReceived ='0' THEN RECEIPTDETAIL.BeforeReceivedQty ELSE RECEIPTDETAIL.QtyReceived END   
			, (CASE WHEN RECEIPTDETAIL.QtyReceived ='0' THEN RECEIPTDETAIL.BeforeReceivedQty ELSE RECEIPTDETAIL.QtyReceived END - RECEIPTDETAIL.QtyExpected )      
			, CASE WHEN RECEIPT.ProcessType = 'F' THEN 'Fully Inspection' WHEN RECEIPT.ProcessType = 'P' Then 'Partial Inspection' ELSE '' END      
			, CODELKUP.Short    
			, RECEIPTDETAIL.ToId    
	   ORDER BY SKU.IVAS,UCCNo, Sku      
	   END    
	   ELSE   
	  BEGIN     
	  
	  DECLARE @n_SumUCC INT, @n_SumRD INT    
	  , @c_Storerkey NVARCHAR(20), @c_SKU NVARCHAR(20), @n_RemainingQty INT    
	  , @c_UCCNO NVARCHAR(50)    
	  SELECT TOP 1 @c_Storerkey = Storerkey FROM ucc WHERE receiptkey = @c_Receiptkey    
	
	      
	  DECLARE @T_RD TABLE (Storerkey NVARCHAR(15), SKU NVARCHAR(20), UCCNO NVARCHAR(50), QtyExpected INT, QtyReceived INT, VarianceQty INT, UCCStatus NVARCHAR(10), UCCUserdefined01  NVARCHAR(10), Id NVARCHAR(20))    
	      
	  INSERT INTO @T_RD    
	  --Full UCC Received    
	  SELECT RECEIPT.StorerKey    
	       , RECEIPTDETAIL.Sku    
	       , UCC.UCCNo    
	       , UCC.qty AS QtyExpected    
	       , UCC.qty AS QtyReceived    
	       , 0 AS VarianceQty    
	       , UCC.Status  
	       , UCC.Userdefined01  
	       , UCC.Id  
	  FROM RECEIPT (NOLOCK)    
	  JOIN RECEIPTDETAIL WITH (NOLOCK) ON (RECEIPT.ReceiptKey = RECEIPTDETAIL.ReceiptKey)    
	  JOIN SKU WITH (NOLOCK) ON (SKU.Sku = RECEIPTDETAIL.Sku AND SKU.StorerKey = RECEIPT.StorerKey)    
	  JOIN UCC WITH (NOLOCK) ON (   SKU.Sku = UCC.SKU    
	                            AND SKU.StorerKey = UCC.Storerkey    
	                            AND UCC.ExternKey = RECEIPT.ExternReceiptKey    
	                            AND UCC.Status = '1'    
	                            AND UCC.ReceiptLineNumber = RECEIPTDETAIL.ReceiptLineNumber)    
	  LEFT JOIN CODELKUP WITH (NOLOCK) ON (   CODELKUP.LISTNAME = 'BSJPCate'    
	                                      AND CODELKUP.Long = SKU.SKUGROUP    
	                                      AND CODELKUP.Storerkey = RECEIPT.StorerKey)    
	  WHERE RECEIPT.ReceiptKey = @c_Receiptkey    
	  GROUP BY RECEIPT.StorerKey    
	         , RECEIPTDETAIL.Sku    
	         , UCC.UCCNo    
	         , RECEIPT.ExternReceiptKey    
	         , UCC.qty    
	         , UCC.Status   
	         , UCC.UserDefined01  
	         , UCC.Id  
	  UNION ALL    
	  SELECT RECEIPT.StorerKey    
	       , RECEIPTDETAIL.Sku    
	       , UCC.UCCNo    
	       , ISNULL(UCC.qty,'0') AS QtyExpected    
	       , 0 AS QtyReceived    
	       , UCC.qty * -1 AS VarianceQty    
	       , UCC.Status  
		   , UCC.Userdefined01  
		   , UCC.Id  
	  FROM RECEIPT (NOLOCK)    
	  JOIN RECEIPTDETAIL WITH (NOLOCK) ON (RECEIPT.ReceiptKey = RECEIPTDETAIL.ReceiptKey)    
	  JOIN SKU WITH (NOLOCK) ON (SKU.Sku = RECEIPTDETAIL.Sku AND SKU.StorerKey = RECEIPT.StorerKey)    
	  JOIN UCC WITH (NOLOCK) ON (   SKU.Sku = UCC.SKU    
	                            AND SKU.StorerKey = UCC.Storerkey    
	                            AND UCC.ExternKey = RECEIPT.ExternReceiptKey    
	                            AND UCC.Status = '0'    
	                            AND UCC.ReceiptLineNumber = RECEIPTDETAIL.ReceiptLineNumber)    
	  LEFT JOIN CODELKUP WITH (NOLOCK) ON (   CODELKUP.LISTNAME = 'BSJPCate'    
	                                      AND CODELKUP.Long = SKU.SKUGROUP    
	                                      AND CODELKUP.Storerkey = RECEIPT.StorerKey)    
	  WHERE RECEIPT.ReceiptKey = @c_Receiptkey     
	  GROUP BY RECEIPT.StorerKey    
	         , RECEIPTDETAIL.Sku    
	         , UCC.UCCNo    
	         , RECEIPT.ExternReceiptKey    
	         , UCC.qty    
	         , UCC.Status   
			 , UCC.UserDefined01   
			 , UCC.Id  
	  ORDER BY [Status] DESC    
	         , UCCNo ASC    
	         , SKU ASC    
	      
	  DECLARE CUR_SKU CURSOR LOCAL FAST_FORWARD READ_ONLY FOR    
	  SELECT Storerkey, SKU, SUM(BeforeReceivedQty)    
	  FROM RECEIPTDETAIL RD (NOLOCK)    
	  WHERE RD.ReceiptKey = @c_Receiptkey     
	  AND RD.StorerKey = @c_Storerkey
	  GROUP BY Storerkey, SKU    
	      
	  OPEN CUR_SKU    
	      
	  FETCH NEXT FROM CUR_SKU INTO @c_Storerkey, @c_SKU, @n_SumRD    
	      
	  WHILE @@FETCH_STATUS <> -1    
	  BEGIN    
	     SET @c_UCCNO = ''    
	     SET @n_SumUCC = 0    
	     SET @n_RemainingQty = 0    
	      
	     SELECT @n_SumUCC = SUM(UCC.Qty)    
	     FROM UCC (NOLOCK)    
	     WHERE UCC.Storerkey = @c_Storerkey    
	     AND UCC.SKU = @c_SKU    
	     AND UCC.Receiptkey = @c_Receiptkey    
	     AND UCC.Status = '1'    
	         
	     SET @n_RemainingQty = @n_SumRD - @n_SumUCC    
	      
	      
	     IF @n_RemainingQty > 0    
	     BEGIN    
	        SELECT TOP 1 @c_UCCNO = UCCNo  
	        FROM @T_RD    
	        WHERE Storerkey = @c_Storerkey    
	        AND SKU = @c_SKU    
	        AND UCCStatus = '0'    
	  ORDER BY QtyExpected  
	      
	        UPDATE @T_RD    
	        SET QtyReceived = @n_RemainingQty, VarianceQty = @n_RemainingQty - QtyExpected    
	        WHERE UCCNO = @c_UCCNO    
	        AND Storerkey = @c_Storerkey    
	        AND SKU = @c_SKU    
	  
	  IF EXISTS (  
	  select 1 from  RECEIPTDETAIL A join @T_RD B    
	  on ( A.sku=B.sku AND A.ExternLineNo = B.UCCUserdefined01 AND B.QtyReceived = case when A.QtyReceived='0' then A.BeforeReceivedQty else A.QtyReceived end)  
	  where B.id='' AND A.ReceiptKey=@c_Receiptkey AND B.SKU = @c_SKU)  
	  BEGIN    
	   UPDATE B   
	   SET B.Id = A.ToId  
	   FROM  RECEIPTDETAIL A join @T_RD B    
	   ON ( A.sku=A.sku AND A.ExternLineNo = B.UCCUserdefined01 AND B.QtyReceived = case when A.QtyReceived='0' then A.BeforeReceivedQty else A.QtyReceived end)  
	   WHERE B.id='' AND A.ReceiptKey=@c_Receiptkey AND B.SKU = @c_SKU  
	  END  
	  ELSE BEGIN  
	    DELETE @T_RD where UCCNO =@c_UCCNO AND SKU = @c_SKU  
	    INSERT INTO @T_RD    
	    SELECT @c_Storerkey, @c_SKU,@c_UCCNO, B.QtyExpected AS QtyExpected, case when B.QtyReceived='0' then B.BeforeReceivedQty else B.QtyReceived end AS QtyReceived,   
	    (case when B.QtyReceived='0' then B.BeforeReceivedQty else B.QtyReceived end - B.QtyExpected ) AS VarianceQty, A.UCCStatus, A.UCCUserdefined01, B.toId  
	    from @T_RD A Join receiptdetail B on (A.sku=B.sku AND B.ExternLineNo = A.UCCUserdefined01 )  
	    where B.SKU=@c_SKU and isnull(b.DuplicateFrom,'')<>''  
	  END  
	    
	     END    
	      
	     FETCH NEXT FROM CUR_SKU INTO @c_Storerkey, @c_SKU, @n_SumRD    
	  END    
	  CLOSE CUR_SKU    
	  DEALLOCATE CUR_SKU     
	  
	 SELECT RECEIPT.ReceiptKey   
	   , RECEIPT.ExternReceiptKey AS ExternReceiptkey      
	   , RECEIPT.ReceiptDate AS ReceiptDate      
	   , RECEIPT.Storerkey AS Storerkey    
	   , UCC.UCCNo AS UCCNo      
	   , (SELECT  ISNULL(CAST(COUNT(U.SKU) AS NVARCHAR),'') FROM UCC U(NOLOCK) WHERE U.Externkey = Receipt.Externreceiptkey and UCC.UCCNO = U.UCCNO) AS MixCarton      
	   , UCC.SKU     
	   , ISNULL(SKU.IVAS,'') AS IVAS     
	   , UCC.QtyExpected     
	   , UCC.QtyReceived      
	   , UCC.VarianceQty      
	   , SUM(UCC.QtyExpected) AS TotalExpectedQty      
	   , SUM(UCC.QtyReceived) AS TotalQtyReceived      
	   , SUM(UCC.VarianceQty) AS TotalVarianceQty      
	   , CASE WHEN RECEIPT.ProcessType = 'F' THEN 'Fully Inspection'   WHEN RECEIPT.ProcessType = 'P' Then 'Partial Inspection' ELSE '' END  AS ProcessType        
	   , CODELKUP.Short    
	   , UCC.Id AS ToId    
	   FROM RECEIPT (NOLOCK)          
	   JOIN RECEIPTDETAIL WITH (NOLOCK) ON (RECEIPT.ReceiptKey = RECEIPTDETAIL.Receiptkey)          
	   JOIN SKU WITH (NOLOCK) ON (SKU.SKU = RECEIPTDETAIL.SKU and SKU.Storerkey = RECEIPT.Storerkey )          
	   JOIN @T_RD UCC  ON (SKU.SKU = UCC.SKU and SKU.StorerKey = UCC.Storerkey and ucc.UCCUserdefined01=RECEIPTDETAIL.ExternLineNo)          
	   LEFT JOIN CODELKUP WITH(NOLOCK) ON (CODELKUP.ListName = 'BSJPCate' AND CODELKUP.Long = SKU.skugroup         
	           AND CODELKUP.Storerkey = RECEIPT.StorerKey)      
	   WHERE Receipt.RECEIPTKEY = @c_Receiptkey   
	   GROUP BY RECEIPT.ReceiptKey      
			, RECEIPT.ExternReceiptKey      
			, RECEIPT.ReceiptDate      
			, RECEIPT.Storerkey     
			, UCC.uccno    
			, UCC.Sku       
			, SKU.IVAS      
			, UCC.QtyExpected    
			, UCC.QtyReceived    
			, UCC.VarianceQty       
			, CASE WHEN RECEIPT.ProcessType = 'F' THEN 'Fully Inspection' WHEN RECEIPT.ProcessType = 'P' Then 'Partial Inspection' ELSE '' END      
			, CODELKUP.Short    
			, UCC.Id   
			, UCC.UCCUserdefined01  
	  ORDER BY SKU.IVAS,(select  ISNULL(CAST(COUNT(U.SKU) AS NVARCHAR),'') FROM UCC U(NOLOCK) WHERE U.Externkey = Receipt.Externreceiptkey and UCC.UCCNO = U.UCCNO),UCCNo, Sku      
        
END  
END -- procedure
GO
GRANT EXECUTE ON [dbo].[isp_RPT_ASN_TALLYSHT_022] TO nSQL 
GO
GRANT EXECUTE ON [dbo].[isp_RPT_ASN_TALLYSHT_022] TO JReportRole
GO