IF EXISTS ( SELECT * FROM dbo.sysobjects WHERE  id = OBJECT_ID(N'[dbo].[isp_GetPalletSNDoc_DropID]') 
AND OBJECTPROPERTY(id ,N'IsProcedure') = 1 ) 
DROP PROCEDURE [dbo].[isp_GetPalletSNDoc_DropID]
GO

SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
/************************************************************************/
/* Stored Proc: isp_GetPalletSNDoc_DropID                               */
/* Creation Date: 2020-MAR-10                                           */
/* Copyright: LF Logistics                                              */
/* Written by: Wan                                                      */
/*                                                                      */
/* Purpose:                                                             */
/*        :                                                             */
/* Called By:                                                           */
/*          :                                                           */
/* PVCS Version: 1.0                                                    */
/*                                                                      */
/* Version: 7.0                                                         */
/*                                                                      */
/* Data Modifications:                                                  */
/*                                                                      */
/* Updates:                                                             */
/* Date        Author   Ver   Purposes                                  */
/************************************************************************/
CREATE PROC isp_GetPalletSNDoc_DropID
           @c_DropID             NVARCHAR(20)
AS
BEGIN
   SET NOCOUNT ON
   SET ANSI_NULLS OFF
   SET QUOTED_IDENTIFIER OFF
   SET CONCAT_NULL_YIELDS_NULL OFF

   DECLARE  
           @n_StartTCnt       INT = @@TRANCOUNT
         , @n_Continue        INT 

   WHILE @@TRANCOUNT > 0
   BEGIN
     COMMIT TRAN
   END    
    
   SELECT PD.PickSlipNo
         ,CartonNo_Min = ISNULL(Min(PD.CartonNo),'') 
         ,CartonNo_Max = ISNULL(Max(PD.CartonNo),'')
   FROM PACKDETAIL PD WITH (NOLOCK)
   WHERE PD.DropID = @c_DropID
   GROUP BY PD.PickSlipNo--, PD.CartonNo
   ORDER BY PD.PickSlipNo--, PD.CartonNo   

   WHILE @@TRANCOUNT < @n_StartTCnt
   BEGIN
     BEGIN TRAN
   END   

END -- procedure
GO
GRANT EXECUTE ON [dbo].[isp_GetPalletSNDoc_DropID] TO nSQL 
GO
