
DO
$$
    DECLARE
        target_table  TEXT := 'students';
        target_schema TEXT := 's336456';
        col_rec       RECORD;
        header        TEXT;
        divider       TEXT;
        output_line   TEXT;
    BEGIN
        header := lpad('No', 4) || ' | ' ||
                  lpad('Имя столбца', 16) || ' | ' ||
                  lpad('Тип данных', 16) || ' | ' ||
                  lpad('Комментарий', 20) || ' | ' ||
                  lpad('Ограничения', 20);

        divider := lpad('', 4, '-') || '-+-' ||
                   lpad('', 16, '-') || '-+-' ||
                   lpad('', 16, '-') || '-+-' ||
                   lpad('', 20, '-') || '-+-' ||
                   lpad('', 20, '-');

        RAISE NOTICE ' ';
        RAISE NOTICE 'Таблица: %.%', target_schema, target_table;
        RAISE NOTICE ' ';
        RAISE NOTICE '%', header;
        RAISE NOTICE '%', divider;

        FOR col_rec IN
            SELECT row_number() OVER ()                       AS no,
                   a.attname                                  AS column_name,
                   format_type(a.atttypid, a.atttypmod)       AS data_type,
                   COALESCE(d.description, 'Нет комментария') AS comment,
                   CASE
                       WHEN c.conname IS NOT NULL THEN c.conname || ' (' || c.contype::text || ')'
                       WHEN a.attnotnull THEN 'NOT NULL'
                       ELSE 'Нет'
                       END                                    AS constraints
            FROM pg_attribute a
                     JOIN pg_class cl ON cl.oid = a.attrelid
                     JOIN pg_namespace n ON n.oid = cl.relnamespace
                     LEFT JOIN pg_description d ON d.objoid = a.attrelid AND d.objsubid = a.attnum
                     LEFT JOIN pg_constraint c ON c.conrelid = cl.oid AND a.attnum = ANY (c.conkey)
            WHERE cl.relname = target_table
              AND n.nspname = target_schema
              AND a.attnum > 0
              AND NOT a.attisdropped
            ORDER BY a.attnum
            LOOP
                output_line := lpad(col_rec.no::text, 4) || ' | ' ||
                               lpad(col_rec.column_name, 16) || ' | ' ||
                               lpad(CASE
                                        WHEN length(col_rec.data_type) > 16 THEN
                                            substring(col_rec.data_type from 1 for 13) || '...'
                                        ELSE col_rec.data_type END, 16) || ' | ' ||
                               lpad(CASE
                                        WHEN length(col_rec.comment) > 20 THEN
                                            substring(col_rec.comment from 1 for 17) || '...'
                                        ELSE col_rec.comment END, 20) || ' | ' ||
                               lpad(CASE
                                        WHEN length(col_rec.constraints) > 20 THEN
                                            substring(col_rec.constraints from 1 for 17) || '...'
                                        ELSE col_rec.constraints END, 20);

                RAISE NOTICE '%', output_line;
            END LOOP;

        RAISE NOTICE '%', divider;
        RAISE NOTICE ' ';
    END
$$ LANGUAGE plpgsql;