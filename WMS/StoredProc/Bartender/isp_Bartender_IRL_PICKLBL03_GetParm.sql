SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

/******************************************************************************/
/* Copyright: MAERSK                                                          */
/* Purpose: isp_Bartender_IRL_PICKLBL03_GetParm                               */
/*                                                                            */
/* Modifications log:                                                         */
/*                                                                            */
/* Date        Rev  Author     Purposes                                       */
/* 15-Nov-2023 1.0  WLChooi    Created (WMS-24164)                            */
/* 15-Nov-2023 1.0  WLChooi    DevOps Combine Script                          */
/* 06-Jan-2024 1.1  WLChooi    WMS-24164 - Revise logic (WL01)                */
/******************************************************************************/

CREATE OR ALTER PROC [dbo].[isp_Bartender_IRL_PICKLBL03_GetParm]
(
   @c_Sparm1  NVARCHAR(250)
 , @c_Sparm2  NVARCHAR(250)
 , @c_Sparm3  NVARCHAR(250)
 , @c_Sparm4  NVARCHAR(250)
 , @c_Sparm5  NVARCHAR(250)
 , @c_Sparm6  NVARCHAR(250)
 , @c_Sparm7  NVARCHAR(250)
 , @c_Sparm8  NVARCHAR(250)
 , @c_Sparm9  NVARCHAR(250)
 , @c_Sparm10 NVARCHAR(250)
 , @b_debug   INT = 0
)
AS
BEGIN
   SET NOCOUNT ON
   SET ANSI_NULLS OFF
   SET QUOTED_IDENTIFIER OFF
   SET CONCAT_NULL_YIELDS_NULL OFF

   DECLARE @c_Storerkey    NVARCHAR(15)
         , @n_Qty          INT 
         , @c_Orderkey     NVARCHAR(10)
         , @c_SKU          NVARCHAR(20)

   DECLARE @T_RESULT AS TABLE ( 
      PARM1    NVARCHAR(80) NULL
    , PARM2    NVARCHAR(80) NULL
    , PARM3    NVARCHAR(80) NULL
    , PARM4    NVARCHAR(80) NULL
    , PARM5    NVARCHAR(80) NULL
    , PARM6    NVARCHAR(80) NULL
    , PARM7    NVARCHAR(80) NULL
    , PARM8    NVARCHAR(80) NULL
    , PARM9    NVARCHAR(80) NULL
    , PARM10   NVARCHAR(80) NULL
    , Key1     NVARCHAR(80) NULL
    , Key2     NVARCHAR(80) NULL
    , Key3     NVARCHAR(80) NULL
    , Key4     NVARCHAR(80) NULL
    , Key5     NVARCHAR(80) NULL
   )

   /*
   FN1620/21 - Orderkey, SKU
   FN593 - DropID, ExternOrderkey, SKU, Qty
   */
   IF EXISTS ( SELECT 1
               FROM ORDERS OH WITH (NOLOCK)
               WHERE OH.OrderKey = @c_Sparm1 )
   BEGIN
      SELECT @c_Storerkey = OH.Storerkey
      FROM ORDERS OH WITH (NOLOCK)
      WHERE OH.OrderKey = @c_Sparm1

      --WL01 S
      --SELECT @n_Qty = SUM(PD.Qty)
      --FROM PICKDETAIL PD WITH (NOLOCK)
      --WHERE PD.OrderKey = @c_Sparm1
      --AND PD.SKU = @c_Sparm2
      --AND PD.Storerkey = @c_Storerkey
      --WL01 E

      SET @c_Orderkey = @c_Sparm1
      SET @c_SKU = @c_Sparm2
      SET @n_Qty = 1   --WL01
   END
   ELSE IF ISNULL(@c_Sparm1,'') <> '' OR ISNULL(@c_Sparm2,'') <> ''
   BEGIN
      IF EXISTS ( SELECT 1 
                  FROM PICKDETAIL PD WITH (NOLOCK)
                  WHERE PD.DropID = @c_Sparm1
                  AND PD.StorerKey = CASE WHEN ISNULL(@c_Sparm5,'') = '' THEN PD.StorerKey ELSE @c_Sparm5 END ) AND ISNULL(@c_Sparm1,'') <> ''
      BEGIN
         SELECT @c_Orderkey = PD.Orderkey
         FROM PICKDETAIL PD WITH (NOLOCK)
         WHERE PD.DropID = @c_Sparm1
         AND PD.StorerKey = CASE WHEN ISNULL(@c_Sparm5,'') = '' THEN PD.StorerKey ELSE @c_Sparm5 END
      END
      ELSE
      BEGIN
         SELECT @c_Orderkey = OH.Orderkey
         FROM ORDERS OH WITH (NOLOCK)
         WHERE OH.ExternOrderKey = @c_Sparm2
         AND OH.StorerKey = CASE WHEN ISNULL(@c_Sparm5,'') = '' THEN OH.StorerKey ELSE @c_Sparm5 END
      END

      IF ISNULL(@c_Sparm5,'') = ''
      BEGIN
         SELECT @c_Sparm5 = OH.Storerkey
         FROM ORDERS OH WITH (NOLOCK)
         WHERE OH.OrderKey = @c_Orderkey
      END

      SET @c_SKU = @c_Sparm3
      SET @n_Qty = IIF(ISNULL(@c_Sparm4,'') = '', 1, @c_Sparm4)
      SET @c_Storerkey = UPPER(TRIM(@c_Sparm5))
   END

   WHILE @n_Qty > 0
   BEGIN
      INSERT @T_RESULT
      SELECT PARM1 = @c_Orderkey
           , PARM2 = @c_Storerkey
           , PARM3 = @c_SKU
           , PARM4 = ''
           , PARM5 = ''
           , PARM6 = ''
           , PARM7 = ''
           , PARM8 = ''
           , PARM9 = ''
           , PARM10 = ''
           , Key1 = 'Orderkey'
           , Key2 = 'Storerkey'
           , Key3 = 'SKU'
           , Key4 = ''
           , Key5 = ''

      SET @n_Qty = @n_Qty - 1
   END

   SELECT PARM1
        , PARM2
        , PARM3
        , PARM4
        , PARM5
        , PARM6
        , PARM7
        , PARM8
        , PARM9
        , PARM10
        , Key1
        , Key2
        , Key3
        , Key4
        , Key5
   FROM @T_RESULT

   EXIT_SP:
END -- procedure     
GO
GRANT EXECUTE ON [dbo].[isp_Bartender_IRL_PICKLBL03_GetParm] TO [NSQL]
GO