SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
/***************************************************************************/
/* Stored Procedure: msp_BEJ_GenReplenishmentTask                          */
/* Creation Date: 2026-07-10                                               */
/* Copyright: MAERSK                                                       */
/* Written by: PREETHAM                                                    */
/*                                                                         */
/* Purpose: Generate replenishment tasks for AEOMX (ReplenType = T)          */
/*                                                                         */
/* Called By: msp_BEJ                                                      */
/*                                                                         */
/* Version: 1.0                                                            */
/*                                                                         */
/* Data Modifications:                                                     */
/*                                                                         */
/* Updates:                                                                */
/* Date         Author    Ver   Purposes                                   */
/* 2026-07-10   Preetham  1.0   FCR-12991                                  */
/***************************************************************************/

CREATE OR ALTER PROC dbo.msp_BEJ_GenReplenishmentTask
     @c_StorerKey   NVARCHAR(15)   = 'AEOMX'
   , @c_Facility    NVARCHAR(30)   = 'MX05'
   , @c_OtherConfig NVARCHAR(4000) = ''
AS
BEGIN
   SET NOCOUNT ON
   SET QUOTED_IDENTIFIER OFF
   SET CONCAT_NULL_YIELDS_NULL OFF

   DECLARE @c_SP_Name     NVARCHAR(128) = 'msp_BEJ_GenReplenishmentTask'
         , @n_Err         INT           = 0
         , @c_ErrMsg      NVARCHAR(255) = ''

         , @c_Zone01      NVARCHAR(10)  = 'MX05'
         , @c_Zone02      NVARCHAR(10)  = 'ALL'
         , @c_Zone03      NVARCHAR(10)  = ''
         , @c_Zone04      NVARCHAR(10)  = ''
         , @c_Zone05      NVARCHAR(10)  = ''
         , @c_Zone06      NVARCHAR(10)  = ''
         , @c_Zone07      NVARCHAR(10)  = ''
         , @c_Zone08      NVARCHAR(10)  = ''
         , @c_Zone09      NVARCHAR(10)  = ''
         , @c_Zone10      NVARCHAR(10)  = ''
         , @c_Zone11      NVARCHAR(10)  = ''
         , @c_Zone12      NVARCHAR(10)  = ''
         , @c_ReplenFlag  NVARCHAR(10)  = 'N'
         , @c_ReplenType  NVARCHAR(10)  = 'T'


   SET @c_Zone01 = @c_Facility

   SET @c_Zone02     = dbo.fnc_GetParamValueFromString('@Zone02'    , @c_OtherConfig, 'ALL')
   SET @c_Zone03     = dbo.fnc_GetParamValueFromString('@Zone03'    , @c_OtherConfig, '')
   SET @c_Zone04     = dbo.fnc_GetParamValueFromString('@Zone04'    , @c_OtherConfig, '')
   SET @c_Zone05     = dbo.fnc_GetParamValueFromString('@Zone05'    , @c_OtherConfig, '')
   SET @c_Zone06     = dbo.fnc_GetParamValueFromString('@Zone06'    , @c_OtherConfig, '')
   SET @c_Zone07     = dbo.fnc_GetParamValueFromString('@Zone07'    , @c_OtherConfig, '')
   SET @c_Zone08     = dbo.fnc_GetParamValueFromString('@Zone08'    , @c_OtherConfig, '')
   SET @c_Zone09     = dbo.fnc_GetParamValueFromString('@Zone09'    , @c_OtherConfig, '')
   SET @c_Zone10     = dbo.fnc_GetParamValueFromString('@Zone10'    , @c_OtherConfig, '')
   SET @c_Zone11     = dbo.fnc_GetParamValueFromString('@Zone11'    , @c_OtherConfig, '')
   SET @c_Zone12     = dbo.fnc_GetParamValueFromString('@Zone12'    , @c_OtherConfig, '')
   SET @c_ReplenFlag = dbo.fnc_GetParamValueFromString('@ReplenFlag', @c_OtherConfig, 'N')
   SET @c_ReplenType = dbo.fnc_GetParamValueFromString('@ReplenType', @c_OtherConfig, 'T')

   BEGIN TRY
      EXEC dbo.isp_GenReplenishmentTask_01
           @c_Zone01     = @c_Zone01
         , @c_Zone02     = @c_Zone02
         , @c_Zone03     = @c_Zone03
         , @c_Zone04     = @c_Zone04
         , @c_Zone05     = @c_Zone05
         , @c_Zone06     = @c_Zone06
         , @c_Zone07     = @c_Zone07
         , @c_Zone08     = @c_Zone08
         , @c_Zone09     = @c_Zone09
         , @c_Zone10     = @c_Zone10
         , @c_Zone11     = @c_Zone11
         , @c_Zone12     = @c_Zone12
         , @c_ReplenFlag = @c_ReplenFlag
         , @c_Storerkey  = @c_StorerKey
         , @c_ReplenType = @c_ReplenType
   END TRY
   BEGIN CATCH
      SET @n_Err    = ERROR_NUMBER()
      SET @c_ErrMsg = 'NSQL' + CONVERT(NVARCHAR(5), @n_Err) +
            ': ' + ISNULL(@c_SP_Name,'') + ' failed for Storer=' + ISNULL(@c_StorerKey,'') +
            ', Facility=' + ISNULL(@c_Facility,'') + ' (SQLSvr MESSAGE=' + LTRIM(RTRIM(ERROR_MESSAGE())) + ')'

      RAISERROR (@c_ErrMsg, 16, 1) WITH SETERROR
      RETURN
   END CATCH
END
GO

GRANT EXECUTE ON dbo.msp_BEJ_GenReplenishmentTask TO NSQL
GO

