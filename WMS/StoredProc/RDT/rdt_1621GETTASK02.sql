if exists (select * from dbo.sysobjects where id = object_id(N'[RDT].[rdt_1621GETTASK02]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [RDT].[rdt_1621GETTASK02]
GO

SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS OFF 
GO

/************************************************************************/  
/* Store procedure: rdt_1621GETTASK02                                   */  
/* Copyright      : IDS                                                 */  
/*                                                                      */  
/* Purpose: Use Codelkup to determine pick seq                          */
/*                                                                      */
/* Called from: rdtfnc_Cluster_Pick                                     */  
/*                                                                      */  
/* Exceed version: 5.4                                                  */  
/*                                                                      */  
/* Modifications log:                                                   */  
/*                                                                      */  
/* Date        Rev  Author      Purposes                                */  
/* 2021-06-28  1.0  James       WMS-17350. Created                      */  
/************************************************************************/  

CREATE PROC [RDT].[rdt_1621GETTASK02] (  
   @n_Mobile                  INT, 
   @n_Func                    INT, 
   @c_StorerKey               NVARCHAR( 15),  
   @c_UserName                NVARCHAR( 15),  
   @c_Facility                NVARCHAR( 5),  
   @c_PutAwayZone             NVARCHAR( 10),  
   @c_PickZone                NVARCHAR( 10),  
   @c_LangCode                NVARCHAR( 3),  
	@c_oFieled01               NVARCHAR( 20)      OUTPUT,
	@c_oFieled02               NVARCHAR( 20)      OUTPUT,
   @c_oFieled03               NVARCHAR( 20)      OUTPUT,
   @c_oFieled04               NVARCHAR( 20)      OUTPUT,
   @c_oFieled05               NVARCHAR( 20)      OUTPUT,
   @c_oFieled06               NVARCHAR( 20)      OUTPUT,
   @c_oFieled07               NVARCHAR( 20)      OUTPUT,
   @c_oFieled08               NVARCHAR( 20)      OUTPUT,
   @c_oFieled09               NVARCHAR( 20)      OUTPUT,
   @c_oFieled10               NVARCHAR( 20)      OUTPUT,
	@c_oFieled11               NVARCHAR( 20)      OUTPUT,
	@c_oFieled12               NVARCHAR( 20)      OUTPUT,
   @c_oFieled13               NVARCHAR( 20)      OUTPUT,
   @c_oFieled14               NVARCHAR( 20)      OUTPUT,
   @c_oFieled15               NVARCHAR( 20)      OUTPUT, 
   @b_Success                 INT            OUTPUT, 
   @nErrNo                    INT            OUTPUT,   
   @cErrMsg                   NVARCHAR( 20)   OUTPUT 
)  
AS  
BEGIN  
   SET NOCOUNT ON  
   SET QUOTED_IDENTIFIER OFF  
   SET ANSI_NULLS OFF  
   SET CONCAT_NULL_YIELDS_NULL OFF  

   DECLARE @c_LoadKey      NVARCHAR( 10) = '',
           @n_PickBySeq    INT = 0
           
   SELECT @c_LoadKey    = V_LoadKey,
          @c_UserName   = UserName
   FROM rdt.RDTMOBREC WITH (NOLOCK) 
   WHERE Mobile = @n_Mobile

   SELECT @n_PickBySeq = 1
   FROM dbo.CODELKUP CL WITH (NOLOCK)
   WHERE CL.LISTNAME = 'NIKESORT'
   AND   CL.Storerkey = @c_StorerKey
   AND   EXISTS ( SELECT 1 FROM dbo.ORDERS O WITH (NOLOCK) 
                  JOIN RDT.RDTPickLock RPL WITH (NOLOCK) ON ( RPL.StorerKey = O.StorerKey AND RPL.OrderKey = O.OrderKey)
                  WHERE CL.Storerkey = O.StorerKey 
                  AND   CL.Code = O.ConsigneeKey 
                  AND   O.LoadKey = @c_LoadKey
                  AND   RPL.StorerKey = @c_StorerKey
                  AND   RPL.Status < '9'
                  AND   RPL.AddWho = @c_UserName) 
   
   IF @n_PickBySeq = 1
      SELECT TOP 1
         @c_oFieled01 = PD.Loc,
         @c_oFieled02 = PD.OrderKey,
         @c_oFieled03 = PD.SKU,
         @c_oFieled09 = PD.LOT,
         @c_oFieled10 = PD.PickSlipNo
      FROM RDT.RDTPickLock RPL WITH (NOLOCK)
      JOIN dbo.PickDetail PD WITH (NOLOCK) ON (RPL.StorerKey = PD.StorerKey AND RPL.OrderKey = PD.OrderKey)
      JOIN dbo.LOC L WITH (NOLOCK) ON (PD.LOC = L.LOC)
      JOIN dbo.SKU SKU WITH (NOLOCK) ON ( PD.StorerKey = SKU.StorerKey AND PD.SKU = SKU.SKU)
      WHERE RPL.StorerKey = @c_StorerKey
         AND RPL.Status < '9'
         AND RPL.AddWho = @c_UserName
         AND PD.Status = '0'
         AND (( ISNULL( @c_PutAwayZone, '') = 'ALL') OR ( L.PutAwayZone = @c_PutAwayZone))
         AND (( ISNULL(@c_PickZone, '') = '') OR ( L.PickZone = @c_PickZone))
         AND L.Facility = @c_Facility
         AND NOT EXISTS (SELECT 1 FROM RDT.RDTPickLock SKIP_RPL WITH (NOLOCK)
                           WHERE SKIP_RPL.OrderKey = PD.OrderKey
                           AND SKIP_RPL.StorerKey = RPL.StorerKey  
                           AND SKIP_RPL.SKU = PD.SKU
                           AND SKIP_RPL.AddWho = @c_UserName
                           AND SKIP_RPL.Status = 'X')
         -- Not to get the same loc within the same orders
         AND NOT EXISTS (SELECT 1 FROM RDT.RDTPickLock SKIP_RPL2 WITH (NOLOCK)
                           WHERE SKIP_RPL2.OrderKey = PD.OrderKey
                           AND SKIP_RPL2.StorerKey = RPL.StorerKey  
                           AND SKIP_RPL2.AddWho <> @c_UserName
                           AND SKIP_RPL2.Status = '1'
                           AND SKIP_RPL2.LOC = pd.LOC )
      GROUP BY SKU.itemclass, SKU.BUSR6, L.LogicalLocation, PD.Loc, PD.OrderKey, PD.SKU, PD.LOT, PD.PickSlipNo
      ORDER BY SKU.itemclass, SKU.BUSR6, L.LogicalLocation, PD.LOC, PD.SKU, PD.OrderKey    
   ELSE
      SELECT TOP 1
         @c_oFieled01 = PD.Loc,
         @c_oFieled02 = PD.OrderKey,
         @c_oFieled03 = PD.SKU,
         @c_oFieled09 = PD.LOT,
         @c_oFieled10 = PD.PickSlipNo
      FROM RDT.RDTPickLock RPL WITH (NOLOCK)
      JOIN dbo.PickDetail PD WITH (NOLOCK) ON (RPL.StorerKey = PD.StorerKey AND RPL.OrderKey = PD.OrderKey)
      JOIN dbo.LOC L WITH (NOLOCK) ON (PD.LOC = L.LOC)
      WHERE RPL.StorerKey = @c_StorerKey
         AND RPL.Status < '9'
         AND RPL.AddWho = @c_UserName
         AND PD.Status = '0'
         AND (( ISNULL( @c_PutAwayZone, '') = 'ALL') OR ( L.PutAwayZone = @c_PutAwayZone))
         AND (( ISNULL(@c_PickZone, '') = '') OR ( L.PickZone = @c_PickZone))
         AND L.Facility = @c_Facility
         AND NOT EXISTS (SELECT 1 FROM RDT.RDTPickLock SKIP_RPL WITH (NOLOCK)
                         WHERE SKIP_RPL.OrderKey = PD.OrderKey
                         AND SKIP_RPL.StorerKey = RPL.StorerKey  
                         AND SKIP_RPL.SKU = PD.SKU
                         AND SKIP_RPL.AddWho = @c_UserName
                         AND SKIP_RPL.Status = 'X')
         -- Not to get the same loc within the same orders
         AND NOT EXISTS (SELECT 1 FROM RDT.RDTPickLock SKIP_RPL2 WITH (NOLOCK)
                         WHERE SKIP_RPL2.OrderKey = PD.OrderKey
                         AND SKIP_RPL2.StorerKey = RPL.StorerKey  -- TLTING02
                         AND SKIP_RPL2.AddWho <> @c_UserName
                         AND SKIP_RPL2.Status = '1'
                         AND SKIP_RPL2.LOC = pd.LOC )  -- james02
      ORDER BY L.LogicalLocation, PD.LOC, PD.SKU, RPL.OrderKey    
      
   IF @@ROWCOUNT = 0  
   BEGIN  
      SET @c_oFieled02 = ''  
      GOTO Quit  
   END  

   SELECT @c_oFieled04 = SKU.DESCR,
      @c_oFieled05 = SKU.Style,
      @c_oFieled06 = SKU.Color,
      @c_oFieled07 = SKU.Size,
      @c_oFieled08 = SKU.BUSR7
   FROM dbo.SKU SKU WITH (NOLOCK)
   WHERE SKU.Storerkey = @c_StorerKey
   AND   SKU.SKU = @c_oFieled03

   SELECT
      @c_oFieled11 = ExternOrderKey,
      @c_oFieled12 = ConsigneeKey
   FROM dbo.Orders WITH (NOLOCK)
   WHERE StorerKey = @c_StorerKey
   AND   OrderKey = @c_oFieled02


   Quit:
END 
GO

SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

GRANT EXECUTE ON RDT.rdt_1621GETTASK02 TO NSQL
GO
