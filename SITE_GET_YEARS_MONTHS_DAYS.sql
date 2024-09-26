CREATE OR ALTER PROCEDURE SITE_GET_YEARS_MONTHS_DAYS (
    BEGIN_DATE DATE,
    END_DATE DATE
)
RETURNS (
    YEARS INTEGER,
    MONTHS INTEGER,
    DAYS INTEGER
)
AS
DECLARE VARIABLE TEMP_DATE DATE;
BEGIN
    -- Инициализируем переменные
    YEARS = 0;
    MONTHS = 0;
    DAYS = 0;

    IF (END_DATE < BEGIN_DATE) THEN
    BEGIN
        SUSPEND;
        EXIT;
    END

    -- Вычисляем разницу в годах, месяцах и днях
    YEARS = EXTRACT(YEAR FROM END_DATE) - EXTRACT(YEAR FROM BEGIN_DATE);
    MONTHS = EXTRACT(MONTH FROM END_DATE) - EXTRACT(MONTH FROM BEGIN_DATE);
    DAYS = EXTRACT(DAY FROM END_DATE) - EXTRACT(DAY FROM BEGIN_DATE);

--    -- Корректируем дни
--    IF (DAYS < 0) THEN
--    BEGIN
--        TEMP_DATE = DATEADD(-1 MONTH TO END_DATE);
--        DAYS = DAYS + EXTRACT(DAY FROM TEMP_DATE);
--        MONTHS = MONTHS - 1;
--    END

    -- Убедимся, что дни не отрицательные
    IF (DAYS < 0) THEN
    BEGIN
        TEMP_DATE = DATEADD(-1 DAY TO DATEADD(MONTH, MONTHS, DATEADD(YEAR, YEARS, BEGIN_DATE)));
        DAYS = DAYS + EXTRACT(DAY FROM TEMP_DATE);
        MONTHS = MONTHS - 1;

        --IF (MONTHS < 0) THEN
        --BEGIN
        --    YEARS = YEARS - 1;
        --    MONTHS = MONTHS + 12;
        --END
    END

        -- Корректируем месяцы
    IF (MONTHS < 0) THEN
    BEGIN
        YEARS = YEARS - 1;
        MONTHS = MONTHS + 12;
    END

        -- Убедимся что года не -
    IF (YEARS < 0) THEN
        YEARS = 0;

    SUSPEND;
END;
