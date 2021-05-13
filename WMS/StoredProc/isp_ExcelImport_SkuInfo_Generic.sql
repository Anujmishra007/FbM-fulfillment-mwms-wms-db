IF EXISTS ( SELECT * FROM dbo.sysobjects WHERE  id = OBJECT_ID(N'[dbo].[isp_ExcelImport_SkuInfo_Generic]') 
AND OBJECTPROPERTY(id ,N'IsProcedure') = 1 ) 
DROP PROCEDURE [dbo].[isp_ExcelImport_SkuInfo_Generic]
GO

SET ANSI_NULLS OFF
GO

SET QUOTED_IDENTIFIER OFF
GO

/*****************************************************************************************/        
/* Stored Procedure:   isp_ExcelImport_SkuInfo_Generic                                   */        
/* Creation Date:                                                                        */        
/* Copyright: IDS                                                                        */        
/* Written by: kelvinongcy                                                               */        
/*                                                                                       */        
/* Purpose:  New Data import into WMS SkuInfo via Web Excel Loader Management            */        
/*                                                                                       */        
/* Updates:      Author ver   Purpose                                                    */      
/* 18-Nov-2019   kocy   1.0   https://jiralfl.atlassian.net/browse/WMS-10941             */      
/*                            New Data import into SkuInfo for Storerkey -'PVHQHW'       */       
/*                            via Web Excel Loader Management                            */       
/* 05-08-2020    kocy   1.1   New requirement Sku. Style(a) + '_'Sku.Busr1(b)            */      
/*                            = Newtable.Style_Busr1(a_b)]                               */      
/*                            when busr1 is empty, the style is a when style is empty,   */      
/*                            then Busr1 is _b.                                          */      
/* 19-01-2021    kocy    1.2  https://jiralfl.atlassian.net/browse/WMS-16078             */      
/*                            New Data import into SkuInfo for Storerkey -'PVHSZ'        */      
/*                            via Web Excel Loader Management                            */ 
/* 03-05-2021    kocy    1.3  revised script try prevent mutliple sku info inserted      */ 
/*                             based style_busr1                                         */
/*****************************************************************************************/      
CREATE PROCEDURE [dbo].[isp_ExcelImport_SkuInfo_Generic]      
(      
   @c_StorerKey nvarchar(15)      
  ,@b_debug  bit = 0      
)      
AS      
BEGIN          
   SET NOCOUNT ON             
   SET ANSI_NULLS OFF        
   SET QUOTED_IDENTIFIER OFF             
   SET CONCAT_NULL_YIELDS_NULL OFF            
              
   DECLARE @d_EffectiveDate      nvarchar(15)      
         , @c_Status             nvarchar(5)      
         , @c_Style_Busr1        nvarchar(20)    
         , @c_SKU                nvarchar(20)  
         , @n_starttcnt          INT      
         , @n_continue           INT      
         , @b_success            INT      
         , @n_Err                INT      
         , @c_ErrMsg             NVARCHAR(255)      
         , @c_Delete             NVARCHAR(5)    
         , @c_Exist              NVARCHAR(5)  
      
   SELECT  @n_starttcnt=@@TRANCOUNT,@n_continue=1 , @b_success=0, @n_err=0, @c_errmsg=''       
   SELECT  @c_Status = '0', @c_Delete = 'Y'      
  
  IF ISNULL(OBJECT_ID('tempdb..#temp_STG'), '') <> ''                      
   BEGIN                      
      DROP TABLE #temp_STG                    
   END  

  CREATE TABLE #temp_STG ( 
   StorerKey   NVARCHAR(15), 
   Style_Busr1 NVARCHAR(20), 
   Sku         nvarchar(20), 
   [Status]    nvarchar(5) 
  )
  
   -- if exist record's EffectiveDate match to today then delete the old batch records     
   IF EXISTS ( SELECT 1 FROM [DTS].[ExcelImport_DTS_WMS_SKUINFO] WITH (NOLOCK)   
               WHERE StorerKey = @c_StorerKey  
               AND EffectiveDate = FORMAT(GETDATE(), 'yyyy-MM-dd')  AND @c_Delete = 'Y')  
   BEGIN      
         DELETE si FROM [dbo].[SKUINFO] si    
         INNER JOIN SKU sku (NOLOCK) ON sku.StorerKey = si.StorerKey AND sku.SKU = si.SKU  
         WHERE si.StorerKey = @c_StorerKey   
   END      
             
   DECLARE CUR_RETRIEVED_Style_Busr1 CURSOR LOCAL FAST_FORWARD READ_ONLY FOR      
   SELECT stg.Style_Busr1 , ISNULL (sku.SKU, ''),  
          CASE WHEN EXISTS ( SELECT 1    
                             FROM dbo.SKU sku WITH (NOLOCK) WHERE sku.StorerKey = stg.StorerKey  AND  
                            ( ( ISNULL(LTRIM(RTRIM(Style)), '') + CASE WHEN ISNULL(LTRIM(RTRIM(Busr1)), '')  <> '' THEN '_' + LTRIM(RTRIM(Busr1)) ELSE '' END ) = stg.Style_Busr1 )  
                   ) THEN '1' ELSe '0' END AS n_Exist  
   FROM  [DTS].[ExcelImport_DTS_WMS_SKUINFO] stg  WITH (NOLOCK)    -- synonyms table   
     
   LEFT OUTER JOIN dbo.SKU sku WITH (NOLOCK) ON sku.StorerKey = stg.StorerKey  AND  
   ( ( ISNULL(LTRIM(RTRIM(Style)), '') + CASE WHEN ISNULL(LTRIM(RTRIM(Busr1)), '')  <> '' THEN '_' + LTRIM(RTRIM(Busr1)) ELSE '' END ) = stg.Style_Busr1 )  
   WHERE stg.StorerKey = @c_StorerKey   --'PVHQHW' 'PVHSZ'   
   AND stg.Flag = 'Y'      
   AND stg.[Status] = '0'    
   AND stg.EffectiveDate = FORMAT(GETDATE(), 'yyyy-MM-dd')    
   --AND stg.Style_Busr1 IN ('J308363', 'J308364')  
  
   OPEN CUR_RETRIEVED_Style_Busr1      
   FETCH NEXT FROM CUR_RETRIEVED_Style_Busr1 INTO @c_Style_Busr1 , @c_SKu ,@c_Exist  
   WHILE @@FETCH_STATUS = 0      
   BEGIN   
     
      BEGIN TRAN  
          
         IF (@c_Exist = '1')  
         BEGIN  
            SET @c_Status = '9'           
        
            INSERT INTO [dbo].[SKUINFO] (StorerKey, SKU)       
            SELECT StorerKey, SKU      
            FROM  [dbo].[SKU] WITH (NOLOCK)       
            WHERE StorerKey = @c_StorerKey  
            AND SKu = @c_Sku              
         END  
         ELSE  
         BEGIN  
           SET @c_Status = '5'  
         END  

         INSERT INTO #temp_STG SELECT @c_StorerKey, @c_Style_Busr1, @c_Sku, @c_Status 
        
         IF @@ROWCOUNT = 0 OR @@ERROR <> 0                                   
         BEGIN                                    
            ROLLBACK TRAN                                          
            GOTO QUIT                    
         END   
  
         WHILE @@TRANCOUNT > 0      
         COMMIT TRAN   
               
      FETCH NEXT FROM CUR_RETRIEVED_Style_Busr1 INTO @c_Style_Busr1, @c_SKu, @c_Exist  
   END      
   CLOSE CUR_RETRIEVED_Style_Busr1      
   DEALLOCATE CUR_RETRIEVED_Style_Busr1     
   
      BEGIN TRAN
      -- update status based Style_Busr1 existance
      UPDATE tgt 
      SET tgt.Status = src.Status
      FROM [DTS].[ExcelImport_DTS_WMS_SKUINFO] tgt WITH (NOLOCK)
      JOIN
      ( SELECT StorerKey, Style_Busr1  , Status
        FROM #temp_STG  GROUP BY StorerKey, Style_Busr1, Status
      ) src ON src.StorerKey = tgt.StorerKey AND src.Style_Busr1 = tgt.Style_Busr1
         
      IF @@ROWCOUNT = 0 OR @@ERROR <> 0                                   
      BEGIN                                    
         ROLLBACK TRAN                                          
         GOTO QUIT                    
      END   
  
      WHILE @@TRANCOUNT > 0      
      COMMIT TRAN

      IF @b_debug = 1
      BEGIN
        SELECT tgt.StorerKey, tgt.Style_Busr1, src.Sku, src.Status
        FROM [DTS].[ExcelImport_DTS_WMS_SKUINFO] tgt WITH (NOLOCK)
        JOIN
        ( SELECT StorerKey, Style_Busr1, Sku, Status
          FROM #temp_STG  GROUP BY StorerKey, Style_Busr1, Sku, Status
        ) src ON src.StorerKey = tgt.StorerKey AND src.Style_Busr1 = tgt.Style_Busr1
      END

      
    QUIT:                      
   IF CURSOR_STATUS('LOCAL' , 'CUR_RETRIEVED_Style_Busr1') in (0 , 1)                   
   OR @n_continue = 3                
   BEGIN                      
      CLOSE CUR_RETRIEVED_Style_Busr1                       
      DEALLOCATE CUR_RETRIEVED_Style_Busr1                         
   END  
      
END --SP
GO


