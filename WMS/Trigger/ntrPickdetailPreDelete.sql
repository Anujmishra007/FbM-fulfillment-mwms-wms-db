SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
/************************************************************************/
/* Trigger: ntrPickDetailPreDelete                                      */
/* Creation Date: 2024-06-04                                            */
/* Copyright: Maersk                                                    */
/* Written by: Wan                                                      */
/*                                                                      */
/* Purpose: UWP-18393 - Unallocation for Mixed Sku Pallet               */
/*                                                                      */
/* Input Parameters: NONE                                               */
/*                                                                      */
/* Output Parameters: NONE                                              */
/*                                                                      */
/* Return Status: NONE                                                  */
/*                                                                      */
/* Usage:                                                               */
/*                                                                      */
/* Local Variables:                                                     */
/*                                                                      */
/* Called By: When records DELETED                                      */
/*                                                                      */
/* GITHUB Version: 1.2                                                  */
/*                                                                      */
/* Version: 2                                                           */
/*                                                                      */
/* Modifications:                                                       */
/* Date        Author   Ver   Purposes                                  */
/* 2024-06-04  Wan      1.0   Created.                                  */
/* 2024-06-21  Wan01    1.1   UWP-18393 - Fixed.                        */
/* 2024-08-01  Wan02    1.2   INC7095402- Split Storer ConfigKey check. */
/*                                      - Revise LocationType (Leong01) */
/************************************************************************/

CREATE OR ALTER TRIGGER [dbo].[ntrPickDetailPreDelete]
ON [dbo].[PICKDETAIL]
INSTEAD OF DELETE
AS
BEGIN
   IF @@ROWCOUNT = 0
   BEGIN
      RETURN
   END

   SET NOCOUNT ON
   SET ANSI_NULLS OFF
   SET QUOTED_IDENTIFIER OFF
   SET CONCAT_NULL_YIELDS_NULL OFF

   DECLARE
        @n_StartTCnt       INT            = @@TRANCOUNT
      , @n_Continue        INT            = 1
      , @b_Success         INT            = 1 -- Populated by calls to stored procedures - was the proc successful?
      , @n_err             INT            = 0 -- Error number returned by stored procedure or this trigger
      , @c_errmsg          NVARCHAR(250)  = ''-- Error message returned by stored procedure or this trigger
      , @c_Facility        NVARCHAR(5)  = ''
      , @c_StorerKey       NVARCHAR(15) = ''
      , @c_LockedID        NVARCHAR(10) = ''
      , @c_Loc             NVARCHAR(10) = ''
      , @c_ID              NVARCHAR(18) = ''
      , @c_PickDetailKey   NVARCHAR(10) = ''

      , @CUR_ID            CURSOR
      , @CUR_SCFG          CURSOR --(Wan01)

   IF EXISTS(SELECT 1 FROM DELETED WHERE ArchiveCop = '9')
   BEGIN
      SET @n_Continue = 4
   END

   IF OBJECT_ID('tempdb..#tmpPICKDETAIL','U') IS NOT NULL
   BEGIN
      DROP TABLE #tmpPICKDETAIL
   END

   CREATE TABLE #tmpPICKDETAIL (PickDetailKey NVARCHAR(10) NOT NULL PRIMARY KEY)

   INSERT INTO #tmpPICKDETAIL (PickDetailKey)
   SELECT PickDetailKey FROM DELETED

   IF @n_Continue IN (1, 2)
   BEGIN
      SET @CUR_SCFG = CURSOR LOCAL FAST_FORWARD READ_ONLY FOR     --(Wan02) - START
      SELECT D.StorerKey, OH.Facility
      FROM DELETED D
      JOIN ORDERS OH WITH (NOLOCK)
      ON OH.OrderKey = D.OrderKey AND OH.StorerKey = D.StorerKey
      CROSS APPLY dbo.fnc_SelectGetRight (OH.Facility, D.StorerKey, '', 'StockOnLockedID') SC
      WHERE SC.Authority = '1'
      GROUP BY D.StorerKey, OH.Facility
      ORDER BY D.StorerKey, OH.Facility

      OPEN @CUR_SCFG
      FETCH NEXT FROM @CUR_SCFG INTO @c_StorerKey, @c_Facility

      WHILE @@FETCH_STATUS = 0 AND @n_Continue IN (1, 2)
      BEGIN
         SET @CUR_ID = CURSOR LOCAL FAST_FORWARD READ_ONLY FOR
         SELECT D.StorerKey, D.Loc, D.Id
         FROM DELETED D
         --JOIN PICKDETAIL PD WITH (NOLOCK) ON  PD.StorerKey = D.StorerKey               --(Wan02)
         --                                 AND PD.ID = D.ID                             --(Wan02)
         --                                 AND PD.Loc = D.Loc                           --(Wan02)
         JOIN SKUxLOC SL WITH (NOLOCK) ON  SL.StorerKey = D.StorerKey
                                       AND SL.Sku = D.Sku
                                       AND SL.Loc = D.Loc
         JOIN LOC L WITH (NOLOCK) ON L.Loc = D.Loc
         --CROSS APPLY dbo.fnc_SelectGetRight (L.Facility, D.StorerKey, '', 'StockOnLockedID') SC --(Wan02)
         WHERE D.[Status] < '9'
         AND SL.LocationType NOT IN ('CASE', 'PICK')
         AND L.LocationType NOT IN ('DYNPPICK','DYNPICKP','DYNPICKR') --(Leong01)
         --AND SC.Authority = '1' --(Wan02)
         AND D.StorerKey = @c_StorerKey
         AND L.Facility = @c_Facility
         GROUP BY D.StorerKey, D.Loc, D.Id
         ORDER BY D.StorerKey, D.Loc, D.Id

         OPEN @CUR_ID
         FETCH NEXT FROM @CUR_ID INTO @c_StorerKey, @c_Loc, @c_Id

         WHILE @@FETCH_STATUS = 0 AND @n_Continue IN (1, 2)
         BEGIN
            INSERT INTO #tmpPICKDETAIL (PickDetailKey)
            SELECT PD.PickDetailKey
            FROM PICKDETAIL PD WITH (NOLOCK)
            LEFT OUTER JOIN DELETED D ON D.PickDetailKey = PD.PickDetailKey
            WHERE PD.StorerKey = @c_StorerKey
            AND   PD.Loc = @c_Loc
            AND   PD.Id = @c_Id
            AND   PD.[Status] < '9'
            AND   D.PickDetailKey IS NULL

            FETCH NEXT FROM @CUR_ID INTO @c_StorerKey, @c_Loc, @c_Id
         END
         CLOSE @CUR_ID
         DEALLOCATE @CUR_ID

         FETCH NEXT FROM @CUR_SCFG INTO @c_StorerKey, @c_Facility
      END
      CLOSE @CUR_SCFG
      DEALLOCATE @CUR_SCFG   --(Wan02) - END
   END

   DELETE P
   FROM PICKDETAIL P
   JOIN #tmpPICKDETAIL D ON P.PickDetailKey = D.PickDetailKey

END -- Trigger
