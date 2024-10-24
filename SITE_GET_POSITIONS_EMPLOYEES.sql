CREATE OR ALTER PROCEDURE SITE_GET_POSITIONS_EMPLOYEES
RETURNS (
    POSITIONS varchar(4000)
)
AS
BEGIN
FOR
    SELECT
        DISTINCT V66.val
    FROM
        VALS V66
    WHERE
        V66.PARAM_ID = 66
        AND V66.IS_DEL = 0
    ORDER BY
        CASE
            WHEN LEFT(V66.val, 1) = 'У' THEN 0
            WHEN LEFT(V66.val, 1) = 'П' THEN 1
            WHEN LEFT(V66.val, 1) = 'З' THEN 3
            WHEN LEFT(V66.val, 1) = 'М' THEN 4
            WHEN LEFT(V66.val, 1) = 'С' THEN 5
            WHEN LEFT(V66.val, 1) = 'Д' THEN 6
            ELSE 10
        END
    INTO
        POSITIONS
    DO BEGIN
        SUSPEND;
    END
END