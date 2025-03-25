\echo 'Введите название таблицы: '
\prompt name_table

SELECT pg_catalog.set_config('s368929.table_name', :'name_table', false);

DO
$$
    DECLARE
        target_table TEXT;
        schema_rec   RECORD;
        table_count  INT;
    BEGIN
        target_table := current_setting('s368929.table_name', true);
        
        SELECT COUNT(DISTINCT n.nspname)
        INTO table_count
        FROM pg_class c
                 JOIN pg_namespace n ON c.relnamespace = n.oid
        WHERE c.relname = target_table;

        IF table_count < 1 THEN
            RAISE EXCEPTION 'Таблица "%" не найдена!', target_table;
        ELSE
            RAISE NOTICE ' ';
            RAISE NOTICE 'Выберите схему, с которой вы хотите получить данные:';
            RAISE NOTICE '-------------------------------------';

            FOR schema_rec IN
                SELECT DISTINCT n.nspname AS schema_name
                FROM pg_class c
                         JOIN pg_namespace n ON c.relnamespace = n.oid
                WHERE c.relname = target_table
                ORDER BY n.nspname
                LOOP
                    RAISE NOTICE '%', schema_rec.schema_name;
                END LOOP;

            RAISE NOTICE '-------------------------------------';
            RAISE NOTICE 'Всего найдено схем: %', table_count;
            RAISE NOTICE ' ';
        END IF;
    END
$$ LANGUAGE plpgsql;
