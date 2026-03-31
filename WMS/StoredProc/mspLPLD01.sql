SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

/************************************************************************/
/* Stored Procedure: mspLPLD01                                          */
/* Creation Date: 2026-03-31                                            */
/* Copyright: Maersk Logistics                                          */
/* Written by: AYD                                                      */
/*                                                                      */
/* Purpose: FCR-11572 - ONBR - Assign Lane for B2B                      */
/*                                                                      */
/* Return Status:  None                                                 */
/*                                                                      */
/* Usage: Loadplan assign lane                                          */
/*                                                                      */
/* Local Variables:                                                     */
/*                                                                      */
/* Called By: isp_LoadPlanLaneDetailTrigger_Wrapper                     */
/*                                                                      */
/* Version: 1.0                                                         */
/*                                                                      */
/* Data Modifications:                                                  */
/*                                                                      */
/* Updates:                                                             */
/* Date        Author   Ver   Purposes                                  */
/* 2026-03-09  Wan      1.0   Created                                   */
/************************************************************************/
CREATE OR ALTER PROC dbo.mspLPLD01
   @c_Action            NVARCHAR(10)  = ''
,  @c_Storerkey         NVARCHAR(15)  = '' 
,  @b_Success     INT            = 1   OUTPUT    
,  @n_Err         INT            = 0   OUTPUT    
,  @c_Errmsg      NVARCHAR(250)  = ''  OUTPUT  
AS
BEGIN
   SET NOCOUNT ON        
   SET QUOTED_IDENTIFIER OFF
   SET ANSI_NULLS OFF
   SET CONCAT_NULL_YIELDS_NULL OFF

   DECLARE @n_Continue           INT            = 1
         , @n_StartTCnt          INT            = @@TRANCOUNT
         , @n_RowCount           INT            = 0

         , @c_Facility           NVARCHAR(5)    = ''
         , @c_Loadkey            NVARCHAR(10)   = ''
         , @c_ExternOrderkey     NVARCHAR(50)   = ''
         , @c_Consigneekey       NVARCHAR(15)   = ''
         , @c_Orderkey           NVARCHAR(10)   = ''
         , @c_LP_LaneNumber      NVARCHAR(5)    = ''
         , @c_LocationCategory   NVARCHAR(10)   = ''
         , @c_Loc                NVARCHAR(10)   = ''

         , @CUR_ALANE         CURSOR

   DECLARE @t_AssignLane      TABLE
         ( RowID              INT            NOT NULL IDENTITY(1,1) PRIMARY KEY
         , Loadkey            NVARCHAR(10)   NOT NULL DEFAULT('')
         , ExternOrderkey     NVARCHAR(50)   NOT NULL DEFAULT('')
         , Consigneekey       NVARCHAR(15)   NOT NULL DEFAULT('')
         , Orderkey           NVARCHAR(10)   NOT NULL DEFAULT('')
         , LP_LaneNumber      NVARCHAR(5)    NOT NULL DEFAULT('')
         , LocationCategory   NVARCHAR(10)   NOT NULL DEFAULT('')
         , Loc                NVARCHAR(10)   NOT NULL DEFAULT('')
         )
 
   SET @b_Success = 1
   SET @n_Err = 0
   SET @c_ErrMsg = ''
       
   IF @c_Action NOT IN ('INSERT','UPDATE','DELETE')
   BEGIN
      GOTO QUIT_SP
   END  

   IF OBJECT_ID('tempdb..#INSERTED') IS NULL OR OBJECT_ID('tempdb..#DELETED') IS NULL
   BEGIN
      GOTO QUIT_SP
   END
 
   IF @c_Action = 'DELETE'
   BEGIN
      GOTO QUIT_SP
   END

   IF @c_Action = 'INSERT'
   BEGIN  
      SET @CUR_ALANE = CURSOR LOCAL FAST_FORWARD READ_ONLY FOR           
      SELECT i.Loadkey, i.ExternOrderkey, i.Consigneekey
            ,i.LP_LaneNumber, i.LocationCategory, l.Loc 
            ,o.Orderkey
      FROM #INSERTED i
      JOIN LoadPlanDetail lpd (NOLOCK) ON  lpd.Loadkey = i.Loadkey
                                       AND lpd.ExternOrderKey =  i.ExternOrderKey 
      JOIN ORDERS o (NOLOCK) ON o.Orderkey = lpd.Orderkey
      LEFT OUTER JOIN LOC l (NOLOCK) ON  l.Loc = i.Loc
                                     AND l.locationcategory = i.LocationCategory
                                   AND l.Facility = o.Facility
      WHERE o.Storerkey = @c_Storerkey 
   END
   ELSE IF @c_Action = 'UPDATE'
   BEGIN 
      SET @CUR_ALANE = CURSOR LOCAL FAST_FORWARD READ_ONLY FOR           
      SELECT i.Loadkey, i.ExternOrderkey, i.Consigneekey
            , i.LP_LaneNumber, i.LocationCategory, l.Loc 
            ,o.Orderkey
      FROM #INSERTED i
      JOIN #DELETED D ON  i.Loadkey = d.Loadkey 
                      AND i.ExternOrderKey = d.ExternOrderKey 
                      AND i.ConsigneeKey = d.ConsigneeKey 
                      AND i.LP_LaneNumber = d.LP_LaneNumber 
                      AND i.MBOLKey = d.MBOLKey
      JOIN LoadPlanDetail lpd (NOLOCK) ON  lpd.Loadkey = i.Loadkey
                                       AND lpd.ExternOrderKey =  i.ExternOrderKey 
      JOIN ORDERS o (NOLOCK) ON o.Orderkey = lpd.Orderkey  
      LEFT OUTER JOIN LOC l (NOLOCK) ON  l.Loc = i.Loc
                                     AND l.locationcategory = i.LocationCategory
                                     AND l.Facility = o.Facility
      WHERE o.Storerkey = @c_Storerkey
      AND ( i.loc <> d.loc OR i.locationcategory <> d.locationcategory)
   END

   OPEN @CUR_ALANE    
   FETCH NEXT FROM @CUR_ALANE INTO @c_Loadkey, @c_ExternOrderkey, @c_Consigneekey
                                 , @c_LP_LaneNumber, @c_LocationCategory, @c_Loc
                                 , @c_Orderkey
            
   WHILE @@FETCH_STATUS <> -1 AND @n_Continue = 1    
   BEGIN  
      IF @c_Loc IN ('',NULL)
      BEGIN
         SET @n_Continue = 3
         SET @n_Err      = 68010
         SET @c_Errmsg   = 'NSQL' + CONVERT(CHAR(5), @n_Err)
                         + ': Invalid Loc for LocationCategory: ' 
                         + @c_LocationCategory
                         + '. (mspLPLD01)'
      END

      IF @n_Continue = 1
      BEGIN
         IF EXISTS ( SELECT 1 FROM @t_AssignLane as al
                     WHERE al.loc = @c_Loc
                   )
         BEGIN
            SET @n_Continue = 3
            SET @n_Err      = 68020
            SET @c_Errmsg   = 'NSQL' + CONVERT(CHAR(5), @n_Err)
                            + ': Duplicate Assign Loc found. Loc: ' 
                            + @c_Loc 
                            + '. (mspLPLD01)'
         END
      END

      IF @n_Continue = 1
      BEGIN
         IF EXISTS ( SELECT 1  
                     FROM  #INSERTED i 
                     JOIN  LoadPlanLaneDetail Lpld (NOLOCK) ON  Lpld.Loadkey = i.Loadkey
                     AND   Lpld.Loadkey = @c_Loadkey
                     AND   Lpld.loc     = @c_Loc
                     AND   lpld.LP_LaneNumber <> @c_LP_LaneNumber
                   )
         BEGIN
            SET @n_Continue = 3
            SET @n_Err      = 68021
            SET @c_Errmsg   = 'NSQL' + CONVERT(CHAR(5), @n_Err)
                            + ': Duplicate Assign Loc found. Loc: ' 
                            + @c_Loc 
                            + '. (mspLPLD01)'
         END
      END

      IF @n_Continue = 1
      BEGIN
         IF EXISTS ( SELECT 1 FROM @t_AssignLane as al
                     WHERE al.Loadkey      = @c_Loadkey
                     AND al.ExternOrderKey = @c_ExternOrderKey
                     AND al.ConsigneeKey   = @c_ConsigneeKey
                     AND al.LocationCategory= @c_LocationCategory
                   )
         BEGIN
            SET @n_Continue = 3
            SET @n_Err      = 68030
            SET @c_Errmsg   = 'NSQL' + CONVERT(CHAR(5), @n_Err)
                            + ': Duplicate Location Category found. LocationCategory: ' 
                            + @c_LocationCategory 
                            + '. (mspLPLD01)'
         END
      END

      IF @n_Continue = 1
      BEGIN
         IF EXISTS ( SELECT 1 
                     FROM  #INSERTED i 
                     JOIN  LoadPlanLaneDetail Lpld (NOLOCK) ON  Lpld.Loadkey = i.Loadkey
                                                            AND Lpld.ExternOrderKey = i.ExternOrderKey
                                                            AND Lpld.ConsigneeKey   = i.ConsigneeKey
                                                            AND Lpld.LP_LaneNumber  <> i.LP_LaneNumber
                                                            AND Lpld.LocationCategory = i.LocationCategory
                     AND   i.Loadkey = @c_Loadkey
                     AND   i.LocationCategory = @c_LocationCategory
                   )
         BEGIN
            SET @n_Continue = 3
            SET @n_Err      = 68031
            SET @c_Errmsg   = 'NSQL' + CONVERT(CHAR(5), @n_Err)
                            + ': Duplicate Location Category found. LocationCategory: ' 
                            + @c_LocationCategory 
                            + '. (mspLPLD01)'
         END
      END

      IF @n_Continue = 1
      BEGIN
         IF EXISTS ( SELECT 1  
                     FROM LoadPlanLaneDetail Lpld (NOLOCK) 
                     JOIN LoadPlanDetail lpd (NOLOCK) ON  lpd.Loadkey = Lpld.Loadkey
                                                      AND lpd.ExternOrderKey =  Lpld.ExternOrderKey 
                     JOIN ORDERS o (NOLOCK) ON lpd.Orderkey = o.Orderkey
                     WHERE o.Storerkey = @c_Storerkey
                     AND   o.Status   < '9'
                     AND   o.Orderkey <> @c_Orderkey
                     AND   lpld.Loc   = @c_Loc
                     AND   Lpld.Status = '0'
                   )
         BEGIN
            SET @n_Continue = 3
            SET @n_Err      = 68040
            SET @c_Errmsg   = 'NSQL' + CONVERT(CHAR(5), @n_Err)
                            + ': Assign Loc is In Use. Loc: ' 
                            + @c_Loc 
                            + '. (mspLPLD01)'
         END
      END
  
      IF @n_Continue = 1
      BEGIN
         INSERT INTO @t_AssignLane (Loadkey, ExternOrderkey, Consigneekey, Orderkey
                                  , LP_LaneNumber, LocationCategory, Loc)
         VALUES (@c_Loadkey, @c_ExternOrderkey, @c_Consigneekey, @c_Orderkey
               , @c_LP_LaneNumber, @c_LocationCategory, @c_Loc)
      END

      FETCH NEXT FROM @CUR_ALANE INTO @c_Loadkey, @c_ExternOrderkey, @c_Consigneekey
                                    , @c_LP_LaneNumber, @c_LocationCategory, @c_Loc
                                    , @c_Orderkey
   END
   CLOSE @CUR_ALANE
   DEALLOCATE @CUR_ALANE
 
QUIT_SP:
 
   IF OBJECT_ID('tempdb..#TMP_PALOC') IS NOT NULL  
   BEGIN
      DROP TABLE #TMP_PALOC
   END

   IF OBJECT_ID('tempdb..#TMP_CL') IS NOT NULL  
   BEGIN
      DROP TABLE #TMP_CL
   END

   IF @n_Continue=3  -- Error Occured - Process And Return
   BEGIN
      SET @b_success = 0
      IF @@TRANCOUNT = 1 and @@TRANCOUNT > @n_StartTCnt
      BEGIN
         ROLLBACK TRAN
      END
      ELSE
      BEGIN
         WHILE @@TRANCOUNT > @n_StartTCnt
         BEGIN
            COMMIT TRAN
         END
      END
   END
   ELSE
   BEGIN
      SET @b_success = 1
      WHILE @@TRANCOUNT > @n_StartTCnt
      BEGIN
         COMMIT TRAN
      END
   END
END