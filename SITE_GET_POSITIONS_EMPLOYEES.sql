CREATE OR ALTER PROCEDURE SITE_GET_POSITIONS_EMPLOYEES
RETURNS (
    POSITIONS varchar(4000)
)
AS
BEGIN
FOR
     SELECT
        DISTINCT V3543.val
    FROM
        VALS V3543
    WHERE
        V3543.PARAM_ID = 3543
        AND V3543.IS_DEL = 0
    ORDER BY
        CASE
            WHEN LEFT(V3543.val, 1) = 'У' THEN 0
            WHEN LEFT(V3543.val, 1) = 'П' THEN 1
            WHEN LEFT(V3543.val, 1) = 'З' THEN 3
            WHEN LEFT(V3543.val, 1) = 'М' THEN 4
            WHEN LEFT(V3543.val, 1) = 'С' THEN 5
            WHEN LEFT(V3543.val, 1) = 'Д' THEN 6
            ELSE 10
        END
    INTO
        POSITIONS
    DO BEGIN
        SUSPEND;
    END
END
