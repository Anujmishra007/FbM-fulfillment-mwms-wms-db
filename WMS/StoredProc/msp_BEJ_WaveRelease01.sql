SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
/************************************************************************/
/* Stored Proc: msp_BEJ_WaveRelease01                                   */
/* Creation Date: 2025-05-08                                            */
/* Copyright: Maersk Logistics                                          */
/* Written by: Wan                                                      */
/*                                                                      */
/* Purpose: FCR-3958 - JCB Picking Task                                 */
/*        :                                                             */
/* Called By: Call by SQL Scheduler Job                                 */
/*          :                                                           */
/*                                                                      */
/* Version: 1.0                                                         */
/*                                                                      */
/* Data Modifications:                                                  */
/*                                                                      */
/* Updates:                                                             */
/* Date        Author   Ver   Purposes                                  */
/* 2025-05-08  Wan      1.0   Created.                                  */
/************************************************************************/
CREATE OR ALTER PROC [dbo].[msp_BEJ_WaveRelease01]
   @c_StorerKey   NVARCHAR(15)   = ''
,  @c_Facility    NVARCHAR(5)    = ''
,  @c_OtherConfig NVARCHAR(4000) = ''
,  @b_Debug       INT = 0
AS
BEGIN
   SET NOCOUNT ON
   SET ANSI_NULLS OFF
   SET QUOTED_IDENTIFIER OFF
   SET CONCAT_NULL_YIELDS_NULL OFF

   DECLARE
           @n_StartTCnt       INT            = @@TRANCOUNT
         , @n_Continue        INT            = 1
         , @b_Success         INT            = 1
         , @n_Err             INT            = 0
         , @c_ErrMsg          NVARCHAR(255)  = ''

         , @c_WaveKey         NVARCHAR(10)   = '' 
         , @c_UserName        NVARCHAR(128)  = SUSER_SNAME()

         , @CUR_WAVE          CURSOR

   IF OBJECT_ID('tempdb..#TMP_WAVE') IS NOT NULL
   BEGIN
      DROP TABLE #TMP_WAVE 
   END

   CREATE TABLE #TMP_WAVE
   (  RowID          INT            IDENTITY(1,1)  PRIMARY KEY
   ,  Wavekey        NVARCHAR(10)   NOT NULL    DEFAULT('')
   ,  AutoRL         NCHAR(1)       NOT NULL    DEFAULT('N')
   )

   INSERT INTO #TMP_WAVE (Wavekey, AutoRL)
   SELECT TOP 1 WITH TIES w.WaveKey, UDF01 = ISNULL(cl.UDF01,'N')
   FROM WAVE w (NOLOCK) 
   JOIN WAVEDETAIL wd (NOLOCK) ON wd.Wavekey  = w.Wavekey
   JOIN ORDERS o (NOLOCK) ON o.Orderkey = wd.OrderKey
   LEFT OUTER JOIN LOADPLANDETAIL lpd (NOLOCK) ON lpd.Orderkey = o.Orderkey
   LEFT OUTER JOIN MBOLDETAIL md (NOLOCK) ON md.Orderkey  = o.Orderkey
   LEFT OUTER JOIN CODELKUP cl (NOLOCK) ON  cl.ListName = 'JCBORDPR' 
                                        AND cl.Storerkey= o.StorerKey
                                        AND cl.Code2 = o.[Type]
                                        AND cl.UDF02 IN ('', o.[Priority])
                                        AND cl.UDF03 IN ('', o.[OrderGroup])
   WHERE w.[Status] IN ('2','99')
   AND   w.TMReleaseFlag = 'N'
   AND   o.StorerKey = @c_StorerKey
   AND   o.Facility  = @c_Facility
   GROUP BY w.WaveKey
          , ISNULL(cl.UDF01,'N')
          , CASE WHEN cl.UDF02 = o.[Priority]   THEN 1
                 WHEN cl.UDF03 = o.[OrderGroup] THEN 2 
                 ELSE 3 END
   HAVING COUNT(1) = SUM(CASE WHEN o.[Status] = '2' THEN 1 ELSE 0 END)
   AND    SUM(CASE WHEN lpd.Loadkey IS NULL THEN 0 ELSE 1 END) > 0
   AND    SUM(CASE WHEN md.MBOLKey IS NULL  THEN 0 ELSE 1 END) > 0
   ORDER BY ROW_NUMBER() OVER (PARTITION BY w.Wavekey
                               ORDER BY w.Wavekey
                                       , CASE WHEN cl.UDF02 = o.[Priority]   THEN 1
                                              WHEN cl.UDF03 = o.[OrderGroup] THEN 2 
                                              ELSE 3 END)

   SET @CUR_WAVE = CURSOR LOCAL FAST_FORWARD READ_ONLY FOR
   SELECT w.WaveKey 
   FROM #TMP_WAVE w (NOLOCK) 
   WHERE AutoRL = 'Y'
   ORDER BY w.RowID

   OPEN @CUR_WAVE

   FETCH NEXT FROM @CUR_WAVE INTO @c_WaveKey
   
   WHILE @@FETCH_STATUS = 0  
   BEGIN
      SET @b_Success = 1
      SET @n_Err     = 0
      SET @c_ErrMsg  = ''   

      UPDATE WAVE WITH (ROWLOCK)
         SET TMReleaseFlag = 'A'
            ,TrafficCop = NULL
      WHERE WaveKey = @c_WaveKey
      
      EXEC [WM].[lsp_WaveReleaseTask]
         @c_Wavekey           = @c_Wavekey 
      ,  @c_Loadkey           = ''
      ,  @c_MBolkey           = ''
      ,  @b_Success           = @b_Success  OUTPUT 
      ,  @n_err               = @n_err      OUTPUT
      ,  @c_errmsg            = @c_errmsg   OUTPUT
      ,  @n_WarningNo         = 1   
      ,  @c_ProceedWithWarning= 'Y'                      
      ,  @c_UserName          = @c_UserName  
      
      IF @b_Success = 0
      BEGIN
         IF EXISTS ( SELECT 1 FROM WAVE w (NOLOCK) 
                     WHERE w.WaveKey = @c_WaveKey
                     AND TMReleaseFlag = 'A'
                   )
         BEGIN 
            UPDATE WAVE WITH (ROWLOCK)
               SET TMReleaseFlag = 'N'
                  ,TrafficCop = NULL
            WHERE WaveKey = @c_WaveKey
            AND TMReleaseFlag = 'A'
         END
      END

      FETCH NEXT FROM @CUR_WAVE INTO @c_WaveKey 
   END
   CLOSE @CUR_WAVE
   DEALLOCATE @CUR_WAVE
  
QUIT_SP:
   IF OBJECT_ID('tempdb..#TMP_WAVE') IS NOT NULL
   BEGIN
      DROP TABLE #TMP_WAVE 
   END
END
