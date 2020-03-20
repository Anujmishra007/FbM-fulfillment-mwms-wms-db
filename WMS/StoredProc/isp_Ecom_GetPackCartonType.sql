IF EXISTS ( SELECT * FROM dbo.sysobjects WHERE  id = OBJECT_ID(N'[dbo].[isp_Ecom_GetPackCartonType]') 
AND OBJECTPROPERTY(id ,N'IsProcedure') = 1 ) 
DROP PROCEDURE [dbo].[isp_Ecom_GetPackCartonType]
GO

SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

/************************************************************************/  
/* Trigger: isp_Ecom_GetPackCartonType                                  */  
/* Creation Date: 27-APR-2016                                           */  
/* Copyright: LF Logistics                                              */  
/* Written by: YTWan                                                    */  
/*                                                                      */  
/* Purpose: SOS#361901 - New ECOM Packing                               */  
/*        :                                                             */  
/* Called By:  d_dw_ecom_packcartontype                                 */  
/*          :                                                           */  
/* PVCS Version: 1.0                                                    */  
/*                                                                      */  
/* Version: 7.0                                                         */  
/*                                                                      */  
/* Data Modifications:                                                  */  
/*                                                                      */  
/* Updates:                                                             */  
/* Date        Author   Ver   Purposes                                  */  
/* 01-JUN-2017 Wan01    1.1   WMS-1816 - CN_DYSON_Exceed_ECOM PACKING   */  
/* 24-APR-2017 Wan02    1.2   WMS-4628 - [CR] DYSON - ECOM Packing      */   
/* 02-JAN-2019 WLCHOOI  1.3   WMS-7418 - CN IKEA Ecom Packing CR (WL01) */ 
/************************************************************************/  
CREATE PROC isp_Ecom_GetPackCartonType   
         @c_Facility    NVARCHAR(5)  
      ,  @c_Storerkey   NVARCHAR(15)  
      ,  @c_CartonType  NVARCHAR(10) = ''   
      ,  @c_CartonGroup NVARCHAR(10) = '' --(Wan01)  
      ,  @c_PickSlipNo  NVARCHAR(10) = '' --(Wan02)  
      ,  @n_CartonNo    INT          = 0  --(Wan02)  
AS  
BEGIN  
   SET NOCOUNT ON  
   SET ANSI_NULLS OFF  
   SET QUOTED_IDENTIFIER OFF  
   SET CONCAT_NULL_YIELDS_NULL OFF  
  
   DECLARE   
--           @c_CartonGroup  NVARCHAR(10) --(Wan01)  
           @n_StartTCnt    INT            --(Wan01)  
         , @b_Success      INT  
         , @n_err          INT               
         , @c_errmsg       NVARCHAR(250)   
  
         , @c_ConfigKey    NVARCHAR(30)  
         , @c_authority    NVARCHAR(30)      
         , @c_Option1      NVARCHAR(50)     
         , @c_Option2      NVARCHAR(50)    
         , @c_Option3      NVARCHAR(50)  
         , @c_Option4      NVARCHAR(50)   
         , @c_Option5      NVARCHAR(4000)  
  
         , @c_Sql          NVARCHAR(4000)  
         , @c_SqlWhere     NVARCHAR(4000)  
  
         , @c_SPCode       NVARCHAR(100)  --(Wan02)  
  
   --(Wan01) - START  
   SET @n_StartTCnt = @@TRANCOUNT  
  
   WHILE @@TRANCOUNT > 0   
   BEGIN      
      COMMIT TRAN  
   END  
   --SET @c_CartonGroup= ''  
   --(Wan01) - END                    
   SET @c_SqlWhere = ''  
    
   IF ISNULL(RTRIM(@c_ConfigKey),'') = '' BEGIN SET @c_ConfigKey  =  'CtnTypeInput' END  
   SET @c_CartonType = ISNULL(RTRIM(@c_CartonType),'')  
  
   IF @c_CartonGroup= ''                     --(Wan01)  
   BEGIN                                     --(Wan01)  
      SELECT @c_CartonGroup = RTRIM(CartonGroup)  
      FROM STORER WITH (NOLOCK)  
      WHERE Storerkey = @c_Storerkey  
   END                                       --(Wan01)  
  
  
   SET @c_ConfigKey = 'CtnTypeInput'  
   SET @b_Success = 1  
   SET @n_err     = 0  
   SET @c_errmsg  = ''  
   SET @c_Option1 = ''  
   SET @c_Option2 = ''  
   SET @c_Option3 = ''  
   SET @c_Option4 = ''  
   SET @c_Option5 = ''  
  
   EXEC nspGetRight    
         @c_Facility             
      ,  @c_StorerKey               
      ,  ''         
      ,  @c_ConfigKey               
      ,  @b_Success    OUTPUT     
      ,  @c_authority  OUTPUT    
      ,  @n_err        OUTPUT    
      ,  @c_errmsg     OUTPUT  
      ,  @c_Option1    OUTPUT   
      ,  @c_Option2    OUTPUT  
      ,  @c_Option3    OUTPUT  
      ,  @c_Option4    OUTPUT  
      ,  @c_Option5    OUTPUT  
  
   IF @b_Success <> 1   
   BEGIN   
      GOTO QUIT_SP  
   END  
  
   SET @c_SqlWhere = @c_Option5   
  
   IF @c_CartonType <> '' AND @c_SqlWhere = ''  
   BEGIN  
      SET @c_ConfigKey = 'DefaultCtnType'  
      SET @b_Success = 1  
      SET @n_err     = 0  
      SET @c_errmsg  = ''  
      SET @c_Option1 = ''  
      SET @c_Option2 = ''  
      SET @c_Option3 = ''  
      SET @c_Option4 = ''  
      SET @c_Option5 = ''  
  
      EXEC nspGetRight    
            @c_Facility             
         ,  @c_StorerKey               
         ,  ''         
         ,  @c_ConfigKey               
         ,  @b_Success    OUTPUT     
         ,  @c_authority  OUTPUT    
         ,  @n_err        OUTPUT    
         ,  @c_errmsg     OUTPUT  
         ,  @c_Option1    OUTPUT   
         ,  @c_Option2    OUTPUT  
         ,  @c_Option3    OUTPUT  
         ,  @c_Option4    OUTPUT  
         ,  @c_Option5    OUTPUT  
  
      IF @b_Success <> 1   
      BEGIN   
         GOTO QUIT_SP  
      END  
  
      IF NOT EXISTS (   SELECT 1   
                        FROM CODELKUP WITH (NOLOCK) WHERE ListName = @c_Option1  
                    )  
      BEGIN  
         SET @c_Option5 = ''  
      END  
         
      SET @c_SqlWhere = @c_Option5  
   END  
  
   --(Wan02) - START  
   SET @c_SPCode = ''  
   SELECT @c_SPCode = ISNULL(RTRIM(CL.Long),'')  
   FROM CODELKUP CL WITH (NOLOCK)  
   WHERE CL.ListName  = 'CTNTypMeas'  
   AND   CL.Code      = @c_CartonType  
   AND   CL.Storerkey = @c_Storerkey  
  
   IF ISNULL(RTRIM(@c_SPCode),'') = ''  
   BEGIN    
      GOTO QUIT_SP           
   END  
  
   IF EXISTS (SELECT 1 FROM dbo.sysobjects WHERE name = RTRIM(@c_SPCode) AND type = 'P')  
   BEGIN  
      CREATE TABLE #TMP_CTNTYPMEAS                                
           (                                                           
              SeqNo             INT            IDENTITY(1,1)           
           ,  CartonizationKey  NVARCHAR(10)   NOT NULL DEFAULT('')    
           ,  CartonType        NVARCHAR(10)   NOT NULL DEFAULT('')    
           ,  Cube              FLOAT          NOT NULL DEFAULT(0.00)  
           ,  MaxWeight         FLOAT          NOT NULL DEFAULT(0.00)  
           ,  MaxCount          FLOAT          NOT NULL DEFAULT(0.00)  
           ,  CartonWeight      FLOAT          NOT NULL DEFAULT(0.00)  
           ,  CartonLength      FLOAT          NOT NULL DEFAULT(0.00)  
           ,  CartonWidth       FLOAT          NOT NULL DEFAULT(0.00)  
           ,  CartonHeight      FLOAT          NOT NULL DEFAULT(0.00)  
           )           
     
      SET @c_SQL = 'EXEC ' + @c_SPCode +  ' @c_CartonGroup= @c_CartonGroup'  
                                       +  ',@c_CartonType = @c_CartonType'  
                                       +  ',@c_PickSlipNo = @c_PickSlipNo'  
                                       +  ',@n_CartonNo   = @n_CartonNo'  
      EXEC sp_executesql @c_SQL   
         ,  N' @c_CartonGroup NVARCHAR(10)  
             , @c_CartonType  NVARCHAR(10)   
             , @c_PickSlipNo  NVARCHAR(10)  
             , @n_CartonNo    INT'  
         ,  @c_CartonGroup  
         ,  @c_CartonType  
         ,  @c_PickSlipNo  
         ,  @n_CartonNo     
  
      SELECT  CartonizationKey    
           ,  CartonType          
           ,  Cube                
           ,  MaxWeight           
           ,  MaxCount            
           ,  CartonWeight        
           ,  CartonLength        
           ,  CartonWidth         
           ,  CartonHeight   
      FROM #TMP_CTNTYPMEAS  
  
      GOTO MEASURE_CUSTOM  
   END  
    
   --(Wan02) - END  
   QUIT_SP:  
  
   MEASURE_STD: --(Wan02)
   --(WL01): One line can only show 10 carton type, to show next 10 carton type, use mouse scrolling or keyboard up and down arrow button   
   SET @c_Sql = N'SELECT TOP 20'  --WL01
              + ' CartonizationKey'  
              + ', CartonType'  
              + ', Cube      = ISNULL(Cube,0)'  
              + ', MaxWeight = ISNULL(MaxWeight,0)'  
              + ', MaxCount  = ISNULL(MaxCount,0)'  
              + ', CartonWeight = ISNULL(CartonWeight,0)'  
              + ', CartonLength = ISNULL(CartonLength,0)'  
              + ', CartonWidth  = ISNULL(CartonWidth,0)'  
              + ', CartonHeight = ISNULL(CartonHeight,0)'  
              + ' FROM CARTONIZATION WITH (NOLOCK)'  
              + ' WHERE CartonizationGroup = N''' + RTRIM(@c_CartonGroup) + ''''  
              + ' AND  (CartonType = N''' + @c_CartonType + ''' OR ''' + @c_CartonType + '''='''') '  
              + @c_SqlWhere  
              + ' ORDER BY UseSequence'  
  
   EXEC ( @c_Sql )  
  
   --(Wan02) - START  
   MEASURE_CUSTOM:  
  
   IF OBJECT_ID('tempdb..#TMP_CTNTYPMEAS','U') IS NOT NULL  
   BEGIN  
      DROP TABLE #TMP_CTNTYPMEAS;  
   END  
   --(Wan02) - END  
  
   --(Wan01) - START  
   WHILE @@TRANCOUNT < @n_StartTCnt   
   BEGIN      
      BEGIN TRAN  
   END  
   --(Wan01) - END   
END -- procedure  
GO
GRANT EXECUTE ON [dbo].[isp_Ecom_GetPackCartonType] TO nSQL 
GO
