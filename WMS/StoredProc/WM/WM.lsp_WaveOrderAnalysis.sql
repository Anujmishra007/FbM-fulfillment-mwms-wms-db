IF EXISTS ( SELECT * FROM dbo.sysobjects WHERE  id = OBJECT_ID(N'[WM].[lsp_WaveOrderAnalysis]') 
AND OBJECTPROPERTY(id ,N'IsProcedure') = 1 ) 
DROP PROCEDURE [WM].[lsp_WaveOrderAnalysis] 
GO

SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO   
/************************************************************************/                                                                                  
/* Store Procedure: lsp_WaveOrderAnalysis                               */                                                                                  
/* Creation Date:                                                       */                                                                                  
/* Copyright: LFL                                                       */                                                                                  
/* Written by: Wan                                                      */                                                                                  
/*                                                                      */                                                                                  
/* Purpose: LFWM-1789 - SPs for Wave Release Screen -                   */
/*          ( Summary Tab - HomeScreen )                                */                                                                                  
/*                                                                      */                                                                                  
/* Called By: SCE                                                       */                                                                                  
/*          :                                                           */                                                                                  
/* PVCS Version: 1.0                                                    */                                                                                  
/*                                                                      */                                                                                  
/* Version: 8.0                                                         */                                                                                  
/*                                                                      */                                                                                  
/* Data Modifications:                                                  */                                                                                  
/*                                                                      */                                                                                  
/* Updates:                                                             */                                                                                  
/* Date        Author   Ver.  Purposes                                  */  
/* 28-Dec-2020 SWT01    1.0   Adding Begin Try/Catch                    */
/* 15-Jan-2021 Wan01    1.1   Execute Login if @c_UserName<>SUSER_SNAME()*/
/************************************************************************/                                                                                  
CREATE PROC [WM].[lsp_WaveOrderAnalysis]                                                                                                                     
      @c_Facility          NVARCHAR(5)                                                                                                                     
   ,  @c_StorerKey         NVARCHAR(15)  
   ,  @c_BuildParmGroup    NVARCHAR(30)  
   ,  @c_BuildParmKey      NVARCHAR(10) = ''
   ,  @n_SessionNo         BIGINT = 0   
   ,  @b_Success           INT = 1             OUTPUT  
   ,  @n_err               INT = 0             OUTPUT                                                                                                             
   ,  @c_ErrMsg            NVARCHAR(255)       OUTPUT               
   ,  @c_UserName          NVARCHAR(128)= ''                                                                                                                         
   ,  @d_debug             INT   = 0         --2020-07-10
AS  
BEGIN                                                                                                                                                        
   SET NOCOUNT ON                                                                                                                                           
   SET ANSI_NULLS OFF                                                                                                                                       
   SET QUOTED_IDENTIFIER OFF                                                                                                                                
   SET CONCAT_NULL_YIELDS_NULL OFF       

   DECLARE @n_NoOfAllocated   INT = 0
         , @n_NoOfPicked      INT = 0
         , @n_TotalBuild      INT = 0
         , @n_BuildOrders     INT = 0
         , @n_WavedOrders     INT = 0
         , @n_RemainOrders    INT = 0
         , @n_TotalOrders     INT = 0

         , @n_AllocPctg       DECIMAL(10,2) = 0.00
         , @n_WavedPctg       DECIMAL(10,2) = 0.00

         --, @c_BuildParmKey    NVARCHAR(10)   = ''
         , @c_AnalysisType    NVARCHAR(10)   = 'SUMMARY'
         , @c_GenByBuildValue NVARCHAR(1)    = 'N'

         , @n_FromPos         INT            = 0
         , @n_ToPos           INT            = 0
         , @n_HavingPos       INT            = 0
         , @n_GroupByPos      INT            = 0

         , @n_MaxOpenQty      INT            = 0   --2020-07-10 
         , @n_MaxOpenQty01    INT            = 0   --2020-07-10 
         , @n_MaxOpenQty02    INT            = 0   --2020-07-10
         , @n_MaxOpenQty03    INT            = 0   --2020-07-10
         , @n_MaxOpenQty04    INT            = 0   --2020-07-10
         , @n_MaxOpenQty05    INT            = 0   --2020-07-10

         , @c_SQL             NVARCHAR(4000) = ''
         , @c_SQLParms        NVARCHAR(250)  = ''
         , @c_SQLBuildWave    NVARCHAR(4000) = ''
         , @c_SQLHaving       NVARCHAR(1000) = ''

         , @CUR_PARMKEY       CURSOR

   DECLARE @t_WaveOrderAnalysis TABLE
         (  BuildParmKey      NVARCHAR(10)   NOT NULL DEFAULT('')
         ,  TotalBuild        INT            NOT NULL DEFAULT(0)
         ,  BuildOrders       INT            NOT NULL DEFAULT(0) 
         ,  WavedOrders       INT            NOT NULL DEFAULT(0) 
         ,  Allocated         INT            NOT NULL DEFAULT(0) 
         ,  Picked            INT            NOT NULL DEFAULT(0) 
         ,  RemainOrders      INT            NOT NULL DEFAULT(0)
         )

   SET @n_Err = 0  
   
   IF SUSER_SNAME() <> @c_UserName     --(Wan01) - START
   BEGIN 
      EXEC [WM].[lsp_SetUser]   
            @c_UserName = @c_UserName  OUTPUT  
         ,  @n_Err      = @n_Err       OUTPUT  
         ,  @c_ErrMsg   = @c_ErrMsg    OUTPUT  
         
      IF @n_Err <> 0   
      BEGIN
         GOTO EXIT_SP  
      END          
                  
      EXECUTE AS LOGIN = @c_UserName  
   END                                 --(Wan01) - END
   
   BEGIN TRY -- SWT01 - Begin Outer Begin Try
             --        
   IF OBJECT_ID('tempdb..#TMP_ORDERS','u') IS NULL  
   BEGIN                                                                                                                                      
      CREATE TABLE #TMP_ORDERS                                                                                                                                    
      (                                                                                                                                                           
         OrderKey NVARCHAR(10)   NULL                                                                               
      )   
   END 

   SET @c_BuildParmKey = ISNULL(RTRIM(@c_BuildParmKey),'')

   IF @c_BuildParmKey <> ''
   BEGIN
      SET @c_AnalysisType = 'BUILDKEY'
   END 

   SET @CUR_PARMKEY = CURSOR LOCAL FAST_FORWARD READ_ONLY FOR                                                                                         
   SELECT BP.BuildParmKey
   FROM   BUILDPARMGROUPCFG CFG WITH (NOLOCK)
   JOIN   BUILDPARM BP WITH (NOLOCK) ON (CFG.ParmGroup = BP.ParmGroup)                                                                                                                          
   WHERE  CFG.ParmGroup = @c_BuildParmGroup  
   AND    CFG.Storerkey = @c_Storerkey 
   AND   (CFG.Facility  = @c_Facility OR CFG.Facility = '')  
   AND   (BP.BuildParmKey = @c_BuildParmKey OR @c_BuildParmKey = '')
   AND    CFG.[Type] = 'BuildWaveParm'                                                                                                                       
   AND    BP.Active = '1'                                                                                                                       
   ORDER BY BP.BuildParmKey                                                                                                                                              
                                                                                                                                                            
   OPEN @CUR_PARMKEY                                                                                                                                    
                                                                                                                                                            
   FETCH NEXT FROM @CUR_PARMKEY INTO @c_BuildParmKey
                                                                         
   WHILE @@FETCH_STATUS <> -1                             
   BEGIN
      SET @n_TotalOrders = 0

      --2020-07-10 - START
      SELECT @n_MaxOpenQty01 = CASE WHEN BP.Restriction01 = '2_MaxQtyPerBuild' THEN BP.RestrictionValue01  ELSE 0 END
          ,  @n_MaxOpenQty02 = CASE WHEN BP.Restriction02 = '2_MaxQtyPerBuild' THEN BP.RestrictionValue02  ELSE 0 END
          ,  @n_MaxOpenQty03 = CASE WHEN BP.Restriction03 = '2_MaxQtyPerBuild' THEN BP.RestrictionValue03  ELSE 0 END
          ,  @n_MaxOpenQty04 = CASE WHEN BP.Restriction04 = '2_MaxQtyPerBuild' THEN BP.RestrictionValue04  ELSE 0 END
          ,  @n_MaxOpenQty05 = CASE WHEN BP.Restriction05 = '2_MaxQtyPerBuild' THEN BP.RestrictionValue05  ELSE 0 END
      FROM BUILDPARM BP WITH (NOLOCK)                                                                                                                                 
      WHERE BP.BuildParmKey = @c_BuildParmKey 

      SET @n_MaxOpenQty = @n_MaxOpenQty01

      IF @n_MaxOpenQty = 0
         SET @n_MaxOpenQty = @n_MaxOpenQty02
      IF @n_MaxOpenQty = 0
         SET @n_MaxOpenQty = @n_MaxOpenQty03
      IF @n_MaxOpenQty = 0
         SET @n_MaxOpenQty = @n_MaxOpenQty04
      IF @n_MaxOpenQty = 0
         SET @n_MaxOpenQty = @n_MaxOpenQty05
      --2020-07-10 - END

      GetBuildOrders:
      EXEC [WM].[lsp_Build_Wave]                                                                                                                       
            @c_BuildParmKey   = @c_BuildParmKey                                                                                                                 
         ,  @c_Facility       = @c_Facility                                                                                                                 
         ,  @c_StorerKey      = @c_StorerKey
         ,  @c_BuildWaveType  = 'ANALYSIS'
         ,  @c_GenByBuildValue= @c_GenByBuildValue             
         ,  @c_SQLBuildWave   = @c_SQLBuildWave OUTPUT                                  
         ,  @n_BatchNo        = 0
         ,  @b_Success        = @b_Success   OUTPUT  
         ,  @n_err            = @n_err       OUTPUT                                                                                                             
         ,  @c_ErrMsg         = @c_ErrMsg    OUTPUT 
         ,  @c_UserName       = @c_UserName           
    
      IF @b_Success = 1
      BEGIN
         SET @n_BuildOrders = 0
         SET @n_FromPos   = CHARINDEX('FROM ', @c_SQLBuildWave , 1)
         SET @n_HavingPos = CHARINDEX('HAVING', @c_SQLBuildWave, 1)
         SET @n_GroupByPos= CHARINDEX('GROUP BY', @c_SQLBuildWave, 1)

         IF @c_SQLHaving = 0
         BEGIN
            SET @n_ToPos = @n_GroupByPos - @n_FromPos 
            IF @n_GroupByPos = 0
            BEGIN
               SET @n_ToPos = LEN(@c_SQLBuildWave) - @n_FromPos + 1
            END
            SET @c_SQL  = N'SELECT @n_BuildOrders = COUNT(DISTINCT ORDERS.Orderkey) '
                        + SUBSTRING(@c_SQLBuildWave, @n_FromPos, @n_ToPos)
         END
         ELSE
         BEGIN
            SET @c_SQL  = N'SELECT @n_BuildOrders = COUNT(1) FROM ( SELECT ORDERS.Orderkey'
                        + ' ' + CHAR(13) + SUBSTRING(@c_SQLBuildWave, @n_FromPos, @n_GroupByPos - @n_FromPos)
                        + ' ' + CHAR(13) + 'GROUP BY ORDERS.Orderkey'
                        + ' ' + CHAR(13) + SUBSTRING(@c_SQLBuildWave, @n_HavingPos, LEN(@c_SQLBuildWave) - @n_HavingPos + 1)
                        + ' ) t' 
         END

         SET @c_SQLParms = N'@c_Facility     NVARCHAR(5)'
                         + ',@c_Storerkey    NVARCHAR(10)'
                         + ',@n_MaxOpenQty   INT'           --2020-07-10
                         + ',@n_BuildOrders  INT   OUTPUT'
 
   --print CAST(@n_BuildOrders AS NVARCHAR) + '=>' + @c_Facility + ' ' +  @c_buildparmkey + ' - ' + @c_SQL
         EXEC SP_EXECUTESQL
               @c_SQL
            ,  @c_SQLParms
            ,  @c_Facility
            ,  @c_Storerkey
            ,  @n_MaxOpenQty                                --2020-07-10
            ,  @n_BuildOrders  OUTPUT
      END

      SET @n_WavedOrders = 0
      SET @n_NoOfAllocated = 0
      SET @n_NoOfPicked= 0
      SET @n_RemainOrders= 0 

      IF @c_AnalysisType = 'SUMMARY'
      BEGIN
         SELECT @n_WavedOrders   = COUNT(DISTINCT OH.Orderkey)
               ,@n_NoOfAllocated = ISNULL(SUM(CASE WHEN OH.[Status] = '2' THEN 1 ELSE 0 END),0)
               ,@n_NoOfPicked    = ISNULL(SUM(CASE WHEN OH.[Status] = '5' THEN 1 ELSE 0 END),0)
         FROM BUILDWAVELOG BW WITH (NOLOCK)
         JOIN BUILDWAVEDETAILLOG BWD WITH (NOLOCK) ON (BW.BatchNo = BWD.BatchNo)
         JOIN WAVE WH WITH(NOLOCK) ON (BWD.Wavekey = WH.Wavekey)
         JOIN WAVEDETAIL WD WITH (NOLOCK) ON (WH.Wavekey = WD.Wavekey)
         JOIN ORDERS OH WITH (NOLOCK) ON (WD.Orderkey = OH.Orderkey)
         WHERE BW.Facility = @c_Facility
         AND BW.Storerkey = @c_Storerkey
         AND BW.BuildParmGroup = @c_BuildParmGroup
         AND BW.BuildParmKey   = @c_BuildParmKey
         AND OH.[Status] < '9'            --Fixed 2020-04-10 LFWM-2038
      END
      ELSE
      BEGIN
         --SELECT @n_TotalOrders = COUNT(1)         
         --FROM ORDERS OH WITH (NOLOCK)
         --WHERE OH.Facility = @c_Facility
         --AND OH.Storerkey = @c_Storerkey
         --AND OH.[Status] < '9'
         IF @c_GenByBuildValue = 'N' AND @n_BuildOrders > 0
         BEGIN
            SET @n_TotalOrders = @n_BuildOrders --@n_TotalOrders - @n_WavedOrders - @n_BuildOrders
            SET @c_GenByBuildValue = 'Y'
            GOTO GetBuildOrders
         END

         IF @n_SessionNo <> 0
         BEGIN
            SELECT @n_WavedOrders = COUNT(WD.Orderkey)
            FROM BUILDWAVELOG BW WITH (NOLOCK)
            JOIN BUILDWAVEDETAILLOG BWD WITH (NOLOCK) ON (BW.BatchNo = BWD.BatchNo)
            JOIN WAVEDETAIL WD WITH (NOLOCK) ON (BWD.Wavekey = WD.Wavekey)
            WHERE BW.SessionNo = @n_SessionNo
            AND BW.BuildParmKey   = @c_BuildParmKey
         END

         SET @n_RemainOrders = @n_TotalOrders - @n_BuildOrders
      END

      SET @n_TotalBuild = @n_BuildOrders + @n_WavedOrders

      INSERT INTO @t_WaveOrderAnalysis
         (  BuildParmKey 
         ,  TotalBuild        
         ,  BuildOrders      
         ,  WavedOrders        
         ,  Allocated    
         ,  Picked 
         ,  RemainOrders
         )      
      VALUES 
         (  @c_BuildParmKey
         ,  @n_TotalBuild 
         ,  @n_BuildOrders
         ,  @n_WavedOrders
         ,  @n_NoOfAllocated
         ,  @n_NoOfPicked
         ,  @n_RemainOrders
         )

      --SET @n_TotalOrders = @n_TotalOrders + @n_BuildOrders 

      FETCH NEXT FROM @CUR_PARMKEY INTO @c_BuildParmKey
   END
   CLOSE @CUR_PARMKEY
   DEALLOCATE @CUR_PARMKEY

   SET @n_NoOfAllocated = 0
   SET @n_WavedOrders   = 0
   SET @n_TotalOrders   = 0
   
   IF @c_AnalysisType = 'SUMMARY'
   BEGIN
      SELECT @n_NoOfAllocated = ISNULL(SUM(CASE WHEN OH.[Status] = '2' THEN 1 ELSE 0 END),0)
            ,@n_WavedOrders   = ISNULL(SUM(CASE WHEN WD.Wavekey IS NOT NULL THEN 1 ELSE 0 END),0)
            ,@n_TotalOrders   = COUNT(1)
      FROM ORDERS OH WITH (NOLOCK)
      LEFT JOIN WAVEDETAIL WD WITH (NOLOCK) ON (OH.Orderkey = WD.Orderkey)
      WHERE OH.Storerkey= @c_Storerkey
      AND   OH.Facility = @c_Facility
      AND   OH.[Status] < '9'

      IF @n_TotalOrders > 0 
      BEGIN
         SET @n_AllocPctg = CONVERT(DECIMAL(10,2), @n_NoOfAllocated * 1.00 / @n_TotalOrders * 100.00)
         SET @n_WavedPctg = CONVERT(DECIMAL(10,2), @n_WavedOrders * 1.00 / @n_TotalOrders * 100.00)
      END
   END

   SELECT   BuildParmKey     
         ,  TotalBuild            
         ,  BuildOrders          
         ,  WavedOrders            
         ,  Allocated        
         ,  Picked
         ,  RemainOrders
         ,  SummWaved      = @n_WavedOrders
         ,  SummWavedPctg  = @n_WavedPctg
         ,  SummAllocated  = @n_NoOfAllocated
         ,  SummAllocPctg  = @n_AllocPctg
         ,  SummTotalOrders= @n_TotalOrders
   FROM @t_WaveOrderAnalysis
   
   END TRY  
  
   BEGIN CATCH    
      SET @c_ErrMsg = 'Wave Order Analysis Failed. (lsp_WaveOrderAnalysis) ( SQLSvr MESSAGE=' + ERROR_MESSAGE() + ' ) '  
      GOTO EXIT_SP  
   END CATCH -- (SWT01) - End Big Outer Begin try.. end Try Begin Catch.. End Catch 
   
   EXIT_SP: 
   REVERT
END
GO
GRANT EXECUTE ON [WM].[lsp_WaveOrderAnalysis] TO nSQL 
GO  