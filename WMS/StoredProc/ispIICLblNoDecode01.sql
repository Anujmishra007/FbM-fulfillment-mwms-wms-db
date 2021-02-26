IF EXISTS (SELECT * FROM dbo.sysobjects WHERE id = object_id(N'[dbo].[ispIICLblNoDecode01]') and objectproperty(id, N'IsProcedure') = 1)
   DROP PROC [dbo].[ispIICLblNoDecode01]
GO

SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS OFF 
GO

/************************************************************************/
/* Store procedure: ispIICLblNoDecode01                                 */
/* Copyright      : IDS                                                 */
/*                                                                      */
/* Purpose: Decode Label No Scanned                                     */
/*                                                                      */
/* Called from:                                                         */
/*                                                                      */
/* Exceed version: 5.4                                                  */
/*                                                                      */
/* Modifications log:                                                   */
/*                                                                      */
/* Date        Rev  Author      Purposes                                */
/* 2021-01-07  1.0  James       WMS-16020. Created                      */
/************************************************************************/

CREATE PROCEDURE [dbo].[ispIICLblNoDecode01]
   @c_LabelNo          NVARCHAR(40),
   @c_Storerkey        NVARCHAR(15),
   @c_ReceiptKey       NVARCHAR(10),
   @c_POKey            NVARCHAR(10),
	 @c_LangCode	        NVARCHAR(3),
	 @c_oFieled01        NVARCHAR(20) OUTPUT,
	 @c_oFieled02        NVARCHAR(20) OUTPUT,
   @c_oFieled03        NVARCHAR(20) OUTPUT,
   @c_oFieled04        NVARCHAR(20) OUTPUT,
   @c_oFieled05        NVARCHAR(20) OUTPUT,
   @c_oFieled06        NVARCHAR(20) OUTPUT,
   @c_oFieled07        NVARCHAR(20) OUTPUT,
   @c_oFieled08        NVARCHAR(20) OUTPUT,
   @c_oFieled09        NVARCHAR(20) OUTPUT,
   @c_oFieled10        NVARCHAR(20) OUTPUT,
   @b_Success          INT = 1  OUTPUT,
   @n_ErrNo            INT      OUTPUT, 
   @c_ErrMsg           NVARCHAR(250) OUTPUT
AS
BEGIN
   SET NOCOUNT ON
   SET QUOTED_IDENTIFIER OFF
   SET ANSI_NULLS OFF
   SET CONCAT_NULL_YIELDS_NULL OFF

   DECLARE @c_SKU       NVARCHAR( 20),
           @c_Lot01     NVARCHAR( 18), 
           @c_Lot02     NVARCHAR( 18), 
           @c_UserName  NVARCHAR( 18), 
           @c_WaveKey   NVARCHAR( 10), 
           @c_FromLoc   NVARCHAR( 10),
           @c_FromID    NVARCHAR( 18),
           @c_PackKey   NVARCHAR( 10),
           @c_ReplenishmentKey   NVARCHAR( 10),
           @n_Func      INT,
           @n_Step      INT,
           @n_InputKey  INT,
           @f_InnerPack FLOAT

   SELECT @n_Func = Func, 
          @n_Step = Step,
          @n_InputKey = InputKey,
          @c_FromLoc = V_Loc,    
          @c_FromID  = V_ID,    
          @c_WaveKey = V_String12,   
          @c_UserName = UserName  
   FROM rdt.rdtMobRec WITH (NOLOCK) 
   WHERE UserName = sUser_sName()
   
   IF @n_Step = 5
   BEGIN
      IF @n_InputKey = 1
      BEGIN
         SET @f_InnerPack = 0
         
         SELECT @c_SKU = SKU,
                @c_PackKey = PACKKey
         FROM dbo.SKU WITH (NOLOCK)
         WHERE StorerKey = @c_Storerkey
         AND   ALTSKU = @c_LabelNo
         
         IF @@ROWCOUNT > 0 -- Altsku
         BEGIN
            SELECT @f_InnerPack = InnerPack
            FROM dbo.PACK WITH (NOLOCK)
            WHERE PackKey = @c_PackKey
         END
         ELSE
            SET @c_SKU = @c_LabelNo

         SELECT TOP 1 @c_ReplenishmentKey = ReplenishmentKey    
         FROM rdt.rdtReplenishmentLog WITH (NOLOCK)    
         WHERE StorerKey = @c_Storerkey     
         AND   WaveKey = @c_WaveKey    
         AND   FromLoc = @c_FromLoc    
         AND   ID  = @c_FromID    
         AND   SKU = @c_SKU    
         AND   Confirmed IN ( 'N', '1')     
         AND   AddWho = @c_UserName  
         ORDER BY ReplenishmentKey    
                 
         SET @c_oFieled01 = @c_SKU
         SET @c_oFieled05 = 0
         SET @c_oFieled09 = @c_ReplenishmentKey   
         SET @c_oFieled10 = @f_InnerPack
      END      
   END

QUIT:
END -- End Procedure

GO

SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO
GRANT EXECUTE ON dbo.ispIICLblNoDecode01 TO NSQL 
GO   
