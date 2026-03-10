
/************************************************************************/
/* Store procedure: [API].[fnc_ECOMP_IsCCTVEnabled]                     */
/* Creation Date: 10-OCT-2024                                           */
/* Copyright: Maersk                                                    */
/* Written by: Alex                                                     */
/*                                                                      */
/* Purpose:                                                             */
/*                                                                      */
/* Called By: SCEAPI                                                    */
/*                                                                      */
/* PVCS Version: 1.0                                                    */
/*                                                                      */
/* Version: 1.0                                                         */
/*                                                                      */
/* Data Modifications:                                                  */
/*                                                                      */
/* Updates:                                                             */
/* Date           Author   Purposes		                                 */
/* 10-OCT-2024    Alex     #JIRA PAC-356 Initial                        */
/* 26-AUG-2025    Jiawen   #UWP-40024 Update CCTV Switch Config         */
/************************************************************************/

CREATE OR ALTER FUNCTION [API].[fnc_ECOMP_IsCCTVEnabled]
(  
   @c_StorerKey         NVARCHAR(15)   = ''
 , @c_Facility          NVARCHAR(5)    = ''
 , @c_ComputerName      NVARCHAR(30)   = ''
 , @c_UserId            NVARCHAR(128)  = ''
)  
RETURNS NVARCHAR(1) 
AS  
BEGIN     
   DECLARE @c_EPACKCCTV_IsEnabled      NVARCHAR(1)    = '0'

   SET @c_EPACKCCTV_IsEnabled = dbo.fnc_GetRight(@c_Facility, @c_Storerkey, '', 'EPACKCCTVTrigger')
   SET @c_EPACKCCTV_IsEnabled = CASE WHEN ISNULL(RTRIM(@c_EPACKCCTV_IsEnabled), '') = '' THEN '0' ELSE ISNULL(RTRIM(@c_EPACKCCTV_IsEnabled), '') END

   IF @c_EPACKCCTV_IsEnabled = '1'
   BEGIN
      IF CHARINDEX('\', REPLACE(@c_UserId, ' ', '')) > 0
      BEGIN
         SET @c_UserId = REVERSE(LEFT(REVERSE(@c_UserId), CHARINDEX('\', REVERSE(@c_UserId)) - 1))
      END

      IF EXISTS ( SELECT 1 FROM [dbo].[Codelkup] WITH (NOLOCK) 
                  WHERE
                     ListName = 'CCTVSwitch'
                     AND StorerKey = @c_StorerKey
                     AND UDF01 = @c_Facility
                     AND Short = '1'
                     AND (
                        UDF02 = @c_UserID
                        OR
                           CHARINDEX('\', REPLACE(UDF02, ' ', '')) > 0
                           AND
                           REVERSE(LEFT(REVERSE(UDF02), CHARINDEX('\', REVERSE(UDF02)) - 1)) = @c_UserID
                        OR
                        UDF03 = @c_ComputerName
                     )
               )
      BEGIN
         SET @c_EPACKCCTV_IsEnabled = '1'
         GOTO EXIT_FUNCTION
      END
      ELSE
      BEGIN
         SET @c_EPACKCCTV_IsEnabled = '0'
         GOTO EXIT_FUNCTION
      END
   END
   ELSE
   BEGIN
      GOTO EXIT_FUNCTION
   END

   EXIT_FUNCTION:
   RETURN @c_EPACKCCTV_IsEnabled
END

