SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

/******************************************************************************/
/* Copyright: MAERSK                                                          */
/* Purpose: isp_Bartender_IRL_TRANSPLBL_GetParm                               */
/*                                                                            */
/* Modifications log:                                                         */
/*                                                                            */
/* Date        Rev  Author     Purposes                                       */
/* 15-Nov-2023 1.0  WLChooi    Created (WMS-24197)                            */
/* 15-Nov-2023 1.0  WLChooi    DevOps Combine Script                          */
/******************************************************************************/

CREATE OR ALTER PROC [dbo].[isp_Bartender_IRL_TRANSPLBL_GetParm]
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
   SCE - Orderkey
   FN593 - ExternOrderkey, Qty, Storerkey
   */
   IF EXISTS ( SELECT 1
               FROM ORDERS OH WITH (NOLOCK)
               WHERE OH.OrderKey = @c_Sparm1 )
   BEGIN
      SET @c_Orderkey = @c_Sparm1
      SET @n_Qty = 1
   END
   ELSE IF ISNULL(@c_Sparm1,'') <> ''
   BEGIN
      SELECT @c_Orderkey = OH.Orderkey
      FROM ORDERS OH WITH (NOLOCK)
      WHERE OH.ExternOrderKey = @c_Sparm1
      AND OH.StorerKey = CASE WHEN ISNULL(@c_Sparm3,'') = '' THEN OH.StorerKey ELSE @c_Sparm3 END

      IF ISNULL(@c_Sparm3,'') = ''
      BEGIN
         SELECT @c_Sparm3 = OH.Storerkey
         FROM ORDERS OH WITH (NOLOCK)
         WHERE OH.OrderKey = @c_Orderkey
      END

      SET @n_Qty = IIF(ISNULL(@c_Sparm2,'') = '', 1, @c_Sparm2)
      SET @c_Storerkey = UPPER(TRIM(@c_Sparm3))
   END

   WHILE @n_Qty > 0
   BEGIN
      INSERT @T_RESULT
      SELECT PARM1 = @c_Orderkey
           , PARM2 = ''
           , PARM3 = ''
           , PARM4 = ''
           , PARM5 = ''
           , PARM6 = ''
           , PARM7 = ''
           , PARM8 = ''
           , PARM9 = ''
           , PARM10 = ''
           , Key1 = 'Orderkey'
           , Key2 = ''
           , Key3 = ''
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
GRANT EXECUTE ON [dbo].[isp_Bartender_IRL_TRANSPLBL_GetParm] TO [NSQL]
GO