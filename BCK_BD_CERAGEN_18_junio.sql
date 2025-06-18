PGDMP  :    
                }         
   db_ceragen    15.13    16.0    \           0    0    ENCODING    ENCODING        SET client_encoding = 'UTF8';
                      false            ]           0    0 
   STDSTRINGS 
   STDSTRINGS     (   SET standard_conforming_strings = 'on';
                      false            ^           0    0 
   SEARCHPATH 
   SEARCHPATH     8   SELECT pg_catalog.set_config('search_path', '', false);
                      false            _           1262    26483 
   db_ceragen    DATABASE     v   CREATE DATABASE db_ceragen WITH TEMPLATE = template0 ENCODING = 'UTF8' LOCALE_PROVIDER = libc LOCALE = 'en_US.UTF-8';
    DROP DATABASE db_ceragen;
                uceragen    false                        2615    26485     ceragen    SCHEMA        CREATE SCHEMA ceragen;
    DROP SCHEMA ceragen;
                uceragen    false            8           1255    26486    register_insert_event()    FUNCTION     7  CREATE FUNCTION ceragen.register_insert_event() RETURNS trigger
    LANGUAGE plpgsql
    AS $$DECLARE
    table_id INTEGER;
    user_id INTEGER;
BEGIN
    -- Obtener el ID de la tabla
    SELECT aut_id INTO table_id
    FROM ceragen.audi_tables
    WHERE aut_table_name = TG_TABLE_NAME;

    -- Verificar que la tabla exista en audi_tables
    IF table_id IS NULL THEN
        RAISE EXCEPTION 'No se encontrÃ³ la tabla en ceragen.audi_tables: %', TG_TABLE_NAME;
    END IF;

    -- Obtener el ID del usuario basado en user_created
    SELECT su.user_id INTO user_id
    FROM ceragen.segu_user su
    WHERE su.user_login_id = NEW.user_created 
    AND su.user_state = true 
    AND su.user_locked = false;
    

    -- Verificar si el usuario tiene permisos
    IF user_id IS NULL THEN
        RAISE EXCEPTION 'El usuario no tiene permisos suficientes para realizar esta operaciÃ³n.';
    END IF;

    -- Insertar el registro del evento de inserciÃ³n en la tabla de auditorÃ­a
    INSERT INTO ceragen.audi_sql_events_register (
        ser_table_id,
        ser_sql_command_type,
        ser_new_record_detail,
        ser_user_process_id,
        ser_date_event
    ) VALUES (
        table_id,
        'INSERT',
        jsonb_strip_nulls(ROW_TO_JSON(NEW)::jsonb)::TEXT,
        user_id,
        NOW()
    );

    RETURN NEW;
END;
$$;
 /   DROP FUNCTION ceragen.register_insert_event();
        ceragen          secoed    false    6            9           1255    26487    register_login_event()    FUNCTION        CREATE FUNCTION ceragen.register_login_event() RETURNS trigger
    LANGUAGE plpgsql
    AS $$DECLARE
    table_id INTEGER;
    sql_command_type TEXT;
BEGIN
    -- Obtener el ID de la tabla
    SELECT aut_id INTO table_id
    FROM ceragen.audi_tables
    WHERE aut_table_name = TG_TABLE_NAME;

    -- Verificar que la tabla existe en audi_tables
    IF table_id IS NULL THEN
        RAISE EXCEPTION 'No se encontrÃ³ la tabla en ceragen.audi_tables: %', TG_TABLE_NAME;
    END IF;

    -- Determinar el tipo de operaciÃ³n (INSERT o UPDATE)
    sql_command_type := TG_OP;

    -- Insertar el registro en la tabla de auditorÃ­a
    INSERT INTO ceragen.audi_sql_events_register (
        ser_table_id,
        ser_sql_command_type,
        ser_new_record_detail,
        ser_old_record_detail,
        ser_user_process_id,
        ser_date_event
    ) VALUES (
        table_id,
        sql_command_type,
        jsonb_strip_nulls(ROW_TO_JSON(NEW)::jsonb)::TEXT,
        CASE WHEN sql_command_type = 'UPDATE' THEN jsonb_strip_nulls(ROW_TO_JSON(OLD)::jsonb)::TEXT ELSE NULL END,
        NEW.slo_user_id,  -- Usar el ID del usuario directamente
        NOW()
    );

    RETURN NEW;
END;$$;
 .   DROP FUNCTION ceragen.register_login_event();
        ceragen          secoed    false    6            :           1255    26488    register_update_event()    FUNCTION     x   CREATE FUNCTION ceragen.register_update_event() RETURNS trigger
    LANGUAGE plpgsql
    AS $$DECLARE
    table_id INTEGER;
    user_id INTEGER;
    sql_command_type TEXT;
BEGIN
    -- Obtener el ID de la tabla
    SELECT aut_id INTO table_id
    FROM ceragen.audi_tables
    WHERE aut_table_name = TG_TABLE_NAME;

    -- Validar que la tabla existe en audi_tables
    IF table_id IS NULL THEN
        RAISE EXCEPTION 'No se encontrÃ³ la tabla en ceragen.audi_tables: %', TG_TABLE_NAME;
    END IF;

    -- Determinar si es una eliminaciÃ³n lÃ³gica o una actualizaciÃ³n
    IF OLD.date_deleted IS DISTINCT FROM NEW.date_deleted AND NEW.date_deleted IS NOT NULL THEN
        sql_command_type := 'DELETE';
    ELSIF OLD.date_modified IS DISTINCT FROM NEW.date_modified THEN
        sql_command_type := 'UPDATE';
    ELSE
        RETURN NEW; -- No hay cambios relevantes
    END IF;

    -- Obtener el usuario responsable de la acciÃ³n
    SELECT su.user_id INTO user_id
    FROM ceragen.segu_user su
    WHERE su.user_login_id = 
        CASE 
            WHEN sql_command_type = 'DELETE' THEN NEW.user_deleted 
            ELSE NEW.user_modified 
        END
    AND su.user_state = TRUE 
    AND su.user_locked = FALSE;
    

    -- Verificar permisos del usuario
    IF user_id IS NULL THEN
        RAISE EXCEPTION 'El usuario no tiene permisos suficientes para realizar esta operaciÃ³n.';
    END IF;

    -- Registrar el evento en la tabla de auditorÃ­a
    INSERT INTO ceragen.audi_sql_events_register (
        ser_table_id,
        ser_sql_command_type,
        ser_new_record_detail,
        ser_old_record_detail,
        ser_user_process_id,
        ser_date_event
    ) VALUES (
        table_id,
        sql_command_type,
        jsonb_strip_nulls(ROW_TO_JSON(NEW)::jsonb)::TEXT,
        jsonb_strip_nulls(ROW_TO_JSON(OLD)::jsonb)::TEXT,
        user_id,
        NOW()
    );

    RETURN NEW;
END;$$;
 /   DROP FUNCTION ceragen.register_update_event();
        ceragen          secoed    false    6                       1259    27357    admin_client    TABLE     i  CREATE TABLE ceragen.admin_client (
    cli_id integer NOT NULL,
    cli_person_id integer NOT NULL,
    cli_identification character varying(13) NOT NULL,
    cli_name character varying(100) NOT NULL,
    cli_address_bill character varying(200),
    cli_mail_bill character varying(100),
    cli_state boolean DEFAULT true NOT NULL,
    user_created character varying(100) NOT NULL,
    date_created timestamp without time zone NOT NULL,
    user_modified character varying(100),
    date_modified timestamp without time zone,
    user_deleted character varying(100),
    date_deleted timestamp without time zone
);
 !   DROP TABLE ceragen.admin_client;
        ceragen         heap    uceragen    false    6                       1259    27356    admin_client_cli_id_seq    SEQUENCE        CREATE SEQUENCE ceragen.admin_client_cli_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 /   DROP SEQUENCE ceragen.admin_client_cli_id_seq;
        ceragen          uceragen    false    260    6            `           0    0    admin_client_cli_id_seq    SEQUENCE OWNED BY     U   ALTER SEQUENCE ceragen.admin_client_cli_id_seq OWNED BY ceragen.admin_client.cli_id;
           ceragen          uceragen    false    259            ü            1259    27281 
   admin_expense    TABLE       CREATE TABLE ceragen.admin_expense (
    exp_id integer NOT NULL,
    exp_type_id integer NOT NULL,
    exp_payment_method_id integer NOT NULL,
    exp_date timestamp without time zone NOT NULL,
    exp_amount numeric(12,2) NOT NULL,
    exp_description character varying(200),
    exp_receipt_number character varying(100),
    exp_state boolean DEFAULT true NOT NULL,
    user_created character varying(100) NOT NULL,
    date_created timestamp without time zone NOT NULL,
    user_modified character varying(100),
    date_modified timestamp without time zone,
    user_deleted character varying(100),
    date_deleted timestamp without time zone
);
 "   DROP TABLE ceragen.admin_expense;
        ceragen         heap    uceragen    false    6            û            1259    27280    admin_expense_exp_id_seq    SEQUENCE     ‘   CREATE SEQUENCE ceragen.admin_expense_exp_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 0   DROP SEQUENCE ceragen.admin_expense_exp_id_seq;
        ceragen          uceragen    false    6    252            a           0    0    admin_expense_exp_id_seq    SEQUENCE OWNED BY     W   ALTER SEQUENCE ceragen.admin_expense_exp_id_seq OWNED BY ceragen.admin_expense.exp_id;
           ceragen          uceragen    false    251            ú            1259    27273    admin_expense_type    TABLE     ñ  CREATE TABLE ceragen.admin_expense_type (
    ext_id integer NOT NULL,
    ext_name character varying(40) NOT NULL,
    ext_description character varying(100) NOT NULL,
    ext_state boolean DEFAULT true NOT NULL,
    user_created character varying(100) NOT NULL,
    date_created timestamp without time zone NOT NULL,
    user_modified character varying(100),
    date_modified timestamp without time zone,
    user_deleted character varying(100),
    date_deleted timestamp without time zone
);
 '   DROP TABLE ceragen.admin_expense_type;
        ceragen         heap    uceragen    false    6            ù            1259    27272    admin_expense_type_ext_id_seq    SEQUENCE     –   CREATE SEQUENCE ceragen.admin_expense_type_ext_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 5   DROP SEQUENCE ceragen.admin_expense_type_ext_id_seq;
        ceragen          uceragen    false    6    250            b           0    0    admin_expense_type_ext_id_seq    SEQUENCE OWNED BY     a   ALTER SEQUENCE ceragen.admin_expense_type_ext_id_seq OWNED BY ceragen.admin_expense_type.ext_id;
           ceragen          uceragen    false    249            "           1259    27699 
   admin_invoice    TABLE     (  CREATE TABLE ceragen.admin_invoice (
    inv_id integer NOT NULL,
    inv_number character varying(20) NOT NULL,
    inv_date timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    inv_client_id integer NOT NULL,
    inv_patient_id integer,
    inv_subtotal numeric(10,2) NOT NULL,
    inv_discount numeric(10,2) DEFAULT 0,
    inv_tax numeric(10,2) DEFAULT 0,
    inv_grand_total numeric(10,2) GENERATED ALWAYS AS (((inv_subtotal - inv_discount) + inv_tax)) STORED,
    inv_state boolean DEFAULT true NOT NULL,
    user_created character varying(100) NOT NULL,
    date_created timestamp without time zone NOT NULL,
    user_modified character varying(100),
    date_modified timestamp without time zone,
    user_deleted character varying(100),
    date_deleted timestamp without time zone
);
 "   DROP TABLE ceragen.admin_invoice;
        ceragen         heap    postgres    false    6            $           1259    27724    admin_invoice_detail    TABLE     O  CREATE TABLE ceragen.admin_invoice_detail (
    ind_id integer NOT NULL,
    ind_invoice_id integer NOT NULL,
    ind_product_id integer NOT NULL,
    ind_quantity integer NOT NULL,
    ind_unit_price numeric(10,2) NOT NULL,
    ind_total numeric(10,2) NOT NULL,
    ind_state boolean DEFAULT true NOT NULL,
    user_created character varying(100) NOT NULL,
    date_created timestamp without time zone NOT NULL,
    user_modified character varying(100),
    date_modified timestamp without time zone,
    user_deleted character varying(100),
    date_deleted timestamp without time zone
);
 )   DROP TABLE ceragen.admin_invoice_detail;
        ceragen         heap    postgres    false    6            #           1259    27723    admin_invoice_detail_ind_id_seq    SEQUENCE     ˜   CREATE SEQUENCE ceragen.admin_invoice_detail_ind_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 7   DROP SEQUENCE ceragen.admin_invoice_detail_ind_id_seq;
        ceragen          postgres    false    292    6            c           0    0    admin_invoice_detail_ind_id_seq    SEQUENCE OWNED BY     e   ALTER SEQUENCE ceragen.admin_invoice_detail_ind_id_seq OWNED BY ceragen.admin_invoice_detail.ind_id;
           ceragen          postgres    false    291            !           1259    27698    admin_invoice_inv_id_seq    SEQUENCE     ‘   CREATE SEQUENCE ceragen.admin_invoice_inv_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 0   DROP SEQUENCE ceragen.admin_invoice_inv_id_seq;
        ceragen          postgres    false    6    290            d           0    0    admin_invoice_inv_id_seq    SEQUENCE OWNED BY     W   ALTER SEQUENCE ceragen.admin_invoice_inv_id_seq OWNED BY ceragen.admin_invoice.inv_id;
           ceragen          postgres    false    289            &           1259    27742    admin_invoice_payment    TABLE     S  CREATE TABLE ceragen.admin_invoice_payment (
    inp_id integer NOT NULL,
    inp_invoice_id integer NOT NULL,
    inp_payment_method_id integer NOT NULL,
    inp_amount numeric(10,2) NOT NULL,
    inp_reference character varying(100),
    inp_proof_image_path text,
    inp_state boolean DEFAULT true NOT NULL,
    user_created character varying(100) NOT NULL,
    date_created timestamp without time zone NOT NULL,
    user_modified character varying(100),
    date_modified timestamp without time zone,
    user_deleted character varying(100),
    date_deleted timestamp without time zone
);
 *   DROP TABLE ceragen.admin_invoice_payment;
        ceragen         heap    postgres    false    6            %           1259    27741     admin_invoice_payment_inp_id_seq    SEQUENCE     ™   CREATE SEQUENCE ceragen.admin_invoice_payment_inp_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 8   DROP SEQUENCE ceragen.admin_invoice_payment_inp_id_seq;
        ceragen          postgres    false    6    294            e           0    0     admin_invoice_payment_inp_id_seq    SEQUENCE OWNED BY     g   ALTER SEQUENCE ceragen.admin_invoice_payment_inp_id_seq OWNED BY ceragen.admin_invoice_payment.inp_id;
           ceragen          postgres    false    293            *           1259    27772    admin_invoice_tax    TABLE     ÿ  CREATE TABLE ceragen.admin_invoice_tax (
    int_id integer NOT NULL,
    int_invoice_id integer NOT NULL,
    int_tax_id integer NOT NULL,
    int_tax_amount numeric(10,2) NOT NULL,
    int_state boolean DEFAULT true NOT NULL,
    user_created character varying(100) NOT NULL,
    date_created timestamp without time zone NOT NULL,
    user_modified character varying(100),
    date_modified timestamp without time zone,
    user_deleted character varying(100),
    date_deleted timestamp without time zone
);
 &   DROP TABLE ceragen.admin_invoice_tax;
        ceragen         heap    postgres    false    6            )           1259    27771    admin_invoice_tax_int_id_seq    SEQUENCE     •   CREATE SEQUENCE ceragen.admin_invoice_tax_int_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 4   DROP SEQUENCE ceragen.admin_invoice_tax_int_id_seq;
        ceragen          postgres    false    6    298            f           0    0    admin_invoice_tax_int_id_seq    SEQUENCE OWNED BY     _   ALTER SEQUENCE ceragen.admin_invoice_tax_int_id_seq OWNED BY ceragen.admin_invoice_tax.int_id;
           ceragen          postgres    false    297            ×            1259    26513    admin_marital_status    TABLE     º  CREATE TABLE ceragen.admin_marital_status (
    id integer NOT NULL,
    status_name character varying(100) NOT NULL,
    state boolean DEFAULT true NOT NULL,
    user_created character varying(100) NOT NULL,
    date_created timestamp without time zone NOT NULL,
    user_modified character varying(100),
    date_modified timestamp without time zone,
    user_deleted character varying(100),
    date_deleted timestamp without time zone
);
 )   DROP TABLE ceragen.admin_marital_status;
        ceragen         heap    secoed    false    6            Ø            1259    26517    admin_marital_status_id_seq    SEQUENCE     ”   CREATE SEQUENCE ceragen.admin_marital_status_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 3   DROP SEQUENCE ceragen.admin_marital_status_id_seq;
        ceragen          secoed    false    215    6            g           0    0    admin_marital_status_id_seq    SEQUENCE OWNED BY     ]   ALTER SEQUENCE ceragen.admin_marital_status_id_seq OWNED BY ceragen.admin_marital_status.id;
           ceragen          secoed    false    216            ô            1259    27237    admin_medic_person_type    TABLE     ì  CREATE TABLE ceragen.admin_medic_person_type (
    mpt_id integer NOT NULL,
    mpt_name character varying(30) NOT NULL,
    mpt_description character varying(80),
    mpt_state boolean DEFAULT true NOT NULL,
    user_created character varying(100) NOT NULL,
    date_created timestamp without time zone NOT NULL,
    user_modified character varying(100),
    date_modified timestamp without time zone,
    user_deleted character varying(100),
    date_deleted timestamp without time zone
);
 ,   DROP TABLE ceragen.admin_medic_person_type;
        ceragen         heap    uceragen    false    6            ó            1259    27236 "   admin_medic_person_type_mpt_id_seq    SEQUENCE     ›   CREATE SEQUENCE ceragen.admin_medic_person_type_mpt_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 :   DROP SEQUENCE ceragen.admin_medic_person_type_mpt_id_seq;
        ceragen          uceragen    false    6    244            h           0    0 "   admin_medic_person_type_mpt_id_seq    SEQUENCE OWNED BY     k   ALTER SEQUENCE ceragen.admin_medic_person_type_mpt_id_seq OWNED BY ceragen.admin_medic_person_type.mpt_id;
           ceragen          uceragen    false    243            ö            1259    27245    admin_medical_staff    TABLE     3  CREATE TABLE ceragen.admin_medical_staff (
    med_id integer NOT NULL,
    med_person_id integer NOT NULL,
    med_type_id integer NOT NULL,
    med_registration_number character varying(50),
    med_specialty character varying(100),
    med_state boolean DEFAULT true NOT NULL,
    user_created character varying(100) NOT NULL,
    date_created timestamp without time zone NOT NULL,
    user_modified character varying(100),
    date_modified timestamp without time zone,
    user_deleted character varying(100),
    date_deleted timestamp without time zone
);
 (   DROP TABLE ceragen.admin_medical_staff;
        ceragen         heap    uceragen    false    6            õ            1259    27244    admin_medical_staff_med_id_seq    SEQUENCE     —   CREATE SEQUENCE ceragen.admin_medical_staff_med_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 6   DROP SEQUENCE ceragen.admin_medical_staff_med_id_seq;
        ceragen          uceragen    false    6    246            i           0    0    admin_medical_staff_med_id_seq    SEQUENCE OWNED BY     c   ALTER SEQUENCE ceragen.admin_medical_staff_med_id_seq OWNED BY ceragen.admin_medical_staff.med_id;
           ceragen          uceragen    false    245            Ù            1259    26518    admin_parameter_list    TABLE     g  CREATE TABLE ceragen.admin_parameter_list (
    pli_id integer NOT NULL,
    pli_code_parameter character varying(100) NOT NULL,
    pli_is_numeric_return_value boolean DEFAULT true NOT NULL,
    pli_string_value_return character varying(100),
    pli_numeric_value_return numeric(8,2),
    pli_state boolean DEFAULT true NOT NULL,
    user_created character varying(100) NOT NULL,
    date_created timestamp without time zone NOT NULL,
    user_modified character varying(100),
    date_modified timestamp without time zone,
    user_deleted character varying(100),
    date_deleted timestamp without time zone
);
 )   DROP TABLE ceragen.admin_parameter_list;
        ceragen         heap    uceragen    false    6            Ú            1259    26525    admin_parameter_list_pli_id_seq    SEQUENCE     ˜   CREATE SEQUENCE ceragen.admin_parameter_list_pli_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 7   DROP SEQUENCE ceragen.admin_parameter_list_pli_id_seq;
        ceragen          uceragen    false    6    217            j           0    0    admin_parameter_list_pli_id_seq    SEQUENCE OWNED BY     e   ALTER SEQUENCE ceragen.admin_parameter_list_pli_id_seq OWNED BY ceragen.admin_parameter_list.pli_id;
           ceragen          uceragen    false    218                       1259    27514 
   admin_patient    TABLE     Æ  CREATE TABLE ceragen.admin_patient (
    pat_id integer NOT NULL,
    pat_person_id integer NOT NULL,
    pat_client_id integer NOT NULL,
    pat_code character varying(20),
    pat_medical_conditions text,
    pat_allergies text,
    pat_blood_type character varying(3),
    pat_emergency_contact_name character varying(100),
    pat_emergency_contact_phone character varying(20),
    pat_state boolean DEFAULT true NOT NULL,
    user_created character varying(100) NOT NULL,
    date_created timestamp without time zone NOT NULL,
    user_modified character varying(100),
    date_modified timestamp without time zone,
    user_deleted character varying(100),
    date_deleted timestamp without time zone
);
 "   DROP TABLE ceragen.admin_patient;
        ceragen         heap    uceragen    false    6                       1259    27513    admin_patient_pat_id_seq    SEQUENCE     ‘   CREATE SEQUENCE ceragen.admin_patient_pat_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 0   DROP SEQUENCE ceragen.admin_patient_pat_id_seq;
        ceragen          uceragen    false    6    276            k           0    0    admin_patient_pat_id_seq    SEQUENCE OWNED BY     W   ALTER SEQUENCE ceragen.admin_patient_pat_id_seq OWNED BY ceragen.admin_patient.pat_id;
           ceragen          uceragen    false    275            ø            1259    27263    admin_payment_method    TABLE     l  CREATE TABLE ceragen.admin_payment_method (
    pme_id integer NOT NULL,
    pme_name character varying(40) NOT NULL,
    pme_description character varying(100) NOT NULL,
    pme_require_references boolean DEFAULT false NOT NULL,
    pme_require_picture_proff boolean DEFAULT false NOT NULL,
    pme_state boolean DEFAULT true NOT NULL,
    user_created character varying(100) NOT NULL,
    date_created timestamp without time zone NOT NULL,
    user_modified character varying(100),
    date_modified timestamp without time zone,
    user_deleted character varying(100),
    date_deleted timestamp without time zone
);
 )   DROP TABLE ceragen.admin_payment_method;
        ceragen         heap    uceragen    false    6            ÷            1259    27262    admin_payment_method_pme_id_seq    SEQUENCE     ˜   CREATE SEQUENCE ceragen.admin_payment_method_pme_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 7   DROP SEQUENCE ceragen.admin_payment_method_pme_id_seq;
        ceragen          uceragen    false    6    248            l           0    0    admin_payment_method_pme_id_seq    SEQUENCE OWNED BY     e   ALTER SEQUENCE ceragen.admin_payment_method_pme_id_seq OWNED BY ceragen.admin_payment_method.pme_id;
           ceragen          uceragen    false    247            Û            1259    26534    admin_person    TABLE     `  CREATE TABLE ceragen.admin_person (
    per_id integer NOT NULL,
    per_identification character varying(20) NOT NULL,
    per_names character varying(100) NOT NULL,
    per_surnames character varying(100) NOT NULL,
    per_genre_id integer NOT NULL,
    per_marital_status_id integer NOT NULL,
    per_country character varying(100),
    per_city character varying(100),
    per_address character varying(200),
    per_phone character varying(100),
    per_mail character varying(100),
    per_birth_date timestamp without time zone,
    per_state boolean DEFAULT true NOT NULL,
    user_created character varying(100) NOT NULL,
    date_created timestamp without time zone NOT NULL,
    user_modified character varying(100),
    date_modified timestamp without time zone,
    user_deleted character varying(100),
    date_deleted timestamp without time zone
);
 !   DROP TABLE ceragen.admin_person;
        ceragen         heap    uceragen    false    6            Ü            1259    26540    admin_person_genre    TABLE     ·  CREATE TABLE ceragen.admin_person_genre (
    id integer NOT NULL,
    genre_name character varying(100) NOT NULL,
    state boolean DEFAULT true NOT NULL,
    user_created character varying(100) NOT NULL,
    date_created timestamp without time zone NOT NULL,
    user_modified character varying(100),
    date_modified timestamp without time zone,
    user_deleted character varying(100),
    date_deleted timestamp without time zone
);
 '   DROP TABLE ceragen.admin_person_genre;
        ceragen         heap    uceragen    false    6            Ý            1259    26544    admin_person_genre_id_seq    SEQUENCE     ’   CREATE SEQUENCE ceragen.admin_person_genre_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 1   DROP SEQUENCE ceragen.admin_person_genre_id_seq;
        ceragen          uceragen    false    220    6            m           0    0    admin_person_genre_id_seq    SEQUENCE OWNED BY     Y   ALTER SEQUENCE ceragen.admin_person_genre_id_seq OWNED BY ceragen.admin_person_genre.id;
           ceragen          uceragen    false    221            Þ            1259    26545    admin_person_per_id_seq    SEQUENCE        CREATE SEQUENCE ceragen.admin_person_per_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 /   DROP SEQUENCE ceragen.admin_person_per_id_seq;
        ceragen          uceragen    false    6    219            n           0    0    admin_person_per_id_seq    SEQUENCE OWNED BY     U   ALTER SEQUENCE ceragen.admin_person_per_id_seq OWNED BY ceragen.admin_person.per_id;
           ceragen          uceragen    false    222                        1259    27323 
   admin_product    TABLE     Á  CREATE TABLE ceragen.admin_product (
    pro_id integer NOT NULL,
    pro_code character varying(20) NOT NULL,
    pro_name character varying(100) NOT NULL,
    pro_description text,
    pro_price numeric(10,2) NOT NULL,
    pro_total_sessions integer NOT NULL,
    pro_duration_days integer,
    pro_image_url character varying(200),
    pro_therapy_type_id integer NOT NULL,
    pro_state boolean DEFAULT true NOT NULL,
    user_created character varying(100) NOT NULL,
    date_created timestamp without time zone NOT NULL,
    user_modified character varying(100),
    date_modified timestamp without time zone,
    user_deleted character varying(100),
    date_deleted timestamp without time zone
);
 "   DROP TABLE ceragen.admin_product;
        ceragen         heap    uceragen    false    6            ÿ            1259    27322    admin_product_pro_id_seq    SEQUENCE     ‘   CREATE SEQUENCE ceragen.admin_product_pro_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 0   DROP SEQUENCE ceragen.admin_product_pro_id_seq;
        ceragen          uceragen    false    6    256            o           0    0    admin_product_pro_id_seq    SEQUENCE OWNED BY     W   ALTER SEQUENCE ceragen.admin_product_pro_id_seq OWNED BY ceragen.admin_product.pro_id;
           ceragen          uceragen    false    255                       1259    27340    admin_product_promotion    TABLE     ž  CREATE TABLE ceragen.admin_product_promotion (
    ppr_id integer NOT NULL,
    ppr_product_id integer NOT NULL,
    ppr_name character varying(100) NOT NULL,
    ppr_description text,
    ppr_discount_percent numeric(5,2) DEFAULT 0,
    ppr_extra_sessions integer DEFAULT 0,
    ppr_start_date date NOT NULL,
    ppr_end_date date NOT NULL,
    ppr_state boolean DEFAULT true NOT NULL,
    user_created character varying(100) NOT NULL,
    date_created timestamp without time zone NOT NULL,
    user_modified character varying(100),
    date_modified timestamp without time zone,
    user_deleted character varying(100),
    date_deleted timestamp without time zone
);
 ,   DROP TABLE ceragen.admin_product_promotion;
        ceragen         heap    uceragen    false    6                       1259    27339 "   admin_product_promotion_ppr_id_seq    SEQUENCE     ›   CREATE SEQUENCE ceragen.admin_product_promotion_ppr_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 :   DROP SEQUENCE ceragen.admin_product_promotion_ppr_id_seq;
        ceragen          uceragen    false    6    258            p           0    0 "   admin_product_promotion_ppr_id_seq    SEQUENCE OWNED BY     k   ALTER SEQUENCE ceragen.admin_product_promotion_ppr_id_seq OWNED BY ceragen.admin_product_promotion.ppr_id;
           ceragen          uceragen    false    257            (           1259    27762 	   admin_tax    TABLE     ÷  CREATE TABLE ceragen.admin_tax (
    tax_id integer NOT NULL,
    tax_name character varying(50) NOT NULL,
    tax_percentage numeric(5,2) NOT NULL,
    tax_description text,
    tax_state boolean DEFAULT true NOT NULL,
    user_created character varying(100) NOT NULL,
    date_created timestamp without time zone NOT NULL,
    user_modified character varying(100),
    date_modified timestamp without time zone,
    user_deleted character varying(100),
    date_deleted timestamp without time zone
);
    DROP TABLE ceragen.admin_tax;
        ceragen         heap    postgres    false    6            '           1259    27761    admin_tax_tax_id_seq    SEQUENCE        CREATE SEQUENCE ceragen.admin_tax_tax_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 ,   DROP SEQUENCE ceragen.admin_tax_tax_id_seq;
        ceragen          postgres    false    296    6            q           0    0    admin_tax_tax_id_seq    SEQUENCE OWNED BY     O   ALTER SEQUENCE ceragen.admin_tax_tax_id_seq OWNED BY ceragen.admin_tax.tax_id;
           ceragen          postgres    false    295            þ            1259    27313    admin_therapy_type    TABLE     Ö  CREATE TABLE ceragen.admin_therapy_type (
    tht_id integer NOT NULL,
    tht_name character varying(50) NOT NULL,
    tht_description text,
    tht_state boolean DEFAULT true NOT NULL,
    user_created character varying(100) NOT NULL,
    date_created timestamp without time zone NOT NULL,
    user_modified character varying(100),
    date_modified timestamp without time zone,
    user_deleted character varying(100),
    date_deleted timestamp without time zone
);
 '   DROP TABLE ceragen.admin_therapy_type;
        ceragen         heap    uceragen    false    6            ý            1259    27312    admin_therapy_type_tht_id_seq    SEQUENCE     –   CREATE SEQUENCE ceragen.admin_therapy_type_tht_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 5   DROP SEQUENCE ceragen.admin_therapy_type_tht_id_seq;
        ceragen          uceragen    false    254    6            r           0    0    admin_therapy_type_tht_id_seq    SEQUENCE OWNED BY     a   ALTER SEQUENCE ceragen.admin_therapy_type_tht_id_seq OWNED BY ceragen.admin_therapy_type.tht_id;
           ceragen          uceragen    false    253            ß            1259    26553    audi_sql_events_register    TABLE     Y  CREATE TABLE ceragen.audi_sql_events_register (
    ser_id integer NOT NULL,
    ser_table_id integer,
    ser_sql_command_type character varying(20),
    ser_new_record_detail character varying(1000),
    ser_old_record_detail character varying(1000),
    ser_user_process_id integer,
    ser_date_event timestamp without time zone NOT NULL
);
 -   DROP TABLE ceragen.audi_sql_events_register;
        ceragen         heap    uceragen    false    6            à            1259    26558 #   audi_sql_events_register_ser_id_seq    SEQUENCE     œ   CREATE SEQUENCE ceragen.audi_sql_events_register_ser_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 ;   DROP SEQUENCE ceragen.audi_sql_events_register_ser_id_seq;
        ceragen          uceragen    false    6    223            s           0    0 #   audi_sql_events_register_ser_id_seq    SEQUENCE OWNED BY     m   ALTER SEQUENCE ceragen.audi_sql_events_register_ser_id_seq OWNED BY ceragen.audi_sql_events_register.ser_id;
           ceragen          uceragen    false    224            á            1259    26559 
   audi_tables    TABLE     î  CREATE TABLE ceragen.audi_tables (
    aut_id integer NOT NULL,
    aut_table_name character varying(100) NOT NULL,
    aut_table_descriptiom character varying(300),
    aut_state boolean DEFAULT true NOT NULL,
    user_created character varying(100) NOT NULL,
    date_created timestamp without time zone NOT NULL,
    user_modified character varying(100),
    date_modified timestamp without time zone,
    user_deleted character varying(100),
    date_deleted timestamp without time zone
);
     DROP TABLE ceragen.audi_tables;
        ceragen         heap    uceragen    false    6            â            1259    26565    audi_tables_aut_id_seq    SEQUENCE        CREATE SEQUENCE ceragen.audi_tables_aut_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 .   DROP SEQUENCE ceragen.audi_tables_aut_id_seq;
        ceragen          uceragen    false    6    225            t           0    0    audi_tables_aut_id_seq    SEQUENCE OWNED BY     S   ALTER SEQUENCE ceragen.audi_tables_aut_id_seq OWNED BY ceragen.audi_tables.aut_id;
           ceragen          uceragen    false    226                       1259    27626    clinic_allergy_catalog    TABLE     Î  CREATE TABLE ceragen.clinic_allergy_catalog (
    al_id integer NOT NULL,
    al_name character varying(100) NOT NULL,
    al_description text,
    al_state boolean DEFAULT true,
    user_created character varying(100) NOT NULL,
    date_created timestamp without time zone NOT NULL,
    user_modified character varying(100),
    date_modified timestamp without time zone,
    user_deleted character varying(100),
    date_deleted timestamp without time zone
);
 +   DROP TABLE ceragen.clinic_allergy_catalog;
        ceragen         heap    uceragen    false    6                       1259    27625     clinic_allergy_catalog_al_id_seq    SEQUENCE     ™   CREATE SEQUENCE ceragen.clinic_allergy_catalog_al_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 8   DROP SEQUENCE ceragen.clinic_allergy_catalog_al_id_seq;
        ceragen          uceragen    false    6    286            u           0    0     clinic_allergy_catalog_al_id_seq    SEQUENCE OWNED BY     g   ALTER SEQUENCE ceragen.clinic_allergy_catalog_al_id_seq OWNED BY ceragen.clinic_allergy_catalog.al_id;
           ceragen          uceragen    false    285                       1259    27591    clinic_disease_catalog    TABLE     ý  CREATE TABLE ceragen.clinic_disease_catalog (
    dis_id integer NOT NULL,
    dis_name character varying(100) NOT NULL,
    dis_description text,
    dis_type_id integer NOT NULL,
    dis_state boolean DEFAULT true NOT NULL,
    user_created character varying(100) NOT NULL,
    date_created timestamp without time zone NOT NULL,
    user_modified character varying(100),
    date_modified timestamp without time zone,
    user_deleted character varying(100),
    date_deleted timestamp without time zone
);
 +   DROP TABLE ceragen.clinic_disease_catalog;
        ceragen         heap    uceragen    false    6                       1259    27590 !   clinic_disease_catalog_dis_id_seq    SEQUENCE     š   CREATE SEQUENCE ceragen.clinic_disease_catalog_dis_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 9   DROP SEQUENCE ceragen.clinic_disease_catalog_dis_id_seq;
        ceragen          uceragen    false    6    282            v           0    0 !   clinic_disease_catalog_dis_id_seq    SEQUENCE OWNED BY     i   ALTER SEQUENCE ceragen.clinic_disease_catalog_dis_id_seq OWNED BY ceragen.clinic_disease_catalog.dis_id;
           ceragen          uceragen    false    281                       1259    27581    clinic_disease_type    TABLE     Ø  CREATE TABLE ceragen.clinic_disease_type (
    dst_id integer NOT NULL,
    dst_name character varying(100) NOT NULL,
    dst_description text,
    dst_state boolean DEFAULT true NOT NULL,
    user_created character varying(100) NOT NULL,
    date_created timestamp without time zone NOT NULL,
    user_modified character varying(100),
    date_modified timestamp without time zone,
    user_deleted character varying(100),
    date_deleted timestamp without time zone
);
 (   DROP TABLE ceragen.clinic_disease_type;
        ceragen         heap    uceragen    false    6                       1259    27580    clinic_disease_type_dst_id_seq    SEQUENCE     —   CREATE SEQUENCE ceragen.clinic_disease_type_dst_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 6   DROP SEQUENCE ceragen.clinic_disease_type_dst_id_seq;
        ceragen          uceragen    false    6    280            w           0    0    clinic_disease_type_dst_id_seq    SEQUENCE OWNED BY     c   ALTER SEQUENCE ceragen.clinic_disease_type_dst_id_seq OWNED BY ceragen.clinic_disease_type.dst_id;
           ceragen          uceragen    false    279                        1259    27636    clinic_patient_allergy    TABLE     ½  CREATE TABLE ceragen.clinic_patient_allergy (
    pa_id integer NOT NULL,
    pa_patient_id integer NOT NULL,
    pa_allergy_id integer NOT NULL,
    pa_reaction_description text,
    user_created character varying(100),
    date_created timestamp without time zone,
    user_modified character varying(100),
    date_modified timestamp without time zone,
    user_deleted character varying(100),
    date_deleted timestamp without time zone
);
 +   DROP TABLE ceragen.clinic_patient_allergy;
        ceragen         heap    uceragen    false    6                       1259    27635     clinic_patient_allergy_pa_id_seq    SEQUENCE     ™   CREATE SEQUENCE ceragen.clinic_patient_allergy_pa_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 8   DROP SEQUENCE ceragen.clinic_patient_allergy_pa_id_seq;
        ceragen          uceragen    false    288    6            x           0    0     clinic_patient_allergy_pa_id_seq    SEQUENCE OWNED BY     g   ALTER SEQUENCE ceragen.clinic_patient_allergy_pa_id_seq OWNED BY ceragen.clinic_patient_allergy.pa_id;
           ceragen          uceragen    false    287                       1259    27606    clinic_patient_disease    TABLE     Ö  CREATE TABLE ceragen.clinic_patient_disease (
    pd_id integer NOT NULL,
    pd_patient_id integer NOT NULL,
    pd_disease_id integer NOT NULL,
    pd_is_current boolean DEFAULT true,
    pd_notes text,
    user_created character varying(100),
    date_created timestamp without time zone,
    user_modified character varying(100),
    date_modified timestamp without time zone,
    user_deleted character varying(100),
    date_deleted timestamp without time zone
);
 +   DROP TABLE ceragen.clinic_patient_disease;
        ceragen         heap    uceragen    false    6                       1259    27605     clinic_patient_disease_pd_id_seq    SEQUENCE     ™   CREATE SEQUENCE ceragen.clinic_patient_disease_pd_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 8   DROP SEQUENCE ceragen.clinic_patient_disease_pd_id_seq;
        ceragen          uceragen    false    6    284            y           0    0     clinic_patient_disease_pd_id_seq    SEQUENCE OWNED BY     g   ALTER SEQUENCE ceragen.clinic_patient_disease_pd_id_seq OWNED BY ceragen.clinic_patient_disease.pd_id;
           ceragen          uceragen    false    283                       1259    27537    clinic_patient_medical_history    TABLE     '  CREATE TABLE ceragen.clinic_patient_medical_history (
    hist_id integer NOT NULL,
    hist_patient_id integer NOT NULL,
    hist_primary_complaint text,
    hist_onset_date date,
    hist_related_trauma boolean,
    hist_current_treatment text,
    hist_notes text,
    user_created character varying(100) NOT NULL,
    date_created timestamp without time zone NOT NULL,
    user_modified character varying(100),
    date_modified timestamp without time zone,
    user_deleted character varying(100),
    date_deleted timestamp without time zone
);
 3   DROP TABLE ceragen.clinic_patient_medical_history;
        ceragen         heap    uceragen    false    6                       1259    27536 *   clinic_patient_medical_history_hist_id_seq    SEQUENCE     £   CREATE SEQUENCE ceragen.clinic_patient_medical_history_hist_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 B   DROP SEQUENCE ceragen.clinic_patient_medical_history_hist_id_seq;
        ceragen          uceragen    false    278    6            z           0    0 *   clinic_patient_medical_history_hist_id_seq    SEQUENCE OWNED BY     {   ALTER SEQUENCE ceragen.clinic_patient_medical_history_hist_id_seq OWNED BY ceragen.clinic_patient_medical_history.hist_id;
           ceragen          uceragen    false    277            ,           1259    27899    clinic_session_control    TABLE     Ú  CREATE TABLE ceragen.clinic_session_control (
    sec_id integer NOT NULL,
    sec_inv_id integer NOT NULL,
    sec_pro_id integer NOT NULL,
    sec_ses_number integer NOT NULL,
    sec_ses_agend_date timestamp without time zone,
    sec_ses_exec_date timestamp without time zone,
    sec_typ_id integer NOT NULL,
    sec_med_staff_id integer NOT NULL,
    ses_consumed boolean DEFAULT false NOT NULL,
    ses_state boolean DEFAULT true NOT NULL,
    user_created character varying(100) NOT NULL,
    date_created timestamp without time zone NOT NULL,
    user_modified character varying(100),
    date_modified timestamp without time zone,
    user_deleted character varying(100),
    date_deleted timestamp without time zone
);
 +   DROP TABLE ceragen.clinic_session_control;
        ceragen         heap    postgres    false    6            +           1259    27898 !   clinic_session_control_sec_id_seq    SEQUENCE     š   CREATE SEQUENCE ceragen.clinic_session_control_sec_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 9   DROP SEQUENCE ceragen.clinic_session_control_sec_id_seq;
        ceragen          postgres    false    6    300            {           0    0 !   clinic_session_control_sec_id_seq    SEQUENCE OWNED BY     i   ALTER SEQUENCE ceragen.clinic_session_control_sec_id_seq OWNED BY ceragen.clinic_session_control.sec_id;
           ceragen          postgres    false    299            ã            1259    26702 
   segu_login    TABLE     m  CREATE TABLE ceragen.segu_login (
    slo_id integer NOT NULL,
    slo_user_id integer NOT NULL,
    slo_token character varying(1000) NOT NULL,
    slo_origin_ip character varying(100) NOT NULL,
    slo_host_name character varying(100),
    slo_date_start_connection timestamp without time zone NOT NULL,
    slo_date_end_connection timestamp without time zone
);
    DROP TABLE ceragen.segu_login;
        ceragen         heap    uceragen    false    6            ä            1259    26707    segu_login_slo_id_seq    SEQUENCE     Ž   CREATE SEQUENCE ceragen.segu_login_slo_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 -   DROP SEQUENCE ceragen.segu_login_slo_id_seq;
        ceragen          uceragen    false    6    227            |           0    0    segu_login_slo_id_seq    SEQUENCE OWNED BY     Q   ALTER SEQUENCE ceragen.segu_login_slo_id_seq OWNED BY ceragen.segu_login.slo_id;
           ceragen          uceragen    false    228            å            1259    26708 	   segu_menu    TABLE     ´  CREATE TABLE ceragen.segu_menu (
    menu_id integer NOT NULL,
    menu_name character varying(100) NOT NULL,
    menu_order integer NOT NULL,
    menu_module_id integer NOT NULL,
    menu_parent_id integer,
    menu_icon_name character varying(100),
    menu_href character varying(100),
    menu_url character varying(100),
    menu_key character varying(100),
    menu_state boolean DEFAULT true NOT NULL,
    user_created character varying(100) NOT NULL,
    date_created timestamp without time zone NOT NULL,
    user_modified character varying(100),
    date_modified timestamp without time zone,
    user_deleted character varying(100),
    date_deleted timestamp without time zone
);
    DROP TABLE ceragen.segu_menu;
        ceragen         heap    uceragen    false    6            æ            1259    26714    segu_menu_menu_id_seq    SEQUENCE     Ž   CREATE SEQUENCE ceragen.segu_menu_menu_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 -   DROP SEQUENCE ceragen.segu_menu_menu_id_seq;
        ceragen          uceragen    false    229    6            }           0    0    segu_menu_menu_id_seq    SEQUENCE OWNED BY     Q   ALTER SEQUENCE ceragen.segu_menu_menu_id_seq OWNED BY ceragen.segu_menu.menu_id;
           ceragen          uceragen    false    230            ç            1259    26715 
   segu_menu_rol    TABLE     É  CREATE TABLE ceragen.segu_menu_rol (
    mr_id integer NOT NULL,
    mr_menu_id integer NOT NULL,
    mr_rol_id integer NOT NULL,
    mr_state boolean DEFAULT true NOT NULL,
    user_created character varying(100) NOT NULL,
    date_created timestamp without time zone NOT NULL,
    user_modified character varying(100),
    date_modified timestamp without time zone,
    user_deleted character varying(100),
    date_deleted timestamp without time zone
);
 "   DROP TABLE ceragen.segu_menu_rol;
        ceragen         heap    uceragen    false    6            è            1259    26719    segu_menu_rol_mr_id_seq    SEQUENCE        CREATE SEQUENCE ceragen.segu_menu_rol_mr_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 /   DROP SEQUENCE ceragen.segu_menu_rol_mr_id_seq;
        ceragen          uceragen    false    231    6            ~           0    0    segu_menu_rol_mr_id_seq    SEQUENCE OWNED BY     U   ALTER SEQUENCE ceragen.segu_menu_rol_mr_id_seq OWNED BY ceragen.segu_menu_rol.mr_id;
           ceragen          uceragen    false    232            é            1259    26720 
   segu_module    TABLE     V  CREATE TABLE ceragen.segu_module (
    mod_id integer NOT NULL,
    mod_name character varying(100) NOT NULL,
    mod_description character varying(200),
    mod_order integer NOT NULL,
    mod_icon_name character varying(100),
    mod_text_name character varying(100),
    mod_state boolean DEFAULT true NOT NULL,
    user_created character varying(100) NOT NULL,
    date_created timestamp without time zone NOT NULL,
    user_modified character varying(100),
    date_modified timestamp without time zone,
    user_deleted character varying(100),
    date_deleted timestamp without time zone
);
     DROP TABLE ceragen.segu_module;
        ceragen         heap    uceragen    false    6            ê            1259    26726    segu_module_mod_id_seq    SEQUENCE        CREATE SEQUENCE ceragen.segu_module_mod_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 .   DROP SEQUENCE ceragen.segu_module_mod_id_seq;
        ceragen          uceragen    false    6    233                       0    0    segu_module_mod_id_seq    SEQUENCE OWNED BY     S   ALTER SEQUENCE ceragen.segu_module_mod_id_seq OWNED BY ceragen.segu_module.mod_id;
           ceragen          uceragen    false    234            ë            1259    26727    segu_rol    TABLE        CREATE TABLE ceragen.segu_rol (
    rol_id integer NOT NULL,
    rol_name character varying(100) NOT NULL,
    rol_description character varying(200),
    rol_state boolean DEFAULT true NOT NULL,
    user_created character varying(100) NOT NULL,
    date_created timestamp without time zone NOT NULL,
    user_modified character varying(100),
    date_modified timestamp without time zone,
    user_deleted character varying(100),
    date_deleted timestamp without time zone,
    is_admin_rol boolean DEFAULT false
);
    DROP TABLE ceragen.segu_rol;
        ceragen         heap    uceragen    false    6            ì            1259    26734    segu_rol_rol_id_seq    SEQUENCE     Œ   CREATE SEQUENCE ceragen.segu_rol_rol_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 +   DROP SEQUENCE ceragen.segu_rol_rol_id_seq;
        ceragen          uceragen    false    235    6            €           0    0    segu_rol_rol_id_seq    SEQUENCE OWNED BY     M   ALTER SEQUENCE ceragen.segu_rol_rol_id_seq OWNED BY ceragen.segu_rol.rol_id;
           ceragen          uceragen    false    236            í            1259    26735 	   segu_user    TABLE     ò  CREATE TABLE ceragen.segu_user (
    user_id integer NOT NULL,
    user_person_id integer NOT NULL,
    user_login_id character varying(100) NOT NULL,
    user_mail character varying(100) NOT NULL,
    user_password character varying(200) NOT NULL,
    user_locked boolean DEFAULT false NOT NULL,
    user_state boolean DEFAULT true NOT NULL,
    user_last_login timestamp without time zone,
    user_created character varying(100) NOT NULL,
    date_created timestamp without time zone NOT NULL,
    user_modified character varying(100),
    date_modified timestamp without time zone,
    user_deleted character varying(100),
    date_deleted timestamp without time zone,
    login_attempts integer DEFAULT 0,
    twofa_enabled boolean DEFAULT false
);
    DROP TABLE ceragen.segu_user;
        ceragen         heap    uceragen    false    6            î            1259    26743    segu_user_notification    TABLE     '  CREATE TABLE ceragen.segu_user_notification (
    sun_id integer NOT NULL,
    sun_user_source_id integer NOT NULL,
    sun_user_destination_id integer NOT NULL,
    sun_title_notification character varying(200) NOT NULL,
    sun_text_notification character varying(1000) NOT NULL,
    sun_date_notification timestamp without time zone NOT NULL,
    sun_state_notification boolean DEFAULT true NOT NULL,
    sun_isread_notification boolean DEFAULT false NOT NULL,
    sun_date_read_notification timestamp without time zone,
    user_created character varying(100) NOT NULL,
    date_created timestamp without time zone NOT NULL,
    user_modified character varying(100),
    date_modified timestamp without time zone,
    user_deleted character varying(100),
    date_deleted timestamp without time zone
);
 +   DROP TABLE ceragen.segu_user_notification;
        ceragen         heap    uceragen    false    6            ï            1259    26750 !   segu_user_notification_sun_id_seq    SEQUENCE     š   CREATE SEQUENCE ceragen.segu_user_notification_sun_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 9   DROP SEQUENCE ceragen.segu_user_notification_sun_id_seq;
        ceragen          uceragen    false    6    238                       0    0 !   segu_user_notification_sun_id_seq    SEQUENCE OWNED BY     i   ALTER SEQUENCE ceragen.segu_user_notification_sun_id_seq OWNED BY ceragen.segu_user_notification.sun_id;
           ceragen          uceragen    false    239            ð            1259    26751 
   segu_user_rol    TABLE     °  CREATE TABLE ceragen.segu_user_rol (
    id_user_rol integer NOT NULL,
    id_user integer NOT NULL,
    id_rol integer NOT NULL,
    user_created character varying(100) NOT NULL,
    date_created timestamp without time zone NOT NULL,
    user_modified character varying(100),
    date_modified timestamp without time zone,
    user_deleted character varying(100),
    date_deleted timestamp without time zone,
    state boolean
);
 "   DROP TABLE ceragen.segu_user_rol;
        ceragen         heap    uceragen    false    6            ñ            1259    26759    segu_user_rol_id_user_rol_seq    SEQUENCE     –   CREATE SEQUENCE ceragen.segu_user_rol_id_user_rol_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 5   DROP SEQUENCE ceragen.segu_user_rol_id_user_rol_seq;
        ceragen          uceragen    false    240    6            ‚           0    0    segu_user_rol_id_user_rol_seq    SEQUENCE OWNED BY     a   ALTER SEQUENCE ceragen.segu_user_rol_id_user_rol_seq OWNED BY ceragen.segu_user_rol.id_user_rol;
           ceragen          uceragen    false    241            ò            1259    26760    segu_user_user_id_seq    SEQUENCE     Ž   CREATE SEQUENCE ceragen.segu_user_user_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 -   DROP SEQUENCE ceragen.segu_user_user_id_seq;
        ceragen          uceragen    false    237    6            ƒ           0    0    segu_user_user_id_seq    SEQUENCE OWNED BY     Q   ALTER SEQUENCE ceragen.segu_user_user_id_seq OWNED BY ceragen.segu_user.user_id;
           ceragen          uceragen    false    242                       1259    27454    clinic_allergy_catalog    TABLE     Í  CREATE TABLE public.clinic_allergy_catalog (
    al_id integer NOT NULL,
    al_name character varying(100) NOT NULL,
    al_description text,
    al_state boolean DEFAULT true,
    user_created character varying(100) NOT NULL,
    date_created timestamp without time zone NOT NULL,
    user_modified character varying(100),
    date_modified timestamp without time zone,
    user_deleted character varying(100),
    date_deleted timestamp without time zone
);
 *   DROP TABLE public.clinic_allergy_catalog;
       public         heap    postgres    false            
           1259    27453     clinic_allergy_catalog_al_id_seq    SEQUENCE     ˜   CREATE SEQUENCE public.clinic_allergy_catalog_al_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 7   DROP SEQUENCE public.clinic_allergy_catalog_al_id_seq;
       public          postgres    false    268            „           0    0     clinic_allergy_catalog_al_id_seq    SEQUENCE OWNED BY     e   ALTER SEQUENCE public.clinic_allergy_catalog_al_id_seq OWNED BY public.clinic_allergy_catalog.al_id;
          public          postgres    false    267                       1259    27497    clinic_blood_type    TABLE     Ó  CREATE TABLE public.clinic_blood_type (
    btp_id integer NOT NULL,
    btp_type character varying(3) NOT NULL,
    btp_description text,
    btp_state boolean DEFAULT true NOT NULL,
    user_created character varying(100) NOT NULL,
    date_created timestamp without time zone NOT NULL,
    user_modified character varying(100),
    date_modified timestamp without time zone,
    user_deleted character varying(100),
    date_deleted timestamp without time zone
);
 %   DROP TABLE public.clinic_blood_type;
       public         heap    postgres    false                       1259    27496    clinic_blood_type_btp_id_seq    SEQUENCE     ”   CREATE SEQUENCE public.clinic_blood_type_btp_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 3   DROP SEQUENCE public.clinic_blood_type_btp_id_seq;
       public          postgres    false    274            …           0    0    clinic_blood_type_btp_id_seq    SEQUENCE OWNED BY     ]   ALTER SEQUENCE public.clinic_blood_type_btp_id_seq OWNED BY public.clinic_blood_type.btp_id;
          public          postgres    false    273                       1259    27483    clinic_consent_record    TABLE     1  CREATE TABLE public.clinic_consent_record (
    con_id integer NOT NULL,
    con_patient_id integer NOT NULL,
    con_type character varying(50) NOT NULL,
    con_signed_by character varying(100),
    con_signed_date date NOT NULL,
    con_relationship character varying(50),
    con_notes text,
    user_created character varying(100),
    date_created timestamp without time zone,
    user_modified character varying(100),
    date_modified timestamp without time zone,
    user_deleted character varying(100),
    date_deleted timestamp without time zone
);
 )   DROP TABLE public.clinic_consent_record;
       public         heap    postgres    false                       1259    27482     clinic_consent_record_con_id_seq    SEQUENCE     ˜   CREATE SEQUENCE public.clinic_consent_record_con_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 7   DROP SEQUENCE public.clinic_consent_record_con_id_seq;
       public          postgres    false    272            †           0    0     clinic_consent_record_con_id_seq    SEQUENCE OWNED BY     e   ALTER SEQUENCE public.clinic_consent_record_con_id_seq OWNED BY public.clinic_consent_record.con_id;
          public          postgres    false    271                       1259    27383    clinic_disease_catalog    TABLE     ü  CREATE TABLE public.clinic_disease_catalog (
    dis_id integer NOT NULL,
    dis_name character varying(100) NOT NULL,
    dis_description text,
    dis_type_id integer NOT NULL,
    dis_state boolean DEFAULT true NOT NULL,
    user_created character varying(100) NOT NULL,
    date_created timestamp without time zone NOT NULL,
    user_modified character varying(100),
    date_modified timestamp without time zone,
    user_deleted character varying(100),
    date_deleted timestamp without time zone
);
 *   DROP TABLE public.clinic_disease_catalog;
       public         heap    postgres    false                        1259    27382 !   clinic_disease_catalog_dis_id_seq    SEQUENCE     ™   CREATE SEQUENCE public.clinic_disease_catalog_dis_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 8   DROP SEQUENCE public.clinic_disease_catalog_dis_id_seq;
       public          postgres    false    264            ‡           0    0 !   clinic_disease_catalog_dis_id_seq    SEQUENCE OWNED BY     g   ALTER SEQUENCE public.clinic_disease_catalog_dis_id_seq OWNED BY public.clinic_disease_catalog.dis_id;
          public          postgres    false    263                       1259    27373    clinic_disease_type    TABLE     ×  CREATE TABLE public.clinic_disease_type (
    dst_id integer NOT NULL,
    dst_name character varying(100) NOT NULL,
    dst_description text,
    dst_state boolean DEFAULT true NOT NULL,
    user_created character varying(100) NOT NULL,
    date_created timestamp without time zone NOT NULL,
    user_modified character varying(100),
    date_modified timestamp without time zone,
    user_deleted character varying(100),
    date_deleted timestamp without time zone
);
 '   DROP TABLE public.clinic_disease_type;
       public         heap    postgres    false                       1259    27372    clinic_disease_type_dst_id_seq    SEQUENCE     –   CREATE SEQUENCE public.clinic_disease_type_dst_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 5   DROP SEQUENCE public.clinic_disease_type_dst_id_seq;
       public          postgres    false    262            ˆ           0    0    clinic_disease_type_dst_id_seq    SEQUENCE OWNED BY     a   ALTER SEQUENCE public.clinic_disease_type_dst_id_seq OWNED BY public.clinic_disease_type.dst_id;
          public          postgres    false    261                       1259    27464    clinic_patient_allergy    TABLE     ¼  CREATE TABLE public.clinic_patient_allergy (
    pa_id integer NOT NULL,
    pa_patient_id integer NOT NULL,
    pa_allergy_id integer NOT NULL,
    pa_reaction_description text,
    user_created character varying(100),
    date_created timestamp without time zone,
    user_modified character varying(100),
    date_modified timestamp without time zone,
    user_deleted character varying(100),
    date_deleted timestamp without time zone
);
 *   DROP TABLE public.clinic_patient_allergy;
       public         heap    postgres    false            
           1259    27463     clinic_patient_allergy_pa_id_seq    SEQUENCE     ˜   CREATE SEQUENCE public.clinic_patient_allergy_pa_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 7   DROP SEQUENCE public.clinic_patient_allergy_pa_id_seq;
       public          postgres    false    270            ‰           0    0     clinic_patient_allergy_pa_id_seq    SEQUENCE OWNED BY     e   ALTER SEQUENCE public.clinic_patient_allergy_pa_id_seq OWNED BY public.clinic_patient_allergy.pa_id;
          public          postgres    false    269            
           1259    27434    clinic_patient_disease    TABLE     Õ  CREATE TABLE public.clinic_patient_disease (
    pd_id integer NOT NULL,
    pd_patient_id integer NOT NULL,
    pd_disease_id integer NOT NULL,
    pd_is_current boolean DEFAULT true,
    pd_notes text,
    user_created character varying(100),
    date_created timestamp without time zone,
    user_modified character varying(100),
    date_modified timestamp without time zone,
    user_deleted character varying(100),
    date_deleted timestamp without time zone
);
 *   DROP TABLE public.clinic_patient_disease;
       public         heap    postgres    false            	           1259    27433     clinic_patient_disease_pd_id_seq    SEQUENCE     ˜   CREATE SEQUENCE public.clinic_patient_disease_pd_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 7   DROP SEQUENCE public.clinic_patient_disease_pd_id_seq;
       public          postgres    false    266            Š           0    0     clinic_patient_disease_pd_id_seq    SEQUENCE OWNED BY     e   ALTER SEQUENCE public.clinic_patient_disease_pd_id_seq OWNED BY public.clinic_patient_disease.pd_id;
          public          postgres    false    265            ¢
           2604    27360    admin_client cli_id     DEFAULT     |   ALTER TABLE ONLY ceragen.admin_client ALTER COLUMN cli_id SET DEFAULT nextval('ceragen.admin_client_cli_id_seq'::regclass);
 C   ALTER TABLE ceragen.admin_client ALTER COLUMN cli_id DROP DEFAULT;
        ceragen          uceragen    false    260    259    260            ˜
           2604    27284    admin_expense exp_id     DEFAULT     ~   ALTER TABLE ONLY ceragen.admin_expense ALTER COLUMN exp_id SET DEFAULT nextval('ceragen.admin_expense_exp_id_seq'::regclass);
 D   ALTER TABLE ceragen.admin_expense ALTER COLUMN exp_id DROP DEFAULT;
        ceragen          uceragen    false    252    251    252            –
           2604    27276    admin_expense_type ext_id     DEFAULT     ˆ   ALTER TABLE ONLY ceragen.admin_expense_type ALTER COLUMN ext_id SET DEFAULT nextval('ceragen.admin_expense_type_ext_id_seq'::regclass);
 I   ALTER TABLE ceragen.admin_expense_type ALTER COLUMN ext_id DROP DEFAULT;
        ceragen          uceragen    false    250    249    250            ¼
           2604    27702    admin_invoice inv_id     DEFAULT     ~   ALTER TABLE ONLY ceragen.admin_invoice ALTER COLUMN inv_id SET DEFAULT nextval('ceragen.admin_invoice_inv_id_seq'::regclass);
 D   ALTER TABLE ceragen.admin_invoice ALTER COLUMN inv_id DROP DEFAULT;
        ceragen          postgres    false    290    289    290            Â
           2604    27727    admin_invoice_detail ind_id     DEFAULT     Œ   ALTER TABLE ONLY ceragen.admin_invoice_detail ALTER COLUMN ind_id SET DEFAULT nextval('ceragen.admin_invoice_detail_ind_id_seq'::regclass);
 K   ALTER TABLE ceragen.admin_invoice_detail ALTER COLUMN ind_id DROP DEFAULT;
        ceragen          postgres    false    291    292    292            Ä
           2604    27745    admin_invoice_payment inp_id     DEFAULT     Ž   ALTER TABLE ONLY ceragen.admin_invoice_payment ALTER COLUMN inp_id SET DEFAULT nextval('ceragen.admin_invoice_payment_inp_id_seq'::regclass);
 L   ALTER TABLE ceragen.admin_invoice_payment ALTER COLUMN inp_id DROP DEFAULT;
        ceragen          postgres    false    293    294    294            È
           2604    27775    admin_invoice_tax int_id     DEFAULT     †   ALTER TABLE ONLY ceragen.admin_invoice_tax ALTER COLUMN int_id SET DEFAULT nextval('ceragen.admin_invoice_tax_int_id_seq'::regclass);
 H   ALTER TABLE ceragen.admin_invoice_tax ALTER COLUMN int_id DROP DEFAULT;
        ceragen          postgres    false    297    298    298            o
           2604    26765    admin_marital_status id     DEFAULT     „   ALTER TABLE ONLY ceragen.admin_marital_status ALTER COLUMN id SET DEFAULT nextval('ceragen.admin_marital_status_id_seq'::regclass);
 G   ALTER TABLE ceragen.admin_marital_status ALTER COLUMN id DROP DEFAULT;
        ceragen          secoed    false    216    215            Ž
           2604    27240    admin_medic_person_type mpt_id     DEFAULT     ’   ALTER TABLE ONLY ceragen.admin_medic_person_type ALTER COLUMN mpt_id SET DEFAULT nextval('ceragen.admin_medic_person_type_mpt_id_seq'::regclass);
 N   ALTER TABLE ceragen.admin_medic_person_type ALTER COLUMN mpt_id DROP DEFAULT;
        ceragen          uceragen    false    244    243    244            
           2604    27248    admin_medical_staff med_id     DEFAULT     Š   ALTER TABLE ONLY ceragen.admin_medical_staff ALTER COLUMN med_id SET DEFAULT nextval('ceragen.admin_medical_staff_med_id_seq'::regclass);
 J   ALTER TABLE ceragen.admin_medical_staff ALTER COLUMN med_id DROP DEFAULT;
        ceragen          uceragen    false    245    246    246            q
           2604    26766    admin_parameter_list pli_id     DEFAULT     Œ   ALTER TABLE ONLY ceragen.admin_parameter_list ALTER COLUMN pli_id SET DEFAULT nextval('ceragen.admin_parameter_list_pli_id_seq'::regclass);
 K   ALTER TABLE ceragen.admin_parameter_list ALTER COLUMN pli_id DROP DEFAULT;
        ceragen          uceragen    false    218    217            °
           2604    27517    admin_patient pat_id     DEFAULT     ~   ALTER TABLE ONLY ceragen.admin_patient ALTER COLUMN pat_id SET DEFAULT nextval('ceragen.admin_patient_pat_id_seq'::regclass);
 D   ALTER TABLE ceragen.admin_patient ALTER COLUMN pat_id DROP DEFAULT;
        ceragen          uceragen    false    276    275    276            ’
           2604    27266    admin_payment_method pme_id     DEFAULT     Œ   ALTER TABLE ONLY ceragen.admin_payment_method ALTER COLUMN pme_id SET DEFAULT nextval('ceragen.admin_payment_method_pme_id_seq'::regclass);
 K   ALTER TABLE ceragen.admin_payment_method ALTER COLUMN pme_id DROP DEFAULT;
        ceragen          uceragen    false    248    247    248            t
           2604    26768    admin_person per_id     DEFAULT     |   ALTER TABLE ONLY ceragen.admin_person ALTER COLUMN per_id SET DEFAULT nextval('ceragen.admin_person_per_id_seq'::regclass);
 C   ALTER TABLE ceragen.admin_person ALTER COLUMN per_id DROP DEFAULT;
        ceragen          uceragen    false    222    219            v
           2604    26769    admin_person_genre id     DEFAULT     €   ALTER TABLE ONLY ceragen.admin_person_genre ALTER COLUMN id SET DEFAULT nextval('ceragen.admin_person_genre_id_seq'::regclass);
 E   ALTER TABLE ceragen.admin_person_genre ALTER COLUMN id DROP DEFAULT;
        ceragen          uceragen    false    221    220            œ
           2604    27326    admin_product pro_id     DEFAULT     ~   ALTER TABLE ONLY ceragen.admin_product ALTER COLUMN pro_id SET DEFAULT nextval('ceragen.admin_product_pro_id_seq'::regclass);
 D   ALTER TABLE ceragen.admin_product ALTER COLUMN pro_id DROP DEFAULT;
        ceragen          uceragen    false    255    256    256            ž
           2604    27343    admin_product_promotion ppr_id     DEFAULT     ’   ALTER TABLE ONLY ceragen.admin_product_promotion ALTER COLUMN ppr_id SET DEFAULT nextval('ceragen.admin_product_promotion_ppr_id_seq'::regclass);
 N   ALTER TABLE ceragen.admin_product_promotion ALTER COLUMN ppr_id DROP DEFAULT;
        ceragen          uceragen    false    258    257    258            Æ
           2604    27765    admin_tax tax_id     DEFAULT     v   ALTER TABLE ONLY ceragen.admin_tax ALTER COLUMN tax_id SET DEFAULT nextval('ceragen.admin_tax_tax_id_seq'::regclass);
 @   ALTER TABLE ceragen.admin_tax ALTER COLUMN tax_id DROP DEFAULT;
        ceragen          postgres    false    296    295    296            š
           2604    27316    admin_therapy_type tht_id     DEFAULT     ˆ   ALTER TABLE ONLY ceragen.admin_therapy_type ALTER COLUMN tht_id SET DEFAULT nextval('ceragen.admin_therapy_type_tht_id_seq'::regclass);
 I   ALTER TABLE ceragen.admin_therapy_type ALTER COLUMN tht_id DROP DEFAULT;
        ceragen          uceragen    false    254    253    254            x
           2604    26771    audi_sql_events_register ser_id     DEFAULT     ”   ALTER TABLE ONLY ceragen.audi_sql_events_register ALTER COLUMN ser_id SET DEFAULT nextval('ceragen.audi_sql_events_register_ser_id_seq'::regclass);
 O   ALTER TABLE ceragen.audi_sql_events_register ALTER COLUMN ser_id DROP DEFAULT;
        ceragen          uceragen    false    224    223            y
           2604    26772    audi_tables aut_id     DEFAULT     z   ALTER TABLE ONLY ceragen.audi_tables ALTER COLUMN aut_id SET DEFAULT nextval('ceragen.audi_tables_aut_id_seq'::regclass);
 B   ALTER TABLE ceragen.audi_tables ALTER COLUMN aut_id DROP DEFAULT;
        ceragen          uceragen    false    226    225            ¹
           2604    27629    clinic_allergy_catalog al_id     DEFAULT     Ž   ALTER TABLE ONLY ceragen.clinic_allergy_catalog ALTER COLUMN al_id SET DEFAULT nextval('ceragen.clinic_allergy_catalog_al_id_seq'::regclass);
 L   ALTER TABLE ceragen.clinic_allergy_catalog ALTER COLUMN al_id DROP DEFAULT;
        ceragen          uceragen    false    285    286    286            µ
           2604    27594    clinic_disease_catalog dis_id     DEFAULT        ALTER TABLE ONLY ceragen.clinic_disease_catalog ALTER COLUMN dis_id SET DEFAULT nextval('ceragen.clinic_disease_catalog_dis_id_seq'::regclass);
 M   ALTER TABLE ceragen.clinic_disease_catalog ALTER COLUMN dis_id DROP DEFAULT;
        ceragen          uceragen    false    281    282    282            ³
           2604    27584    clinic_disease_type dst_id     DEFAULT     Š   ALTER TABLE ONLY ceragen.clinic_disease_type ALTER COLUMN dst_id SET DEFAULT nextval('ceragen.clinic_disease_type_dst_id_seq'::regclass);
 J   ALTER TABLE ceragen.clinic_disease_type ALTER COLUMN dst_id DROP DEFAULT;
        ceragen          uceragen    false    280    279    280            »
           2604    27639    clinic_patient_allergy pa_id     DEFAULT     Ž   ALTER TABLE ONLY ceragen.clinic_patient_allergy ALTER COLUMN pa_id SET DEFAULT nextval('ceragen.clinic_patient_allergy_pa_id_seq'::regclass);
 L   ALTER TABLE ceragen.clinic_patient_allergy ALTER COLUMN pa_id DROP DEFAULT;
        ceragen          uceragen    false    288    287    288            ·
           2604    27609    clinic_patient_disease pd_id     DEFAULT     Ž   ALTER TABLE ONLY ceragen.clinic_patient_disease ALTER COLUMN pd_id SET DEFAULT nextval('ceragen.clinic_patient_disease_pd_id_seq'::regclass);
 L   ALTER TABLE ceragen.clinic_patient_disease ALTER COLUMN pd_id DROP DEFAULT;
        ceragen          uceragen    false    283    284    284            ²
           2604    27540 &   clinic_patient_medical_history hist_id     DEFAULT     ¢   ALTER TABLE ONLY ceragen.clinic_patient_medical_history ALTER COLUMN hist_id SET DEFAULT nextval('ceragen.clinic_patient_medical_history_hist_id_seq'::regclass);
 V   ALTER TABLE ceragen.clinic_patient_medical_history ALTER COLUMN hist_id DROP DEFAULT;
        ceragen          uceragen    false    278    277    278            Ê
           2604    27902    clinic_session_control sec_id     DEFAULT        ALTER TABLE ONLY ceragen.clinic_session_control ALTER COLUMN sec_id SET DEFAULT nextval('ceragen.clinic_session_control_sec_id_seq'::regclass);
 M   ALTER TABLE ceragen.clinic_session_control ALTER COLUMN sec_id DROP DEFAULT;
        ceragen          postgres    false    300    299    300            {
           2604    26792    segu_login slo_id     DEFAULT     x   ALTER TABLE ONLY ceragen.segu_login ALTER COLUMN slo_id SET DEFAULT nextval('ceragen.segu_login_slo_id_seq'::regclass);
 A   ALTER TABLE ceragen.segu_login ALTER COLUMN slo_id DROP DEFAULT;
        ceragen          uceragen    false    228    227            |
           2604    26793    segu_menu menu_id     DEFAULT     x   ALTER TABLE ONLY ceragen.segu_menu ALTER COLUMN menu_id SET DEFAULT nextval('ceragen.segu_menu_menu_id_seq'::regclass);
 A   ALTER TABLE ceragen.segu_menu ALTER COLUMN menu_id DROP DEFAULT;
        ceragen          uceragen    false    230    229            ~
           2604    26794    segu_menu_rol mr_id     DEFAULT     |   ALTER TABLE ONLY ceragen.segu_menu_rol ALTER COLUMN mr_id SET DEFAULT nextval('ceragen.segu_menu_rol_mr_id_seq'::regclass);
 C   ALTER TABLE ceragen.segu_menu_rol ALTER COLUMN mr_id DROP DEFAULT;
        ceragen          uceragen    false    232    231            €
           2604    26795    segu_module mod_id     DEFAULT     z   ALTER TABLE ONLY ceragen.segu_module ALTER COLUMN mod_id SET DEFAULT nextval('ceragen.segu_module_mod_id_seq'::regclass);
 B   ALTER TABLE ceragen.segu_module ALTER COLUMN mod_id DROP DEFAULT;
        ceragen          uceragen    false    234    233            ‚
           2604    26796    segu_rol rol_id     DEFAULT     t   ALTER TABLE ONLY ceragen.segu_rol ALTER COLUMN rol_id SET DEFAULT nextval('ceragen.segu_rol_rol_id_seq'::regclass);
 ?   ALTER TABLE ceragen.segu_rol ALTER COLUMN rol_id DROP DEFAULT;
        ceragen          uceragen    false    236    235            …
           2604    26797    segu_user user_id     DEFAULT     x   ALTER TABLE ONLY ceragen.segu_user ALTER COLUMN user_id SET DEFAULT nextval('ceragen.segu_user_user_id_seq'::regclass);
 A   ALTER TABLE ceragen.segu_user ALTER COLUMN user_id DROP DEFAULT;
        ceragen          uceragen    false    242    237            Š
           2604    26798    segu_user_notification sun_id     DEFAULT        ALTER TABLE ONLY ceragen.segu_user_notification ALTER COLUMN sun_id SET DEFAULT nextval('ceragen.segu_user_notification_sun_id_seq'::regclass);
 M   ALTER TABLE ceragen.segu_user_notification ALTER COLUMN sun_id DROP DEFAULT;
        ceragen          uceragen    false    239    238            
           2604    26799    segu_user_rol id_user_rol     DEFAULT     ˆ   ALTER TABLE ONLY ceragen.segu_user_rol ALTER COLUMN id_user_rol SET DEFAULT nextval('ceragen.segu_user_rol_id_user_rol_seq'::regclass);
 I   ALTER TABLE ceragen.segu_user_rol ALTER COLUMN id_user_rol DROP DEFAULT;
        ceragen          uceragen    false    241    240            ª
           2604    27457    clinic_allergy_catalog al_id     DEFAULT     Œ   ALTER TABLE ONLY public.clinic_allergy_catalog ALTER COLUMN al_id SET DEFAULT nextval('public.clinic_allergy_catalog_al_id_seq'::regclass);
 K   ALTER TABLE public.clinic_allergy_catalog ALTER COLUMN al_id DROP DEFAULT;
       public          postgres    false    267    268    268            ®
           2604    27500    clinic_blood_type btp_id     DEFAULT     „   ALTER TABLE ONLY public.clinic_blood_type ALTER COLUMN btp_id SET DEFAULT nextval('public.clinic_blood_type_btp_id_seq'::regclass);
 G   ALTER TABLE public.clinic_blood_type ALTER COLUMN btp_id DROP DEFAULT;
       public          postgres    false    274    273    274            ­
           2604    27486    clinic_consent_record con_id     DEFAULT     Œ   ALTER TABLE ONLY public.clinic_consent_record ALTER COLUMN con_id SET DEFAULT nextval('public.clinic_consent_record_con_id_seq'::regclass);
 K   ALTER TABLE public.clinic_consent_record ALTER COLUMN con_id DROP DEFAULT;
       public          postgres    false    272    271    272            ¦
           2604    27386    clinic_disease_catalog dis_id     DEFAULT     Ž   ALTER TABLE ONLY public.clinic_disease_catalog ALTER COLUMN dis_id SET DEFAULT nextval('public.clinic_disease_catalog_dis_id_seq'::regclass);
 L   ALTER TABLE public.clinic_disease_catalog ALTER COLUMN dis_id DROP DEFAULT;
       public          postgres    false    264    263    264            ¤
           2604    27376    clinic_disease_type dst_id     DEFAULT     ˆ   ALTER TABLE ONLY public.clinic_disease_type ALTER COLUMN dst_id SET DEFAULT nextval('public.clinic_disease_type_dst_id_seq'::regclass);
 I   ALTER TABLE public.clinic_disease_type ALTER COLUMN dst_id DROP DEFAULT;
       public          postgres    false    262    261    262            ¬
           2604    27467    clinic_patient_allergy pa_id     DEFAULT     Œ   ALTER TABLE ONLY public.clinic_patient_allergy ALTER COLUMN pa_id SET DEFAULT nextval('public.clinic_patient_allergy_pa_id_seq'::regclass);
 K   ALTER TABLE public.clinic_patient_allergy ALTER COLUMN pa_id DROP DEFAULT;
       public          postgres    false    270    269    270            ¨
           2604    27437    clinic_patient_disease pd_id     DEFAULT     Œ   ALTER TABLE ONLY public.clinic_patient_disease ALTER COLUMN pd_id SET DEFAULT nextval('public.clinic_patient_disease_pd_id_seq'::regclass);
 K   ALTER TABLE public.clinic_patient_disease ALTER COLUMN pd_id DROP DEFAULT;
       public          postgres    false    265    266    266            1          0    27357    admin_client 
   TABLE DATA           Þ   COPY ceragen.admin_client (cli_id, cli_person_id, cli_identification, cli_name, cli_address_bill, cli_mail_bill, cli_state, user_created, date_created, user_modified, date_modified, user_deleted, date_deleted) FROM stdin;
     ceragen          uceragen    false    260   ^      )          0    27281 
   admin_expense 
   TABLE DATA           ð   COPY ceragen.admin_expense (exp_id, exp_type_id, exp_payment_method_id, exp_date, exp_amount, exp_description, exp_receipt_number, exp_state, user_created, date_created, user_modified, date_modified, user_deleted, date_deleted) FROM stdin;
     ceragen          uceragen    false    252   +^      '          0    27273    admin_expense_type 
   TABLE DATA           ±   COPY ceragen.admin_expense_type (ext_id, ext_name, ext_description, ext_state, user_created, date_created, user_modified, date_modified, user_deleted, date_deleted) FROM stdin;
     ceragen          uceragen    false    250   H^      O          0    27699 
   admin_invoice 
   TABLE DATA           ë   COPY ceragen.admin_invoice (inv_id, inv_number, inv_date, inv_client_id, inv_patient_id, inv_subtotal, inv_discount, inv_tax, inv_state, user_created, date_created, user_modified, date_modified, user_deleted, date_deleted) FROM stdin;
     ceragen          postgres    false    290   ³^      Q          0    27724    admin_invoice_detail 
   TABLE DATA           á   COPY ceragen.admin_invoice_detail (ind_id, ind_invoice_id, ind_product_id, ind_quantity, ind_unit_price, ind_total, ind_state, user_created, date_created, user_modified, date_modified, user_deleted, date_deleted) FROM stdin;
     ceragen          postgres    false    292   Ð^      S          0    27742    admin_invoice_payment 
   TABLE DATA           ñ   COPY ceragen.admin_invoice_payment (inp_id, inp_invoice_id, inp_payment_method_id, inp_amount, inp_reference, inp_proof_image_path, inp_state, user_created, date_created, user_modified, date_modified, user_deleted, date_deleted) FROM stdin;
     ceragen          postgres    false    294   í^      W          0    27772    admin_invoice_tax 
   TABLE DATA           Á   COPY ceragen.admin_invoice_tax (int_id, int_invoice_id, int_tax_id, int_tax_amount, int_state, user_created, date_created, user_modified, date_modified, user_deleted, date_deleted) FROM stdin;
     ceragen          postgres    false    298   
_                0    26513    admin_marital_status 
   TABLE DATA              COPY ceragen.admin_marital_status (id, status_name, state, user_created, date_created, user_modified, date_modified, user_deleted, date_deleted) FROM stdin;
     ceragen          secoed    false    215   '_      !          0    27237    admin_medic_person_type 
   TABLE DATA           ¶   COPY ceragen.admin_medic_person_type (mpt_id, mpt_name, mpt_description, mpt_state, user_created, date_created, user_modified, date_modified, user_deleted, date_deleted) FROM stdin;
     ceragen          uceragen    false    244   Ü_      #          0    27245    admin_medical_staff 
   TABLE DATA           Û   COPY ceragen.admin_medical_staff (med_id, med_person_id, med_type_id, med_registration_number, med_specialty, med_state, user_created, date_created, user_modified, date_modified, user_deleted, date_deleted) FROM stdin;
     ceragen          uceragen    false    246   e`                0    26518    admin_parameter_list 
   TABLE DATA           ü   COPY ceragen.admin_parameter_list (pli_id, pli_code_parameter, pli_is_numeric_return_value, pli_string_value_return, pli_numeric_value_return, pli_state, user_created, date_created, user_modified, date_modified, user_deleted, date_deleted) FROM stdin;
     ceragen          uceragen    false    217   ‚`      A          0    27514 
   admin_patient 
   TABLE DATA           )  COPY ceragen.admin_patient (pat_id, pat_person_id, pat_client_id, pat_code, pat_medical_conditions, pat_allergies, pat_blood_type, pat_emergency_contact_name, pat_emergency_contact_phone, pat_state, user_created, date_created, user_modified, date_modified, user_deleted, date_deleted) FROM stdin;
     ceragen          uceragen    false    276   ]a      %          0    27263    admin_payment_method 
   TABLE DATA           æ   COPY ceragen.admin_payment_method (pme_id, pme_name, pme_description, pme_require_references, pme_require_picture_proff, pme_state, user_created, date_created, user_modified, date_modified, user_deleted, date_deleted) FROM stdin;
     ceragen          uceragen    false    248   za                0    26534    admin_person 
   TABLE DATA           +  COPY ceragen.admin_person (per_id, per_identification, per_names, per_surnames, per_genre_id, per_marital_status_id, per_country, per_city, per_address, per_phone, per_mail, per_birth_date, per_state, user_created, date_created, user_modified, date_modified, user_deleted, date_deleted) FROM stdin;
     ceragen          uceragen    false    219   *b      	          0    26540    admin_person_genre 
   TABLE DATA           š   COPY ceragen.admin_person_genre (id, genre_name, state, user_created, date_created, user_modified, date_modified, user_deleted, date_deleted) FROM stdin;
     ceragen          uceragen    false    220   ¶e      -          0    27323 
   admin_product 
   TABLE DATA             COPY ceragen.admin_product (pro_id, pro_code, pro_name, pro_description, pro_price, pro_total_sessions, pro_duration_days, pro_image_url, pro_therapy_type_id, pro_state, user_created, date_created, user_modified, date_modified, user_deleted, date_deleted) FROM stdin;
     ceragen          uceragen    false    256   2f      /          0    27340    admin_product_promotion 
   TABLE DATA             COPY ceragen.admin_product_promotion (ppr_id, ppr_product_id, ppr_name, ppr_description, ppr_discount_percent, ppr_extra_sessions, ppr_start_date, ppr_end_date, ppr_state, user_created, date_created, user_modified, date_modified, user_deleted, date_deleted) FROM stdin;
     ceragen          uceragen    false    258   Of      U          0    27762 	   admin_tax 
   TABLE DATA           ¸   COPY ceragen.admin_tax (tax_id, tax_name, tax_percentage, tax_description, tax_state, user_created, date_created, user_modified, date_modified, user_deleted, date_deleted) FROM stdin;
     ceragen          postgres    false    296   lf      +          0    27313    admin_therapy_type 
   TABLE DATA           ±   COPY ceragen.admin_therapy_type (tht_id, tht_name, tht_description, tht_state, user_created, date_created, user_modified, date_modified, user_deleted, date_deleted) FROM stdin;
     ceragen          uceragen    false    254   ‰f                0    26553    audi_sql_events_register 
   TABLE DATA           ²   COPY ceragen.audi_sql_events_register (ser_id, ser_table_id, ser_sql_command_type, ser_new_record_detail, ser_old_record_detail, ser_user_process_id, ser_date_event) FROM stdin;
     ceragen          uceragen    false    223   ¦f                0    26559 
   audi_tables 
   TABLE DATA           ¶   COPY ceragen.audi_tables (aut_id, aut_table_name, aut_table_descriptiom, aut_state, user_created, date_created, user_modified, date_modified, user_deleted, date_deleted) FROM stdin;
     ceragen          uceragen    false    225   J“      K          0    27626    clinic_allergy_catalog 
   TABLE DATA           ±   COPY ceragen.clinic_allergy_catalog (al_id, al_name, al_description, al_state, user_created, date_created, user_modified, date_modified, user_deleted, date_deleted) FROM stdin;
     ceragen          uceragen    false    286   e•      G          0    27591    clinic_disease_catalog 
   TABLE DATA           Â   COPY ceragen.clinic_disease_catalog (dis_id, dis_name, dis_description, dis_type_id, dis_state, user_created, date_created, user_modified, date_modified, user_deleted, date_deleted) FROM stdin;
     ceragen          uceragen    false    282   ‚•      E          0    27581    clinic_disease_type 
   TABLE DATA           ²   COPY ceragen.clinic_disease_type (dst_id, dst_name, dst_description, dst_state, user_created, date_created, user_modified, date_modified, user_deleted, date_deleted) FROM stdin;
     ceragen          uceragen    false    280   Ÿ•      M          0    27636    clinic_patient_allergy 
   TABLE DATA           Å   COPY ceragen.clinic_patient_allergy (pa_id, pa_patient_id, pa_allergy_id, pa_reaction_description, user_created, date_created, user_modified, date_modified, user_deleted, date_deleted) FROM stdin;
     ceragen          uceragen    false    288   ¼•      I          0    27606    clinic_patient_disease 
   TABLE DATA           Å   COPY ceragen.clinic_patient_disease (pd_id, pd_patient_id, pd_disease_id, pd_is_current, pd_notes, user_created, date_created, user_modified, date_modified, user_deleted, date_deleted) FROM stdin;
     ceragen          uceragen    false    284   Ù•      C          0    27537    clinic_patient_medical_history 
   TABLE DATA           
  COPY ceragen.clinic_patient_medical_history (hist_id, hist_patient_id, hist_primary_complaint, hist_onset_date, hist_related_trauma, hist_current_treatment, hist_notes, user_created, date_created, user_modified, date_modified, user_deleted, date_deleted) FROM stdin;
     ceragen          uceragen    false    278   ö•      Y          0    27899    clinic_session_control 
   TABLE DATA             COPY ceragen.clinic_session_control (sec_id, sec_inv_id, sec_pro_id, sec_ses_number, sec_ses_agend_date, sec_ses_exec_date, sec_typ_id, sec_med_staff_id, ses_consumed, ses_state, user_created, date_created, user_modified, date_modified, user_deleted, date_deleted) FROM stdin;
     ceragen          postgres    false    300   –                0    26702 
   segu_login 
   TABLE DATA           —   COPY ceragen.segu_login (slo_id, slo_user_id, slo_token, slo_origin_ip, slo_host_name, slo_date_start_connection, slo_date_end_connection) FROM stdin;
     ceragen          uceragen    false    227   0–                0    26708 	   segu_menu 
   TABLE DATA           õ   COPY ceragen.segu_menu (menu_id, menu_name, menu_order, menu_module_id, menu_parent_id, menu_icon_name, menu_href, menu_url, menu_key, menu_state, user_created, date_created, user_modified, date_modified, user_deleted, date_deleted) FROM stdin;
     ceragen          uceragen    false    229   >‰                0    26715 
   segu_menu_rol 
   TABLE DATA           ¦   COPY ceragen.segu_menu_rol (mr_id, mr_menu_id, mr_rol_id, mr_state, user_created, date_created, user_modified, date_modified, user_deleted, date_deleted) FROM stdin;
     ceragen          uceragen    false    231   “                0    26720 
   segu_module 
   TABLE DATA           Ó   COPY ceragen.segu_module (mod_id, mod_name, mod_description, mod_order, mod_icon_name, mod_text_name, mod_state, user_created, date_created, user_modified, date_modified, user_deleted, date_deleted) FROM stdin;
     ceragen          uceragen    false    233   ß–                0    26727    segu_rol 
   TABLE DATA           µ   COPY ceragen.segu_rol (rol_id, rol_name, rol_description, rol_state, user_created, date_created, user_modified, date_modified, user_deleted, date_deleted, is_admin_rol) FROM stdin;
     ceragen          uceragen    false    235   ù˜                0    26735 	   segu_user 
   TABLE DATA             COPY ceragen.segu_user (user_id, user_person_id, user_login_id, user_mail, user_password, user_locked, user_state, user_last_login, user_created, date_created, user_modified, date_modified, user_deleted, date_deleted, login_attempts, twofa_enabled) FROM stdin;
     ceragen          uceragen    false    237   Yš                0    26743    segu_user_notification 
   TABLE DATA           O  COPY ceragen.segu_user_notification (sun_id, sun_user_source_id, sun_user_destination_id, sun_title_notification, sun_text_notification, sun_date_notification, sun_state_notification, sun_isread_notification, sun_date_read_notification, user_created, date_created, user_modified, date_modified, user_deleted, date_deleted) FROM stdin;
     ceragen          uceragen    false    238   U                0    26751 
   segu_user_rol 
   TABLE DATA           £   COPY ceragen.segu_user_rol (id_user_rol, id_user, id_rol, user_created, date_created, user_modified, date_modified, user_deleted, date_deleted, state) FROM stdin;
     ceragen          uceragen    false    240   r      9          0    27454    clinic_allergy_catalog 
   TABLE DATA           °   COPY public.clinic_allergy_catalog (al_id, al_name, al_description, al_state, user_created, date_created, user_modified, date_modified, user_deleted, date_deleted) FROM stdin;
    public          postgres    false    268   wž      ?          0    27497    clinic_blood_type 
   TABLE DATA           ¯   COPY public.clinic_blood_type (btp_id, btp_type, btp_description, btp_state, user_created, date_created, user_modified, date_modified, user_deleted, date_deleted) FROM stdin;
    public          postgres    false    274   ”ž      =          0    27483    clinic_consent_record 
   TABLE DATA           ä   COPY public.clinic_consent_record (con_id, con_patient_id, con_type, con_signed_by, con_signed_date, con_relationship, con_notes, user_created, date_created, user_modified, date_modified, user_deleted, date_deleted) FROM stdin;
    public          postgres    false    272   ±ž      5          0    27383    clinic_disease_catalog 
   TABLE DATA           Á   COPY public.clinic_disease_catalog (dis_id, dis_name, dis_description, dis_type_id, dis_state, user_created, date_created, user_modified, date_modified, user_deleted, date_deleted) FROM stdin;
    public          postgres    false    264   Îž      3          0    27373    clinic_disease_type 
   TABLE DATA           ±   COPY public.clinic_disease_type (dst_id, dst_name, dst_description, dst_state, user_created, date_created, user_modified, date_modified, user_deleted, date_deleted) FROM stdin;
    public          postgres    false    262   ëž      ;          0    27464    clinic_patient_allergy 
   TABLE DATA           Ä   COPY public.clinic_patient_allergy (pa_id, pa_patient_id, pa_allergy_id, pa_reaction_description, user_created, date_created, user_modified, date_modified, user_deleted, date_deleted) FROM stdin;
    public          postgres    false    270   Ÿ      7          0    27434    clinic_patient_disease 
   TABLE DATA           Ä   COPY public.clinic_patient_disease (pd_id, pd_patient_id, pd_disease_id, pd_is_current, pd_notes, user_created, date_created, user_modified, date_modified, user_deleted, date_deleted) FROM stdin;
    public          postgres    false    266   %Ÿ      ‹           0    0    admin_client_cli_id_seq    SEQUENCE SET     G   SELECT pg_catalog.setval('ceragen.admin_client_cli_id_seq', 1, false);
           ceragen          uceragen    false    259            Œ           0    0    admin_expense_exp_id_seq    SEQUENCE SET     H   SELECT pg_catalog.setval('ceragen.admin_expense_exp_id_seq', 1, false);
           ceragen          uceragen    false    251                       0    0    admin_expense_type_ext_id_seq    SEQUENCE SET     L   SELECT pg_catalog.setval('ceragen.admin_expense_type_ext_id_seq', 2, true);
           ceragen          uceragen    false    249            Ž           0    0    admin_invoice_detail_ind_id_seq    SEQUENCE SET     O   SELECT pg_catalog.setval('ceragen.admin_invoice_detail_ind_id_seq', 1, false);
           ceragen          postgres    false    291                       0    0    admin_invoice_inv_id_seq    SEQUENCE SET     H   SELECT pg_catalog.setval('ceragen.admin_invoice_inv_id_seq', 1, false);
           ceragen          postgres    false    289                       0    0     admin_invoice_payment_inp_id_seq    SEQUENCE SET     P   SELECT pg_catalog.setval('ceragen.admin_invoice_payment_inp_id_seq', 1, false);
           ceragen          postgres    false    293            ‘           0    0    admin_invoice_tax_int_id_seq    SEQUENCE SET     L   SELECT pg_catalog.setval('ceragen.admin_invoice_tax_int_id_seq', 1, false);
           ceragen          postgres    false    297            ’           0    0    admin_marital_status_id_seq    SEQUENCE SET     J   SELECT pg_catalog.setval('ceragen.admin_marital_status_id_seq', 8, true);
           ceragen          secoed    false    216            “           0    0 "   admin_medic_person_type_mpt_id_seq    SEQUENCE SET     Q   SELECT pg_catalog.setval('ceragen.admin_medic_person_type_mpt_id_seq', 2, true);
           ceragen          uceragen    false    243            ”           0    0    admin_medical_staff_med_id_seq    SEQUENCE SET     N   SELECT pg_catalog.setval('ceragen.admin_medical_staff_med_id_seq', 1, false);
           ceragen          uceragen    false    245            •           0    0    admin_parameter_list_pli_id_seq    SEQUENCE SET     N   SELECT pg_catalog.setval('ceragen.admin_parameter_list_pli_id_seq', 4, true);
           ceragen          uceragen    false    218            –           0    0    admin_patient_pat_id_seq    SEQUENCE SET     H   SELECT pg_catalog.setval('ceragen.admin_patient_pat_id_seq', 1, false);
           ceragen          uceragen    false    275            —           0    0    admin_payment_method_pme_id_seq    SEQUENCE SET     N   SELECT pg_catalog.setval('ceragen.admin_payment_method_pme_id_seq', 3, true);
           ceragen          uceragen    false    247            ˜           0    0    admin_person_genre_id_seq    SEQUENCE SET     H   SELECT pg_catalog.setval('ceragen.admin_person_genre_id_seq', 4, true);
           ceragen          uceragen    false    221            ™           0    0    admin_person_per_id_seq    SEQUENCE SET     G   SELECT pg_catalog.setval('ceragen.admin_person_per_id_seq', 42, true);
           ceragen          uceragen    false    222            š           0    0    admin_product_pro_id_seq    SEQUENCE SET     H   SELECT pg_catalog.setval('ceragen.admin_product_pro_id_seq', 1, false);
           ceragen          uceragen    false    255            ›           0    0 "   admin_product_promotion_ppr_id_seq    SEQUENCE SET     R   SELECT pg_catalog.setval('ceragen.admin_product_promotion_ppr_id_seq', 1, false);
           ceragen          uceragen    false    257            œ           0    0    admin_tax_tax_id_seq    SEQUENCE SET     D   SELECT pg_catalog.setval('ceragen.admin_tax_tax_id_seq', 1, false);
           ceragen          postgres    false    295                       0    0    admin_therapy_type_tht_id_seq    SEQUENCE SET     M   SELECT pg_catalog.setval('ceragen.admin_therapy_type_tht_id_seq', 1, false);
           ceragen          uceragen    false    253            ž           0    0 #   audi_sql_events_register_ser_id_seq    SEQUENCE SET     V   SELECT pg_catalog.setval('ceragen.audi_sql_events_register_ser_id_seq', 11822, true);
           ceragen          uceragen    false    224            Ÿ           0    0    audi_tables_aut_id_seq    SEQUENCE SET     F   SELECT pg_catalog.setval('ceragen.audi_tables_aut_id_seq', 43, true);
           ceragen          uceragen    false    226                        0    0     clinic_allergy_catalog_al_id_seq    SEQUENCE SET     P   SELECT pg_catalog.setval('ceragen.clinic_allergy_catalog_al_id_seq', 1, false);
           ceragen          uceragen    false    285            ¡           0    0 !   clinic_disease_catalog_dis_id_seq    SEQUENCE SET     Q   SELECT pg_catalog.setval('ceragen.clinic_disease_catalog_dis_id_seq', 1, false);
           ceragen          uceragen    false    281            ¢           0    0    clinic_disease_type_dst_id_seq    SEQUENCE SET     N   SELECT pg_catalog.setval('ceragen.clinic_disease_type_dst_id_seq', 1, false);
           ceragen          uceragen    false    279            £           0    0     clinic_patient_allergy_pa_id_seq    SEQUENCE SET     P   SELECT pg_catalog.setval('ceragen.clinic_patient_allergy_pa_id_seq', 1, false);
           ceragen          uceragen    false    287            ¤           0    0     clinic_patient_disease_pd_id_seq    SEQUENCE SET     P   SELECT pg_catalog.setval('ceragen.clinic_patient_disease_pd_id_seq', 1, false);
           ceragen          uceragen    false    283            ¥           0    0 *   clinic_patient_medical_history_hist_id_seq    SEQUENCE SET     Z   SELECT pg_catalog.setval('ceragen.clinic_patient_medical_history_hist_id_seq', 1, false);
           ceragen          uceragen    false    277            ¦           0    0 !   clinic_session_control_sec_id_seq    SEQUENCE SET     Q   SELECT pg_catalog.setval('ceragen.clinic_session_control_sec_id_seq', 1, false);
           ceragen          postgres    false    299            §           0    0    segu_login_slo_id_seq    SEQUENCE SET     F   SELECT pg_catalog.setval('ceragen.segu_login_slo_id_seq', 889, true);
           ceragen          uceragen    false    228            ¨           0    0    segu_menu_menu_id_seq    SEQUENCE SET     E   SELECT pg_catalog.setval('ceragen.segu_menu_menu_id_seq', 69, true);
           ceragen          uceragen    false    230            ©           0    0    segu_menu_rol_mr_id_seq    SEQUENCE SET     G   SELECT pg_catalog.setval('ceragen.segu_menu_rol_mr_id_seq', 88, true);
           ceragen          uceragen    false    232            ª           0    0    segu_module_mod_id_seq    SEQUENCE SET     F   SELECT pg_catalog.setval('ceragen.segu_module_mod_id_seq', 11, true);
           ceragen          uceragen    false    234            «           0    0    segu_rol_rol_id_seq    SEQUENCE SET     B   SELECT pg_catalog.setval('ceragen.segu_rol_rol_id_seq', 8, true);
           ceragen          uceragen    false    236            ¬           0    0 !   segu_user_notification_sun_id_seq    SEQUENCE SET     Q   SELECT pg_catalog.setval('ceragen.segu_user_notification_sun_id_seq', 1, false);
           ceragen          uceragen    false    239            ­           0    0    segu_user_rol_id_user_rol_seq    SEQUENCE SET     M   SELECT pg_catalog.setval('ceragen.segu_user_rol_id_user_rol_seq', 13, true);
           ceragen          uceragen    false    241            ®           0    0    segu_user_user_id_seq    SEQUENCE SET     E   SELECT pg_catalog.setval('ceragen.segu_user_user_id_seq', 11, true);
           ceragen          uceragen    false    242            ¯           0    0     clinic_allergy_catalog_al_id_seq    SEQUENCE SET     O   SELECT pg_catalog.setval('public.clinic_allergy_catalog_al_id_seq', 1, false);
          public          postgres    false    267            °           0    0    clinic_blood_type_btp_id_seq    SEQUENCE SET     K   SELECT pg_catalog.setval('public.clinic_blood_type_btp_id_seq', 1, false);
          public          postgres    false    273            ±           0    0     clinic_consent_record_con_id_seq    SEQUENCE SET     O   SELECT pg_catalog.setval('public.clinic_consent_record_con_id_seq', 1, false);
          public          postgres    false    271            ²           0    0 !   clinic_disease_catalog_dis_id_seq    SEQUENCE SET     P   SELECT pg_catalog.setval('public.clinic_disease_catalog_dis_id_seq', 1, false);
          public          postgres    false    263            ³           0    0    clinic_disease_type_dst_id_seq    SEQUENCE SET     M   SELECT pg_catalog.setval('public.clinic_disease_type_dst_id_seq', 1, false);
          public          postgres    false    261            ´           0    0     clinic_patient_allergy_pa_id_seq    SEQUENCE SET     O   SELECT pg_catalog.setval('public.clinic_patient_allergy_pa_id_seq', 1, false);
          public          postgres    false    269            µ           0    0     clinic_patient_disease_pd_id_seq    SEQUENCE SET     O   SELECT pg_catalog.setval('public.clinic_patient_disease_pd_id_seq', 1, false);
          public          postgres    false    265                       2606    27365    admin_client admin_client_pkey 
   CONSTRAINT     a   ALTER TABLE ONLY ceragen.admin_client
    ADD CONSTRAINT admin_client_pkey PRIMARY KEY (cli_id);
 I   ALTER TABLE ONLY ceragen.admin_client DROP CONSTRAINT admin_client_pkey;
        ceragen            uceragen    false    260            ø
           2606    27289     admin_expense admin_expense_pkey 
   CONSTRAINT     c   ALTER TABLE ONLY ceragen.admin_expense
    ADD CONSTRAINT admin_expense_pkey PRIMARY KEY (exp_id);
 K   ALTER TABLE ONLY ceragen.admin_expense DROP CONSTRAINT admin_expense_pkey;
        ceragen            uceragen    false    252            ö
           2606    27279 *   admin_expense_type admin_expense_type_pkey 
   CONSTRAINT     m   ALTER TABLE ONLY ceragen.admin_expense_type
    ADD CONSTRAINT admin_expense_type_pkey PRIMARY KEY (ext_id);
 U   ALTER TABLE ONLY ceragen.admin_expense_type DROP CONSTRAINT admin_expense_type_pkey;
        ceragen            uceragen    false    250            (           2606    27730 .   admin_invoice_detail admin_invoice_detail_pkey 
   CONSTRAINT     q   ALTER TABLE ONLY ceragen.admin_invoice_detail
    ADD CONSTRAINT admin_invoice_detail_pkey PRIMARY KEY (ind_id);
 Y   ALTER TABLE ONLY ceragen.admin_invoice_detail DROP CONSTRAINT admin_invoice_detail_pkey;
        ceragen            postgres    false    292            $           2606    27711 *   admin_invoice admin_invoice_inv_number_key 
   CONSTRAINT     l   ALTER TABLE ONLY ceragen.admin_invoice
    ADD CONSTRAINT admin_invoice_inv_number_key UNIQUE (inv_number);
 U   ALTER TABLE ONLY ceragen.admin_invoice DROP CONSTRAINT admin_invoice_inv_number_key;
        ceragen            postgres    false    290            *           2606    27750 0   admin_invoice_payment admin_invoice_payment_pkey 
   CONSTRAINT     s   ALTER TABLE ONLY ceragen.admin_invoice_payment
    ADD CONSTRAINT admin_invoice_payment_pkey PRIMARY KEY (inp_id);
 [   ALTER TABLE ONLY ceragen.admin_invoice_payment DROP CONSTRAINT admin_invoice_payment_pkey;
        ceragen            postgres    false    294            &           2606    27709     admin_invoice admin_invoice_pkey 
   CONSTRAINT     c   ALTER TABLE ONLY ceragen.admin_invoice
    ADD CONSTRAINT admin_invoice_pkey PRIMARY KEY (inv_id);
 K   ALTER TABLE ONLY ceragen.admin_invoice DROP CONSTRAINT admin_invoice_pkey;
        ceragen            postgres    false    290            .           2606    27778 (   admin_invoice_tax admin_invoice_tax_pkey 
   CONSTRAINT     k   ALTER TABLE ONLY ceragen.admin_invoice_tax
    ADD CONSTRAINT admin_invoice_tax_pkey PRIMARY KEY (int_id);
 S   ALTER TABLE ONLY ceragen.admin_invoice_tax DROP CONSTRAINT admin_invoice_tax_pkey;
        ceragen            postgres    false    298            Î
           2606    26810 .   admin_marital_status admin_marital_status_pkey 
   CONSTRAINT     m   ALTER TABLE ONLY ceragen.admin_marital_status
    ADD CONSTRAINT admin_marital_status_pkey PRIMARY KEY (id);
 Y   ALTER TABLE ONLY ceragen.admin_marital_status DROP CONSTRAINT admin_marital_status_pkey;
        ceragen            secoed    false    215            ð
           2606    27243 4   admin_medic_person_type admin_medic_person_type_pkey 
   CONSTRAINT     w   ALTER TABLE ONLY ceragen.admin_medic_person_type
    ADD CONSTRAINT admin_medic_person_type_pkey PRIMARY KEY (mpt_id);
 _   ALTER TABLE ONLY ceragen.admin_medic_person_type DROP CONSTRAINT admin_medic_person_type_pkey;
        ceragen            uceragen    false    244            ò
           2606    27251 ,   admin_medical_staff admin_medical_staff_pkey 
   CONSTRAINT     o   ALTER TABLE ONLY ceragen.admin_medical_staff
    ADD CONSTRAINT admin_medical_staff_pkey PRIMARY KEY (med_id);
 W   ALTER TABLE ONLY ceragen.admin_medical_staff DROP CONSTRAINT admin_medical_staff_pkey;
        ceragen            uceragen    false    246            Ð
           2606    26812 .   admin_parameter_list admin_parameter_list_pkey 
   CONSTRAINT     q   ALTER TABLE ONLY ceragen.admin_parameter_list
    ADD CONSTRAINT admin_parameter_list_pkey PRIMARY KEY (pli_id);
 Y   ALTER TABLE ONLY ceragen.admin_parameter_list DROP CONSTRAINT admin_parameter_list_pkey;
        ceragen            uceragen    false    217                       2606    27524 (   admin_patient admin_patient_pat_code_key 
   CONSTRAINT     h   ALTER TABLE ONLY ceragen.admin_patient
    ADD CONSTRAINT admin_patient_pat_code_key UNIQUE (pat_code);
 S   ALTER TABLE ONLY ceragen.admin_patient DROP CONSTRAINT admin_patient_pat_code_key;
        ceragen            uceragen    false    276                       2606    27522     admin_patient admin_patient_pkey 
   CONSTRAINT     c   ALTER TABLE ONLY ceragen.admin_patient
    ADD CONSTRAINT admin_patient_pkey PRIMARY KEY (pat_id);
 K   ALTER TABLE ONLY ceragen.admin_patient DROP CONSTRAINT admin_patient_pkey;
        ceragen            uceragen    false    276            ô
           2606    27271 .   admin_payment_method admin_payment_method_pkey 
   CONSTRAINT     q   ALTER TABLE ONLY ceragen.admin_payment_method
    ADD CONSTRAINT admin_payment_method_pkey PRIMARY KEY (pme_id);
 Y   ALTER TABLE ONLY ceragen.admin_payment_method DROP CONSTRAINT admin_payment_method_pkey;
        ceragen            uceragen    false    248            Ö
           2606    26818 *   admin_person_genre admin_person_genre_pkey 
   CONSTRAINT     i   ALTER TABLE ONLY ceragen.admin_person_genre
    ADD CONSTRAINT admin_person_genre_pkey PRIMARY KEY (id);
 U   ALTER TABLE ONLY ceragen.admin_person_genre DROP CONSTRAINT admin_person_genre_pkey;
        ceragen            uceragen    false    220            Ò
           2606    26820 0   admin_person admin_person_per_identification_key 
   CONSTRAINT     z   ALTER TABLE ONLY ceragen.admin_person
    ADD CONSTRAINT admin_person_per_identification_key UNIQUE (per_identification);
 [   ALTER TABLE ONLY ceragen.admin_person DROP CONSTRAINT admin_person_per_identification_key;
        ceragen            uceragen    false    219            Ô
           2606    26822    admin_person admin_person_pkey 
   CONSTRAINT     a   ALTER TABLE ONLY ceragen.admin_person
    ADD CONSTRAINT admin_person_pkey PRIMARY KEY (per_id);
 I   ALTER TABLE ONLY ceragen.admin_person DROP CONSTRAINT admin_person_pkey;
        ceragen            uceragen    false    219            ü
           2606    27331     admin_product admin_product_pkey 
   CONSTRAINT     c   ALTER TABLE ONLY ceragen.admin_product
    ADD CONSTRAINT admin_product_pkey PRIMARY KEY (pro_id);
 K   ALTER TABLE ONLY ceragen.admin_product DROP CONSTRAINT admin_product_pkey;
        ceragen            uceragen    false    256            þ
           2606    27333 (   admin_product admin_product_pro_code_key 
   CONSTRAINT     h   ALTER TABLE ONLY ceragen.admin_product
    ADD CONSTRAINT admin_product_pro_code_key UNIQUE (pro_code);
 S   ALTER TABLE ONLY ceragen.admin_product DROP CONSTRAINT admin_product_pro_code_key;
        ceragen            uceragen    false    256                        2606    27350 4   admin_product_promotion admin_product_promotion_pkey 
   CONSTRAINT     w   ALTER TABLE ONLY ceragen.admin_product_promotion
    ADD CONSTRAINT admin_product_promotion_pkey PRIMARY KEY (ppr_id);
 _   ALTER TABLE ONLY ceragen.admin_product_promotion DROP CONSTRAINT admin_product_promotion_pkey;
        ceragen            uceragen    false    258            ,           2606    27770    admin_tax admin_tax_pkey 
   CONSTRAINT     [   ALTER TABLE ONLY ceragen.admin_tax
    ADD CONSTRAINT admin_tax_pkey PRIMARY KEY (tax_id);
 C   ALTER TABLE ONLY ceragen.admin_tax DROP CONSTRAINT admin_tax_pkey;
        ceragen            postgres    false    296            ú
           2606    27321 *   admin_therapy_type admin_therapy_type_pkey 
   CONSTRAINT     m   ALTER TABLE ONLY ceragen.admin_therapy_type
    ADD CONSTRAINT admin_therapy_type_pkey PRIMARY KEY (tht_id);
 U   ALTER TABLE ONLY ceragen.admin_therapy_type DROP CONSTRAINT admin_therapy_type_pkey;
        ceragen            uceragen    false    254            Ø
           2606    26826 6   audi_sql_events_register audi_sql_events_register_pkey 
   CONSTRAINT     y   ALTER TABLE ONLY ceragen.audi_sql_events_register
    ADD CONSTRAINT audi_sql_events_register_pkey PRIMARY KEY (ser_id);
 a   ALTER TABLE ONLY ceragen.audi_sql_events_register DROP CONSTRAINT audi_sql_events_register_pkey;
        ceragen            uceragen    false    223            Ú
           2606    26828    audi_tables audi_tables_pkey 
   CONSTRAINT     _   ALTER TABLE ONLY ceragen.audi_tables
    ADD CONSTRAINT audi_tables_pkey PRIMARY KEY (aut_id);
 G   ALTER TABLE ONLY ceragen.audi_tables DROP CONSTRAINT audi_tables_pkey;
        ceragen            uceragen    false    225                        2606    27634 2   clinic_allergy_catalog clinic_allergy_catalog_pkey 
   CONSTRAINT     t   ALTER TABLE ONLY ceragen.clinic_allergy_catalog
    ADD CONSTRAINT clinic_allergy_catalog_pkey PRIMARY KEY (al_id);
 ]   ALTER TABLE ONLY ceragen.clinic_allergy_catalog DROP CONSTRAINT clinic_allergy_catalog_pkey;
        ceragen            uceragen    false    286                       2606    27599 2   clinic_disease_catalog clinic_disease_catalog_pkey 
   CONSTRAINT     u   ALTER TABLE ONLY ceragen.clinic_disease_catalog
    ADD CONSTRAINT clinic_disease_catalog_pkey PRIMARY KEY (dis_id);
 ]   ALTER TABLE ONLY ceragen.clinic_disease_catalog DROP CONSTRAINT clinic_disease_catalog_pkey;
        ceragen            uceragen    false    282                       2606    27589 ,   clinic_disease_type clinic_disease_type_pkey 
   CONSTRAINT     o   ALTER TABLE ONLY ceragen.clinic_disease_type
    ADD CONSTRAINT clinic_disease_type_pkey PRIMARY KEY (dst_id);
 W   ALTER TABLE ONLY ceragen.clinic_disease_type DROP CONSTRAINT clinic_disease_type_pkey;
        ceragen            uceragen    false    280            "           2606    27643 2   clinic_patient_allergy clinic_patient_allergy_pkey 
   CONSTRAINT     t   ALTER TABLE ONLY ceragen.clinic_patient_allergy
    ADD CONSTRAINT clinic_patient_allergy_pkey PRIMARY KEY (pa_id);
 ]   ALTER TABLE ONLY ceragen.clinic_patient_allergy DROP CONSTRAINT clinic_patient_allergy_pkey;
        ceragen            uceragen    false    288                       2606    27614 2   clinic_patient_disease clinic_patient_disease_pkey 
   CONSTRAINT     t   ALTER TABLE ONLY ceragen.clinic_patient_disease
    ADD CONSTRAINT clinic_patient_disease_pkey PRIMARY KEY (pd_id);
 ]   ALTER TABLE ONLY ceragen.clinic_patient_disease DROP CONSTRAINT clinic_patient_disease_pkey;
        ceragen            uceragen    false    284                       2606    27544 B   clinic_patient_medical_history clinic_patient_medical_history_pkey 
   CONSTRAINT     †   ALTER TABLE ONLY ceragen.clinic_patient_medical_history
    ADD CONSTRAINT clinic_patient_medical_history_pkey PRIMARY KEY (hist_id);
 m   ALTER TABLE ONLY ceragen.clinic_patient_medical_history DROP CONSTRAINT clinic_patient_medical_history_pkey;
        ceragen            uceragen    false    278            0           2606    27906 2   clinic_session_control clinic_session_control_pkey 
   CONSTRAINT     u   ALTER TABLE ONLY ceragen.clinic_session_control
    ADD CONSTRAINT clinic_session_control_pkey PRIMARY KEY (sec_id);
 ]   ALTER TABLE ONLY ceragen.clinic_session_control DROP CONSTRAINT clinic_session_control_pkey;
        ceragen            postgres    false    300            Ü
           2606    26872    segu_login segu_login_pkey 
   CONSTRAINT     ]   ALTER TABLE ONLY ceragen.segu_login
    ADD CONSTRAINT segu_login_pkey PRIMARY KEY (slo_id);
 E   ALTER TABLE ONLY ceragen.segu_login DROP CONSTRAINT segu_login_pkey;
        ceragen            uceragen    false    227            Þ
           2606    26874    segu_menu segu_menu_pkey 
   CONSTRAINT     \   ALTER TABLE ONLY ceragen.segu_menu
    ADD CONSTRAINT segu_menu_pkey PRIMARY KEY (menu_id);
 C   ALTER TABLE ONLY ceragen.segu_menu DROP CONSTRAINT segu_menu_pkey;
        ceragen            uceragen    false    229            à
           2606    26876     segu_menu_rol segu_menu_rol_pkey 
   CONSTRAINT     b   ALTER TABLE ONLY ceragen.segu_menu_rol
    ADD CONSTRAINT segu_menu_rol_pkey PRIMARY KEY (mr_id);
 K   ALTER TABLE ONLY ceragen.segu_menu_rol DROP CONSTRAINT segu_menu_rol_pkey;
        ceragen            uceragen    false    231            â
           2606    26878    segu_module segu_module_pkey 
   CONSTRAINT     _   ALTER TABLE ONLY ceragen.segu_module
    ADD CONSTRAINT segu_module_pkey PRIMARY KEY (mod_id);
 G   ALTER TABLE ONLY ceragen.segu_module DROP CONSTRAINT segu_module_pkey;
        ceragen            uceragen    false    233            ä
           2606    26880    segu_rol segu_rol_pkey 
   CONSTRAINT     Y   ALTER TABLE ONLY ceragen.segu_rol
    ADD CONSTRAINT segu_rol_pkey PRIMARY KEY (rol_id);
 A   ALTER TABLE ONLY ceragen.segu_rol DROP CONSTRAINT segu_rol_pkey;
        ceragen            uceragen    false    235            ì
           2606    26882 2   segu_user_notification segu_user_notification_pkey 
   CONSTRAINT     u   ALTER TABLE ONLY ceragen.segu_user_notification
    ADD CONSTRAINT segu_user_notification_pkey PRIMARY KEY (sun_id);
 ]   ALTER TABLE ONLY ceragen.segu_user_notification DROP CONSTRAINT segu_user_notification_pkey;
        ceragen            uceragen    false    238            æ
           2606    26884    segu_user segu_user_pkey 
   CONSTRAINT     \   ALTER TABLE ONLY ceragen.segu_user
    ADD CONSTRAINT segu_user_pkey PRIMARY KEY (user_id);
 C   ALTER TABLE ONLY ceragen.segu_user DROP CONSTRAINT segu_user_pkey;
        ceragen            uceragen    false    237            î
           2606    26888     segu_user_rol segu_user_rol_pkey 
   CONSTRAINT     h   ALTER TABLE ONLY ceragen.segu_user_rol
    ADD CONSTRAINT segu_user_rol_pkey PRIMARY KEY (id_user_rol);
 K   ALTER TABLE ONLY ceragen.segu_user_rol DROP CONSTRAINT segu_user_rol_pkey;
        ceragen            uceragen    false    240            è
           2606    26890 %   segu_user segu_user_user_login_id_key 
   CONSTRAINT     j   ALTER TABLE ONLY ceragen.segu_user
    ADD CONSTRAINT segu_user_user_login_id_key UNIQUE (user_login_id);
 P   ALTER TABLE ONLY ceragen.segu_user DROP CONSTRAINT segu_user_user_login_id_key;
        ceragen            uceragen    false    237            ê
           2606    26892 !   segu_user segu_user_user_mail_key 
   CONSTRAINT     b   ALTER TABLE ONLY ceragen.segu_user
    ADD CONSTRAINT segu_user_user_mail_key UNIQUE (user_mail);
 L   ALTER TABLE ONLY ceragen.segu_user DROP CONSTRAINT segu_user_user_mail_key;
        ceragen            uceragen    false    237            
           2606    27462 2   clinic_allergy_catalog clinic_allergy_catalog_pkey 
   CONSTRAINT     s   ALTER TABLE ONLY public.clinic_allergy_catalog
    ADD CONSTRAINT clinic_allergy_catalog_pkey PRIMARY KEY (al_id);
 \   ALTER TABLE ONLY public.clinic_allergy_catalog DROP CONSTRAINT clinic_allergy_catalog_pkey;
       public            postgres    false    268                       2606    27507 0   clinic_blood_type clinic_blood_type_btp_type_key 
   CONSTRAINT     o   ALTER TABLE ONLY public.clinic_blood_type
    ADD CONSTRAINT clinic_blood_type_btp_type_key UNIQUE (btp_type);
 Z   ALTER TABLE ONLY public.clinic_blood_type DROP CONSTRAINT clinic_blood_type_btp_type_key;
       public            postgres    false    274                       2606    27505 (   clinic_blood_type clinic_blood_type_pkey 
   CONSTRAINT     j   ALTER TABLE ONLY public.clinic_blood_type
    ADD CONSTRAINT clinic_blood_type_pkey PRIMARY KEY (btp_id);
 R   ALTER TABLE ONLY public.clinic_blood_type DROP CONSTRAINT clinic_blood_type_pkey;
       public            postgres    false    274                       2606    27490 0   clinic_consent_record clinic_consent_record_pkey 
   CONSTRAINT     r   ALTER TABLE ONLY public.clinic_consent_record
    ADD CONSTRAINT clinic_consent_record_pkey PRIMARY KEY (con_id);
 Z   ALTER TABLE ONLY public.clinic_consent_record DROP CONSTRAINT clinic_consent_record_pkey;
       public            postgres    false    272                       2606    27391 2   clinic_disease_catalog clinic_disease_catalog_pkey 
   CONSTRAINT     t   ALTER TABLE ONLY public.clinic_disease_catalog
    ADD CONSTRAINT clinic_disease_catalog_pkey PRIMARY KEY (dis_id);
 \   ALTER TABLE ONLY public.clinic_disease_catalog DROP CONSTRAINT clinic_disease_catalog_pkey;
       public            postgres    false    264                       2606    27381 ,   clinic_disease_type clinic_disease_type_pkey 
   CONSTRAINT     n   ALTER TABLE ONLY public.clinic_disease_type
    ADD CONSTRAINT clinic_disease_type_pkey PRIMARY KEY (dst_id);
 V   ALTER TABLE ONLY public.clinic_disease_type DROP CONSTRAINT clinic_disease_type_pkey;
       public            postgres    false    262                       2606    27471 2   clinic_patient_allergy clinic_patient_allergy_pkey 
   CONSTRAINT     s   ALTER TABLE ONLY public.clinic_patient_allergy
    ADD CONSTRAINT clinic_patient_allergy_pkey PRIMARY KEY (pa_id);
 \   ALTER TABLE ONLY public.clinic_patient_allergy DROP CONSTRAINT clinic_patient_allergy_pkey;
       public            postgres    false    270                       2606    27442 2   clinic_patient_disease clinic_patient_disease_pkey 
   CONSTRAINT     s   ALTER TABLE ONLY public.clinic_patient_disease
    ADD CONSTRAINT clinic_patient_disease_pkey PRIMARY KEY (pd_id);
 \   ALTER TABLE ONLY public.clinic_patient_disease DROP CONSTRAINT clinic_patient_disease_pkey;
       public            postgres    false    266            _           2620    26894 4   admin_parameter_list tgr_insert_admin_parameter_list     TRIGGER     œ   CREATE TRIGGER tgr_insert_admin_parameter_list BEFORE INSERT ON ceragen.admin_parameter_list FOR EACH ROW EXECUTE FUNCTION ceragen.register_insert_event();
 N   DROP TRIGGER tgr_insert_admin_parameter_list ON ceragen.admin_parameter_list;
        ceragen          uceragen    false    312    217            e           2620    26895 "   audi_tables tgr_insert_audi_tables     TRIGGER     Š   CREATE TRIGGER tgr_insert_audi_tables BEFORE INSERT ON ceragen.audi_tables FOR EACH ROW EXECUTE FUNCTION ceragen.register_insert_event();
 <   DROP TRIGGER tgr_insert_audi_tables ON ceragen.audi_tables;
        ceragen          uceragen    false    312    225            `           2620    26904 4   admin_parameter_list tgr_update_admin_parameter_list     TRIGGER     ¦   CREATE TRIGGER tgr_update_admin_parameter_list BEFORE DELETE OR UPDATE ON ceragen.admin_parameter_list FOR EACH ROW EXECUTE FUNCTION ceragen.register_update_event();
 N   DROP TRIGGER tgr_update_admin_parameter_list ON ceragen.admin_parameter_list;
        ceragen          uceragen    false    217    314            f           2620    26905 "   audi_tables tgr_update_audi_tables     TRIGGER     Š   CREATE TRIGGER tgr_update_audi_tables BEFORE UPDATE ON ceragen.audi_tables FOR EACH ROW EXECUTE FUNCTION ceragen.register_update_event();
 <   DROP TRIGGER tgr_update_audi_tables ON ceragen.audi_tables;
        ceragen          uceragen    false    225    314            ]           2620    26918 4   admin_marital_status trg_insert_admin_marital_status     TRIGGER     œ   CREATE TRIGGER trg_insert_admin_marital_status BEFORE INSERT ON ceragen.admin_marital_status FOR EACH ROW EXECUTE FUNCTION ceragen.register_insert_event();
 N   DROP TRIGGER trg_insert_admin_marital_status ON ceragen.admin_marital_status;
        ceragen          secoed    false    312    215            a           2620    26920 $   admin_person trg_insert_admin_person     TRIGGER     Œ   CREATE TRIGGER trg_insert_admin_person BEFORE INSERT ON ceragen.admin_person FOR EACH ROW EXECUTE FUNCTION ceragen.register_insert_event();
 >   DROP TRIGGER trg_insert_admin_person ON ceragen.admin_person;
        ceragen          uceragen    false    312    219            c           2620    26921 0   admin_person_genre trg_insert_admin_person_genre     TRIGGER     ˜   CREATE TRIGGER trg_insert_admin_person_genre BEFORE INSERT ON ceragen.admin_person_genre FOR EACH ROW EXECUTE FUNCTION ceragen.register_insert_event();
 J   DROP TRIGGER trg_insert_admin_person_genre ON ceragen.admin_person_genre;
        ceragen          uceragen    false    312    220            g           2620    26937     segu_login trg_insert_segu_login     TRIGGER     ‡   CREATE TRIGGER trg_insert_segu_login BEFORE INSERT ON ceragen.segu_login FOR EACH ROW EXECUTE FUNCTION ceragen.register_login_event();
 :   DROP TRIGGER trg_insert_segu_login ON ceragen.segu_login;
        ceragen          uceragen    false    227    313            h           2620    26938    segu_menu trg_insert_segu_menu     TRIGGER     †   CREATE TRIGGER trg_insert_segu_menu BEFORE INSERT ON ceragen.segu_menu FOR EACH ROW EXECUTE FUNCTION ceragen.register_insert_event();
 8   DROP TRIGGER trg_insert_segu_menu ON ceragen.segu_menu;
        ceragen          uceragen    false    312    229            j           2620    26939 &   segu_menu_rol trg_insert_segu_menu_rol     TRIGGER     Ž   CREATE TRIGGER trg_insert_segu_menu_rol BEFORE INSERT ON ceragen.segu_menu_rol FOR EACH ROW EXECUTE FUNCTION ceragen.register_insert_event();
 @   DROP TRIGGER trg_insert_segu_menu_rol ON ceragen.segu_menu_rol;
        ceragen          uceragen    false    231    312            l           2620    26940 "   segu_module trg_insert_segu_module     TRIGGER     Š   CREATE TRIGGER trg_insert_segu_module BEFORE INSERT ON ceragen.segu_module FOR EACH ROW EXECUTE FUNCTION ceragen.register_insert_event();
 <   DROP TRIGGER trg_insert_segu_module ON ceragen.segu_module;
        ceragen          uceragen    false    312    233            n           2620    26941    segu_rol trg_insert_segu_rol     TRIGGER     „   CREATE TRIGGER trg_insert_segu_rol BEFORE INSERT ON ceragen.segu_rol FOR EACH ROW EXECUTE FUNCTION ceragen.register_insert_event();
 6   DROP TRIGGER trg_insert_segu_rol ON ceragen.segu_rol;
        ceragen          uceragen    false    312    235            p           2620    26942    segu_user trg_insert_segu_user     TRIGGER     †   CREATE TRIGGER trg_insert_segu_user BEFORE INSERT ON ceragen.segu_user FOR EACH ROW EXECUTE FUNCTION ceragen.register_insert_event();
 8   DROP TRIGGER trg_insert_segu_user ON ceragen.segu_user;
        ceragen          uceragen    false    312    237            r           2620    26943 8   segu_user_notification trg_insert_segu_user_notification     TRIGGER         CREATE TRIGGER trg_insert_segu_user_notification BEFORE INSERT ON ceragen.segu_user_notification FOR EACH ROW EXECUTE FUNCTION ceragen.register_insert_event();
 R   DROP TRIGGER trg_insert_segu_user_notification ON ceragen.segu_user_notification;
        ceragen          uceragen    false    238    312            t           2620    26944 &   segu_user_rol trg_insert_segu_user_rol     TRIGGER     Ž   CREATE TRIGGER trg_insert_segu_user_rol BEFORE INSERT ON ceragen.segu_user_rol FOR EACH ROW EXECUTE FUNCTION ceragen.register_insert_event();
 @   DROP TRIGGER trg_insert_segu_user_rol ON ceragen.segu_user_rol;
        ceragen          uceragen    false    312    240            ^           2620    26950 4   admin_marital_status trg_update_admin_marital_status     TRIGGER     œ   CREATE TRIGGER trg_update_admin_marital_status BEFORE UPDATE ON ceragen.admin_marital_status FOR EACH ROW EXECUTE FUNCTION ceragen.register_update_event();
 N   DROP TRIGGER trg_update_admin_marital_status ON ceragen.admin_marital_status;
        ceragen          secoed    false    314    215            b           2620    26952 $   admin_person trg_update_admin_person     TRIGGER     Œ   CREATE TRIGGER trg_update_admin_person BEFORE UPDATE ON ceragen.admin_person FOR EACH ROW EXECUTE FUNCTION ceragen.register_update_event();
 >   DROP TRIGGER trg_update_admin_person ON ceragen.admin_person;
        ceragen          uceragen    false    219    314            d           2620    26953 0   admin_person_genre trg_update_admin_person_genre     TRIGGER     ˜   CREATE TRIGGER trg_update_admin_person_genre BEFORE UPDATE ON ceragen.admin_person_genre FOR EACH ROW EXECUTE FUNCTION ceragen.register_update_event();
 J   DROP TRIGGER trg_update_admin_person_genre ON ceragen.admin_person_genre;
        ceragen          uceragen    false    220    314            i           2620    26976    segu_menu trg_update_segu_menu     TRIGGER     †   CREATE TRIGGER trg_update_segu_menu BEFORE UPDATE ON ceragen.segu_menu FOR EACH ROW EXECUTE FUNCTION ceragen.register_update_event();
 8   DROP TRIGGER trg_update_segu_menu ON ceragen.segu_menu;
        ceragen          uceragen    false    229    314            k           2620    26977 &   segu_menu_rol trg_update_segu_menu_rol     TRIGGER     Ž   CREATE TRIGGER trg_update_segu_menu_rol BEFORE UPDATE ON ceragen.segu_menu_rol FOR EACH ROW EXECUTE FUNCTION ceragen.register_update_event();
 @   DROP TRIGGER trg_update_segu_menu_rol ON ceragen.segu_menu_rol;
        ceragen          uceragen    false    231    314            m           2620    26978 "   segu_module trg_update_segu_module     TRIGGER     Š   CREATE TRIGGER trg_update_segu_module BEFORE UPDATE ON ceragen.segu_module FOR EACH ROW EXECUTE FUNCTION ceragen.register_update_event();
 <   DROP TRIGGER trg_update_segu_module ON ceragen.segu_module;
        ceragen          uceragen    false    314    233            o           2620    26979    segu_rol trg_update_segu_rol     TRIGGER     „   CREATE TRIGGER trg_update_segu_rol BEFORE UPDATE ON ceragen.segu_rol FOR EACH ROW EXECUTE FUNCTION ceragen.register_update_event();
 6   DROP TRIGGER trg_update_segu_rol ON ceragen.segu_rol;
        ceragen          uceragen    false    235    314            q           2620    26980    segu_user trg_update_segu_user     TRIGGER     †   CREATE TRIGGER trg_update_segu_user BEFORE UPDATE ON ceragen.segu_user FOR EACH ROW EXECUTE FUNCTION ceragen.register_update_event();
 8   DROP TRIGGER trg_update_segu_user ON ceragen.segu_user;
        ceragen          uceragen    false    314    237            s           2620    26981 8   segu_user_notification trg_update_segu_user_notification     TRIGGER         CREATE TRIGGER trg_update_segu_user_notification BEFORE UPDATE ON ceragen.segu_user_notification FOR EACH ROW EXECUTE FUNCTION ceragen.register_update_event();
 R   DROP TRIGGER trg_update_segu_user_notification ON ceragen.segu_user_notification;
        ceragen          uceragen    false    314    238            u           2620    26982 &   segu_user_rol trg_update_segu_user_rol     TRIGGER     Ž   CREATE TRIGGER trg_update_segu_user_rol BEFORE UPDATE ON ceragen.segu_user_rol FOR EACH ROW EXECUTE FUNCTION ceragen.register_update_event();
 @   DROP TRIGGER trg_update_segu_user_rol ON ceragen.segu_user_rol;
        ceragen          uceragen    false    314    240            3           2606    27004 C   audi_sql_events_register audi_sql_events_register_ser_table_id_fkey 
   FK CONSTRAINT     ³   ALTER TABLE ONLY ceragen.audi_sql_events_register
    ADD CONSTRAINT audi_sql_events_register_ser_table_id_fkey FOREIGN KEY (ser_table_id) REFERENCES ceragen.audi_tables(aut_id);
 n   ALTER TABLE ONLY ceragen.audi_sql_events_register DROP CONSTRAINT audi_sql_events_register_ser_table_id_fkey;
        ceragen          uceragen    false    225    3546    223            4           2606    27009 J   audi_sql_events_register audi_sql_events_register_ser_user_process_id_fkey 
   FK CONSTRAINT     À   ALTER TABLE ONLY ceragen.audi_sql_events_register
    ADD CONSTRAINT audi_sql_events_register_ser_user_process_id_fkey FOREIGN KEY (ser_user_process_id) REFERENCES ceragen.segu_user(user_id);
 u   ALTER TABLE ONLY ceragen.audi_sql_events_register DROP CONSTRAINT audi_sql_events_register_ser_user_process_id_fkey;
        ceragen          uceragen    false    3558    237    223            E           2606    27366    admin_client fk_client_person 
   FK CONSTRAINT     µ   ALTER TABLE ONLY ceragen.admin_client
    ADD CONSTRAINT fk_client_person FOREIGN KEY (cli_person_id) REFERENCES ceragen.admin_person(per_id) ON UPDATE RESTRICT ON DELETE RESTRICT;
 H   ALTER TABLE ONLY ceragen.admin_client DROP CONSTRAINT fk_client_person;
        ceragen          uceragen    false    219    260    3540            L           2606    27600 "   clinic_disease_catalog fk_dis_type 
   FK CONSTRAINT     ¿   ALTER TABLE ONLY ceragen.clinic_disease_catalog
    ADD CONSTRAINT fk_dis_type FOREIGN KEY (dis_type_id) REFERENCES ceragen.clinic_disease_type(dst_id) ON UPDATE RESTRICT ON DELETE RESTRICT;
 M   ALTER TABLE ONLY ceragen.clinic_disease_catalog DROP CONSTRAINT fk_dis_type;
        ceragen          uceragen    false    282    3610    280            A           2606    27290    admin_expense fk_expense_type 
   FK CONSTRAINT     ¹   ALTER TABLE ONLY ceragen.admin_expense
    ADD CONSTRAINT fk_expense_type FOREIGN KEY (exp_type_id) REFERENCES ceragen.admin_expense_type(ext_id) ON UPDATE RESTRICT ON DELETE RESTRICT;
 H   ALTER TABLE ONLY ceragen.admin_expense DROP CONSTRAINT fk_expense_type;
        ceragen          uceragen    false    252    250    3574            K           2606    27545 .   clinic_patient_medical_history fk_hist_patient 
   FK CONSTRAINT     È   ALTER TABLE ONLY ceragen.clinic_patient_medical_history
    ADD CONSTRAINT fk_hist_patient FOREIGN KEY (hist_patient_id) REFERENCES ceragen.admin_patient(pat_id) ON UPDATE RESTRICT ON DELETE CASCADE;
 Y   ALTER TABLE ONLY ceragen.clinic_patient_medical_history DROP CONSTRAINT fk_hist_patient;
        ceragen          uceragen    false    3606    278    276            S           2606    27731 #   admin_invoice_detail fk_ind_invoice 
   FK CONSTRAINT     ¼   ALTER TABLE ONLY ceragen.admin_invoice_detail
    ADD CONSTRAINT fk_ind_invoice FOREIGN KEY (ind_invoice_id) REFERENCES ceragen.admin_invoice(inv_id) ON UPDATE RESTRICT ON DELETE CASCADE;
 N   ALTER TABLE ONLY ceragen.admin_invoice_detail DROP CONSTRAINT fk_ind_invoice;
        ceragen          postgres    false    3622    290    292            T           2606    27736 #   admin_invoice_detail fk_ind_product 
   FK CONSTRAINT     ½   ALTER TABLE ONLY ceragen.admin_invoice_detail
    ADD CONSTRAINT fk_ind_product FOREIGN KEY (ind_product_id) REFERENCES ceragen.admin_product(pro_id) ON UPDATE RESTRICT ON DELETE RESTRICT;
 N   ALTER TABLE ONLY ceragen.admin_invoice_detail DROP CONSTRAINT fk_ind_product;
        ceragen          postgres    false    256    292    3580            U           2606    27751 $   admin_invoice_payment fk_inp_invoice 
   FK CONSTRAINT     ½   ALTER TABLE ONLY ceragen.admin_invoice_payment
    ADD CONSTRAINT fk_inp_invoice FOREIGN KEY (inp_invoice_id) REFERENCES ceragen.admin_invoice(inv_id) ON UPDATE RESTRICT ON DELETE CASCADE;
 O   ALTER TABLE ONLY ceragen.admin_invoice_payment DROP CONSTRAINT fk_inp_invoice;
        ceragen          postgres    false    3622    290    294            V           2606    27756 +   admin_invoice_payment fk_inp_payment_method 
   FK CONSTRAINT     Ó   ALTER TABLE ONLY ceragen.admin_invoice_payment
    ADD CONSTRAINT fk_inp_payment_method FOREIGN KEY (inp_payment_method_id) REFERENCES ceragen.admin_payment_method(pme_id) ON UPDATE RESTRICT ON DELETE RESTRICT;
 V   ALTER TABLE ONLY ceragen.admin_invoice_payment DROP CONSTRAINT fk_inp_payment_method;
        ceragen          postgres    false    3572    248    294            W           2606    27779     admin_invoice_tax fk_int_invoice 
   FK CONSTRAINT     ¹   ALTER TABLE ONLY ceragen.admin_invoice_tax
    ADD CONSTRAINT fk_int_invoice FOREIGN KEY (int_invoice_id) REFERENCES ceragen.admin_invoice(inv_id) ON UPDATE RESTRICT ON DELETE CASCADE;
 K   ALTER TABLE ONLY ceragen.admin_invoice_tax DROP CONSTRAINT fk_int_invoice;
        ceragen          postgres    false    298    3622    290            X           2606    27784    admin_invoice_tax fk_int_tax 
   FK CONSTRAINT     ®   ALTER TABLE ONLY ceragen.admin_invoice_tax
    ADD CONSTRAINT fk_int_tax FOREIGN KEY (int_tax_id) REFERENCES ceragen.admin_tax(tax_id) ON UPDATE RESTRICT ON DELETE RESTRICT;
 G   ALTER TABLE ONLY ceragen.admin_invoice_tax DROP CONSTRAINT fk_int_tax;
        ceragen          postgres    false    296    298    3628            Q           2606    27712    admin_invoice fk_invoice_client 
   FK CONSTRAINT     ·   ALTER TABLE ONLY ceragen.admin_invoice
    ADD CONSTRAINT fk_invoice_client FOREIGN KEY (inv_client_id) REFERENCES ceragen.admin_person(per_id) ON UPDATE RESTRICT ON DELETE RESTRICT;
 J   ALTER TABLE ONLY ceragen.admin_invoice DROP CONSTRAINT fk_invoice_client;
        ceragen          postgres    false    290    219    3540            R           2606    27717     admin_invoice fk_invoice_patient 
   FK CONSTRAINT     º   ALTER TABLE ONLY ceragen.admin_invoice
    ADD CONSTRAINT fk_invoice_patient FOREIGN KEY (inv_patient_id) REFERENCES ceragen.admin_patient(pat_id) ON UPDATE RESTRICT ON DELETE SET NULL;
 K   ALTER TABLE ONLY ceragen.admin_invoice DROP CONSTRAINT fk_invoice_patient;
        ceragen          postgres    false    3606    276    290            ?           2606    27252 !   admin_medical_staff fk_med_person 
   FK CONSTRAINT     ¹   ALTER TABLE ONLY ceragen.admin_medical_staff
    ADD CONSTRAINT fk_med_person FOREIGN KEY (med_person_id) REFERENCES ceragen.admin_person(per_id) ON UPDATE RESTRICT ON DELETE RESTRICT;
 L   ALTER TABLE ONLY ceragen.admin_medical_staff DROP CONSTRAINT fk_med_person;
        ceragen          uceragen    false    3540    246    219            @           2606    27257    admin_medical_staff fk_med_type 
   FK CONSTRAINT     À   ALTER TABLE ONLY ceragen.admin_medical_staff
    ADD CONSTRAINT fk_med_type FOREIGN KEY (med_type_id) REFERENCES ceragen.admin_medic_person_type(mpt_id) ON UPDATE RESTRICT ON DELETE RESTRICT;
 J   ALTER TABLE ONLY ceragen.admin_medical_staff DROP CONSTRAINT fk_med_type;
        ceragen          uceragen    false    244    3568    246            6           2606    27109    segu_menu fk_menu_parent 
   FK CONSTRAINT     ‰   ALTER TABLE ONLY ceragen.segu_menu
    ADD CONSTRAINT fk_menu_parent FOREIGN KEY (menu_parent_id) REFERENCES ceragen.segu_menu(menu_id);
 C   ALTER TABLE ONLY ceragen.segu_menu DROP CONSTRAINT fk_menu_parent;
        ceragen          uceragen    false    3550    229    229            O           2606    27649 $   clinic_patient_allergy fk_pa_allergy 
   FK CONSTRAINT     Å   ALTER TABLE ONLY ceragen.clinic_patient_allergy
    ADD CONSTRAINT fk_pa_allergy FOREIGN KEY (pa_allergy_id) REFERENCES ceragen.clinic_allergy_catalog(al_id) ON UPDATE RESTRICT ON DELETE RESTRICT;
 O   ALTER TABLE ONLY ceragen.clinic_patient_allergy DROP CONSTRAINT fk_pa_allergy;
        ceragen          uceragen    false    288    3616    286            P           2606    27644 $   clinic_patient_allergy fk_pa_patient 
   FK CONSTRAINT     ¼   ALTER TABLE ONLY ceragen.clinic_patient_allergy
    ADD CONSTRAINT fk_pa_patient FOREIGN KEY (pa_patient_id) REFERENCES ceragen.admin_patient(pat_id) ON UPDATE RESTRICT ON DELETE CASCADE;
 O   ALTER TABLE ONLY ceragen.clinic_patient_allergy DROP CONSTRAINT fk_pa_patient;
        ceragen          uceragen    false    276    288    3606            I           2606    27530    admin_patient fk_patient_client 
   FK CONSTRAINT     ·   ALTER TABLE ONLY ceragen.admin_patient
    ADD CONSTRAINT fk_patient_client FOREIGN KEY (pat_client_id) REFERENCES ceragen.admin_client(cli_id) ON UPDATE RESTRICT ON DELETE RESTRICT;
 J   ALTER TABLE ONLY ceragen.admin_patient DROP CONSTRAINT fk_patient_client;
        ceragen          uceragen    false    276    260    3586            J           2606    27525    admin_patient fk_patient_person 
   FK CONSTRAINT     ·   ALTER TABLE ONLY ceragen.admin_patient
    ADD CONSTRAINT fk_patient_person FOREIGN KEY (pat_person_id) REFERENCES ceragen.admin_person(per_id) ON UPDATE RESTRICT ON DELETE RESTRICT;
 J   ALTER TABLE ONLY ceragen.admin_patient DROP CONSTRAINT fk_patient_person;
        ceragen          uceragen    false    219    276    3540            B           2606    27295    admin_expense fk_payment_method 
   FK CONSTRAINT     Ç   ALTER TABLE ONLY ceragen.admin_expense
    ADD CONSTRAINT fk_payment_method FOREIGN KEY (exp_payment_method_id) REFERENCES ceragen.admin_payment_method(pme_id) ON UPDATE RESTRICT ON DELETE RESTRICT;
 J   ALTER TABLE ONLY ceragen.admin_expense DROP CONSTRAINT fk_payment_method;
        ceragen          uceragen    false    3572    252    248            M           2606    27620 $   clinic_patient_disease fk_pd_disease 
   FK CONSTRAINT     Æ   ALTER TABLE ONLY ceragen.clinic_patient_disease
    ADD CONSTRAINT fk_pd_disease FOREIGN KEY (pd_disease_id) REFERENCES ceragen.clinic_disease_catalog(dis_id) ON UPDATE RESTRICT ON DELETE RESTRICT;
 O   ALTER TABLE ONLY ceragen.clinic_patient_disease DROP CONSTRAINT fk_pd_disease;
        ceragen          uceragen    false    282    284    3612            N           2606    27615 $   clinic_patient_disease fk_pd_patient 
   FK CONSTRAINT     ¼   ALTER TABLE ONLY ceragen.clinic_patient_disease
    ADD CONSTRAINT fk_pd_patient FOREIGN KEY (pd_patient_id) REFERENCES ceragen.admin_patient(pat_id) ON UPDATE RESTRICT ON DELETE CASCADE;
 O   ALTER TABLE ONLY ceragen.clinic_patient_disease DROP CONSTRAINT fk_pd_patient;
        ceragen          uceragen    false    3606    276    284            1           2606    27119    admin_person fk_person_genre 
   FK CONSTRAINT        ALTER TABLE ONLY ceragen.admin_person
    ADD CONSTRAINT fk_person_genre FOREIGN KEY (per_genre_id) REFERENCES ceragen.admin_person_genre(id);
 G   ALTER TABLE ONLY ceragen.admin_person DROP CONSTRAINT fk_person_genre;
        ceragen          uceragen    false    3542    220    219            2           2606    27124 %   admin_person fk_person_marital_status 
   FK CONSTRAINT     £   ALTER TABLE ONLY ceragen.admin_person
    ADD CONSTRAINT fk_person_marital_status FOREIGN KEY (per_marital_status_id) REFERENCES ceragen.admin_marital_status(id);
 P   ALTER TABLE ONLY ceragen.admin_person DROP CONSTRAINT fk_person_marital_status;
        ceragen          uceragen    false    215    3534    219            D           2606    27351 ,   admin_product_promotion fk_promotion_product 
   FK CONSTRAINT     Å   ALTER TABLE ONLY ceragen.admin_product_promotion
    ADD CONSTRAINT fk_promotion_product FOREIGN KEY (ppr_product_id) REFERENCES ceragen.admin_product(pro_id) ON UPDATE RESTRICT ON DELETE CASCADE;
 W   ALTER TABLE ONLY ceragen.admin_product_promotion DROP CONSTRAINT fk_promotion_product;
        ceragen          uceragen    false    256    258    3580            Y           2606    27907 %   clinic_session_control fk_ses_invoice 
   FK CONSTRAINT     º   ALTER TABLE ONLY ceragen.clinic_session_control
    ADD CONSTRAINT fk_ses_invoice FOREIGN KEY (sec_inv_id) REFERENCES ceragen.admin_invoice(inv_id) ON UPDATE RESTRICT ON DELETE CASCADE;
 P   ALTER TABLE ONLY ceragen.clinic_session_control DROP CONSTRAINT fk_ses_invoice;
        ceragen          postgres    false    300    290    3622            Z           2606    27922 +   clinic_session_control fk_ses_medical_staff 
   FK CONSTRAINT     Í   ALTER TABLE ONLY ceragen.clinic_session_control
    ADD CONSTRAINT fk_ses_medical_staff FOREIGN KEY (sec_med_staff_id) REFERENCES ceragen.admin_medical_staff(med_id) ON UPDATE RESTRICT ON DELETE RESTRICT;
 V   ALTER TABLE ONLY ceragen.clinic_session_control DROP CONSTRAINT fk_ses_medical_staff;
        ceragen          postgres    false    300    246    3570            [           2606    27912 %   clinic_session_control fk_ses_product 
   FK CONSTRAINT     »   ALTER TABLE ONLY ceragen.clinic_session_control
    ADD CONSTRAINT fk_ses_product FOREIGN KEY (sec_pro_id) REFERENCES ceragen.admin_product(pro_id) ON UPDATE RESTRICT ON DELETE RESTRICT;
 P   ALTER TABLE ONLY ceragen.clinic_session_control DROP CONSTRAINT fk_ses_product;
        ceragen          postgres    false    3580    256    300            \           2606    27917 *   clinic_session_control fk_ses_therapy_type 
   FK CONSTRAINT     Å   ALTER TABLE ONLY ceragen.clinic_session_control
    ADD CONSTRAINT fk_ses_therapy_type FOREIGN KEY (sec_typ_id) REFERENCES ceragen.admin_therapy_type(tht_id) ON UPDATE RESTRICT ON DELETE RESTRICT;
 U   ALTER TABLE ONLY ceragen.clinic_session_control DROP CONSTRAINT fk_ses_therapy_type;
        ceragen          postgres    false    300    3578    254            C           2606    27334    admin_product fk_therapy_type 
   FK CONSTRAINT     Á   ALTER TABLE ONLY ceragen.admin_product
    ADD CONSTRAINT fk_therapy_type FOREIGN KEY (pro_therapy_type_id) REFERENCES ceragen.admin_therapy_type(tht_id) ON UPDATE RESTRICT ON DELETE RESTRICT;
 H   ALTER TABLE ONLY ceragen.admin_product DROP CONSTRAINT fk_therapy_type;
        ceragen          uceragen    false    256    254    3578            :           2606    27134    segu_user fk_user_person 
   FK CONSTRAINT     ‹   ALTER TABLE ONLY ceragen.segu_user
    ADD CONSTRAINT fk_user_person FOREIGN KEY (user_person_id) REFERENCES ceragen.admin_person(per_id);
 C   ALTER TABLE ONLY ceragen.segu_user DROP CONSTRAINT fk_user_person;
        ceragen          uceragen    false    219    3540    237            5           2606    27184 &   segu_login segu_login_slo_user_id_fkey 
   FK CONSTRAINT     ”   ALTER TABLE ONLY ceragen.segu_login
    ADD CONSTRAINT segu_login_slo_user_id_fkey FOREIGN KEY (slo_user_id) REFERENCES ceragen.segu_user(user_id);
 Q   ALTER TABLE ONLY ceragen.segu_login DROP CONSTRAINT segu_login_slo_user_id_fkey;
        ceragen          uceragen    false    227    3558    237            7           2606    27189 '   segu_menu segu_menu_menu_module_id_fkey 
   FK CONSTRAINT     ™   ALTER TABLE ONLY ceragen.segu_menu
    ADD CONSTRAINT segu_menu_menu_module_id_fkey FOREIGN KEY (menu_module_id) REFERENCES ceragen.segu_module(mod_id);
 R   ALTER TABLE ONLY ceragen.segu_menu DROP CONSTRAINT segu_menu_menu_module_id_fkey;
        ceragen          uceragen    false    3554    229    233            8           2606    27194 +   segu_menu_rol segu_menu_rol_mr_menu_id_fkey 
   FK CONSTRAINT     ˜   ALTER TABLE ONLY ceragen.segu_menu_rol
    ADD CONSTRAINT segu_menu_rol_mr_menu_id_fkey FOREIGN KEY (mr_menu_id) REFERENCES ceragen.segu_menu(menu_id);
 V   ALTER TABLE ONLY ceragen.segu_menu_rol DROP CONSTRAINT segu_menu_rol_mr_menu_id_fkey;
        ceragen          uceragen    false    3550    229    231            9           2606    27199 *   segu_menu_rol segu_menu_rol_mr_rol_id_fkey 
   FK CONSTRAINT     ”   ALTER TABLE ONLY ceragen.segu_menu_rol
    ADD CONSTRAINT segu_menu_rol_mr_rol_id_fkey FOREIGN KEY (mr_rol_id) REFERENCES ceragen.segu_rol(rol_id);
 U   ALTER TABLE ONLY ceragen.segu_menu_rol DROP CONSTRAINT segu_menu_rol_mr_rol_id_fkey;
        ceragen          uceragen    false    235    3556    231            ;           2606    27204 J   segu_user_notification segu_user_notification_sun_user_destination_id_fkey 
   FK CONSTRAINT     Ä   ALTER TABLE ONLY ceragen.segu_user_notification
    ADD CONSTRAINT segu_user_notification_sun_user_destination_id_fkey FOREIGN KEY (sun_user_destination_id) REFERENCES ceragen.segu_user(user_id);
 u   ALTER TABLE ONLY ceragen.segu_user_notification DROP CONSTRAINT segu_user_notification_sun_user_destination_id_fkey;
        ceragen          uceragen    false    3558    237    238            <           2606    27209 E   segu_user_notification segu_user_notification_sun_user_source_id_fkey 
   FK CONSTRAINT     º   ALTER TABLE ONLY ceragen.segu_user_notification
    ADD CONSTRAINT segu_user_notification_sun_user_source_id_fkey FOREIGN KEY (sun_user_source_id) REFERENCES ceragen.segu_user(user_id);
 p   ALTER TABLE ONLY ceragen.segu_user_notification DROP CONSTRAINT segu_user_notification_sun_user_source_id_fkey;
        ceragen          uceragen    false    238    237    3558            =           2606    27224 '   segu_user_rol segu_user_rol_id_rol_fkey 
   FK CONSTRAINT     Ž   ALTER TABLE ONLY ceragen.segu_user_rol
    ADD CONSTRAINT segu_user_rol_id_rol_fkey FOREIGN KEY (id_rol) REFERENCES ceragen.segu_rol(rol_id);
 R   ALTER TABLE ONLY ceragen.segu_user_rol DROP CONSTRAINT segu_user_rol_id_rol_fkey;
        ceragen          uceragen    false    235    3556    240            >           2606    27229 (   segu_user_rol segu_user_rol_id_user_fkey 
   FK CONSTRAINT     ’   ALTER TABLE ONLY ceragen.segu_user_rol
    ADD CONSTRAINT segu_user_rol_id_user_fkey FOREIGN KEY (id_user) REFERENCES ceragen.segu_user(user_id);
 S   ALTER TABLE ONLY ceragen.segu_user_rol DROP CONSTRAINT segu_user_rol_id_user_fkey;
        ceragen          uceragen    false    3558    237    240            F           2606    27392 "   clinic_disease_catalog fk_dis_type 
   FK CONSTRAINT     ½   ALTER TABLE ONLY public.clinic_disease_catalog
    ADD CONSTRAINT fk_dis_type FOREIGN KEY (dis_type_id) REFERENCES public.clinic_disease_type(dst_id) ON UPDATE RESTRICT ON DELETE RESTRICT;
 L   ALTER TABLE ONLY public.clinic_disease_catalog DROP CONSTRAINT fk_dis_type;
       public          postgres    false    264    3588    262            H           2606    27477 $   clinic_patient_allergy fk_pa_allergy 
   FK CONSTRAINT     Ã   ALTER TABLE ONLY public.clinic_patient_allergy
    ADD CONSTRAINT fk_pa_allergy FOREIGN KEY (pa_allergy_id) REFERENCES public.clinic_allergy_catalog(al_id) ON UPDATE RESTRICT ON DELETE RESTRICT;
 N   ALTER TABLE ONLY public.clinic_patient_allergy DROP CONSTRAINT fk_pa_allergy;
       public          postgres    false    3594    270    268            G           2606    27448 $   clinic_patient_disease fk_pd_disease 
   FK CONSTRAINT     Ä   ALTER TABLE ONLY public.clinic_patient_disease
    ADD CONSTRAINT fk_pd_disease FOREIGN KEY (pd_disease_id) REFERENCES public.clinic_disease_catalog(dis_id) ON UPDATE RESTRICT ON DELETE RESTRICT;
 N   ALTER TABLE ONLY public.clinic_patient_disease DROP CONSTRAINT fk_pd_disease;
       public          postgres    false    3590    264    266            1   
   xœ‹Ñãââ Å ©      )   
   xœ‹Ñãââ Å ©      '   [   xœ3äôô
õõæôôÓ
¾‡;]<%œ‰)¹™yœFF¦ºfº†f
V`Äã G\FœÎþ¾žÁžþ~®ÁœŽîþ
.®
!¢
ŠÑãââ ƒ"Ü      O   
   xœ‹Ñãââ Å ©      Q   
   xœ‹Ñãââ Å ©      S   
   xœ‹Ñãââ Å ©      W   
   xœ‹Ñãââ Å ©         ¥   xœ•A
Â0E×“Sä	3i’ŽÙÅ¶‹@i µ]u#ˆàBWÞEŠ¨(Rø»á=æ‚!·»¦Ï*Âö‡óéUè¡DÀÜ=#Tqˆõ¤€:M¹¯Ò:ÌÂ”Æ¿D|¹°B/É„‚ƒ%íÈ1‹ÌÁØ¥ÜÉ6mûæCèYIŒè4£+7üÝ[ÞÕÚšwvñò2 }‚¬ÉbùVmÖBˆ°ÔTï      !   y   xœ3ätõss
òu
ò×pÔätÍKK-ÊM-ÊWÈW€±9K8Sr3ó8ŒLu
Lu
Í¬Àˆ3ÆŽ¸Œ8C=ƒü‚7:‡x:ûsº¤&g&æd—$*¤æ)–få%Vd¢j†ÓÐ=... žh-ö      #   
   xœ‹Ñãââ Å ©         Ë   xœmÍjÃ@„ÏÚ§ð
x‘´Ú?ÝÞCBbƒ³I.…ÚSßŸÚRL
:	Í§™aá .Ýaœš©Ôqº~oqYwÏ¯Ïo`di1´$
±RVqÖE>Ãmx!ð~‹•ÖÇ‹ÔGE±Qˆ9o>óN%Ø@ä0Ãc}Š*¬œlŒ,˜ƒˆúr9—C!¾ÂôÇÝð–³o()gåh±£°
#°¿Ö{ÝË¬œuçZN@Œÿ{I-ÏVE…'H‰ƒ¬P7kŒù…äO      A   
   xœ‹Ñãââ Å ©      %       xœÍ±‚0Ðùõ+Þ #ƒ!%aAƒË³<L
´I­þ“ßáÙ88“{‡;›ƒjT­ÛËNtóÈïx$œ½¡ybíËÃ”ÆÅ:(d±Ïd™å%Jyø†î_Q€î«îÜ¨^uu[ä vÆ^É
i¤/ód)Áëñèm
šÂ#áÈhÂç=Úè“W+ÃFñ–äDë         |  xœµ•]râFÇŸÇ§˜
X™éù’ôä1Œ±\BJFà*\û2­ƒ(¼)û9W.–ÖëŒ¼lÑUR•šž_wÿ»G–)ÅXª2I\¿ï<-‹Û¢ŒêŠëjTO,½µ~`ÂñçzcÛ¯=ŒíÄþ2.JrUÖžö½´Í¨À?±ÌdBKÍ$ig³v,»Õ¶{
_.ï“vö˜´Sä9ËÎ™ Lä\æB%€ešlI˜-ç«#ÆrÎÎ´Eì	‡½†|ªÐÎ¢ÆušêŒx{e]I¯ÇÃKçG5ÞV}Km9tøôÅ{é5?Å”ÒL³TâÙëð9´‹d9_‡Õ,„ÿ›Ó)äƒœvÈ/àš0Ã´R`ŒBÐÁÁ¯ì¸Aì[[ZïîjÚØªwíî>„Î$ÁSC–óûG„þaÝ>w?ÚLK“¡ˆ+›	ñußGø;êÝ­+k°Æòfœ§¤]lž’u7[Gæç‚šî4¯˜¨•›ºqdèn
K{µ÷Î~¬Zd#Ý¦M–íÃ<L÷1þMä’GJ4ü€…³#¤4 ’Ü8[ÑžõeÝPÏ­jK÷^ŸAÓ	--u±‚©F“‡6¬¦a½>ÎWÝÅý2ÌÉ´[¾"q Œç"Ë%áéÙêc	‡Ô<Rk" Újtm)‰³TßYì4¼Ò¢RG––ã^a‰½¥"îŠ+wé¯1ˆT&…Ý„eXmÃ²]ÍøE÷¸]tÝïÇÔÀr)r€Ds-?E]  ždRFiœtØñ’¢pL0Éˆí‹ªhFþ+?¾¹áÈÂh%p²i§];Kþj=¨;cçŒ£QÔäÎöÑÕ9Cƒïßö+
1º,F?½—–ÀÓŒ½Kk¢Ï¹¤€Ã"sÎ±ÕÚI>”mçÂMiÎ³DËLâ˜¾q8Žqä )OQL¹0‰ä†Is&ö	ãþ|MññÏß¤‡7‰¯qkL\LP½&Ø·ãÒ‘«œ·%†¯ìÅ	hÆ=ïö
§óß’iØl×ÝúÔÉ( LÐÒ$ÅËŠCìH,ï+2(
<W,j¯4­ãÉ>Ž!¾‰)6+Àma2b«+-™Øj7§ÚUÕ~´ãL(Ã€„Õ}»OaõNÍïW²4Ê\qcäÛ
øâbr¥Ã8üþ=Ä·KóSrvvö/•rì]      	   l   xœ•Œ9
€0 ëÍ+ü@Ân’ºx€`ðè|†ÿG±ÐJ˜rfb³´Û4¦ 4]X´^#k¢Q.`OÊÂÐÇ>ýIäuÎËËš¸ÀZ<‰#ãjÏÈ_Pˆ+8ø²¼»QJV*'ä      -   
   xœ‹Ñãââ Å ©      /   
   xœ‹Ñãââ Å ©      U   
   xœ‹Ñãââ Å ©      +   
   xœ‹Ñãââ Å ©            xœì½ËrâJ·.Ú^~
GuÎÞ~åU³¸ÙÆX\ØÆ±"Ë„ÅÅÀŽõ0s7VcÇß[qêÅN¦¸X¥]²]5å˜U1
”H™ß9¾‘cd ÿÛ”þ­Pªå¯ëÿö¿~ŒnËìþHªð¯SçÓdªO
öÅÔžì«.ûÔêØûoöJ'$9¤:RÿócÛ¬kŒàf³‰a»ï¦w‡æhwÁõûÝçÆC«köÌãwv·ÛÝJM^ØõIGëñ¢Í•±muŒÉ¤õ<3&SÓ­¯ÏUçîúÄìÑtÓä?9àßÖýQ:0Õ”“HTÂ'@ÚÃzho~ÉŸÍ>xfßØÖàõùì3{Úló…"”I@\‡0Ô”D“„? ÓN—ÙŸõ•€§¤°š" 	USzB€"P/
â½ê£ 0„‚À=¬»æðõîüÃHr¤äÓœÙýùÏÎÔìX?6WC	‚i‡R—¾LW…Ry{Ó®1éØæ˜ÔçÉ~
Ä4¦ HHdtÿÏºÆé@ŸœÖ
ÙÏ’ëÉAC‚@ÅHeï„*x'ð÷;ñúNxMªÏ;Ž¿J°I¼Àž¡ðq°q° lú
ö+Øä8ØaÜ}×khuÖ?¥B\)VHKç…ÌmýA£Ð Mè
šë¼·kfOŒ	¯‘5°ú?ÿ‹™RÇ¢žF=Ëêóç¿F§Àó;¯¿óz…uPo£ ¾¹Z›“Vg`Mœ.öôÁÄs³ÉƒeOßÛG *ÖQ{®/ž¹åÍ3™MöÜN×ÕšËö½ÞÑmƒµ¶iu}[X¶Ù7GL¦Vw«éþ-:lÜ}öoÃ­ÍîY2%$R
ã$d¢£¸SgùoªÎ^ÑÿŽê| ž«Î ?ÿÕJôÄããíÔYL¼þluF€:{ûøÁê|ð¸?RU¤xâñ¢'kãÂsÇ‘šZO†ƒŠ±¼|hŸwÌ²yYh¬
 d&…Ñ5éd
´ð4¾»É^ªIÖhÜ¼«šåÇ<Ò5¨åª¤ôÈo0o¨Õ;KmÕ|)ÕûP3_Ìî]iÐ’‡ömƒßøáþŒÛ&¿‘5éÌÚ
º6ñSiø¸TËÞË¸Û.°ÑÞ^_ZÕA!¯žÕQ:ýcÓS è:ü› k2Ý)ú•>žZãËì¶ù3sÌ/&UØœ•”¶
^µˆÁ<­~¼ÂÉã)óÝ`RR0Tñ=ïŽµÀ§Úkqâñ¤gñÆ“æ¯.û’ÚJ0Ð¤¤w²sÿ’m\ÔÍwkã3ñž8Ýf~)–’X…¸‚ØE ¸SÊ?lQÎZ‰ü\Ìô®eÿØ\
9$ ö†Ä„ãŒóh—ËFŒ4§JÛ'y^dÖcÛ™Ó
ƒ`rªwôîÏÿ=4;ÖäÒ;Ã†˜‡¹Ld…Ik?L1¶§¯Æ?l‡žM­õ£ñcs9ÔÈE
%L~KÏ+Õ°¸™ÒYN]8í²K#öüÍ/;Öp<c˜Z-Þêµ[ü"GÏXÞ`K_\á©C”h
“$E
D%ìô ”ýrŒ:\#ŒW„ŒÓñZü\4\Ä.ä«2`3ª3ï|Vy·þƒÓñ;cÄ§ÁñAQÚ¾¨ïÒ*…Y$BÌÓbSÝ·”öÖTr›ã|ŠŽÍÖÉÚê€í×>³´ê?$¥LR•ùzVQ¶#pÌGøHû–‘ÿ’ùYÎånÆˆRDe‚Å¾~2¾ç>òè‡Ÿ¡c­¶Â.ÇÆþýÜpìMb@ eÂWü‘ƒ±FN rÄ™©eBfÖEõGÅ99$ù#‡cÅP`«å7Ùj5!á: )ä,5bD$‰¾ÕdÃ “í±<üq§žÇ à¯$ÖZ€Â¼?Ð9kä®Î>rÈ9ùEîÐÕ÷Å
ŠqÍu$OW¡Ì<i„ýqSbŒ›h¦ÛÃøã¦Æ7Ñ<·‡øóRŒM
{À‰ˆÐŸË„~8ÑÌ° œ€ ?—ý:p¹Ü>
z
ls?î—ÛH[i¤´êxÛU)×G¥e@`­—O(kÞŽ+Óê­1šÙùb¯iÙÂÏÃÚó¢¤ñ.*°},¬
Â‡µI]â
Br’BÃƒ¨69ØÝà„xÂÃ¯ù!Ž óâr„9ï”]ê§©_”
Èƒ¨»t¢¿Þ•!HO%B0EpR…„Jè
²‰Ï8?)EÐ=N"gPÚànœ$)+ò	¤BRÿqVŒ®Þÿù¯¾©ÚPiàP]
- H!àcÿÑÊ¿‡öÊ¿¨½$	%ÉÊ	&þãT~íU~Y{‘„ÀäIýÇ©þ6Ú«F¡½HU%I=Á²ÿhð¨ï®ïÒ_¾x‘²˜ñU¿‡þîúñ.v
Ù8¹ùU#õË®ÿ
Þuå½*ìŒQ‚)sÕÀUS¾]µWWMþë¨«*I
ÀV¿Á~[9v¨$uÿÌ¼µ©ðö 5ÿhÀ3^9hôÙz V |¶žóª;™i§%“uó—²MºT¾bý:úw¤çí”0Ï
½>Þñûÿ1	xŽ9Æ E' f,GÙ÷Ÿ^ãrqŠêB{ì¬Ê¹ý8E)—_–s§h½f·ºèLÎG7½VÁ>o³£ÉD3Ÿ[ÃòÔª?ç&…ÛI¥Ó	§D§Py¬ŠW`ÉI•ÈXR½
(Jx¯Å	ð,RíŠ-9m}c±¥“#)\Èt’NØ³%Â­
€o@M­·Ü³mžŸ2ÛFü' Iß3ÉëL¢þE„Eö ½U,UêU")	áX°ÇK0‰Hß #„/\»~yB`úƒÁÓŸ7'Ú5ý¡™þ~!Yý`&ø•ìô›þ"NG?~ÿ?qúƒ’ª(à„`Ö¢ &)u ð<v>Ãi;xàµvG¼õßÂ]
èŽŸ¦:£‡R
£ŽZÐ÷uþ:Š$xBˆ@GÅóÿ1Ü²F¨£¿ƒM
èŽ@GUÑcÅ:zÄŽþ!:ªªTev”
t”¼›ü‚ßmöÿÈBâ¨÷Ï*$F„Šc•9äÌ
êâÁ
ã?%¾ó›–Šÿ^ÅÅ†ŠÉä„JåÁjåw
÷‘õÆŸ¥á¿W½ñŸ¡áT•¬žAù|ÀÆeÇ|éÈý”}éßÁ%	èNßã…Ëá}é#ŽÆŸáKË
‘$f†=•‡®`ëvÃ¿ï`ëmÖó/ïwD¼U’¯po6é†;Än“!Ö¤©h™Tý¶À
d
¿-pÄ¦L"•J@9‘kðýŽð7Õû¦z_­ârŠ¨I‰/|Ðà©6v-+;ãàl£ÇqùGÍèÏl³«wÿ¡YÝÙÀÉ'tZlåùÚ²»În/`ûEØêÛõ¢5¯Åg; À·úv7‹9·òGoNüW²]÷c³½`ã` Ålçà#³}ˆ­ƒC$EQÏ~e¯9t×eÝäuÓ?Œ.Sš¡5šZK]Uÿ½Ï¿Ov¬ánl¹8ß
¬ÎÓž)	P- § {
hR…˜ÊkÝ¯7wRDœ+’J˜s®ï.õÉä…©ºè²aOvÛ "Åwïuõæ„:sN£’K×óî9G¼ÈsÒùÑn‘é/,Ÿÿôôh§ü&_èC.ŸÿA›k†RÃ¸zçßñ‘s]ü\s¬JHæó·`“s Ål—s/÷Ìß!¶9ñnJó
wÌö9?wˆÎCdþQÁ2:gñ}{ß^À×pI%‰0@œPÁÊ8<RùðúùúùZ‹•$ù„
V»á‘„åïzïz/ÐZæøRžPÁ6üNXþNXþj¥cY>‘%Ž~',',µŽÊP’=‘@GÅ	Ëß®ï@×çè¨¨¢2;*H•€ïÏ8þNªÿ€eèï¤ú·«¸
,Áe¿¶éµüœ«ø/—Ÿ¿h¹æ²\Ï{ÊÏÓ/¥Užhµ€òóç»ªVx@7×ù{ý^µŠé»Ð*Ö®*­Cz¨y[+ç/ &œB”Ÿ/¶íö*ÏÉûÃþKî®/<g“J!%p’Y") ;ä)§lÚp·8!Þ}¥_¹1;CñH 7Ä!Šav^ñnFý
÷÷–„n¸CìI"Í@”ñÂ7‹ö»G ¿+bW¹à$l	#È‚*`(Î›ý^ú^òÝ1ûCµ–±U‰oƒ¬
NdÁ‚&/h~/
}/
}•ÖB+Ì›¬g¢ïÜ¾W†~?¥E*ó•Y°ž‰Äë™ß+Cß+CŸ££X!2¤'²`õ½õò{e(+CŸ¡£DV#ZŠ`õ}§@¯}µŽRBY=Q«—èýÛ-}(~@¼ëïV ø*.SB! 
6Š RÌvŠ?²`b«ø‰þŠ ä½?‚þ½Öü½Öüõ)IIá;iž(‚E"$Ž /}ŠÿÝ‰>CÅ,SU9žU~Ïfñ¢ªþkkP3'SÃ©µÞ+ìgWvßýÎUýÞ“x_…ï“NÜÎBˆ£NB”©)ûò×¬~û_ÎÚYj¹§UiåÍÚ),´\fíöÍË6†¶•.d–ó)H'Úôkz¹~û,“Ùe	(p£áyØÃ-£>4JuÈ7Íç ¾ËQE>84ð³DÝ-NE ·ÜýE¥Ç¾ îæ²ToÂr6 nª¤/jjí¢‹³Vç¥KäšÔLçŸòÕU¿¸š+ít¢!Wïg…Ùç'IAÂ÷{`Óc’%p€3á[0¸œ(‚#[µÊ(`n ö÷f¦ñ¥ ­.LfÕÙÌnÊ™fæ¦{ÝYÖÚgljÆí«Õ¨QÇ“áÙxR—O’õE0#%…I’¨²$ä¢­qv·8Q%Ð 
 IiÕ—J IO˜é34ýë;ó¹¤v(éfW/ÍùâFév
Å ¸RkÒrØoÀDs^ý*óáÄf±Äfý$ *:4Hâ“£»Å‰
pÃˆà~Zjõæ!ÜÕEÉ€ûªYQ¬§ÆK¶’}ª€ž™0F‰³œÅr7½S‹%Ó¾md«Œ…¿nÂ<
’”T3-×p»[œ¨P 7Šîr.µºv w¹ž^hA'*åé*g_$`÷f@©Ü«ÃáL©Üš·ÈÔkÊÃœ,‹Ù¯:Q‰ÁÍWÇ(Ã3‰ ð1&n°×âDE¸qp7^J…•–óXíz–ëìZ1¹XÍÚmÓ¸Ã©oÞ)z ”GÙrâe¹2¥íÜòôÑî•Á}û«Œ	÷4•QR'H’Ÿ1áÇ±»Zœ¨X wçšs¸›¸œK{áF¥\k¾HW*wØä8ìOºÙñÍèq`Ê—Wõ´‘égéR¥»³kmu~ÿÜø:¸™vÌŒsIXU\¸v»[œ¨‚üxE~<    ‡»órp<›÷‘ãÙ
/x8“¥ÜE›H™V« ÁjG{jæŒËêË¬ÕË[ÒKíÒ~ùZ¸•”$'	A’rpŽünW‹UpŠâ4¼/;`¶ûÀ˜ n»IV¹¿i–ÎK÷ƒËôS)?”èËµÙ`x?R†µKíòYA™f»:¹
­ÝãŒü_Ä¡$%Ù;Ãoƒ|mIR¡’L±äp¯Å‰*à’(
.É!g¼ÑKnÈµe ¹fFJÚ°
««²²ÌÞ[¶°ÙÏÀ
8îáj¤Ê‰Ü%nè÷¡§ËƒC'3²(€ÜÝâDðIŸä7A©~`T°¶ê€@£¢æ¤ÉŒkí©fÎàB“fâ±v' Ó4ý|S:œ^tôÊõåWCÎÏäN™Ÿá,ùk9Úkq¢
¸%Ž‚[:Cö× ò>
ôÁ²­_äåÊƒ´ÌN¾4e¹7É¡Ü‚fª2ºÈd³F¯[‡…þÚq·œ"”™@!ÀíjqÂ\ÞQPL oÆ{´¼K9v=HÅo¯É¨H®f‰óQ/‘)§ ZÛ¾”ìeQ/rëLéÝŒ
˜êå‹U|ƒBIJFÈs¼×‚a.à™8
žÉ1çš•R®lV²ógªó–LõiÆŒ,ëbP,i‹Z¢Y,ç3?JÚÙrQ„öU>s9…x˜•`_w»0ÄTGA5×ˆ—ë s'GœÎdz±,\wî:º­Ú‰Á}ådzóy'ßº°úW=m±ºœäë«¯6äq…¹€I¤ò½¬»Z0Ì|GÄ7Wfµ\DÌþ®]ÄëK+{IÇ°Û]^ÞdrV¹Pì%@áÎÀOÌc¹¿ëj—ËìTÉ|½eá;ñ’$PYõ<ñ^
†¹€tâˆH'Ãœ1!?Ìa e©Óùýð¤MåÊÝ Ýk*­Ú“ÚêÚ7v¶]Ê«k@eÞ-þ˜c9I%KbÌw-ææ‰£ažå\h¹êæŒ¾”‚lK­ŽÔ›tûš¶n‰¬Ù]ól|Eûæ<£]—0ÊèÈ*.—3y˜ÿJÌ³æéDN0Â’?æd¯Ã\@?q4ô³œÓ–Z®àÅœ09¼hA^b^ž5K7Ï=)ýXš-HùìqÆ¬J^ÙÅÛ®fOŠ`¹*t²_:ƒ:˜cÊÈN’ÊŠ_<ËÁÜÝ‚a.àŸ8þ¹Ðê¢=z=ó<“C~è™[ƒê–G·™§Á•ñíb…Æ—×ÝF¹rGZmøX±õ¹¼Y…/Æ\å~ D“*_oðÃà½sÅ‘P†yguè·0¼s`¿åòîjœ~N¯…ââ¢8Î%†8s~¯ç_úOKä-½[.àãe"tÌöc0ç§¶Sž÷$ _ ‘ŸÎîjÁ00P	]hš¤=>y1_9;pù-««y3c
î3‹›–®u=/éè¦uATEÓÑy«6¾èÏgÚc8Ç”Ô$2Å~,”înq€€…’HX(óÍÓ@[yíy1ÓÎ*Ðž?Œ&fç¢Ð¬Þ#dT{EûvT{&ÝÄå°Ñ®”³W
ûåéªœÎÝæ›!1g¾T’\¬pÈý‰Ìx?#þIBf%Â¯&$è¤yÁ€I,Qêšó\ÙÝ-ð*J"¡¢xTÊy
 þI
&FOJcª?‹Z~99›<¬z#K¹¸Ïô»Ó)¼*·µz¢mêÏF!l‚ÊQàß£ï;ØÙdéXª
PmÀ@°Q	e `ùÀ{)féq ¶ÃyAAíþ´m
W/í¥\c·œ5óµùí)$,òÔ¼µ‡£Ê]õ<,ý`m'
›/“ª@h»»^@II$””¯1ŠäuÕµžŽèª›V7¿˜V–·9
áså¥sYêX¹RO,Û“~B~^*ýK|1é¯×vbá$¡Uìt¯ƒ]ÀJI$¬”Ã¾(¬<sØ5)0p…ªÙÎ²þŒ‡óÛ{ò’ŸÃ——yµüÔz æKe±„…¬|ÕH}ñô%1ÝÞ„ç1‹àíjÁð0R	#åx/ýÕ¼¬æÌ†$ú}ãúi:ÖMM1•É}‘çOuCí?ö/_¦­6CýË–6
ðûB“ £·/§NR¡7-n ¼«^@KI$´”ÏÜuoø…ß áóêªVæ/Ê
R¹Èž×p±aÔ39cQ¹YÜ=\ä[•'Ü*TºOÑ¹1²Ì:30*7ìô­À«|IHa7Pð®x7%‘pS¼ÄfUà›$pFmiýB#S¼nkWÏ×Ó¦}³¬Œþ’ÉO†`	3ÓRFÍ<_ÏaXnúÁÏþ ˜TeH ñ ÞÝ‚/ ¨$‚Ê€¯âòÿÈ€Lã@ÿñ¥z1NŒ r­E–J7+Ú×Ú÷‹ú´òÐxƒÅ|+ÙYÁÀ_G–¶˜#Ì}C‰a‰ÊînÁ0T	Aå
œ¤`Îþ.—ìêØMÜ—ZÒÍò>Œ¯`Y‚†®×uihä:âyS©ºvÞpüP÷¦ ’Â(‰,ù»ò^‹ ,•FÂRWÏ%:4ï
-—^·Ü-+àlÖ|¹ñ#¬Î—7¥Õåýå¤n1“_íZ=½jVza“^>Ô¼#¾_¯6“±ðÊ^
¼€¥ÒHX*^[•rÞÐ# ¾!†ÏïóÝfe:!³‡L¯Úït†zö93©j™;µ¯µš©Öoè¨£_ÛbNx<—Ïªwùn‹¹»Ã\@Ri$$u¥ÕÓ‡¹çÜ‘_É=/¨´Ø3qaQ[éÁè¼\]Ýh‹ËÛù-{ÎÈ(¯¡D£Gvd\éW¦TFA1›3“)ªäç½Ci¯^@Ri$$•Ÿ_ù˜÷E9×6ïÆ}Ãè\Ôì‹ÖÍâ¾­WJº7ìç_¬ñ¤µª%Šx¶²ñ­þ<”>À¼¿x^¯Â·d ùEe ØkÁ€ÐT	MeÀ7˜v{¿lN}ÔP`à7£³ê¤Öo¤{Þ…ÕÙÙÜº+f¥A+‘-””V¯Oï
óU9:ÿó.§ØÔJÔ$‘%€ü'ùÚ‚/à«4¾Ê€oÂÃUüª¼ÊÑï&ŠÓVoÖ(><ä;F¡¯/z·Tž•+­ÊÝX¾Ã·åQË°ÊÑÍ«¿àÐ8åE@Iª„ï(é¼»Þ³éä®p÷= ¶Á†éW»÷ýo\
 ,¹s€`ÀÈ5vÉoä{ßÿÖ#WD# ïyc2Ómó8ÐxDu¾CæŒÀ=ÛÃ·ö‰ÏjÃƒÃÂÙ7¶åÚ—„}öœxd,<™T!{xÀÁáþÝvý”uûw›¾£Ûâ£ï6ñï¶üŽn‹wQ¾ÛÔ¿ÛÊ;º-Þ±8únËþÝVßÞm ÞÜ$ún
¢f4’81sï
ñ«‡Ç‰ì9<øùñ¥ò4ÈÎúZfd^Ö

?w@§ö0~hŸÙƒ ùîz•{Y-”°|ö×¡T*a¿†Tò	#laßµ`°;@£’K×óÎ¾6›½/KÈ>l;½3þ?6¶æ}Û0”u'¼— »š¥lq±¦œ‚()
ÙöÈd¸ìú[`j¦1Øuxj,¦‡Ãi‘]7|7Êà¿ôì	£ýü›m¬ÓWHþówBî Šöâ´½H·ss¸h
ð€¥}­ÙY²‘ŸŒ¥Ëš´Ðn®žÙ;áu˜|<o¯59ð:Ð›¼’€¸Î+¤”’lŒ
%¿¢žñ2Lž%ˆÔ#úå@çÕÜ=¿ÒãÜøÂ}·yaoÆÃ¯£^rƒÂTTèu³¡1o³Ôçp¢ß}—¢cÚCx¾#ÄP"ô½Ú3	£>ö¾N úå‚ééòè—ÆokªØºI~yZìÑþ×¿~Ä/…`ù=ú…ºÙYÛ¨Û¥fèO.¤šíÐcj†Dj½jÆÿ
ƒíØþUâ
¿VÉ(¯5Sù*¡ÿ&ÓQ+ÙŸ°8Ð1xLÇð·)i™œ’P’@™¼ÏÑª[3›MßfÈb‹÷'L /ƒKÆìe ¢—AògóÒóßks¿(À}ü… Ì	’¨Œ•õÿðE-ÛÇ´LµH#Ižã‹Í«ÃFþ]#¸€1{®å­i¾yß=µ­j)´•']íwûÓÛt§»•Aç™æ£)
MYIB¨$Ùm¥2ESÈþÁ(w
†ºüýn ½ÛÎ>ˆ’D0ø`^ø
÷G›RŸa'[ö"(‚áuúU2ü9Ç$³Púý×¯IFå©*¦ï¢¡ßƒ?}Éÿ@É^qc:&J™$MÙ™âöa^OqÁû0w›ú>ÐÂÕYCÓrMzoÛveùXíÕùØ¨•º–TÌ=t.Aâ7(üqt¾…:Â‡U[Ôw-N …Îß08fnÿ”P‚ÎfW* ôsâQß¡™Íx_·ŒÙKàÿsù«¼÷%øÐ„›íáoƒÙÿò"^;,# È¾K$Çwó?ª®xÒ*¸cª È©–#©ÜàÓÔ
Ø4Ô_(ú°¢å4zÌ»U¦©Ý*—ÕÌu~5ž©ƒ‹ŽÑ)ÒÌÒÌÒÙò%ìþô:
1PÙ;-S$ù”[oaßµ`°
2ªåˆê6øþÝ Õa+­ÎÄT> g—
<èÝ=Ú æ‹ÓâP<[·è¢v©ÃGùÂœås u'g/¢«·V ?q<‰aR%o„óÝ1“P†2=Lëu`w·`°
ò©åˆª6«’v°•#‡½¹
¬Úxº©tïhŽœÕf‹NM¹¿É¢‡ÛâÙÙêÆî^×K
Ü}¹¢•E¯öz+ÇªÚPy`¼(P¡Ì]-Nˆ'ýìõxÀMLŒŽw9rœú×Ñã]Ðñã]ˆ'mÎ7ˆÜÁ§é@é8Üø8Ü€³¶wÉ!;·A'ÿ8g½°ì¤Ù“Fz‡õçW&“HvfO¬ÿçÀp®ñ“¯œë‡y%oödCd1ýÇ8ŸYfXž|]]2ÃX·_$Âû'_mM‘ya—„êÌ†ŠoÎä:öÆTOñ)ªáG/è³ÊOŠ€›…"àïrDÅh¼4ç Bdå”æ…¨ie:+T
—«»e½¸|Ô®M»·XªÌnÎ'Fgð¨d–Š4ŸDWXÿ
38 UI¬Ê‡%€;Ô7
N ”»Ê¢±¿‡'pÐÁ'LŸõÊE¡S—fµûôü|M—z¦^J_¯*z·Ng—wR}fvfÑm#ñ^Ð·‡/'
ôžÒ±¸0Ð¥®rDEhÎÙJ~ w– Ï‹Ã‹Ñ¬`Œ´áÃí4‘–_.®†XŸhjâv*OU£27.Î´Q{Eø%Ð	Oæ#bïþÀ;Ô]-ì"fQ	‡Ý×ÀtV¦5yxh\g/ÔjíîªÑ­×Ïm­ñlÖï    Õ«gUy<ÏeEkÑ
}PÛÇøªkÌ¸*DöõUÁ^
†9Íæ4p6Ï³®t-gŽ>˜Â××N÷/~äü-ž¼5æèè}ÿ ‘ïDíì7ƒÔ$?aCáø`>²7<×ÆóÌœ˜S—³
×o/q''Íœ±öúhÏ¤Þ–Qü«HeŒÁàM0©)€øI$(™½	ÚÿÎgé¨Óx
ÿ“°næ›ÃVáÝÌ `)?Fâ›I+TU(zO°4À_ýOh~+ä¥C>2 ßkSÝ2c/ƒ!)^04}45FæÐd·ÿ$,Ä@ÔŒéÔõýW*f€œYK6}#…Q*¨©’£ª©jíp
¨•¶Ê/ƒ|Õë¹”*ƒŠUj•gRU(ŽZãA³aö¾ÆÝ¨
ªƒùdz“¹uœøæ­0‰0‘ýkªÀ^
»°¨ö`=Ùý¾î)ß?üßÖO|IÞPk8Ö'½ô}G¶âI¬B•oÑ'KØÐAªÙØ*ÎÚôN½W¿ÄŒµˆ @¾÷XRA²³ñ˜,:¿¬ 0íœQ.ÀÏsñkàcŽ >™ T*Ä^[Šà;H-wÃw£,Û™fCïÒ÷â^à§!vf
º‚ª2Ñd¢8+FŒ„c®]þ5ó¼#FFu”‚óãm—BÊ¬Ã¢µ–¨r8›RÉ/‡sÅ¾â¯ð¢7œ’Y¦8šNLÅj [ŸÔˆ~×„ÕYº›îcû6;}ºÏ3²Šâ_Hã„¼0…1£À˜ï7ä;ÿ¹[0àýëý×ioÔùc4…oûÂX%EPf~’ì_é¿N÷c‡•Oé°ÿºžï¬ñ¬Ã‚ û;6Ü@{)DÖaÕ¿ÃïØjîYU‡É¿ÃïØdî
Y‡EQÝ¨ò› |¸63Ï|\jb¥XS¹ÑÏ3çuš{R*ÃGeÐ“Ê³gë"—¹BÝê*?-†=YüCÉ	?…Œq]IQ}6_ÃîjÁ`Du•¨òmšP«ûÍŠýEà¬X¬?ÍÚw¹«ËëÎKÕhß'cp×]Úå—óã»ú``.GJÓŒnÃÎ_	ì2Pf®£¢€ÃM·°ïZœÏ®,®Uqþ²ÅhU<8	z/û¬Šƒ0IŠn/¸$!ÀãpÃIŠ`·B%ªl²ŽT:Ü­oP
—Š2åæ]þ¡UÜ¼Hi¤Uå^ƒÞõ†—êÍóÃ“v¦%š³ËªMç7_ŸÄÇŒ
rvø•)–$Qq·`°
ªÔ”¨²É:PóIá/åú«Àþº½ªP©ad³¨Õ.´òËýÚOz¢\R3µ.º-s:ê…>þúM›DéM›Drò"ñ}‰ŸE+ˆð¹[0à{ë+Qå^t|«¥ú‘Àêj©èOO©Ó›—Êàjv^¨%‡[…^ôÆ7wç“¢úr]Ò/¬ßÁwÁ„g#f”·æ\£þÚ€.ˆf+Qå^ôA¹~°-½C÷¢½Ñ‹¹Féa~^Ì›°9ÈæçVQ ôþç²ý{‰Úg	Ek¿ÀYØ?r/Z¾·2å~8ÀÌ~Ò/Ü-ð‚=ÂâàÚéÊñýÍÉÔv­ ºö»Ú6ÿÄÂ “¾AR&Jê¶G‡ÁX½»Y•önæSëXÁ„xw-}w§®eïoö{ ùþÃ¼C;P'—˜o¦Š|3/ßìˆ+ìuÝÞ™‹%Ü$^p{}]Üø8ÜaòqU¿Ž*Yí	•ê‡þ¥Ç'˜á¯–û cÜ˜­§Ñõóüò¥p~ÛÚUyª¯*ùëôT.
rS@ÌóAØ´ÌÊš)~B eˆb¢úî ÷Z0 "§ñRñ#…Wñ0äCÜr¼à>bQèq¸CkŠ÷Þfvg¼1)¼ËüSØõCÌÏÞ@jŠ€$FD’|kùvþÀæAënÛÖ`Mp¾îè¶Á¾;KénÍq }ñ©çqLuHu”x©Î‘7U>®:!æ~ ŠRŸw'«m’¨97ývÛtFóM·Í©>HÔ˜Œf¯ëÙ¯ÙgA­¼é¨üIQäù±ùçhM‰—FŠÙe<ñ]÷1…læq?‹,:9 yw1­è6{äÔ¶NÆãM;ÃvÚ‰0´ÚŽÊó°¨`†|û¤Í)
³ëYfQFòæ³n’{Äð:×…°î_ÝÁ)Èz7Œ%) ²
>ÆÝ³N˜K&‚‘Â8±FZê\€Ñ}Õ#¿it0"š¤2Bä3`Ü=‹Á(Ì³’ýaLœ#ÃTJÖŒ·rm¨à‹©§ ÙÍs¢˜¨I*©âO x÷,°0Kñ œÕmÛ°ÅzÚ™s†9]&²ŽË"‚WÜp—ü¶~TTà¢’’’‚…®ëY\Aå¿QYÏ*½ô]4XUƒ
rÔÀð
k3SÎä‹g´¤À:ËFÅ³›œ|ÕU«êø)Ó¼Šfk»_!¨QæÔòT oäîµ`˜‹ÊVw?/¦‡]½›Ð;z×š±fÏFæt×L¤Õþv{„xž‘j#Ì—Jd$#ðáÞ˜ûYf"€{7´Û¼Ì‰cîÂÚ$‚½ÿF»‘ˆÖ‰@„9ÌÆÔ Ùõ,²è€4¼ ›ßÍq7¨±«ÂÙnÿâJ~Ãè $4‰‰"“ŸÝÜÏb ŠHöîKU0|
²„
†€|‘
>ùÇïŽ¦ MÊ’1úpà\Ï:!‹‚ Û­+b<8wRþŠ"’M°hßø½oŠîû¦„ó,Ú7e—¸ƒµ…Ø7%T[” c–ç]÷òÀ"!/D$Ñ²XD¥ˆ«üªì³,VÎ5Hà²X7m±©1‘/ÚZI«/º÷}KVù&:›¶ê‰âe
ÚÕÁ’Þ6Â–"~ëÀˆok…T¨"Á²˜»Ã\P £DT ³Ê-w˜¥TÎu^³”Qñrr[èŸ]á¦Q\‘\sZKÖ¥Um<_®GE<ÎŒ/Îµ˜`Vž“„$Á$–	¾é2p¯ƒ]PëðŽs#Ñ±ÃEaŠ@gwY&rÿ@‚8!ÿ·¬ß‚’‡wéD¿ô§ ’”d	É¾ÁäÀ~»~{¡åzÇæM(pó¦¨û
üûýŽ‚:XPu¿¡¿ßQÞ…Ë»¢î·#zG•
¬òŠºßþ§þ¢w{¡c ºFÚoÿ2@ôŽš/|ìüÜHûí_
ˆÞQú…Wi¿ý‹Ñ;*Àð±Ó¡#í·(¯7¢B°Ua¡Õ
ÁÊumXöÐ¬?_Y½j¾~mÌêÅf#œyZ<&¦‹fYnÂy¯›{É–F¿…›Bˆ³é‰à»½ÜkÁ`ì¨FT¶*¬4Ÿtêr½±L§Ö'õ&š¬Z·Y\G:í)Ã	™öóE©1^`Ú5sú½\¸}Õ#+û•òh¼Â“¥¡
ì[µ÷Zœ@äMÈ´ÝDŒ½DæÔ‰þ7ÒÍtµQ¸ú±¹0ÔM'˜Ïåò×Z¹T/7ÓªúïçZºp•Ì–µm;>îÉ®áéUá¦P:¯—KÛëã kä #©²Š(fm{Éc$øWz·k3âÇÛŸ]•¯OsùÓLºV/¼Þ¯cÍFS{F’m¤såëGÌ ßÝ/xµ•!ÙÞ§Ï×6Ý!ÖŸõñlÎÓ7#>½I_Ÿ§kb›³ùiÛ´§ŽŸ·íÍ.#´Œ4wô­˜%•IRˆŠ_%à¤¶80Í&¢¼'&óÝ# DF‘ ØU¨@jU ¥Ã}#%-——·0\À´”MOŒ±
¬§éKú:s1ZJCýù>
Úú$›I_N5íù9Âb×÷¿lïsÆl¤„F¶ü^6´×‚/ZJÆÞ¨ô¬kNkÕ+Ÿˆ»s‰
BÿGÇõQwòüšº´
¾ ¶Ú¥öožI0òýž°’d*¦’÷ã36ë¦¶twÔ”§¾ »ŸÉ íXˆ½PÎÐó¶mùVô
žÁ[L–þ : 7ÛÙyRT0ó³$R‘,)ï€Ùé
^[Ù° »žÈ@Þ?ôíS†ÑeÃZ£©µÔÙ”Ñçß'™šþ¦økS†¸ŒÈy8À|« 	B€o”5ôÜãºýÕ¹Ç9)äÛø;8ž×­$Øë/(¯V#ªó]iÄ'eGÒêùà”’ro(åAÑ.êŠU/èZo «æ¥]z1óòU€ÁX Åù°á>~¿â=@â<‰ŒßSRÐ^
¼ ÀZ¨ÎwU}a û Ï(kð²1U®m½#O¦Õ»A©pÕÖ/Ïg¥óY¥b©ù^­³ÝLoîŸ#£¦¿<åéP«øX£½xAµQ­ïªº(çNbÀk8ðT ®nµVäá^½À»çâÍ­ÒØîæ:Ï³rV¶¯­ÛK-]U£ÜÜþ—€çç¥$Jeÿ}JÐ^
¼ £FT¾¶ª®|Š¬ðà"ë§ÚjlLç5ÜTŠ“‹árúR*™&~¾ª/®3uXÕË‰q'S±¥èŠ¬	x~Êãü ¨ªÀÔ¸[0àEá˜¨Ò2«À'
Æ€ïGÁšK³Ò#ó
SÓ§{u"IæJ[^ÎçMÛ0ÖM£%Ù3Û0~à(QdÆ¼À»Zœ@,8ÒAjeº
µ•ŸÆ÷W_–/é¹j¹‹îì|™¿¨Hƒz!T8»‡ö^].úùQúavá^¿¼Ìõ(D¢jînqB°h³=zŽ$¼D³GÁ¢²{³²û#	/Ñ”ÝC,H³W£J¾hø%_HÚã‘ä‹«—+õéþê¦p§Xy}Šž;çj}6¨®¤|^é£n¬]¿IÄ ~€žÊ|q"˜HÝ-ð‚¬5ªå¤ÑµCàWù¥ä:æÃy®§™*æê
éæl4L_ž\ï€¢5~¹Ì¸g”ß„,%…QRáÇèù¦¡½'„ˆ6š€ßM¸
L4M@,
 )ª¼æKéñ`Ó5¦è¸éÚÍUïNoeúÔ›ÎJóÇ—ûb¿–ÏÑDeœ0fÖâ¬Hï‡pVÿ-ö7F)~|Š’lî_/3Ì÷ÏUyíñ¾bÏõÁl]°PÈ^•O
âhI °·;¿²Ó@u¾Ù»ÃÕ$Ì·,÷_å´Bé=:¿Žk±±âÁI…âÊ&;sþçÿ Œ^aÏà@ì#I,QB”ÀÑ{âu;Üd„$È,¡h?³ýHŽ¸ZíGBDû‘ÀïýHÜpG³	!¢=<`Ìöð8wˆ=<BÁ-ªz‚1«z:bLBT=…2&¢ª'³ª§#pGtZ4U=í
ObwðFÍ8DÕS(c"ªzBßUOn¸£©z"DâD1
q;Dˆ3LÅ*…8ÑwˆÓ
wˆg˜©’Š>(fŸàa"àÆvS«D1c•Á~7Á*ÃØn*b•(f¬òˆg«¤"V‰¾Y¥î¬2”í±J3Vyî¬2”v‹X%Ž«<    bL¢a•È4Æ
ÜüþüÓßm>¨},	Ú|½ÅR¸g¯KIæÇhÊªŠ)`ª+bèø›¡»áŽˆ¡SCÇ1cèGàÁÐÃPF*bè8fýÜ%!QCÇ1cèGàŽèìYÄÐqÌz°—GB0ô0Nµ,bè8fýˆv‡`èaŒ‰,bè8f=8þDB0ôPÆDÄÐqÌúíÁÐÃx&²ˆ¡ã˜1ôà`6‰hÝW1t3†~îˆv»”E¬’|³JÜ4«e»E¬’ÄŒUO•4¢ã§e«$1c•GàŽˆUÊ"VIbÆ*ƒiˆU*"VI¾Y¥îˆý=Ž ¾3DìöüÃ6K¾ÆFÞé°ÇŸÎF›Óøå¿,ø < Ñæ §³ÉL·Më´k´ÓÉ
Ýf`è§k ŸZc œ®q:g-Ù]Œ‰_Â¿”(E¤$  ÊˆÁ¿ï>O¶†‰;žüÓß`>¨C€»L‰f§úxÀ´ëÔàÇýN¾©ON»f÷ç?;Söõd÷{“)ùäu“ôÍ×SËLÍ±sÆ2¿oÎìêÎ·¿Û¼dÓå8à` ‰ïÔ¤LTÊWñ8“¯"Rã)¢ iùD·mk0àgíY\Z?ÿéúrÄ¾5Gsn®úëC¦Ù;Ò¶Söž¼JóÔöù‘Rú ),öò„”—dSL$~À–Ç[ÝÉÓIÁý–çŸ O…½¢I€±L™88Á·8ÿDqªqÂ‰óÿû¿ÙŸÿZ§Ìt¶|²þ—Î¥Ã?wõ.“å€y!öÜd>Çÿû‘ÂQø~|&¡*©ü„]E´Ab¶qÄ9¨öL­A˜­A‰cE“%=ÔóÕö oÛóå¶ zlÏ«tpŒ¤ó Oô ò„y’8É“‰dvÊ¤Å# ËàõíL˜ö_ì@—Iå”»SãUîNb'V{#Rv—±½•(³…zÿç¿úìß²º=5mþ„59]Iöö™	ÙøùôÑjý”5ûþ\-@- qÒ‚Wéî{ºÜCØ=›_Ü—>f_vÍ•þh°¶{ÖØ¶K­ÏŸ,O,§OyN¸ ¬¥ce™ÙíYöpcŠõÙ”ýÏê§C[ßÓŽÉ~ñó¿ø¤Ëß~þÎ÷L'¤¨wŸg¦Í^á%×€±e»¢®W˜›õ,ý¹"Ä0QLc˜‘‘{f`£;ã{øÎ³¬sy­¹asiÏ&ü¥=þüßc?xËyTymÂ­‰Ù0{ÐÓ;SËfÿ`r4ì»ÄÍ¸9êðí‚ùóÙ]76ÃcîÙ§OÕAÅ4ˆÊt„	ÖêÌÆL,›‹Ì²Ù?ØK­ïÏå£™1greÁê˜Cn"¬É_§–ÍÿÅ<&úÉØè˜ú`¸ ³Éßž0ëà˜}Ðÿùß£S&FGþ]“qª1SÄO7‚˜+ŽiÌÕñÈ:æØ™:Öpæ–n¼ñŽ‰`×7œ±àõ{½×þû44Ùí†Æ££:{Š³yVòsßsA4Ç4û*h‹¶ÝGÆÌ˜ä»æ|6ØNîéŸÙl6ML—6`
ùÜwX™ÅqŠÌºDË;Ã<°S}Ø67®;›ƒù‚ãÜúËyim.“¹Å½66aóï×o-›ò™Qw$;´¸×båó WÃñÜ™Àg]g!™)áyk6${óî›ŽQ0>UTA€Ç)@æRcÎý,.¦ L¬½¹¸§êõ
<9mëî¥M~¤Œ5Xsó‰#è½æLm¬çÖƒõ$ÀŸ7ê2?±ãDçÖ“„ã`N¶3þäsuAŽÃ±
Ç9þÁœËÝ»WÝðÄo:3î¹­Ý³!cøLG,öÓ£+Sãç¿ì-
àN¿+`Œz»=Ö'K_¼Ã±
Þ¹ƒrÃ™‚áú0›š¯±òŸÿäó“áDo³××eº×/6kÏ4…ëÃÔäö^_“üžÁ%øÉ!YUŒÃ1
Æmpî¨ÛÐ˜ê«ÏøùzÎÖ_´®{â¼æÎÕz6ß³Ú§L6ÇùðŸNf“Ó‘ÁžàË>WÑ;Óè>±¸w›^WœÕf÷FÓ—)þµvý
î¬}z6ÌW#ÁÃ´NøŽÙÿ]˜ñÈßÄŽÙ-ùoò}ók‡õo•í“
¿ Ø‡cìëšŽÌÙÏçõµ²ìVÖl›™:ëp™™ƒÃàýWKTšÃ1
Ím%j3‰ÚÜêë<æn:±¶uÈÖš:’vb¶{ÑûZ‘
Âm$¦á6&Ò©m¶gKG2Î”Ã®¸œ˜aŽ×/¦c'ìuv§kzÆÄmv­¯cÝ‚˜‰iLí5ÁáÔ1ÁÎ†NPÜ™õóµkö?ìŸÿÝ^3¨åé€iÀz†e/ï£õçÓ¶qjMmkò?7Ûù­íP0'ŠóêŽ}é»,»‘˜†ÝrÅ<¬×U2#P
Ù2[nõù"Û–”¯C/Ì°÷íÍÚØÊI‚¸‰S\-7³×
œú©ÕæfþüçÌaaA1• ½cl—OùûëòÒÿriÊrïÅ^¿õƒW{²Ó×¤þÉŠ ª‘8Õ®öè. rÒ8±æÿ´l·
p_ÛrB¢lRg2˜8]á±Ý/-ç‡LÉ#snØ“Ï^
E’ tFb:ãÆúçë§n{l²·½¦3}à]
áaSžGcŽvô™‰¾Ïø³íNvpK>ñªA|-f»Xê±.Õú\uÄÜHLcnÌÃC'D.2{¡–¿6i6®,>
è|I}Ô1ÆN¦ÄÔ°x
37þNvãÑé§<?|¤Ogö—­§!In#1
·™£Î€“´uš*Oc›ÖÚUË9¬ÜÚZmÇ0ì‘ïu²SwÓléÕuÎéœª]cO™>WÞ‚à‰SðìJ5µÎº
wô\³®kbïYk0òúè Î³ÿL†úv-•½÷›ÿš[a}®À±5ÓØš“½:bÿè#c³žÂgãµ/®OØDîLÍÜQ“Ù¾ì—ŽÕ™£þl´NnðŸ±€}ÏmÃÔþùÏO~½a7Ó°ÛVÚ¢yœ½Ñ¦çp:Ý‘ûÀ›7x-÷å` ·g\àüýfŠsª3ßoýj®xq8Ó8œ7ã¼„ÏiàIlk£nÝÉVïêß}?º¶[öžüåëÛû®­š£¹5˜10¶yòSc¨o<8³ûÉZ!ˆÏÑ˜ÆçÖÞ¸ÿ¤¾‹Ûò¸ºÙY»fn'.M§Üi®1ê
Œ¿×_[·žyú¬ùúþÛ*™¶ùé…Âv4Na»·Š~6ò}ê´Às*¬¿Üã¸Ùöç’2 ˆÁÑ8Åàö.PßêÄí´í
Ãng'½¡»NfìÍ6‹6Ìj»ªŸ–§íŸÿ=á®š¾ál[·¹ÍŸ›Ï†€ (Gc”‰ûµ•Í±–=uæá]Á_#e/©uÊ÷Åb^÷¿FN¼u/›Ù•Ï™Üœ¯ž/¹ÔÍ¶iŸrù:~þ«·À€S§ÌÈ&‚ÏÕALŽÆ)&—åooˆ—Þyum^yäó;ùÊÍÈI{µu§*ÍÉ”Óm}‹Þ]Îæ‡¥OÛ
–O½ $Gc’{£Ýg×¿®rÐ×•hœ­m2ekó¿º3-<°y}Mó6ËòCg_Agrø\
br4N19QûÌqRg4ní‰;±™/ŸÁ÷Cmì›ß²›òÛ,¯y¢žÝµNº8~Å#`þWxcóã Óp§&pï{ZvÃbJä$IB $†©ì)aºÜÖ=…ÄÆ_Å_$À÷/¼âgsœUœ± çôÑ×]8Â¡‹ã.ôîØlo9þ:u>tÌé’?é|¦/õç™9ø±¹0ÔÙ¿Ù[ïéÆ 94™{ØÕõŸõ“lImC.Ÿ‰ó"¤ÏÒù«í×ã käÈMR•J
†d{É#-þ•ÞíÚÆÄ¹Mí¥mÃŽ5cn©Ó¿|Çqr~¥©r0¥£“üA3þœ¾1²÷¶-g}œÙ»i…ët)—ŽTö ýÚuÍn1"6}hu×¸
e[»Âgùµû ©HTQ¨ú*ZÛœêG³‰X—T¦H)‰&)!W%ïþ‚U¢Ñ«’fögÆào¨J7ú@·•õÇê ëÿÞ¡K4EP’ÊP–e¦LÞÝ7Ê$G¯LùÁdù7T¥k«kó×duzmÌÁŸªR JËŠŒÞ£Rj
À¤Š(Æ*S©ýÀÓãG¼îÝqZz”Áùn`užœ±÷ôÁäc›«on(žgJ‹Ö¹2Ö'“Ëî®……ðë§²Ýñ@gÑy–¨C¾’Ä0…sZ’&I,$òJòLg,ØJÎ7fu?QÊe¾ž,“ßT”D Jì¥ÁÌtÒÞµØ	rßF!H­ ©@äûüðwò—E)3Z˜Ä˜y=Ü÷Úm…±ÅÝì¶lk°±ìðþ'×õ?JH‡RðE‹ÐI˜·‹ZÊ{Ð" h
óüMÐRÃ¡E÷ÐÂ h
Ûü=ÐBžèÌLwùûìÃßnyÃá¤e,ŒÎlºgíùçþ®k¢ûó¶Î3øâWËzí^¹ý+›[¹®m7¡ï°©imcM«+¤ ¤N’TÈþâ‚ßâú|qùà•ô—ú–×Ûåä£y½¿¸ð·¸>_\a^¯}šnŒ;¯³ÿð·“Ôþé&ÎQ€üë7j>LIr
KIYU1Jâ%Œ”jDPR(Q| tN]‰JÙJ#(IDP*þP’A)G¥ê%”0(±ä¥#(QDP(•AI#‚úC©ÆÊˆüJŒ.º#,#r,±ˆîÄˆïà¨&ß1"<8ª™G@x@ŒŽˆñ`ã1¢<8ªi\@y@Œ8Žˆ>bç1"=8"ŸˆHˆë!RDX
Xˆí! ,©Ç^mäÌ•ò×(1û<4F³W¦$JH•0)Oî!I*«ŠHoŸ13Ý®2é
ØŒ» Yx"`0Fì‚D!$¢Õ”±
Õl)`0Fì‚F5[
ØŒ» ÑÌ–ˆØŒ» Ecˆ€]À±
Q
ØŒ» E¶¨€]À±
‘I‹*0F«*4¢Èð#Þƒ#ZU¡ÞƒâÄ{"šÇ©€÷ ñ‡¤¢4²ñï¡ÞƒbÄ{pD¼‡
xŠï‰*g‡
xŠï‰*iGð#ÞUÖŽ,à=(F¼'ª¬YÀ{PŒxOTY;²€÷à8ñžˆæYÀ{pŒxOTY;²€÷àñž¨²vdïÁqâ=ÅÜdQýLœxOT>‘€÷àñž¨²vdïÁ1â=eí EÀ{pŒx‰È'R¼ Çˆ÷D•O¤xŽï‰*ŸHð#ÞU>‘"à=$F¼'ª|"EÀ{HŒxOTùDŠ€÷ñž¨ò‰ï!1    â=Qå)¢bÄ{¢Ê'R¼‡Äˆ÷D•O¤
x‰ï‰*ŸHð#ÞU>‘*à=$N¼'¢y\ð#ÞU>‘*à=4F¼'T>‘ßÆs `
ˆñ	•P
Ló¡1b>Ñi¦€úÐQŸè4SÀ}hŒ¸O¨\·P`Š¶M‹ù	•ìL,	Øû	•í
Lý¡1¢?¡ÒÝB)à?4Fü'T¾[(0HŽ
•ð
L’ãÄ€ÂD…C)`@rœPd³¹€Éqb@aâÂ¡À0 9N(2×HÀ€ä1 PYo¡À0 9F(TÚ[0hëè1 Pyo¡À0 9F(Tâ[(0HŽ
•ù
LRbÄ€B¥¾…SÀ€”1 P¹o¡À0 %F(Tò[(0H‰
•ý
LRbÄ€B¥¿…SÀ€”1 Pùo¡À0 %F(T\0¡€)1b@¡2àB):>'F(T
\(0H‰Šj6‡¤Æˆ…J‚
¦€©1b@Qåa(`@jŒPT¹FÄSã76¶?vØ?ÿø·C“JM^ØõIGD7W¶€úX÷eçöúÄìÑt“Ëà
7TSPNB"Q	3¸±n5^pÃ`¸•ãpã0pÜN8&Fpƒ`¸Õãpû'{{à¦"¸A¼àFpËÒq¸ým· nY7ŒÜÁÆDö*ÿ{m·"‚Å
î#Úí•Æ{m·*‚Ç
î`Û-{¥ñNcâ)ltÁMâw°#({/¿n ‚›Æ
î#¶›‡;Œíö”Gºà–ã÷ÛMÃÆv«"VIcÆ*Øî¬2”1±J3VyÄv‡`•ahŽ*b•rÌXåc‚U†Òn«”cÆ*ƒµ[	Á*CM•"V)³J7Ü!Xe¨©RÄ*å˜±Ê#p‡`•¡l·ˆUÊ1c•Á¶[‰†UR¸o»wG÷rÇ‡éCŽõk£c±;wõë‚1ù±¹JüÉuÀKR$6
c™ßÀœ´øÁ¬uOLŒ ð vIÇ6Ç~-ïw0ƒÜý¨*‰¨³3ê|D§BPç•DÔYŽu&Jêb‚¢’ˆ:Ë1£ÎG&¨Ô9ŒÅ”DÔYŽu>bLBPçþ •DÔYþ¦În¸CPçP¶[D•˜Qç#¶;êL%uVbFƒ‰‚:‡2&"ê¬|Sg7Ü!¨s(¸½ÔÙv¿[ößlvg“4Ùa¹ëÔÖ{=³Ó˜ý‡éÄ-»Å:9hÍõÁÌØ	‚|’”¤M‹ÑlØæ7±¦¬¥«
Ø6Ðç†­÷
Ÿ»$É¶ÍP_lîpÐŠH¯Ïz³Ð	I!)©²YR˜Ð½ÞÞl„„…NÂ:
!tNèþn¡)ˆ“"•½èÀK°m·U‡ÌQ€ÌQ Ìi™“ã2G!d.“_yÑ÷dîeù¶ÛO‡ÌÿVÆ=Ì{î
5ldNb$ó¿•móž{ã™ÓÉüoeÛÃ¼çÞ ‹ýº*™ Ùö`™Ž
:Jbz\è G÷¦{c?©+1’zu`FÿØÚžÈ½ñ§ÈÕ‰üƒ¸ßÎ‡ÛMÖ‰w•œZO†³ºj,/Úç³l^«(™…IatM:Ù-<ïn²—j’57ïªfù1´Ç†¤åÒ+íQ›†7˜7Ôêe©^})­KmùbvïJƒÎ<´oüÆ÷ç`Ü6ÙjçC,--“~*Üa£ÿp&= i5z©˜ÕÖÊ5¡2¹x¦gmëÇ¦§;!òo¬Ét·h=°:ú€³moÙfßdbó«€ÈI Iì/MŒ¶mczoO[k42:Ûµf÷b6M˜’PR‘…ÊÁ4:…`¯ƒ]Á#‚=¿*­ª °—s
TÊÀ^)×²UUuKÏçsT¨T3‹5@)7Ö 9µ‰y ¥Ï/Ï›‘ÀäLBI Þºœ’ÔÂIE
òîµ8¡ž­\ £¨@'¥Ç§CÐëyX®€nÜâëëûüæž,	ÜŒÒgWÍRí2;žÜ´Ti–kW‹·ÍÖÅsmYýrÐyæ†šT•eèº»ˆ@Ç^x)Õ
L¹^ ‡¦À¾o f”p©þ$FRò®U0šÒài
Í»ó4–Æ£ÇæÝ?P’=È¯ú•yM¹/ÐÇÎÐÏÅJ)‚’¨„€5öÔƒ½»ÃŠ°'aß€ÚcÚ‹ýB{ì/µ +3º(ô•Âª­C–J(ß©Õg/½¬u>Ÿ•ñu&ÓJ—‹ŠRáIPÀP%IYÜ¾+W(%1’0Rý´íµ`È#ò4"ä›/ZîÀÔ,´Óð Ss•3/‰‹ÌP/—Íê½r3>Ë ÒEõ!={²
Ën9SžJ‹+ŒÎ
aM>žZcÌUÈÄ¢0Ì“ðÍˆÓV“fx"â®q,B\Žñ>Cøqö"~ù\™)•Q^-_NêN6›ž™Ö%¹/ÈÓÇÕ,=¯HýId{™Fdº.ËpfdTÂþOß„¼š’03áITìcá|:w
†<!¯D„ü“äcá¥Ç¦…w!Ÿ©#Ki]ä•²HÔ¬¡üØŸÃ«›ó‡ô•¡•¯sÅ¢¿Ì
Wú¥ö{ ®(©LDÈ»[0äç=—¿Ê×ó¿®¹Mµ|[¾¦?­s·f|H‘dÉAá­ÙBÒ'JûüC³UýRU·¸ ù`ŠmèmËþÂB­3‚qJ"I‚$ R?Ê
 D±Ì8
y 9Þ®ôø“c'Çð(;fª‚+8;^gSâW¨§Œ¸ Q0ùMY
‘	 ( , ,‡ˆN ã ð¸ ŒP ‚˜”ü¦‚ÈðþØ¿‚B¼ô¸ €z\ Œ\E&•
’ Õ·ã®EÀ(
@%)¢‘ýD ©ìÁTQ¨úÞ„%¢ødŽ ÷F¾ß7>rA>žú¶ºØÏyèÕcdÆ©o«Pý¼ƒ	¯áF.¨ïRßV,ú‰#{zlä‚R+õmu›Ÿ7rz_ž##—AêÛJ(?qä!22Ã\P›£¾­šñGz?c#”É¨o+,üÄ‘‡.X96rAÅŠú¶ò·OyT¶]¨o«DûÄ‘GeÛe‘
÷¶¢°Otá"³í"îmõYŸ8òhl;”°`µ
Kja9¢=æ_J¹†',÷´,ç
R)pµ
=ßVVWZýBkÝâÄãsfÑÑžg/w×íqã6'M£=æ¯šÃ§ÈÂr
»¬ªIŒ“ô
‹.*_tAR
“$UU…Òƒ œ¼»Å	&h_å<úev7!#´þÀ‡öcb±ù´¹N”Àº¤¤Ja””%H%EœAáé2€Œæïýô„Â}§wHS>&†¥$•%„ÕÈiÝîë]«k†Vw6`ÿ°=]Õ…ïúÂC
Ö#«ï`=kM™ÊÁ58kxGkˆùALñ·};¡H¸0‰©JõÆ²”;X'„ÚcU
\'”ô:–Ÿ`
Þtt4!ÛÉ´–€ÛÁµR¼¹PºO—…LzXŸ%Â®V}Ü:!æ¯¤Äi“   což»C^´:îd{G|G*é*,åš8ÐH7½úÍóUï>¡]iÓFG£p _.[wWFGRª¥ìp~>'zfIÑ#Ï×Nä7"Ï4šaH»?òîyÑÚ8ˆ&ñ©Tï³¿ùCäëM !ß¼:'W‹ráŽ¶žF½Ù°¾h¤o†S2œäÒ
õÊ(>_W/:gg—‘éü;sî*Ï²# )!‚öÃïµ`¸‹VÆA4™OÌY•û‡¸?6`9ÈÖ,Õj¥ÚWàÅusXmWch”ûeó¶95[u5ýø(+µÆ…°ÿ!‰ è€¦$%‰ˆ‚ˆßB!ÝÝ‚.Z Ñd>•ÓP«¤›ÁÒª¿L7k•s7òbÔHÏ³ãÙà®Y¬÷–ãú ØH×§˜0¤æ¤?leK“/M7s@G4EpAf›}-ÞkÁ@­‹ƒh2ŸJ¨­-L¹Þ_Zžù¤½hõ&.çš„g>õ3­¡}‘¿ºZôÓc‰Ö›¹«³þåíUï¢K‡g·éªžYÌ/[ÒÌb?{ ¥ØØ¯enòoàöd¯ÃžŠ°&ó‰c_®Î«{r8¯{AJ¹.­4À±—¯m]®¬2-¥›o™…ónû¡¾,Vër+ß/[‰ômcP¾×šóæØ'ë2ö Å¦dL7Øc/ö®{QJ1ˆ&÷‰aÉôÁþ	kf€±y’»ç	êtçÄ@ƒëiïÆ¼0ï–åÕ]¹Z|Y©S¹ß|X•´Â¦±á 3O&1sU¤Ã„³5è®tQB1ˆ&ý©ô¨-|ò¸‘–Ó|ò¸Íj4²Jýž25zq¹¨ÈíâœQÿIñ¹bç3³kÓV>÷øpç“âêklŽû“*÷³“Ñþ·‚¯8ìÉ
ÄkãjÁÀWEàG“ÅÀg\©ã~Y
~£K¸Ò$ dVÙçBúNe[¹
3÷¨#Ø^<©ÀÜCC.Ý¿|=øPf)IU¬`à¾»Å	Å¹ ˆˆ¼>j„ýÿüz~écêÀŸço5ÐÊÜ¾H´U¸»žÕêƒ²º4«•g«={Ò_»êõåt0l€þ×ƒ _ú—d$©Íw·`à‹ø+Œˆ¿2ð}ê8øÁu÷ô¶vŸîƒÎ´¤*-Ï:³væf¸êå2¹z=]¹é»»…1¾‰,Èø+æž¡Ê<GEÂúÆ
È^
«¬S+Ò;Ö©?%VúŒ ÀX¹`Z‘Þ±Ný)#‘•jä¢3éëÔŸ2òÐûÓ¹`Z‘Þ±Ný)#±Nnä‚ujEzÇ:u4#?²Ó_èódŽ\°N­HïX§þŒ‘‡Ù¯>ÜÈëÔŠôŽuêOydN°N­HïX§þ”‘G³ÃF.X§V¤w¬SÊÈ#³í‚U7Eú²U·à‘ÓÐ;õ¹È‡_æÃÙV4¢õF¼oàfvg¼ÉÊàÝæŸÂœ9ÏÌ5VùFD’|“ºÓ»¢’õƒÜ«ìxûµß‰¬ÎP8 Ú÷Ä]ccEyaDëH|ô±éÃ€šËÒA´ë~’¹yye”zX{YfçU9q>nßvÔ—~ýV¿ïê·××4Ÿo»‘ÑÏ_!BXJA¦(2ãöÈŸ€º[0øE^Ñrƒ¿\÷…Ÿ„ÿ©•_IÊYù†JùPéãÀÊOÕl,j•fY©M§Ë«^^N·eúÙìƒ¢IÀ€•eø®|Q¤Fµ¬TÚaÍ%¿³¬¹Ìµ2³ÛZ˜Ó‹IÓ²ŸõËGd>¨ƒR³G™»‡éuÅ Ú²qÙêõ/)=H5)1-û®,‘½wQ    ¼Fµ²ÔxñY»f×
>k×>6GîÁÒ$Ñ“¯nîD9'—+sXn%jh®ÝVnÓèþ©>ÌVÊŸÂËÏ·9ÄY V  Š âènqB‰(â£Z\j,Ê‡é2ìš†ÓeáÏž—ðåì‰ÜdPíVº·Ò‰I¾V<ë?£Z,È¢m¼´¨¤»¡OÅñÀRì× a´ÝÝ‚Á/Œ9Fµ¾ÔXiõƒ~mq˜Apÿm£Š$h?4Ïû~ó:«dõ¦vûdÕus|^K_@•* {ë“ÀñÙ&ŸðµŒ¤	Ró­»_”6£ZgjHÚÊO÷›+?Ý/­ÒÐI/[uœ…ÕLÞ¾¿i´“ú}1ƒµs8–ªP=ÝÉçé}^»¥wõrëY…>ºO>|9˜^K*‘6Ø/ø®|QîŒj‰ÿõ³ûMèc÷Vµ3ÝR¯6xôJÍæm_éÙ÷mé©dÞ=4z(Æröº’xÌjEÍ÷]ÕþXð1û!…Lµý—µÝ-ø¢Ñ:Ó*Ï·48 ¿œÓà¡§érv@¹ ú…F~¡ê›ÛìÈTæòˆäiø’Õ3ç­Ù­­•‡R§à³º÷K;e½9O@¾Žá”"*nÚÄ`—÷Z0ØEü
E´Â´Ê/Ë>¾N9W%yz—ù•Ví0Í¿¾®I3{ÚÈt\š¥òef<7Ê3éòúVµîJtûzüò8åf«”ø®1É{-ò"j…"b¶«‚¯©gtËÇÔ»ïÊY¨ÜHj¿
¤ZUÁ\«ë`RêÝL¯4/+
ý¢çh’Æ~
væ¼)‰d•ôÝÕ€.¢T(">»*@¿pB¹Þ÷	'¸@ŸYõ~ÕVæ/×ù&µf÷ÍöYSih‰–š›Ö´§ÆpÐ†T;+4Boô‘ Ë<Þ¤Rê·_ÓuW
»(}EÄdWsé28°–Óða‡
öë³–VJ/ÝÎÉÍ§L~ ´‡·
›v·…a> †ƒ;¹G^Œçh²Rvæ¥S~à U
|“•½vuo›ƒÄ;ætÉŸr>Ó—úóÌüøk»÷É£w?l½§ƒäÐ´õQW×ÿ}ÖOÝYÒèlòQOxËëôY:µýzü`4$UQÙ<ƒánÃ OèÑÙ¡Ûµ‰s›Ú?JÛ†k6šÚNÿò™ÞµìA¡JT—6{’òÚyýÀ€Mt|Zó§ö‘½w(ëñÌÞ
S+\§K¹´¸h{á
ªŠº¼¯jÛ´§Žâ¸ï„¤Ý¶
Í®1š²{tô­Ry«è¸¼m“ïtÁ…3›ìÂ³ß*ˆì—èŠ§_¯$^Ä½” Rù©DTò7A4¬>
ÍþŒéÓ\è¶±²ôIsZúè“Š¡Œ€"ÿVúônt³Aâ·A²Ä¸ ”eÞÅ^gÞnƒ>HY>Í…Õ’`#äÙ“ahŒf› ŸÖœO†#²ÛÏ3{°÷ùÁ6z{_lý½ìÌžX“Óå©Îœ¶¹ÙÕ»ëÊ]§‘ewòc´ý"ÔÂ+I@\—£”y‘DH¬¾M#´øî¾Â^ãÊØ8»oºaWj—óå˜©¦ðüFì”~Ó”ÄÄ¨ÊH…l.þsÉö Œ£vÁL–IÛêÚü­_˜…<kèc¸[¢ üVF!ÔD²ÛÍÍe®·@œ^scð‡O(‡[ËŸPâ­8Á³ÉhÌgÍ*¡Uåˆk+Z«A-¯ø2ñAr>æËÄÉùÙÊm÷jóîŒáo<˜¥R©V¨\_]Tõ›è`Û¨‘Vú‡aÏvøÐÐ)âó
ÂIL™ÃåÖp5`¸£XE5øâ,_¥
7¶þÒ¨ÆawÞóV¯ïÄ+€IR‚PZo.úÜøz2ú»ÇÃÄ‹0âa
À$¢óYÿ¾íî?˜yúÀˆÇØ§ïÀÇw°ìê½Ñ}E~Sý X§/¢ÑŸo¥¾ÙôwæWLÕ»)ö¾©¦ÈD”	¼jJ¥Ãcž°Æ¾L€ ­„<•ç¬½|M;e«N¹Þ|)WO™ùÏÖÃ-.@Éš„dØ—6àì†Õ$?:
?~­îµ`°
“d"Ê ^5‰Ïf'¸”Ë ZIZÆÌº/ÞO³ZQZdù±kJ­Ð¬e¥t¾×Ðr·ç4wIÓaòûÐÀCÞÙÇ ‰úïi¥îµ`È
ód¢Iÿ-çò/Úá~…¸ÌOù
Rø~ç%ctívcÒk\œÏ_rð¡=‘oÏ ìç_Îïk4CÎ³3³ØC_ŸIøîl˜I”Œýòd ´×‚Á.*ø@Ñ$þ–ëé…Oâ/)­4ŸÄ_wzRGÏŒä³‚†ÖýÃCvÞ}îÎnP-;*j¤ôŠgwª|&2þ^fV„Ÿã©$ù*<„{-N¨,ªõ@Ñdý–ëÚª´ò*|ƒ¿(PáóÃ«óÆ|©Î ç/¸½´ºd5Cù¹Q¨ÏÛånn®Yäl5›÷¾þX9\_Oœ„ðO‰ìgä!ÚkÁ•yàhyšié`
7†üª‘/Ì3Oõ«Ç§ÄÙLšv53+.úJf±,_çï
2L˜Í‹ë»ÄÓ$ºÃ+7ûWS)‰É›pWy:5»13!„ÚÂ·Av·`¸‹V
p$i¿@ËUl‚õâ¾Ðê
SQ9x$¸DZ•öUK:kç'•:jÔÎT
Iú	4d…99™úSq1?ÿÿÙ{åFv¬]t|ê)*z¼É?a©Ñ¡÷IoãF0è½÷Œè‡¹Ã3¸£óýb Jª$ (*KÌÝ›µC-q‘>¬Ö·Œsõ”î…_d>Ÿª²#þÜ¼q ð~x&ñƒ²sµŸüøi»™Ø®“S³…¶ævìïàk%ÄÅè H¦ß­!C“Ö³—–ÃFgoåZ£ÊŽÀŽÄ-s­iÓ¶TÐâÞ‰Ý¶kM>Ã­¿²È¦ŽÁ^6=­h³‡‡mh¸:ÐÚ¨xô
vÃ8JÚïÖšS\âïd:aöz—'ø­~U–v$~YÀ¯¥Ž—ñË~¾‰^³ˆË¸©´ÚzZèÕŠ@çÑj¨ØÝvâ ß¢­gHqÛ–K!Y‘ÑoÞ,á)ðCPFí9¯¸[$8î§
`1ô|UïO+»ãi%×ŸV‘'OtãJ¹ÿ«Wí×92q—b¢¾rÕþ÷çc82ÛÀ2|¾ ª« v„ãŠL[±Q¡øü¸á´ª 5_$cÌÃõ²g–›§ÓÙL8ÖKÍ
ýÌÔ3™]šôxœ’äª<`ß1NEE9ºDzZ¡3	¿ê>ˆq€¼Âoëý{‚_ÑÝýþÎ1«Za}Ñ³‘i&\­¥B-œD“tØ_f½êÆ—bÑ¸K¶}C´÷…LƒL
ÿ»„(!£*† Vïƒ2ÉbšªxX1¼fîP‘,¦©Šá‡Ãû`æ•ŠâJ¯š¹K‹á7´±ºmæªbxàaÅð>Xs‡
 2MU<¬Þ 3w¨ "ÓTÅðÀÃŠá]Ÿ¹S™¦*† Vïƒ™;¶·«Šá‡Ãû`æ@dšªti1<§
 2MeÃA—ÚpN@d@eÃA—Úp7ôf¼mâ*ºÔ„sÌ*>Ì„ûà8wLÙU&t«	çØš«L8èVîÒª¿{æ*ºÔ„sNÛU&t©	ÇÛÛU&ti=cçžs•	‡\jÂ9¶ä*
¹Ô‚ÓºC•‡\jÁ9¶µC•	‡fÂ}P°Ý¡™Êm8¾½Û(jýt…$]’^H…€DK R¬‰Ž™.EÆNQŸÞ*n}ëªŸ?¥<ù“ìãSxéïÆØÏôú ÒëÂ¼Ì@Œ¡”©b±°#aŸ‚l‚))ÙÔÛ_
ûÌö7	:Ð´AgÆ¹°ž×q ‹çæÍ
¬²™Bg8œd—¨#«{ùý$7ÖN’Ž	RÜV	Ž»2"È‘ Ïîé ="ˆãŽo‰Òs»lžÌ=éP²]ª›¨ßHöB¦ê[úè²‘ôf?l‚ZÝ±rÓ_‚ˆöL§"ÁAJòY%8üªª¯Ø‘àO?Je¡5£ãÕ ój™ù3K¶Þ»BFßý‹PyÌ„'óV¾Óíé¾i,HvHØ±"rßàïÆÚ³¸_q·HpÜ±ê¼Ð¿|^„¶Ÿ¹Î|¶ä§Áåaž‡Å]‡&¯O
Ã€ŸöLåHà®xjˆi‹TçOM!¤]
m‡÷`]õÖèØê —š¿žðGÑTo„z¡~@kï›Õn#0+€œs!Ó_yjˆÒXÇÀÞjüõ©±HpÜU)1Ä‘°]Ž{O3ƒ’CºPÕn‰éëõ®’Ô‚ëÄŠLVNfÓ<ˆ×£%¼Î¥q9@Õœs½	¾?á¶7ò ±·Ô˜ËÃÂ*Áá×U›ûº‘;ëüüŸŸ¾ÍzÖÙ6Æ›“±û4u?½{a*Ý¾uö‰ahT¬#S­£ñõu<U{®œƒ+‡4/Ò4¨‹[Š*W‡8?ßã·IDbßRn°–
a²<†ëÓž¯ßEñ1_Äž}ÕŸÛ¶êöMù›ÕY!y`ƒ–+6@zªI®ó[¼½;Èëh‘øA
Õ%‘8ˆÞ}p$ð2ø/TT‡N¹ÐÑa\£³jZ3·ÑiEõI½²Ñ
áFgÓNÏ
}íúìðßÙ â+ð‹Ä/Ñtj[‹ŠWø-~UÖq*½‡Ó²;úÐG®ÞÑõvfÒì¤òÑ.ìí'ýø2îOnz¾»o®A%ÒgçÒ-öÎÕœºw$\Wy5¬„df>“à¸«îèÄ©8èÑÎÞ‚^à“´ ·ÖÖ›ËýpqLü{PšWFµV>‘¦‡zbÌwBÅ8‹£C{¨ËSû
îH4ŸÀ„†ÔÜÅgwÕåœ8 =ÚK²Ô8î)I–š}·o•£áänXÞG·0]™vÓ°‡Z<éçÂ­M2ÑìðÚ=‰Ú÷nÏáý†¼bM³·#z…ß"Áá¿¸£¿µn<IüË}Ûj°òWÞ¬ž7É
žÕïS<b;Ÿ|š±Õšiî6÷aº¼½¼îì×gÆÎãˆ‹·;«Ör0[Ÿ”0Šf?- Js75&ÒbˆFuÑ ÎP]¾‰SžÚÑQê©¯{j#¹m$Pëå6þA¥Ón
ÅSa=Z
.c#sZ¨.«¡C!©tû.pYPå{<1 r3ú-ÀQ§g…sxÞ*Þ|éixŸÌ)u"¬“+DÎßö¡xî>ß´í°ètù‰pê©ü åM»&®Ÿ@€ðUÐm˜Åø/þÙlTœg¶·ßc­W‘’ïÖ±q„T9[Ä):g¤Ù«§ˆÍ¹z½zÊÑœ7õà$\˜Ôz±d´XhÃñP(¶].*áA{<ðd4Âõ­}þèæÌQ…ÈËøÅ ÙKI¼áþ.ÁqW:œâqFÐ^ö­¸÷    à-}+‘¾î;ö‚¡m³Vž¤òƒlaØ£û¶«|ËZ½7‹«£F/Í$­†¾ßTø2¯®3¢KS¤ñ™Ä]S:œ"F(e«†,àçüµjÈ!,³Ýåe§Ëâ~’‰ô
£Õb˜CFoê1æ¯Ž··–®ù³¸¬¨ÒÁ¤å$°U€£®ò P§è€JË¼aÃ±»c¬–`ÈçN	FÃh©ïVß×§fØ_ÕX —R0žÓ4õ€ôºaèö†f¯°[$8îðÜ\Z,{EÃ«1:§“óŠ
ÖTDB0¡‚"°CójiŒÈŽJßuûäßêùÜrtÇtä´["Ö‰ñ%P¹¨CŽàSÑ&IØÄñƒ†¡‰¬ÿ˜·$ôä²F{9*‡á¼¹ì=Æ¬|œíõL©[H(°ïW}ABR¯Ž5*/`ƒÏ$8îªR$Ô!pÁ§™2ð±
¯n9µÙÚ“=úHq-ô; F“ËÒºÅÒ=ÌÊ¤œGªtA˜Ç]Ž]€(ÃT»E‚ãN¤µ0îˆ
„=¡ê›Ìû™hñK˜¡ApåròowÌG²ãXÆÏW@^äãâ¶«‹wü ÜF~íÔyÛ
<p>Òx?_U9êýQði¨Ü±%	•³ì=Ó`b=."T[Ù’fz­}:¼w@«•n6ångVó%ÙJ;òø¢eB+±£cŒQÐV	Ž»êNK¢?
>˜JbäŽ½ÃÕ¹^áXCãF'[öiëÂt: µlc0¤]¿14»}²ClRñ—–	™ÿýûqGüÆjx!SÜi­wÕ–:D|È^Tà>’Ôµßi­±ì¶2ùN7ªõÝ&ã
tæÕÒ&‚
ëÅ.¾YO`¤ÒÒÄÅâ8üàJÅ“‡†â3‰:PÝi©C~v¿)«ºv«jŸ]– ¡ý ’Ï«#–Þ&æ›Þ¢¶ç'±¸¹m×[åZVóåÆÜ·+QÑ†;¿µ*ÔÞ"ÁqWÞjr¡B;Y[:“¹Y«‚†ª´5Ø$'hëÉÌè&ã/%+yOt
æ°³nÐ]o¥se:t îºpAÃ †ÂÄ´JpÜU,7uÈ…&p—°Üwhg¹íÛM4ä/äŠ´›õ·›EdkNkÁ ù}»8›6'2Ìw&xÚ9¬]\x‚ë^¾‘¬p¡Y%8üÊ­C.4:hw¡qøñUšÙòw5?½èö‰h#GªZ½Ïóñr'TÉbûq¼x(®ê·vIÿ³¸³
{5†”&`à3	Ž»êF«;ãD3ƒU ¹Ñ‚Ô±uýF
jÅqý°l‰e¹Æ%–FÙ\r`Ý¾×mçæë|Lëé¹áÚ±zçPÓ¼s	äàvÜIA3„Í¡1Y Àgw­;ãÁá¸Csè“àÞƒ©<öÔŒE2ýã°”nâ‡î?úZ©ê°hb¸
Åµ}aYÕæÅŠÆV’Øš;·›·êÛ z
í“øsã…¿U§HÓdæ
ÀgÿóXòß\øc\ÞÛ8!ó|½Ò¦”Ë«Íf“ì¯ÔKÇÙ¼WŒÞGÇ1RÝ8ug¼]\G‘iÏâ::BWMÀ±>k¯w«HàÈÈÔò½v3ÑŽû+5¯÷§Ní¬/QŒÅ£5¾¤œð…p
 Úë“¿o‘àÀ«®œº3W}ó”–e³E€HËºÅYÒ–t˜íKûÁ¤˜ÃH«›*)­¼=zÖ,³ê$
«¹g¥'Ü±9`öÂßÎÏ:
›ƒU‚ã¯ºzêÎ\ùÍ`ïÀ7b;þ…ìÑN§ZifÈ8ŽýSÁ¨¯horépœBµ`y‡j¥ñj×ž
ÚvÌÍû•C‘è"ï cLjoø¡_$üÿö°Ò{ÎÒ2§<óÙ{xý}ùm§a""øÉL)?™¥¤Ñy€¿5” É´Î?Ï
¨æ.ç¸–þâÎÉAÕäàåä>Èî®œRM]N/×YmÆëFûËé/ß55¥åïŒorÄ,H™a\
ëöË¥@51æ·ÙÒÞS8&z‰a:»”4?ÎâÉv¼”Luö¹åÊ1GÃÝ›œ2Dx*å·Xù.GÎ$DyU2äÒR³ŽÕ/‚ª:eèauÊ¾§°	ƒª:eèauÊ>˜¹ce|TuÊKë”9¦ìª2eÈ¥eÊ¨c3W•)Cn­4ëT]e¨*S†]Z¦LwlÍUuÊ°[ë”9Uš©ê”a—Ö)£NÕUFª:eØ¥uÊ¨SUÄ‘Ê„Ã.-5Kª"ŽT&v©	çÔ‡Tvi¥YêTq¤²àðÃ,¸oZr•‡]jÁ96q•‡]ZgVwª¶0RpÄ­œc3WpÄ­œSF;VpÄ¥œcF;VpÄ¥½3Ú±Ê€#n5àœ2Ú±Ê€#.5à3Ú±Ê‚#.õÁ9f´c•G\êƒsÌvÅ*Ž¸Ô„£ÎœjPSi;ÐîñÂÁ$*Bx††!e£7õó±ýÐ/¯o©øWæÆ•Üú×EnÇÉö¹ÆÒi/ 

Q“+ÉùR^ÈúV>l]>ì“‚ìÃVgY†€W7 3îöû[ù°™|ØèŽa++¶Ÿ
[÷à«|Ç°ßÞÊ‡mÈ‡?¶­1Qg}¾ó¯÷iú*W>lË[èÎÆ÷a“;†}ƒncQFGkðóÃ~+¶¼ó<¦wûÝÆ|3ô2MC|~ØïoåÃ†òaëwûÝÆ/x
Ü¥$ïoåÃVÅRëÎ¤n˜¢
‡=… ˜ÃêNR'wŸú laó˜:Õ),‡.ó§µ¦§¿)'|…EtB}½]¦µc¢	Q2Ì‘CC>öõ}? /yúZŠ/á·Hpø•Îdpœà?ÚCª9üGI™Hü±Lk›/æƒ Òë5"¾E3ßZ2×\ú7­º/–[c}I|Åà×ÅÈOv~iSÀo‘àð+#«Iäð›ö4~(«}Y¥³9øÓë.P3Xmø&tej³l~öÔ6ƒU.r°òºî­ìðßW¥ó‹ð
Ý†]R¥óþw	ÿE¥0Å	%+áÄ¥,q’éŸä”Í¯˜o/X>FÓ5JÔur–.üàs÷r%¬Óã+¡ßv&¥†?85Ù„£ï’$P^>z`´'
“Å ³œmÐlÒžæáhŽ×@ßKÕòfÙ$kùZl,Éðøþ Šæ^hP$-Wû
ÿ»‡_ÄÍœÊ¬‘”½|'‡?´¿Ú% ÛŠV×Ã,˜
˜jèsÖmE`b)7õn3s‚HdÜ®kGçò†¿„;ßaˆ—C#²Œ&»E‚ã®
ÞfNeÖŒˆy´e’	Ü‘=“Ì<ßmEû¥|ßßcó^(0J„
¹p`–òo³ž}»Kg³£oju’³£cE²¿?%—aP&'g?t¬ÊfN%ŒH:hOlâðc{b“Eíó‰e?­ŒM±¶ëµUd1I.}&Ç`¹Ûˆuû•<[-ç‘àþÝI#¯ÀCÍk ˜,qøøw	¼*q˜9”4RðíÌ¡Lïcð½Õb¾‡q·zèã <ÂŽ†|
->HTq«2gzÖ¿Ï´2«$wáz¯‹› bÔÀºBï-~Uþ0s(g„Ã/)Ï!à¿©“ÕÐëÆ V™IÓ3<‚xÅiÙn»»I¤ª…aªÖ¥ÿÀ\³#ðgÂI7˜‹ÇÉíÎ‹»úmvçç/ëØLô¢Ô`ìŠA'³;
¤Ê„»ùßîñ@HVâ}z|%T÷_æPb(N&»ÿSè–ûo=‚¡N·Ì˜»E{óå3Ç}²‹ö‹RÚlî&ëMf1‡i.')Ô|ßý÷kO‚H ôRC—_€­Õ˜9äþEÊì²9þUpK›$X	áL3^gµvÔ¨¦*È“4³íÚ<‰ôc¹-®¹
4/eF†¤^Ðv"„E`F4¦+, «Ç_Õ¦Š9äÿ…k
2
h´¿jÕ±ÎòƒF•ñØ SÑj%óÐ¶Ùž­Qý°óí‡ùz5ÙÑò·Z@ãY«1qüøEL¨´f²úät‹ ]uÙey}D¹š =W™ƒ®Ùs•íJ_iÏó³Q°>ŽôéÚp™	µiÍ3Ï÷C“iÙß—
lF'¡2ö9W¾ãKJo¼h†—_¨R¿V	Ž¿ò¶ë³¡àÃ© }ÓçWÝ-›~:‘Cžx?œ)6™±Õ#ã}#•¯Ã£fô˜k…F‡¹?1	äÂƒ”Äëö€Mk/ô"l Šä›¾U‚ã¯ºõy
¡½)1?ÓÁ”&3?/=“}ÆèÎ ´ÝÏññ×úC ÞUKx:;®'GOuµOµx1í¹ÕëùçöÑuy1¡rOUâ 7—TØ;äq(„4¾—H°¯î¯VæKêæq1Üê£IÒ¿ì—GáÝ~_ÙÏWhjDª ¥ã¥¯ÖòÎµ¤øŠÒA¶xu@ˆ®¸òZ%8ðª+¯á¯¡Ód.¶t¡*q±Ij6õÕjhÄà,µð3Ï:–ËúÓ-ÿz™-i›èY­T‚fzØ:×!ç~ü¿N‰8blHï¼ôL‚ã¯ºóN¹bÒâAéÂ Åƒ"ú4\è/ëãx''¢[Ã¿"úTÏWJ|HMÍyô
¡dGVoþNÅ7è^hxñgQ?Ò(B@Z:ˆžIpÔUô®á”§!Í£Ý¯Ÿ.ôÐ-~ýl¬Ãáü&Xêë 6
$#‹M¨DV£U<<
¥†)†ò›~*OkCwÿn^Nÿ¼óg²ÝžžIpøU×[Ã©ëíi¹„rëG²ÛK*75¢å1}}S
Ô¢	mêÂõ˜yj¹í<ÜnÎÇ8¼ì¢p$ôî›ÎÝºÏÑ%"hÿÈw« _u·5œºÛf¹™cÓ}˜*¤4»î[vœr«ë×ó‘Fï¢{ÎNFÓi`|Ìök-i›…t«ž%ùÁ,¸q¬$ÑW”AUiDCDVŒUü·HpÜUwZÃ©;mö ©ŽÈqÏÊª#ÚÌûh6T,
4î†"Æ2ºÔ*+T,¡Ê* 7õF~×O3µlÍÓ‘c½Ó¼¿[é_+ê "µíé™ _øq±j[ˆÝÉqxÍ	N÷jÝË #ôs‘ôì­|ØŠÈÀ+Ø‡Ín6ß'¨ÆAû\¬={+¶ò&å”'!
$u‡¹ª·nª;<läÌaaÛ;°N¨m¢&Šæ2tt<$·ÝðÒw\è‘/ zµqÍ1÷ÙWv|ª*¬C¬3Y!P:e‘ø¡SåeÊ)GB–[2²¾E$Öm§1G1OlÍR‹öžÂQ¢5kçG£î€ÄFqßXûõYZ÷·³í\bZ~wôGl`"ßj,    |Å…ŠÀ)ð‘i/|ÆÁ!I)ø‡ü¾•Á1}¼‡ÃH#Ð$Ça¨9ÂñU¸Õïä†8Î]–ØKtÿ»·y|êºN!P±Í[%8øŠÛÔœr#dqÊÞÄ
r·4ñÚxBÌ3OWùA¿¶màxbÁõ8ÁÆÌH½ðµv‘ÈÒ9æýàŸZ¶SÌ¨œ¾¥g|Å¥Š¿Ç1ðM»Ó^€$õXmš?J|%º.tö¹ÍnÝŽg:+]ƒû|CRÏ¤¼)êÍÀ<›ö 5É¥êÛ5_ÍŠ¿Q¦Ð|‹ _q¥‚šS~„ê^â¼‡©cê&ç}©[K´Šë–QXÕIÉqiÓDÔ™é™ÅÒ¬os˜äÇÆ.ãcu'øP8
4ÃK
L¡Tóõ3	¾âJ5§Ü	U’¶{î¹v‡°¬«½ÍÞ™^=¾F|ÍHfKãŒÖ*~‡
0­ù•‘Hw_Ç±x©ûÁ½h¡—!h`)m¢ŸIpð÷*¨9åLàFåÐnlš¢êüµû,›ÆÆUË,¦1q—Åc„l@+2îéþ@½’‹7ê“h¦Þy¸ £ŽEÜ+ÒM!¨[8æº<Rä"ÑJ)âD¦ÕµHxŠeÔ½XCÚµÜI¤ˆ½—Ñƒ3Çlk`™__5§9­}ZâÈ1ƒ),sb^î:±Åª´Íîõå±%‘‰>9ÔX­êo7íº±Ö£Écê@V¨Ë’àäoßuè
Z
ßÈrÛ®c‘àà+®¸PsÊ›Ó:¤‚voŽÌî®–þÜŽ#Ý¼´9¤ëZ~ºñŒòqâKápøŒu	wÙvÒˆ¢?·q®MïWP
, T¢ ŸIüÐuÅÍjN98êö¦õƒÄql71™²Þö¸¥Lt¾jl¦O.0BpØª¥À: X÷bÃPLþ÷š˜P_jÔ‹(£š4+H?“øahŠDð×èØÏdCS‘.ò­™—@ °t´Äíý¥Ê†¾¬âqž
.“¥%ÙÐðòY§?/ÆÆµNy¥wÆŸÂ7Îƒ½5tu—
f%­¡-Ïztšˆ.Çëq¾²K—Û£t3Ù(¯Žãa¥;*™Åq2±BOgÐ 	Éæ»ÉixÒ8+$b;9MjèL‚¯ºÎg|)ø£="F _”EÄØN¸ÐRÏbÎ"ãÅ(Ø–<±ÁRëx1v˜®šhãkÎ³»`"˜u®Ù—ð?U¯€bIG¡Wü-Õ8ãNIŠG{"ÇX¼žˆ€òÕÖ²µØfÚ@›^“dæ¾V>\ìøFñö*8H÷
‰Í|º88×Hë~àùu‰Æ)ßN€+¢¢¥U‚¯ºÍg\)xÍÎÑ	à«ŽÎ~ÎÅGYƒ®&‰N‘±»£ÆzŸÖKYæ
vb(R›G‡Û™Ôó²D„ïøs€ÃvÔ½âo‘àø«.ôÀoJúÔ)D²ñ[Ú-¡x½y>2fÕÁvÓ[{æÁá¦@3ÅÀ0Øž5QpÚmOé¸â™ôfYì#ð'¢1Ö =ûûý÷×9öªû<pÆ™’~M4–a/iÌmßôûé˜6Zu`œŽâùôºØVb%š-x8“lÙaÛo¡¬sÎ·oúHÄq#hCvgÖ+ú	Ž¿"gü)˜¶u­ø÷È-žÄuíPëÖôÄ¢®7ö,×žmëáöh]Ÿ&¸R	G¥¿æÏ |Å
‡.-# ?± eo†
‹Ç_u­ Î\ë9þ8e‹ãø‹œãôÿpXoŒÖ
÷R=:¶b«°¶Ë™es4
òÏ¨fü$ÛlÂCìXÚ—ðéÐ«Â4»?ñ„¿U‚ãºÙÿnÓýÖÖìä
²t5
ò;Å”_wþ:oiö&vÓ]ˆx4XÐ´—Ó?Ù%è†>Ý¯“,^†4á±þKÑú,<wVo¯žõ<û5—úoÚßÞãû/y+´ÿü_Ñ
íçÿvd6šûŸÍ½GxênžÌ¥™fÅù‡ÎTîàŒè$k‹sjJ»%Î¡jt
¦9ÈgõéˆŒ¬žÇ6ƒÐb2(íÒÛÍ`
Š«ê0:’Åp>âQaá^†™!I”~Ãÿ]‚ãäªk:~ôÔ2ñ9"lUõÔù‡ËŸÚËN…w=¸hþíJÿ\G¶ Þ²D\á”	güü?Úëˆ ¾(­ rùÀ·f«×îÕ&{zl5h¤ï‡ù£æ«tã™é2º©e·}’
ö“hîÛˆ£‹—êˆjXñÀ[$8þJ‡„Sž¸êQz78¥wƒË¸mÄ¢‰}ÃlLcf½ÅýyÉ(&Š¡¥cL;Q¸É–sO :¬V$ñ÷Åm
ã”ul”ÚÓt^ñ·HpüU~	è”C®ŠR2‡Ðq´»%Ä#9 b.NâÚxT-Ä
[2®‘®/ûœYØšfiíåfE]—|*5$¼>ˆP&‰-;áo•àø«üÐ)‡œÀÒî‰©›·Ä7™¬ZÔóËm§‹“‰ì.²ðïëé	ì
,=.¡Þ1ÐBm	ÿñ€ý ‹^Þ\»¹AggýNø[%8þ*ßtÄ/ SÁ,±Ç—U¹ž‡$ñe‡hÉ÷”›S}6õy« rµ|§×
n›¬CöáiG1ÍTBµ‚sQ]÷B„½À ü'½yZÐÀ
†"tŒéïÏ^jEˆN	ìÝJR¾Á/£ƒ9Œ®öQn6&í¬mlæõexåé­&‘Êä v¡ˆO›¶‘ù:_ï‡‡`Ò‘ÔùZo{Œ½ô±¬FAäˆÐ%/ƒŒ1lÃýTÙ*Á^åŒ€Ž8B¹Â÷4®ô6…?m:×¾\ÕÙ*Q™Í…v;}œ*ÂÍF»3_£8iO+“R?Û¯8ÖÛþ+
O¹ÆØ‹ F{K®ñú™„¨>­¨8´{:¡}Kõé;KŽ_TŸ64Eï”×:@!š/ëj_t÷t†g6.»h,­ÏÇ<XÄ€#›Æ¡±ØÆÿúõÂ¤Áÿ?a8[u¼“ÎpÐhýïMÏÛio¼¯}BHèùJHÅ¹ÔÛçýÙ´ó
Ó EÆë*^ºÀXü©Ñn/ùü„üê¦o‚­Ùfº^žFjmíÙò_××D<
àh^Ê1×ÁÛçô:Óå¯ÏÇ°Y¾;%æõ30[òÏ¼ê÷yÅ#ÏïÁ­ÆÛÓ¨„MG†þµå`ÝŸ&ºYýúâÓ2‰•²<šçÃåë$/ÅüÚcûj°Ø¯t£ßÁbàj%ËW¨Ð
¢^H){{VÎëŽby«8DÙ™»ä]¿Ð…~›qG¦[ó¾·ÕX­—³å ê5ïÿä?þódjF &:·©Y¤3í,ãŸ¥W„cãçág~Ãç~êQ$b; 'o¯ÁWê7ª^à4éŸ¹ÎáÕjS½`*f^÷÷œ¶`n÷ Ä·9QqBê°9Óáæ`¹îŸŽ—«ŸtMå_x&B:¯¨<ù÷§uaÕiÍ:mï®Óüß=ñ7ok6±éÁi.ÜÛ²ü(B®Óþ@T
wíKï]¹×Íêü$ý¥„QoTçî’ß{W>éÉñ×ïGû$u±4§¿g­ÑiîoA¾ìb†ˆãCº‚rÇ³“ÙÕ¶oÜjçé•ycµÚÍ–§W–\Küý qWï'¶d¿<$GïÂÙqÂ -¶õ_Xò_ÄWœÿöëuò!6¢" ônƒ Otd8íðÖ·ò+ÝŽPçÜZíìyÜZÆ$yk}6©ê±Õ¨
ý»J¸Ú,t·ÃN²Ø,6à”ŒüÍX¸ÛÒÁH½%ñ‹=ÂZ'@<¦ü}DR9ôy‹G^^²ûÒ$Ä;a(â_'OÕe…§}üì]
ˆ°c[ËÌø"¨" #‘
0u¬ÓVV¢*"©€<räW¥¹ãÒp¨gì3Š=ß ©–
Ct‡7t=N/WÅY0šýEj¼Ù%i8ì»ŸQÁŒˆ¬n2~^½>Ìº ¢‚™E‚/€Ò[àHè_€ÖNâ-à
»î-`™v<~€µ@oNÒÝºbp¢©x´K3­ye°ö…ŒÿÐpƒ·@ OOMTŠ¤þ1¼E‚#/ïÅC>nØôéÇUŒN<y^LN‘ãŸ8°Ä°-oýÁ4që	…ÙÛÝzBaR·žý‰Ýt÷©Ê¸GÃEµ_ŸíŽÌ\`:ö È{†³É°;4ó™í—$±.yb7bÄFŠTìo¿*°:Bgžà·÷ù8Á/éóay^zoîÙŽ«!´ÎD¶
bøçË	š-«zcY„ÍÉÔ·Ü¯§p‡«n°^k=BäXÃšÌ^x­õø.Á‘—·E"ç›ÙŸ×«…=N£ÃøÔUQŒ>Ñé4lë[ù°Uü+t„
£¥
²
žŸ¼Rþéüy­‚ƒx¨>ËOg­á$WDÉæl1œÎh6÷¹X<vl÷µ4]ò¼rx	ö‚ÉX«Ä`è—¾Ñ_ƒ×
ù5úºOXô ^
hL¾‘_ºF¹u8àš·ºh—½¬ó[~—_`ëãA¯¿^YÅ\u;üÞ*b,:ïnS6ðjÚ›Ï`3iŠ™‰®E¾}|cË/ÿ½ŽýS—Ñ÷òþ×'Ø¿
ÿþ®ÏøhO7j+Fü	P]±#¸x y´…|ñ' ‡®f›;=¿›oi©ï
Ç§6÷Å˜–·Žõªyú‹U!ÒŒ¬óçòþ¾¦úº¨ƒÈøÖÁ&ŽUB¨þecñ·çV{ˆêÃ»Uë«>@«>…«>7¶R}¾ —ýÍß <dÐ• W€h7ì=ô£ ^ã† šc›ÔlÝÆßV Þ³‚uÓ½QQ•]²—Œ “»?sb÷[c»¿š™|Ãè‡¡]nAïÌäg;;ÆL^ï}CËó˜I®x—ÍÞß=Dñîß{­ûáý{¯E£¾¾÷Þ x€ŸÄèj¿1è7	—7†S‡^é
xÊ
§‚FIåPgðŠËÐzjŸÞ*4ÇúVA:*
%`gRöEä²ß1EäÎèú³š.U[ÑåàØÌo;­í.“/t#áE2ê
œ5"÷;`45wAäÎ©â¿?Bë’ÂÞ¯ÔEâ mŽg­_¸ÊÇ“zv–Z!Þ4îl;–~8—Š÷e‹13-ó[^Rð¢¶/´±;–ÏƒiÍ6ËUçðL§ÝèÍzÿùÿ?ÍæOx!xùTü~…¨QïL-ƒab0ÀxAÖÙÿ’¬ê­ñluÆwY¿¦?[®oÔïÿ ú7ùó°õ?ß~H[^ýµuV³¥ôõVcÙy%Ëo© ø\â—JOf³¶µƒ]¢Å'ÚãÿÿMH[!î†°ò
`Ãàj
äj{¥Cø	»_mö DmÑQ[ë~Um‘ÕörPJµ½„þFµµ}þßZm¡BmÕÎt¯]0AáðjkûÂO    ªmpÐþÏÿËO§VÃ
{e82UÕOç¨ük/TõÚ'ÛíÐ¿‘’"…’ª+–}d ·í­…Nk:Ÿö™ÕÏvçç¸ñ36íÎ–“FkðŸÿ;ý	\ ¹ŸãwÞOÝÍò7Òq¬ÐquëÆÇ˜½PÇÝ`vŒXÇ?°‘ÿf:N:®¼×¨ã®³‘?ZP7X ŸãÖñl•¿™ŽS…Ž«Ã)?2¨·U4¨Ý`–\ŽÂ f¨½V.»Ù þÀØø›ÔºBI©RI‰ ²o5¨m_øUg…TõÃAÉV
ýÎŠÔöoæ¬`
µUw6úhouÜFvpouƒ9|e8×öV>³·~`äþÍöVC¡¤êp·'ñä/djKþ¨Úò
i^D
Q=ÎÐ.cdÞ#Þ’£¿=BàzÒ6Ðþr"D ì2{ù×Ì
ÝøäÌ-áA¦HëC}}æw• ·Då¼Ží ƒ
¦•|À´>)«'eõ¸ŠAÓJÕLë“²zRVß¬¤
^•ªyÕ'eõ Wçeõ­:® eéý´ì“²zRVîÒq-Kï§e]g#?)+÷QVßªã
Z–ªiÙ'eõ¤¬¾YI¼*UóªOÊêIY=\mL+U3­OÊêIY}³’*xUªæUŸ”Õ“²’©­ñÇÕV÷ê:#¢¨ T0­ô¦õÉ_<ù‹ ª-RÐnTM»=ù‹'ñ­Jj )˜°	\X0 \¶Ô¾/€!»¨Çù$nžÄÍßäáfHANê÷““OâæIÜ¸KÇä¤~?9éºËÁ“¸qqó­:® 'u59ù$nžÄÍ7+©‚]ÔÕìâ“¸y7W[ß¨ßŸÇù$nþ	ÄÍ·*©ªqr¤­*L{û”¬qD!µ¿¥qD1ˆt´DDï.<½PxŠ¤—Yªm³,zXhÙcŸ´PÓ_f»ýå†²Ö„ˆ	 À`ò²ÖV	¾ çÌÙ¦5ÿµzÂ[$~»ÉKF<´?²q¯_ðKíÞNÂ×¿½ê JsNå
5âÕt¦QÄ n(¾gàP2p¤8^A¦sÄ±¦8|ÜÀ™ràzu€˜ùÀbàè{Ž%§ŠÃ,tœ«7W•‹ª¿ Ž¿gàD2p¨ø©§t"NŒ'ß3p*8Vœh^Ã |àª{:häÉÇ?ùx™5r:ˆþ”9Âõ–½ ÃËˆAÐ[ÕUïƒ8’'!ÿ$äª·ª»ž:äÉÈ?ùïÕR (‚ÿ
’{‚¿¬=é_—=ZÍ
à  Êq¢£; @#7UQÿõVnž½•?YŠðWýþbÞO6ýÉ¦»êÁüÕžÜ®äìþ‘'þ¤Ó]¦äŠ`[vÌˆëlû'Ÿî>>ý[•œ(Bs™:häI¨?	õïÖREˆ*S‡}<õ'£þx½U„²ûóÌŸ”ú?Rÿ^-UŽ2uàÇ“|y’/R½•k¥ƒz
u¯A…„ë­‚4d†OòåI¾<To¤!»¿¨÷“|ùG/ßª¥
ŠÝ_ÕûId<‰—)¹‚­cnk½û$2þ»ˆŒoTrã¢Q¯%³]lånÌl‡9’ÙN4¥q?Méº
Â“Áq!ƒó­G˜‚¦4îïgüdpþÎwj)UðŒ†šg|28Oçñz«`ûÎŸÎ?‚ÁùV-UðŒÆým†ŸÎ]»ëßŸÁZoE&«‰A¹Þ*˜GãæñÉà<œ‡ê­‚y4î¯qýdpþÎ·j©‚g4î/rýdpžŽË”\ASnk>üdpþ»œoUrMiÜOSºÎN~.$2¾UÉlÐîosûd2þLÆ7ª©Î}m6ý³ÍÓ¿‹M¿|ùN6*ˆF ©™Æ'‡óäpýÄ2]Á=íþ$Ç'‰ó q¾UMT#Ðîï¼ûdqîÚ_ÿþ,úÓŠ‹‘×€‚\oä#Ð>`Ÿ,Î“Åy¤Þ*ÈG Ý_ðúÉâü#XœïÔRÕ´ûK£>Yœ'‹ã.%W0•@s[?Þ'‹óßÅâ|§’+˜J ÝOUºÎN~²8.dq¾SÉL%Ðîïõû$qþ$Îwj©ŠjjªñIe<©Œ‡ë­Š‚÷'û=™Œ“ñ}Zj€sÇÚo†ü”wíF†ÿåCÎTD#¸¿ï“Á¹ëXùû38øO?°z™ÆÖ¹âª¨Gðõø¤pžÎCWÅ=‚û+¬>9œ‡ó­jª¢Áý%VŸ$Î“Äq™–«¨Jà¶.ŽOç¿‹ÅùV-Wq•à~®Òu¶ò“Æq!ó­Z®"+Áý"Ÿ<Î?‚ÇùV5UÑ@M7>‰œ'‘óxÅU1ðþdÇ'“ó`r¾UMU„#¼¿	â“Ñø‡2ä+®áe:ÌøÁ ? âžŒÆ“Ñx âàÜ‰f!ÏÅw¸‘<×ÿr„<7T$¼¿Ôê“ÊùGP9ßz°¨Gx­Õ'•ó¤r\¦å*Âº­'ä“Êùï¢r¾UËU„%¼Ÿ°tÝ%áIå¸ÊùV-W–ðþ~“O*çAå|«šªG¨fŸTÎ“Êy¼âª8HxÊã“ÊùGP9ßª¦çŒãj<û5
$&"~]ÏFC¼ßŒ´éA<V<Æ€9ˆ­bÓib46šWJ¸áåBój%;HC(5,ÂÔqt4ƒ£UlRÂB0UhÌBU3‡E-ß
ÚsÜš~³\äÛ¥
E`|ˆ¿Å¦š×hÖÑ"mQYwóãm´qXûfa}¼˜Íˆ/n¶G­Y ìû×¯Ÿ ?M‚ýúK¶Z¿ë,ñ
¼@”X3ÞÞò
ÀÁ\ ]÷B„½À ü'}“ù­Aöé´ÓzÓ
‹k•Ã
È
æð€!ù×iØÙÐ3	¾ †jS
@Ì¡Ï¾ ÇL. Þ¯EÀ¼9àÄŽ«Ð¨2Z$ÊAÊúÍÃÑ\ojþ)5{z²&­~c•¨ÅK
lGÈÏZ±ø‹v¨i^ÈQGÈ
À'AçÖ½†½Ø0f¯ ƒ
Ð­?MSŽÝf±ì]‚RCŸ–¾:hÇf[ ‘ –©èˆë\£à	73k}»0F)¶†lDu—‚þ±º Ü

/þêðë/ñGÄ ÈP×Ï$8ê@…:qõB§†±KÔùjø©l¯IíRü=é`•ˆ½Æô}Y7È®†Y˜J.ËÙD¶$­É±½NøP›U³ú*ÍìàÃûÀgüeÃðRèÅäSðs}Ö_4è¥iàü—TŠU‚ÃUðS‡àoshWút0
íJo‡?DRþØ7[K´€±òjî qà¨µA´T‚žfnUaéZ¤
B7Â}Ãù
ö'cÅK"Ê±·Jpì/“_ßÙ×Ü×åçé;6_Rt
}·”ÙÒâÏëe£ÛpsÐë¯W¿‘¯ñ×·ñ¦óNíñW¹:kocžn&Mñ!³5—´ÈÀ·ol;ËF¯cÿè5Þ>dÒØÿú›Ã¿¿ë.ñ
#Žÿ%ú†?xþðnü‘ñ1þ¿J{_Áýþ+øèþD?|þè
þø*þ€[)? ôã`äã šsO ¸\÷‚·¶êÿ ª‰#wNÜ™²ÐUóÆîœ·3
	ÀTó&îœ7shÞ†jÞÔó6œ™7ÔTóÖÝ9o 94q š8séÄCWõZ1ÜÚk:4qE	¨¹µ„ŽC{:T„?BÍ¥áÈ©‰+¬6¨¹ÕjsÈz
«
j.µÚˆCóVXmPs©ÕæÔÖ¦°Ú æR«
8µà
³
j.5Û ufâHa·AÍ¥vthOG
»
jnµÛRu¤°Û æR»
:5q•ÝÜj·9õŒ«ì6àR»Í¡
R™mÀ¥ftèG*³
¸ÔlslSWÙmÀ­v›S{›Êp.5ÜSu•á\j¸A‡êXe¸·nNM\e¸‡n—·í
/„CªŽU†x˜áv}â™/Xe·Á‡Ùm×çí”¢«Ì6ø0³íú¼C
VÙmðavÛ wˆDÁ*»
>Ìn»>qè‰‚Uv|˜ÝöÁÄº¢`•Ýf·}0q‡<ËXe·Á‡ÙmLÜ¡ÓŒ¨ì6ø0»íóÅ¡gœ¨ì6èV»Í¡gœ¨ì6èR»
:tœ•á†\j¸A‡¢²ÜK-7§®(De¹!—Zn™êDe¸!—nN™êDe¸!—nN™êDe¸!·nNã*Ã
¹Õpsè§*Ã
¹ÔpsÊT§*Ã
¹ÔpsÊT§*Ã
¹ÕpshW§*Ã
»ÕpshW§*Ã
»ÕpshW§*Ã
»ÔpsêrFÏ-7K:žØÕIÇÃ©BK’Ž×Ú› [:Þ>5ôA3ØÂæ1D:^{XlÖýc$—Ye;¹ƒg™62ÝÄ1 h­3bùiÈXÍñ‘tvöt¼·4ÚoJÇƒèY¿Òñð%ö	Ž½®Âž9ƒýÐ‡SÃ¬-õôó†TÈÈÆLÁy9Ú¯"z¡¥Çaª¸î²Øª
Ãn{C`Î7Û^¾Ö{p*¤þH3”"¨ËR!á™Ä`0Å©n°ÏîñFº¨ìD½¦°?óÄßs¶?/†&&®8Õ9"š¸óö‰ú…ýºiX®Àü—›f­ÿ*äõ^Yæ$f©v¢»D¥Ñž¦ï/XÞÿþ‚²VŠì“­rïŸpšáªÞÙwZ›õYåñÊéó-¯©>_Èž¾£³mŒë³Ý´³|SÕ³W~}Ô¿~Å ó×ÞÖKV\JõÙ
$ü)õ2®1â
ä
Æž
æì‚Á¯,†^ þW¾`—;Ë[zí[¢ë­‹^Ðø~­ó ØK„	•­€Å:ÓQ¤×^K/‘"½œ:‘^Ž¼à-‹÷ëéåøÒžÐ^`$¶vÅ½…ïùî<ÓîJB“ííªÂø!š÷_•Xƒæºª°yþ×ë¯ã¯'òê¡—±ñ¿5¯þ–GŸ½ÒªÅLÐWYWà
ŠÖ`}Ø›qç_ïƒŒÅ‡³UgÞ÷¶«õr¶üß›ž·ÓÞx;­79a¾¯„`ü$øöçy6í¼nŒ@Ltþ%_ïZíö’ÏPÈG:üPjŒ–:ËiãØøyø™ßðõ}{sk¶™®—§á†Z›F{¶ü—Rg¨ qã&Ú
„^C7 ·ÿ}N¯3]vÎÏ‚Õfù>™Àiº?sÿ]¢f¾`*f^9Ùß·I(Ê
1Š)@ÒÞ÷~Àóšƒåº:Ì¯~|“´¹"ðj5Þ.>|Û3C¿×q9*&PßüÒsòï?­?ùÿüŸ§2œ-¡^ò"Œ°ñEe°|’ºðÿ˜— è«®éº®a:(<Ü¦p©épLzV¸þ8$.ù=dµtæ
ÖÖ`Ÿåð¾ÉpW"·tæ
Ú–CâÒ5¿‡Ë’Î\ÁÛrH\ºæ÷„(Hg® n
öYï»ÖÜ©™
æ–Câ    Î™;³Á]îoÿº˜÷×ýëé ÿy´5Åéàèh/jj÷¯gŽ›˜oî¯²U/6¾I´Q›ô³‹V¹ÖVñ”ŽtÔ-f‹•„ÛøæJ½ˆK‡æ5¨Žµ¹ØùŸIü¸ÜdÃbQ€?vHÙË›ât!»“Tz´QKËƒÙdbÜ‡o<Ëk‹Q`ß^éý]§síV	ƒL>—EzêFjéÂ/||ÌK©N4;»t‚ß*ñãr§·Àœ‚ÿ˜.Øêœrø‹Ä^çÔR]ÖLa5]ÂZW+¬|‡Ðþ8®×]=U[ ;ZL’cRïù²ÎU—ý
îüŸðqbÝÐmõe_q·Hü¸<g,¸;SËšãŽ$Œ*Ç}$cTm»Îþà™b®–«5ë‡ÞhZÚE§¥ñ²V6ŽýM¿/˜•eÆ˜ã‘vÀ^î¥‚šb×±Jü¸<ì,ð;SÉšÃSÃê%ü$ôÌÊû‚Y†£˜ÅñHÌhfh±ÅæþvªP!Ép·o÷ösØ€ÆÜ ?Mk¼#+à·JpøUÕ•±35­9üÄ<Êà!	ü¶M?A£q¬b_?îËÑ¾Ø|»jäPô£:4wòžÍ›
XKÊû~ÿ¦ÏmB½€éù¦o•àð«ª+cgŠ[§ƒ©ÿ)?{0m…ô-›~zàIlÖµRIËƒÆb?ˆ“Ü òuñ2;
.1 ™Z£8ß-–¡¢6}¨¿hÄ
)†Ð^Êýw‹ÇýD@CÉÐÉý:yS˜S;¦ß°÷ÖËúrö«}ý›¶›_ÞuOQþåD} Š-?l:¤jRÓ2¼ŒÜ ¼ƒÛü÷•	½õÕpx>òþ[¶ï3ã‹€å‹ÀîX¬î?õ:hð‚Nç¿iŠoZbxäc_]öùE¸c>ŸX„÷™ñE òE0îYuw%Ë ùöG5½ºÌ?X&JÑkDgDzuýÌ"w,Âççsó"XfÆAuóÅÎÙçÇÀ1´Ùþü(î$=l§p¤K»ýÙ¸=/ï·Á Ä+ÒÐÆ¨ÝwIi÷[ÔWñÐ:îŽS˜	>€ ¡8…-~åÍ×™ J¿)µA‹ÐnYNaä
ù[ñb&U
Ì¶á\"Ý´s±Ò¼2ë‡ú¹hdÐ%š•Åˆ$WÞ œÂ†0-u¢c¢:…-wå•×™€JŽ»–¦$¸W©‚YµzµÝéÇ
¡h½2ËÃpÜÃªSœô7êÙÉx/jˆŒÖ•Ô2SuƒÚ#nÙ#/P#
ƒU‚Ã¯¼ù:åoKifP¦öUíªÚ÷3<Y% Ýh1¹7}hš8Ÿ–X`ÈH C6ÁM$™+ŒOŽ*æ7*LFrµ·Jü š²‘qÊÓ–ÒÒv—ƒ žÜÄÝ4ã1F{ƒn'ê)m‚õÅ`^‰B¬ØØW}Xo¡Š+<mC Uè½EBàä6võ¯Ýb-ó³1øêa¿nò üˆ—[ÖìëvçÅ|n2þ?=[-ëÄÄ@ù€{Ö Ü2hÀ¼ˆòƒçã_Œ•y© qÅ´¾mÀ‹ðùù|fÞf&V©v"§œÎ)hmüøNÔƒ’F~¶ˆÖÈ°½ð”æÇ|4£ëôpêß…ã£]cõM`Ob–KN¦‹¶Äûö€HX8^¤é€èŠÈ"!ðÇ*ür>§„
N†?¾êôÀÑ†‚z:ã¯-^²J³SƒÇAsêÎµòNo6æabì æŠ#‹ÀfŠ
©Ž`‹„ ž¨€wÊíœÂfPâx+ø4»ãÍ®øƒÏ\6·ÈBQÜ¯YÓD©’/6*úGã\ ¶ Ã-0RØ7.¤¿@¾¹kXg
½ÿ- ÐWÝw‰S^gŽþPb 8Ê7p.mÿœå=Cc’Ë%§Ót:’ÌÓíR§Wm”Í@¾Â'¥¯ÇUÍÓ™¹ÁéôSª”†È[÷ÐK§¿UBà¯ºð§ÜÎÙ=Ç[‚
ÜBº„µÚ†Mãã¡‰
ÝD”fwÝX(Ä6C
ÇñvÀŸhÔ&…
gÝ€?†/ˆò/Ð)³÷õ;áo•ø«.¾Ä)OVKIwŸêîªÛ?ã†A#˜Ik0:Tç±R2•Êê³(Ø°Q› ›Æ>âkŽomßúg§/˜ˆ \F‰|Û·JàUW^â”§'
¤|‹ø)m\|®ø-PËÍ¹]H*ÉH|QkFÌu$×L¦¢§Ó~¡<ï÷‰tÞšÂùgñg]Ì†Bñ-?Dâ‘
§<>Y õ´ZO›ýØ¦ê›¢Þƒ“íxßÚÓY­áÙ³D¡mµœ¾ƒÚXz&‰uøþcŸÜiLÓ±Fäç®UBà¯¢{‰S.Ÿ,Ç3$Á¿§¥nÐÿH§Ÿg‰àb—GUÏV§p7®¡i>ë–,‚*ÑL3‹ùÄ~ê
ý'Ú‰ÏÒíÍtOø[%þ*¾—:åùÉIŒI
C7ÅX%°QNeú ;lFó¡¶‡ÊñÉ}ñh{öâ/w»`³	JÞï×BD•®+î[V	‘vs™EþkèúgSßó?¯ÆqÝ“\Â¿ÔQ÷zGQæHG]äeoÉQ £î{ÞÂF"¶U•Æo<,ßùþ’’ ^í¢“ê›{èdp;ç£#ˆ.ÀxÑ¨—¢öuIEK£Vº=•Úžª,mCä–S"2æ|ª#uÊQUÜ›G[í
¾q¦¤ö†mã\ãbÚçéè3¶éëišx*µÅ06–c›A‘Uo0JNôEÿÖº'vã4^öŠ¼5  Š¬Õ‘:å¨*Me1,‚[(‹p˜ÿ¢é¹4kjy’V†M¶_™Å(«…ÍB¹±_ è¸’×ÌŒäâò­øë‘ú
 ¡EËð'gÕ‘:å¯*ÓA‰£vXÄ·8ja)×Ø
þèª5¥…ý 4û"f9v+ádu”ŽƒžH`?z¸¿êô¢\»0‹„À_uq¤Ny¬ŠüÆ.¡ª‡Õ„ª¶ÎM\§|‰h eÄu}¨-–Íe¡ò"ÉµÆëÅ²8Ÿ¦âyO6(¡ì¾Õp~Ã"/ †®!™áLÎ$„á¦¨U¡¶b€3†ÛµŠ×
7¬;S1€¾
áën1Ü˜­8òÛ|¶d€3
p­d ¸º Ds¢d ð7,À­%n3U… Œ‡‚ºžæT¤¡*“b<¬LŠó½Ù¥W%ynMòv¦>ø•*›¹K“¼)z.#A-XŽ÷7åõªoÃ­9ÞNe·ªoÃ­9ÞNU40T9Þ†[s¼9Óàe eæËñþ½é¥3Wx EX¤;ýžž—Ò™+8èÎ™ßÕÃY:u…	'â Ý©ïw53–N]aÄ‰à;w®ú]Ým¥SWXq"îÍ¥«î˜Â+ì8yæÒUwlê
CN„}¹tÕš¹ÂW.]tg,9xXcº[M9§6x 0åD´‘;§îØ”¶p){WWgéÔ•Æp©1çØ”Æp©1çØ6 ”Æp«1ç˜Â+9ð0cîrYè(ºÒ˜3æ®OÝ™³
0UgHFî;ÚNŒ†aL¤¹côÙ¹ßAc›˜¹BÝ½ïdûã3¿Ÿt¸˜¸BÙ½ï\s`âªßÈÙÄ5¨Ê…£N%Eœþ“Pü=|KJP!blvµA';÷ô„y–ZŠ™xš6 U^f½™‘f†¹T¤åŠ
&
îP«44“XúªL8êTJD™²Z Ã¼%ÀdÚ30Îµü4ÞEvIO*f”·!3ž6C½î ¨uóÄ˜-üëƒý X§ð	Ê.Ì'gUBu*3¢H¤))Ç$%ÅŽ¿¯•êY7x0W
êÂœ¶ápÿ`Ò»¨owðûöV‹dö’š ß? "ï@Ã`rø-}ex£SyE"
o<†dáöÒ§3tlÑÒÆŸ
jÕRÒøªhVª`ØËÚ m'´`ÉD‡G!|E¾ìe¨/²Jü•áNåETwÒÝç»i÷ÁýR*Q¢Íè¯-£·¨ÃL€TczÓå(ËoëIIÍ[Ìøc±·hT'@šAÎ$þªðFÝ©¼ˆêNZã“UÄ°á¿®²H|†@“¢`ûíÖ‹µfeY¬˜þx?4ê—³Ëi»˜­x$áÁŸˆ›jüß%þªðFÝ©ðêê>Uéjo×KBbo±É¬L¶I`ZnÆJ¾
^r‘˜¯ÔN¬²žqc_¡ždÓÐ|¡GŸ}þÔÛ´ÄV@"gx¤JˆÓŠ«®LY\ï1«Iâzíf0ß ËÉJ»¹
šžhh•ÝúL%±aªo6@gœšç‚¾þ£²^ñ×…I¯cbÕÆo‘ø_”‚9¯‚xúõmà¹Îj3^7Ú³SÃ‘ÓK³eûÔ­M{ûÃeÙ’kE<N0„^J!bW5ÞçÆ^ˆ¨YÆ„d7)e®Æùë4ÎÉ¬½y»]ðo gþÑ¥P:qåT¤ƒµ-©±¤P±¤@»œX`æ	‰ ÍFkðŸÿ;ýê²žr^Nqû"ç"DÈõ‚?§e=¥z	f:VrñÝ½¬o7–ï7a¢ýÛaL®.¸
å$?1K5°)Ô@u×Ê˜¨òë¹¤´Ê±§Ij*ÚvÖ(Æãå81mƒ
ƒÓI¶¹è†š£e„æÊ¾…§³ÊÝJ>ß[»âB	E» /”?fòÕ*!ðW]èu§2&ªÈÊ®4#í–+M21Þ6F»ã´½l¤@=4,áôp›ØÁš§Þl<ý+L˜YztaïWüÉ
æ$ê½*ð·HüUzÝ)wV¥
¶nrK7
-;[5ÑQ³™™Ñ ¬‹f(²/&=:ÚÅ§óŒwÌjuXJ¶]ããú‚4/#Ÿ/
ü-Õ•^wÊ¡UÅ2ý7ƒ¾›ô¿+®²AíPÇ+s®wò{
ªaâI‡A°’ã $BE£¥£}gæŽý‡ÛmØ
eº½aø+þ	¿êJ¯;åÐÎCþ¡›ºµ·ÆÁ|¸7ï¥òƒýÈsÁN>êOó›Õ1Ø­ÕÙf‡ƒþzuê
J2€?»
dLËX´áo‘ø+¯ôN¹´Z;YqWS´™¹áJ?KÕ‹õÌ!ÕXUjKc_?&‚ÙõJÇC ?ÊW²±Ìj…V‡Ð<àŠýÿµt+a„È;3	Áã(Â°½¤ÿãÖ’G.,E£÷qô~æ÷  ]Ì\…Åè}ýŸŸùýý9y‡”,§¸­}jh/lcŠ7øQ†~b$aûÐèƒeªì®ÌJ+è—V½}7•žû’Åm¥—é·ScW8‘ègêÅ€@¢p Z%8þXåÇbN9p[{Y!QS¸¼ÿ0ò“©'Å)ê˜`”h—f#XL    )žmó&ã”5±zþ§<U
 5þïUa'æ”·uHI­Íìîk§ l†J)-é/ûz&H×åö4pØÐ¸´l"é7kh6ÝqÚ"aK€ÿOaíX%þªÂNÌ)?në–TTäø“[**¦ÒÒ#éä¢Es‡Ô°6Õû¬ÿ8ÌmâëM9œé× É~tœÔŽ® Om54J
ªð6X%þ*osÊÛÓ’¶0å­løŠñJk˜)
£íR´í7Œât¹~ZÙÑ}ÆƒAê€|¶ wì?ú‹†¼”aUÖ¦EBà¯òö0§¼=-ia?3x[a¿HµA'Ù@*…2é%šúwØCW»D¯ÚŽ²±Æ–$Ì™oî_¥È£ëó¼â*Ûg0ÆXyôŒUBà¯òö0§¼=-þŸ½°œìá[
ËUë“n&§Ýx·L"ªÙÌVg“ §¾35¨õB›nµ‘Ÿ%u¿D·u~“Ò‘¢>UBà¯òö0§¼=-$·?G7ÙŸu¬c­\Úí$ŠýQ@£ÁËØ21bíMnà©OôBz˜v‡OÖ%€„©âg¬•·‡9åíia)þŸûþS£_¢”<$ðAKÍ·í5.&‡Ž‰NenŒóæ8Ø®E
I Íô‰²•:%Iëƒ‘3	¿ÊÛÃóöàÔÑÀÁñ?ÞÀ¡MrHCñö1lµ¶8\›’ðq0cØœçF³u}¼nÌB½Ñ¸âþÅÑ%ºC)Ž_‹€@_uûeŽÝ~±¬ž7G_RÏÛ¾‘ê£âfÀiu¿ÛÍ{Ûò*4'k-=¦G
Ê¡ ª -7CèÑõ¤_aÇ"ú]×t¥½ƒÉ™ ž¨®½†S×ÞÞNzí-ÄnºöÎwÍdà°™–=áq
üÓÈ!žåÛF23ÚÌò“Á(TÅ¨“¬ä\·‡õlx‰Ž5Cáä·JüU×^Ã©koo'‹Ùæøß³ó—ëñy\D“G6Ž7ŒMeªŽÕ6ÝúÊÛC`›ž÷kéI¢³rÅ¶
ÉÒ6Ä* ÐWEZwÒ~³‹¯ùŸÎ¶ñ?¯>¾ÙÿfzçWˆÁì7ëß_vº·ÊþV¼øª /CþDTŽ(°}*0Ì´ÏõkP£Xg:"·Eå¸Òo÷±é q¡„ç7
búÛ'Ž:‡Ë™ÕÁ¿.ð´BÔ’aðæ‡‚7!	>‹äIÛ8¥g:ÿ'CR¢TþÀ¿)Æ1Ñr¬ÿRDÚH6ë@Ä"¨®ÿ†Sî¯Þ15”\?
ÅÃ-×Ï~\€d{½^/õ²QÍóAdê)Äa{¶o%wÍRÛç£óÄÀû0§ªåˆ@*m`JÎ$þªë¿á”û«w4Rü‘‹AvØ&Zíè*xS3'Ø,‡­h‹õ€™ J‡£Á|©G÷‘zž0/ÄØ 
Ð*!€§çG ¢¬÷W[	~¢®÷ûTp¬Cýsá¢Î–ö~–:¿Öœ-×'CáÇFÐ?ÿoÄÍÑË¨EÁ-ŒÐ- ój22@5½ÐË,
‹VŽã¶–ÅÇÌx¹ÍvF…¢g‹ŽR%Éó,ÝHÇ³Vc,þrõaÆø“³hD¨½¡Äd}A~&!f]eÏþ½L‰í\©-ñáv‚5/3ˆ¥9ëç–‡òrÊ$ù¯Ž‹
=Éæô¾èâùP9ù§HžHd·íÖþ¦écÑ²F.+¶{zvQÎv"ÓÈª]Õûz²Þ>ô§¹š9/fî[üºÆ"ÈKP‘"m•ø«Ü|†S$Ç_êmâ Ä
Þ¦Œ/…š…ÎºÒŽïŽd<nê°“Ï±}aíD–™î1Ÿ_­ÊeßtåŠ"ô]hð£SUŽ´U‚ãO•Þ>§HžHd$C‹ÜBò4ƒ0Õ:ëìb
†Y³˜Ïµed9i
›6ffÔ¡Õ>XÜr€?}AÀ
eT‘¬e•øÕUŸ]œ —{¾mo·íá™×Þžáôéý’µÐ
B¢ÏòÕ“Õ.ê˜Uªþt»U*=A>qt@ÉM‰//ãç‡×`Ö„qEU2†S]Kž¡OöðØ’/µ{¢‘ün]² ÃÌ]c\2‹­X£ÑÃ~gc¶šÕG·þãxáÿø£uJå­ÿè™„À_!c8ÅÐõ¤­çLië9‹‹ Ÿ9§ÑvË0Z•t½Bq6¹_D#Ù%®ÕWùö”LWÕL´\•„f|·‹à<×
J]ôLB ò3Aßå­âr×ºn·>Äáû÷Ýý^ëTf 0,âX?¹
:ÐçêL;Ÿ1¤Ù¿Ÿ‡Óc§Ë=S ñ,*ý¤NåÂ½"	Æ$LÐvQÉµ+‡NvÐiŒ÷FµPYÐ‰Ö©„ö5DÛÓ|l˜ÀíIdêKÂtpa±~bM“†‰Ð3	¿"L
iNñå£ÜˆÝdAc¨5šˆì»J sd±t´dd—Ÿ
©ºé‹.c$eð'Ü>Ö
ƒI-hz&!ðW„I!Í)¾|t†I
³7…Iær4é3½Ð3+¾Ý0š(ûÍƒ]æ ´¹˜u»‘´X¸€§áøë§$„u"
¤g… iNñd£ƒ9”„I
³ð¦:7œ^—ÓÁI©ÝÖ›áLº®ïôn¬º±	¨·Ò…nmÉ›“ª+ô_Áº—RŠ©4^„žIü¤9Å“4YKsX½©e³³ò´³‘Rª±¬‚ä¦²›§j‰YÍlUæµ
ƒþmÅL ó…F± 	Óÿ~ý šˆB3(&ò0Az&Áñ×¤9åAäøÛèþzÃr	Ñ¾C¬“ïU“´;5m¤£Ä„î;ƒ<é4è¡ï[W=é¤0’@©ï¿„â‚¿éBù%Ä*!€¿p¼qr¿·Oqrðïõix{Eã
÷¨÷û[Å¸^¤9åòi÷°%Ëâ¶=°Ö1†…xÌ‚ÕÔ<¼HöS‡FEÛtÛ+/œ1[µH¤±ˆö«%ô=*Á-/Wn |`-©9åòÁÔQâröŽ·ôM
‡óN`Uëmëk¿Ö9¤Ïuæ
ÕúY@†45 .°»ÂkDëe/ ©ËŸžI>XXƒ #ø£Ô±Ê¬KÊ¥uøÞB¹4á²´9¤ÛåVmš¬ñítŸ©Õ¶q’„Ìüð°_£I †öáDäVüÿŒEÍ;ÀmbPMÊ g?ø‘un-o–­¹%Uýôë÷n 
9ƒ§qó?^¿N¿~Ñ+R|#þµ
ŸþÜj,;ü¯óÎr0{+C~±‘øót±~ÿ2ñcµýwtB}HpÂÍñú\bNEuø)OÇ9ûwôFýÖûoãÕzè2ÛŽ‹R‹-@áûBšSÌJs†½›rŠE}Zð¯º3\öáx`•ÞVóãB|©û£€gHûž`cÓsÇ…
R”O[ä µ®]á{±Jü•¾/‡˜‚o'+õÉïC7•úÌ¶ýÃH=½ðxæÆ¸Ó›e~þQFÀ÷/C¾Ún±èí ½}5YqAŠ x"öÞ
 %@ÊÞÓ3	¿Ò÷åïWà/ó}‰Ï7˜R4®±|83<Ž*å`776FfßÉ/ÑÊ˜¢Õ,i\G…|Ð)‚A…yÐT\%¬•ï
8äû-øöÒÇ”¬D…ý*aÐQ6ÉÖg­ý¬ˆŽÛÓd‹i?+§òƒæDgåt-)ñý>nß	—:Jüß%þ*ßpÈ÷Ëñ7e¾wŽï-ú¿/nPÒloj(}lÖö¥ÔºÏtŽ:‡ËJ²©Ù®¢É¸Â÷¡ ×2Ôø[$8þLåûù~
¾ƒý*'ðÏÞt•;»d#Pk5<¾ôl—?´g£Z¹]›$j©ÖbUE¬“dwY¹Â•±ˆcTgHš¬FÏ$þŠ\Aòý
üeÜß1{÷@‘íd$i>’o¬£!jÐgço[Z¤S(—òƒCâÚ´]áÊ€¯ÌÕAJüß%þ*WpÈ÷+RÁe®¤cÝâJŠú³­]íÿgïÝšRçš½ïãµ>Åªëø‘JÆ.‰g*nP7àî„Ü!Š(*BÕûÝßœ0!Ich:ÃŒûºŸZOÝuÍ™þ»Ãÿ›þµEýå,Ø½8ÛßèÉ­³—
±1º	^› ›Gbc¿xûruÝM`,üBüCƒ˜xØ{š}BÇZÊs‰–RÃøWÇŸºLCxñÜ»ÝÛR©ä¹Gò¸sùut~qä¨Ö ÒÝÑùCås‡9¯£ƒœ^Ç?ü`&©Âª¹'tü¡¥<—h)µ¶á&ÞUµRÝUÞl–×zm×;éÝ7å÷N§Qê¾]tjkÕ—ó;¹åU®Ô¶zÞÌÅÙh€Ž/]) ÷æ	¨þu‰êßÚ/'4Ç¤Aš«5å³³+gïÁk•ox'(?:ï%þÌÝÍíâEk¿ß-n¿>¿Úk9h‘£Ï®
Vp”#¼¤ÕTGÍ=¡ãÕ¿.YýË“²‡ñOjÈ¿ÚtúÐf[ÁÆ‹óP}þfiû²è?v.º§Ÿ®ËÞ;oG}Wl\\§½Ú”müuÌ‚à,¹C‘š}@Gª~]²ê—WFIî¿ÃÓœ¼ùðª[›»'W{¯7ÝíÓNu{°yÓ_ó§úºßhïo7/]ïÓ­î”T.NÞèö‹nÁL‹?3èèCµ/#«}EÒýÜjq#á~nüÝ?<úÚ*–oœKvº¶¶ã=
G×WÇ¯—õ³íÚ¥{Ð©¾íÙçþþèí&áÜÇ/¼û¡³ô
ŽäNx?ZÍ=¡ãÕ¾Œ¬öÕëœ	ñßfiâ¾Ö×£çÃ×žï¯÷­öQã¤zrÙƒ`ïìáƒïñööº÷rßÌÅ¹'®ôÊ²ÃÂÒÿß ô&&Tù2ªÊw{to¬Z,¥º7öÚ¸8.Ö›;/{££³÷ç‹Ú{»Ö½>¼m ¢úu'Ïj-U¹z¹î^æ€¬9Ž¾}¥ãNéj	áŸ>¡ãU¾Œªò
ãŸpê&Œÿ(ÍÌûX|íÜ8;çû•r¯Þoß];oýÆ{qsmwpµ½×Ùá£C9ü|:ÍÁ½=W·¾tYA*r>3OèøC•/£ª|· •b|î
ãïÄçÞÙîïêòr·Ù­óOV»ºñë}ïÔ¿¼R¯U^:®Ønã•î›Õ÷‡ùSOaX™[—ºWôôÐì:ðåg$–?´›­Q¥e ´œqàStEn¶ëµMÞö¯žFŸBž]¶nŸZÁÁðñ`íêåtØ=m4Ž®Ë,í…É¬NOx\'ÜBàJé$ht„™'tð!¿ÏHü¾(?–GåÇè¨s? RŒ:ý#¶×ßùÜY»ºû¸ã[ÞÎÚãIíù½üÔm¿ª    Íùª†ÚPÛI÷ŽV9º²Ü›ïë£+at^`*ðÚûúèÊì:øÝg$v_ ß‰/6èà—S-6Œ6Eñ°üÔ~–ÁçågýþâôècsÍ»ž2Õ“â¦È^Î>›êy§žvÊÍ0øB¯#§d|¾ýþÌ:øÛç$n_ Ÿ—c+Í:ø—£4+ÍµúÑ¨S>mÖºgow‡í·jgkãèdû¡ÏßßªýëÊ ÑTþçeÚ•†ƒÿ}‹Ô“Ì/3 æ	|Èês«ÿxX®%;µí¯4ÃÎ¹ÕnîÊ_£ÁIéõpÄ_Ä¨¿¶+Z÷»w§¯Õwÿk³õæ>¾÷Ü´ÛŒÙ_ûHVP~àð¸Ó ö‰ÿu] rúœÄéëàÊ±UüÐi¦vžš·¯äî{ìõ©y=j(¹ë<Ååõë÷¯*×¯×ž¸å´N3Ãàûz "|µàÏ<¡ƒÙ|NbóuðpˆI~ÙIÓƒ}k§:h†eòážS?{S­>w÷ÜãÍöÝÖ•W½mÖî:¾úºwXÚE†ì‚/œu¡ÂãAÂõêqðgŸÐÁ‡<>'ñøaðë£J·ÿ±ä&XÍøAÝMqûºv}Sº,ödíöýîèiÀkAñËñüa»2Üî–[_g
UM°ú†ƒ/¥f›xžñSÒãàÏ>¡ƒmmq’­-|7¾µ®ƒŸnký¼å^ïlv+ÝÁîvÿno³Ôòœâý…ê¼µ×N:µ¡êŒÖ×½ùûo¾ô®¹PŽrãûêßÁŸyB Ú×â$ûZ:ø¬\‹žëÑÁ¯¥9×óÞ®ïß~µnO¥S¾=»¬÷6›ŸÃ×Í]ß—[O7ÇÍÎ»{ZÚ}">¢¾tðåú˜Ý^ð¹ë'´,óÿ9sOèàC.'©pÃà_Êj’ÛÝË4nçfó°[ßzÙfOÏ¥Û£‹Ý½§æñÅf¿Q~u½òÅÇãSÀ+ò¬]üí"kÖW¦¤Ÿ´ª<þì:øP…Ë©*Ü‹¯kÞÃÂ+i]3¶¼pÖ:ÚÚy
ºæöÅ@í¼«×§
yx÷Z¹)·¯^ïø´{ÊOöî i¡3ÙŸs½YÎÃÐ²øvú8ø³OèàC.§ªpï •QÜíT‹ž†¸tv¬/?·‹_—wÍ»ò~icïstw¶÷Zß{¹Ø{z9ñÝÆÅûÙ}Úã´Ù_Œ»ÍI}I?Ž» ö	|¨ÂDîèXVcg™ïòã¶H>Ë¬'è°*îð±ÏßÚù*õÎYÇ+ÏÍÝJuó¼rØàwç;Ÿýz©qQz>dwå·ã'ÿç…MÏ+0.ÂHÝ±j©xºŽÒ8C'PâÏØãÏe€Í=¡3 •¹‚¨ÌuÂ?žÊh[¦9M.v½Ê]ëëkxýÐxØ|óŽwkû­+ñ1>öžºÞ¦rö:§ü-©Qèjû¹Ë|íidPðX8oÆ‰aüùÜaü]¨Ò4•n¥¸‘°§¢ãŸnOe³Ø
F'›£»ûJsçåö¸ÛéŸ?Ý=x^õl£Üi°·ƒ×ëÚÉÍ=9ðjùø ëcæasW²øÜèvb³OèøCÅ® )vÃø*1à›ŽèFStRø<¼9)y­ægqó±yâó×žqðæ~wçø¨¾»´‡·¯þ¥·3$¿MŠ¿/3é»ñN
ßñŸyBÇªwM½«1æåQÌû„ñ¿¥)¹N/Ï‡âþåÙÙêo®‰µµýò×õÝËëÕÅÚûùÎ>Û|üÍÏ¶<"?M…Š¿Þ`)ÈpzuâËœßñŸyBÇ*yMÉÆ_†ÿ‹UãÍSŒÿWeOìmô¼ûQËÿ(+/8c‡ÖõæÕëÙýUùŽn·¯Gåîn°ŸpšÖüû¯í¿,„¶^%gÆñŸ}BÇªzMÕ;ŽìDÏ8þ£„%ñÛ\ÏÂÙ½Ù9ÿÜ?n÷UùŠïÕýûÃû@5^K;rçª»2”õ‹ ô+ñç~øÁÂuã»‹“øOŸã/çk¯IC
5¾IÙÐÂ¯éÚC®»NÁ—<±Å ;áWwg~Z¿8PÅ.h*öJø‚Tb¤4ýâÔyš47­¯“×çÖZÿ±¾ï—Ÿ?ÞFÝ½ûíáÇÞÑ­:<¿ÝïmœoÉc^œÐK/´e.O¸†6~qfŸÐñ‡ŠvAS´‡ñwâ}0uü/ú`Æ¿¸¿tûúþÞvŽvkkOêíú³]ºkµ/ïºÍë›“âmekèž¿_ƒEÅŸkÚ|qgŸÐñ‡êvAS·‡ñçI¥cøg	¥ã,«Nn‰K¯×Mïêb·[/UïNG7g£·óàDmU^Ïëµúc½yÓMØZí0*ð¾ÝªTxñÃ0ßŸyB ÞO1¿»çÓŽ˜zoJw*xžË–i4þ½gTÿÞP¥+iÖÂ&üòÅvV}¦6ÍÎJ½þtúrtûþzqÖ¿[Ûi<•÷ö/+â™ß¬<WŠÎãyë¼|WÙÌ…Óäúêt!Pa¡ß\™ÄúDUº’f¥aÿøú¾3>S»¨qp÷vûêÓûz½½Ùl67ª/ò»û/½—£ëµÎÛám·ÑóNî_Þ>k	Lyó_X®Ï-‡ÿ€ffƒ/þô	xw¾qp¾°ÿoQ÷‹ïÏaëÌÓŸ#¼¿äŠÈ@¿;ÅÒ0£@§a¾Òùô„…æŽ4®?Þ— @gÓPå;~aÅ#
cB
ßˆä6&üfë£y{Ú{¸}[ª“‰“üÝ˜ùetR òWR-¿…}RùU+'•_±I¡å”Öv¯öö}ïexwÿþð¶}|²©‚ÍÛú•ÓëlnÖ[|üH3jlWÜ	ÛŽ“ðOÐÑ‡Š_IµøVJh%0Ž~R+˜‡¾>U·[Ûn«]>Ý©otœ=î}¾VÝËÝÝË³GùQ~~?9Û{’Á>9í}édX¢Ä×ž'ÑŸ< £U’jé­ôUŸóÑÑ
iÏühpÚ¹øxm^õÅ½¼¾¾}s‡§;'ýp‚®¼lž\n¿4NNÏJÇ_˜õÝã¾˜àncƒÎÌ:ðØßÂLðc+µÄ© l¯õý´§Ixß×ƒÍKRÂV˜PþC’•ói;öõùûèoTøKªëÒ°ëÿ£‡­c'Í9!g÷¨ì
¶šìòX5Ë5wxî_{}Yl±çãþM÷~PÈàÕÏÅÂ—¾ê"
Ì÷…?•>	ÿô	hÏ^R­X—œr-¾cV­]~¥Ù1sÜ·—þÖÐÛ¾ÕŸ?øËžß;îu÷^×d³T»õ÷KƒÞÎèãðê*áJ€ùI[8cv¤
'~fbÿÙ'tüÁuª…ßRë„…_}
;ÅÂïÎÃ™è\oß³›»^ç¬>Üjœ•îžª/Ïý­­“fóhÐ9Q‡,;ÆBß +È€'¾ã?óD®cP-ü–ÜrÒÂc­5X¸ðø&ÏX“¿¾n\zß­ö.¶ŸîÎz'—µ‡»Aí~0¸Þ(=7vÈÉÈÀë¶zÊç	 ¤Ià§OèÀ»ó¶	¨úÓ1’ùÒeÿb¯"Ø„¿&-&ÙôzÈòÉ|…'ö^ÌÄZ¿,yAÚÏd5HŒ»²ª€{®ZrAzöGõï
®=Pí`”D¼‘ê}8¸l¤j¤Úy´w>ÅÍÚùÚýþV³¹Ù8®ß°­÷àpûþ­SlyÇîñévÇõÊ¹8z"<=ZðÀ	y~Çæ	hõAQm”ÃÉ1fdÂø—‡iŒÌ{ùõÜ}zö¼âö…{ñÚc%u}~È{•µý³ÎZ÷¼Ø9o|Š¾±‘‹<9¾9ê3$œ¼Çö	™ü½
ßÛ`Ñ÷VÕÜñ—O¸“•àX”r  >=iÌ›>&—U„_aŽÆ÷%8´­¨öSÊ£x'ýúÖ“:ñÄû 5Ý›·÷«@îuÏ¯Nwz¢sóT”n§qÒ>iª‹ýîÁæC¹ºuÜÈE$53DW9ARáûõyBÇªCÕÒqyT×¡:þ"¡
Û‡O®ÿ6Ø?;u:¥RÇòÛbûó Ëß[îC«7|»¹8f•òà3í©ý¬ã¯—dàMúpÆ†™'tü¡:TQ-‡ñ¯Å–îuüåBiïèî@öë·]U_««Þk±wùu»Ù|(ïÜù
g«9’Å×#yu› Žì¸îï¨’}Ëì:ðPª¨ÖËn5Ö†D ¾%R]Î}þZ}5ÎOÞ['òuÓý¸k¾Ý¶îÚ¥½×Ï­ÖÚvã}øµýuó±—‹TêR(œ‡G6gŸã/ TQ-€•ÃX&<º5[Š0÷ùöú³ÚÜï¾½‰öÖÅËnc³ØjÈîaÙ}xü8Ú,ÉÃã÷ÏÝÄ#Ë†ã¯oÂ	½[îq/P‰¿;÷„Ž?td\Q-€•Ôãø§‚O¾×ë'å›Ûªlm¿¶ú»»{½·›ÃÓýÖEõèì´}úQU#t7_=ò¨ÈøëÛç®ô®LLâ?}BÇ:2®¨ÀÊ2Þ€VÇ;©mìý¿¾n\žoŸî_î—{¥Ý¡<¯¿<ožß|Ýl¾TŽùqñæCõÖJ›äMðPñ·—åBú~¼äwügžÐñ‡êVEµ v<H8²Æ¿”êÈ~pTÕƒæ—wRþ(?7«û—;%v±- Ãf½öâît ¯ â™¼	*þãùŒ9	]a¾Ãÿ÷}°j¥Z58NÀŒ£Ÿ
ÿ!öUñcgmãâàîµr0ðëóç­†Ø¸8. §Ï¯ŸÛ'rã8,`rô'2úLÿ¤¯$4úÌ<¡ãíš{T«aüã&tüYüíŸ±5ÑÿØ¿­5{Å§ö?é>Üô½Òsõ«ûÖ¬”äV©\ÕN®åïcû¼ÿé
å&ÙNwî	xà¤¾C¿Ì§½`|xQ(á/µÊçÎþ¤þ­¡*Ñ£ªÒ¿«ôZ9U•þzzþ~uÞpÏÎ5o{çºw¹Ý8}ßÚ¹o]²›ƒ¡8þ:ø¬­‰°NÏÅ`ŒYA8%ÞïsçžÐñ‡ªDªJ?þªùje‘f‘ïäîªÔåkWÞöù©øÜ¾î„ÅáÝ1wz'_âüþâeÿmPvÛ´­û²Ž¿àáË?ñ~“;÷„Ž?T,zTUzÿZì‘Ž¿\xÈHÔŸûAm´vyü|zÑ{å=us=l_¼?½­‹Ãjñ¬q~ãÕF7<ábÙ/—ºP/’KžX¥»sOè‹MNânYt¸L·[¶ôx¹`³,|XÃaÃ_ÕçŽÄœìùÿr3üGs0+Lç ª=ª•’c§ZŒmÕ»z€I³UzYºªž­µž¯Ëû×ÞAññt´[Þ?Þ»þ,Ý¼7êû×ÃÊ( þŽùè~Z^Áu\® «<û„Ž?T)zT+%õa5ÞLK“ eüÊÇÌàó¸u×’¯û îÑ×¡{8¨­í^¾yŸçµ§zÏ    »^+–ÚW½Íþõ(á® nðaŽS`"|‚\wÉÀ3__<ô˜*ñŽ;÷„<T"zTK$º‹YÂÚìcÝMu«õ´¹³¶s¸¿µuèÝ³Ã^°ÍZ7»[ìã²Ñ©ŸlÕ^?ÝÝªÿ8<H`äáfÝ•â¬»~!Ï®†Î>¡ã‰ÕIÝ)'Æÿò+Í±ö×no÷`t}}(øÚé}§Ü}y*ï>5v‚úáS­ýö<x<mVN:—>#o•øsGG—‰pX–HfŸÐñ ‹Dª%’zÏ¤øß;©Þÿ õq68;åµqqxß/¯]|òaë\^\ú¬¿Vé÷>ïNßw»½„%róï?hý€ñä[õîÜ:þ`ÕEµH¢‘ç	KäQš½¹Ñ}ÑqÛ»í“¯—¯Ã‹§Jézä:{B;lt´vòRn×wF‡©vg9¾P&Î€E’Ù'tü¡ªË§Z$©ó8'cÿTœŒêÃóöÓ±ã…Ÿ&ùÇ¨x~uûòº½5|Ûl~~}ƒu~·}³vÓ“d×jVŠÿƒáé¶Ð‰—ÓÝ¹'tü¡ªË§Zu¨ËÊcBÕ5Úfišš‰ZícëáîéÄßëV_ÏÍ»jõšÍÎY£#‚ç²Ó¹kô‹_£„µª_xÿ}#àÒc‰{ÓîÜaü´EçS­:\ãŒ*ÿãTŒªƒbÉ}i*>ÚW'{ïOg·ÃóŽx®~:;Ý»·‹£½‡»»ÑkµúDÆè\%þ"ÝYA2%4rÇö	¨ðò©V.“úG‡ñ¯§ê}t±ÓÛvØìø·‡•îÇùŽsôZY»(^ºÛ íË·QM¯ü“ó^.Æ!õšš’LA[¤³OèøC…—OUø^º	gÔÃø·RQ?<Ú{=Ú{llÈêùk¹ì;u)›âaÃyåW}§u}x¥6wïïwÉ¶èVŠ [0O2–xFÝ{BÇª¿|ªÂ÷’%tõ
ãŸÔÕ/ÿÊþ­¬›Å³ÆÚÝå®ws~ä>¼³‹Ð÷¼o
Ywkoí¶~wÕ¾fdŒòUâ/õ _ðUhï÷ö	¨þò©êßËð“âß¦‰Ë?ÙeÝãòíè¤Ëo‡Ç'Oêªæ?”+÷íûþÞéÍËy‘wîÝ¯û\Œ?úà¨&Ð:ÂVýgŸÐñ‡ê/Ÿªþ½	]]Ýí/Íü[+žÞöGÏOŸí«»úðîíE
÷:Cq±sWý8íŠboÔ¿99«vÉv]VŠ?×t†@p7óÿ™'tü¡³©>Uý{)šêêø'5ÕÅ¿÷ùpÌo¿jÍâíµÿþÄoNû×­óÃç=ö´Ý+úÝíþPmì\>’X)þ¡QðœÐ>Æ{©Çæ	¨þõ©êßKYNXø¬·¿ÒôºÙWGÞ§xiß­]Ü‰³îgyøR>e×Ÿoüt_Þ_¼°ÇJUm]¹ùxÿ¥>ùë8‚CGdfŸÐñ‡êß€ªþm…±Žï:†î¤!÷tz'­Ë~³|¸/nK¯w§ÛÇ½ç•ƒÃ7÷öý®q¶Ö«^_^µï~ÿˆ$s×©÷9wdøþ³¹'tü¡ú7 ªCŸ™°þY©m'­?ÇÍj¯ÑÞÆh´ãÞ•ê½²ó1¼QïÕæyål£¾yððÑÙ]«?æ`ãe¼­Åý‚ðÇMœÙÜaü=¨þ
¨êß–L:›Æ?álvHcë¨ê_žœnœ8Û.Þntö«_ÛÍR¯Y<¾ènžŸÈóÏã³»³„Íß_ˆ?¯î»¾ûª°¹'tü¡ú7 ªï 	Ì¼0þ‰Ì¼ØúÏËõëÞ}í¡µsqòôz³÷Þ{÷·7ûŸï÷wÅêS³r$: û÷^çÊûý®¢ßñÌ
$ÞÑfsOèøCõo@Tÿêžfñ¶BúØ|§yfãqôru¼?zÙŸn[•ýËÃ¦,=Ÿ¼ Î“ßýzJêtÐr®ƒ‹pjI¹ñøM@êíX'üÿªÀ¾7ûSÇ=ÕÙºô
žË'W³ç·ùì:êPÕU½údVèVõv{Š£‘ÁÎ­ß¿z{¸n~îö¶ØÞs¯»§^×ž6zþW«|úu¶Á»'kŸí!9›|ù·žé=]G¤ç9Nâª?Ÿ{BÇªz¢ª·V
]gÒªÛýWšU·Qãã½Úw”ò*ÕáÝQ¿æ9Ã²[yéž›[£/¹!†ÃÛûóËíË„
ò&!2Ó 5"Æ‘|Ï=¡ƒ•¼QÉ;tÌr²J­• ‹œr^o¶ê ƒÁ£XÛÿüØ
6^zG\4wö?Ü“Ýó3oX¹nµ^÷Þz£g‚šî>Æ@2Ž&‰ ­äÜ:ðP­ÐÔºÕZ'¡mgPkà4k=·ÏCÙ÷§ÕÝ—Ç“‡Ë·fõü˜°=µw2¼ðQí£Wê³ý{bJ§»Ô[ÔÜñ6gGr?±‡«æžø_×l´ôno¾o|JÿgÚžGÁxÈcc8J žG3ºÿ|üu·?Ÿé‡ùÓ×ˆÿù›ïîMýÆëÇm_«ýóBGÿzüO\÷Û÷ÏÓH,>ØF~7ýÚA%~@RâËrq;a‰%|í[©¸Eo‡ìóá~øzõ±ÕÛ×¯³·vÐ-=íîÜŒ¶ßªõÊ`»óÜ¨¦·dõÚ…îÍÕîY0é'öàÑÔê™'tðú^8$õ½~XßD [ü{¹p°½»å­áKðyyÒ¯]–ž¼µ‡b¿X/_4¯øÖ‘½¯æðônÐÛN(,1þn•¨s}¯Å•~øÿFZõ™'tÔª^8$U}uÝ0#ºªF}ÔbIöÊ(ikõaeÔ´êxóþâ³(w¿6ÙÝËŽººÎwƒ²(W; _{O/£Š/N®®Ž×:	«êÒlð™§
–€1Æÿ¼ò2üÙ'Âàû@I/’’^ê®IÓÜ¸­s
s(ÕÓkñÒ¾>y(vöj‡{o§ÝáÙ°wôÙ<WuõxzÕ_»K{¤ »àóñ…ÆÀ—H:O 9^3Oèàõ¼pHêy|_OÑÁOºëžpžo»ÑX´?¯ööË÷‡þaPy¯—ºür{ã]õÛ_ÃòÑAåsïý¸v›v==»àë®RNAß*r’ÃàÏ>¡ƒÏ"c2\ªñT;{¾Àbèçã#âAà"Éb¸ÌQÂó=.ÿùóñ7íÐôÿ:ˆ?üþv}w×n5žÚ÷ïý¿ï±þ»ðãžº!äíÔ~ü£¡&…ñü¤Ÿè~<7õ‡¼¼‡OÎ<Ã&ýyûv}ÿ”pL˜|Èóõ×ŸOˆ=å‹¿ÿÖ«#’0# $Àû•°	à
Ž§?&Àå?% ¬=øÏ	Œ0H€ÿ+	àèo€'S|ÔÏß ßÿ9®C÷ð# šfêõ[uŽX\çDÿYçø*:úN•{9­ð<*åÑaoªÜÏiÎÉ”GÇ›©ò ŸÊ•p	÷œ|¾ìD«~äÀÈŒp7Ÿ'Þ<H8ËgÆ}*á>$œç3ã®C¥<€”‹|*ˆ„{Ðb­÷k‹µ?¤Ü¥RÙ7/¯öj™:ˆì“Ò!@•J·âæ*¬Ìé‹g±¸tð(Šg^P“¢5³ây&F:Ñ	f²äåüJÏ‹ šâÙK‘€ÕŠçH¢Ý$î¯$`Qñ¼xõbö­ÄÏéV/V,žç2à{P	éåµ„¤ª'<¨„ôòZBRùj*!½_+!¨¤¨J)ª!ý_«!ç\R	‡jH?§5¤K¦*"ýœ‘®¢RU‘~N«HFö5‡ªHÿ×ªÈrNõ¶ûPéç´ŒddÊ¡2Òÿµ2ò‡œS	‡œÿkî‡”S9¸ØÞçTy^ÕÐÛtœ*Ïë& ÕÐîC.Èé. £Úøñ!
äÔÂÑ
í…
rjáèF8ÈÂyµpdo;dá‚_³pÑ¤FjTªœ …
~ÍÂ-VN5©ƒ
~ÍÁ-Nõ® ƒ
~ÍÁ-îRmtƒ
~ÍÁý œj¿/€\ðkn±rF´ÅËpb‘M¶?–[ó473G¨ÄvÉîzù>Å®—(L·û2Ûõš‰‘N pbqº÷`6ø]/Irdt&²™ízE­a&	¿’€E»^‹ o/“l{ýYÊrÛk.¡—J~ç×ÊÈ†_ªå¢Ø¡ƒ©ò_+#PNµíÛíŸ*ÿµ2ò ådÎ(#ç×ÊÈ”“L Œœœ–‘ŒÈ`†¤<§e$§1˜BF°6S†~×Ó0þ<ñ—†ÁÑ0\Vs¹PJYð}ïû6}4.‰0$—…%ÔìOê|Õoàä´úåD3R8üBÊsZþR-õ„Ã/¤<§å/ÑŠG8úBÂsZýR­x„£/ ÜÍ©ñ¤ZñÇ1Hy^'ÑŠG8ŽAÊój<É†vÈxºy5žDÅF8AÊój<‰Šp ƒ”çÔxRá@)Ï©…#+6\ÈÂ¹yµpTc»
Y87§ŽÈ¶3Çf5×A¾îjÝU+è»‰\Áßt¯3¿šVÌj¡rÜëž¹òìkD:0­…Òqï{öÒñcÜ¼tÌk¡t\Ñ’¹ôlD:0±¹ÃU-ÙKÇr³Ò]&£YŸìÕLv,–Ú«‘r]ˆ‚ë9,Q÷7+çB¤Ã}ó&áGõZ5üÿ‚­ÊHøöNÕ]hÕðÿ+6*gþ
`¬Ã‘·j’ýÈ‹¯ #“à¬Cé¸e“ì¥ãKèˆt`y4”Ž[7É^:•ÁŒø+·p’½t2ƒ	,†Òq+'™K_¡ŠŽH kI–ÓZr…2:",&YN‹É¶¿"ÒÁb’å´˜¤YARÌ+ŸnQë!nÙ-jwA\ôµX×Ûƒ‚ò•›ØÜ¢fR¯u  ½åÍø÷r’Ïõx¸sÍe1DÒì3tƒá«Cà’Û4F:ÀÁAoy;N‘€ú•¤h“¦_‰b?' e9”.@ÇoùfŸ	XT¹
 Iê!·¤H@Úz(MX¬ýá¤"E´[õõøÆDø9ÒQä
2‹3ÀR¬ü<…YŠŠt…™ùé@‡—M«°hZœ —SŒAnÖK2ñ cG4­"H ~b$
‡Bb^eM&’æpp'€åt'€lÿ‡ƒ;<§;dû?\Šãy]Š£*Ï9¸ÇóºGUžsp)Žçu)Žj–ƒKq<¯KqT
°\Šã9]Š#[€åàRÏéRÙ, —âx^—âÈFxp)Žçt)ŽlV ÷‘ýåoc²1¾Èñ
‚+ß£÷Óÿ›œ‘(…%
ŒŒ#AËr±þUEá´Aåqƒ§Ó>ßœ“—»ÝífåãªÓëöû{îÍó“ìo}Üì½ìœ4ž¿êÝ~ ŽNFùYšŒ²îzÅ]®‚$~–?÷„>HŽ#!ëàËÅ89®ò¸=H ÇÅøYÅ
¿äíc®î{ÞQ]uÕÉ'Ûº    svFGw»Ÿ‡/§Ý‹Ï÷£Í£Cy¾Q~Ö8ø‚D ¨Iü,î‰0ø±~}os£Û²Å|°Îœ‚0•¼ øßóEó1Ò	 qD7
‚üÇŸ0Š' 8bÄÝ(ðŸ?ýFS ["@æO V6ôìî¸`A Ó$aù6c*ÅF,ì<&¿›–V;µ²a@zŠB/t°Ú¨•
ÒSz)¤»tu!@žäfëR…†J9ÒÃ;‹•óU®¥M7­º‡<È¹òUîfÍ	‡îã!ÏQ_ÜCr•«Y³Â¡k
òeæ_‰%5§ºŽ‡<D™½òU®fÍ)‡®ã!ÏPf¯|•Ž
3ÊY¬­ÞÛÜ º¤›dBßxãœ¹É'§þ[OÍÇH' 8À÷eð/¨§¢	€Ž  nÌ$à_QOÍ§ €n.ÈsÜ™{•ˆvsÔ×yŒ;û‰‡ÊXC÷ä)îìs¾J/Ÿ9åP_ä!îìsN¦*#‘Ç€2WNä²èÎB€<”ùËN6¾AU$òPæ§Þ #oò Pæ§Z7€¼Èã?ö”ÏÐy· yú'såT+&Ði· yöÇšuk×5©÷Kœõðÿ\Qà¶Åÿ­ž“¦çc¤_&	@Ü/!HÀzõO@¬yÙ$Ëßn HÀ~õKA ¸
ç³~©Ü%tà6@?Ì¾†¤*( ó¶òô¡=ëÐqÛ€ÿZ
™!‹yN9TDŠœnE®‚³›‘¸Ó^v*åª"q‡-p«4ES•‘¸³–Š¨¾æ*#Å¯•‘²˜ç”Cu¤Èi¹°sN9dáÄ¯Y¸ìXÌ³tlã}ryù»¹¡+æÎºÔg…}%S¨ú7Ð³1Ò	 .sˆåÏSS$à_P@G ÀËŸ§¦HÀ¿¢€Ž¦ 8‚!–?Q~¸Pë®?Üõù{–	˜‘N pC n”$à_0E-ª'	XþEþƒÐ|
B
YÀ_[ËúÁüR­eA·)‘×µ,²"ZËy=AVäBkY2§ "Õ-fÉœ.f‘¹±ÎðSå9]Ì"ábMÙ§Êóº˜Eõ¶Çú¡O•ÿÚbV†¨Â9åÐb–üµÅ¬ÅÊ©&5	­eÉ_[ËÊŽÑ8'rpò×\†ŒÆÙU¼ØÍ¤|@ô¹
Ksgù%5˜ö¿trñ0£0±}¢IPçVNÀ¿ €Ž& èŠ PçVNÀ¿¢€Ž¦ ÚJ@D’lÝa©”p¹rÿ„æc¤ l%HÔ^ÎÊ	ø7B‘ [	µ—³rþƒP$€ äbEçûÓõF…”É EDŠz V>ùÝ´r`ûˆ#ÊS<é”«xÜG¬èQŽlW¬âq±¢cD9²L\9°ŠÇ}ÄŠŽåÈV01åÐ*÷+:&”{)î÷¤S¬âq±¢cDyŠS:é”«xÜG,éQN5«A«xÜG¬éQžbµ>r`ûˆ]9»”CÎÏ©‡#ûšC.È©…#9¸ §ŽL8dà‚¼8*Ó.!äÕÀQ™v¸ §ŽÌ´+ÈÀ95pd¦]A.È«£2í
2pA^
ÕØ¿M•çÕÀQ™öqmª<§N‘åppÂÉ©ƒóR(K§°pÂÉ©…óR\ˆM§ðpÂÉ©‡#{Ù
'œœZ8ŸJ¹ X¸oüG•}Í…Œ¬>N9ÐÚÀ-É÷û‘íª‚rÂ¢ q
l1zú£:c€õNN­§O50{€õN^­'ÕÀìÖS89µždÃà<…“SçéSUà<…“SçI7%AÎÓÍ©óô©–‹=Èyº9užtC;ä<Ýœ:OºœCÖÓÍ«õ¤ábü­©òœZÏ€L9dáÜœZ8ª¡=œš
Ï©ƒST_srpnNœGµ=âCÎÍ©…ó¨¶G|ÈÂaPGF”Smø…Ã ŽŒ(§Úñ!
‡a™Î©–Ê}ÈÂa`GF”SUç>dá0°##Ê©Þö ²pØ‘åT#\ Y8gÄˆrªY-€<†3bD9•“	 ‡áŒXU°ÄÐ^Så9õpd¾=ÆÔš*Ï«‡#Û!‡Xå^ÈÃaH#VÕjäá0¨«jµ òpÖˆM¾]8‡Ã°FlòíÂ<6b“oäá0}þmòíÂ<¦Ï¿M¾]8‡Ãôù·É·
 hÊ)Q}Q¥\ç²àK©ÄÁ´Pfb¤ 4å”¨®¨+'àßp?’  )§DuE]9ÿŽëü‘€ÖWH†Ÿ®
^g–ª¥‚Ñëü3¿›VYklÄˆrüÄ3¯<F´š*Ç’Ù+Ç›ˆrÈZch#F”ã
fD9d­1´#ÊñEED9d­1´ÊW¸QYkmÄˆrüŽˆrhyC1¢œjVs¡åQL“m#ÊñKâåÐò(¦É¶]Ê!‡i²mB9Ù×²p˜Û6	gƒÃ´Ø¶J8dà0¶­2í1ŽÔTy^
•iœ¦ÊsjàÈL{Œœ4UžSGfÚcÀ¢©ò¼8*Ó#M•çÕÀ‘í“y5pT¦ANæÔÀ­p?¢rp*§n…{¾óÊ9dáTN-Ü
·Fg•‡s×¼‡›ÞpÖ#û²7œå‚ÀLo8³  <)Üå/8O~Rç
rž*§Î“ê+Ê!ã©rj<W¸ñQO•SãI78AÆSåÔx®pã3¢2ž*¯Æ“fX•CÆSåÔx’}Í!ß©rê;W¸êQùN•SßI7´C¾ÓË©ï\áb÷¼òHgª<§¾“lhl¦ÊsêàèrY8/¯Žj„‹[¦ÊsjáV¸QY8/§Žjh‡ %ÂË©ƒ[áRPD9äà¼œ:¸.ˆD”CÎË©…[á‚HD9dá8žì•SmŽ@€Äñd¯œjs”$Ž'ûéœj¡”$Ž'{åTÕ9(HOöÊÉÞvÈÂ!q<Ù+§á @‰@âx²WN5«A€Äñd¯œÊÉ@„ÄñØS°@ˆÄñØãÛ!F‰@âx,r2‡Còxìq¯£D <öÔj£D ‰<öÔj£D ‰<öøvˆQ"D{|;Ä(H"=¾b”$‘Çß2JD{|;È(Ayìñí1FÉä*óäBïÂÝuÇ_çNÁÌeÜôeþwÉ¾ÌÏ
AŠ»ä+\æŸ‘N@ÔJN ~%‹.ó³…	àœâ2?+L/Ñgs™?–€²e’ ïW°è2ÿâHAq—?Œ¬ÿsV¹ËÏ è¬uääÓÏWLåë.ÿüï¦•ÎZb¨`F”#ç¸rÀYKÌˆr¤×ˆ+ œµÄPÁŒ(GúË¸rÀYKÌˆrdMW8k‰Á‚™PŽ½W8k‰ÁkQŽ<ÏW¬ŽJ^Ëˆr²Y
X•¼–åÈñ˜rˆÁ"1|-»”NbøZ&”S}Í!‹Äàµ¬98]Ë*áÃÀµ¬2íEbàZVYWˆÀ"1p-«D`‘¸–U…D`‘º–Uå
D`‘ºòèàM³ùSX$†®eD9Í'dä Þôv³Îø²·›Õ‚ÀLo7
^p<ßUþò×›§?ª3OÌHÆ¨Æ'ˆ#1T0#Ê©|DŽ‘*˜åÈmù¸rÈ{b¨`F”S-*@ä‰¡‚™PŽ=lWyOÌˆr*×
‘c$†
F£<ú:Ó6‹+‡¼'†
fD9Ù¬yOÌ„rìqÚ¨r	‘c$†
F£<z…™æu\9äá0T0Ê©ê
	‘c$†
fD9ÑØ.!rŒÄPÁL|Ï©|»„È1C3’s"÷*cä˜©ò_óp?('šÏeÙ2Uþkî‡ùœì{y8ÌDÎ©|»„%C3ò¶ÕjB”HÌ„r¢­!	J$
f•…ƒ%Ãã1ò²#ÛóÄ•CÃã1¢œ,ç…ÃðxŒ(§*Õ B‰ÄðxŒ˜W²²pådo;dá0<ÊÉR98ŽÇˆw¥ªW @‰ÄàxìšÔ  ‡ÁñqíTÊ!D‰ÄàxŒäœê{1J$ÇcÕ÷b”HÇÈ
ÙÛY8Ç„r²—rp ‘m2åƒÃ yl:‘/!D‰Ä yŒLjT
2¢Db€<F”S-¼Bˆ‰ò˜PN¶!J$Èc$çT,¢Db€<&F8²u‰ìcr—yr¥w)á®³îª‚ãså'2Hœ€;®ò} nóOþ.ù.3#¹Íïœ\ò”·ùÙ8,’€ÙéDä$Á¯$`ÑmþÅ	pInó»?dõÛüé5´“s¬Î¯$`ÑmþÅý,’Ûü¼ ØÏ	H{›?]@g*#¿?=ð}/ðÒ¤`ù’‚§(#)ÿþÝ´rÈYc `&”§ØãM'2Ö&˜	á)¶xÓ	‡|5®eB¸›b5<rÈWcèZF”§¨"Ó)‡|5†®eDyŠ*2•rÁ"1t-#ÊS,“¥S-bèZF”SÍi‚EbèZF”§¨"Ó)‡–F1x-»”Cƒ×2¡œl€ƒ†®eÄºR	‡®eB8Ùð8[Ë&ËñW$­e“e‡ð+CÖ²Ê²Cø‰!kYdÙ…Œ 8¦w›õ—iÙ»ÍÞ‚ÀLï6K¿þÓn¸^¼ønóôGuÆ Û‰A‚YUj@Ø‰A‚YUj@Ø‰A‚YUj@Ø‰A‚q_d9‡|'	fByŠýªtÂ!ß‰!‚yÙÉ”CÆC3¢<ÅŽ|:åóÄÁŒT—d_sÈzbˆ`V½í5Fbˆ`FrN¦²p"˜Ußsˆ#1D0#Ê©„C3ò²S¹v#1@0«†v#1@0#Ê©‹!hŒÄ ÁìÚ!
‡‚Ùõ=‡,f×ÛY8ÌHJ•ó&eªü×,Ü æ©„CÃ£þÃ9Z*áÃàÀh„ÿÐà™js„“`p`F”SíŽ€pŠ'{åŒjw‚“(ŠÇ€rªz‚“(ŠÇ€rªgN¢p(ÊÉ&5ÀÁ)ŠÇ€r²±pp
‡â1 œjl‡à$
‡âÉ^9§Û!8‰Â¡x(§Û!:‰Â¡x(§ªW <‰Â¡x²WNeÛ!<‰Â‘x,²ížDáP<ÙvO¢p,‹l;„'Q8E¶Â“(ŒÇ"ó
áIÆcQÁáIÆc‘m‡0
 ã±È¶C˜…ƒñXdÛ!Ì‡ÂÁx,²í1ÌÇäÄêäÒörÂùºô41Çqåïñ	˜‰‘N@ÔJNÀ~%‹îñ/†Âó€â?7p?’€¨£$€ÿJð÷ø]Ç¡¹È    ï§ø
¬x‘?’ÐZã
Éñ§‡CœäAî†ß™ßM+‡¬5Ž¬e@9~Ê(‡¬5Ž¬•½òlÖœrÑWŽ¬e@9ÞZG”CÖGÖ2 _HF”CÖGÖ2 _HF”CÖGÖ2 œhlW}EáÈZ”í
¢¯(Y+{å+,F”CË£8²–ådc;äápd­ì•ãwA"Â!
‡k°pø¯ˆrÈÂáÀZöØvÑW¬emÑ«“Ó
ÎúK¾ìgA`þ\pÖ}'
¾âL\H[tÁyæGuÆ ë‰‚YTn@Ô…‚Yd=!jŒÂÁ,*7 jŒÂÁ,*1!jŒÂÁ,2Ý5Fáˆ`Z6Fáˆ`•6Fáˆ`•6Fáˆ`ö”5Fá€`Ù
§šÓ hŒÂñÀ,ª³ hŒÂñÀ(”/¾´Â%¸ˆrÈÁá€`”“årp8 ˜åøË®åƒÃÁlzÛ! ‡‚PŽ¿ÔQ98Ì¦ï9äàp@°ì•S™v£p<0Â©ŒQ8 ˜EC{3Uþkî‡œ“)‡,fÑÐÃ¤L•çÔÂÑå²p8 ˜M#dáp@0
åYuŒ‡Ž –½ðZjF”CÉâÉ\ù
-5#Ê! ‡dñdŸs*ï
ñIÆ“½r*ó
ñI’Æ“½rª]ˆO¢4žì•S}Ï!>‰BÒx2WNµÉ áIÆ“¹pª=ˆN¢,žÌ…SMæD!Q<ÙOæTÂ!ÿ†$ñd.œj*‡è$
	âÉ~X§Zt…ð$
Iâ±Ç²C|…DñØ“sˆO¢,{LÄùPH=Å
ÄùPH=Å
ÄùPH=Å
ÄùPHª5–Â|($Ô&{G5©Aœ…„ÚXS¬D0ý§—?5Á¸ó˜þÏ÷—Î­¾ºûÏípÿ¡¹ÛjWÛû¥ú¨äVÚ¥~©{"[[%Uêô.Î¶öƒBøPïòâ¸]}ÜæåÇº,×.jñ²_z>úÁr­5¬Ô:_•QYTÚƒöÍEå©õ,šçõðƒKƒj­<F„?#K]§pÐ~÷žŠ5qó\W¶oö<¾ùöq¾±Ñ¹oö=÷¶ìwÛrôð9:*þùó
C1µ¹úO^úïîõ³Îß?O/aŒõŸLžykß·Ã°öôßº¾[pƒ  Ü‚“'ÆÉ_€·÷Fë¥Û½mý¹Í<›uW­»b]ø…Ð
¨’C?ý{ø¨œ‰ŸÜÖ^î…ó×QPŠ¹‰D¯ÿ6P˜
‘ÔÅNÂ/#üÿ†ö	sáñV&áW¿þGó„ù€ŽW¹‡.
RBæïÖÌï¦•CŽÉ2Ë^9Þ×F”CŽ	3Ë\ù
—™"Ê!G„™e¯ïï"Ê!K„™e¯š ¢²ôH˜YöÊñÅLD9´*‹„™e¯œll‡Ve‘0³ì•“íÐª,f–¹ò.3Í+‡¸/
I3Ë^9ÕØ_’f–¹rüB|D8dá0³ì-~9:¢²pH˜™=¶¿($ÌÌÛ‚_03{l;~AÂÌì±p ø	3³Ç¶ƒà$ÍÌžR
¿ qfö˜Wü‚Ä™ÙS°€à$ÎÌÛ_<$ÎÌÛ_<$ÎÌÛ_<$Í,sáTsÄ}ñ03{êˆûâ!afÊ3»•Q88	3Ë^9YÎ ç!afÙ+ÇßãŠ( œ‡„™Ùó¶CÜ	3Ë^9þhdD9àà<$ÍÌžï9Ä}ñ4³Ì•S™vûâ!afÙ
§221ìËTù¯98CC{Œ·2Uþk.³ûèå…CÂÌ,Ú!
‡„™Y”sÈÂ!afp…CÂÌ”gÕƒ`N¸ áE<$Ë,sá+\hŠ(‡#”¹òzD”C‰Ê>çDÞÕƒð"#”½r"óêAx‰Ê^9Ñ.ƒ áE<$F({ådßsÈÂ!1B™+'Údð ºˆ‡¤e.œhÁƒè""”¹p²ÉòoH†Pö“9‘pˆ-â!B™
§šÊ!D‡‡$e?¬-ºz¢ÃC"„ì±ì¢ÃC"„,Ê9dß!{L„èð({ŠÑá!Q<ö+¢ÃC¢xì)V D‡‡DñXcÙ!B‡‡$ñdoà¨&5Ñá!I<Ö+1DÇä2ðwÆ—¼ÌÅºË
Žô…`Iº]æ(áùá‚¸
¿ø6°Orž‚—±SÞ…ãˆHfc¤5’“ø¿’€E·á'@x4·áû9)oÃ§K@ÔÏÎòÍ'`Ñ}x¾øÀi®Ã»ÁÏ	H{>]@_ª"¿?=˜ŸL Œ¦ iðÚÇÈà›bÂ]¤üûwÓÊ!_ƒPžbÞI§òÕ8˜å)ªÈtÊ!_£Pžb7rÈWãp`”§°—é”CÆ‡£P¾xOßOQ?§R‘S<,{åÍ'¢8°©kèO­úWß¨Ô7ÿY—Õ˜³Î½uG\p%’"°ñ—¯¬Ýÿägùÿ9îŸŸõ…ò¥Ð¹VoqÀ2¹¡ƒ!¶‹‡–PNå8 ¶‹‡–PN5û@l ,Ë^¹Jq¼(rÈeâ€eÊ_!ó×ÜÅÃË(§ò×ÜÅÃË('Û!—‰#–PN6ÂA.G,Ë~„
R¬Ø§RÁ]<±Ì@Î©*
îâáˆe”SUÜÅÃË²WNTY„Ê!‡C–PN5¶Cx‡,3 œÊÉ@|‡,3 œjVƒ /Y–½r2ß^<²,{å)Ž¤Y8±,{átF²p8b™éœêe‡ /Yf@9UÎ!À‹‡c–PžâXY:å…ÃAËlzÛ!
‡£–PN5¶C€‡-3°Bö=‡,[fÏt^<µÌ€w¥ªÎ%äàpÔ2›†vÈÂá¨eöÈ”CG-30ÀQ}Ïc`‘©ò¼îõRå"zx8j™åT#DôðpØ2{&5èáá¨e–%È”C‡¯10S-9C@‡¯1 œ,ç…Ãák(§ríÐÃÃák|Ï©–œ! ‡‡Ã×80AµÁ=<¾Æ@Î©6X  ‡‡Ã×dŸsªâyx8z”Sí¯@@G¯±(åƒÃÁkì±®ÎÃÃ±kT+TË®ÎÃÃÁkØ2åÃÁk,2íÎÃÃÁk,2íÎÃÃÁk,2íÎÃÃÁk,2íÎÃÃÁk,2íÎÃÃÁk(§2í Î ¯±È»‚8¼Æ€r¢Y-€öÔÌ@¶þŸTÅ•“¬<MÃ‚Åwé°ðšùßM+ æó sÐ„r,ª)®˜ÏÌ@#Ê‘½hâÊù<Àœ4¢Ù˜$¦ÚS
0g (GvƒŽ+ æó sÐˆrdO–¸r`>0‡ (§Û¡Mµ sÐ„r,h4®X“	0‡ (§Û™yuÌåx¦’ã¸`A óU Ïÿn¡tèÌk(õ¾Ž¬ÐãÒÑ=”Žzá
HGZ÷¸t`x¥#ê5#Ò‘«qéÀøJG•-6I øP:ªnÉ^:Ù( ,º»æþ¹UÊ"=TŽª[²WŽ]™‰K ªôP:ªp±(é@•*G.’Ž\ˆŒK ­æºéÈÕç˜t¨N¥çÔÊa·âÒA+‡¹ƒnD:ÕwªÔCéyµrdÒA+‡[¶¨vjõPzN­Yí€uÜ´=Ó:t6TžS/‡½Ý—z9Ü"´éÈë
qé ™Ã­Bg/{›'.4s¸eh‹^xèl(=§f{o/.4s¸…hÒ©¦uè l(=§fŽê«„
•çÕËQ
ðÐYØPzN½Ù †uÌ…t#Ò©c¡Ó°¡ôœš9ºQ4s˜;évÍm ™Ã\J·ë… ÍæVº	éØ–J1éÐ‰ØPzNÍÕ ˆ
•çÔËa[§Å¥ƒ^s/Ýˆ£¡ÚyÎÄ†Òójæ¨á}ÐÌa®¦‘Nµõâƒfs7Ýˆtªý 4s˜ËéF¦uªåX4s˜ÛéF¤Sn>hæ0×ÓH'áA3‡¹ŸnD:Õ€fsAÝˆtª> ÝæŠºéT#| º9Ìu«ª— ts˜[êVyø ts˜{êV¹¹ ts˜‹êV•/èæ07Õ­*_ÐÍa®ª[åáÐÍaîª[åáÐÍa.«Û4¯»èæ0·Õm2²®º9Ìuu›Œ¬ë€ns_Ý¦ÊÍu@7‡¹°nS½î:Q7÷6·Å±f;üp_x O[§º©O	š÷)@ó"f{Ðü|Œt¢žòmîå6 <h~þŽ ÍÏD6Ð|<Qgû67°šNÀ"Ðüâ„ó6
i~úÝÏˆ4Oì°q%eøñAÁçÜYUÓx›9ó»iéÃv\I™½tü¬;+](6?ò}´z¤ë/žþ¯”Âÿ ˜ýu×
_IVeIÂ¿Ì>¹}Óh]¿ÝÞ¾i=ÿ,|—Û/ãï> jÿÊó|6ÎT"„62§¹Ã›Åù×Ö…J„ÐFæT:¾DˆH‡J„ÐFæT:¾0ŒH‡J„p6È§ôîÕD¤C%Bhàr*¿Ö‘-ø†Ö)§Ò©fgZð
-KN¥ã—ù#Ò¡ßÐ²ü§K‡ìh8ãçS:Ù( ºQ7§n”L9èåÜ¼z9ÎÂß”žS/G•tZ97¯VŽÊÀ3ÐÊ¹9µrdžVÎÍ©•#3ð´rnN­Ü
="ÒA+çæÕÊ‘I ­œ›W+GU»0ÐÊ¹9µrdµ
½û÷rôr,§^n…+ÒóÒ9èåXN½Ü
WF#ÒA3ÇrjæV¸2‘š9–S3G÷ÂƒfŽåÔÌ­po2"4s,§fn…Û²é ™c95sd_uÐË±¼z9²ôr,§^Žn€ ½Ï©—[áŠtD:hæxNÍÙ('@3ÇsjæÈæ6š9žW3GõÂ
ÐÌñœš¹nÕD¤ƒfŽçÔÌQ
ðôr<§^n…ûDé —ã9õr+\ª‰H ÍÏ«™£Z„ ™ã95s+Ü"‹H ÍœÈ©™[á>QD:hæD^ÍÕr,	'üœJ§*Ü@¨H8áçT:ÕBE\$E'{éT#<q‘ì¥Sð TÄERt²—N5ÂƒTIÑ±§z±".’¢c‡ ±".’¢c›¹".£cOùrE\$GÇžòäŠ¸HŽŽ=äŠ¸HŽ=äŠ¸HŽ=ó:Èq‘ {Œ,Èq‘ {Œ,Èq‘ {*7,â"A:öÔë°HÿéåÏ/èÿ|éÜê[ÀÿÜ÷š»­vµ½_ªJn¥]ê—º'²µUR¥Nïâlk?(„õ./ŽÛÕÇm^~¬Ëòã¶(    ×.û¥ç3¡,×ZÃJ­3¬Ö6¾*íAûæ¢òÔz–Íóºþà‡«]·×l‡´{y~¶Ùìî å¢sò°<ðûÁõAãÆñÎÄééÆ5—÷§ÞÑç~ýŸ?¿é8Ó¥zý'/ý÷F÷úYgîYç³‚ËeÁ
&?òòÖ¾o‡1íÓâ‡!
Ê<1Ît˜ý·÷Fë¥Û½mý¹=›r×[|«Bà))Å?ãÀ»‘ÀÏ>¡õ’osCÙ’WÑ…X—^ApÎ<…ºŠþ/hÆ0£0`Ó×ÑN¼_àœKîæljöWÓ¯^TùÛœ0ýêý
ÚPD^½ÜæmnyÂtþm(¢)€+Ô*Föß~|ŠÈ×„ì¸8€œéh£•V68‚œéh{•V68‚œéè¢.*¬lp9ÒÑ¥|T:XÙàrÙKÇß„ŠJ ×©q9ÒÑ»Qéà:5Ž g@:ÙäºzAÎ€tôÆLD:HÙqq9›¤ƒn‡³§–);.Ž g‘rÐËá rÙX²ãâ r%´r8~œEdì¸8~œEdì¸8~œEdì¸8€œédßuÐÊá rÕ. cÇÅä,ª]@ÆŽ‹ÈYT»€Œ ³gZ ;.Žg éèÛoQé —ÃñãHGï=G¥ƒfÇË^:þ’oT:hæpü8›^xÐÌáøq²N&4s8~œéDÓ:93.¢fÏ0Ç@ÎŒ‹ƒ¨Ù3Ì13ãâ j¤-I23ãâ j6}×AKƒƒ¨Ù3Â³áå¯ô¼Z²´48ˆZöÒñ·¢ÒAKƒƒ¨YS¸1i‚c¨Xž"{ßÁå)CÍ€£!Ú`0ÇP3 h)šÁD¾È€t¢
A_d@:Ñ*<‰ Gÿ10­-J2ÂpôÒ©
7ÂpôÒÉFxÈÌ1ýÇ€t²2sGÿ1 l„‡ÜÃÑH'á!7Çpô‹ª	Âpô‹<<a8úEn„‚0þÇ¢ò„‚0ÿÇ¢ò„‚0ÿÇ"BA d‘‡ ¡   ²h^ ¡   ²ÈÈ‚P† YddA*Ã€,ªÜ@*Ã€,ª×cTÉµÚÉíóå„«uWœ@	ž¤Û	¸ã*ßWÁ¿áF=ÇŸEãÿ7D:üQG9	?ûð/ºUÎ†_(Š[å¼ ÅÏáOy«<Uø£®v~þá_t§Ü]þ—ú¾Rîû9üi¯”§Š?l­qµ¤Cî¹ðE"ä>š‚¤7ºÍ7?ðò»€°òÉï¦¥ƒÖ‡3 =ÅâI:é µÆñÇ²—ÎRXëtÒAkãžÂZ§“ZkÌ€ôþ2tÐZãøc¤§ð—©¤ƒŒ†ãN5ÂƒŒ†ãe/Ý¥æ@F
ÃñÇdjr-  £]‹dj„ !-  Ë^zŠµ“tÊA3‡ãe¯œÌÇ‚Œ†ãNöU ÍŽ?f@zŠÕñtÒA3‡ãe/ÌÂƒŒ†ãN5ÀƒŒ†ãNeáAF
ÃÈH§²ð £…á d¤SMn £…á d¤SMn £…á d|,Õ2Z@–½t²Q4s8þ˜EÅ
ˆha8þ˜=Å
Hha8ü…òèÝ²Œl,Hha8ü˜ñ&ëBE¶^"2Û7·—§ð¿å÷èåÏ8óç¿þü½· &.¯¹Îº¬Ë ®B"¥ãø2øÓ^ýÏßÿ?WÎþx˜0+ÃpÐ´ìßU–âÜeªwäÊ04Í€tª
äÊ04Í€ô—cÓI (šF!}ñÑF58ƒ\†ƒ¦e/ªì ±2ÇL3 œÊ‚X†c¦N6ÀƒÇL3ðU'“ZP3Í¦´ 8fšE/|éñWú¯™¹^xªiDi03-{édI ½™–½rN–tÐËái¾êTkÈ Iƒ!Ñ1ÙK'Ë:hæè˜ì¥S9x¤Áè˜ì¥SYx¤Áè˜ì¥Sí€$
†DÇd.jã i0$9&såT«ç Gƒ!Á1™+§šÙ@ŒCrc²÷3TÊA'‡ÄÆdoß©”ƒFIÉ~p§ZŠ1I±H:häØ{ì;ÈÑ`HnŒ=öäh0$7Æûr4c} 9	Ž±Ç¾ƒ
†ÇXcßAŒCrc¬±ï Eƒ!±1Ù›Xª©
Äh0$6&û½eªñ=‚Ñè?½ü‰üxÕÿùþÒ¹Õw~ÿ¹î?4w[íj{¿T•ÜJ»Ô/uOdk«¤JÞÅÙÖ~Pê]^·«Û¼üX—åÇ’SyÜî—žÏ„~°\k
+µÎ°<*³òé }sQyj=Ë‡æy=üàÒ Z+ÊµKQ-^ÊR×)[¢×ÞÚ=:oÞ¹ƒVqà~½÷Ÿ½óçûÃÆG­wut°¶wt~Ú÷ ÿüù…Ç¡˜z}ý'/ý÷F÷úY'ðŸ§—0ÈúO&Ï¿¼µïÛa\{úo]ß-¸APnAÈÉãl‡oÀÛ{£õÒíÞ¶þ\ƒžM»ë­K±Îô½hOºìŸÄàÏ>¡ƒu““«ç“ðK½urLêö]á£nž/ê»0¹ž|ó\qŠ¾
<N~¥¾
#¤ƒõ³“àË_þ
]\š®
n
’üJ]æƒuÔ“à«_þ¢ž
‹ƒï=Â7?EË‹Õz.ÌG6õ¨^ŽûÉxn ¡ó}¿7ÕÏþnZ:hêq¬0
é‹§z´¿›WÎA’Ã±Â²WŽöôQå §Ç¡Â(”ÿp¢]ÈE¥ƒ¦‡
3 ]¾G¥ƒ¦‡
Ëþ}Ç/ÚD¥ƒ
´8T˜éè¥º¨tp‡
3 hjã H†ù¨Þ€tô²|T:¸@‹£¤æÈ¤ƒ^GIË>ëd£håp´ì“N5È†c¤eŸsª1ÄÈ0"ÍûSdp„4{ì;‘ÁÒÌkTö†Èà iÙêdö†ÈàiÙw"ƒ#¤p3d3häp„4‹ì;‘ÁÒ²—Ž¾U9Ž¤e¯ "dÈp ÍÀûN•u!Ãq€4…
YÖ!/Çq€4Ó:úª[T:dæ8f ëd/<dæ8f ëdÒ!3Çq€4Ò©”C^Žãøhx²¯:äå8Žfà«NåàA„ÇñÑ²ßéæ6ÐÌáøh²Nµ
"d8Ž–}ÝF6·Å2¥çÕÌQ}×cø–¿ÒsºÅJ÷ÂƒfÇG3P¸‘e4s8>ZöÒ©¦uZÂqx´ìßw²×ôr8:š/Gµû 2K8ŽŽf@:ÕöÈ,á8>‘/Gµý 2K8ŽOd`j£ªÛ@f	Çñ‰ª…hYÂq|"/<ÕÜ2K8ŽOd ëT#<È,á8>‘éT#<È,á8>‘ƒ$T#<-á8>‘ O6ÂƒnÇ'Ê~˜£ò± ³„ãðDŽÿS•m ³„ãðD¢ÉxÐÌáøDYxYÂq|"sÕ 2K8ŽOdÀÌQ
ð ³„ãøDYxYÂq|"Ò©,<È,á8>‘Ed–pŸÈÀwl„ ÍŽOdÀÇ’ð ›Ãñ‰,²ð1jÉäñwÎ—½E¬Ö…_¾+ƒÄ{Ä.s”ð|Kòôá¿Kpƒžþ|Ÿ(nÐ‹qD431Ò	ˆzÊIü_IÀ¢[ô‹ÀS´0øù=+È¹SÞ¢O•€
e’€àW°è&ý=$HnÒ³‚JÑÆ íMút€
6®¢TëÒ)ð@½c¢9X~ÒU)ŠiPúôwÓÒAƒc¤QHÿa4…ËL'4Ø8H…ôðp)VÒI 
6’f@z
ƒN:h°q”4
é‹‘æ^
—™N:h°q”´ì¥«µE:é ÁÆñÆd=…ÁN'\.ÅñÆH'›ÜÀåRo,ûaÎKq˜/•tÉÂq¼1›¤ƒnÇË^:ÕWd²poÌ"å —ÃáÆ,RZ9mÌ€•£2ð ‘…ãhcxÈÂq´1‹<Hdá8Ú˜éT.$²pm,ûb¬v‘,‡3 f„w]O¸ÿãª¿ÚŸÿ¬Ž›>Ç– ŸÇHç?oÞ÷‡ÿàÇ÷Œ)]	‘‘k[sýsÖ]µÎxé›nRd®ožÛÝïÖ¸îÿL4ø?ÇûÑ0g L†ã8irFUy€4Žã¤XV£2$ N†ã8iÙK'SšP&ÍÀûžâÆ`:é 
ÅaÒHOqN#tÐ…â0iÙûŸì… ](Ž“fÓ
ºP(Í@ÖÉ¤ƒ.GJ³é»ºP*Íže&Ãq¨´ì“îS• N†ãPi
ð O†ãPi²NµŠòd8•fÑ €f‡J³é»š9*Í@ÖÉ^xÐÌáPiÙg= Ë:hæp¨4‹¦uÐËáPiÖ)ÈÞwÐËáXil,ÑÆ‰ 1"ÇJ3 hãD€ŽÄæd¿/N´q"@ŽGbs²Ï:ÑÆ‰ 9"ÉÍÉ~Z'Z‰ G„#Á9Ù›9¢j]€ŽçdŸu²4sHpNöY'áA3‡çd/l„ Ýœ“½t²tsHpŽ5Õ‹ I"	Î±ÆÃ
%Â‘à{<<ÈáHrŽ=„‰p$:Ç#
ÂD8’“ýOedA˜GÂs²—Nö] Ý’žc‡ a"IÏ±ÇÈ‚0Ž¤çd_¾PY˜&‚¤çd/j„‡i"HzNö“UÖc4‘? ÝéEßå” ënøé\	_þ· ™éDMå4î¯dàßÐ ’¨·f€ýJþÝ ")€=6®¨?Þ-0!<ä®ÀÌï¦¥C[ )^Ò3ë‘yl¤xHÏì2QD:ä±’â•½t¼åˆH‡<¶@R¼¤gÖ
 "òØIñÊ\ú
÷¨æ¥ƒ¤xeŸuüˆthÅT )^ÙK§šÜ@È‹@b¼2æV¸‘­˜
$ÆË"é›HŒWæÒÉ¾ê ™CR¼ìQz9$ÄËå •C2¼²·rTd¼$ÃË2^’áe‹×—£UòåhýZ|9úÏ/GËè.G‡ÿ:+p&<!–½=ó£aÎ@8@ÂÇ²Ï•ýá4IË|•¬èá4‰Ë^:ÕÔÂi?–½tªÊ„Ó$~,ûe5²¬ƒ&‰Ë\:™rÐ„"écÙ¿ïø
dé 
EÒÇ²—Ž?¯‘ºP$},ói}…Ë¢é 
EÒÇìyáA8@ÒÇ²Ï:™tÐÌ!écö|×A8@ÒÇ¬Yf Ù4IË<é+ÜŽH ½’>fÏ ²i’>–}Ö©V‘A6@ÒÇ,àA    3‡¤Yô] Í’>–}ÖÉ^xÐÌ!éc™g}…û4óÒc<–¿Òsjæ¨xƒ"ð±ì×)¨Þwƒ"ð±ìm,ÕÆ	ÈAHøXöÒ©6N@Š@‚²ß§:ùrPü“}Ö©ö@Š@‚²ŸÖ©V¢AŠ@‚²7sTÕ:ÈAHðOöY'áA3‡ÿdŸuªä $ø'{éT#<ÈAHðOöÒ©Fx„"à{ª„"à{<<ˆBHð=D¡$ùÇ¢Pýc‘Q(ÉþÉ~„§2² 
E Ù?ÙK'û®ƒnÉþ±ÇÃƒDdÿØcdA¢ˆ@²²/_¨Œ,HHöOöÒ©Fx)"ì'7²¬GÝÜô&ôäNòÊù:gšM–>œ'öApî¸Ê÷U€è0ù€›ÐŠ¢ /¸)î¢§ìÀÆ`s˜‘Î@ÔTN3 ~%‹º,Î€`Ý xñŸ3²@ºD½í4òW2€ïà¥È@šn Ê’n éR {lDQùýñ¢À•dâ
‚h–y
·KŸünZ:è±1$/ÒSÌ=é”ƒCò2¡<…áH¥ä¼ÈË„r7Åîw:é ÃÆ€¼ŒHO±h˜N:è°1 /#ÒS,$¤“:lÈËˆô'»ÒI ×K1 /#Ò©¦6ó"0 /#ÒS,$¤“®—bH^vI ½†äeB:Ù( Z9ÈËˆ‹¥RZ9ÇË„rš1N_ö’¯Fë—jÙ«Ñ<90óW£¹(„ºå/5zú£ÿË$ˆ§þ˜Eu‡é4ƒ³¨î œF`èc6™o	Âi†>fSÉ%A8ÀàÇlª;$§ü˜Mu‡á4ƒ³©î œF`ðcF|YÖA
ŠÁ™žâ\R:å ÅÐÇŒ¼ïTÒA6ÀÐÇŒHOqL#tÐËaècFŠMª¯:È¦ú˜]/<hæ0ô1é‹›G32é ™ÃÐÇìú®ƒfC3"J9èå0ð1»F9ÐËaàcF¾êTÅ
ˆ¦ø˜‘¬­!KM#0ð1«xM#0ð1#Y§záchš¿Òójæ¨^øæ¯ô_3s‹_xN–uÐÌaàc&²Neh@ŠÀ°ÇL('{ÝA+‡A™xÝ]ªÝ ‚A‘Nµý #P0Ì#³:Õöˆ@‘æ‘©ªx(Ãü1’uª…h"1Ì#Y§šÛ@ŠÄ0Œdj„ (Ãü1’uªD HóÇÈÎ
Õ"P$†ùc“™(ƒü1’tªÚd HòÇˆtªi„ HòÇÈj,Ù š9ó‡Fú½ëÈxÐÌa ?&¤“ùX%"1Ô#Ò©|,È‘êéTÓ:È‘êéTd‰H<Çˆtªd‰H<Çˆtªd‰H<Ç„t2
ÂD$žcD:ÙäusÓ;Ð“ëÂË)Wë®¾Þ+G%)ÿ‘ˆ¾¨Àâ;ÐBPô`wò!«÷HêÄ0#¨©œfÀû•,êà.Ì KÑ‰áç> 3WÙWï.Qo;Í€ÿ+XÔ `q„OÑ À-øòç¤í* âEb^ß¯G9_92M– 'c›ÐÌÿnZ:è±1/#Ò‘MhâÒAxÑHÿ¡õ²áT\:è±1/#Ò‘ÖâÒAx‘Žì°—zlÄËˆtdKÁ¸tÐcc ^&¤cIÆ¥ƒ+¦ˆ—éd#<¸bŠx‘N6Âƒ+¦Š—é4#¼¾í'ßÖãû²w£ErdæïF
Và<ü÷ÝåïFO4Ì§‘ü˜‰œaÛ;Ç^WN#1ø1Ò±M½ãÒAŠÁ™•©¦&N#1ø1#Ò©¦&N#1ø1«ŠN#1ø1«8H§‘ü˜U¤ÓHÌ* Òi$†?fUµ
Òi$†?fUñÒi$†?fUñÒi$†?fQñJ Ý†?f•‡ é4Ã3!ÉÖŒ+ Í?fUõÂi$?fdn#{ßA3‡Á‘N–uÐÌaðcF¤#‘Ùqé ™ÃàÇìzáA3‡Á‘N5Âƒp‰ÁYõ] á4ƒ³iZ Ù4C3bc©*@6ÄÐÇŒH§àclš¿ÒsjæÈæ¶æ¯ô¼š9²ï:hæ0ô1»¾ë ™ÃÐÇìú®ƒfC³jn½>fd‚J:ˆA‘HêOöï;Õ"<ˆA‘HêOöÒÉ²š9$ö'{éTÄ H$÷'ûï:ÕÖ
ˆA‘HîOöÒ©ö@ŠDr²—Nµÿ bP$’û“½tªý ƒ"‘Ük
ˆA‘Hì=ÊA/‡¤þØ¢\4‰„þd?©-Æ*'"‘Ô‹¤ƒV‰ý±ÆÀ+'"‘øk\¬y"ÉÏ±ÆÅ*'"‘ kÊ6òD$ cW OD":ÖxòD$ cW PD":ÙK§šÜb@‘éMèïtÉ›ÐÂÕŸÎ\Ïõ‚$å?ÑuXÌ¤÷\Šn ¼À'WÀWïÜa6F:QS9ÉÀ´-Ù,ê°¸OÑ!M7 Å~Î@Ên é2õ¶Ó¸¿’EÝ g@yÝ XA¦ø¤í.°ÇF•úãe!g}™xAŒ ):ºãÖìï¦¥ƒÇñÊ^:ºõRT9h±q¯ì•£;/E•ƒ‡ñÊ^9žÎ•:lÆ‹BzVtÎ¨tÐaã0^¤£»§F¥ƒ‡ñ2 5š“®¯F ÉW£uÎ—½-“#35ZŠB8mn¢ûX|5zú£aÎ@<ÄñÇRTs2ˆ§‘8þ˜×Ýâ9*\èÅÈl’šP€,{éTÃ3ˆ§‘8þXöÊiFçP9èAqø±ì•“q  ÅÑÇ²WNUw€p‰ƒe¯œªî€Ù48ö˜Áªî€Ù48ö˜Eu Ì¦ÁÁÇ,ª;`6
Ž>fMÝJ Ž>f@:ÕÔ³ipô1v†,ë“S8úXöÒÑ4Õ¨rÈÉ)|ÌÀûN&²r
 3 M.ˆJ‡¼œÂÁÇÔld_uÈÌ)|Ì¦2s
 3u*é ›Fáàc²N¥òr
 ³h”Ñ4
 £þ¤„ÊÁƒh…ƒN5Àƒh…ƒNµ
¢i>f@:Ù š9|Ì¦ï:hæpð1Ó:Ù
š9|Ì@ÉJ–uÐÌáàcÙK§šÖAŠÂ±Ç²WNõºƒ…Ce?Èá‘¢Qé —Ã¡ÇØXªí ¢pÌã;Õöˆ@Q8æYªn(
Çü1uª…h¢pÌY'›Û@/‡cþÈ:Ùz9óÇ€t²ôr8æK5Âƒ$…cþdÿ]Ç#E£ÒA7‡cþXT¼€$…cþØcáAˆÂ‘s,²ð HDáÈ9Yx$¢päŽ†l€ ÍŽœc`Z'àA3‡#çXdáAˆÂ‘s,²ð HDáÈ9¤Sð HDáÈ9Yx$¢pä‹,<Q8rŽéT#|$2½=¹q¼œr¾îzOùA¢ðh„¥Ú ,¢s‡¢
€[“[Ø«·HnÄ0"ÿ¨¥œÆŸÿFüWhHŸ¦	@@× Uü£¾vññ_Ô`qŸS´ à7ø9þi[ ¤J ì®qådøé~AyRi24ôFÇVª,3¿šzk¸+{áè¶;á ³Æa»²Žnµúj´+{áèöZ³Â]×“NòUh]N,{ÚKŽËÌUèðÿœp6Ra\—½
=û£aÆ@ÂÁÆ²Ïº
Þü«
‚h5–¹p|ëÃˆp°ÀÆ²Žîþ.ëâ0cÙ
'š‡AÂAÆ²Žîí.éâc™
§zÓAÇ‰ã‹Y£4œ8¸˜5†$Ï([Ìš„ƒ~ ³Äo2Rg+fM…2g*F <«ŽÕá mÃ!Å2NeÔAÞŒÂÅ²Ï8ÑàÒf'–½p"¿
²fŽ&–ý«N•qÐ·áXb™
§Ò
ú6H,û7Œ }#–½p4&2"4n8ˆXæÂñhÐ9áÈ˜Q8„˜-¯º f F ü‡ž\TÂAã†Ã‡e.œè;ît…ƒ‡ÿ¡û3U÷@¶ŒÂ±Ã2N5¶¾
GË>áTÂAß†‡e?¶Ñ,°z TFá°aöê qÃAÃìÉ8hÜpÈ°Ì… Dƒz'óWøo·•›Ó¤Ò
ú6-,óA]½é1vÊ_á9õm4›	H,Q8RXæ÷hÖ–=W¢pœ°ì3N³›à¸…£„eŸqšµe¤•($œ'óiœf‰ÕY%
‰æÉ\8Õà7$™'ó…¨ 9%
	æÉ\8Ñ¨Â>Ë“ù«N4¸¨…„òdžq¢é}($’Ç–Ä|($×&káT^¤|($ÕÆ¯B>’ic‹W 
I´±Å«ƒˆ…Úd.œj:’gc‹W ù
‰³É\8‘eé
I³±¥HÙ
	³±Å«ƒd…DÙdžq¢Qäz($ÈÆ–"¦z 16™OgD–†z !6™gœ¨H‰ =úO/~v|_ÿçûKçV_Âýçv¸ÿÐÜmµ«íýR}Tr+íR¿Ô=‘­­’*uzg[ûA!|¨wyqÜ®>nóòc]–/ Õb½_z>úÁr­5¬Ô:ÃÊcGTN í›‹ÊSëY>4Ïëá —¾Ê¬Rl‰Ê¨ì–ºNáåéÔ}Úkµ÷·º ]¿xÞ<¿»lœ~U¼“½§=µ¡^o?¯›£FëŸ?¿ð8ÓaRÿÉÃKÿ½Ñ½~Öéûçé%Œ±þ“Éó/oíûvÖÞ83¾[pƒ  Ü‚“'Æ¹óÿöÞh½t»·­?÷’g“îúëR¬
/ü1ß÷ƒc?û„¾ ŸSÿ«<:Ž ´1ªlÅ‚?¨ÖÊƒríRT‹—R Ÿ=ìî¾òÛÏ7y<¬žïÚ{Ç{G—µÛm]Š—óãÏ]u°{¸=ØÜ¿ Ÿ¾\çª õ=gùOb'ŠÙ'tð}(ø‚*øÃjñ>!øÛ¢š"øwçWŸÅÇ«âp÷ùë}«t»ûÙû¼
ÊÝ½§§fí`o·Ùzë¾öêy¾¿î:å²°à‚?ó„~ _Rß©ŒZ	Á/óÊðçàßwŠ¢¶w¿¶uÑ)ß7GþZðÖ?*žºƒÝ5qQüØUw'ƒ{¯ñ5x/ýrðƒõ1Q¹HéJ
¾ëüŸãÌ=?†v™ö øžMS÷ pšþt¶Îý‚îXÄ½¤É.Ú}f©&,“®@ŠM@~nÂ"R5¡HÙ„%ÚçOfb¤3-)¦P    ¿’EmXg`¶5
¾
ËLhWoÃ’.ÑÚfšïW2°¨Ëâ¸NšND):±øòç¤íÄ’. p™µäªá4	"ŒE8Î±Ä>«ƒß9¢ÛßTúôwÓÒ¡BË[ŸhJ:¢í[²r¨Òò–Å'šRŽA'K‡VÉ½eñ‰Æ¤#Ú¾%K‡ÖÉ½eñ‰Æ¤#:7'K‡VÊ½eñ‰Æ¤#ÀbÉÒ¡µroY|¢1éT<ˆÜñ–Å'“ŽhØ,Z/÷–å'Ú'Z1÷–å'š’N5ÊÈoY|¢1/G¥´rËÒM)'ã@+·,<Ñ”rDÛædå “[–h›} q;Þ²èDëì;ˆÛñ–E'ZgßAÜŽ·,:Ñ:ûâv¼eÙ‰ÖÙw·ã-
O´Î¾ƒ¸oYx¢1;C–uÐÉ-
O4%ADNV:¹eÙ‰ÆÞw2é •[–hL:‚>’,ôrË²Õld_uÐÌ-ËN´ï… ÍÜ²ìDcY§‘®»c»ÉÝ±õ7jÙîØ~rdæ»c3¯à RˆÄ­±ÅÝ±§?ªsºÐe¡Ö
R 'È[úhL:•rÐ„.Ë|4öE¥*=@L·,óÑº™)†	ú+=§&”Q­!Ç=SéËB-›™Bé 
]úhßwt¡ËBí{áAº,ôÑX­M–uÐ….
}4%ÌÐ€^nYæ£)åT¯;Èxñ–E>³rTÛ& åÅ[ùhL:Õ¾	Èyñ–E>ß©öM@Ò‹·,qÍ˜tªâd½xË2×ŒI§ZA i/Þ²Ô5cÒ©æ6øâ-Ë]3&l„ ½Ü² 3cÒÉFxÐË-‹03fcÉFxÐÌ-
13&j„ Ñ/Þ²3ëŠþâ-
2³ÍÂƒôoY’™uä¿xËÂÌ¬³ð Æ[–gf… 0Þ²D3ë,<Hñ–…šYgáAŒ·,ÖÌ:
¢`¼eÁfÖYxã-‹6³ÍÂû Æ[nf›…÷A Œ·,ÞÌ6
ïƒHoYÀ™eÇØýf¦
ƒ~Ý)º0´Ür-Þ¤Z<þJÓäÚéÞªµÚîîçæéŽ·-jµnÿ† =Ïýh<<V~;¸~ì•ý×ßïÂàúãî"Ž¯<•Ü…aö	|ß#
þýWÐxðk²œ¢ÆÀi‡§Ÿk¥Î{ÿë¶ÑhúO¢Èû›R¸²×Ûß9’nïÅmW¶ ¿|¬KYðd ÝäØÏ< C/¡ÐûT¡VK	¡ßfåöÏ¡{Ý.½ž¬ëk‡×ûûž¼~<|l|œŒêjûþbã©¼Ñ;¹¨}w~=ôÜ]wdÁqB£ë»óûÙ'tðÁŽSUðG•bÒ{_rÒ¼÷Ÿ[ªzýÎodQì8áK~r7:®oÖŽÍgÿ¼Yº?©mÉàýp»ú)~?ølÉBÀ…t ø3OèàC§Æ¥"Eð;£rq#üQå±>(ÇFüý‡«]·×l‡Ôc7Å‡¯z©~·÷ø>¼¾b­‹/çÈ
¶«îçñEçæ©Õm¼Þ®Ëñ¨»IQ—W…‘åá×> ¯
®ç
ô£K†^øëÌ)(éŒÏœ^œ	ýì:ôP¿)æÒ„~´ÁÂw?úr­>Lè7ë´vQ:zÝÚ-nWŽØÕöëí;Û)_ÝœçÍ½Ç£¦ã6ö¿Ž¿œ“xLvZcáTªG•‚/%WÑFk:öîì:ôÑ’fÚìåÛI-Õì%üp®]T˜Xžª¹ßv¿£h“Á?ñÿ¢0þ1ZÓ4þÁoÄßíH¤ˆÿÏÝŽxA¥ˆÊnG©âµ›bÎoÄßë(ðhZyüçø§mu”*p‰‰X5ÿþt·~xà%–˜Ü.D»ì¿Ê'¿›–n,K“6&Ñ7:Y:¸a°,OÚ˜tDçèdéà†Á²DicÒ½£“¥ƒË2¥IGtN–n,K•6%ÝC´QN–n,Ë•6&¤L–n,K–6&jriVÞ²licÒ
Ó“¥ƒËâ¥MI§zßA •·,_Ú:å —[0mrÐÊ-K˜¶ÎÅ‚P+oYÆ´e.Vß”fÉ7¥õ?°ìMé 92ó7¥¹_ÐËUÂ]þ¦ôôGuÎ@º,Û:û
¹¼e	ÙÖÙoÉå-ËÈ¶Ï€tYJ¶u• Èåò–åd[Wy€d.oYR¶u• Èæò–eeæÈ²ºÐeiÙ¶¹PÏå-‹Ë6ö¾#àƒÉÒAº,0Û”tŸ,ë ™[™m,ë)Ú€¤“š¹e¡ÙÆ²N&4sËb³íû®ƒfnYp6ôÅ4>ª¯zŒÌôWù¯y9za²tÐË-ËÎ¶n€±ˆþJÏ©—ó©ê6ä-ËÏ6öÂS
ð0hY‚¶1édY ÍÜ²mS/|@6ÌfnYŠ¶mÅ
Œ Z£m¬b%{ßA/·,HÛÔWÝ£Ú=€@Ë¢´ÙXª300hY˜¶1éT‹ð0hYœ¶1éT‹ð054bæ¨Ö$A‘NU²‚ C54"j„ )@>†jhD:Ù™9C54báÉFxÈÍùª¡‘¬“ð›ó1TC«ªäc¨†Vyxäc¨†F,
Õr€|ÕÐ*r€|ÖÐ*r€|×Ð*‚€|ØÐÈ¼NåáA!ZåáAAZåáAAZåáAA‘N6Âƒnƒ6´ÊÃƒ<ƒ64"ÊÃƒ@ƒ6´ê8I¨3Ó‚aÒ·cå¢òëw4
ÿ—%õ;ªŒ6X¥VVF­q
†ÝÑ èõ«jã¼Ty<?ªûvcp³ûÐiîm½Ÿ÷šÊÙOh="ÿŸÙb©‚çJüéû"£ÁŸyâ9 Ö#\¿Å+£Xß—QµxÉ“ú¾Dƒ_î}=ž·šµÇã­^÷vïõüÃ}Q·Ã·óV.UËO;ÅàK‰³ƒÇÏ„$FƒÏÖ@·’r„›{>ûÀÿr]á`Ãùãº»†ô
ržˆtû½³ó¿›þÊC­žÆÊ)Þºí¯r­ÿÊ?n|UNî6ôÚ÷·®ÎNFO
wãÊ«ô¿ÞnúOµã‹ÖÎùð±óä¿µê•ËÍ†\Æß:“Ý†Øw3¿àº®’‰­žÜ¹'tð£ŽzÚwbÒa©™†év…°üô8Kzí¢õ(¯(¢Æ+“Y½ñJR‡¿ùéDý4âW2€o½òÿ³÷n[©,ß–÷õÞO1Û¼^òÏˆ<sU(¨¨€ PñÆ¦ˆ
ž(­Õ#|WõHõb_&
bfvM†#BbÕn{íÚ5çL‘>FäÈã7Ý…Þze*´?o½’/ÉùÅ$î¯d€Þ|EXO÷•Àý>y»¯äËžèVñâ›Èˆ@fÔchnJìáüù»EÒ!m* 0­uH'67M+‡ó
ÒZ‡rbã´r¸hM!Zó(ÿæýibã´t¸hMqº:’.ˆmŒÒ#“–/#“OXÃÓaò©óú”É‡˜­€"]KÖ‰–ô€‡ëõ&¶éDFpZ:\¯§0±µHg{ªÃõz
[‹t"{'-®×S ØZnlÒ¡¥@±ud«ÊAÊV@abk1ð\Ê¡‹¥ ±u(çªq²PˆØ&Í\ c+  ±Mš¹@ÄV@áaky®qÍ\ b+  ±
š¹DÒ¡‘£±²ï±PˆØFÙwˆØ
(Dl£ì;Dl"¶;Ã”õ"¶
[‡ô/çSˆ­e¼³I‡VŽÄÖ"LK‡^ŽÄÖ2gc»Õ¡™£ ±ÍðÐÌQ€ØZ²Î&š9
Û¬{š9
[‹t.åÐËQ€ØZÆ;“ƒSl¡ésêåØ
|
ë3‘Nbk‘Î´¦ˆ:ÒçÔÌ±xÈ²	(@l£îuÈ²	(@l³<4s ¶–)+[Ö¡™£ ±uHç24ePxØ:”³
whå(8l-VŽi÷!„$›€‚ÃÖ"iû!„$›€†iÓPß™¶BH²	h˜6
Ò¹&/dÐ0m¤3-D‡eÐ0m¤s=Û Ë& aÚ4HçªðfÐ0m¤sUx³	h˜6
6–­ÂC3GÃ´iÎVá¡›£aÚš¼@&L@Ã´™cá!& aÚ²ð	Ð8mYxˆ„	h 6ƒ,<DÂ4P›A"aïÌ 
™0wf…‡L˜€Æ;3ÈÂC&L@ãdá!& ñÎ²ð	ÐxgYøfªCüXú8ëý³Œ>UÙÈÑº¥º58ªŸß‰°´ûŠUïþöÙé–äé]ùuo°¾jm^µ:¯›ëGgÿùåÖ-RÝèÇli»^vë–é+¢à§°4“3ìãÓÞ³
;'N­eû"Ès°³ƒàhã`‚±îŸ·qÈn\4¢8þIS;‰¿ÿñÿª‰ƒýeü–&vaÒ?äçMrÅ?é¬'ñ~#þÿ²¹2€
>m2?úôÐ
”nöÈ9§¿[,|îRƒtr[Ê¤thði¼K
ÒÉm)“Ò¡Á§ñ.5H'·¥LJ‡ŸÆ»Ô Ü–2)|ïR½t:Æ:).×Òx—¤“ÉX	éÐx—¤s=Ü (( /5H'’Òár-
xi’tèæhÀKõÒÙnuhæh¼Kƒ”C/GÃ]¤Z9í’Cù×KØ<¦Ñh—¤sxL	¢á.5Hç2ð˜DÃ]jÎeà1%ˆ†»T/ÍÀcJ
w©A:W…Ç” îRƒt.)A4Ü¥†É:[Ö‘—
i¸Ks
„…4Ú¥†ñNFH$¥#3Òh—¤“ùHIéÈÌ…4Ú¥zéTŠ@Z:2s!viÒ€Gf.¤Ñ.5dK:„…4Ú¥A÷:„…4Ú¥zé\·º¼\Hƒ]jï\ÞG^.¤Á.
*ð>ôr4Ø¥é\‹±>4s4Ø¥zËWà¡™£Á.5Hg»×¡™£Á.5HgðÐÌÑ`—ê¥ÓùÝIéÐÌÑ`—æLY! %¤±.5¬SpwB	i¬K
\û„ÒX—¤sí?@JHd©—Îµÿ q !‘y¤^:×þÄ„Dè‘úÇ:×J4Ä„Dê‘zé\³uˆ	‰Ô#õÒÙ*<4sDôzélš9"úG½t®
y !ý£^:W…‡@ˆþ1gö‰ !ýcŽ‡‡Hˆþ1ÇÃC&HHdÿ˜ãá!$$ÂÌñð	é?æxxÈ	‰øs<<d‚„Dþ92AB"ÿÇo[	ù?¦xøH:tsDþ)>’Ý‘ÿcŠ‡¤vsSÍÆ ~ÜÌÀª÷«Íj²ÖK53x©õK²^î8õamÔÌ |8´ZKÇÏÕöBÏ4¶åŽkßmm´KþÁÍõÁþÙæõfc°º°3·øhf0îÇ «™ýWðË    ¶¿(ø“+âà;(ø[ðÍZVðÝÚë÷$¬—§ƒÁJmuq±¿ÙÚ¿ÝÞç»Ï ËâÆ-U½³egÇ}ôŸ¶·šV:øº;I8E×+Ø®ï;t’˜º"¾‹‚ï3¿åÔ›¥TðëýŽ¨åhã!Öj¥Ëçë«ðdqu£|wPß<º¼Üt^ÚÛòº~w½ü|ÛØ¬Ö6o_:¿|Q´ý¢m¤Mü¬àËOWü·m§ÜÕ¸;îè@ „[®}/OÁåìãpôñp
ï[!ªúx|ŽQœ¤É›dÀþ•|ÕÉãë¸,<¦B«¦“G2NÊkN2àüJè½<Â<÷@ŽV¾ÿ}~ÒÊ#•ÔUÚ”uëñÇ‡ž5w/}þn±t0¿¤f::¤Sß(MJ·’Äœ§£‡fü‡\ºýÛjFlÅÿý_vÒ½ì~}Y2.G'W½ëÉ?LýüäF|usÒ;í}ÿÉÓ×M>a¤ðá°ûÒí<½}úéÑåC÷ý_FŸ?õoèóãkG¿£Ý”‡7ƒëîýTÐ>þåý£¦þmœ°ÎÑ}7¾k»÷½›ñk”0ñ_~"zZÝÈ'Çå@HÏ†šÙ„J)ãOwý‚£²{Íù–çºÒ÷)náë®SžÇÓõKŒ…ÿÜ-¸™~m:Fq’‹þ“¸¿’¯Ü‚ü2vŽ|ïd®gUN·/É½‡Iï2ð•[ø:¾Ãá$kã¯|)À{ „¯·
^`;ž›' ³¿™mçxdbéãïK‡{ V²é9Öó)‡[ V²å9–ó)‡; T²å"Çö~>ép „‚JÖ"=ÇÛÉ¹¤CúRHA%k‘žcË/Ÿt¸BA%k‘žc6˜O:Ü¡ ’µHçz´AúRHA%k‘žcË/Ÿtø>
…•l–tèå(¬dÒÙª´rT²Ë¥Z9
)Y‡r¶ ­”l’‰…è¥ÂI6iâÉK!“l’}wPÒ¥My1YÇÚ6ñlaji2§B
 Ú¨‰
dN…B´QÈœ
)ˆh£&.9RÑFM\ s*¤ ¢µ9¶¬CKADëžãôE>åÐÃRÑZÆ;›thb)„h-Òs¼–œO:t±B´–Ù*×­ž>}HŸWË5àS¬¥é¿fæ’–%‘u6éÐÌQÑFÝë/RÑZ¤s)‡^ŽˆÖRå¸<Ä
…B´–[­ÀC/G!DkÉ:×"4Ä
…B´élš9
!Ú¬{š9
!ZË½Î5à!^(¤¢uH·¹²ñB!…­cÀsH
)€hÊÙ†;´r>´+Çµû éB!…­E:×–Ä
…@¨–G×{S/R ¡Z¤sM^ _(¤ BµHçZˆ†|¡Õ"íÙ½ªE:W…‡|¡Õ"«ÂC¾PH„jÙyá²±/R ¡Z¤sUxÈ
)€P-Ò¹žë˜/D„šdá1_ˆÂ 5ÊÇb¾j”Å|!
!Ô¨‰æ
Q¡FYxÌ¢ B²ð˜/DA„eá1_ˆ‚5ÊÂcÀj”…Ç€!
"Ô(‹CD¨Q>6š¢ŸæžM¹[^!p\éüO#”©ÅHšÊI‚_ÉÀÿ
HzÛIÂ_ÉÀÿ)À›6©Œ>Þ/øAŠÌó	¿ÚH`ê»ÅÒÑÑ‹B*Ö!n¶>+GØ§H9mN©\9Ýk%”‡)§M)•+ÿÁI¤„tà°#é´)¥zét›™v$6¥T/¾Hžv$6¥T/þ6_B:X/¤Ó¦”ê¥s=Úõ)’N›Rª—N_%OHG}-
©Ø,é¨¢E!ëÎVå •£€Šµ¸X&åˆù)ŸS+ÇSã„ð]ç¿„÷!ýê}ò8Ú¼JM£¿¹¿¹üXëˆþýÂ§·¿äÈŒ»`ÉŒšz{EaÜ ”Ù ¯ß:\~´|ûÑpÔí{êGã”AJá+›ä¾ª*R>§”kÆ…HU‘òyu \óDªŠ¤Ï«åšw RU$}^(×‘ª"éóê@ÙÉÐRðÊFÍ;©*’>§ô } Ò¡¥à•uH§ŸŸú¤\ PUôCsjAp,:!Z9
]Y‹tú»
	éÐËQèÊZ&›L·º° ™£Ð•ÍðÐÌQ(<Ò•õHH‡fŽB©0ë^‡fŽÒÄL‹t.åÐËQàÊZª“ƒôr¸²–[­ÀC/G+kÉ:Ó²ÐÌQàÊZ¤sø$‹gJúœš9¶{=EµùþkfNY€„thæ(peÒp€*!š9
\YÇ€ç24Ÿ)ŸS/Ç6Ü¡•£ •µX9¦5xð)‘ô9õr?8?•½¤þÑÆ´ý ?EZD\zé\“ÄO‰¤Ï«—cZˆˆŸIŸW/ÇõlCü”Hú¼.ÌqUxÄO‰¤ÏéÂÜ%¤C/G©ßyá²±ˆŸIŸS3÷ƒóS	éÐÍAê¥s=×!/Ù"ƒŒ±ð—lyAæøXHÓ°ˆÀ s|,b¨DÒçÔÌ±MÜI$’>¯fŽ«À#’H$}^Í—…G$‘Hú¼š9.
H"‘ô95sl‘D"ésjæØ,<"‰DÒçÕÌ±•9hæˆès|l%òpyóöÃÎè–ŠÿøxsÑÏýþí¾®¯tzÞZµ5¬Šz¯úP½Þv;KU¯zq»¿»´¢‹nÛû[½F¿b×ú-·6ìjÍÒCõj×‰/¬5;¯õæÅ°>¼x©-
z'ûõËÎ•{~¼×Š>¸úRë—d½ÜqêÃš¨^[…ª½^Ý¼8Z>lû[ýçÅòÓíåËé¦Ø­Ôk{ûO—ÝÇÇ­3qu·ü}ÿÂ£P¼‰xÿ›ó›‡ÇÃë£«8/o¢ Ç3¾þæ¾wÖ‹âzÿ«DA„aÁÇ_1Êv4î;7××ÝÎûQèIÚ­°)EÑõŠn|†Úuù7ƒQ&?] ?é'Ç ÐñùêÙ†]P´ìB¿âe
»$œm¦&ãîÙ Ðƒ€£	ƒSã“÷?oÂE‰û£()¦Ê$âW2ðƒ&!GûãC~Þ„!_’îz’ù+ 7að|ž&nð}ò6aÈ—ìòi3úèã‚ïXÒ—yr0;$ÒË±x‡¥¿[,º|">M½ô.?Ÿtèò‰ü4õÒs,aå“]>‘Ÿ¦^zŽ	N>éÐåùiê¥ç˜àä“]>‘Ÿ¦\ºŸÃåç“×l‰ü4õÒ‰à´t¸fKä§©—ÎõpCŒ™èÒfôê¥çx™2Ÿt¸fK¨$º9"@M¹t®[Af¤Eä§™£z9">ÍåÐÊéiæx„˜‰¤Ï«•ã2ð1IŸS+Çfàb&’>§VŽÍÀ#ÄL$}^­—Gˆ™Hú¼Z9®
3‘ôyµr\!f"ésjå<¶¬C/Gä§ãha&Rþk^î›7Ër|Ì'š9">M½ô¯›ä“ÍŸ¦\zÀ6à¡™#âÓðÐÌñiê³Î&š9">Íœ{!f"é¿fæ~ÜÏ Ÿrèåˆô4õãËÁ#ÂL$ý×¼œ¦3Ò"âÓÔKçZŒE„™Húœš9¶Ÿ"Ì|HŸS3Çw¯C3GÄ§4à¡™#âÓ”KÙ²ÍŸfÎcz9"=M¹rk¼c–	‘žÆ ýëþ>×þ†™éiê<×þ†™±Eê¥sí?@˜‰ b‹Ôx®ý 3Dn‘úÇ:×J4„™"¸H½t®Ù:„™"¸H½t¶
Ìœ ‚‹ÔKg«ðÈÌ	"¸H½t¶
Üœ ‚‹ÔKçªðg"ˆà"å7¶Ù
Ä‚"¸H¹t6¹ ‚.2ÇÃC0ˆ ’‹Ìñð"ˆè"s<<ƒ"H½t¶
Ý‘dŽ‡‡`A„ ™ãá!D!@Ê+<›‡‡`A„ ©—ÎTá%$ƒ"H½t¦
/!D!@Æxx™ ƒLu4ˆKGƒ—Z¿–êhÐ(—^k¯©Žƒú°$ëÍÖk}Øu4¸
,ëYlž¯–6öKK‡½§j­Þ»öòÊêåÖênÿbpµ}~Z¶—WKãþ
Üôv4ŠŽW–í¹ÎßìvSWÄÁ·AðG
+X‚?¬õÏ2‚_}m¤ÛI¤‚rã¬Ÿ´§·»ûåŠïû› nùîõùa{àn½ô×Ö®Î6w§g=ûøì—ƒ/‹Qt…(¸‘'óý¬àÛŸ®ˆƒï à
¶à×3G~UfüF³6¨5ÛN£ÜvãàË¥»¾³ÝõÃòu«¿¸~yÖë?>…ö°rrw²sð°ÔõïÝZ©“¾Ôüx\;n ì·àËtð'WÄÁwQð%Wð­ú°•üš]ßù¾‘J÷Àõkm·ô|ürÿè</Z/÷ppqò´¶WÚÛYð¬›¹±zÜìÖÒÁ×ÚH%
¾S´ý‚vèg5R±?] ?éê'M$ÆífxÚEŸî·•´èÖÊó´ãl¤âò4Ry_¥TÕHåsŒâ$'“8¿’¯©|×âi¤äÈÀ©¤3œãL2àþJ¾j¤òuB‡£‘Š]ðä÷øI#•D
¢Y…oý—t§ŸÞ;‰Ðß8Ñâ_óùOïÿ>Z…A<h)šbÔk*zôÛ®ÈöãVèº–¸á»móþëãÇÿoúÇã¡ƒçˆ„Ð·°xXÂ¶3!.Š|þn‘tn¦éÄ•´t8G¤€3µH'®¤¥Ã
8S‹tâÊ@Z:\ñ§€3µH'®¤¥Ã
8“Gú7ËÞÄÝ½´t¸âOgêÈ:õühZ:\ñ§€3µHg{¸Á
8S‹tâžnZ:\ñ§3Í’Ý…œ©C:×­‰C‚Î4J9ôrn¦QÊ¡•£`32ð7$(ØL~†ÍÀCÞ `32ð7$(ØL£<ä
	
7SËCËÀCÞ €32ð8$(àL-Ó6.C‚ÎÔr¯se‡œi’£¼!Aáfj¹Õ‰g†ÓÒ¡™£p3µÜêÄWÔÒÒ¡™£p3udÚ -š9
7Ó¬Í…›©%ëlÒ¡™£p3µdí^‡fŽÂÍ4êÙ½›©e¼s-Ë¥`?ÒçÔË±Ýê)ÊÎD:…›©ã±Î–õÞæCúœš9¶Ç:ÄÊ
7S‹t®Ù:ÄÊ
7Ó,éÐÌQ¸™:¤SP¦¥C3Gáfê(sl·:ôrl¦–u
¶½›©ÅÆrí?@ªŒ `3µHçÚ€TAA¦iY¨àÚ€TAA¦i‘Îµÿ ©2‚‚LÓòXçZ‰†TAA¦i‘Î5[‡XAA¦i‘ÎUá!WFPiZ¤sUx–dšélº9
2MËt    ­ÂC7GA¦5{`AA¦åá!XFPiZ,
W…‡`Aa¦åá!XFP iZ¤sUx–jšé\‚e…šf”‡‡dA¡¦åá!YFP¨iFyxH–jšQ’e…š¦ÅÈ²Uxèæ(Ô4-Yg«ðŸÝÜT'†8ö,D£œÕ‰aËÉèÄjƒq±¿(ƒ
ùlï9Ò¾­Ýž–*Í›ãëÃ¥ë‡ÒÙIå`ð<´Ïzû»[ã¾	£P¼åï½¼¢ô
¾íIW‚6SWü·ã%^hyºïÜ¾o5ÄžjôÇ¼ãÎn
«ýgY+²d¶óÍAçñç>Kíÿºstßþö¶{ß»y¿ÄÇÙè÷_ùG¸Ÿ~e4œR´žÉ¹úñôÙn$¿h[i[–ãg
²­hÆx!8Wÿ¯ê-!³ÇÔTŒâ$ú$þ¯dà_Õ["_’ó…I‚_ÉÀzK„<½%ñ}òö–È—<o¡­QD=KÚ™ý=’9˜ýnç0ïXúø»ÅÒá¼…ÂÕ!=‡‹Ë§N[(,PÊs˜¸|Êá¬…‚åQþÍ»9bóI‡³

TGÒEŽ÷HòI‡³

T‹ô‹3ù¤Ã5h

T‹ô¯‡æ’J‚‚Õ"ëÑJ‚‚Õ"=ÇâL>ép
šÂ5K:ôr¨é\U#”((Pu¶" ­…ª#çl5Z9
Ô$ûŽùI¨Iöã“(P-ÅË¾c|j”}Çø$
 Ô(ûŽñI¨Qöã“(P£ì;Æ'Q8 Zì[Ö‘““¨Ž¬çx[,Ÿrää$ªe¼³IGVNR0 Z¤çx"Ÿtäå$ªeÎÆv«#3')P³<2s’‚ÕQà%“tÒ“$jÒ½nCz’¤`@µHçRŽ¼œ¤P@µT9& o[ÈËI
Ô¤o[ÐËQ( Z¤3-ÅÚ4s
¨élš9
Ô¬{š9
TËcmÀC3G¡€j™²²eš9
TÇ€ç24r")PÊ¹†;„œH
T‹•cÚ}°!äDR Z¤3m?Ør"‰@#õ6¦í BN$h¤^:×äBN$h¤^:ÓB´
!'’4R/íÙ½h¤^:[…‡^Ž4R/­ÂC/G©š«ÂCÊ‰$ÔKçªðs"‰@#õÒ¹&/s"‰@#c,<ÄœH"ÏÈ
1'’42ÇÂCÌ‰$Ì±ðs"‰H#s,<ÄœH"ÒÈ
1'’ˆ42ÇÂCÌ‰$"Ì±ðs"‰H#s,<äœH"ÒÈ
9'’ˆ42ÇÂ'8'SÝâ/ÀÒA6ÊµŒî-§öšêÎðRë—d½ÜqêÃšˆ»3œnûíƒãýêÒæÊëýÝ¸éïí ËÍµÃµf{q¯Ú¹Yßïœwý‡å¶õ÷Ÿdw†±]Ý‚¢åÜÐ
ÃàovkŒ©+âà'ýää÷ÛM=ë9îpÔ)Á™£YÃ.ÙäßÝË 4'™ŠQœ¤­gÀµ~%ô^ŽÏÓËÀ“ßg g/ƒ|HºëIÄ¯dà ½òÜ9zx9î¼½ò¥ »|ÚŒ~ôñ¡ëGŸŸ' „Xz¶©ïK‡.Ÿˆµcþ
³•Þˆ,!º|"×N}ÖéÈ>K‡ IäÚ©Ï:½YB:tùD®ú¬Ó‘%¤C—OäÚ)—þ\mB:\³%ríÔK§³PÒáš-‘k§^:×Ã
p$‘k§^:½…tB:\³%‚í’Ýl§\:Û­Í‘kgŽrèåˆX;å††K9ÄßH"ÕN½Ÿá2ð#‰T;s<ÄßH"ÕN½t.ñ7’Hµ3ÇÀCü$bíÌ1ð#‰X;s<ÄßH"ÖÎñ7’ˆµS¯³ez9"ÖÎ/ é7’HµSîåü sI‡ôI¤Ú©—N'b$¤C3G¤Ú)—þ0uB:4sDªúÏ6à¡™#Rí”Kÿ„>!š9"ÕN}ÖÙîuhæˆT;cfë~#‰P;õãËÁCø$BíÔKgË:ôrD¨zé\‹±4sD¨9>jù>§fŽí^OR>¤ÏéÊÛ€O¡I>¤Ï©™û±5!š9"ÔÎ˜)+$‚H"ÓNý:Ûx‡^ŽÈ´Soc¹ö D™vê¥sí?@&ˆ$ÒÔ/Tpí?@&ˆ$ÒÔgkÿ2A$ÿ£þ±Îµ
™ ’ÈÿQ/k¶™ ’ÈÿQ/«ÂC&ˆ$òÔKçªð	"‰üõÒ¹*<„‚H"ÿG½t®
© ’Èÿ1gö± ’Èÿ1ÇÃC.ˆ$òÌñð"‰  õF–­ÂC7G$ ©Ï:W…‡`ID ™ãá!D@æxx‘D9‚A$dŽ‡Ç`"Hý2<W…Çd"H½t¶
Ý¤^:S…w0-€VÑ
¡g…v&ý7O³N·X:ªð6
¤A:¹Ì%¥£
oÓ(@¤“Ë\R:ªð6¤A:¹Ì%¥£
oÓ(@¤“Ë\R:ªð6¤^:ýeø¤t4_·i 
ÒÉ;­Iéh¾nÓ(@¤³=ÜÐ|Ý¦Q€4H'/P%¤C^€MÃ ™$¹9›†R/ëV‡¼ ›F2H9ôr4AÊ¡•£1€2ð`Ó@xH
°i ƒ<¤Ø4AÒlÈ i6d‡´ ›F2ÈÀCZ€M£ i¸×Ù²½dŽ£´ ›Ò0ÞÉ  ’Ò¡™£A€4H'ï·%¤Ã6Ú6Ž¡^:ýìGR:¬r4<†é\÷:l£mÓð¤s-SØ°ÌÑð¤s•¹TëésZæøîu8g¥á1LðpÎJÃcpHÿzƒ™þ¦dR:œ³Òðæ˜9Ø-Ù¦Ñ148x¶ñ§¬4:†3Çµ2 »%Û4:†é\+s°[²MëŒ®A:×Êì–lÓ:£kÎµ2 »%Û´Îèë\k4°[²MëŒ®A:×œvK¶iÑ5Hg«ðÐÌÑ:£kÎVá¡™£uF× ­ÂC7GëŒ®ÞÂÓßMJ‡nŽÖ]}ÖÙf/°a²MëŒn‡‡
“mZgtƒ<<l˜lÓZ£äáaÃd›ÖÝ &Û´æèyxØ0Ù¦5G7ÈÃÃ†É6­9ºA6L¶iÍÑ
òð°a²MkŽn‡‡“mZstƒ<<ì˜lÓš£kÎUá“§Èµñxg!×ºµr5ƒ\{6¨õRäÚA}X’õfëµ>ìŒÈµµöÖþšÛ}Ú¨ß;N§þòt½tÝ®¯nzÕëµ—µÁÂ¶Xìì{Îiãìï?Ir­ûVr­EÇ-8¡#Â7p­›ŒýÇqè%
½Ïú³×zù"úfÅjì|zëòþtãðöü®w*
+•NgçÈÚØÊÒó`gspé÷–J‹—‹å{1øýÐûE[Æ‘
¢{*;öSWÄÁOúÙ	0uÌ
íŽŠÒ.„¶H™uÇ[¾å¹®ô}Ð` ,Æòsh°›©Å@Øf×û•ü ò@ƒß'kÐà|€ØfÿW2ðhpŽä âûä…çKžeÐS¢w
ãˆ È“ƒÙ‡c–¥¿[,Î2hlõÒsØÍ|Êá$ƒÆ&Q¯<‡ÛÌ§Î1hhõÊEŽã\Òa#o›†&áþ
® Ç
/ù¤ÃcšDCÖs¬"å“WŒih
Òs¼Ñ˜O:\1¦¡I4Hçz´ÁNÞ6
M¢AzŽU¤|ÒáŠ1Mb’tèåhlõž­ÊA+GC“hp±\Ê¡•£‘IÔ+g«qÐÊÑÀ$æØwØÅÛ¦qIÌ±ï°‰·MÃ’dßao›†%Ñ Ë¾Ã&Þ6Kb}‡M¼m—Ä 
›xÛ4.‰A3ØÄÛ¦qI4Ø6éÐÉÑ¸$ê¥çx­-ŸrèähX
ë3lÒ¡•£aI4HÏñ¾G.é°‡·MÃ’¨ï’ëV‡=¼m–DCçð°‡·MÃ’hÈ:›thæhX
Yg»×¡™£aI4HçR½J¢aeŠËÁÃÞ6JbR‡^ŽF%Ñ k)6„fŽF%1©ÀC3G£’hÎt¯»4s4*‰9Þ…íúm•DÃ”•-ëÐÌÑ¨$ê¥3wë§AIÔ+gîÐÊÑ˜$¬Óîƒ‹›õÓ˜$¤3m?¸¸Y?‘I¢ÞÆ2m?¸°Y¿Cd’¨´1M^\Ø¬ß!2IÔKgZƒwa³~‡È$Q/ëÙ›õ;D&‰zé\6ëwˆLõÒ¹*<ìÖï™$êm,W…‡íú"“D½t®
ûõ;D&‰9“Ø¯ß!2IŒ±ð°]¿CD’˜cáa»~‡È$1ÇÂÃvýJ¢þÙÆVà¡™#RIÌ±ð°]¿C¤’˜cáa»~‡H%1ÇÂÃvý‘JbŽ…‡ýú"•Ä
ûõ;D*‰9>VB3G¤’˜3{‘ŸÝÜT/ƒX9K/·Ö¬%{Xõ~å¥öšîeÐh¶D½Y²kÃ
;îeÐ¾y¾ÄâÕòéAo}°µà_ßU+‡{µÁf«²q}×¾[Û«´O«—[ãÎ½Æ>õ2p
Âa»?ÿÈçv¾_¶S¡ý_o|MÎ†2(ÚvA¸žçùo

‚D¦¯ˆ3à£„L¸°jÃRFÚÃÚÒ÷µÚöcû´wÛo­­úÕææ}Øly•ÛÓ[÷z¿\»ëžílû5¶¸~AXVAeÁ™1¶_VÁ
-Û÷²30}Eœ d`Ôê÷ç¨—·¬F9•Qk¶<8-×Ú«®xxXÜÛèoî=l.zk òà¤·þr;”½£ý…mq'¶úµ‹œÒ/D(Ö .~VÑEË¶;+üî§+âð‡(ü‚)ü­A½ÜI‡¿_µê9JèÝ­ìÔe°Z^í,ž>4ƒÃÅjÝ>mno^
V–ö¶o+­åËpÂ/¬¢B•÷Ìúã~º"
V3~Éþ(œgáïˆFŽÑo5÷ËG‡ÁÃÆ­¼8:xÞqV¯¯+ ­Žl¬œ6ëõ…òÊÒzÅ³[yÃ¯ì	ðž0zÈFOXÏµ%ÈÀÔqP+§QçåŸg Ñ<ÖúíÏè—£žA©VNkç +âö¸}Pk¥¿Óh->ì—W‡ ÕÚâÁp½tÜžm.Ôý¦ý|sÚ>:¹É
½Ð:ò…Stƒ¢ã\Ç·ä{ÝÓq‚>}EwÔÇiÔöù§qojåŠ¨÷k©¸×ú[2Ëû$û8=5v½¥Ýƒûaå¦úz~Ùi®w6šOâÆv¶_:×½;·±¾&÷oÒáÿA'Ïž¥S|·èÊ¸¨D5EJ?£“´>] ßFÁwy‚ßlÛõæV2ø/õa[ÔÓeç    ¥Ö‚_î8õamüÝá­Þ<ÔV¯ŽÂµÚ°Y³Ö:ƒš]“K‹ÝîùÎMà¬<WOª­tðÁB•×)ø®ïï
Ì¦šÇ‰?ÑóvúŠ8ø
>Gó¸·à7’Ü·à;YÜäÈ¯Þ.È¥º³^;=Z8>\ØØëwWe`Ÿßî/‡§/+Çíãž}â,¯f¸~#?¾WŒŠš+méy©‘ÿü©+âàÃîMo“ÍüÝ›D3þt¿=É„z¹Zr60
˜˜…ï×ü¼Yªuâ[>BÇ?¹1‰øñÿª}™ü2þ6Sû2+G¹œíËrÅ?¹‹2Ž¿gýFüéÍËâ)*O÷2÷ûäí^–+x3gÖ-¼I
¼‚å¹~˜¹ÞÅÐŸÒz¢|üÝbép3gf­.é”ÉYÒ!ÈÊ™™E«K:¥Er¦t¸™33‹V—tJ‹äLép3GÎº…§K:¥Er¦t¸™#gÝÂÓ$„˜Ï”7sä¬[xº¤S(™ÒáfŽœu
O—t®‡Y9rÖ-<]Ò)p›LéðÕœ™‘ÛÆI‡nnfä¶&él·:4s3·
S1VÎÌÀmÓ”C+73oÛ4)VÎÌ¼mÓ<¤X93ó¶M3ðbåÌÌÛ6ÍÀCŠ•33pÛ4)VÎÌÀmÓ<¤X93·M3ðbåÌÜÖu¯³ez¹™Û†9±rfæm³)ÿút¬Ÿ£ÓI>éÐÌÍÌÛÖ%ÂêË”ÍÜÌ¼mMÒ¶ÍÜÌ¼mã<4s3ó¶ueM:4s3ó¶»×¡™›™·­I:Û­½ÜÌ¸m]ãËÁCX33nÛ¸½ÜÌ¸m]Ò¹c!-È™·mZ‡´ gfÜ¶i÷:¤93ã¶ðÐÌÍŒÛÖ4o
Ù²ÍÜÌ¸mÃ¦¬äÌLÛÖµNÁ6Þ¡—›™¶­kuŠkÿÒ‚œ™iÛº¤sí?@\33îS—t®ý È
rfÆ}ê’Îµÿ AÎÌ¼OMÒ®•hHrf~ê’Î5[‡Ä gfà§.é\ƒœ™Ÿº¤sUxHrf~ê’ÎUá!1È™ø©K:[…‡nnfà§i³Hrf~šæá!2È™øiš‡‡È gfâ§i"ƒœ™‘Ÿ¦yxˆrff~šæá!2È™úiš‡‡È gfê§i"ƒœ™©Ÿ¦yxÈrf¦~šæá!3È™™úiš‡‡Ì gfê§i>Åšœ'Ÿ=ŸMyXaÁv,K8YÊ“ÍÛþÝ êSMäÞ20£8IS9É€ü•|u¤Þþ2ŽËs¤Þñ¾Ï@Î#õy2à¥J“Ø¿’¯ÕÝÔÀÏ‘ïÏÔËB|Ÿ¼gêó¥ {lÚ¤2uI
í¸‘WŽšHRzåŽ¥O¾[,zì™áÃš¤SúÅf*‡{fø°&å”v±™Ê¡Ãž™=¬I¹ ôLMKæŸïôIXzGå&þê^çòæÏÑõÓÑåß¯âà6-§èEé¼PZ¡›‡ÒÉUïú­ÏPôßÇÏþ™ü¬o…ãÁ™ÀÌŒd])¢tôÍp&03#Y—t
™"S:œ	ÌÌHÖ%NÍ”×ugf$ë’Îö†ëº33’uI§ I²¤câÔÌdã¤CÏ93$Y“t®*‡S33’5)çºÓ1ojfD²®y—rh9g&$6ÍÀ´©™É†M30mjf>²YÓŒH:4r3ó‘M³ï˜653 Ù4ûŽiS3’M³ï˜653!Ù4ûŽiS3’u=ÔÙ²Žœœ;3!Y“ô¯!åSŽœœ;3 ™Mù7ÇBÙ¤#+çÎHÖ%BWË”Ž¼œ;3 Y“tÉv«#3çÎH6nÀ#3çÎHÖ•u6éÈÌ¹3’»×‘™sg$ë’Î¤ÜF^Î™¬keŠËÁÛÈË¹3’uIç*ð6ôr3’uIçZŠµ¡™›¬K:W·¡™›lÜ½ÍÜÌ€dã<4s3’5=Ûl¶¬C373 Y“t.CÉ!îÌ|dMÊÙ†;´r3ã‘uY9®Ý qgÆ#ëš»p­ÁCpˆK$å¨Ï:×Î
‡¸DRŽú¬sM^ 8Ä%’rÔKç*ðâI9ê¥³•9èåˆ¤õÒÙîuèåˆ¤õ^Ž­ÂC/G$å¨—ÎVæ ™#’rŒ1sâA9æ˜9Hq‰ s
D‡¸DPŽ9>¢C\")Ç3 Ñ!.•£^:×[âY9æ˜9ˆq‰¬s,<D‡¸DVŽ9>¢C\"+Ç
Ñ!.‘•cŽ…è—ÈÊ1§ÂCvˆKdå˜³Ÿb‡LŽ<ÙÏ¤\XE[Â úË0Kù·qú±? ÇýûcÿvÁÏqè<ç±ÿìÆ
Ó1Š34•“¸¿’¯Žýé£øôcÿS¡ýù±ÿ|HzÛI¼_ÉÀWÇþ¿Î@Èrìß.L†Ã±ÿ|)À›4©Œ?^‚Ð
ìÌÖ
môÈý¥¦¿[|ú³ô§ÎíÔZEü§¼ÂG Ÿ]»hù[Z®›)üíàóû'÷N;G÷Ýîýß·½Í÷¿‹Ú»-e~ÿ¶-}çNhÌ1ŽÜ}³Kîõ)w‘t8I AÇ4[r—¨¤t8I AÇ4H'w‰JJ‡“tLÃ€'w‰JJ‡“tL½t:K4!2i\tLƒt2¨").ùÒ cêïu:K4).ùÒ c¤“ûû&¥Ã%_uÌ$éÐŽÒ¨cê¥³ÝêÐÌÑ c)‡^ŽÆ3H9´r4ä˜Ai\rLƒt.‰4.
9¦A:—‡D—†Ó0wá2ðHãÒ˜cê\i\sLƒt®
‰4.9¦aîÂeà!‘Æ¥1Ç4”9¶¬C/GcŽ™ãh Æ¥!Ç4Üêd~lR:4s4ä˜éd\AR:4s4ä˜zétVtR:4s4ä˜Ai\rLCÖÙ¤C3GCŽt¯C KCŽ™ólƒ<—FÓ0Þ¹<äÑ¸4â˜Aòh\qLƒt®ÅXÈ£qiÄ1“
<4s4â˜I÷:4s4â˜Iš9qLý”•ŽÓü,ÝOX>¤Ïé&+S÷!øÄ¥Ç4¬S0w‚O\pLƒeÚð!ùÄ¥Ç4HgÚð!úÄ¥‘~4HgÚð!RÄ¥‘~4HgÚð!RÄ¥¡~4<Ö™V¢}ˆqi¬
Ò™fë>DŠ¸4†Žélš9CGƒt®
‘".¡£A:W…‡H—ÆÐÑ «ÂC¦ˆKcè¨—Î6{P—ÆÐÑð^—‡‡T—ÆÐ1ÈÃC¬ˆKƒèäá!WÄ¥Qtòð+âÒ0:yxÈqiõKlrE\HÇ ¹".
¤c‡‡\—Ò1ÈÃc®
¤£á^çªð,BéäáS`‘É‰è·¤Ïz"Z¯àE5Òš»‚§+@ ¼+ÀTŒâ$Må$Á¯d€ÞÀÉÑ—áû® vÁ÷¿ÏÀÏº$2ô¶“„¿’tÈÓ#GW€@|ŸvH¤ {lÚ¤2úx¿àú~Ê¹ë
0õÝbéÈc{4ž‡tegrÒ‘Çöh@/
Y§»­ÏÒ!ïÅ£½4H§»­„tä±=ÐKƒtºÛJHGÛ£½ÔKÿÁ™œ„tä±=ÐKƒtú
	éhÅÔ£½4Hçz¸AÞ‹GziN_'OHG+¦èe’täæ<ÑK½t¶[š9ÐË åÐËÑx^æ(‡¸†ó2ÈÀCÜ‹GÃyiÎeà!îÅ£á¼4Hç2ð÷âÑp^¤sxˆ{ñh</õÒÙ<Ä½x4 —élZ9ÐË q/
è¥a²Î–uèåh@/ƒ
ôr4ž—†[~ë³tˆ{ñh</
·:}Û?!š9ÏK½ôœ¹LH‡fŽÆóÒu¶Íç¥!ëlÒ¡™£ñ¼4”9¶{š9ÐË”g›“|Ãçé~Ò…;þý£?ÎÔ†;ú
Ò/xžo9™ïzMÚp¿ý¦·/~sù®iô×o½¹ßÛq¿1R#¹§]œGèLit2
w/×|²k<Ì¤Çt¦4:™é\KË]ãÑèdêk6Ûã
²k<Ì {=Å®ù>¯Ö”kÀ§ 1ÒçÔšþàMB:´¦4:™)&%R)
N¦aÕ…m¼CgJƒ“i˜Šqí¦@ÆˆGƒ“iÎµ›#‘
¤^:×n
dŒxD¨Žzé\»)1â¡:êë\ëê1â¡:ê¥s­=@ÆˆG„ê¨—ÎUá!cÄ#BuÔKçªð1â¡:ê¥sUxÈñˆPõÒ¹*<„ŒxD¨Ž9³HñˆPs<<ÄŒxD¨Ž9bF<"UÇ1#«cŽ‡‡˜ÈÕ1ÇÃCÌˆGäê˜ãá!fÄ#ruÌñð3â¹:æxxˆñˆ\s<<ÄŒxD®Ž9rF<"WGý¾[…ÿìæ.oÞxdáã?>Þ\tã#Á»¯kçÇ+^£·Vm
«¢Þ«>T¯·ÝÎRÕ«^Üîï.­……è¢ÛöþV¯Ñ¯Øµ~{Pkv^jÃ‹‡êÕ®_ýùµÞ/½4Ê¥acgÐ;Ù¯_v®Üóã½VôÁÕA£Y‹~¦í4Êm·zmª¥;o{É¿Û¶Ö^œÖÉÒa§·uu¶ðX;»z´j·[íjè
owëïû…â-ïs~óðxx}t'ðïåMäøoÆ×ßÜ÷ÎzQ\oG©	DA„aÁ³
Ž;¾b”íhÜ?vn®¯»÷SÒi·šÒ*
Y”VAø2šþ_&ƒ?uEü ?à
þk­ÙÊ~å¥ž#ø•ëþÆMy¡¾tS:ÞóœV¹¿¸±VÚZ]~ªw–Vn^v¯_6¶…?lÿ~ðí¢í,[HêŠ8ø!
~Èüz9käW¬¬‘_–d½Ùz­;"þ²}P²·_W–Ê‡ƒÚÂ]cë²¿5X®/,ÜˆÁ¥svZ‹ÝÒ•½¹|“¾«9øNQXGú¡ã½ßMêŠ(ø)ÚË¸+ƒ?n:0[Áu£ºVp×rÂ¬‚kùVä]¢»NAg‡£3ÉÔ‡ü¼3‰›©ÅHZûIÄ¯d€Þ™Äµx:“¼ïêst&É—äc’ù+øAg’€§3IžÞ0y;“äKžéÐÖ²¢—Ç—®Ì4~Éd¿äö³ñ³sLò°ôñw‹¥Ã™‘*È ýÏË¥NtˆTAåß,[s)‡ó"TP¹r‘cÁ>Ÿt¸jM„
ª—žã}£|Òáª5*¨^zŽE¼|Òáª5*¨^zŽJóH ‚Ç#BÕKgz´Áã¡‚Êm"Ç"^>épÕšHTŸu6éÐË©‚Ê¥3U¹ "x<"TP¹r¶" ­‘)¨\9[ƒVŽˆ4ÆÊÀã‘‚¦ø÷ òw    <"QP¹r¦9[ ñ;(hŒ} ~Ç#±ïÄïxD¢ 9öâw<"QÐûñ;‘(¨ÞÎ°e:9"QP¹ôoæS(¨~ÎÆ&Z9"PPý­žãu›|Ò¡•#ÕÏÙØnuèåˆ@AõYgðÐÌ‚ê¥3)‡ðÈ4çV‡ðÈT«swßñˆ<AõÒ¹<„ïxDž 9>ß™H'òÕKçZŠMQo>¤Ïé²ß½Í‘'hÐ½Í‘'¨ÜÂó
xhæˆ<AõSV¶¬C3Gä	*—Îåh0å…ˆT®œk¸cÈ
‘&¨ÞÆr-DcÈ
‘&¨^:×î†¼1^êm\[Nòâ1^ê¥sMY!äÅ'b¼ÔKçZˆ†ŸˆñR/íÙ†¼œOÄx©—ÎVá‘—ó‰/õÒÙ*<òr>ã¥ÞÆrUxÈyñ‰/õÒ¹*<ä¼øDŒ—9“Èyñ‰/åSV.
1/>‘âeŽ…‡˜Ÿˆñ2ÇÂCÌ‹Oäx™cá!æÅ'‚¼Ìñ±óâA^æÌ^ æÅ'‚¼Ô¯IrYxÈyñ‰ /s,<ä¼øD—9>r^|"ÈË
9/>äeÎÄ-Åy™%êM¹W”vÁ
e}”8Ù¿„ó8}ž£Ä9ŽÓ¿[&Žãô ÊTŒâ$Må$Î¯dà Çé%Çqú|

r§Ï—¤·dÀý•|uœÞþ2¡Ísœþ½yËqú|)À›6©Œ>Þ-¸¶úªºbÒÛÅM}·X:ôØDž zéôži	éÐc‚ê¥Ó{¦%¤CM
ª—Nï™öY:ÖøD  zéôži	éÐc‚Ê¥ÿ€œ=6(¨^:Û’WL‰@AõÒ¹nXã‚ê¥Ó»]'¤ÃS"ƒÏ éÐÍ|Ê¥³ÝêÐÌ|æ(‡^ŽHà3G9´rD Ÿ9âj|"€Ïq5>ÀgŽ‡¸Ÿà3ÇÀC\O$ð™cà!®Æ'øL1ðŽŸØ¾ºŸ
íUjuðjÄqþxÆDŽ~ßÓûH´¾
ŒÛvQq·aß³Üà
tt-‚O?§ZP"9Ðœ‰ ÄìøDr úÅåG fÇ'’qb²ãÁêÇ;M(¨\ú°çŸ¥CÊŽO ªÏ:·’M(hÎ€‡”ŸT?àÙ¤CJ 4à¡	%‚y¶AÈŽOäªï\3Ùñ‰Ü@ƒžmÐË¹ê¥s-" ÐÌ¹xhæˆÜ@sîõÞåCúœš9¶Ÿâª|Hÿ53÷õÇ?€â&¤C3Gä*—ÎUà!GÄ'b•+ÿ8!z9"6P¹ôà€Ò¡™#bÕKçÚ7$ŸÎQ/kß’D|"8Gý¼kß’D|"9Gýck%’D|":G½t¦ÙzI">£^:S…!IÄ'¢s”—¹à€Ò¡™#¢sÔg©Â‡$âÑ9ê¥3Uø¢D|":G¹t®ÙKY">£~¯‘ÉÃ‡&âÑ9ê-
[…‡nŽÈÎQ/­ÂC7G„ç¨—ÎVá¡›#ÒsŒñð!Ä‰øDzŽ1>„8ŸˆÏ1ÇÃCœˆOäç˜ãá!NÄ'òsÔKçªð'âù9æxxÈñ‰üs<|‚'òpyóþÃ£ÍÆø7ÝøðïßîëÚùñJ§×è­U[Ãª¨÷ªÕëm·³Tõª·û»Kka!ºè¶½¿Õkô+v­ßÔš«6¬=T¯vøÂèÏ¯õ~é¥QŽþöuÐ;Ù¯_v®Üóã½VôÁÕA£Y‹~¦í4Êm·zm:O«úØyqOZ
CçÖê¼:{å²³ÞYÝZ{Z?ÚÞ®5ÎG/Ñ‹“ñ…â-ïs~óðxx}t'ðïåMäøoÆ×ßÜ÷ÎzQ\oG©	DA„aÁ³
Ž;¾b”íhÜ?vn®¯»÷óÐi·šÒ*
¿(ì‚ž%Þ^Ö”ÉàO] ßGÁ\Á—õæVFð[¢¾”~}XŠ®o½Ö‡ ÿtÏjÙ[
ûãj­¼Ù.»õƒ«Ó½a%ðýû×‡ð¡Ô·¯¶÷VnwËéà»zƒýç:×±ÂÐþ›ÙcúŠ8ø
¾ä
~ÿ"+ø²±óýÈoÔ¯zÝué®ã=¯-®¾<.?¼œW·¯}c©~ðÔ(µ¬‡ã†waýúÈ—ÑÐ¶
¡/¤çdüé+âà‡(ø6[ð£@fß©÷RÁ©õ£‘_î8õam4òw«+ÝÍ¥ç×½gÙ»¨]VO¶«‹þò^ù<ºKýêNÿáúzáu¿•¾£=øÒ‹ŠŠ?O2kþôQðS`™Ió‹qŸˆ™žvRFÿE_;|í
`|¦0ã_£ªÌtŒâ$'“ø¿’4€±8ÀØ…Àý>?j “Ì@rŽ3É@ð+øªÌ×ˆªK˜@|ŸŸ5€I¦ ÏµH
‰ñÇÛ…¸Em8w
`¦¿[,ÎµhèF
ÒÉ3ì¤t8×¢±5H'Ï°“ÒáÊ9Ý¨A:y†”WÎiìFéß¼óDža'¥Ã•s»Q}ÖéçG“ÒáÊ9Ý¨A:ù%¿„tÈûñiðF
Ò¹nøãÓà¤“÷F“ÒáÊ9
Þh’tèæhðFõÒÙnuhæhìFƒ”C/GC7¤Z9¹Ñ i?4r£AÓ~häFƒ<¦ýÐÈ¤sxLû¡¡
2ð˜öCc7dà1í‡Æn4ÈÀcÜÝ¨á^gË:òrÝhŽ£´Ÿ€†nÔ0ÞÉgo“Ò‘™
hèFõ‹Sôæ
IéÈÌ4t£ú¬ÓÏÙ'¥#3ÐÐ&
xdæºQCÖ¹¤CÚO@C7jÈ:×½i?
ÝhÎ³
Â~¹QÃxçrð)ØÏ‡ô9õrl>EÙ™H§¡5HçZŒMám>¤Ï©™ã+ðÐÌÑÐêÍß½Í
ÝhÒ€‡fŽ†nT/~1)š9ºÑœÇ:¤Ê4r£†u
®ñ©2Ü¨ÁÆrí?@ªL@#7jÎµÿ ©2
™¦A:×þ¤Ê4dšé\û*Ðië\+Ñ*Ði¤sÍÖ!V& !Ó4Hg«ðÐÌÑi¤³UxhæhÈ4
³®
Á2
™¦!ë\‚e2Í Ù
Ë4dšA‚e2Í Á2™f‡‡€–€M3ÈÃC@K@£¦äá! % QÓòðÐÐ¨iyxHh	hÔ4ƒ<<$´4jšAZ5Mƒt®
	->f‡OZ¦:ŒÛü´£Á™Ý(—Ò
šm§–ÑË#ÙNÂ_¯\µ†ööáÚSE–Žìíûó-ÿòdu%|è¼ú¯ÕÛ{¹¾zÙ÷øµvvXtDA®oÉìvÓWÄÁOúÉÉiî·ôÎxšÛ±Š®,Héú æþAG©£ÁøCTu4˜ŽQœ¤­g °~%?èh x:„òûü¨£A2Iw=É€ø•ü £AÀÓÑ`ÒLCYGƒd
°Ë'Íèã·
Â
=ßU´˜AvùÓß-–]>@©A:Ùê&¥C—OCPjN¶º	éÝÐ”Ò¿9ÖO¶ºIéÐåÓ”²N¶ºIéÐåÓ”ê¥ÓD%¥Ã5[‚RƒtòÛ6IépÍ–† Ô ëáÙ=
A©A:y“")®ÙÒ”&I‡nŽÆ T/íV‡fŽ† 4H9ôr4¥)Ê
‚{€ÒI‡VŽ 4ÆÀGÒ¡•£(5Hç1ð‘thåh J
sI‡VŽF 4ÆÀGÒ¡•£(1ð‘thåhJc|$Z9RC™cË:ôr4¥AŽz9€R}§ðNH‡Üž€ Ôp«“ß¹HJ‡fŽ T/~à5)š9€RCÖÙ<4s4 ¥†¬³I‡fŽ 4é^‡fŽ 4çÙ& —£ñ'5Œw. / —£ñ'M*ðÐËÑø“¤ó,ÆFÒ¡™£ñ'
*ð)\Ë‡ô95sl÷zŠ“ò!}^Í×€OJ>¤ÿš™ûzöB?””Í?iÎcrA~RÃ:Ûx‡^Ž†ŸÔ`c¹ö $ á'5HçÚ€\€Æ Ò kÿrAHƒt®ý È	h 
u®•hÈ	h 
Ò¹fë
Ð@¤sUxÈ	h 
Ò¹*<ä‚4é\‚AH½…§Ÿ†JJ‡nŽÆ RŸu¶Ù
Dƒ4A¢AÈ Ñ 
d‡‡h€F2ÈÃC4H@Ã äá!$ a€òð
Ð0@yxˆ	h ƒ<<FƒÐ0@yxÌ¡a€òð˜
BÃ iÎVá?»¹©Žñ­ÎÒÑÀi4«
:n­÷}Gƒîðn¸ñ¸¿^^_«Ÿ,­oôƒ“N]\oÜ¸gC÷i?Ü?¿½Þ_\®<­8ãþ¿ÖÑÀE[\Gz^vCƒ©
âÐ'Ýää,÷øPùlƒNíø8tôñvÖ ³BÛ^4+
ÁYîô3ð™úŒÍÏûÈìLÅ(Î@ÒÔN2`ÿJþUýre Ej™dÀù•ü ŸAÈÓÏ`ÒÈ¡ŸA¾`O›ÏGï|a»n' ³?üìFK·X:òø!
§^zÇ“O9²ø!
§^yÃ“O9rø!§^¹ÈñâA>éÈá‡4œé9fóù¤#‡Ò8p¤çXªÎ'­×†4‡ô¯7(DŽ—êòIGëµ!§!ël6´^Ò8p¤çXÈÈ%cBÎ$éÈË…4œzé\cB Nƒ‹åR­
§^9Wƒ¸˜F3Ç¾CZLHƒÀ™cß!,&¤1à2rÒpÍ\ ,&¤Aàš¹@XLHƒÀiÎõdƒ°˜3È¾CXLHƒÀi°3lY‡NŽS/=Ç›Uù”C'GcÀi˜©³I‡VŽÆ€Óp«çxå Ÿtèåh8
s6¶[š9NCÖÙ<4s4œ†¬³I‡fŽÆ€3é^‡fŽÆ€Ó I9DÅ„4œ†ñÎåà!*&¤!à*ðÒp¤s-ÅÐÌÑpø¨åCúœš9¾{š9Î¤Í
§aÊÊ–uhæh8õÒ¹
$‚„4œzålÃZ9 Nƒ•ãÚ}€@€Ó°NÁµý  !þ£¾¾sm?@ HH„ÿ¨—Î5y@ÿQ/k!AB"üG½t®g‚„Døzélz9"üG½t¶
½þ£ÞÆ²UxhæˆðõÒÙ*<tsDø1“™ !þcŠ…	Ù?ÆXx‘ !þ£^:S	é?ÆXx‘ !ÿcŒ…    	ñ?ÆXx‘ !ÿcŒ…	ñ?ÆXx‘ !ÿcŒ…	ñ?ÆXx™ !ÿcŒ…	&ÈT'ƒx¼³t2pÍNF'ƒ3·þšîdP–d½Ùz­;"îd°¸·S8÷ât§vq²wórvÚî‹íW¹i\8âlusçxïèìp¿ÛïŒû|t27cÐÕÉÀ.Š àÚ¶¥}|7ü©+âà'ýää÷[õ·SV!î“ð6°RÃÎ·<×•¾¸ôÿª^nv¦be 6í	‰Íø¢Û	ü@æI’WK°òñW‹Ç^Rùdìy¿2öþU]r½f’ÿW2ðïêâ/x~C[Ë`¸ý¿Þ“ËÓÅ!ßýç7DøòÊ—ÃãçS§7Dørå9,~>åpvCdß©Úå°øù¤ÃÙ
‘}§^:×“BrB"ûN½ô«ôù¤Ãµj"ûN½ô/‘æ“×ª‰ì;õÒ¹m’Ùwê¥çØœÉ'®UáwI‡^Ž¿S.­ÊA+Gdß)WÎVä •#¢ï”+g«qÐÊÉwÆØwHÈ	‰à;cì;ä„Dî9örB"÷Îû9!|gŽ}‡€œ¾3Ç¾C@NHß™cß! '$‚ïÔÛ¶¬C'Gß)—žãô[>åÐÉ¹wêÇ;›thåˆÜ;å‹ÐyNvç“½‘{§~ÎÆu«C>NHäÞ™3à!'$rïÔgM:4sDîú¬sÝëáoê³Îåc!$&$Âß*sÐÑáoê¥s-H:ÐÒáo•9hiˆð7ƒîuhiˆð7s|
Kò!}N-Mžã@ù¤CKC„¿)÷ð\uL!²ß”'m¸ÃÕ)"úM½—ãZƒÇ8"úM½t®ExŒ!‚Ô×w®Ex„±-"øG½t®Ex„‰¤Ï«—ãZŽE8Hú¼z9¶gðr‘ôyõr\á@"ésêåò„Ê'x¹Húœ.Oå9•O:0s‘ô95syBå“Ü\$}NÝÛäA"ésêæ¸,<"‚DÊçÔÌ±Yx„±-"úÇ
 ‘ôy5slš9"üÇ
 ‘ôy5s\!A"éójæ¸,<B‚DÒçÔÌ±Yx„‰ÏžÏ©t®
˜ ‘ôy5s\1A"ésjæØ,|‚	2ÕË N:G/ƒ‹A£\ÉèepáÔvR½^jý’¬—;N}Xõ2«½ƒŠì¾ž^uÖïm¹é
;AÉktwÏ¯OWÄpåõá²¾½XªŒ;|ô2pþÑÛËÀ):²Z®ïˆ·^N:ø“+âà'ýää4óÛ°›õ4³[´£oîËÀu²†–çøo+èeà1õ2ÈÏ{8Ù˜ŠQœ¤­d ü•ü«NôçË@Ò]3Z¿’×‰þ|)À.Ÿ6£w‹ŽUð„ýOžšÊçXÆÒ'ß-’Ž`1¶EDÀ©—žÃåç“]>‘§^zŽ%¬|Ò¡Ë'2àÔKÏ1ÁÉ'º|"N½ôœ|Ò¡Ë'2à¤ý¾‰Ÿc‚“O:\³%2à”gÝÏ1ÁÉ'®Ùpê¥³=Üàš-‘§^zŽ—)óI‡k¶DœAÒ¡›#Bà”KçºÕ-Æ¶ˆ8s”C/GDÀ™£Z9"ÎX1‘ôyµr\±b"é¿få4xÄŠ‰¤Ï©•c3ðˆIŸW+Çeà+&’>¯VŽ­ÂC+GdÀ™cà+&’þkVî›LY—ˆc[Dœ)ŽF"VL¤|N½œŸãàc>éÐÌpê¥çxÝ$Ÿthæˆ8åÒ¶ÍgÐ€‡fŽˆ€SŸu6éÐÌpêWcÙîuhæˆ8sžmÐË	pêÇ;“ƒ—IŸÓe9¶P1¶EDÀ©—Î´+4sDœ9>jù>§fŽí^OqB>¤Ï«™cðÐÌpÊë![Ö¡™#"àŒy¬#.F¤|Næ<¶ñ½‘ §~òÂ´ÿ #’>§fÎgÚˆŒIŸS3ç3í?HDÆ°-"G½t¦ý ‰È‘ôy5sL+Ñ‘1"éójæ¸fëˆŒIŸW3ÇUá#’>§+sW…GdŒHúœš¹€­ÂC7G¤à¨—ÎVá¡›#Rp”Kg›½ 8F$}NÝ›‡GtŒHú¼º9®
ð¶EÄà˜ãá#’>§nŽÍÃ#<F$}NÝ›‡GxŒHú¼º9.ð‘ôyus\á1"éóêæØ*<tsDŽ9ñ1"ésêæØ<<âcDÒçÔÍ±yøcª£A¬œ¥£ÁK}XKv4x­•Kví5ÕÑ`P–d½Ùz­;£Žw×O7õ³æ•Õó/ÝûÆÃÊò@xæŠ_qöNvŽKG«âør©&ÏÆý >:¸ÿèíhà…S°;”ÎßìvSWDÁO:&§¹Ç‡šgv~Q/út‘9ì¾å³ÿ £ËÓÑà½ÿ!GGÐÐc*Fq’¶v’ù+øAG‹§£A#9;äË@Ò]O2`ÿJ~ÐÑ àéhðþ¸eéh/ØåÓfôÑÇ‡×
\+Ì“BCzß²©ïK‡.ŸˆCcþõ<½wWB94ùDšò¤Ó[w%”CO¤¡)WþÈiB:ôøDšzéôÖ]	éÐãihê¥Ó»ï&¤Ã["
M½t:ê³tŒ‰¤Óæóê¥s=Ú0&’N›Ï«—NoºœWl‰ 8ƒ¤C/GÁ)—ÎUå1Æ¶ˆ8åVŽ­ÈA+GÄÀ)Ï9[ƒVŽHS®œË¾c\gŒ}Ç´"ÎûŽi1Dœ9öÓbˆ8sì;¦Å)pæØwL‹!RàÌ±ï˜C¤À©·3lYGNN)pÊ³N§Ú&”#''ˆ8õãM:²r‚S/NHHG^N!pêçll·:2s‚S^åø<2s‚SŸu.é#ˆ8sîuH‹Dœzé\Ê‘—DœúñÎåà!,F!pæx‹DœòÿX}B:4sDœAš9"Î {š9"N½t¶Í§þ=¶¬C3G„À)—Îeh DpÊ•s
wˆDœz+Çµû ‘ ‚ˆ€S/kû"Aÿ£¾¾sm?@$ˆ âÔKçš¼@$ˆ âÔKçZˆ†HAÄÿ¨—Îölƒ^ŽˆÿQ/­ÂC/GÄÿ¨Ÿ·±Uxèåˆøõ6–«ÂC&ˆ âÔKçªð
"ˆøs&/
"ˆøc,<„‚"ýGýöW‡PAÄÿ˜cá!Dù?æXxD 9BA dŽ…‡PA ™cá!D@ÆXxBA ¤^:S…·!D@ÆXxRA dŒ…·T©^ñ¸béeðZo^dô2¨ˆÆÎ÷½Vú¢yºp_½¾8ªuWžzÖÃq$÷qÓ½õ^ª­«þéÚmÅœ<ÝãÎ¿×ËÀÛD8=7A/ƒ©+âà; ø£F§,Áwjå³Œàw¥Tð_jý(øåŽSÖFÁomÔïjÝÐ+ï-n¶{¥•ã•­•ÃÚëbáõìåæ|ù¡v}½ç
_Xéà;zƒïzE'(MPþfvñ˜¾"~ÒÑNÑ¬ÏtÏ»~Ñö
ÒuCËËºç“ýK8Iä9DŸ£‘Äûd£‘Dv•éÅHëIÜ_ÉÀIžF“?o$‘/I?É€÷+øA#	§‘„—ãÈÛH"_
ð<ƒ´œ|PˆJ²:yr@Ø'·‹›þn±t8Ï ø4H'÷LKH‡ÀACðiNî™–”ç4ŸéäžiIépžACðiNî™–”Wi>õÒédÝ¤t¸jLCðiNÆ¶$¥ÃUc‚Oƒt®‡$Ö‚Oƒtr·ë¤t¸jLcð™$º9ƒO½t¶[š9‚ÏåW#h>ƒ”C+Gðdà!®FÐ |æx7±l3y¹ ¡w4mŽ¿úRui£ñg©±Ýlüý:RãeT«Æï‘Yq(\õ®ßÖ÷¢ÿ¦¾çÇÏºO¬!UGÐ8Í3 UGÐ8Í3 UGÐ@Í3 UGÐ@Í3 UGÐ@Í3 UGÐ@îu¶¬CËIšc¼ TGÐ8Æ;úœ”='È!ýë×ýddÈÒ¡ç¤qÕgxOJ‡fŽÆ	4iÀC3GãjÈ:›thæhœ@
Yg»×¡™£q
z¶A/GÃjï\2u
hR‡^Ž†	Ô kÍ8E´ù>§fŽ­À§P2Òçt‘í^O1\>¤Ï«™cðÐÌÑ0ê-<›”Í
hÎc²S¨a‚m¼C/G£j°±\Û$ž"h”@
Ò¹Þs‚ðA#DiÎµÿ á)‚FˆÒ kÿÂS
¥á±Îµ
á)‚ÆˆRÿX§Ó“Ò¡™£1¢4d«ÂCxŠ 1¢4Hçªðž"hŒ(
Ò¹*<Ä§#Jƒt¶
Ý¥^:ÛìTe‡‡AcDäá!AEÐ QyxHP4J”†ÍF®
	*‚†‰2ÈÃC‚Š q¢òð "h (
Ò¹<<&¨Ð@QyxŒP¡¢òð¡BEi˜´²Uxèæh (ƒ<|¡2Õx!~¬ó4^h”kYœÚë÷]/Ž÷ý§Fû¸wP:¯X‹§ÞíÃƒë%wwï©\n<Ö‚ÖFëfñ¼>øûÏ/w½pƒ¢å„ç[¾ÝõbúŠ8øI?99tþvÇÍzè<,Z²`9Žäj¶ÂÙx!Ï¡ó<ÆòóÆ
ÙM_¦ce Å’™d ø•ü«/äË@Ò]O2þJ~Ðx!Oó‘|ÿûäm¼/ØåÓfôÑÇGÉNhçÉ¡é¹·Ýôw‹¥#—/i°@õÒÉýÝ’Ê‘É—4X zåäönIåÈãK+P½r:8)y|IcjNnï–”Ž<¾¤±5H'whNJG+¶’Æ
Ô KJG+¶’Æ
äþM‹f®GDëH+PCÖÉ¹“ÒÑŠ­¤ÁM’Ž¼œ¤ÁÕKçªr­#i¬@
.–K9´r4T zål5Z9)Ðû¹:’
4Ç¾C¬Ž¤q
²ï«#iœ@ƒì;ÄêH(Ð û±:’F
4È¾C¬Ž¤‘5Hçz´A¬Ž¤‘5Ø¶¬C'G#ªŸ´‘ÉÇIåÐÉÑ@Æ;›thåh @
ÒÉ”‘¤tèåh @
s6¶[š9(Ð¤Í
¨!ëlÒ¡™£Í¹×ˆÕ‘4P é\Ê¡—£q5Œw& ï@ªŽ¤Í)ðŽ½
¨A:ÓR¬cA3Gš    SàQæCú¯™¹oø¿l÷:4s4P Iš9(PÃ”•-ëÐÌÑ@ê¥³èåhœ@õÊ¹†;$—H&Pƒ•cÚ}p ¹DÒ0¤3m?8\"‰”"õ6¦í  ’K$‘R¤þÑÆ5yäI¤©—Î´í@r‰$RŠÔKçz¶Ar‰$RŠÔKg«ðÐË)Eê¥³Uxèåˆ”"õ6–­ÂC3G¤©—ÎUá!»D)EæL^ ¼D)EÆXxÈ.‘DH‘9BA$‘R¤þÍX®¡ ’ˆ)Rÿlã*ð
"‰œ"s,<„‚H"§È
¡ ’ 2ÇÂC(ˆ$€Ì±ð
"‰  s,<¤‚H" È
© ’ 2ÇÂ'¨ S½âgK/·Þoeô28“õï{Øžl?V·êòâü¡¾°ñÒ—~ç|ýÐïîÊãÒpåñIloì]õžNnÆ ~¯—AX”^AJ7t@+ƒ
âÐÛ(ô6Oèû¥—Z¹š}³4¨õ¾ýÅÊÎN}0|ªÜ/ï_.Û·­‡¦w}æ¯-Ôz›²-Ú'ë­Ý­3÷tûªôË¡Å(¸Ž]žg	7+öòÓqð“~ö~ìÇ'Äg¸ã£O—EÇ)X¡z™àA•m$\ž6ïçUµ‘ø£8I[=É€ø•üëÛH¤3t÷“È_ÉÀ¿¿D:x–AXLyûø¨Ds/W+}m$>·X:œePø{:¤'iåp’AáïéPNœc¤”CX¤à÷t(§žCKK‡s
~Gú7k‡Ä9FRº›xÇé©sûþ
âŠÿ)¿ð˜ÓìQBúŽ—%üñüþÉ½“ÃÎÑ}·{ÿ~û¾ÿ]Tº{7£[° ß~‡,9Ê\ò¦ðµ[â>GzØÂ%o
?P‹tâk¸iépÉ›ÂÔ"ëÙq;’ÂÔ"¸½•–—¼) A³¤C3JêxD±U9èE)ü@-6œK9ô¢| å\5²v$…hÒü¢v$hÒü’v$…hÔü’v$…¨E:ÓüÃ¤I eß!iGRàFÙwHÚ‘x –	7Û£
9
<P‹aË:trx éÄóƒiåÐÉQØZÆ;—tÚ‘v –*G|W'-z9
;P‡tê1é´thæ(ì@-YgðÐÌQØZ²Î&š9
;Ð¬{š9
;P‹t.åÐËQÐZÆ;—ƒ‡œIA šUà¡—£ µHçZŠMQn>¤Ïé²[Oáe>¤Ï©™c»×S\—éójæ¸<ä©H
:PÇì…z”,-š9
:PGÖ¹
æ©PÈ:”³
whå(à@-VŽk÷óT(à@-Ò¹¶0O…ÒRß¹¶ OÅ¦@£´Hçš¼@žŠM¡Fi‘Îu¯CžŠMÁFi‘Îu¯CžŠMÁFiYƒçº×!OÅ¦`£´Hçº×!PÅ¦`£´Hç²±¨bS°Q&™9HT±)Ô(£ÌDªØj”Qf2Ul
5Ê(3 ™*6e”™ƒL›ÂÒ"ë­ÈT±)à(-¯‡r-T@¦ŠM!Geá!SÅ¦ £Œ²ð©bSÐQFYxU±)è(£,<„ªØt”Yº9
:J‹t¶
ÿÙÍM5cˆ¿ O3†F³–ÕŒÁ­½~ßŒ¡¼¿½5¼pn¯÷N/ÏN­gçÁzª¾\n·.•ûåC÷aÉÙ¬]vº^çï?¿ÝŒÁ.
§`‡Âw3aÈOWÄÁPð]–à7š•a­‘¾Û(·^©&$kç +âö¸}¬¬ß.VvËþ®+ŸœJùy#|y<° wçõîÃÊõR·³usq¾uf´ÀYQw
Â‹"k»?÷
Â¢ÿ.sÂü¡Má è„…Ð¾õzñéh£øtEúÏ~v2\Æß·U¯îV¶wªåRùÏR©ùÿÏFu©ôg§ToVK+?åÊŸ•V©]ÚjU7F_õsy8:9¹îÊøƒJ»•zô)Ñ‡lo4vþ¬µ6ª?¥íÆN¥V©—þ¬×þˆÂh 
ºÇ‡½Ñ§üÝÛÛ+´–vV
•r«PYŠÿù¤ûÐ¹ïÝŽåÏøý¾:Z*Š®[”nÁ
d8ŠûÕQïòpZB}¥²}Xý ô¿Vj¥êFa©Q{»ðúè,Jû8hµ¥ÂŸR=»±QÕ¶ó›ëî{k‚Qå
W:®/>Âšu4uòC_Úþ;nªÝîxð;tz¯ñg~
Ã[‹ƒÞeük•R=NJüõÆga·ï¢ÆŽÓ7þÇ‘®7A^àÅ‡r½ñ?%†Â¨óÂG,¥÷§ýg£ô§2¾¼sótýx?úª•¥V©ÜØþ2_2î³d‡Ei¢l¹ŽÎY÷ú¾ûqŽ¾ÉÓýDÄ›Ê?»•Æýû÷îÏG·ÞW¿ÛÇ×÷N¢‡Nï´×9O+úçxs[:a¿ïÅ}%âð<½7·©TË?“_M,}Ï‹Qæ_­Ír©YùŸ[UÉ­úg»R/ÿßÿS§Þ²ã¯}us
ƒÌï…[p-ÙÉçL_>¾÷ÿ'ÁsW‹…ø-“Â—ß"ý óñYªVêKÕÒÎŸZ¥Åe'#E½ÈoÊ”›ÌW!ŠÞF³ôÏGÿX¡å
+3Kãýg¹´ÔŠ~¬\ÙùOF¾²¾Ñ×½"ßæÊ‚m{žcÿ,+¥íÿûÿ•¢¼4õj¥YúÓl´¶« £?.—þù§óÁ9ùî®t½Q¾dºš’ó%þ'_?È×wU3ÒáEPp<!œ\Uón¼ß»ñwÝ[æ|Ïvc»š@Û’Låjj½ôÝó+wZ¢|ì´6+ÛÕÆvœ—Ærô‹K
¥¥(5µ(ôÿ©Fšzn-”+
“üOô|Ü®l—vþ3ýµ~œKE%šZº‘[þQ*ËÛ…?K•ÒöŸriµ²ýƒ»ï±÷xÙ=<»?º~ÿ—rc©ÙØþ3–ýg¥Râ0zjG·ÊQçè¤{Õë>]÷Gw[vÅ}êù®qîtÅstÝ»ù;ê:7}×Ž>*úÜ?KÕjÆpèô:ãe™ÎÊ§Ÿþ³¿³âŽÖª¬âè¿Ì(•kÕzŽ%F=ƒ\×½¯jTÂ‡(„½çîG¢Ó£Ë‡îÿÖŽ`%éÁð_ZV÷—ƒž‘à†…Àõ¿|XÍÍ@0çöÈTq¤}ËuÜÿv“-'ëˆ~À±ˆÛ±ëåšL-â;V½ÜÊ\Äm4[¢Þ,Ùµá…/âV.œ…ÝöÚð¡bw÷/íÕí¥ÀÛ½;?|ðž.äÍíf5¸êmÝí®®VÓË‰Á?Ë‰Bú+ú‘½–èûi;ºÑÿõr¯%ÚVS„ñJ¡°
®ãYáÛ“=x‹¾°,ñ'SÄwtˆq=†àÇ‹¸[/õÔ
zePkÖD:øS‹¸ Ç½Û§òéÅkïäüì¶Qn?öVÖª› Çbµu²øxPõÚÁàÈ>°Ï2ZHë_Äõ‹¶[tã£¡„Y‹¸òÓÿ-„›:
;þöã–ªß®^žÜtºÑóÿPŽ>þÿÿëé¬Ð=y*t;©åÀúaä*õfåPd¬Ê0*^ÞÕÀÿÔië€ÑHÂáXE•é;Áä~·øùÛÏ>1ÉþÍ¸ªe¯Æˆï0°>–/³– eÒ^ÙÖŸÄïŽW‚G
‘-®&´£kâŒvtõI÷²›yµ#ŠÒ.Ø~h»ÁüN›Æÿ0%ãéú¤{Ú»Žþ0G“cSÆÄÜf™+‘)ô>ÎCÛ·â™–€P ŸéQ|6l¤È•A½ÙrÒd©G±×t¬ðápÏîNnO:µ•‹Ë‡§÷®n]_ÖÖ­­¥áÓÊÖIû6ï~êw»ØôçpPt¼¢ŒÆ•cyNæsØþtEwHt˜â~aE6(÷~Û­/}÷ýjûDÞ/–k‹]»[[¾µÕc[>7ŸZ•óþÙÆÍÆáòÃÎÊýiÆÛšãÆ÷Aän¤p|;½‰-cç9}Ew Å=äˆûK­\‹<|*îÑß_ÓqOûþPZâ®Ý_ï×÷Â°xíÓ¥­Kßév:öÅñÓP,vnŸ®ZgÅz†Íôýß;P¢õ+‘Un1úÙ@¸®ç|òþ“½Éé+â¸ £þ™h
Ò¯ÏDèW3f^S#¿{ýž4¼ípyçñnµ¿´½¾~ó¼ÐºêˆÓåRéª}Ö\¹={Ù=¬m±™×/+š“Y^¼Ê7cèíÑ¤*ô„íË¬Á/>]‡þó›KWïß}ÔPý*e¼£¿¹¿¹üxy6úóU÷úiêõÁ¯·å¢›/úå¶ÃÀÉzÖ}<¢>oùéGãï^úñÓiÛ™CfxñõiUWz×+gK»w—××›Vmápåâ¡æîîÙÃ§xUå¹ë¬¬Þ“uÁS,0^¢„xEÛŽnq;ð\÷©+â¸£yºÏB|ŠãîFÿ7÷z¹òZÿÊì\—.o¬]ë¹»sœÝ¿î„áàj§nŸ\?.VÂ‡ÒÓ}«Ö¾w¯_*l)/º›Ãè†žéG=v Ï÷ÃÌ'”œ¾ Šy”;sÔÓ(æõfò·QÌÅ—/¸Ù——ÞÕýââÂÒéåÆjyñlã¢±¶¾÷zPYÚz\­¯X{½ãÍÅú¹ò®(ëa1Ê–å¹>êÄQ(ê,ïtFQ—ÿÎ2¢¾e7¾²cÞ ¾_í¹×»;/U»|»xô|yy÷Ð}ìl<ìœµë;‹¥½Ë§ÃJæá¡=íè©S}'šJgG~úŠ8ôhâ³¼Ñ‡Þª7S3(ômñådïbo½V.÷¼µ—ý¥å¥Çµ~;ª6»ð*¬íÈ›ÊÒÒñóÆÆSÞâžk1ZgâÕ@YðíÈDƒ!?}Ex4ñYVa£ÀŸ
åŒêÞ¬:_V÷ÊÚÓ‘¾l·WW/÷†Î`§]ÝxYX_Ýî·†/òqa}yñîú`í‰iê÷£/ƒè±Y‘‹–vvÜ§¯ˆãŽ¦ >Ë”;Ž»[/'9ŠQÜû+ÍQœ®ð×Ã×úeiemÿ.z¬¶*Ëëú’¼[óý›ÖÆfsQ\ÔžÖ¶–ÖoùV¿zGÆ/~	7]Pk¦¯ˆCç,³îx–7¨53Ê|¿úòe™o_ì{öáå™èœ‡ðng½¼p$Üƒ›½§çÁI·{¾;|Z¬oT„^¼­†Íz;.â/,Ç¡Ÿº"½‡BÏ5ñ¾ˆ›²Bï~úÕÕ^«ö2\b½Õ°üÅ»Ýá`e§·Z_îŸŸ>\Û;»õÃ—›¡5Ó¾(ôNÑ
¢gDÜ „~êŠ8ôèÀJÀ4ãnV­Z3]èÍöË—…þ©½Xjn^øöáýÉÝSÝ:]
·Î[Ë÷; ×·í–s"V{÷¥öÕ&O¡—QÌ¥eÆŽªñLQm¡Då@ˆ {²mº"ŽúçIëÇ'ëµ9^«]˜˜˜þ.RzÑlx»ð‰¨Â    ËÐ³3ÏW}Ú^¸¼ííäÕ§÷ÒGÿ|{ôð0¸¹ûçÀ÷E×Ž¬ z€ž¶ïvŽON‚cïØ9=•?Ô½ø@dGpêKÆDÓÏ€iÚß¬ÚµSÞh^Ó%c´V7Œ
{­_µâµº§ÅîíRéêR†[­½µÒ…å¶†½ÍíÝ’µy~´ÓºW¯¾ÜÛïºG1Ô<|ÝèYXð£2ü6xÃdè'ÿÞFsÐ€iÞß¬¹ãµÖ¬|]0÷nžz×›—·KáååóÑéÒJg¸²^rîoŸÛçW§›ÃÓÒöÅU{öç¥]´Ü¢ð
e[^¦Cq>]‡MD¦ésë5Ã¡D·õµCÙ<¹Ýß¾ª­Þ9Ãºß«T[Í…«“Ë¥‹Öõ}½\}òÎÊÏ«W·~ðÛûQÜ…ïyQÔ2öcFqŸ¾"Ž;š…²¼= Ë%«Öï$ãnÕ‡í×úWKŒr§}î¯o.Ü¶wýµò~¯q½Ø;.y«ý‹ëmï¶ñp»¾ñÚvœ‡àìwã.›–W”~Ñò
Ò­ k*Ä§+â¸£IhÀ3û¯—+v=½Äh5ÊòËR³ö\·ÎüŠÕn”Ÿíã½çÁÎÅà*ŒJ¼¿³°wP>XZè-¿ž¿zÕç×KÍ(ôÎˆ/¤íe–š(ôÓWÄ¡GóÐ€gþÍA­è‘™½¨Å[©yhz+Ì]q—Æs¥qç…Ýç“µÃ»½íÛÒÞ«X[\=°{÷¤ÖBçñ*ãñªñ¸8ü~Ñw[
–o‰ÐËØ òÓqøÑ\4àY¨—;nm˜½Y~¹°<´oJ­ýÍ½ÁÉ’s¸¾¶Vi5WüÇR¯ûX²›WÞÝÅ­mï]ùw¿êÊ£¨ E[Æž;Š¥´ý¬Aoº"Ž:ÚJ
xV êå³ø@~FÔ#¯™ÃSöî+WKW¯ýÒð|¸ßÊë¨5<z
ÏO—¶‚ÁJ·w$®¶W|ï²õ›žò-øN¼±ëØž“é*ãàO] zž5€(øVÆ>^üö×ûx«ýÒsõ©}±sz}a¯î¶¬ÝÎA©qu|óZ”ÝÕí—¡Ü:zòÊ5¦‡ì[ËÇ)x³FÝñã^ÌòÓWDQw›y¦ÿõfM4š•dÔe-.@9êüž”¬ÀÛ}<9í7–{'õÞêëVg±¿__w—îïºÕ­ãðxg¸±œñÆ‰æWd3òñ.©(¸ž´¥Ì*õî§+â SòLdëÍVdrR[²Ö¿_nqÔ_ŸEípaUXÇÎÑÉÑíC¿ü:p[ûµ§×ÅËv·Þ_–Ïî.ù^öñÜ¨fº/æ¬ fnf
{÷ÓqÐ‘£y&±õ~mXï§ž¯v­Ü’yìÍþ}£ñRê‡²±õp³|Ñ¸¬8›ë+ûvÿaË=¼ï9ûg¥ëóêvÕÍ˜ËêördÝ‚íá‡YÃÞÿtEœäíCž¹l”¬½(ßìì,WêO¥Í…öa9‹ç·ƒÒÊÆîªwæ-”«¥ÓÊÑñRïxoÏmo<3meS‡}d­ø…UË³…›ipüOWÄAG®>dšÈö;q‡¢TÐëåê+08Ÿ†½t ƒöéÕBùy¥~ìn÷Ý§Å…ZØ?_÷7n.B1¨¾Ö»—‡Öo»úèQ7rG¡å…ãWf>ùàÓqø‘«™æ³£ð§ÖoFá k–ŸÂ_’G§WÝ`§vt³¿p³Øß»[êÝ\Ý-XgÖÖÆR¸ºqvÚÙ9¬<mg8ýUç-Aôs¡o}‘ñqÐFSÈ4­íwD­œ²;Q¢Ìd×ýOÿ¶´Øö1lŸ”®×Z;—¢sðxíî[K+÷Ý«Ûam³ì¬Õ2ŠO¦ÃÏ±° 
v8rœÁ}oñŠRÄ½++È2ùÁ§+âø£Ý¦i^Ç?½¢Çÿë—Æ®üòéárè_în÷7Û7¥{/8
J»•‡FûzÅÝ®:‹Ã§gx—1µ¢®èü(ðŽWð¥ºY;¬oŸ\Þ…¥‡ijÛïÈF9«ôœ9y¶KüÇêÚ`ÐëŸ­¶ïÜËË³fX‘{§•µ‡
çà¢Õ+—÷—åêóúå|§hÅ¯v<ÛwÇGë>üðÓqüaáašÝöÏ†µrêÕr;rÿƒ<¯–ïîÕj+G
ÝãÊaà=Š‡‡öëév©7¸=¬Ül7 ‹÷k¯Û:~¹üõõ´(üñz¥_‚Ð±3×ÓÂOWÄá uÇµ˜¦¹ý³¨î§^œŒÂß¤_œL‡¿5XnŽ»µÚémy¯{°Ô·d©nm «Á«¬6½ÛCk«nù¡“±¬¦ÿÉëÄïí[aÁ
ÝhF20uEœ°¶æZLÓÜþ…Ufd ß¶ód`ÿÊ^”õÚåSãeûê¨¾ýX¹¬E&¨²ù¼»¾zõôd76Ï‡ ã­áßÈ€-âµKÛñ,Gdg`úŠøT;X`óYvSâSí­—Ú0±‹Ÿjï—†é]¬t^/;rwó`Ã_¼i6›áÀn^x+GõëÅÎEy¹zùR_¹Û}¼·2^sÒ{ª=>Ú¿2Yˆœ»ç|¶žïÇÚÅ§+F‡«“m Çîá­5íL‡«åÔáj™ëpõädðÔáê@ØÑÿîøŸ~ópµüç«ÃÕoŠüÂáj)|7”Žýåáj7Çáêx$b ;û °§kØƒ t¤ëy¡?ƒàëööoÛñ-a[¶÷Õ H5àƒ Ù|<¼Ù 35œ\ƒÀÉžåûÑƒBÌÃ øºdžÓ5<O†BÒå¨¨ã®?û p§›k¸Yƒ ´‚À
ƒùî¯Û•–cù_¶âµs‚$üg<‚Ù 75¼\ƒÀËvÜIøï7 ”Ò¶„ëX• ‰A‚pöAàO
?× ð3ð-ßö]{þ ÿ›ƒ@„žJ;üòqjj˜9<Ûþ/éL½~ß¹}×ï‡þø=3Ã¦£FkaôáEË)¡ýåëñG÷NÞæR÷7—ï“©Ñ_wŽî»oog÷nN¦Çôhµñý·E˜O¿-šj¢·
|–·Çâ©fû¥‘\íŠ§šÃ’“gµë¼¶°Ø_ÜÞœ^<÷;›[
ëÖýÿÙû®åÆ‘-Ûç™¯¨˜ç!Ò!z’ I 4 Á Aï½AÄùªû	÷Çn&TRB‚I¨’º§#ºO‰›±öN³¶í%*uu£˜×YõÔ™•¡“AA¾ê§š\ž
˜jú%¼åõt±_FîæÿsGQ|;ŠiGQ;
Á2Rt*ýìå1ËP>õn¡P¢PõñÝ"â±B_ÏY{6ðv#P}F F2U`P¦PAô/@5…e0ìn!(CPFðzâÜ³À·ü-ý¤h=ý$PJˆ"/ÑÔïñõˆ{•þ!CP%glCVB”®~ÜBZ;Â÷´v¼ëí±¹£¨»£‚‘
$é‚òÔÔýRyó† >ÖÞñÕŸ~ó±@!&ªŒÁ{Á÷·=CqCÃw¸¡ß
¢9¢ÈU…€?æú!|ÌýACà§'UUôðhóB¾6„W4|‡+ø}Ñ š3ˆ¼ÑF=Ñº"|È>æŽþ !0Ö©°­]zÛ<¨CqGÃw¸£ß
¢9¤È#Y&ŒU}CøÅác.é‚ª*l?ÁCD˜7òµ!„¸¤á;\ÒÀï“ÑœÒ@ä•†<yO&êW0„_ìsKÐo„©ò»<’¯
!Ä-
ßá–~¿4ˆæ˜"Ï4Ü9­H_Á~±#|Ì5ýAC@Ü5 ¥ŸgèG.‹!®iø×4ðû¦A4ç4y§>,‘À/qYü…!|Ì=ýAC R‰m
w„¨GCˆG½Ã£ü.EÍ§DNEb	©ê_áhø˜Wñƒ†@eD¥‡~„°8Å+CPB¼Šè^Eàw+‚h~E r,"Eyjm÷á;ÂÇ<‹5"ËŠ
'±D<”Ï"z‡gú=‹0šgŠ<‹
–xïÈ¿€!Ày?êG D’¬¾Ë³øÚB<‹èžEè÷,ÂhžE(ò,bª°
áOå²|È>×³ˆ$ªðšÌovßÓì%‚íå6FŒ`?¥/[zª± IY¦~süwx ×3äÛ«?ç™uˆŸ½']÷._7bÂ®ÈOJ»óP‚ÿfý©~R E’âq˜+!~Rô?)ôûIa4?)fíRÀ"…ýíSý¤Êì˜SÞ?rõ
ñ“¢wøI¡ßO
£ùI¡ÈOÊnsTelÿ+Âc?ÕOJ°¢°S}WþökCñ“¢wøI¡ßO
£ùI¡0{Ê
AÒ—ðŠüÂ>ÕOŠ!’$ À»ª9^BˆŸ½ÃO
ý~RÍO
…~RÈ>Hÿ
èSý¤lçd
F}ßÌÄ×†â'Eïð“B¿ŸFó“B‘ŸBöp’ü%.‹¿Ø>ÕOŠ‘,	¨c©Q
!ÄOŠßá'…~?)Œæ'…"?) ˜]…é_áhøT?©‚eÊxŸòð²ñŽ †øIñ;ü¤Ðï'…Ñü¤Pè'@!Pý+ìŸê'EŠB)–ÈÃ4›ˆ‘5ÄOŠßá'E~?)Šæ'E"?)•!þCéØ¹# Oõ“…òùÓécÄ£AõXC£¢¥¼ÁÊ?

ä—/öCá£áp´_mÖÇÍ­¯ªÿ3á¿O:›ÕË<ìùÿ
çš„ølpÞCNªíx[þ‹ Uïw<äs
¨úó2÷jB ‘$…¨âQ´‚—ýúT¥}•P2*²2FÒ€ÝÙ€*#GŠÓ÷ÖçÓ_ë£ÕöÈ­ ½|’oª ~ùrýÃñéúQðIßy6žb§zƒŽ›’~5˜!~-¡¤Á_EI0.%ÉÿñóY¿ñjŸEòÂ*	ü™e÷g4
á
 ùŽh(@V~Çº£XaÍKÞ%¢)î;ŽBú¤Q`:ªTz«JÚ'özÅ ^€ü·Zw|´s’ L	ù
Z"}ÙQà˜-½@@U$0Â¤„Œ•þhÔÿ½Zz^xÜ$yÇ1¿Iz
/¤Ù$£ÇªkHÆ¼z}5MÙe?»–Ö¦lh)lÚ
¯åØñ:«•Œ´T“«FiÞëáµ”R[K°?r£N?^¡z5Í]Ðñç¹Žñ÷vÓ~YîØë%C‘¬>·[z¾_ÂCŸþ D³mð¦R %%(ÿHý
Ûxó‚zÑªÊQÁlÝþ-v½—³If•ä=OËuãMb%Ý-»§	ç/é•q«ÿäàmoRìã)Úä¿_MÑÆH¬±§²kèÑõ;¡IB$NB÷!ùsÓxz?ò;ùÞïQ”¶Ø4–±²ì*Û¶¯ë¶‰i·(m±ëZŽÐ®ÚYÅTº^ú©[[ƒÙú    `”u°mïG…ÛÞé§O©uÔnð¿¡nÛ«Êæ%øyUÙ`€uÛ ßIxø‡´)¤qÌ@pubØ¼öâþÈœ/®Æ¼Ú¦Ðdn­Cžšö°")Nõ²«ÎnÍž9é»z—¨[±Wdæ‚qˆèÈ|¹­ N$â9>ïŽÌ¦à“ðŽLø·d
_p7~û‘ùwe
ÿ+ø\€)øLÒ[x!Í‰i³ ž˜ÂÍ¼oKÿƒ)t`X[zÿ¶GtÑÏíÙ\sL‚Úi°8oÊ–Õ+Ž‡—s³k`Ô£æ¾º¼ÕÓþ4SÀŒu&yO?LC˜‚OÂC_ù»25É“\ñï ÞïZPoöyý½™Âß›Î‰˜Â³Aòe $& ÜôbhÇëmz
ljÁMÏtSRpÓóó¬â©’¨£©ïW×L]²Fj5Öéew3N”Œöâš¨¶
ãî<žažïßí¢”ïe¼"LEw}ðÂî“øO,ƒ†C¤˜ÿ¸2ç˜Ýºa”yWìH–Œ)gOU&®õ†Ü¦K¼¯êÛs¹lœÓ’½Â7ÇÈ‰6ÔOƒ• ;MTRAj(ÝIp
„þ!RLƒ\3Ôƒ°S×‡ÃTç¥y½:˜tÃŒ\Tw'}žÊšÅü±µÉ-R»¬·ÖÞl*A
üS…|@‰¤¼wä
Œ” @0‚ãî“à¸‡¸c‰Óì—]šÜÀè
Ìx¿½´|·¿^AÚvÛr7Z†nÑáZ¯ÁéírªmqîÊåŽ–ßŒõOäö?à—yso(%‘BeUÔ}‚;	È—H1ÍþqÙv›Ùv¢À_–š»–RjŽHJÕÞS»qîŽ{2<_”Eª}ž•Êuu½LÕ>~Ê	"¯„I ?¼“àð‡Ìß RLƒÜ1Üà¾oºY7Ê¾J•†Ôjì¬Ëa¸©’BU Ê$}œ¯vÍœVµtâ ¨•jV¿ÄÀ7¦Â§B
¡pà×€O‚k tG<£,Í€†˜@CmâF~µ5šƒæ-Ÿ³ÌÂ¤PÔšõlsSK•;´r&.‘…ÏJw•>wü ‡_á“²!`×DÑä+ˆî$8ü¡ó7â Äá7ƒÇ.‡<<vó›ÆàbeZÚ5GKv¯R(V‡nmpPëŽ|vº›A±¢mËõ^EŽ:Ã<ò,í÷œ¼ôˆ2ò¹¼èN‚C2xƒHñÌþ±´ÉÍÜ9-;{
î=>èiù†àÆÌ7.ý®¥t¯µÍ^&ÕzÅ!ç]·fMiVeñluèÕï»ñ¨ü>ƒaR&@Á™Wè›$ÝI0ÜaHZâúÃpgÿ
Ì\b¸wnÁ ´÷ýþˆ–™c/}tSòåº”Èi VÚ5§s—Öqyp[)äõWÀ@ÞÛ—"„_q¬Üý÷‰¶ì"îì¬
âÎ·šÇ¸Ÿä'ªæÞÝöÜUm@oÛÉô8M4ª»ã´®2j
öŠí´»ûôþÓ„™§žÊ îàN‚ãÆmA<Ü–í'38^’öOXîé¥½_ìçŽÖH'j³²i6Ô›Ù+Ðl†]Ó¹RŠ!ýqÜø.)I¯7¥pŸw÷{Fû³‰Þó·ÍèY3£§êßRùZªÆþ÷îÝp³aoæå¾ò7úroSÍoè›–ý–Ë¦kÙšÅßy
z‡™÷æÿº\.É»,àáèàìgÛçGþéÐºë§çgì†$1!ÒS¡w ú³ýU}d¶‚ÿÙœŽËÍfñì`d¯ô'?ò¹l±‘2¿å­Ž7µÌË?î­O«ÁhÿÃ{Gv¾ Iÿ¯Sk(€}E¦bUâqk¦€°Q¯síë)vãûVn0D~&ô>¹M=Õ]fu=e°O)¤¾=¿âï:Àˆ=NÄ¦uÕ¾=ÅúIgz—=Œ%5j³c#kjV7ý÷fûãÔ[;Ñþl0‰šéY)ða¥U ®âIÕüO°3	q é]ŒöUGÉ¦¢êÐDúyj 2&?ûU„&Ò?´™WŸô›ÿþÇþÒËýÕZGÜWU`o[£¬ O±eëì.p™ƒO‘x4,xi¥œ/§Ìðt”Óõ}ûØÞ!9a×/ýö±U¬ÏR3¸+A'#pÖüñûKQö~ª>{j^ßgü÷0¾
bñß·ûUØ\—×¹³À|¸ë¶«f#qÉîJCš%äcaÔn¨
­\£…«„m`Ìò®Þ¸hÞƒ»
“@f˜'ß0ñÔ/Iá „%Œ¨ s>AØ'Á0G¡\5÷0Ã|âšîkÎ¤»l
 ‡œ	š§+žUðHYØ©Ay/™ãfEÉR¥¸Û©K4K/Ç;¸kD½»ÿÚ=C˜1Jû—™=~+ôˆýƒ“D‚¸ˆ‡¼O€JVcq3à¹cøõ\ZfìÜ-ùÈØ{ôÚ½ÁLêŒÎÕÒ‚îú·”³›¹Ûxzj{ûÅRÁœTvF|~1àÃæ9‰#±?ªr¤ïaÀ&å¥?"ÜÉ >”­Æâ¾™Zêb¸º ø…k<ÚÝåÅ®HcgÍ
—Âß&µÑ²ØÙ,™î'½®Õ’uš/Î8.àßÿ	<ýø}J¥X	Þ'Á
À‚X<Áø«a
,ÞN]£$™îo—£9®7•ñº ›mãR•KÄrNåXè$ìâFêo2ÍÀ…Àð…ÙV¿…›5–)~•gúŸÇ?,bq süoÁYäÿl¤$_co›½£T—+yºŸ­‰ìžÜ¼äpž
åÓ®ž×ZÃƒõ4üî³ñç*P“
–eUãï—àø‡¢`,ná'ü_'¹?á/Hr÷m<Gs—©uÖÄn56ue|Ý!\¨ì·Y¼\c4]‹Åù:—©´³ðü¨}‚’$¡…lù>|Ø}Æâö€·ìÀ‡OÞqŠÇ«›Nj.ÉnuQhîiúÒ+5!ÔãóVIU¬Kº»Gy}óE€ ü
eEÛóýú°+=ŒÅ5Ì¡wƒ®a½þØ5\£@?C¹ Oº¤›­¹Ë±–èÅ…^¹¶§d|=Ë	xp»fF
…ünèyaR• A¢h‡Þ'Á ›…H`,,ÖƒÞÒDÛŽn7ÙÉ"¯Uóèx•²‹Â®
Á¬|Y·b¡¯—ûëœéÌóõì<wâ
¼~zÄî^˜	†Y½O‚Cv·‡ñY=9)€Þ@ayåþ”ƒãe\¼Í kÖ?ó*/ýÜ.ÑßØXE²“]­­MS Ê,jÎÍïKúxÒ cO<žÙn0íæI>	®°K>Œ‡Ö2
 Ë~úæ¨’‡¡o
ÍLxÑ¯½vžfË¡tªIà´¤»uk/—Ý½U«q0{VTãæJ@IøVÌežF#ñáaŽO‚cv¿‡ñ0Z†9¶lÑ^ïD×Ôªì½ºw¿¬äÖx;[)OtTØ¤J·>˜PÔôNé,ïìÄu,µˆÀêÕ÷Y=#¶ì
Î¹­òÖ] žF© ™<‡ÕWøû%8þa‰–0.b›½š¢ûå<CŠ(ïð7ôQ½]™Ï×¸9¾ít ÔÓ¥ÁÕ¡·Iþ‚FÝÆØ)^ç©u)ÆŸ€¿Ì÷tI•_2-øû$8þa™–0.~›eüJpÍœg/!} îðO•°}¡3¶µœÆ§‹æh‡±&ƒtÙ(Ìóõ5¥uŠ«ímGïñ§àÙM’ª„ãÿ"Áñã·0.~Ëx”è®9Ï>¾k¦œ¾3ß®u³Ñª\ö»Ö¼Õ*®3³«u‹WÕ°w²R99»NíÛ]ó#ÄR~XQˆ(ï“àÀ‡[±Õ/Á<3üâqž,ä+ÓZª2XíË«\{5?de¹7©vdWÃU”
UKmöýSüÞoñ|t*Ïœ”eÂkýø0b‹â"¶ú…ý+^
º2ƒ;Î´¶	Å9ù´T!vk|5›ª¾s»éå6% ¾‡üL.Iê+ì8˜G“bÞÍX¸ãø%8þaìÅÅny P€¿›Â]É)}—=5ý^º·Wr-þÌëöeÙ­ªõfG¿ÑÅ¶ßÀ™®'¢¬~/ðŒ>1X%™†Ü4}vÆlQ\ÌV‡fì
ÅìmÙZ´*ÔÒŒfq½/ÚvÙ]ã“‘+oÕ™jh;‰ä®¥þ¥_„®þ¼ÙÀÁå{$"6{¿Ç?ŒÞ¢¸è­ŽMqœ<ô, ùr‘¶,ýÖ.7º=]®wš”±k]gShÝÉúØê'¶¹eJpÃüófO0Ox“/QÛ½_‚ß(âgËï õ~\Œ¼ŒŽÌiØ|«xÓG6=Ïmë½|Ú{Y(ýíöð¯üèpÜìÿeô×ÇÑz¶šÖÇÍ¿¼7þxßË»¦ûÑøo{ICô™—W7û¡—Ž÷òÕ#i‘ -Iß½Þ™Xô>ßU’¼õ×ø¾Ô?ÁÌùò@:û!½¹¾¼ÈÞvZŽ~Vìz¿Üö÷šùBÊ¿Côõ—„6&DÖîS	·vfí@hí©Ãè°Ù¿ÙØŸÞöV[õ®{}¼zñó-p—<Å¾o°töô°tð6&<vþ¢nç8ÄÎ=Þ°óÃ›-ü­¶-ÿðeìYæ·vA¾&o°çÌfÅ›5¼ß¦êå/hŒ8lÙ§nËa>0—ß]'¦(¹Æ (Wóýaˆ²9ÓNÇUlÜ?ØÎA…X1;ëù¸ªÍzÛ±;¼{Šû%)áßIÂç…„ø€ýÿ0ŠË o\QÐÏ]\¢ø€oÜ]NÃsQÓ\r:[ù\OîÛÕšTKÕ
næPoè’¦÷ç¯Aäï˜$ïYâðKpüé?{ù›öò§1Ê'‡
÷r>zóølèÿ(ç³ÚÀóY_`¡.Ï¸‚\ï(ØàL-…¢lpµc¯UËÖÕM7Ðc‡ôÇx[-È	RíHòØeÇnL*•\NÐÄè68õ;û`Y†

óýø$8þê?Ü›ÖÊ–Qc¨búÏ÷Õ”ói§`•½˜	[e²æú€¯Ùì/7û¾Ã÷èÐ#Ôé—|¨G¡àó
_|V#ù5>AYb[

m×÷K5æ6KþB-þ;D 
ôÞó¼÷ö)ßAÌGnß§úøFn{m!¿ÎÈmòë‘Ûlµ…Æ3âJÜ0n–$­¦–%QHkqSiÝ4z”UÛ×{Àê·sš®c­µ>åÖZ¹½ÉUqùZ)};…·LB„€LEw
ùN‚ãÖøg·À‹¾CœDPR”÷ZïÙíþÑÁŸ<qkÆ§v¾fÂ‚#ÿ\õÄóšO3.‹å÷kìŸ{øß$V™ÏLø*

Íü‚|óê““@RH2Š‚cŠCþ£°(+òOÇŒE
ñÙbøB$ÿd¾Ä¹•$T Þ¿cJùGi_5]I´ Ÿ­†/H9ìþ©    ¼Òíò‡~­Ü€Ú
¹ÿ„€Fð'-#^`ŸTd	IâÏQ–Q}t<ÎÖ“[Ë¿Cýd`Þ÷(ƒòáÇ
*4rJ_Tm´;Í³ãæÛpô-µÝoŒþ¿ÿ»î¡GûÆË»SQØóC†ýÝ îèÓÐ¤ADïß×GËe$c¤UßþÜË}š[®f¹ò+ËÍ²Gn¾y L¾¶Öù|“½_
>?˜ÿïð…Ÿf¥ŒaAø*0:ú“Q$C•ÿZð½ëú2·Ð° -~e ©Ãl²ö|mÿçÿ¬{àíGõÝ 0oÂŒ$ ¶%È‹nxõ¤Ê|Ôò”$V‚ïwœæGkö,FÉøð—Âç½O$²®g ™uÑÐrœ¸ê.
`¸¯;üóðIÕ
vø†O&õáj­Éyq”Ï'T«,h“>õÑaŸîš)e–#8¸)è¾ý	áo"£ªJaHøÄ'Áñ
_á¸Ê/
`Ù†b<š°@ÒézÆÊõúu;[YŸk¶v5æxhUŽ«)<Øn}Q¿¬=4o}*4¼ü¡¤Ä›€
ËÐä;	|X“	Wù¥½ðŽ wbÐðÓVu“5/¨˜ØÕÜ¥>Ô‹
”fwÖZNÔ&]U/âUn¼¸Ô¾„áópR‘(bÃ÷Kð(4‹BóËéŸBãÿ~…Q¢Ð4¬}Ž«˜Ô †¬¢6µÉåaõút¬‚Õ±bíCo×XÇõÎ¦]X+ƒB}ÚéÇ%lgš¹¬_—ª™I ¨ˆÆ<™Ñ‹ >¬oŽ«œ´zå¬{y"LÈÒ•ÜŽœf˜io€Q6ãj]X-.¬iå¸\X£f
^ôþ´Uíìíþ|·ðÝS–Dˆ÷Suë‘ï$¸Âªp\¥U"ÜHíÉã&´—#Y®Ó›É!-ŸËLŽ1W»„3ó£Z^ºÖŸ¥·ÖqAÿ
¦½³*ær‚ù%8ðaå8®rÆEÔÒ´‚–>àsƒ[}›Ú—®>ìÊËÚ«ý\#_hÖF)XÛO»¥NúµÑ^Ð«çÏ¼N²J±$ìÜ ßIpàÃZfà¸ê4Stg³ xg
öâ\ÃýÁÈnËÂz[Z6Ë§Òñ"J³Bñ¬e{Ü?Îå‰¬)ÙØzq~‚’˜]Ë õâ”ï$8þaiä8®4r†ÿ\høð¡á¯·çËÈpÕue×4Ô!7D—ãô@Žuwº.¨Ë[«wsÈ(ašHÃ{+KDõx÷:„ý”àÀ‡µÌÀqåÚ5.¢®„xAWBnøÆÅ°;ØÒ:Ä+P"‰ÍlºN÷¢+ÓÄèÚ¶w
¥°jº[§½^¸éõn|šå‰àÎ?ÈÂ—1ÄÿE‚á¯„‘uYoÜ,Ñ-“Od}døÝ~åâ‚°åùd½r¤z÷¸>çQ¹Û®TŸåÆ®sÊ[‰ò—8jö†
«
	³ûŸö0ŽNââè
×t„ä­öC:BÞQE½*R…aÉÔuk×mo§%ln7ÅTÆ¢·z"uém½Á"S›h±¥˜¾¿ECŸðnHeÛ¹°.O¾“àø‡QuUo¸– ÷8û—<ÜïëÚa½%Æævtgr= ª§Ûrv8-ìM¾mÛÝbWºÕ÷«~§½‰ÍGò!àeÞRœB €p¾„|'Ácµ$.VÛDM¯Í¹!hz4üÞHwÓéÌd:žóFF­ÑD=UÓ ã¾b÷kfÊu´íq]Ëî¾†áSžxŠT†«bø>	Ž¹%q‘Û†$¤Vs#ÌGuGnÏëVmÝ¶ÇêEUsêv=™I­d·Îh‘3wv«;ê7y¹-*þrËð%8É®‘à¹-êkrë—à#·$.rë\Œ¹À=î.n àJÅhÃfIÕIÛ-ÖåÚzH¦îyOçádItÍ¦iTKì¨ƒ>·¢}¿ÝCžýŒiR–TU…¢}‡ÞIpÔÃ˜-‰‹Ù:Œ`	\—¬ .¬Ê[Õ.Õ+k§u+æÚb2Rú†tP÷ºVkXMÕNÅZÔ}ç7‚¿))A
°ð´¥wü0vKâb·Žk:qZš~{Ø‰ó˜n‡ÔmÝq Óa¦4¨ÃÎäR]7Ž)÷Œñ¶1S‹h² þ§O[È x`%)«¼D)Äê}ø0ZKâ¢µŽ$ò![¼-D„Ó6±¾¬“i¢^u†ã«º@¶
‡“‘(uºú(([ÊÖ¡„¢¶ ý}VÏ§w€¤„©,.c¢wüÐÒè÷g0ý+b
Ó¯ä¾LöÍÃ=äô1N!þ@nê›s˜þÉ,ûÜÌ²ÀÊò™[Yj˜Ó‚Äå4r hVšÅY]”Îæ›šÛšïÒvö2´Ë=Z0ì‰Y-•óe£×Évt¨l§0—•£v–ÿÛúNÔ$J„è²Þß_}QVåGYÖúÒQVújd³ïiÔ?þ4ðÃ1cÄTñ¯w¦Ø¿õ}_8Çž-
>F$	™ªï¯ü§0âC5K`Ïô™_—¡ío+CûÕò
©C{ãÛ¾n!š·&¡ÄgÌ¨Êû«,þ©ü»—z
Öã‹Ùðõøájù_-©7¯A±2¿HI¶·îšäðÑó}-å|f3Á:{1¾ÎB[“WŠ,ÏdœîþÐh ÖànýüL›ÿ—÷ÆKîñ[žxõ5
~[F~4ÿÈüÿõÄ(‰d
¤ôD`<r]Ã¯ý#ÿ(-²ÒØg@o0- IEVYì(ùUÇÌ7ëK° _Ì†/ÈÐºù·µõ¹ÓÒÃ¾>¿–üº}¼UG”$•%“w¯ºš+}õW‚Uó¢v¾jBƒ‡q%I9ØÔ‚ÁC‹‡W"­²\LÑ½êµl­ƒÊÍNßÞÌ2óÉt9®êOÜV¾¿jœ‚Œð?ío¤ü&NT	AaÆ½“àà‡å¸R¥&h³×6pØ˜zÆ©æÊ[mò¹ §Élí.:¬…æm_Â-¥JŽcP±rÝ]Ôá¹ Ò$#+I ÿ#é
ð;Tx¦=Ÿ	
 (]ÞIpøÃBˆr\™R
Âþû~`h“›ùh¦Ùrì u½‘ª˜û}³ªwf“¼qµq¦96ûëV=a+Æ%sl€Vû
dJÁï~—ä¤Œ ÁÂL)z'ÁËŒ•ãÊ”Z3˜'Â‡QÊ(7Ss›)£%Úí`ÕíàÜ&hªv÷ÄŠT+Ó?gÜ#Häé":SÊÃÓ$Y	‹É¨_à?1•ÂBLrLyRvêbºÈ9C¢DÎqiŸ¹õåÑ$#)Ó-YÏ ­æ®ÍÔ Ë¥a#q°õJ6Q˜—Ï_ –òÁe$ùy*\Aï$8þa	²rLYRAVŽHÖû¼ðÚeiÉvIo–y-Tzóö:·ÀûÕâ¶m.‹Ðšã‚››”ô(ÈS{_^ø‡¬3ûNª˜°³E”Nï$8þaküºŸOf3úö¯o©Óq3:÷—'ïò(H\`/þk»ß8£Ãæ_ÎfÔëß½!H"Ê¿8dßâƒáòçzzžA©ðî´/wÕáh9úµhxè¿àûŒ~D2Âg»¨I¬PHÃÈ’€¬0¾~®ž
˜q—ê^Ì,_(È³”ÿýØ
^ëûêþGÛ>=¢ãàmZ
ì>#ûO x7 ÿÜˆW?¶0ê‘ÁýklW^,ûÇVýô³Ïh°}’@RN‘—8(Sª*j8ª?¯O?Þú·@ð½•o`ÿ¸øßèëà£‹#½ ‡ú:~½½ü9ÿÿ6õ|^F°E¼
_ia%rL©Õv
Fð0ÞÁsGÐÇe«Þ™Žr³¼ÛåSÚasu ­	nk£a\ç›ÜµR/·
§Ï'èØëi!ók Š…Åòê‡?¬ž@Ž)¹Úî°[q'šnõÂïà_Î]zªÛûÝPé
öÕÔäjØu$5'ÎµØljÂÕ-—n*‚v~¼j‰¸œC½“àð‡ùåXR¬]Ã^HF rØ¸|ˆÄ£J²Fâd²ÕÝWk›•µ­6We¾ºµ6ŠÊF¯zÒ°››îŽQsÛ;ÂŒ’²
O¿‘”è¸³ÛŽÂ#%ˆéTUe Ü#ø@w÷P·`,9 ®1g»N pØ`Ë¡!=:.OvR£•°vËÓ-±rææD›!’­§ŠiÞ©žL%w›Õtgc—£÷C¯ò‹&$IL”ì=ôøN‚CêŒÅþ}À%èAºSzÂ-Ú¹4ËšR¹¦‹ûÐËªýbcÝ]
\»MíPLõN‘O‚ËI"ñ a(ô/ú0§ ÅîAoiBèñCè£z÷8œ®.î m—ºújâ˜`ÐÜí‹’guSNd‘Þ/\R_Åêîm…*Bâ
 ßI0èA˜GÆâgÐ;’9]9É6yÍ€›Òl;Ym_LK‹ÜF;™|·QÝöÆÃŽ¥³Cx«¡´Ÿvp½ˆ§nï¸³=bÍS1¢‚Ö(˜Ï>óKpÜÃ<4?8Ã}q
&û®¡¥Éþ>ÜWæ¬XÌÍ-«Ñ9À´ÚÌÔmÝ>áò,g÷ez¸¤r§RbLå[ùÓXÞ0r^O¥r°‡»_‚ãV"Ocñ€»†›½˜ó×AOƒ_x`0èéÃ½tÎO•éþÆX¹<oo•yã²Ê7ÒÅíº²ƒ2Ç*;0¿\FÝåîÀ³f)‰W´Ã^&ŸÇ=¬BžÆâùf¸ëìbóú>ÏpwÙÅ&Â}Þ>çÐRµg)g·RaöÚÝVO©{éÃ½í*SiÐÖSÓ…`§ÿÃÚžˆÄ;ª,qå½¾Ò{ðKp
„Z
¡åHC#xÈº&3ä‡‡ìY&§\-»¯›óáPïWšçù`ß(¥q\VvÌ úJÖZ7Qœÿ[þSZ9‰HŸû7Þ[>½“à¸‡1Y
“e¸O.†ÄÝÒîCÜG½5Ø(§ŠaVÔ‰k¡ÊÅ>Öw+sèÆËƒÛûÌHÙ¦:Ÿ¿Ó#¶™|G2#¨*¢ÂG¹“à¸‡QX…5µOey»dØ~Ø‘ –¸Ñ1è
ö ½–;—³Î±tÑªÃava+Í][E3°·£ö ú}¸?×b1zªb!Rï$8îa–ÆCaM;Î^—Åwœ=,‹ï–T‡¢æ­R¯u<0Õ^gg™ãÖw{Êz¶fûÌB-Öt=Æ¦cOÐÊÄðÂËzâ¹Ä¸Ê(Â"“ç™˜>	}…¥ñPXóU@aÙÁ›zLa«—U¶áÎnÛ.,ªùufUX=÷<•ç&Ì6Ç—C9¿+©=TÄÿqè9°*¯ï TQƒ×yòY¼Oà? jÈõ†*1½Ë;fy
‹yv•Ÿ Æl/¾Ñ›LÝÙ¬CÉ’äRÇý
õÝ£DWV;
[ûA£ÒêÍ'Ã3\£¶µýÅf    £B¦%‰’0ä $$bómÄ›”ÂGq½j~Â%äo<Òà“ð@¿Iqßšñ)ÐŸ=Åm‡ÃÑ~µY7·¾ªþÏ„ÿ>élV/‡WAïw<KÙ‹AŒûËÃÃP²y‚à>
òîC§âˆ{J¨òU!o^*K€Ýÿëçwñ ~ŽˆIRHxùæë—ypä²Ù{/;–äþ ?RTJ°Ô'ƒ>»|ÊP–ÁÇÓÚÓ_ë£Õöxøzú¤Ñþ°YÿŒ¬<}¹>3ï=‚§á7Õ$Ûž®Ô¿’¼;žÂt¤Ê¿AI}ªÒ¾Ênæƒ¡"+c$
B€*#GŠÓG¿UIòü|•2~ƒäµå÷çûÏÚrè}?Z[ŽžýÞÚr
•°§üiVÊÃHO£†=
üZº‰ô4(Ì7©Äã6Ý*0ìÀM™võúðPÍ¯ÓéanÙ…ØdoÒWË‹Ô¹ù²2:–MPžk™¶rÒÊùö1*cýåu³W˜ @É§4†ÈwÄSŸ;6%HIðéáî—à¸{>2-[ÎzçêÏäÊ¦ó¼Õò$%ïÛ;3g¹ùÖ_ŸúËÿú¥Ma…‡]ØÎöÀðl$Ÿ4RùFË[1
,0–ÄÖ‡Þ™x€¶Ï÷£§lÄ;”<
¤@Ž2
¢¡œÑ3eë›®‡EÂ6í»¬Œ_bëmûHAŠðI4C7£`
`ûŽo-þbDùYAžÝ†yZ”xb–¦³‹x xŠ
×QR6Ž—¢Bš“FµVÜHé¶R^5ûÆq¥5úµl.]NéÝ5¬I3<iN>7g€Y »'Q> ¢’`Mƒ_¾“àð‡9\”xB¼ýš˜Äá_ (.ÞË2…öSû¼N•{Í^±“®ºY|îÌÖ¤íhíê¥—å¹›«×Ú‚ˆÒ‡ŸpŽÉ©”L‚þ]~¿‡?Ìï¢ÄÙ{@/ÈêÍÐœkH9×üåý¸¹È·×zÇ˜æ.WØÌ9t¸›5}ÒÀ×®YÛNk™š*•/Ÿîa'?ºq")©"@9KäG7Î	®0÷‹KŒC2æÙ+[A
ÌS8lÜ_·í­<0ªNÊÚÜŽ•ž‘rÆÆ¦÷Ý.ÕPÊ9Ëi§tÜ×£jà·- ^Ó%s‹ÂÛs–<øýþ°,%–  ‡ŸûëíŸÃŸ½<Ì€Q÷Rß.k’mÏfËVUÇi«,uûò–Çû¥2Õ÷é´
rSÁ¾ÿNï¡I 1ÅðX?‰èŠñCÏX²(LXy†þE‚A¥û´äç{¾—|É~xþÞOiªÿõã·w|ÙÏ3Ú?žyúô¼8*© üü™¥©KŸ1ò¯G×ã«GéýjL5{Ûptpö³í3ÔÆÿû¿Ã»nþÀâß_¯  ƒë·Á5Á“g£>JÀL|s3	KzPb	…±ª_Lí5¡ã+t!=$t{8,éc½>¯¯Óöò:[Ô{v}’±/åó|¯è—jÈÆ¬–Ž¸BçÎˆ%vö'1$*¶‰&?B/÷°¤ %–P˜‡{0¿ÊÃ]_<˜”}ó :(½Oå¯yi/é+×”»êþ"'¤Ý¡’Ù$š-zµ÷óž`Ï?˜0AåÅÕ±èfÆá÷IpøÃrâxð’èN_å³ðÜ‡9V9Ÿ?d‡ÚjeNJ¨¹³€á.5¾µ|W‡K¶*nõ~›	ÊýÞøÀ©„øm‹à$S¡Ù+w÷°Œ %–pÃ½êšökBÂp·Ù <Š t:oÐ}ªŸQ³]4*@½v-ÜpJ—Â5SœÖŠ·•Ù×có½³ÌÒžgç3ž§2ƒEÃð~	ü=ÿY#¿îüØ8œúûÙ¦÷Üû1Ø’¥>šœö³aø¯Æßâ½Cñå
/1‘ßñÞ«/ñòú{;„<¡Æ; †9øq¨A\ÓÂ¿{öê,û«þÑ_ è¯m!Beøÿ0WF/Tcñ¢òU@‚ù'|LçŸ˜K=çNVë²[ÜÖœœwf!	C½šŸgíå®w‡}l³>²
¬„m[ I ˜ñü‹ >Œª±¸£ø@luPåÿ
Zø€ïË¤ÞE‡ÈlW­VëlUj)Û¼lHsZï:“pVK˜ùvl‰©^T c*ÆåN‚¯ÞyVÿvÛÏ¯Bâýç/ø	d¬&)à
#=a…¿ÚÆþ†ZúB‡„`½¼(›WC«ô? ñíT÷O0ú¦?ÿˆñý×Süþ>â§Š÷©šYå9<S^MI"T;ñ…ÅÎ·ôÞ$žâ?[è$,@¨Æâqæ;,ùÛx µki–—Fµó^m¥Á²0žuÆ³B¾{XäÛ-u6r#Ý°M§íÏï°Œ.žXC0BÈ,Æ/Á#òjL¾æùâfØFãZöeÞš×Ãü©2Èì×=¹¥´Wò°¶Î[µ›Ní©œwÖ`Sm
N¸?L(± .ê„°"Š´ðêLŸ‡?ŒÏ«19šÝÔ58W—Áo§Bçêúá¯X–6Ê°[ºr5UJ´cs3VªYÒQ¥ks~V;£ÌK);åÃOÈ÷'^J$*†ß/ÁáãójLŽf·Á l;®Éƒ`¶Á¼‚jé‚Æ“Ã¤±ËU
³>,ž‡ýMk¢õ‹•vziž;«nÄ7ÃÞGéß”fÉ —½³’”!‘å`2=ùÁ‡>ŒÒ«1yÝ³æ@‹A¿ Q‚\ÇD»š3³J·–’¬Ü±Ñ1³…åñºÉí´]«²Îê´7XuõùüAžæ!t™@ èœçiÀ/Á5dWcò%ºk°2œiÀM	*Ãƒ-ÄÌI¾hh
ŠZI%”‹z*¨s£ž5óœ™J[×üv@HF°ÞÙBìn-o†+ä.ˆ>×æ«¯5à“à‹³«1¹™‚Ã¥=
†Kû¶t4ödßïê<­ÔµN»£µT

õLÎlÂ1ªX¹2kõ]:ªýwC/óT(!E
*?Aï“àÐ‡úRbò(ºvïöÅø›©ÒuÑ–õb.‘9j3:\MP¥^1‹ÍÅäÖ\&R×Lªr¶ÑD?Åøe>…‰ $£àø¹g
¼Hp
„8Ud)&o–Ë›S Wd9øŒ?GÕì†lô¢s2›VÚMÔ±j¶D:³ãØÊÌkÓ¬œÊo×¢»ïŸì
^ÿ¸×é­Ð+<yAA	£HzŸ‡>$¾.K1ù³8ôÁ0‡þqc£HXnµñ‚ÎšiF~éÑ–/‹‘´o&N£.h§Ý<?7âƒþcV¯ð8…¤HT_‚þEÂcèìTÆÂÄ^/Á;ZboˆCˆý¯òÓƒÙ½/sÄÙ½äw÷þ$³&9„BÊRLÜÝí`ñ=ÂyÜaF+ãR¶Iª%œ›êZÞ†Elïº‹uªØÙæú›Åõ*ª½±‹Áo±¦·_¢1ý.±Ã)XÐƒ×³&¿‡>„>2~ôÁD=zA¢ž!ëÕí­óÌ±Rúz;Ë÷oòDQÈ1åÚä’™Â|!]ì—ñ•‰}h!3`Ùû
æ5?#ÿ,À!Ž²oï#˜ÿÀ€ŸªÄ‚×‡KÞFÍí¢—ÉT²Ý¥1ÚùÛ ¹•¥Þ|(]¦ýñzjM;»ãþ‹Üy.6;ÿ¨ª„Ü|ÿ{öød6ÜæûëÙ†o¦’w‹xþòüÇûð-óºßa½¬ñŸ¶÷*7æõ›ø¡—í	å$¡P¦âTìg?ðìÐë30Î£g?õÓ×ñþ>?úç§²ÜsÉ¡aÙ—Y"¢.„ÚÆ­¿‚º›c2Ü|
¼·ó Ï8ÈD4Aú.‘¤,±óÎêža½t õ`zØý÷«î ´b 2ÿã&*©P¨{_ D¡ûßÏ¿|GaOÓ&ã0Žˆ÷º÷ÍŠ“}î6™òQ!‡ó®qÛ*NžçÓB7“^Œ¯Ýc£±wöj}Ú.t‹´Î_„£0|Ÿ
,IÏ»¼@/\¡%.'•ã›¸q
è›¸rÙÍ@B`žhÚR©v-;‘=OÆe–&ûÁøVØ ©é~[XâcWB¾cF¿IØñúóuû=?Ù¾|q~¡ä?9³£OÌ7RTµ¡—ÿëÇ
Ï¨ýõd´ìßúk·_~Ê…ø#¼
ÆÌgË©ç_o§›õèi™*HB„Jðù¥WûÿU8ÜÞÇ˜ŒfŸEÍi}Ü{ß.›i¤4«áÌà=K“Tâž»3­÷£Ÿêò¾ÄiÿòÍ;)³›zx¼ðwfûãÔÓÐ£¿ùÄ7Ÿ@fûúl<súÏJ”T@ ÊÈ‹úáýìØ_zœ?¾aÈ^üô'˜]yÁ|%ŒuÂX¶3À'
Æ:Ø–Å„FˆuÖÝiMiW³SÝÖó3³Ó£Né|­íOùÍI©Áì‘ãxµèïóøÊœúÆþ/ö“Q0¯žr¦æ—`›K.ÃX¶3®F^35® EU£^Ù÷žç6z¶|ÑxR±'§ss;]¶º‚¾K·n#Ÿí	òˆþ¸xå¸W¸ÃL[k ÜI0
Ðûôúÿå;|×Îö¨€ÿIF@’0Åbñ Âè[äÏO’cØ"ÿ×«û¯r½:Åž¬ Aø)FC½]qEÍ>äEp%¬^¢ì¡'s¶­Ë9©‹í‹4#©ƒslôR]Y]–òËô¢IS²¾1•lá‹Ä-9¾jAJ‘(	ÿ‡ž%¸B^qEÍ&ìÄ
,[ Q¦Ý)þjL÷¾ØËîhÔZîjÒí6­-JWÃjŸË×toÝnÖnÇ?O‹èw yt€0RC„Îx'Á5êýŠ'xfjL0XÉK#¤hå‘ãëZïÎ†5=w¾´­Ñ ™tµRŸJéZÛ ÅÜ°1TäYÖýü›Ó€Â³@”d›´€d@w\!Ù2ˆ'xÆÐ—L÷õø©*ÿ=Ÿº×  £Ó m-Ñh¯ªÇNùTïë ¾Ÿ5f—ÙË)éLÂ7Ú5+êLƒß¬äÕ·é%3ùµ|ÿÜ	ÄAcûÉÍpƒ+À´³n” ­g—–ÒLo²ë]jhÌÈYQÁ¬m§;“ÉÂNW¯³c¥EK³í)õ5ð'Òw„’* Š¢ ¿×@Hî„â‰:1
H‚s˜iÀˆtWp§ZêÕú.ª˜¶¾nOÍYUÚëú´§w%§°ÜïÇËN±y˜œ•AŸ¢äå¦Q9D>	®0÷$ˆ'ødj
Þ§0¨¹£¬ÉÙ½]KÛV~Ó£…¡^¬ï†­êdLÝÁäl;¹öê o‰H”£6éø­P¿Kª·Ç+*»j4ðÔ7Ï'Á5æžñD¡Lm‚‚³O«’ew³Oƒ8lëìè¸hžvjU™;¹iv6^©d
—ëµf6N£Ø/ÜUÔìÑ7Ü„    ØñZ¤ÏfAà`£Ùãó>	®0ŸˆÇEÏÐ$‚»(ové.Z¸ºhãTŸÏúfQkTn‰ñØtÆçn«
[«‘­'¦¹ì®`Ò§ÿø]”i {7MY…@
âô4à—à^Å0ŸˆÇEï
õÞ„€9onBþ9+¹æ¡zR«£™Ü˜ßôÛÍN›óñržêNêÕYžË—:°|‘ÑoÉ¡{£‹žÝ/¹«
&%TAYƒÝIpèÃ¨0ˆ‡
{ŽÛà%ˆOvŠt	’{zí”H›t§ëvOº¥§…Kn@öÔ4v·Ìõ¨wÚÄÅ¢ 	á ði„JbF²”àìiÀ/Á5F…A<TØ´'#Ð'«
,mq}<dHugË™<YÝ¤Æê°=;ëÈ71^k+'W^w½µTÞ™¹Û-¾ø”¯M0Rßˆ</Ë I©H	N[ñ÷KpäÃ(0ˆ…³
ž»Ò_#ß¸rWz”e-¼Èæ”‚©Ø¥ÎÊõÕ«ÙA~×1Æ‡ãÖId;Zö¶«T÷­¨-²~k0{
Fä¤$ÉD
¦¯Ë¼vÃ/Á5Fa,˜i ¬@O€o›M¢4)ëS
ÔwÌÙOúÊ¸sËdóÍD›Œ®»)<·¶k´HÁã©Q[aüf
`ÄK“`Ÿ Š5à—à#Á0Ì4ÐAÁj¦žÖa
t@¯zn,PæˆGÖ®ßX- H»œF3¦5Ì4JùÄ¡¹ZÓŸ¿ÿ{ ^_IU¦²tyðKp
„‘`
	ÞDñ`H•iÀ!QNàžAö¥‘’ß×3µë.“ëõyk ¨“*¹“›2Èœ3ÊñVXVµÏ§`2ïŸÌn8ì|eWÑÈßžB~/\a$ÆB‚™œ‹(\åX€DÀ;
n=¥f7›‚Õ_žK9ùJÉzçÞ*î\«%§† µ]¬”ÑøóAOÀ¼>aa°†ïI>	®0c!Á^Z1h€§Ü¢h žÊXÀÉ¦K—­vÙÔùR¦8,/¤Z¹4C¦Ymi‰Â)¯Ž£+TM²Ë
 RÂ7g(|~¨Š‰È
ñ”Uà“àYa4 ÆB /¢F¸o¨)Ð›—í¦¼Uòù‚3b—ÒÅAW	'›ÙÝ”]TV£êê|qk_á*ÄGV>¿(„¡À×@
€±Ð€'
Ì—Q®å2jû¶Ž§ëJÊqÖ³å¼V¬m®óÖ—ƒ­ÛªU¨›ílÊÝ:1Žäzïà
y)D’¬’ø$¸ÂØ Œ‰
¸ÎÕÌ^l¸––ºE©¢/7ÚhÞ—;|Ï:œ–ÁŸKÚ5µÔzÖÜtj¡Q˜©hPÑ'( ±'e ËÁ3ÀÃß'Àá£(&*àò™Ð¯½p~;©an¥1+5L:&zŠ[)ÅlŸ¨LÚôP‚Ê"‘¾Mèæ§‹ý:ÆkÐ à'ä;’+*
Þ‚<üý\aL ÅÄØmÑl@–½EÙ€VˆÌ‹iÕJ¨«Í`e2›
Òíc‡¬<å»±v›{½´<˜ÓÏ?i€òýEE
EAOÐ“|\aL ÅÄÜÅ5X	Ô-©e÷¹³l4ñô²£Õ:	m·½Õn8Ò‡Jµ„lk¦ÝÎæã!üî%Àýœ^£¬E¸Á;	®€0"€â!¦–†–
*À®^ŒKÀ=ìW%š¿nŽª4p$\ª"¹‰sé^.o.r…¢räŽQ2Z1Æ#?  ÄÉX’HŠ…— x'ÁÆP<<ÀÔ²—`H®€… G¤ 1+Óq×­"/‹Çã¾™ÍN\Ü×ôEötmi©Ke[¦õ\¼->?%ÂÓ ÆÜÛC‘m»=
ø%¸Â‚a(žo¦Æ‡_‡b¼oá5JRJ±V¾:“Tîˆn "ƒõ¡|¶h
o=|É
ZÀr,
É‹”únA^Ñì“e(
ax'ñŸX‘Âba(žünSÓ¥`;¦ ×´³S{›ËÂƒZX[ëDuÐïîºåXLƒ9;)s­¡4fÒYé~	§4‰QîjP°,	œÒÔ
‰ù$¸Â¸0Š‡
s
˜˜§…
ïÛº¬m Õñ¬Ö¦£­g¨6ïª
w–½Ï^&…ëö¯_á&ê)€ $BLB&†î$¸Â¨0Š‡
{˜5s§”Å{KWÍfÖú­Y{WZî¸~’¯š!+:(gÁ~B¬Cq•ËˆZ¥~Æà3ãä$R$vF ;	®0.ŒâáÂ¦Æ.<Ä,®E¤Ä¬B¾,ç.SŠÉ¢3\å(¹T-ggJ]¢qvJÛÅù©äÈ1&H`	 /ë
I0Ä‡î$¸ÂØ0Ž‡
3`w†äµ	Žp
ÎØL4Í"ýeŸæÁºjf­Ü:¡sº>–t¨v>]¹fbŒ}@ØëàATJÂV€_‚+ Œ
ãxØ°©5€¥Ü’9¯â(îˆ|÷šVhqod¶ýó¼;Ê0	,ñ(‘èçæGM“¦[©­K•/q…¼Œ
KIB‰o¢èN‚k Œ
ãxØ0Ó 6-I¸)2yrÇY¹œZgäÑlÜtôÖK'{ÙÛPyTN³©¼8qþ
Ä â!žù‰iÈ!€ï$¸ÂØ0Ž‹
w
³»Q‡DQ@¯0@•ªÖï«¸ÝÎŒª:šÍ€ÙÑ&(?®&tªM°’W\£Cè
ðª=Ù{‘" cóžü\alÇÅ†'WSpXä(‡ÀE=AëºÀ­öa•(äWªlõûæ®sÝÑË*;ÀÐèÒãrâ`|âY‡| TU!À~ÆqQá0‚G û»E€(ÕM¥´¯Í×®ef:ng¾Ù‚~g_-ÌÕî0Ým]¥RÝÏw1Žp{üÔþ10\JÊ(bw¹“`
 aTÇD…í”dÌ
°[Ì[E)SØÝ–´æ.ÌDµ«.‹HÑ
ZØèg©RºåW“VÎQ«ÝO?<ðéÑì}„ó‹à—øOÀþ
ŒÔŠý·¿¹W¾tßŸÌûÕƒh|wÄ¼÷:"˜<ÕŠ{¯ÿLë{ée†ïÞÊÍ&Œ¿ã˜ø;7›@6±g6n–µÖú‰Œ®à!’J¦cÎwÙ	wªP¹µ‘ÚdôÙÕ™Ý­ ¶ð_ÝžíÁ¤¢ÊHÊ#w\aÇDàí¬œ,Æ40×“Å‚ …º«AåÔ=lKéÚv46GçTo1î¨gõT¾>ÛÖèzÕÚü7k ž­dŠÄW r'Á5FàqLÞÎ
úùq
ˆúù	|XsÉuRëå´
ÜÔöp«mÖølµõöq¸¦V;}Xûþ Ý¢•O÷ay
ÀˆÏhÀ˜¹X~	®€0Ob"ð¶Î „’€áfa”PÒ‰¤®Ç›FÙñ&=mØ'm£ƒÅ¤ˆGCÒÞvÍáy¾¥ÆªºøK€ð>I•½YèD$~Ž'1ñw[gäE°qòa
J÷û6Îºtql¯º´ªË5ý¤»·]}¾\œñ€¶Ö‹JÚ®Vb<>° ˆêu~GÉ!
À/ÁFßILôÝ6Ønð¢¯ê6‚½<4f®y\[…e·&Í
+WF	ìŒò®¡5Ï—¢uA€Œ}…àE³%”dû
’„éò×@'1ñwÛÀÁ± \N¤± 3ó2Tw×Ò~U¬Ïwi,ÔEÑ¢×ÉÙjnÏ•4¥ËLm3øtâ“dÎe…Ñá$ßIp„ñw·«l	Ï öû[”3`—š3»êmmŸ(¨Ø….(
ÝC{?®æxª%œÑVÎKÝÌ—¸yã'0»èóºAá5H¾“à£ð$&
oWQ°°£Ü‰ÔbaÓÃ¹Öùjœ±-µ®Z»+ÃÎøT:Ÿ¯iÒuF*Y©ýËV®¶?=ší) A«ÆKXèÄ•ï$˜`…'qQø†(š
Ìy´hvƒ QjRÏ¬»Ãµ?Òg%Eç¦mWÃLÏ˜Î£áÑzYž~(ÏÓ »f²S–°û¥ ÀÇÓ€_‚k Œ
“¸Øp	ò*™:‘ò*›ã|(Ó[ç¶Ííj‹Å\ª¹a;EÕº½¹
Ú·ÌÅÞä
VþÓóŠŸàµá‡ BEèF—ï$¸ÂÈ0‰‡[Ú[và †æ(§@ -¤vûTµKÞu0îËçHõTXÁþq9/òh6¿Î{Ñœ?¾ ;‡½)}„¢—Átw`‡°_‚k Œ“xÈ°—BÌì&lYDÊìÎåoËÜ Ù7¶ÓœNvRE_cÇk-c‘½Ç£Ìïpóc}Ï{— S Ïéà³í $‰N>IÊ'ÁF†åxÈ03QZ‰šÖ—­KÍ­-/{Ý
ÌØr}ÑÌ:¹®jwª—í2}»æ;	s;Ü)î§§x
@”w8²‚Ãà—à
cÃr<l˜)à*¸‰cžŠt½¶n(½6s
×½×]kÜZ4š	;+÷ª¤ÛkÛ-.­Œ\Œ‡ÀGö äÝ3%„ÄÕ
OSE^$¸Âè°fLyàMyj ±ßËZë°ê«´87\©Ý"x{êf¤µ/‹>%5ÅjÖKøó«<=
àå­R¨³ë9óIp
„Ña9:Ì4@¬`VÓÀ„DÉ*ëÖí2×ôKc\=—òÛL»ÚQSWœÈøh•ûå†ž«#d^;Ÿ_éü¤Ä/;e™	‡¬¿×@–ãáÃ–­‹²Ê˜¢e•M3}²Ð·óò*±É¤N{dîÇ+|‘&³ZÇ)]Ì´¹(ÛÓôtß9¬²ý±£@…Iå
}vž Õ$•!Vš?ãÿ,Àá#Ãr<dØƒ?ÐiÊƒ?R§©¬Q$Æ¶wÐwK	9d:=^äœ^#ÍV¾›.TÕÜXí“ÙpçEô§0Cóó*Û€~
0øQ–ã¡Â~IP\B×ˆT\Ò³G­sW›5´Ð²ãézÞ»¹g¹¼=–[G'Sv–çœ­Ê…Ýç'v3ü¡7s$eU%²È è„ÎFas»ø
xãÜ®Ÿ1kE…Ò/Æ´ Gvy!ñ°™]àQœÛûsÜ Â˜½³gELM°žÝ‰e=×öGû8³¬yýv½õ[]ìjÅòæ²˜ó) ‰ÑeWJÍ6Rn¿@~
·'õ»$óÎ(@Ð¹éÉž|\aÌ^Ž‰ÙsÌÞE® Å»H•¥Û>Í¶²=Å«¼]Í:=£Ö¼‡íÛ5§w[º
GÍÔñósDŸ5 !3p ,VzRÀ³ Ç?Œ×ËqñzC
ÎÖi°Ea„ÍÖ¹Ã¿š–RÅÍÑ\l¦™ÊVÑ2z¥©~Kè°ÛvÌºŒˆ]Ü¸éøb¬ï¿O@/|!'%URˆÐ±Bï$¸Âx=‹×Ø¶í`
p`$ïîµ¸8ÛÕEÉ7šíÑr    :Ífr·ã‘$ìD¶ºH_T3³Ð”Å@ùôEOóùhHâ¡#±ü\a¼žÆÅë
"è›Â0‰Ô7v	«~µDÙåkµLÓ
‹­Æ¾>¹Ö}cz<ævtZPñù+D˜¸ÇWBL![_‚k Œ×Ó¸x=ä4^þA„[]•áñr¼vFÛ‘½ëZ+	7s¨nÇtW\Î
úQ½jKŠ/Ïà#{©IDBìÿåe}¡§qú*
NÞæÐw“·ÇïÍ¢cSGŒ&­JýZiÀ¾”9”O‹ª’®XÅÁ¤=¢3³e^c4þì>Håã»0»\
ú§?¡ï“à
ãó4.>ß¸Ÿ–9ÏºQ|ZÓuVÇi­´YP½©(Åkj\í£]e
0ß gzí¥„
ÜÏï›åi Sî±‚X4AÀS€O€ãFèi\„¾!Íñ€âïÀuU_uÛ®š[É 7ÙUf•éI×ËÒÎorÐkŸoãé²ßñû‘½ç©ñ13!›¿_‚) ‡Qz¥o C´Í;—(;ÐyƒÆ
Ò‹ÃÉr³)hffw J&Q>WÛ)R×´

ÃnÖµ/eÉ{qð ¦; Zw{
ðKp„Q`îÜUzÄt³‘ªôNER6ªçjã+ìÜúÅUÿ¸¨¶Ó—Ac v›Ö&ÔÆ¶SÄ×°ãý+À«ÃR+
S`åN‚+ ŒÓ¸(°×¶F €ªåúsl—ë–SwuRŸæoëVÕ9];Zw6ƒc{UÏKÇ”F·»ÍöK8µ˜~Á€q`I¹“à#Á4.ÜB
à6"Q€J"Õr›õT'-oÒë{dktápzÖÍù8W-VÝv¦6ý
^]ôHü~°Dá! ÜIp„‘`%.ÜÁ‚*%¦ 'R•Òa´.W—Z× -NÈ’:ckYÝÉµiaÛUúRJO•Ž¯Lò#{@^0[>b¿ºr'ÁF‚•¸H°‰¥U#uN¤{¹ÉÉ†KÃ¥ÚHÚ4Ì2”çÛ6X¦W…snÞ2Õé¼S'>½k“§ èõE”040öð÷	pøÃ°v¸ÃG ÿDŠ”Ü1ÖÈ°ê€N—ÍÅŽL]Õ!µâ`½Ï
|waWçýñz½Ñ¾B¢7ÃŸq\H“( „~	®0"¬ÄE„'@Ä<ßD„¨¤‹VæÚ¦Ô»(•‰ë’žNSiW¿ÌZÈgö½bª›iVN_!½Æ«˜oðX^C•;	®€0"¬ÄE„'88E‰+À‰4E©6É:ú¶êNËê¡“?X§„;³JÂJ\×CÝ¦ÛÃe¶_/ÍÄW¨8ä ¼7.’"ÌråðIp
„Qa%.*<!¢ôöûHé5ö¾¦­Ræ,w(]{ÔêÙó³"/ÙÅXÞP²²í£TÌ1Ö|~äÆ*ÏCˆ *ô)wL$Œ
+qQá…,–ï\MV,oËpRNON¥…¶Xß›úP—RR·‘íØN¡›h©û¼™Ò>”›§âÕÂ+D†Â¶e|Ø›OÂ‹n“HÅÚä¿U¬
~ø–¿#”–eüÖbmß[¹Ý„1x%.¿‚½¾¸Ý‘z}]j™~­åíŠ6™×ìqÞ0GvjÎ«íQ3';S"&jõÃ§7y2Êy)üd
¹=û%¸Â¼ƒ_€àô3®€jØô³ûV_ãñµ\®†kVlVó™Ü%Ñ}|ÌwËùlÕÁF¾W¡º‚¿Dj¨×ÆHI•RIÄSî$¸Â¼ƒ_à"®I¤1D‹íê˜ÝK†l¶Aåjd¥ªARÚ4Ó=]›öÁ,Û½Åt¾?·ñÅ1Þváï¼$‘
‰,\êW@ƒWcað[®`0L¶Ž£\ºéRNÛä$£\ËL*sGÏoû‰–yQjÇãÌrÔtih±C£/P"Ã“”xGG¦?HÅF½“à
cðj,ž+€7V(À€QŒ~Ù2|Ëåæq4nÓ‰Ûè§4½\Ë-;	êlg¹ueÐÞß¤Vù
LB~Ò þq’D©ðþ¬ÞIp
„‘x5Ï5€­À:®Fî#ìAÝ­t˜^Vdy6ëº„d§í«3^ÞR3ãÚ^Vç“F™ÒuŒÓ'>² yÍ¯C‡!ðÿ|ƒÆßÕXø;?‹‚9ž¬)‡À’{sÉ“ñéåì¦ß1ç•i½£‡óYNiŸ×@WõÖ%FþþóGlW™Òˆ`µ ¿O€ãFßÕXè;Ã_GF`ø
ÃßeÿFØÿ•Ê
òs—ªÝÜu¨«³ÝI_KNw¥’YÈ½õºÛ/Ñiá+©òh¼N5Iyý]È	ì—à£ïj,ôiÀ€Áf‹©5"5‹ÈZUY7oflé›ª«§XîmÊiÒvçRc¸²§ãùlSù
ÝRø.Ê[AHˆ(TÄù.ŸÓ€ÆßÕXø;Ó@õlöÈ4`§"5{låibÓ«[CÜ¾ìûãì6$‡ÓÖ(ITiÀÞ>kµº•Yi¢‰ú$âñ\5‰9WB4à—àcÂj,L˜kàf¸A"Æ›iE!bÅÝ(*‡ÒEñ¼"_éåúÕâUîÔ&õ
=ç›Ãî…Ôvû¯Æ`
 ËÂJ¢ò ® ŸW@VcaÂ\|¦·@[”tn˜&W)u	Þæ—Þt–9-ÓuYrnù‘Ò®X©EÑfµu¤ø
ÄÞ "^¦$Lªªh©‡¿O€ÃFƒÕXh° ¿è
ÊàtÝ«SUkïÖ;	‚Ñx¡LË›vQÎå—šucIV7kTZ˜·f¼ÙÜ€‰ ¯µÛ[ñ—ùþö¾l¹q$Éö¹æ+Òú¹ÉŽäÓp€¸Ú5£ ¸ï;aVŸpŸæ;îÓ|BÿØ µ€À¤”PJ©Îž*›å"‰ãî¾;dHösÃ\‚~°ÂòƒËÄÛŸ'8`ÞÕŸ·Ýê³ê8Ó]Ef½1£{¥¼ë‘ŠÑh@¯‚E¶²}€åÃ¸©}Šjb‡Dá.p¹) a„å‹íÓ×ÅœãØ]›H÷*Û×N‰^ªG²ƒô¨ŸH¦Kãt†­¡«g–Ôšâí¶>xh~†h(‰RÌ¢€1¾%­ÎØÊ
Á€ ?XaùÁ5ä-i¨ÝUÒªåö‹Š>(ÕÓýäÃlb&ÍÓ YÎ´ËñXñaŠªˆ·à¸ï“Ñg(æ bãºÈQb¿T*g€›B0 À–AX¾°:øÜãÉñž[ 'Ö°XAq)6Ñ
Ë‡m¿©/;Ídâa”ÝÏ&`@R¹Âêî%üæ[€Hß)bDˆo&OpÀE!8à
Ë ,o¸uôó†5;v—7ÜJÒXæ†ûÃ8_¢t5ÎäªE}?Ì ]Oª´ÚØZ»Ñ`ÚË†i)b,ëw„£0Eös†\‚Î°Âr†Å¿>g];Üs5´âhZEy
ášUÈ¬"9C?[‘Í6Ý|¨v»¾!UÁj¦?C›<ýNù+G% ùÖ“‰E/~9À–AXž°ÉO +Èžïêèú°µèå
½Ù?MªÍæ¬-%Z­c½ŸQ`½yXvöxºIähíL;v±ps%I–‰¯
/(œD¶Ô¦-8ð†6ísÊY’	Ä¯nÓ†ÿ|u›¶ëã„<øõ2Ë¯çÖ³¯:OîÊ.MŒ}y›(÷5]ŸíãåB™ÛLš‚t)}ÚIÓ­©Æ9s•ápÓ{o¼Ñ$§]æGÃ¾é%!P.
Á Ç^a9ö&ô3êŠÉò]F]FŽ—3JZéŠ!5bÚ¾ûPÌÎa©¶+–k#c2,J“Cs–×&Ÿ¡OÆ™3
å(„úf¸Ï›WŸ)\{„åÚ›TÓ½&E19€÷˜ƒF#.r„‡õÜÒRi°OP`ö•f±eŽm`¤hËùHlØÿŠ"wñâ(¥D¦¾¡xA!äÙÃ°<ûÏü/Î ý¾ù_i\T–Ò:Žl˜ˆg†ªtÊ>Ä$æZ«ÎÔaÂÚ—JÖ4=	·OæÍgp £
½þpSyö0,Ï~ ¼óà Ô»æÁ/óÓE9µo­•ªÙZÉ4;Cý1œ§Ç¹Í¢ÞÎDFhØÀËÍ¨[þŽ%g€,Æ«ÉB¾K%\‚Až=Ë³¢gZŠ`€Iî)4SçÖšÉþ)3— ­M:ñdKƒjfg=ôkƒe=y0É¦ZÙ¦?Á(`aâ1Üˆ!F|{µE‚ÛE!äÙÃ°<û‰]ôú•Ü×Ì’{.fIŠ¯éFLzP’ÕByÝ4¶RžÄ Èe-C/7ýl‘LÃâg˜ÖáÌù8JÌ°o‚	^P9ö0,Ç~B5Ï *Á€¸çj‹Óh6SÁ²¦?Ð:0
Ö¨–­ÔÇ˜ï ·E÷FU
†Ÿ¡ÌIúNÑwÅÝApÀà¦rìaHŽ½³}LGUÏÞ•`*—·„Dê©Llž¥ëµ6Î²E7“–§é1•+‘˜õ°¨t@¹ÑÞ~†B?Î Ñˆå <@~­z‚.
Î äÚÃ\{=F¼›Ì»6Å;Æ.
k›|¬²*tÈÀê³R®_*5½>‹Àea×<m»:~†‰²¨!àðb
rÜè‚B0 È†!ùÂzê¤zK]…mjßÝµz“ø¶>kÌú¥tFî¬É\ïV[Ö vTì>®5-Îê!6«¾]äïNŸ@”ÈøŽ€äpS¹Â0$WXOùÌL¸ofJaa@²•:±–™›F À4Vï[&**‹±1A…ƒRF¥²´K~†“ü]ìU¥Q
)ñMo 7€?È†!9ÂzÖg¥$‡ß¾o¥$eæbQa·Ç/í–jíwE8Cóã¢UGãWâór¢½f›o€ŸÈ°Êbí Q@dÿ9Ìbõ¶‹Bp ÈF!yÂz–£éc…Ú-û+TÇ‡J!7=uêVªeåVüèIäöîv>Ýª]»ºi¤ ]×´b÷3¸²sMqIúgXÑ…`@#ŒBr„¡}ž`ÜÑÚw HÎ,kEnÆg%½6Z¥Ðj\L€Ù”+ÓÂÞ  –¢£:+ÃOQì*§Às
)„pSyÂ($OX´{[®Žšž½«åªKélMêÊÙ½yÒ´bEV#í4,V€„@£^JÆgË¦ö)fv0±¶–JQE4TùÞø‚Bp ÈF!¹ÂzsÀë‰qÛÞã‰±Hj°œ23³€ä¾·ãñ¥]ï´»ýÍzŠj¹Ö.í"©ù-óLÛ0ŒŠ= ¾£È9 Ü‚A¾0
ÉÖÅ˜VO’s`p×Üš®QP×±˜±‹Õ+…V#2ŽGvŒ®“ùÝ£Çf,½)M,i]Ö?EÉ·3’ *Q~‹bß±    )_P9Ã(,g˜_¸ÞœÀQ³³Ç{.âm*’Y®äù´ÝÚµÊõò:ÓèOv‘A²:Ï–µ™Y—GÍÌ´3ØD>EÉ7÷,ÆQ™H’ïô8Áç€ä
£°¼aóäŸÛ:“©»ÆçfÒ[	îJñ]eJÒ°ÔAíÈl_‚~“Rj‘œ6N­æªjFBô~†‹ÎZJ„}ob|A!2Ýý¥Ì¿¼3>Žÿp•åž9Ié3	>ÿ<³æ»ÇðóàÊwB¢b|8{õŠm×Ÿ
Ñ	òãQX~üàè]ðÌEGÝµàyÐW–Z½:¬ô3£vXv{éE²“è‘DÍªUª[BJz_î¤ÐúSø1Š3YœE~9ùl6dßÄ {…à@#Ârä b³˜ Êäž
lš;è‹Iv?.$ÌSÃšéy8í‡ÉÈ°}ÔW­‡euÊeèT
ÏŒþ‰Œž"ª6Ä®¤PÅËr8à¦òåQX¾üªž±S­“èã¸'”’Ÿ±D"Ÿî¶¥C#×_Nˆ®©‘e¹wÂµÊÌJ96Ë‘<<´O‘SU„ „î`Å§®Ãá€›Bp È—Ç!ùòãð}áÐÕ»†¾(&¹ôáPn­jk”ÅAEžÕ¬²Èm•c«—œ@n¹ Óe¸9Õ7s€poRŽeÀ7…à@3CræÇ)às
Ô±z×)Z¿ÞPÚ©ÆºÉXºËf]îPê­No>Ä…YŠv¦‰I#©ÄÃm~ DWý DA~Kž9 à…à@3CræÇª_ßÞIKúõíå†í\vGüV½q«_™–ŽSÒ8Õ#ƒÝªÜœ2R˜k4»h›°HcÞ76>ÐÃ·AÏ¤(”™ÉR^u‹F aE!càiè¼BÞM!râqHNüX³ï|/SïéãB~qélY­Ë±b
ÆãÊ®D÷û8<Á
Ìã}@å…U+ šáSŸû6ä	ÿy%ôµ¸+âDÁÜ#ê•÷àî¢¸ ¹î8$×Ÿ-ÞÎwó®Î5{&åÉ1£gÁŒ±]vºíç8L)ejJMõl¶4%•îÂ-~ó™C¿X¹Â`ìSJãpÀM!8äºã\÷qÙ¯CàÄQê°µss%pòØ©ÍrQ¥òøa™?ì·0R©gÍÜ®-ºÛÖ -i•Ÿ40ÝŒ}8 ¼\B! ü_)Šè«ÒxÏ
 ’ŒðS¿¼rÍÅ¹î8$×}\†šgæ¬à@Ý“GJô&rb+ðŒ
»ñÄ<¿j—usø€G³ÊbÔ…=+ëÕg_[ 8÷(R°OÝá€›Bp ÈÆ!yÀã2õ	žpî
žÌâ]|8K?Ì'+VÎ×ª%½œÎéåÉHžíª]I¶Ryé!!Uráf²ßx
q»:!rÆÿÚDç@‚A0Év8à‰A8ðÆ \÷o¾ÚåâHÉ®¹©€ç«ÃRTu2ù}
Æóõ6?9l»= û¸¾o´|~âø9CÏ¢2àiÔ ôþ‰B@äúâ\ßq»¹>ÐS‡€ðÏÅpØˆÑKs¸[H¬Î²³y5%½&uã;Ö8Ö
[K–TeWôq}}/€éÂ4¦â•÷€_]Ø@S¿Ó]Pøƒü^–ß+–vz#ÚxpWäa/+ÊpÃ¦ËŠÙôÇµŽõ€Š¥H®Ö6m­×õ“±™Štü:J³Qž[°
ÿCŸä…Ã7…à@ßKÂò{[À§–õ¤ÙjP-ë…ÄªãZ¬ÙÚ)ëv»­uÖRJéNvP¬ÉÚñ$£Y£J›
çë—+ Â¥•¸/apSøƒœ^–ÓÛ¢>-zþÁ]-z{4Î5å”îÌ”ZuWoLÈ¶‚*°Ú‰j«¶ëLk“åŠäÞåËø¯%J¸Ék@Ô„’Ü ]Pù¾$,ßwpðî²»X&wí²Ý«la3Ýæ[2Ô¦iXPå}GM5z­Êð±S:CïgèÒFçUÎ0
 XSîÏ7…à@LÂò‚ Ð§–øTÔËwÕ×9»jï”UÇPWýZ[Z5Aîq25ßÍ7åxíh–ÚI¸hhŸ¡ŒFTªŠ¢€JÌgd"ç ¾ ò‚IX^ð útôÜÕÑÓÛ”ÌžR5·éU·*½ck0×Q®›ÑŽ[Új+ô(Oi?EôùÌ"$ŸÑÅOx¦à€A^0	Ë
PŸ‰A'gü­Øg59lôÍND¬ ™ªÕÌV“0ÝÆíÑ¢Sioß×ŽéE]öÛ:ôë= ÇÀ{]¥Ä7‡/(œÌ5öÏ\Ë?Ì\“ëÌõÇ£G÷!*½2qíþS!2An;	Ëm{¼ž‹Øpç’+K8Uª6æ¦5/
@VÒ¦²Õ)¡u7ÕÊHUu75“›ƒßÊf_ÃMÔ•C‰‰¬Y¾ƒè8kk£Læ–™¯ñ†/(
‚üv–ß>á¶³çÜ´Õ$·ï87gº6Ëî;‰4
ÝhÙØ0ÊûÆðÙÂQ¯’ìfÇj=·•´ó†ý"Ç7¿5ƒ>ƒÖÎpQ¹ï$,÷}B}¼[´HÞSz•>lzrÕRð²–ßõ2ûÈÃ"2±ÂVa¾Ïv¶ñNX/Ü~ø7ß\H:Gg½¥W Ü‚A<
ËƒŸøÝ\‚A³î.Ž¡“f.{vG{XËÍ¡:³b]+é…c+-¡cv9d§ÀJúMZûc‰™ÊQ#àAÇnÁ€  ž†äÀÛ1¿™û¶ªß7s¿½mŽû«uyÐ{ˆô2ÔÐ×sØ¯áÊÃCdÞŒ2s«žî}ãˆíQ#B}èø‚Bp È‡§!ùðœ>­`‚A­`* ·-#cïÛz5&¥"S–[´áT¸Q>îk\=nfÕÂP†¦ >D§<Šò4öúZ Ü‚A^<
É‹·S¶f{r¢Gß“ÃXnX3cÄÅcUé4©2—æ‰Á P˜l+ñAf[QµJÍ¤]?|ˆ(ÎjIf>S!ÎpQyñ4$/ÞÎ|–¯pLîZ¾’ÕÛÕQ¹˜Þ­‰%¶úñ˜¾ÀJÁ2±Ò-Ê”¢F›ñæÎqÔ×OØBÜMß)×†¿-D.( ‚¼x’o§HÑ›Êà0É=Agmm²Íéºt:<1–¥qOöÐ4Æ[3'ëùªê­ø
Ê>™Ô8†Î, Q"Q|!rAÁY€‚Üx’ogEá°—â†¸C	j»n­Ø(”Ç‡¦¹BUí¤çÕtûXI/†òÊJV87” –g!Î]þ9%[l£’™ÏØÙ3 \‚A^1
É+„~J`—ï*çÞÍÖzy†,[ªdÖl¢mG9§µT·×ZÆ›ÛÎ¾Îì•f®JŸ"™‹µ7çýËøÈ…à@SLCrŠmÕ/œ+Žš»Â¹G´Le+'V²mÔÞÎf(™ËôÚëj‚Ž›½‚0ÿ![žµÂëû)œg‹3@©Ï‡n
Á §˜†äÛeß«XK^ÅÁb’(LæÇñl¨SÛÀS2èÖ|XáÁli/Ó;qW>$?ä"À’¨Ûƒ@Äü/7…`AW,…äÛeî{**mM¯îªçVÓ›c!×U [Ö"§ì©_Þd§ÕD§{(’erQ›]¥lÎC¬ìû©‹€ˆMªQÀqä[SC.( ‚Üb),·˜
µ7§Á_ËÞ•ÓÈ%¤2ÓKLÏç«6^èýÔ|Ñ="3WÊÃ|+YJv›b>£õ?Ccªhø’„Ç…)ókÊs8à¦r‹¥°ÜbßÒûîÒšö<>ßÖŒQ‚eÈ*]H(½ZËÏµÚNÉÓñŒiüõY¢Ú¯>É1Ä†$Š%‚$ßÐ¹ ,r‹¥°ÜâðgÄ‚
%02¹ñ¶_˜F	e¥Rr¼NÈ‰]Ho:•Úl’@ßHÌZØ™ÏÐyæ aQBò™ÓôÄg
Á ·X
Ë-naU÷±†ìÖ1ÀºP‚ì*1¤]­¦Xx]£Ú©Jy=±m–Œ©ßÍKd»ã¥CîÞãwT¦sË)rŠbˆŸ]‚K% ‚A~±–_l"Ÿaqv1Y
wÁýaSS¶«Á<q¨JƒÃÚPmCé(C£Õ‰ÆÅ,+ÊJ¯ÿ	Î!‡Ø™2Î€¬@âÏ7gò‹¥püb-³}r•@Œ°¹ç*H!#­²Ó^$ÒûaÞì‡Âx«€JŽ·ã\mžÙ“JÞ§ÄãXàÌdE$J¹=é_i)]P8inâŸæf¯Os;M‰?Ès#á–Cð­Aåþyn×Ÿ
Ù	òè¥p<zM¬”ôN;¢p1 ´{!;‰*BÃ]­k%§Ãm7Q.d,–(™<0ÒS%mtÖéj.í„!÷!²Cèw(F	î0úËŽ›B° È¥—Âqé
ŠÞÁêe«:…Z´¹+é–½¨v×©X~fïÖfUå¥ca×L ¶±Í+“UýÞúôwÇ^•WLâ÷¿oyŠtA!°ræ¥pœy-©‚¢w¸à¯Ó{êsOíãx_ÚŽëy•§êÊî¦ªÆ¾vŒ
i6S}ØÙgW±¬_‹Þ ˆ?röó¿•$Ìd?ñ—/(
‚œy9gž;,~ŽŒh¾Ë‘T ³c}•ÉW³sæIßŠ“z£¿Î´Ak8)¯ºú¤GióÞ÷«ÑâÅÒrn##þØÏè‚Bp È™—Ãqæµñ øÌzD\1|f=ºËã°‘76™šï”+ÃjõX=×Ï.ûÛ º¯4µæíiúìò|kk0»QÄ»Wô¨rèE¤VÌ	dO;”.Î±sÞE! òâåp¼xÍ©ïðD²°SßqÏ>ÛöjZ•ÒÚ *­t~2?uñ6g7åR©h§‘8ØñM÷¸yµCCâgä$}-DëµÌß™>nìŠn
Á€ ^Ç‡×ì·<Ü«l›mñ‰²%eÊÅÒ¬´9­HŠÙÃÚl¶oÔ]D;âr¯Ý,æ#¦TŠÄ|ÿÙçV
Q¢Œ¿‰â×Ï¡wSèƒœw9ç]@ïS]& ¿«ºÌ~XdZõxaXHé0Ó?)‡òp¤&âéì m´«Zj¹e]{=|üLˆ3 œÚ1,!Yñ
Ÿ¸( ‚|w9ßs€ø\½œæ]¬]ë4Yâ©^VKÌ-3:Ç‰doQk“Oe›l!Û ]m4æ_×ñÄ"Šˆ¡ÿt¦3 ž)8 Hë.‡äºÛ©ƒæÝùÄ90÷œÿËLyÓ)¦7Ú(¿M)‘VšE6í#)uÑz¸J¯WhËÐ"h¢T¨:ðæóŸ'2¢ ÿê2±rÞE!äÿÊ!ù¿6÷½€øÝ]‡¬å
    9ÐÄÆfo}²·ÍÒª¢Kƒ•‘Š•ÉR³„©ýã—	3ÑzÁ=
 òY÷Á9@/( ‚Ü_9$÷×ÎrÌÃÃ—é=miÑ *­ÒNF;Æ3½¢B{*ª—“
)m7¦%Æl¸©+?Ëá€r%€Ÿ0~m±ñÜE!8äË!9Áv–j^ûŸ#< ÷TX²ÁPÓ²ËÓ!Ñoí“ÆC
Œ`µ×jaî+qÜÂ	²*€¹qoiÓý‡ÿ¿Êã±AþÎžö}(WpS¹À,$ØV÷<Ð’*º«MuR~ IkÛ—Ú+m<Ì²âa–;T‡ã=¥íÆBËù(;îÏ`	q`Ñ,U$  Bn
Á ˜…äÛeÛÏÓôì]~X·DOn©k<ZWêCTË&ãÇ5XÙd^.¬w{+ÅØéã;p; ËQ@cpSyÂ,$OØnÁb²ìå€]&Úa =IÅË)¨‘uw´{à‘aš£Á¼M écn³} ­¼œ(ŸZ“{ËjÞó‚Î>	Â-Iò-ò3*]ÿÅÍ­ó”ÄZ)ÓSb›êó·—ž23c4uÐëYëÙb¾]œEùïx=j.fÏ©ˆ«t‡óÚtaNœìDß˜nv±:ß`gc‰ˆæŠµxÒÀ]¬ÎÛÌ½Qäzè¤JÄ]ç“(£ò?^¾Š²C
J`üéŸí~3Ÿ_/Íæ°XŸ¿…¬È†BeÚí1‰õ1èbF¡€…,fNræüiÆvkÍ–ÛÍ£w~~'k½YÌ_Ò@ç/gpqþæ‚©X0±"ó‹Y7ËïÃ¤{`ÿi\AX¸J½ÈØûì’!GQ”¯¨(¢LŠRLä³×²¦PC2êsžv!†
Ð"ÔÀ]JûÌ°,#Ž¾<
Õû˜PgáÔ×a÷HTÊïqœ™€ ÉèSdJ€A»Â’„ø
Ñ#ÔDïÊ¤k­s
¤£vôKª»‚”|–û	ýçÝOÿÁF„Gí^ò¿ÄŸ ¥‚ojg©ª§ÈUË‡è:;ªc3°åCMÆˆ¦O»|ºÅå(ddsÀ*‹Ôº×ßMÖp$mV­Û¥ÒZGZõ
š>y’§ ë+&X9ÉÂ
ra˜ßg“¿è:…˜2ø4:Æ¾‹ÂA?(4£„à—Ú*PÇ*.êåKô…¯šLÑ ¯è}’ü¯z¥#+©ÙÂJ«ukcÌÍ mÙ¯t“ÍJ’åc¸·Øú”ˆü"ôQP:mXTÍ!ùi Åú‚â›ØŒâ¢pÐòI•2Túexµ
úýIà*h7úX_N cTŸGÔê|².çtTô SØ=¶Ú¨GêãX­PŒodŸ	¿}¢ˆä†ˆ(Š?ún
 }î°â_pß?¾ø¾7É~“Ðïˆ	2“Þá*‘ÅêT‰È Êz21L“QC&]`È}ß«¿Ú€s3UŠnÌ³¯pÝ»˜•¨DÞÃz“^m”0éBë„oëH¡uþ…^”Îù‘~: jZ¶žªT³ÉXò["¦ÿû
ÙDì[5¦éÙX¦ø-™ú–©ÅZ±r-[pˆK¦½ÞÚÚˆÇùG¬žÒø»ð7©ŠÕo¹Z![ü««)5¥Å¾åÕo0ê€°ºÍÈy—‡èÎÜ¢VoµœC­gmÌõhùtè¼òûÉ„Î°=*ÂôCŠ#NBd;®G0ækjœŒ¹m\ÊóÌ˜Î•'ÐÔj"ú-¦‰‡-Rß*)-ùïÿÑår¸˜[ùnÖµÖgÉ‘,	?ùÝ+¿ì;’ø÷–!‚¾{¬þÃà_Ï`F¡²‹1÷3øå{3®·Q
BýO ØKø•ºs+ D!’,jphPù
£üÉÄZ2{R¯3O¶	T;uº+óddÕaWpV‘vìÚx7 vb8IªJ¼½s‡¼ÒZÐòfqoú"9ÊÏ» Ú×7ö/a Öâˆˆ…åŽœ¤\¶QBP¬ÅqS8§-á¾fõÂÂä„W¬g
SðáÖn\~ÔŒÆM4DÉau£›Ja¹]Ðí.Ñªæ{©CzRšïŠ‰ÎÀo2¶oùÙ{™–¢ [´4Pî]Už=J=¼ p`§A°‡PõátÐ›¤x¹^ÛvZZõñöp»`7µÂ†¨ÝÊ7
ëÝ¢žÕ\íâÝºÆlrZæ*œî%ÛÇõ½%÷ï»äì‘}2QÀ½$z`—œ=’.
 v)öJ=ØÅ4àkoVÀž=x½Yì•Ó¤>Vöµ-ç»‡uþ°_¥·É"h/ó{% Eùaµ“g÷[¾#ìbfAT2–h ì.
 v9öê;Î°_ }„ÝôiÖvÁ®¶ñétx˜4Êr¹ÔnöSö¸S8áÆ²³CyPèéSµQíÊÅ{ë»ßv‚ÄbK~åÂ§èÁ5ìn
 væ;aDÎØñÕî•GØ'>»W\°—Ti[Fìâ©
¶hµ×e;;C¦ë­£FqÉ›’lä3>-‘¿v§_ @HqÀ!ã¦p`
<GLŸ\Òe.¬^”ÛŸáº£4hätþyµ™çôê‰‡£ìÅ"I"‰jE_?ô2¿ê~£Ëß¸½OF}¤Èåÿp·3…À"÷ûæ+¢ÍÏ/xŸg:kè˜ÂÎ%±Ÿœ!?@ø§qôÍ•½Ç—¶N®Â‡w‰ŠÐ~ò>aŽÅvì(+»8|ø@4}€½u­î¾†übkåvµSd¨U[hY™ËË²2²O£™:zÈmë0‘ÞL"GÙojî½ëàqé…NŸ%@v_³.ÈÝä0ò*˜lg6¸ZTî@^L¶|•» ·‰šIú'ÂtØX“|{–ŸÐ81©Ž*€àŽ
ï &ÇÓá•oƒ:S~˜˜ÚNdä ¹tAát]Kþ]×Â®y—®kŠ¹
B
}½÷Û]×ÏêÈ
ú—„¢ä^Œ³dQ‘¥ˆhÖKÊ#y²‚1 Ÿÿ’úm¬†WÞvÁyQ'E‡[æuÂAGoa,»…T1l$y}ôòcwÜòY4é:zYgcµ§ÍÔn7-	bÕØck’YTPKùé°¨·»ÃÚæ£ŽÞG%“Ç£
f’â¹í!wQ8“_“û™7T,o”$¤7¥ç‚èMIŸ×—VýòÌÜŸìiH<ò(œK…£_Tá‹Œ	ü4}uiÕ—Ì‡ýSQòjÜ³,:'}QÃw[e¬°Ï¢qa7|%&}ÙcÑGížÒQ;ù«Ô}]2”â¨°>
CÿÔ}ý >Z÷,ŽÖ±/yÙI"F
 w½ßTÉ÷I-—?§âç?=þœK…ûEåÍ¿XádþO”È“Þ£Ÿé?÷çT¼ÿŠsÉ¢Ð8¾¨ÆQ±¢GûãÏý ‹>j÷,ŽÚæÅÃè¢r’3X½\˜ó˜œ™ƒÖv¹»¨öJ¶³çåãŒ æ÷s£^Ü›CM±†cÐTìÂŽÖ­®Ïˆé7tQ½9GÃœ¹Y`êî r#ï¢p¨.f „ù~yMWmõªðÏ­›¬nþ-H²IMå•\8ûÔ‹«1þ¼Z_äÃâ¶‹Íé œêâ7A~^V
h”2,êõ¯ÓbèqYé3…yP”þwÊ#Cä<¼üà(d”(¿abÿ…RC‰¢ë9¿C>Y¥Å[û¾q©vÔÉ%sŽ:}µüY³Øy«"“•÷˜'@»}¦FôL… 0‘¡ô%‚%fb
Â0Â=÷CP¾šÍöž†uxŠ÷.I×ŠçIGñz£1IŒŒqClpe:˜@ÌŠôŽ}p™3c?ZÖc<V®‡Jè¤/3‘dbo*Å-ÜD˜&iuMÑpŠ×ß`:<é8‚Q IÒÓÏYç¢p ì£)Éü¨]B}„\…AƒPÝvr¥ÑÒíÁD·ñr•Ö"ãc¤Ù8šõÜ”Ö‡:=Š‰d¡a‘ùŒáü5v2z\®
©ˆn(Øk'ãÇåÚÏyòÕT¬—ò‡cø=ºØ`dà¾iJ†!)2éQD»R Ò¥ŠIÃ;¿\\•)`2þ"·Ì×²ü¸t­xn‘t~IÅSÄ†<ˆEï‘Õ0{†ÒµØ•Âú*ÔTºrORq¯Ê$½ÿ ÅûÒÇ£Gñ\"é(
²5ÂèÄul
ªú˜wÅdêxÏT/¹¸²
MÒëX²;h'—[¤*xÜ=åù\írÓƒU“»‡zµÚú@[‹Ær ¢(ÒÓ¬õKäÉ…ƒ|`©zÍ¸ùÔQ½Üøðˆ¼z¸Ùñ«œªø!ù %ZÊl¶52Æ$ :“M*ÞlßgÃõ¦‚Ø)á³jì—Ör*ô–_—?Ãš\P8“¿ürËp%~lùá,~xú¾±µY¬ÿñø*×cgdÇÕÕÑõ®Á7q4‰r{"cå¼ˆÇùÒ–ç/›å?à^b×µªË¡µ¶žˆ¶Öq{õDì{€=”âÏ®¦¬¨ÿþßÞnºøöÉßŸ6Ýã7~ˆ>®{Å#..¨q¡þâ"]?÷®7Ú.ÖÿþÆõ³K"2bè7‹"
e& ŠL|±˜lüeåùq:ÒÛåå“¿?v?!7îGº–7æŽìHþ²#_=ÅZ.6âmG‹k ä$Fu0EÆ
OlmG{ÿ£ÆõDùÍòãÆåïÏàÛ%èò¡<"äBÞ!Ù_„˜ nX[óžaò³6×(°#*EbÜœ	#Çz[µ.N²tñhöfyêYß®qúûóúvÑò}>	{fŠ#aì7½à°hl¥ód®·	××¾ç~7Á#«.;²ª¸K0Œ!:&âŽçA½¢£Ù&-{º9DgQ.Ü 4Ò©
žËµRmÒ,Ô‡ëë×§ÙõŒ¦g=¬9œÙE¯w—qD'0J%’g¨"ß„¯ä¢Ó Ñ!0ŒÑ!¦øhvër %¹÷zkycUb¥âxfÛVúa˜–‰2°ª4žv*µ|½~TV³Í>›Ðæ5:„CÎ5LaÜ¡`Pöx¨r(]P8 ÅA§"ñðb¥˜¡M0Áø%<÷ÛT¼0P‰"øÿýÎU#Ÿ¬Œç-U#¾¹T'v!sŽ:E7a“xÄTÓU¯‡ñ¬¨§ì›ã âRG“þ©´ë/ºÃAºÍÿ¡Ãe{c£‘vZ&2Jm¦-ÛýœOXó—`NŒM¬%“†ØïcäøËœ`ç¦ ð÷<ÁÎ”¢ÈŠü;Ÿ`ŸíJyë	æaÈµ:¹eÎQ§ Ê]Æ@q‚©'³ªÉòm³wl
‡¬ž¤ÕÉMÚ%C[7fñRK{³ÑÌúLŸÔŠ»˜|VrÿÂ    Éb‹
T¾6» p ˜	Ì`eê&.&Säj¨€œ¿óYêÅœËÖ«™å#ƒ•Žâh·éÐÙ²Þ.ÙFÆPÇÝêÞ0,Ñþ¨Š'D…ž‹Ä,ÿ;•§•Ÿ.È©ð4Üäó€£>Ý¤ZrpRõ«út{5½|¼YŸ>ŸŒ#íTN*ïzÝœ}Rº†}ìöJ«úT/6…r–‘ÕÚl¯3‹Û„$aÛ‰a¿,
˜ä\‰_7…¹üb%S…Ô9öó<ÿÎ‰GˆŸž¾qb1ßì¦[ã	¿y
]À§ž.‡ÝÂå†(üŽa3@Ï±A‡ºgM­ëa{Î£‘óìhÀ ‚o^Î/\oó‚_‘_»©õøˆ‡öÄ?ˆÖø?ppüÏç›^3Ò‡ÃÈ ~íßê~—DPŠ21ìMÁÜAñ/´ýÜ—KV‘~{ƒëóXÀo2¸ür©NäBæu
Œ3†QïÌ¯"]¥š½¾Š¿ž°·øÖuíâÅ<ÄÛ53¦öy¨öåò‚%«‹Þ|¤7Vzu
5YkN>ªUêQ‰•ïX‰è™ ø¹‹B@.?›†~ËMC<ul>nÔ‘(„2Vn%}ÿlú­ü–UR—Úþ²Ck»3ªYtr1×¨æ3L~²€&ÖI¼cjÃÏ'ã\Dà¼¾[;×æ¿R{cº3{þUå$–nt§Ö3Õpmõï {òü)KïùËüØÒ×m2gñ,†³C‚$|c2ôÓ[{nÎ7,:‚÷b{ºíA/NTþ±Š³MÈõ±c™Œwksyþ{$ËùñÎÇBÐ	»JÜeã¬°¯
~U{þ¸óõ³^ž9ñVçuÓX[çk|ô”+¥õ’â3Ôˆë3[þ…¯n	ä>EÙ”–ÈÆªßb™J¬ÂÿÃç¬à_jdmŸ‹ƒãzœNÅ+©JÑ÷ˆ¸q@ø~tà1€tÄ\cH£„ÃöXÖwul®ð[Cäóá/vÛéb1	:
rµ˜ö-SlÅüµŸÊL"ˆ²Ÿ:Þ%Ñœ€¹DýµÿêxÿÃ™p8ãsœò¯'Eù1JÈ‰4?þ7-É?‹›ØO'æŒò.—ojœxå”Œ«Úpnxp‡^ÇàS.}½ö—¤+½s‹¤£xAy®ß”¥ŠÇYŠ£D†øgX~Ž¥–lôiK”Û(„IýR°	H·ß3û’ÁØÅûs<zÏ%’ŽâfÄÂèŽšñôÍˆ óé›ñv,m¥]%…ÊF×»½ùÂZ×†±Dr…e¤z>Òª2r¿6.­Ÿ8Í/éX:
®ŠÂžR×È»)äÑàù_4yòÂ’bÂÞ4+8Îù¦Ãî•C'¯øI¢s¥ý"í™Ÿ÷Jz‹•áË¥këÞ-ŽÊ}±±7 @1+
K¼m^È:7ÿœ‰ŸûLôh›Km
è¸qêÝÕüçÈ¢è³øÇ?/«ùjô»Ëù\Š³ÙIBAâ¸›qX†2–àfÑsÿªþ—Çê@p›³7Êú]àüýF•_âÓûˆÖv^¹ `È~D%=bëâ²#¶_aÑ­`…;Nt‹Hÿ†£Ý	P†0e¿uÉå'+Éxk€‡!êÉ…Ì	u’Û^Â‰aÒb²ùÿ¿v0)Í¾Yÿ7Îûc­ºéU¡Q­ŽÒ(QYž¦U´Ï2ƒÉðX_ÚCØoìÔp–Ó¿Í³T„C/šZ  Ø[4~†ÜEá@4†1
C@>9h×s9äÚ8
oÖéÖñ«FJû¾†úýT,Û6“vj0ŸM‡Zn¨eÚ¥BL—Ö
ö¡"ª`Eñ«ÿã»)È‘HÃ¾Ø:/iØç·Ç4laÄ?¿·ø–\˜Ö|km:Ð“5–ËÍ¿2Öf»Xÿë‰Ì›½Iõ„Ïõ§y³¯+ÁS"þø ü?ÿç‡—ä¦¤ò‘¨0ÉiøfwÅ£ùfuÉßø|Áûáë÷à—rJ/@©l…þ…¨ëhð¤
ÌçÄ§?™šWhìÿü£%Ç€”¿SYÌaÄH
HÉ¹¼ž‹x™øûo¢·Úõ÷ŽŠá #Ê•Š%vüJÛœÇ³\0~kæßwÿ2œÄš/|“ê9
ë|†‡ÝøUì~ªhÅòwÀ¸c…ŸÕæ²~7ˆ4Ð&w~áW¼ûDPT	(’‚¥
 ðÕÉøâ¨ëA@ù-zzqi¬¹¶<rïª|ØÃÍ?\¼‹‹7ßýN¾Žk×g[x…%A
K}öÛé›Á/äý¨gp?îÇê{&Þž~È{á%û/?÷KÃ¥J…càÍ*½›nGKW±×Åý}›áXû›è9òUógrÔœ©¹t­æÆ”;óiüŒÇðõpÛËÕ‹wøIcösðÓ­ªÈiÇF²ØDòUÕ.î¸W+é5»þ°çS¨›K(u“‚ÔÍSð»7¾ÇöXwèÚ¿¬½ñ¯åšû1›…øïÎÚùS]ïú%|©GaŠ„Þ¢•KÄ^oú^sðÓ>…Vú».YqÔRþÓuó[6e¸ôŸ ºV0r‚ýéºù"~M[Õµ¶
É£²Œ(<_ÂA;EP(ãÓhQÏÂ¢>ñDØ‹:ÿ§ÃÞ[5×¶«MI+/lKeÊéN¯³¨õEËJ––‰ü>M‹`4OÆÄhÿUUsBãðwÄÿŽ)Œzæ|?"ï¢pWþ"ÐÕïd˜/â‡ùhoM]?ßÕ˜óüuù`2&ýãñ
fÆ±"ZÜ” <½«53ú‹õâ®Ê	ß¾$Nû¨ˆæ# üM¾½÷ÿürôâé”ì‹­g9ób1AIìš'ïQFß“»L–%Òctq—›ã²¥@Y¬ÿ0LˆBÙÄëQ†‰Ì¾Tâ×¨Yó2èúørK££s\)¥[/¦/ÃßÅOÇí9ïôÇWï´ÌÅF2Wîh´é80=¦lžì¹<“jVû¡bq~IüÞJ’r—,ßûÊq®éÑf»6z‹õ7në{t]Ä¼]ë±Fçßÿ{¶°>4?÷0—B!] éEPò_'¨æãÈý$ŽUc¾µæ£Ùˆ»1‹9èÚ(˜éüñŸ]DX¿]ýò­iå0
ž„ŒÊ"6©(B
ïQ7žCàëßˆ
ûû,Ÿ˜e¯ÍTÿËÎ¾¿Q°É… …+˜¡0YæQI—à8*‰ÿ¸ó¿µ· Å(`Ñ	¥  á/¬?>ýïÉåWm®U^ˆ Š2(ŸgE³ F8ÆxîÁAµkv1yY4WLÆ€:®‘›Esu=ÓJ%õú¸™y¨ç¬ã"?€ØLè8ØÆíy<ÖMféi9`6ÜVýËX#M¸{K<;Ý£Ö\àAƒ!QÓ„  -™Z²æ¼¨·€vkJan9é©ÍŠº(Žcƒˆ<1ëÂ06£v³¯fc–Ù vÐôä‡ÍâdŽEøµ•	æžŽâô‚Â<h0$
cüéà¨ê)¨&³W§ŽÅ¤y¸9ë„³‡6¨æ»‘n<9ëÒòÉ:sv¶´(×âõSAï¥Ú½rï6‚ÞHCÄXÿ(’d${§q9³cÜäA
ŸQãO Gm<!ÚÕF@9Öì¼½ðY¶‡
;©æó¹½“Rdv
Ju›CÓžkCõž™hgÕ;!wNlè‹7 ŠHb…¯À\q¦åÈbâ"ÜBôÖ?+Îl…ƒù—˜á¨ëXìQÃQÌ£þkl?w ‡›2ûe~ãŽOÖRó¦?†\ª“|!sŽ:ÍpDaŒæG˜;iWã„ÏGXÞ'l&‹Ííz¤ìGûMkZOmb¥3@}Ð—‘ÃÎ>š•Þ‰{g8Ò(” ?¦hôÞñ stÂ(Á2•¼ƒœŸ¦È+b”ã3ðÏQ_?ÿäq"7ú
ßR‰Z,Y¬ÜöI¾=9%ˆ
Oáì“´¾•þý‹ßr±JLÍ
Å¾xÿt¿­ÛOi4ÑÚãÇGSÉZ4•ø¯ð]s3Šˆ<ƒsë¤
Ä~JVKÿÛç{\û'ß²Z&úMUô‡Ø·x-!õ[!Å¿\QK½ÞMyò.ü¸ùØìEeâx
ôÄþpó×s“­’‚~0Pðæµ,;»M¹a
•îªøÃçÏ©µ•=óÉXv®>å«Íƒs."ÈÄâB	‰˜ëgI‘¾eàÑN‘~õD¶t¥xn‘tï«Íƒ{V<…Ûœ)ï1|çM,Eï?éxôS¼'‘t/0ÆÀþÁ±¨«XÓËWÎ^ö &'P»¯#[sk–"r;3Ó‡™m
©5¿éÊ”6µ˜«¦;ÓêBËÞGgñ£û;%QŒQ¼ÁYå›X£à¢p&yËA“¼õÈ®”rÅrö©ô+œƒ¦yëk£ß™…Ñ`øRî7ÏÛ—ðewóÓ§yRÆÏ_ìuS½¹ÈAþàŠŒÞ2Õ;¾6æ½Ìb1˜Z±¹1=mGæë¦{»>Þi‰–‚¦{‹Ç»º÷Uß3‘õµ=<Ý?½þÃéÞW½ÒÎg:Zü‹f
þÊƒYIz¬D%xƒ™’ÉP_¡rb¨0 -B
Ü¥´ÏËòÔùçúü2r^®OÄaâIGñ3laŒS×g
iöu™_Ÿãöf‘½…áëí¾–k®O#=VjŽW£¡öP¸œ­í“ûa>	«x)š¼ÚxoQßÂðw¼E§8*1!åº>ü™ÏƒÕaŒœÔ¤ õ:Åé¼Fo¦8‹½²ô0^ŽKKª:e‘Ø±`W& t×´%¢©›xsòai|Eì§D˜%2Q$ïŽZ9¼ (šð„Â7$V
ÆlM]C~Ôl.Û·LÆé œ6Ëue—/ÉÕ­6î›Ö µîèV¦×iÎ:úNîÍÅdxï„§÷v1)}Ç Š¹A‚=S‡òä‚ÂAÞÙoþbº¼|yp}ƒÖïüÔõáþöNî‹œÒíëÃç>€ñëÖuí\tCE6!è
3 PÏd&æœD}Â¯j ½"9†üQu}s Õ ‡ÑÜãÈ3ô—gÓGžÅÑ’‚êx"ÆhS§¹‡®4®¤ó°É˜Ìˆ²:óÓ|¤g&cÃÕ¯)Ýl?YnÝ‰Xƒ7É5dÜ#–¢rüZ±æ~ˆJ”*äI¬Á5 \$ ä ó•\‹µ5Ýœ¢ëE×e¯ÿûb{ÉEûf‰«Ì¿0žsÆþm®²Û’ÿº¾ä3‚N‹«¤p_Ñß¢‚HÜ@‘1}eâ=ÄÍ4*1*óËÓêaúŠÌ_µú
TüuËw€¬hLks·Hß	‰*„(]™¼asö¶Íû±¬
|çã©ïyùžzW—ì:ªÔ9‰C)³‡+7=ñ%~¸°7¾ä=\9f¹©¢T@_Êïö³ùüT@Ë}d    ;š	µ·O%†Ò¦ÉÒ¸è·¢ø×®²°Å ƒH	<\]$ çÛ†i4ü¨ßòu6ÃH&Ús%dð˜wv“½Åøð= !
Ô&?D‘ëZ©?6]X°z)—üA±Ÿ™ ?ÖÌ¢XxÈþË‡­Ž„ÇÌ?GØ§>Â|tíY]
VŒCiÖ’-ƒ`4OÀÆk¤gz¹u˜êÃ™6f©EõñlÙk,Žõtº‘ë•Ö§M§¾Ú¯aÅ¯Èð×Êw E‘¨ùgA‹Äá ý
J%S…Ô¹ýôñ»ËNvçEGžŽ«™“§põ×qA|i?Ô1Ð
ð§ 
º¤æâ¢H
P¤_A
üïô¨ßa?ÿ7ô*‚ûÉ69½¿o6@ #Ð¨÷H>KÎæMÉtW<šš„²¯“³ùœ™µ7ÕùqIºV<—H:‰w”x¿EÛŒscýíqÀôÍä{l³Í 	gJéÍä»/ásOÍÅ'†”€?o¢
¿„å›RãŸ€O-s2
š¾uw¦sÚõèü¾z$N;Iœé1£wÐ£®aZŒ`0Ò%’B-Sa]¹×ï1S6$©÷ç´ûs'yN;—H:Š” Å¡ô€r{;uâö³ÇÞ.&Ë§{F—MT­€ö“Ñæ°TfI¼°Æ»¼ÉE ÙÎ—£e
Å§5Í tòé¾ýÅj!K¢h<J%
$Ù/CM.(PPº‡ÒzÒ’µ“j{ÒKÜ©)Û7Ó¥í¦ÝÁ•Z¢„êÇü×Ò™Ñ*¥ÚQ‹5¥\…vJ3Þ0HäÞ&ÜwB]ô`‘4‚bo/.Gâ

 ù@W3”F¶“¦·¸ø{jj—7kr%£&+%j
F•CÂ^·Z==Ò·çµüXIí›åì(c²S]ùàF6‘´€"äOQñÿQO«¿@^º pGAÈ‡RUzÒÆ1êS•ŠÉÔíªŒagj'ãs{´þö8«ç
íMu¦6†ñzå-î‹z÷`•YÛŽ}<òÜ»ç‡9ŠR~2ä‡<» pÇAÈ‡Q4ò¯wAqNµqêö.¨ñê¸î± Ð§
írsº=MZ4aQ”Ú “UÌd
Z¦¨SŸJ¤·ÔÃ( *qÈ"r'ìHä¸àS©.ãv ºêÜßžË}Ïì5a”!M°:6¹p_EµÄÐä€x£Z.Ø•õ²äBa²¤CEÝ?Øc%V5{p`Gýq?¾5è~©e+å©_~ë—	<ÇUÅ„Š™!„Éz‘—D»›ÂA>h¬£i‚µdŠ#o^#Šù[¿;®³£HÍJ%‹K8ÛKYPÜ¥;«A²·Ç ½ÑZæ´XõXìÞ
ïˆ¼$f‡9*Kb’šxÝîA•$Œª™	U¹¨Ù×¸óhlâ›¸Ë±z° ]™"³Ýf´Ì7b…Üf¸k6
‘˜¾Üœ¤Lr»Ø6ø`Ü™ÀŠjî(¢)Ð<À»)äƒFŒ0Rêù±z*^ÒÑ'¶š,“›ƒtòK#5‰%é ÑÐ[É]_Í¯jê¶”ÆñÒbŸÓ‡‘šÝ¬%ˆœZ}´Ä;a Å,™b${€wb. ÷ RFæBà^>ð½¸ëÙÓÍV™&¦c~ª›uÇŽM­´Se¹SPléØ_sÃ 5tÖ%­+‰ûèE	à ÉuÅéðn
 y%``&õ¬‚[X®-Ìžx{}‚¹°:ÖåewÈÎ±{zÓíb­]OÌÎý™žˆÝ« cž#vT¬ñS"ç¹–þåJÏÔ²Hð „áK*Œz´g†IÎÊFxI%¿bOî%v]«ºZkÿRð%÷ÜFŠÿþUÌ¾‡öë°;t.yô×%0NÄEÜÑKKkk°›oM ]óófP½¼³6â?¸~N½Qõçwõð
ÝÏ/wGN–0$o	¨ßØÔÃæú@ P(¾ô)¡ð¬wÏžŽU.6æí&Â ÒëLF0ö¯ØÆæÆ^l¤ŽJ„Û÷oê&\,&¯BÞõqò8y€üóâ_r
øsVH?o»»#tMy
{à‚Zò6Ô1w3òƒµ>þ¨?Œ¬µ±6‡'ô*ì]ê`O‚°¿Þ7(zXùÏßÖO½¬z
ü—ÿ¬îf3cí³‡ð.jw
íÅÇ{¸@ßÊ*q“L–ýWì¾ž?Ôá
âÂõB¹Øn»ø–zÞ‘njÀ|s°ÖO§Êmð'}Ö«Ïõ /½
}gŒ»Â Fô
è;iÔÝ2puü®OuàÊç0ò9Â
1:Žy¼-Ù:ÝL'l‹m¥¶ Ss”ÀÖbÖR"³Jå³ey£g‹BE­äéÓ¡ÚøÐ ¶ÃMÄm =%ÀõsB ›@àN€¨šzñA¿8ýq‘úçU‘‘£(·-BBøÍ#Êèex»ê–é.žR„ÔD(·¶Áþý“ODQHOtmKÂ‹'pø€|«×ðÕkž¯íì©
üÚäqÜ4¡QI>Ãç_»ö¶ÇG±,cpûx~m÷ˆóeœú±ïD‰r³š›Öwró—{¸ùjX^%oyP¸v„û
…ò¡¸©Î÷&¢
&ŠV€|ŸX0~@Ü¾7~\Òxý@wqóõÏs·nºžÌañe!o`
¨Ä<m*„PÔb#11
Èô.6 e
’oÍˆ»‹
×t×ùúçyžŸÌaƒïyÝèm6Hž¯ïùÚF™ÞËÌeM‘É[ÎÈ¿o<Þéq\Ôˆ‰t”$)Œ½.#n41ºZRü9ú’`(ÅñÏ?&÷}f÷a"Ö½`ùM›~d»_­ÖþÃ–Ÿö„®5ÂÍAG%‚Ò¾$Œª*îÙåƒz=g_Ÿ UÏoÎÙoM
fDoI1–ë}öÔÜjÙ~“Î¸e´ûÇ‡¬J7Í4¦ÆChÉÈø¯QÏ}ÜÕv·„DG2¿Ã
@~Ž¾ p Ìü†QVõ½=ñƒÞöVº _¦º#šgâIk0ßÓµý²q¨
jÛæ®e³0ap=0d;ZqÏÏB¹ù
Q¼ÅOÐ?S8Ð ¦~Ã¨«:C_¼Uq†žÞtþ7»CN+S%­
¶Çy¢ÞÊ¡ÁY»NWYÅÚÛ‡VSÚ§ÆSY¯Ý[ÝóÎÐC1YBdoÖý½‹Â>0ûûó…UZR¬—™Pm|QÒÔ¤hnO¡›%mÒ"RŽV^-v€=_ÎÛ‘Îj|¢‹þb
+à0­§zËidwØ?8ëŽÎeœ"}EÅÌ#ôè\Æé¢pŒxý|m•@ž
8æ(_!Ÿ:hã	¾¹€ô§‘j<•DmMJ”Ò…ø"Ñ…ét×Þ$§õa6VXôzs›ÕÙÎo0Ë¯EžA ‰"MÀÿG$òP\²n
¼TºL~¾¶Š#T“*)ê­käª£7«ÚŒye½0ó¸¦#ê©›’UhmYÊ*=LØˆÄûÃavã³ïúW#E#KD¸Dû".(äá«Úe¢ûpÇ¦„Õˆñ„ƒ(f‚Q‚`PGúOµatûL1Œ>è™ 
A1"PéKKÌÄÔ™ºVÓÙK# ã"s_³Ì'çÑgni
KÒ•Ú½¤£tAUëôçKÏÇ]ªãšÏqgž¼…uÞV™úŠ1X.K¹Es;Nãfr¾]©s*’ÙÄ*—®Mád]É>µ¼¿®UæYÛ‘Øù-3Ž>¹l•y†ßEá0 ¨xþ|e£`€–L8à× Å$÷8nÝô=Ë.Ûé.Õu gWƒJ^+m[Ûng;köÌ‡–ã+Ë„ÉX/û¡mW1’c1X‘ð„üÅ}#Æ
º(œ¡ÈA¢/…acMŽêØ„êÕM_ÔS¶–47ozJæƒÝ‘T*Í¸žeñÖx¦ÔÖ}:i,k%81d½áÆ)ìp'òáŽÑ|šM¨³–TâÞÂUQãÓÌf7…y/'‡qÚÈ ˆ
½r} üÇªGm\æYì(N›Ú¡\®(`
kÐÝ›= ,êÝuj7šk}©Zy¨Åv¥Êrm7>Èÿ2è™³¿pAQ|*]¿Ä_8 
ùí7:º.ÌF$š[e€eæoU}âîóŠû9¹øß“Ÿoƒãëúóãòî.$ÎQ¦ P,ýùºxçÖ I—ˆD¥ÊÍ»CÓ·(“;6×T·Ù‡ºÝ)b©-î¬¡:(¦†ãØ²ÛPË04/ñ±ëaELà{Íµ}VeÑÚ(”½¡‘'èŸ)èƒB±ôç‹ÎÐ· vÙ[|†Þ6ñÍxà>'M“…Õl×b=]© ]mÊ°šýÎðdè•ü¬–j6\&ahÅ@?=S2¢Påz·òôn
 ú×ïùäÞßïI2¦ï2æ->úëG%\z ŠîØ¯à£¥8J ¤+µs
¤£v¯›#óùzV;a7D%„"ïÀREZú)}lÈ]Å²$L€©ô”úT2ÃZAõ…ÕîëŽÅs‰¤£xAYúó	÷GSCŒvð15&¶7áî
Ž™,V¨¦»~¬æ¦jïêf¿ßŠdÇÊx¯h“¬ªË)K‚•žÏ4“·Ç~Êâ È©£Lyêt÷áÀ3…à€´œô÷q’œ‡G"©-M˜QpÞ}v§õÅdDË×§ÜoÆOEx£×êeˆË€G"¹é–9GƒÍ?_Æ"´br ®¦‰òƒîöt X¡¬ãÌ2g2šbê^ÚŒÌxL;”óÅt3
LU#u²øèä¦£Ë8U«ˆ0Å›ÜtwS8È 
K¡?_ÅÂ‘Gê8Ë¯…ë<KËæ×¼9À ^ ”¨wê­1|8Îídq^()•Ùa³ìLKf}?m‰jÔêE¿çûG<9 ’su;õÚv½l’SÈNfÅEá@£	£zE=©z
uór;{RíõNëðN]Ö¥C«¤V­™kØYÀ,h›NQËƒE¤b‘
MHåLí`úÕùN]Þl×£ù Üq1;aß¡HI(ä©hèiÖ2K>9î.
 véë–AXÁ8JdE	pþ`rù{¬
ð¿ÅoŽ/wññÃO–dz½–ñ7dÒ×™þÀÆ¹ÅÑQ¹ ´
#“)N:ÓÖÆÞ“NKÖÐÍ¹D±S|›Áxšô02Øu»‡än¾¨ÆŠ‡Ìá¸+Åç­Ú¸U?f!àp$ŠÀˆ)èê>?CŽ/(œLf%%…Q&æd2WÃÏ3™ªÏð3¯k8L£F¾-h‡Õ4]SÆ–*+fªù
˜ÚõÒýX,µÊÓ«1ú¼PXr‚ü²Ì®Ãçí¿/ü$h+ Ç/6Ör5¹¾­aîØ¢ž}È€ É·ÑÓ'
ry0ñS‹[Š®Q3îã ö•®dîAp_Hu1»ˆB K¯ð)ð­ ê
  ÍÊÎ·wŽ“ xãÒ3×é º6å(?êþ»éBÛcögëàWÝ:x}{¹%ØÑðÀÀf·7ÄªæË±nÂ`à·×äöX·]£)Õ"jk›èÍÓ‡zn×æK•éô*ñ–5[¯¥Ø¾xh22¾7ºÁ èç}à\G2Qüé‚B@Î‚êÊ¥0JŸT Ù*Ô®ëÊí²ð6áÍŠ­Rïo+,¦²ÖJ%bÅÊ4cî+«uŒéÖC¢g£F¦ÒVÝ{Gb‡
9†NA9åâDA2ºª6ãzp.(wQ8 ÍÂ–Â(­l	{ë¨%/¥\×œà¦”—gC­›X,•"Î¨ƒ–Ü<mG±Âº˜1Ž{Z"Çã6¿›õsÝÆ½K›Ã…\üã¸½Ô™x@17¸.!Öƒã‰¸(Èk*Ã¨‹i!Í6m5™½‚¼E¸'r¸`Ü&50Í›9kšêwÆJ-¾ÒöF¬)ÍOHfJ~ÔZ4·`Ü.Õîí[ùÑ(fU”(æöðy¾À}°ËâVL”"1†Èu»ÿ‡‰yûn
 vüÛ§I$1—›ÒHq¢ léùÄY’Kþ)@Òï$ùTY«×'Iüùáª“%Âûq	œ£JAz)Œò²Éáœ÷\9ö1çþ¾Ùd½ëÉ–V²bÊIÍÄqq4&{ÒÕætÔNf{fÄh7Û\F2§æ‡ö<ºõ˜E	b
džâðgàŸ(äƒâõRÙvŽüxÀ-¢Ú5ò¨¨«öÍÉ©¼×Ó™SoõÁqkîi¤4ËÆV»2=•8I6­Ä®³_É¢XTlEä×5 Q„ïÝŽè ©Hƒˆ9Þ¢|òM†x!p`Œ×ÿ6‡•óè"n*‰¸)WtIþíêÂŸØ'Æ†)âdúûÞŸî2ýåÀ‹.
v‰œ£MA¡x)Œ»ˆ
sc÷rEÀcSQìöŠ€µaÒm§®ÌëRyR¯
‰I·tÚÆ±^7´tWmHùd2Q€8û!>ÇS(‘ÅAxzåŸÂ•n
 ò/UùŒƒãY.X®¥°¿cy¤»òK–œ
b¿=“>s
ë›Ê’}˜t%p
¤£vÊ—T;Ù‰”B‰Â÷h—¹Ã%"nÛ±žLÓdâëË€Dþ£vÿñg£Gí\éd>ãÈa’9]Ëb
Œ‘E÷ì¶¬õ»m}¨.cz,ÒNv›ã>’M¶ÍqkD–“He”tfùÐxð±3~}â™ÃËÍ;H1{ãÃ€g
‡Qå0ÊÊxŠ-ÎøA±¡¬¿ÉT%y@KU–>æÍíj˜Œ
Æ„”—5c‹dëm“æ½‚wjGb©CH–%
ÏMá@4‡J#/ ŸÐ¢~àÛ)ê?¤â²m|þÐïÆ¥Xq/rtS¨¨í‘tìÚµñ®ºÍ¥X÷4ZU”Q½]¶üöaÛ¸tÂ]Jü4$áºmÜMâ`”*”ÃˆèOœNWUO]c/:]Þù^ìåFåp’+›ÆBd2ñV­0,­«­ƒÒë§F¤¸ QïÇv¹µ_`ÿWaÏI,Nú(T¦²ö",ã"áØ3tÖË¡Ä"öè:M{Æ~à“¦õb?˜Òý‘mY¬ŠZãfËXvÒƒÅ¡¬O
Ò²ÒŸÇ;½P®(õÆ
ƒAŒ=/œó`ï"q°:æåP¢‘{.ß^GiIÕö¯¾Ä~F;K:±G+POŒj«˜C‰ØF/'ôá±žH¦NÕý:Õ(Œ4ß%—¿{ÊÄ*?…2¤ ìÝ$öAYD9œ Š6n!ìE/Ö]ØOö­BÏW,’_/•1*”S«žR­kÓ$Z=•³ò®³ q¿Nï_†=¶‹±K
#þg¾ q°*l”Ã±/¹ic«¶êÁž›7¶w™®ûHVéŽ‹¥‚¶16ÆìXí¯•¹TtÌ!ÎÃ¥¶Ì²áŽìçíœ_ëbO˜X—K†ÔwD
ÇÞMâ`”{’Ã1-9öXõŽÇq²#÷ŒÇ©œT§æCº™7ºûƒÖ˜5¦“EqŸ©²¡”äc§9Ù¥SZ×¯cábO©˜}£(
ð5sÄ‚«
 ù Ü“Î,(Ž<·0¯³~üwzŠúwz^"_5ÚµZ>§mÁd¯MvýB#)Y»•V©´H¬§¥íAä4¶ãZ7áW1òËWÎ)ƒ¨ÄMæ#õÒ·§¬Â#‰ƒ}Ð@9œRjnÅƒ«mÆöÅdËg›±ûL¢ßœ—RƒýtuÜŽŽ³Z»ÐVèÆŽUVÙ  Lv2Xõëù‡Z9Š¸F‹ÊXT,`ï&q°JW°<+ŽŸ:nq¹¿°0¡šÎ,÷¬ne»Éªs·Í^JWì±¤–ûD_J‹ŒKÁ2.¬A¦tXÒF}”3
Ïmiø;¤Q¤ o–ž»Ò^Àƒ\Y‚;å Î¯×±êxítsWýqXÍŽ',·]ç¶eØœl:yÖP…Ê¤^jeè‚Õq·›€FòcÊ Ÿg¢Ò•#I¯÷Ô?#î¢p ò`Y^Ôrx5@üróö ñæqoƒò:;ÙT’T­ô„TÅÙ†úzmV)/êµ“ê¯î›ÿ>s×rGI”z6gÈÝrÑ±ôÛ×<><ány”` Šÿ?uMÁ
Åì…ŸB¿wMÁ§*òxKQ/C<êä’9G‚b,„XÄùÃW1¸Çlâƒs/þ(,²EV&}s)ŸØdm–K›dŽ×õM¾)p¿n®Ù±Xéd>¦ùo*ð–	Å

8Á\äA!BB@nÇH1Yó@^©”[ÏdlÕUJŠõ5Öä‰m­é!ž(õbËn—7=»€º‘HõcúõÏ;·°èÀX¾žÇ{†_P8ã¿ìZáµè¿´³VŒÿðô}×üþãñå‹µÖüçëU_wGþ¼žŸFQqF|70ÇÞÔ‰ô´SË±Å®†„ä§'ó,J¦Ûùo·Öq{IçG›žøßõ¬¹-Ÿ¸¦þû{»éâiyòyÛØOB³ùëç.‚Ï	™G´]ââˆ6ñmr…oÆÚlëkxÉ;K6ÁQ$â¿£ô'$R1É"©ÁðÓÂK_6ÅÆºçË¦3$[»2oséÓ¿÷÷ëO†—P?KŠ#ÔÔ_¨ñ¸±µñ‚‹ß[¨ùÕÂ
S¨ÆQˆœ–åÜŽÎ­È$ÜKìºVu9´Ö–/¯ÎÈtð›yõíß?ÿ;Êö'†ÍOÄŸäÆqÉ_Äå+Œ+Ör±qµ-®–ßYÎ)ŒJ\%‘oAÕOË¹8øa¤ÈÃàÃhmG{^¹éÈof˜ß¿CbÄ¯‘øO	 Ø?‹‘#ö²¿Ø3ÚæbfÍ{†É?îÅÌzBœ½·è“¨Ä½ ä»¿9Ñ§R Æ€È9ëz[µÎÁ ö]@Ô¹µ‘þ6
{Ö·k¼ÿþÿÍ]o‚0†ïý-ÓP
-\N$
Z'Í“-~¡‚82?’ý÷Ùªs…MCÔû†‹çô…ðž7çäXœ«Éáþ¡òäq¼jL
_¬×“,Áq
mœÒgc¶þ¯
öË³ûxBê—T(ý&é¿%¢”dE”KöNgUSÄô:l_ˆ@ÆçÜÝ=œÿ ö§„‹K˜€ü‘W52ÅVŒsÓÌ÷K‘'€ãEbHí¨äaæXeu2ù`ŽYœ¹È	s»VÏ
¼bV pBâ§q¡È¨…8~¬‹ã7U#s]ã…¢®fŽA¶ã À7Ç’'(r1-
¨ä
Ù#_ÛœFmC·×™Zß.š¶0£¡Ûï5ƒîÔÔZk³¡MkæùŽ×î
¾Õýò­–UúWæ;À0y€OõÜsH„ì¾üšm ›®,í€¸V˜Ó±§W»²`Ôpæ‘ãÊÒD«‡Dï6#r¾€«4P©ÒÝÙÜF-üq‚!OõÜs‚´7¶îŠ»û|‚Ü¢³ö¤ÌÞxq·F î4k!ñ‚%Ü:
™2Ÿ©‚
ÂÅv¸z—zçEÀ9
99¦ Q ’ŒUõ·ç®ÐüGòDá¹T(>î|õÀ         
  xœ­–QnÛ0D¿åSä	DJ²å"'@°äZ!@‘
¹têÛ—
éº*Ðþ¬ 	ÆÃìÎŽ4¬‘z6N,2È‚°&bóæŸ4DÌ‚Æ»Ë¿Þòþ™ñçvxâík;¼vÃË8°¶›÷·ß¿¯P‘Hê*I*©a¾‰äU\ßÀUZ±¯ F?A%-4 4–™´(XòìÇÂŠŸVÀF`Êæ@ ‚OM€Å‹ˆ!)o59da	åfÁDæykÞ Y[Ï)ŸÑB4xJ ÏX+£,Yå=>
ã5•Ö=hÑ;1
d…}eÎ2ÌE”˜¨÷Î†R*íØD˜’˜Á%<5ØìT®Qºø•/<*I÷y,Hm²Æ˜äþ•˜rÚûœoË:­ŸÕÎŠÎÏw˜›ß³ëÀ]8EòÛ÷ÔzŠûê¶p*®Æf Ò©ÐëDÎ
i¦¢Î›$ïðYéÚmî¾­ÑL3ý#Ø±?ìuÍÅ(ù
"rùVó^Yìºfö^ç
B„²
2³V6ò’ÇÏ
uú@2t¨B%ÂäÃUõX€«ñNªL¨KÈO zêK¤[[›ò÷nEV;µ6WKK†ÿÑ©Ä4ƒX…Ï9k7Ôp¥ø¶l?`&»Ö³êÚ’Å¯3dPnØFR¹|“*­ûï‚‰ô÷—Ãáð
KÒÿ      K   
   xœ‹Ñãââ Å ©      G   
   xœ‹Ñãââ Å ©      E   
   xœ‹Ñãââ Å ©      M   
   xœ‹Ñãââ Å ©      I   
   xœ‹Ñãââ Å ©      C   
   xœ‹Ñãââ Å ©      Y   
   xœ‹Ñãââ Å ©            xœÜë’¢J³÷?¯¹Šç4¨#Å|ED@Åx#Å3žÈÕ¿U8k?3ârÙô—{­é˜ˆ®žžùuVeý3++
üþšÞÍÅ¸-¥i©ì¥q2¶UjÄû~·b*eþEû°ï.•Ž¬•!YU5µýùÉØt±øBËîÖÊ½Y¾œÊm9éÛëhCã^ ¾ñbP ûñ’£®MÉÆ¸õjƒÒy×ªD(–ZÍQ¨]$ª£ž7ïíoµ˜§¿€,—!Âe þ;ý
@¹,ñÿÁ_P‚¸$É%$ý ¢ŸþÄ¸¡"ËÊ_ÿÏþ‹R9Uñ¡>Sa+µ°õŽjCÈÐ%“Ö°³Xáé¨äÜ÷þÐ=žèï/SXÅj4ð'Tà?þ„€ÿ*‚
}JMå½¡J¬S²EÒr%ÏÜQk4tu§©Ëms:
½Íue-”¤¡LÚ' ~‰
–±¬H
*ü=*ã5Õò
•BFûžÕt>ÑöÓ†»·¸‚×¸×zÕµ²·jvìßÃRW›‘JQª0AEþÏP¡2ÆH¦HPÑïQ¹/©ìwëjlÛU·ÓÓíîê´.-lLw°ìH Q¯7ý€®Èb6ª¥!a_¢Âe…JdëJþ?CEË’Dù@ö-*?|EEìw3°:_G¥j­Ô9¬ZÝZ`­ŽõYKÕš|‘Žj»JNé¾}'û¶÷‘gÿ›
ÉeÊ×••ò=ªÜ~•Q½Ý¯úÐ×Ók`$—Ö¹fÄ‰äUjË[_&£ÝÙ¥·`¿Ÿ•ê“E n_¢RÊ!Œ2* }+~õÎµËWDZi#m™† •žt­™v²SoÍÎ]”®	3¿h,áˆ ‘3wÁ—×ÿ,Ê€QYzXë;òXUëN÷7XwsÖZ…3å^]Ÿ©ÝˆÔáþÞ±¾ãO")Ð¥µî˜‘µS¢/a¡²"I²B2¬ïè
ŽõjÏâXï<ÆY3»l0¬!ã¢Î’¡
ïËï–»ØÔ
9^i»Ö¼¯í[	‹òµ%ÉÍ°¾#0€å¿´VòÖZÃÀÔÛu¬U¥;
'¥SŠª®éØÓ¡gi½øÜíÎYÅ¢nõKbà2ß±ôÀúŽÂàX¯v-7y»kÍ»4Þ¤çî}Y
Ž­«£_°5Ñ®çévßT@í´´QÍšìKž2†—ñ‰Á±‚×Xï\ÆæÒ¸%ýr[íl­_s4Ÿ^P8º%•)A©å^äÅ¨•_Ãâ›1„”»Œß‡ÐO€3CÊŒRö|C{èÕä´WáûÉIn÷‘q[WzK_ZÜJärvxz÷éøºê[—lÉ¼Ou"g"«0¡¿\É7Ä‡ÀŠ^bÙï°æ«ë1Ú4ZÍÁ2¾ßÃÝU4o|ì æÂofSm½H'ãRë4úÔŠ,VÆDàõ
õñ¿‹ Šq%ü†úXùmZ`½Ý¦'|K•5¶z À¨Fëp2rå9:Cg>´sLVS÷+XË2ÉB0ø
õÁ±Vù, Çº¿ÍÜ§ÝÑUZÇu<qúÃÁüÖ;Èrãk›ÊäèÕ¦áÙ’õÐ¿}êøÿÆR0Vœa}C}ü/ÃeRˆ3Q¿¡>V^Ù
¬·ÊÞŸ^w
MÒOƒÅ
Ï»U80`Enâ¾qxŽz=_M¶Äú÷±2¢äa­‚êÃ‚VÕ%öêIT¥áÍöçð­¨šîNÑeÌPg9ÝÇöfuW‚ûì¶ŸŒép×ë˜;wmèJÍGªúP`PVœå¯ÖhÞíÍÊ/$VHìe’"Rß¡•,a
*
edúäÓ(µ«sôÖ
¢-:Žœ F•eoß^ÝÞt{9êÍ 5;Ó³³Ã‡wHl
ì¥ß‘À/¤ÿ‘ÿp¢d1%d¿f^AÉÁµm•Ï0ÿÏ¼š]Uovª“·yµCßµüÅu;ú`4PvMµ{4†M¯Õ^[™¡°ç9ºÉ€R:ý•”þ‹ÿ_NþJþKÂþÐOÄÄ¾Ë<‘.¯ œàzv¥N5zBÑï\Uá·¦Y[³pâ&Ñ©¾íÎ†Æ±>lV¶§“µ<§+
ýCõdôNí(úÓ4ë'Ó(Ùò¡?ùÂRˆŒ¥G"· pïV5N¹ž€Œ„Ç)è­mÈ¸{»Ã`sÜ©†v¿žZÓ¶FŽß;ÈäbÚ€E ká«ôJÙâ?	wsQöð %„
ù ²ŸÜœÍ' í‡ð­›£LmxŠ×˜àÊ.ºMˆìI¡ªÇº›Î›éeß«¥@v ãòO“
’ÿ ù'¤?%V–,=²ÑUƒ 	 ÿÈ“p³½UêÆéâ^.ÇPÖB­;ïu¢»7®
§[<n¥ÛÀÇ§Mm2ä{,íÞ’ðeƒI™(²$gËT
ÜA§sÉÎy€s£€·³lÞé/¶Q2©¤·ðštÙ$2š 
Üö‚æÔ¾oæ,…W÷ý,Sþ”ŸXúIø QÐc–¡‚A Åwë)ù—qñ6ù×
Ûl ·J»·ÁlYšnKµµ\ÁmÒ?÷•¦½<ö‚Ši;üá¾”%‡cCÕKœªŽŸã$äðýmœ¤Ó´zl”à¤»&¥µäÌ|¸¹°voj+û1 šï±Å•Ü›•÷ŽAé'¢œ©Œ ø{ÊÔÁk‚Ôª>­_…ŽÏÇÞM¹Fz—Ó>Ö¤ù²ÏFp¶§t»§K©J£ÞT>¯Ž3 Æï§’þØOÂD)€ï>PAU €Bü|æÆßIßŸ¹Ñ‰äDÜ
læ§IeßÝ®ÖKÙlùêT›kj·‡préXi}pþ
ˆ[ˆÇåX*#	+ìáß
ÊÝr{iô/{©qÃ›‹,Uc"iÃ¡aA7²â°:5ÝÛe8Ów™©Û©eoŸ ±Ÿ’\&I,Ó9¨ 8„žÁÏ©$ÖÐÛ)Waƒnh×íÁÚTc[ßHteï²Þ¶lã™–y`H
Çî©ð¼Tæ3
 TœhÖ‹Ýéü ÈÖ)3*É4£¨ @P\<ï§”õ>lØh[¦NFÚrØ½2Ø8`8×`î#²I·Š\ªš8
¢¡0;+Â\#àç!*buY"[„
n¹6„üã[)WÞïÜz"G
]n/¤»F"Ý^Ë²<;UQ5¡š+£†V©Lg6Œù¿NI.…d‘cP˜%1QA5”ÛÏ­1·kL©J¢íyìg-/0±À),­¼¾L T©zèÚõÕ¹Úó3ëq(Â¹ÊPýÓzH¨?ÌÕ D¡?pÁMYÀ
¸<¬]ußÃV® ªL¯C™ŽÎÚq½Ýíë¦m%^)l:U¶Ô×’mÕî‰±¾}Ë‰d;AB0Ì`Z&ŒAÆgjÁýúÁú|N÷‹õý997îF'L}Ôó·ãÒzÐ> mv½Fú°±›·fV’šçµÜi}fXNÄÄÚC
Â å‡¸aÆ°,ÿÀåc6‹¹â²^Àòñw†íuÈ¶IZ—R};+iŽº¶ÆGS:Þ›Ò>IäaÍºû)Ô6#ƒ}

…@¡`ôËƒ2¾je€)Â?pñ}>¸Œ|1‹¹xy;‹}zí±u–Ûýõx²¡+ÃÉ±{¬Œý¸
Z#Ú‚öuÒü–Ç X.SIÁÒó’åC|5c†àK¶¸Jã°VšÛ2lúvËì˜»ŠI÷p2¹˜fW«î£9+£?Å1ß_ý‰eÞ+}©­}2`LVr°\"pŸÍÄ‰í\Xðp
¬§:ËEÐíí‰’ç#¥«Ž;tØ#²uœ,kûA‹Î—WÍê8lµÚ5ï÷‹¼ÑÿüGÊDÿ"Œ°ô»e³!¾•"P¦2€;¨ÂbÈ©Z÷çÃNKøàýaçšµÐîf’º²/	qj«
·i¶ŽÍÞÄ:ž‹&¸§FTùÀÿM„!'bBƒÿ>~(2C²DdðÕH‰åÄZ=Ëóë÷·²a·v÷ÐÙö´xÝš.*Ìèzov&Óî“á®ÚÇ‘FÌÞeg|Äªÿ$Ñ²"b\ùiˆ‡ór$ËþÀE%‡ÒüÎÃA«ÁûÇì·öêAMKF3i4÷ÕÒkõŽîë·y|?}7š8ŽWfÉýHÂã"¾óH ÂL$/%å )ª ¹ðµ$k?³¦YFó{J[×PÛ­ ZÒŽF›ÑH‡&Ýv‡
f¸è¼­½}cVß×/ÖG¬@hB‰Çr€
zúÇwOÜ¶üÏÊ
Äà )ºËr9¡+}^±†HE§oWìb{ZF
#t MÝYóØÛz 2)™›`Üv*­àx‹[ŽZíéá_€ï<æâ€@þ‹{\
8;áó–R’ 0!×Œ –±Ä%=x""ïA‘èRT/
`l>ÏdKï5TÌ‚óè°iZúýT;-ÒÙvÇm>9ŸaË[~i|4üÃÔž¬û—ˆË'3Ípa¡”ÄüÓ?HÑ½–ãZ|¿}Þ~¬›Hõ¾Ý~–»‰žœÛ÷^£J!<´o‘iG»ª=³Ö÷ñi^’w67qãÕOqÁO	ÿD¸L¨DzâÖ•¸c2âó¹¨¼‰Ë 	^Kz«-ZÈ­Dwÿ€7×Þ€Üô+¼Ý®®`yk'whTäV ‚Q¿	æ~£Á¤Ìg1"Y~ÕèþÚ€î{¥]i>Ÿvâó~´´Ø’úô&_cªÌWsóvŽ,ï‚ææ±ß(-s‘ûÖ„²(Ñ B	<)"ŸÀ
Ÿ²E÷Nìruô¼B9ñŠ«¦wÄ7·±/m!ëÂ]2£¶ÝMéÜÿÜ^7¸N®)lW.Æÿ›ÿý›a±<% fÏCŠPL
bŠÌ~¢!‡5àsI³pG|³}_Ò¯Cãùy¼Û¤·ñ]öø·¼„ºwíÅ„›žÄaï¸Ù¶ûn=úŠÿ%™êEPÊ³y1e¦`Â=-º½Š Vl±9óòûÛ¸Î_ÃIi`¥îÝ„‹}
:£NG#$m¦Õ(hÖCÖžŽ¬ú\ÿœþ„L”úa KOÄ([Å×Èø )ªŠÅæâé9¸K8 oƒ»e«å57zÃIH»Q©{¸L}­:MÚÝ¤¿hTWÃvŒ‡F{‡¹CøwKXaã_­°'b,
U)£
þA‹n²\*Y©]}ÖÆVÂ‰¥·Ú¸>Ð'aû|"—…6sçQ´UÚÉµ´¾2·†HÑ\¿K·F•þ›\ü›ˆ‘záNMn9X¢¥ŒeDÈR4Ö•ø*~aÝ¼]ÁCknZ³3¶­Cç»÷ö~:ï3M?mÀjg[S´Cç
¯8há›`Y‘!\ÿ"âäˆOu¡‚ÐZÔg¥–¯æöÄ¾›þËÁž¡Ðæl‰ÄKGÑz[w¼m«k%fïÚãz¤F¶º…JÁoêçÄ
sè2â®ø

CâP6
 S÷YEU'æò?ï³§    ¼÷YÓA0Þ±1ì&ƒ1k¦Lmæúm·?
S¯ÔÄ—ôˆ{\UJúçÄ7¤dð( Eõ?_©Î§OÅJUß§O×ý{Ô.á­·Ýãt¯÷U×NÍy2Ô!÷Wîd§Ô4lÏ‚Ï}ÓÃñWTÔà?†d¶‹âPðME"·eÀgêsxÇ÷ž•…Þ†wšÒ¬('o²ov2©O {©]wýfEZKÃfÃÙœökêä/|ý#ñKTEI e§Ÿ´¨'34Í§šÄç‚÷©¦JÝÒwg=Ì·ñxçÚju=fñH™Oæç^uª{uÒ^G ªó£¢$¹!×¿<.yíw±­rç,ó­dg ´¨æ
a>÷À
–Îßçæ“Ró<œ]‚æb¡GScŽ;YJ›šÓ¶û{¹{Îv8Ý9Áç‚!« ¬¬…Ð?äA›$¶O®Œe…;Ø¢‚Ò€ÜÉæˆ3éôŽV·v¼®\æ–¶]š¾0|ˆ@ä-ö‹qí¸^ÈýNZ½¥	{Þ>ÿ‘WÉRÜüKE¹6~6²"vPˆ%€å´¨âÏ&n®é1qß×#MÂÑ	.¨Ñªßoéàx<¶ï«&§õýÔ³';©Y]D&(}¤fP\ÙóÌõÑÓiá²¤0…‚rQ	œf%Œy§Ëyçï+žÙhÓæÚŠ6Ð²Ÿj¡Õc¦«uôtQÖh5©v_Vèå~;}ÎË¡,Ê°$ú<„ÅGR™böC.. W®dåNX-±²Ó·r0î¶'}Z%5ï’Dt+hÑkÖji÷8éøv€'·m'3ï6ÿH*bD€AFŸ†H–œ™¢Èô‡\|GÕ@«œä°ÖûÚTÖ¼˜	^Ïú«#€zóÜÜ(ëÃ®‡ž9‚+¹±¼èU0ìË•è7¦Â<Wzäq1ip(C™²g^9»^‚$(árq5¸ûiÎ=§Ù~úÎY•Tv¾®a¦ý»ß¼¯¬NgÉPvéÖOÓh½bÚI×Sø9¯¨_åVdôä›Åy3wÛ|íŽ[\
ò|EŽÀ
ÞWäœ£vÃˆ|érR&ñáÐ!‰ùšo«´=šøôbö%ÿ²Œ.ìC\ÅƒTQÜÆwäç"¢ub¡–Xqµ´Š‘ý\óÆqíUÞ.]Å™ƒhÚ]ãmçp5oF½7VË9Ò¶ÞQÏ²½®žYÖ×á'KWÄjDµB‚‰"?
‰6 ü§Å#x@°âJ#U¹ªÈïCvê¦o÷¡*bØÂÖe)kz³¨’2»ZÅØ6kÝªÜš°uêîc-lýÛÁäoDð(NR xâKšïÇ`L¹Ÿú†eE¥é«‰½¿ñpmnÛ‹1ÝZ›Eï\Rå[£µÁ£“¥”zgù¬LÛ×i£fmÇÛÓ&rv“ƒ ˆ1|-_ÒrOõC.n\ÁûÒOEé[?5<-A§²j(®×owÚ9Œ­à°ôû+¥uPØª^ÕJÍ]2yNü¿6n‹2WDdú+v”)•dÂa¿¡ bå“|†ëÉÛMÈíÌˆ)µ×í=t.Ò<5šÛá> è²©<þW ÞÚ]_Og‘ÿÔ¸â$
–&òŸ
fç="=ƒ¨‚¸Wþ†‚“OûsÞ¿¯Â+¥lw–ƒh³©kuŸVcÖÞ¬Øz&9—Ã®QÕ1š¸©~nâÏyEÉ)3‰)ìyBcÊ¨°o(È>ßS}ðÎßßSmúñeÜ¯¶ÌNts§ãþþ´ ýÉý¨±vô}ß_¯—÷-
—³çªÃ÷¼\9!…1@žyEm<÷c” ðƒ}CdD/ç³íÿË|NïlÇm)š]À­½n]êF›°*³˜í»ýú©©Ü:ö¨±ûÜ¾˜ˆCJ ÊªaÙ7ÄÄ<_å`Eï¯òwGÍj`/®u¾C®+úu×:0qµ2HôX+1k|ƒ—üÕÇ7`„Š}`äg¹ö
IÏ-2²jø¾’æ„}}1ôÖÝ›¤"ËMœY@û³©t‹ØªY¥ðbºGzí~â<f!w¸<Š‘$’WbîR	å +îpS=}n"x‘ã7A'êÎ˜žJzóhÙ–ŸLóÝhk¤zˆjç¡_jš<ºë;íñ‡Òá´!þ·ä†°Ø]˜Ì…ÅM©žëið€Þ—ù¬PÓ<õŒy­…CQ Z¤ž=uº3wnphÞ:Û&ÞkûFýù„î
Äj”DÓ$îaØÓyÔ­cYðÊßH¬…’ý*±–òÏ¿›Ì°1ÛœÉEknÏ§%Ûè8:ydÔ¡{Q'ê{•s<¨’¥›K¬½ó·RÖÒ
c‘&~"–ÅÁ3FðÙü€=‚/…puþ^k¨×jS)˜V*ð¼†åÜ{xŒG%ÇV4‰î“ÆpyÞÎžJéŸSn‚V)I`þ)  r„õyÔN ü¡ßPS#}¾­Mi?x[{tòCtJ‡½
öÑˆÎØæD.`|hØÁ>Át²¬Ž²Ñ;lýàsqË=1T ’É311BP.!ŠK&QãŸ»¸ ˆ­÷¡híf®îw¦×DiÜ¡l±'«Ò9	9„×Ù¤z«ØÛ/,bBD!&“ ð‰WìK|¦0‰(ä‡R|GJ
bçwÉªêÒÛx'ªTQÏÉŠû¶õ.>ßÔŽÖØÞ¥Íè0¨€ñèTÑTólY‡þÜÂÙÕaþÃ‘0÷Æè™8»ÿÍÕ‚Ê¥ø*N-òbKÙiÖ;
Ûl0eÎºylŽØÎ7FÖl-+Kóhß–ºÜj°îƒ%õM3þ
±(àõ!2b¹¡LxP(b—‰¢©Nþd’ó¹þ¶5ÒôÌ:ÇQ$ŸÎnm­ñÈ¬_výÒnï}æEÉ¶{îâ•õ%b*¢xˆyÿì· ò¸,À'<ø¡W)WH¹ûT‚ØzŸj2Ú
S²8ÀÖ
öÍnE[ Ç“jt¸8ùØÙõLKu•U–}ûœX¤X¹Ô¤2xö[HÜƒ(c¢dë¸xÞ"uÓš™ ï5sì¥ûéùêqéÑ<56÷óÍ¶—K|hùIGóA)õÒ>ÒÚGéöbq&À=5à‘Cnˆdå›ˆò_?”o¤¥Ü\÷ž qôÞS‡÷e{F®%ƒ\e('IZ¦ÖÝ¼^Ããt™4vÝ`(/Çétñ5âÌW&K„=É?*óè2Nü
5írýñÊÆóô­Ù¤5ÒN«É¥~×miíOBFm 
œšÉ\ßª‹Km÷%bYØ0"Ñg_M€pjÊè•oHêà•¤–¸{/©[·–Z]£ÏvúèŒQ}¥ø—µ›J	<¤£ÓÔ_luŒàK»yÆ²ÂãE’b"…A·1'þ†þÈ‹š
‰ïXïk*ªÁæZ)ÍÕ)Uý@êÖ¶Õ¬MOØ@s·¿
6F‰\c_Ú{Ç ÿ›DŠ]dž.Æ ùÁ%kqäð–kS!ïÛt[³þhX	Ú4ž/öuu4çž^¥¥ö¾´\\vI­I xñ¿G L;3qFðè³XTZeýŽó¦tovú/å1^}ƒåÍÎÒôClôñt¾¨I
$¥Û[{ék¨Bvjhm¼Ë•Ç¼‘¨!\Zq;ÊˆBöà** „4Lóµ·îMtÕy÷µ¯â*ÊvbêWd´]-IèØz?ZW• ”J×©u³þÁá E â*Gv¥œ!ö4² !ª(bvO‚–Ø¹{œÖ×á[§;íáNg '°ï$ÐÝªµVh{feêéR»Í^8l¼û E{$q
_fˆÊ2Ì!q$Mù$ü-
kˆŠÓ°ÈOYƒ^øgqG-–Œ­Tîi(­ã3\öë*–öÛUØ?á%•úBOç‹öÕcƒætw2‹0 •)PÏC@LiŠø†‹9tQ!Á¡Ã›UÍY8áþçöÖÂ­’¬ÝJ
m3rœ¥;`Ý}MCvÃ]¨—xgÜ'Žæœ¥¤…QÝø½8¢\u<ý¸,Æ
}$qŸ2[¢E•Gšs„<ÿ o‘Ìƒ»°öVWóäGQ¥¢^–;“ù¼J/êµ-ÍO©Ì´Oë×8–°P
(XþÕ½¶¨ÐåhÌÐ‰vDó÷ tÛ†1+µt<Ú›µm¤Gž¹Í*»úi_ß°}GÓ†ªÓü¸òÿa5‘x*cÄ­–£fâ€GVÆbUUA9–^¬ÊÄ^…/Våïy'íØ°³–S–”¼ÝF^Í¯°Õ­/ÔÖÔr:Õæšn£52óíÊÞXb!g N®M{‹îý+’ò'T.´«áûª ˜ùÝCk6(Y-ëD…kx3‡ýÖ4’˜kW6×ú•´¶“>¬bÃÿõ£X$
!àÑŒ
mH,Ð^4úhÿÖè'lÕI+qŒ>ÆÛÙeã'ÚÝœÉæTU¥5m:íU#ªÕÌç›ÿ¦db
”%DþÈ>†²¤Æ2 .¬
¸ÃIó:Ž¯‚÷:î®¸m7Ü·a£nÜq{½‡Sgî,{áy9ôuµ’§©}îÙ‹]#CÊŠËˆ0qÑèiHñ¶Ä?'v¢Œ9íJ}qÖÈiÿí¬qèT»r²
Ôf½²¿¬ûaÓŸÝ÷þº¨þ9‚¥©žæ›aÅ>} ‚2$Ñá—­‚~Y%`eÆµ8-7}QZãEêÛ¨/’fBX7Ë]zB"„Á\nŽ
½ÕJæê^¢~XmÕæf¯5kLè¦ÖSÝ‘–\Íá‰„ÿvmûo2%¿!æZHÉ‰V
b’01ù
‡vr†šä“è
£rÇa;µ€€–;Ç‘ÜNµ!›èÃ¥QŸŒþ½éúòPŸ;»’Ú
ÖÎÀ
¯áþ5ô â²'2¦ÊÃ=V=å¯X	¸øý«Ã†ô'Eë:™¢uç<ë.ËþÝIûŽÛ¼¥ÊYž‡‹õ®­~lJ”Uq—+åL‰Å™²Äq!ä´rñùk½¸^å"«úêzU~þ¦ÛíÎž{øºÕ<Ú0“¶<n^W íÔ<´ºvZNŽt¨WW‹¾è„Å·>5¹OýG²¾â¶’ÄOCMÁÃT">‹ó»ÂÔ\+=§A5—‡P—02ajI€iiå`¨}k[VËêj„à8‰`uÈöàö)5”…û¥
f<:ã×+Ñ4ç‘åëïãÐíyu¢³­0‰:—è2Öº›tVÕª¾¯¶»óæ$è'Ó}÷ùpù
zÜÃ0ù½4-ÂRö*Îˆ0§ò
s’\Ä ð‹.ˆys^õž†Zï&Ñ¡Ñï\<í(÷¥Û>ìÆ—xt[M”Žy^o0ÿÔœœš‹*IF’ò<‰1ø	ù0Ô§vs‹<¨Ã5yêx¨§«9]*é3 ÐÕz§Ÿ•!¯:Ì;Ÿï­™.«c9þ”‹®beÀ0’*Q˜¼8]    ¾_FF÷¢_FžŽ\—fkjÏ°u»këº+—êûq/Rns¿7LF½N‡‚ðÐ›¬žkÁßñ‰‹öe,‹ž6yt¤ò8È„sC>‰ì}.B-ÏßŸ,W‡Ú¥çi`ynœÂÝñ02Wh¹PÖv8„Û…Ö_œ;í)‹‚Ög
 þ¦"<ôæÎH~VPDü8ÊÜIC*€¿¡ ‚Û‹p@ô£~¼0ôè0ƒö©4“[Ýþš°:1ÓåÆ–<tµzížŠ±¿©´í³óå¿áxTÀ  ìÙi‘¬»ƒ
|ç—&
s'ùÊpÁýê}´<w¥ncó“®†¼ž4Ø©¥“î5kóòf !ÉxzR
HýÍg¥y¸¬@ó­5·÷ŠÛ ¢w5’DVÒop§V®ÔËÍz©ä£¡<w/p‘‹°>æa§bme¥ëõâ?Zîë^©y²Û`Ò3>u[$ëâ/C‚”çeM²#Y‰RÈxyŒ\˜Z²ÒWÖÓWÖ¶S.™ýàn§Q&™5ý8èÃàäš¶êð´±]¨lã¾\W×Çº×£}ß|L-ó€@TÁ‹Ž×¹!þ§å?AÍŠ 
âãÕÚá‹µ
´‰=ó®‹Ûzf‡aoÎfÇÁXŠíeÌVHG{¹Òi—V«ù¹­eA
åßï;ã¿›Hâá9‰ê¢GU’ê"•£vª|[Ü Ì@O”QÔíU¶K¶¸Ê[RJ›[e¤Õ‡—ÞÑr6R$žOyÊÝ¼Ž!`öž£ë}²2Ì:‹†˜Œ‰-«hçfÁk¼œÛ\œ¼˜Û¿ÈÈº’2wA@\WWËÛûàä­
¢Íì«½o'£D‡|S âåPD*#Yy¼\ŠöoÎ°à+Â£Ü÷»öµ?wìzëè!Ý]á¸²À*
•êÙ³â`³CjÕŒÀøKÎzvQ*²©Wñð Õó­ö³éé¾oµoê©åF|iv:žt9žƒ*PKÀ\ÚŽ©í¯Sç"™ž²”Ø§d3‹l°$)”ü¹×¢¬\.ËD’°Â‘‹–½pd¡1rãýUçv÷xä.hrN¦ÓÅÒ¶mÏhwZ
wä
ã)O=2T;°¹Ù}Žœq!\ÆT” fÆ,.SëEA'«þKAO§6´l5AÇù¡*‡±¦¯ÙxÓ
ŽtôŒ^›u_ž‘ÛôÏ¿ž¤\:dOP†€Ÿ†HöP$aH”ó>å°E
mþL
‹ÚÚ·òKòY¾ò¿z¦{V}[™¶"î [ÖŠµë_ƒÝ¢‡
(íNòb‘;æš_œpüzÔ¨p£kÁõ¢¼ÁíKßŸ‰“ÅpzÙ
šƒ3ß¥¤2½Æäè1Ï½Š¤ê³Àªöê´jRÕý|†â_-#¸—¡žä pËkñ\î-ße]4m2ÞwYŸG7m:9ŽƒÓ,hÔ¯·*\ŒOr¯á\¿Õ ÕH½rY6gèÓíd=ÿ8.%?Ê
w½–²–Ýyq#ºÐ¾7¿/½h¤måša¡õn°XT®“ÃÌ¨u‘WÙ6-bß@³ÖWäšü¹É¸¬QD6RIúÛd…Œ“Ýb|6Y ÌˆÞšLolZõàzW®ëú
ï»	I/H¿N
wS;“êÕÚ‘Zz¹~Üæ‹³Dq‡‘ó1ù±Ð
·ï“ÔÎå®9Z€÷/f\µØo­âRíÂ6Ë£«]šÉœiÉÝéèƒRB6¥eØèôKñé¿r)××ÿt5g—éEy\™R…Ð?<æãÞ¦è	 ¾3rà¢‰ÑM6É÷+=:­ýÊóñÖzE°M†íqk(ÕÆú©í£À«)<6PcÈŒ»PÍ›Éµ>ÿû×¥TZFÜüàU*Šç¨HanéŒ»hzŒsG/
?ƒ$ëAúA^ÁkâZtÑú ×J«s·
KQcÁÕýª¯Nw:ˆƒT]Þ¦Š’~jï œ(\æ‚›å†á XÜEàæjüYn>ñß6ÂÆc©"
Î[>DÈ €î¡Ì®Só®&r›ãÚëê¡þ`NÅ—9 Œ‚ç!–u°—Å.š>¸ÀÎ×\þcø`z+ÍZo+ûÚ°WÚuöŽã¶kÆÜÚû‹ö¶´íu*ÄY¯­ð
ÔJvpÃ0þ…à¢i¢ _®Æ!ãû‡Ê£?ù¦iÓÆQM^¶e·¾m×Â¥O¯pÓhÑÕâØ^ÎÃ‹j±†ù¥i¬ˆB (î_</_,‰ss‡&¦qQA$¸aî±™Œ{þþ±wqiÒ¥$-=Ü^wj²'ãŠi˜ý¸ÃŠÛö§«ÕÆ=¢©È|
Œ¥XÆ=Ocœµ…ã›Cœ·èA\Æëäzàe¼ø7-wn®Gö%GoMºájŒ£Ö\·µ­zTéqÐ0ˆsIVc0Z_ÀÎBg2åÁÙóPÖy1J2î¢*Jp£|í¶àŽß×n‡=¦µìœ¤³©ß–¯vÐ{çj»¶ÙGÞt6—Õ­aTZSRû‚»TÜ˜
†07±³[øˆRBpQm%€I¾å, öõ÷-g'µ$ÓüŒÒhQ=JÚ°©5ÐVés}Q‘&É8œ*;tð€³Î³ËÀ§!‘IeÌDášHÅ'öœGl/²JŸ8°Åý~>ßú-©znžèÝf½V{¹õ€9ltñÙóïÝu¯BšaGûÂÄ&X”H*\ýò<DÅmIÆˆ"Î˜É7t×æï 
îù‹;èyn¿FŽim¸«3óÖÀ©àRjëý:
¯iÃÒÆáÎoÝÙ2ú7Ír-2‘1~’³Í£wYpÃ‚™nÁ-În^pÇ÷WÜÏ™î~ó>íùSšÝ…Žd_Û5äÍ°‘ýÚhz™8|s.Ñ™únC”‰$‹W•ÊªÚEË„Ê±¿!»æØyµ_­Tòþ=úá¤½O-¯1ƒód³0¦Öº*Co–ŒÏ _Ÿ¬Ýý…Ì‚J²û”7ƒBH”Ì‚_%³…[‚s°ø–¯•`Æ‹Z‰ßÓ «áø˜¬ik©% »ïÇƒÈk:ô>l&©7Õ“™è>YIið0Ñó‘
Sø<DÄÂÝÂ%Â¿¡¸âäE„È­b~áF½F­u[õ’Æ:ýíÌñÁu¯G>Þ,:<¢h5çËõ>™Å DDÀbIBÏC,›À 0I8êo(®8}©¸Ä# ï]ï\ë•Á¼sÑ–‹“Lg2­šÜTFloýðêwß¨÷g‹wâŒŠÏ`¢ÀœE‰\fÁlÅÍK	^)Ÿr¼áû”[jïÖ—auSó7ƒ¹Ñjþ8­™ºn\‡~m9Y/5‚”Qmtþ8dÈ¨ *3î¡ü<„³û½2"€‹V=	`˜¯CÀóu¨ù‰Ý¬/d5WõëxÐÛXÞÒõWsšèÒm«ÇÁp¾«§a<š;¢QÍÇÜX„û\=“ü¡d<zûŠ+FùŠTÁ¿¯H­ Oì ,gÇ
r·Ç Ù´ë
?>v•}ª+>¾
¦…ëëí
ÀD<'¸ôÀÏ#T,dC¹Â,Ü2=ãÍ·˜Îxß·˜®ëÞW¦]Ø¨¡£œ(ÑB]P»¦…«à^³N|ám:*Ù+ÌŒ*k0­(¹¡,°*L±ˆ!
w%V–‰};¥ÿràÚtµÔ3'âVKW™ã^
îÇÇiµ¤ìzé.‘ÐR¬;|¬-Ñ¯U²x”äÙÂPÎÞ$á#b%n˜²–Ú¯4V¾o9ØKnªUFõ`ÙðS ­c÷1g«+ßîo†Õ}=Ü êÇÁqFÅÅàÒÓç!ñ nQHÃ‹«+_/£cÑ°ëð¶Ú<¯„ç€i{%Ní°ž‚(rÆã´7›îjëàö'õÓ*ZÆ1ò¼£ÌóµÍ6 .®º|æ_ÊZg¾Uhî§´MÝž*ýívI îh¹¢3MYÙ³¹!¶ékÝcó+êCP)eDˆÂž7'”µÛ£€ËgüÁ¢ÀÐñõ›]}>M	‰S5¤·§)ðLÃ°>Þè
ýÁ„'Ùcá€d¸~
ëÃºš÷±svÿ
ÿXo~‰ƒgPÆŠ¸"ô3.ÚH0Lx`pËMÝ•Î%¦ñ~êêæeD•¤6ë^Šo^h´’R³ÑMûAzNà¹Ô¬i‡íÀ¼üÙþòØ-ü@Ö'’‰2 d>âZ\&û*ÊëeÍÒ_ëåÕÄ(ZKÕYÔö"ìŒÂáíÒV+Ó}Ø½Ô‘>ÜÌËyë¾.9äãs…l6ŠtcLyvEdo‹"(3…s—ÉâE¨Wç
iüþ
¡{ì-õdÙo®÷aÌœks™IÍÛ¦}£ÞC¯7Úaw Hân¤è.÷<”¥Þ¹•¨pEÅur¶2ó:9[™oŸýÖC-/­
º–¼¥Ý¸´µn«ï•[°‡ÓóˆÞæ'yÝéÑÕW€eá`¡¢Ð¼…å¬"U&	
×ÉøEÄË_¼®™ŸÙ
]ó;¹Z4ºêW{;¨Vð’I°ÛŽP©¾ò¦¼ÞÏ_P({g“û_€_&R±
U\'sn'×·,ãÆou²iÓå@[8‡Ù|ÙlŒ:$”†QÃÜ{foª÷Ý»‘¬Íàœ†_wUXÔ›Š{ÂUÉ…Sqv5äÏsZÖß~RjKm£Þ^¤«n«z1ïYKÕÈ
WáI7¥Ä?†Ò>èKìô[áà¢Wú @’ÝN¢ÜP4R—èóPÖ|ZÂb™ƒŽDûÄ:‘ƒGïu"ëáý8Íc¯ Ö]æ ·ÓZ*ä–Ìg“ÎþìÒ\î¬ÎŸ½QqÙ¡è4ˆ~?5z guÇ„‰u¸°0æÀ(ÿZ‡ Žß¿Ö±–w“óíT\mÉ›OÆÍ‰©õ À.¶KPk)Wm†yûŠ‰³Ç:$¤€ß‹M³!ÌDízÄ……¢]ßó}Šùç}÷}Ÿâ£Ý&kk[•Ä°¡ú•É¥ãÔL²Ô ÕÞ

ºëÓm²I:ùì6mF%’ÈŒ+cLu…ûM
.’i†~¥¿iF
zÝJØ\sÛMJ~Úœ7WŽ{¨t%6vfkbv[Ö4éOøC.q]T{)å¾÷o0Z°&šƒÅ’•ßN9Xx{q’«‰î-÷Ói\Z\zMÕ?ø`ªW’á¤qt¤´9­ë”¬:ä>ú¬îŸüý*9µ'_”åÚÄ•aQœ)
_ÄŠž
n;ŸnÜðÕ9Ðó¹€ß¾kÎyŠ»w4®†#uCOve°s½U­4¸,Oú½ÂzçnmþY§×¿á².>HäÿÊ6Ö2fŠ"ªÁeù[öÎ=™šq¿x25oo£]½À«‚þ|>ª«‡±7ƒ»ÔêŒÚ%ªFç|ÚHÅæsö8Ûc¿÷Opg7K¹” ¢9CážÓ‚›äÛñÏ‹êø·:9j„çé}WíTl	ä=›EuØ<×{cy6nß« ^_O†R:¾üfMÈ(Q$òKM(ß    ˜ÈØÊÕý	0õþêÂÒóD–+ñ±Öò7‡åô¸» Ýf²õ`¼Çg _WÝ°w9N*­70ÖŸî­Ù*®5()äyˆŠÂ"ˆ‘HÁˆw.Šb‹ƒú¹¿¨+Ê‹¨#´ø¾KºÉr85Xf®é÷-©wMKgÖ>M[þi_:ÉÍ¯ˆ(¾ò¯å¢˜‚gÇõ‹› @
Ø7Ôcüâ:m6‘_\§ÍƒÏ¢Æ¢ë-´9ÛÏõJÜ¬ùZegiW·”Lft·KÕD¦­]}ÁÞTd‘9e4›Ï¬¸a}•‡;¯øx¸ó_}U	oŽñ,¼/p¦p*!õ ™Ëfˆ£þžÉ®–´£öéö©x\‡ÆXÄ4
~³îNœÙ/Ñ.³ßû'X¼æqa4Â¥r	×µ<8Õ›ÖQµ	L«½ÙÈ˜-ú;÷‰>±ËAI¼
~ïöÿ74ä„„ã-\'ìù"W*ìùQ%ÑJY­†Êrîì–]Z¥Àì«õ‰âÎ&³KÓ
ý•5Xèà¨ÝÙÇ
U°e™'® $ÈòCPVc‚! /Ú–B€'ö«6µÐ';í°Žîút6®¶íÛar5T¯&­J]Çß6çKû°5k´ÓÑ¿®dOt`ô>K„Å%qLQv«p7yŽòÀ	ðøýpC,3o9
‰bËv_Œ,Jöúu<ÙÑð~S“•7[SÉ{vM/êëH4!à±ëcÝ½(*¨^twT¯º;åç1ìë¸=6‡l0i(¡ÕG¥–íNûV½¾0:1
ÎÜõî»íXa_0'Êz<1"1ùyÃUŸ|–e%›Ç…óOvöæ|>ˆÍÞœÿ ³ÚŸì½]\®ë‹‘3XÛú„J{o¡o¶=-Z÷|¶£½‡Uë+àŠèNËåÓ-ÿ"|VP‰Š«ÁâÛ×“ü;ÀpÄkì”m’¶2Û/édÑáÿ²Áb¥U†£8ìâí.=oÒRxJÌ­dNé9Dø§é,ÊãD1:•È¯é¬|Ã;á|ËV§¾hÙš÷NN³ƒJæ¢ÖÆL¹Êõu2²<ó\‹Ç´éñ}¯57•Nmi¾`UQ®+ÞÚQ}Þˆ{ÅÞ«>…V®O… “·  -ÙN«ä>Œ7-í¸èÅµ[’ô“ý	mõQ=‘Œê`¶¹{_ñÇDD»\1"ÿIÄý5Ì£|L T8qá« ¶oH¯BÇ_„>/ÈóJê1ƒ;ë ±ÒÙè¸šiç£é„È®ÔíBÛY«»Á3:BÊb¬<$•‚‹/T.
s]¯àüÅ
œù…êkÞ¥]9Êçª´«´ê‡‹Þ%§ødÖbÝZYy—…åÑÏâ$¿^²€ ®|å‡²Çü°y(P¸a¼à~™OuüÉ§ÖåmÍ_‡ksÚ®®›«¢ˆ¼•½~·ïÖÖÞÁÜ×[SoÿëEvòëYvËE¼còÀÍfŠ–Ë€‡|…;‰ƒ¬—bîL6uùïÏd{ÑL“½ú¨…oÖÜM¼ÝVÖ©»D¬>±}'ºÄ[îª—ÛçöED„¸‘Ð¯„Já³Kû±àò`Uã…Kzq 0jônÄV¶T4šÒAŸÁóš•ë¾6ï×¸v\Þ0øSsŠVÄ¢¦€ÿ žÁ³s-Œ (<W¾!+\ðâÀV<-ûÑíjÔ±Wþu~gS}b£1jtÚ4Nï­ë¬vTÓƒ<ŠÕ
˜ÖƒçW
ß`ãìÀ–/K™å†D 8«¦¢JùÆÆë‚ü}÷ŒûÅ}÷üÆkÇFÉ83ë0I(Œ›ÑnâÅñlIÌ»$£³&ïY›Üw×ýguþ†ÎJ"ø‘OVŠç}÷þâ´Rô`|uZ™Ãk¸zÐ[û´žéuåØ8Jý
º¨ªÀËpäÝæ¶=p ¥é'Í¯þgÂÊe™@ž·XÎ-ND0Tdå ÿi}ƒåŸ‘Ôñ‹gdóÔw/‰ÚØ×	\ÕG•1IWz¯~_ÖÌS-ZL;«©‰=eÆš	û”SqöA!0G-‹ë@F"Â…RñTTÖ³àõJ½RÁy)é¬´o®NÞr1¸Ž°ÙÜÕñÐÄÕ@Yn¡a×çƒÝêõ£õ1uv<@1£XÎñŠ‘êàÔð¶Æv>¼ÔàÅñmÎÖ±UQ»ôìO“Îåvž˜íéI–`âä-mz—@Wö®£U%õ
ÔHÊÚ‡Ò?7ßÇC=P¼¶…²þ´\˜¼ˆ¡•ZEÝÙ çHñOCB¥µî^Æ¨„¦;¹}8ÚÃk “Î2ÝÚÎð šxv S˜íÀPúF’*+íÊÑq¹ñ¢Ëæ‹Íh æCó¶ª«ãzºÝu[ŠÂwÝ
SQ|>x'¥éÌîKu}J ³n›A?ÛTœ‰Èe	Eºø™¦Øis}
4—ÓïôÛëPeíÃÖÐ‚[³’‚´N. ª¯ç2rûs4Ü4ÚÃé‡ò1C‚¤Œ$EÏ#Yj™»n†0§ýFþ&JœêÑ®Zø“ÆnÆáÔ½º‰|L}—Ô7òæ>`ƒP›Œ+“¡r–­Ôº“šÂÞ'­EÿFe}…æ‡0·¾¤Œú¹¸ènå²j÷ööÜúº®Ooûîåî%o{)ÅžIT
×@UÎ]<c×Í¨–Zç~WÔ&JsC‹ë™“*ÚàëA›¯¼´¯º4æ]3Ó ›_Ó+µûÓè²õKJŒà*(ÝÊ¹XÏ•n|uJB”Q	>œTá‚(>#ïù
âQ÷}ãîÆ¶Ù8®Ïk¯sz“Ø·F½Sº^õgq×Ö­æ	µKÓå4ÕOx˜‘ñ(ŠW¯ÑóÇ›ÜC~@Pø²¦hü‘OR	âàU’*·fõ3¤¥ÃžÕ×‡¸Q¹vKÆr
|ëlÆ}{£‹:Þ»·j³êÎ¿Î„ €büçðØbË\kR¾lAaáøô¢üø&Þòü$H0cW¡§Ms:`d­àY<:'ŽÜu™Z¨>Ø7V×ˆl†ÞÍø‰ç!$=²®_ o ¾è“  _öIÈÎ÷^}ÍÂåõ2?—öÕÕÅ§í ²ªNvcTÝÎ&[ºî—6óÝeþqúñ×=È2¤ùÂe%_¼„þ€…û³?°s*Ã~q5äÅícÇâ8W–ÕmlzÎ¹_¹ö.uýÒ·[•kÓ]MìÚ~^³FY¢[R’Ÿ‡˜8_ Š¨Háà…SæÛŸðùGíOÎƒû`6›‡¡<JXg²»k“ø<ÜÝ7¸ß¯5*££6ÐÚÈë¾’tJAÊþŒ‘~]ëÍé)%Â…–çïspQžñÅï÷óE¹I³ÚÜšÓx§štëØ=;ÞUù÷Ûq•Km…¿²’ÅA ,Ë„0‰=eV$…ïÅ…[¹?²Ë¹üŽ ·^4ÈƒôÑÌ·í¥çÊÛ˜ÜWöLã²Ô›e÷æ\/Ë3Náª3é+àYƒ†™Âž×8`Ùm(¡¸x|X¸›;ÈúLæ
rxð² ç|’ÚÑ|2lšF#Z_hÐK%µ?3ÛÛcã2p¯
bU-´ÿÊTm«@™ÊˆJøy({jC×ÑÅ/\‰”õ²zåÜÒà¥s{NÃ#Öh&#{´5ìaÄF‹}W	š~Ô.ÊvÚ€·;Ú—*á*ì|Pø ƒ”G‰
ýSuŠ‹SXtÓ•	À[ÎþppdåJ:x|û$#PißQÐqœ¬ãÐ7ü+YÈLmÃJÒ±ý«mHš/'úñÉ’ #ÙKË„²GR~#G8±4_³"¼wð¾fyat00.ÛºÌÇ¤½W#¯LÕØœœªKgî7/ûíáŽ¿â¶³òl ž÷«Çñ„™ò,Üï]¡à|B/¼‰ÃðOR[6
Ù;^§]£‘¶šî­~Ð’¡³ËÄgŽ›ú<õî’>	¿ .è¸áûô¯`-C‚–h¯š&øÜÔ_äî~ÍQ5K½ñVÞ×ªcyù 3ð¦óyõ:fS’Ô¶5ÜÀ´Ý× >þ°§WÜ°x¼ÌdQñ›‘=ƒ¢Ã‹•»7&™ùÞ‘õBîNÍþnwð'ŒØêùµñh2ÝŸ”Ø$“mÓ]¸Ùã!Ÿ’=ZP‰gÄ
àOCäqËžb y¸Pü¶¢hŠ‘O_…¢)ÆûGbv›P6Nñj·~-û³ëjÚ
ÆÁnI¬Åêv­8Õú0úôå± òB<¿ú{QÙc({pX4º‘G&±‚ÈiHìÜ™™èÆªƒ×JúWaR£,cGKkU	æÄ¼ 	»þ
¥µÚ…ž×ÎñìªX¬õå¶Ž>&µ'Dœ›É)ù!*ÎÍßg¡ /zÊÉ£Û‹ùÍÉ÷ó›µ'¦y‡ƒÊ|_kÑÛy¢3x 
ËlÌh;Ú÷—gu}÷ÛÚ}ôùüþÅ%÷¤è÷b}ú«üŠñ°A4©‚P.nì(É_?ÈÖ‹ëÇyc_f‰Õ_OM´:„‹áî–2û€éº„æÀ+­v›Õle{íkŒ»Æ—È³K3PÜ6~Q²gµ%…o¾?Dó®â¶Nò·2ð·~ï-Ï÷¥ë:ÔÑ¹]¿Žˆ¢í´;†òèÀñf«“óÞpøùÂ~pq‡°„%ô4$žäSÄÌ‹ T¾akÉÉµÇÈ|Á¿Üyÿ´u¿R]šúpçmwÑjÓ	Pk¼;¬¶;Zƒã¤c˜Æ½rMÝ¦_²5ÇJQ¾#—…Œ¤²„ø$/Ü]€Ã|—[>ßåv=¾ÉÞm¥Ý…Z3·}¶W
&µ×Q:íûJ½N~}\?{›ðKÄ²(ÐaÜ”ìy]‹*¸ cÙËmâ¶ž'ùÂ‡PÔYþCáÃŸ¶œJ}*5ëòìPšëµ¥UwŽ.•®.kÜ’›.H„—Å9ÞÝ¾B.ð²|HVÞðÛýaD§X$r%œ'ÓüqZ˜=Qñ‰GSÆCtä“íÐ?Ï¼õµ1ºŸµ¦½@X^_7ö¸®ÖjãIí*5õsr…Ç|£Ñ#f(Ü
^’ü-×PôûqËõ÷m*=éq?>4{U »š}Oíóe Hw<—[C°‰£Ss`vGÏ7Œ^”MfT
†…ág{BEt ÃŠDÅ¦\¸¥¿8aÀ|¡>ÓêIoå4˜»+€•zUj÷eDª•sg8œŒJµqû,_Jl±3dIŠ>9
¦âÈAt3ni…þz»­ð‘ƒ”…çùW %žÃz‡%|,Çp»Q‰nO$èÎžº½u‡5»
6‰MCS7þ¥düÑ-âŸ_ñÍÞ}•äìÅ=Ñ(üA-Ò:bˆò€„%‹f*Å»¯¯vÜÂŸ%ìJ@Nz²BRxZñTëØs›îD_¶Òh“NÎMMXxß
Oû¨ÏÂsn)«] x¬Ë¢	IÎ§HÀyyŠôâL…Xš’qtD hôN{­VÅ•T¤e£Û…¥qçÔgÎ >úßëåI³    GÑ¥2AˆÐGT‹ŠV	8lå®é
8®£>¨>š¬‚ñ`´HëöÉvî¥££´gÍ´è 2ÃÛêÊiS2½}'îm*e¬ü‚+šX=øÌÌ)#˜ýþÉÍ¨‹mÁ}¯±XŸê²É&´‚óŒ§™^ƒ³É…À	Ü_®so0ÿN/‚b¾v)E¿*0PÑG¡Så¿ç^íÿøøå‹TÏpíôb¨{-d'.ê¦1lî!ê
æ«pdZ2’Ñ,¸ï§gËýÓ²{ç	Ceü§zdÐùž"+25T¸hîsw+¿q`.oŸTŽwº­æz±Vîu½ó¤C\I&'y±¤g§3‰º´½Ž‹dësnÇÊ”Ê<V}ÇEe¢P ¹ ÂESŠ‚;Íw…ÜÁû®p¶“ÂÐ6à`&ù'õ®'éfu>Ïdkp®N¥:Ø´–Êf8W]õ
ÀHÜ2–¿õ÷ÁŒˆ‡¨aá  0záš8püÊ5å&xrWA;è:ƒñð>·Ý[cÛ] =%å·oúvÿÈc÷­²Ž¿ÀÍÄ­rª (=Op(‰‹b‚-Ü8_“‹ï§Ÿy‚Ý€ÖKèb³n(ã6
"¶×&–ß'­Úl`NæÉÆ^ ¤ÆçÜ0{9Sbá7ÌrrˆILpü…Mò]nýÕC¹…Ý¤
VC¬.LµCoòáâ«·°~ï-
Ú·i/aûñˆVÎÏûì;îì¡
Àd†Àóœ ¦®ŸpÑª2ÎmÝ­\U™àv_¼~ûÛÂv–¥æå<èv%ŒÉÒ$e]WgøèÆÕ#¤=ûÛá¨ _ –ÅFHÿì þb¢|Pd"‰˜àE;hàWE*äŠTr†®Ïèl±[Oö½äZ­‚Š1:‘‘´F“h=#ÝN®¨*ŸLýl~ÅÐY
! ÁÜ"~$|
`qÎ‰‹––eÜ/Žû÷û6—HÕµÈÚÖ ²»Ö:M'ZN:Fwßß-ôE§Q_ÎvÍqÿ“Ê¶,˜ó‰NâäÙÐ(»bÅçµ,4¸hu™ ~Ñ¡W ¿êÐ›7´4'Ó…áëaçÁšYbá·´ÑÐÝ¬·¦ï‰Ï}ëØ?ç~txä»±¸˜âÒSŒïãœ»h˜qçïAfÜ/îAþfèE{ƒ7§ÖrÖZçõX5¾ÖöÛ.«¬©´É2x™€ûÂŠæT˜Š§æFÏCY)ãZñMÀ7ÍÅv.9CDýÉ™œ¡é€¬&‡RwŸz
6ÎÎj«ÝjæE™Øðâ \jî:­Íö0ùÂ–%àÄënò½aþBTü<ìäÜßÐ¢–ää%Š04ù$zÛ¦Áè|9›zõ•lI,–ûîJiúF0JBuÉ·—ùAý/,lÑÑ“Ç@ð¼U?Úb2¢d
›-FÜøE©
ÉúÚ~`ïåRµã«ÜŠÞÀ‹0ecY]Õˆ-^w*Æ®®ÀVºµ/xpGÊ
—¤9–]À¢ŠDàØE‹ÑØ¹«:öG'Úžy¥•²étZÛ­ãÔ[ÞÚ™t§ópÔ³+^¿$ÉòyJ¥éîKØ"¤”äyˆeÇ%$®Ä
wÔçÜnòâès[ÿptø'wm4\ØÖ\¯lìÏš
êÞf†®³ËJ‚ÁÚœT´&>ý«}Öâ5ƒÃ0{«žÊ”=ûqü«e5ášô‡h§ZÜÃ§ÄÂ­½?%®ÿÒ¾mKQdëúúï§Ø/`‚ˆà°ïPPT¢"âCQTPQžþÀêþ2…ÎM’=ztEWšÁZsæbÃ3«È¼9j/®âNs9+ù(Q;¸0NÊ¯W—.S–ù‘=CTˆ‚~¼ï€…b-äèî7mA£
*©(ýwå¦³_ŽËžk½A¼X÷Œ[o¼Öt!=‹öSçâËÏ¡¹aß&ß]´@;Ð€P:iŠ þëDÅªê2¥¸«±Ê3xúònó;öô8>½'w^¬ZOa8]÷Â 3æo¡-o9ÿ˜	æù !6*	'óþacZ7§U ž	î_ä,¶J´YŸîªº¦Ë	²í~"å8@·õ qoz\Àh2èûN.ôà\­ÖžŸÑî›€Ct´Šè=äÂ¸Xûƒ1dé}7î ¸™ò(-Åí~¿ÒtÔ
º`%L†)™{éÏ4]·ø³ŠƒŽ¬¹s_={Òúˆ~pÑÅNSÎà•.Z¤9zžã$Íý‚¨X¸"i†õ@©•4"ÑÑG{0ìg÷ð0×£âNOt”êµž-Üv|Üïò,8½Máƒ<aøÒˆb¹_P*à\ÊôÒ•¼U_%|7d›RkËŸ…ûÖ^š<µæ‹8èGªÓ¿§ö’Ý!ÔN|¼ÿA2”\^±%°Ÿwsñÿa¨f ÝŽ"²,Ï‡Ì5{ ¸ó²Ê&ÅmW¨l–qw»ä?~l
kf‚ÇÁ<X
ÏÄ°UaÑ5¦ÎêyëpÇù„1FõÞó?àøŽ!þ½ÑÉ ò;ÌSÜ¿  ´¿²"àlT'à`gãUzXµÕÄ‹¸éó D©g8ý,Èç]Í
5â«[½Î3¬I@ÿ'[Á?w<ü}Dµ¼@Ü3÷
þiWHRÔ•Ò£%s½FîQ—†jG <0ñu½ãÅ‰;½±w¼ÅWûéƒIË’ë…C£.$¦`J¨_ÔqLqÛM…Á(núOîªnL{â=]¶Ö¥µï`¡uetÁ@‘iäÀs®V¼;‹f0
ÆzÏûn>eŽa?€¼N
±YÌ‰µÙëŽ&]Ö\•=	ÂJÁÕRx´9ƒãØkoM”öR­¥÷Eç¡ÓPvþAfü	Ïqû–ýõ«Ÿ‰n™{?¢Âäù“¯š£¯ü$ÔÆ•Î9Wjé\Hž)ó³/gF²ºÏŽ™8DÝ}&ffªJiÖ–ž[ÏÃ£g½$Êßàß?7¸ü}‚ZßáèpqcÕúv¥
«)S9:Ã|-ª³{{¬tîÌb¹Abs»I¸ÙÊÜfÈÈ3fõÊ/pÅxž@LûþqD“„°"¦×ý
J8WÕ3Ïûµž9ÚÏôáŒ1âþ{â.^²£vûS. Ñ5Tú“ÇR#ýâÕkø•4äxü¹mâï#Lè)ad<÷ñß¿Á]™;ÊûU¹£ò€—+ôgÖø ®äMfùK{±ž_í¹Ñì•pïX×hc[óÖ\GË[$¦(á.7gN>‚ûe=7«hä"¸­Zº€;bpyÊŽ6ß¬SÙh©Jb=$Câp?Ð÷Æ
lúe,Kûz1Ç?àÄžêK½¿ó‚¨Ò–\„	ì_TõhGLE.!ßÕÚsM"èãõ8Œ6âá.°ÑÉZÇ¾²¯=nìHqkû”§Ž?ŸLv·XsZ€û²Îüu„‹Å$ù¾‰ïæÁY\h”›¯	î©cÖ´áñ±
Ó<Ú\W:X*Á™Ácx—syÑZ®;÷Öþ LO‚1«—þíÀ¦Â&øýˆ£YDÀ03Áý‹œ™
Í’èI×iÏ`¬s²ÊÔp½9™;ÜlCé=m­ÅÃt]<v°5\7˜i^íµH8*{‚Y¾G$l¡üÂÕˆãÁZ\Tuß†,ÕºïyßN,™É–(1.üvòä€ÛÅ-³
äùx³º
[ôxøÜžòÎÉç(8'klQÐg(R÷Íÿ‚µPfV…[©ÕkäåIwwÙé“Ã3l³cy;QÛZ0¹'¹ì/–Â=Er{éF’üƒHŒ}_ŠÄ^5>3€¡nì´ÅK«j|mÓ©áÆÎúÒ^Ž2}•ÌWñ¹Ì‡²uK˜ã@“p2·ú£$I¦\:?ø¾_5>,`ü¹[áu¨9ç	ŸÔý‚¶Ð	‹rêŒNXÔIm,jì&[íÁUßç~bÌ½ag?KvO_7/’f?æ»Ñ~£à¾!KõÀ´–W:¢›H¸B»S„_Ð:`QvßtÀ¢ŽûîÂ6ŽZ}°²#¸5@8ÜÌbc%ÛC¡á#»¬ÁmÙšÝHƒÃÄd2€%ÜÅè##"LcïÆ*òwV1D„
]˜ß÷t„3œéŒÖv¤ÌÅÁÙDì1…Ç%`¬¡Ö6ðÜ	Ö?yçt$—ÎuPú¾ý‘@BRé÷-ü‚®y™YQû!¸qÚnnñ›ZìqãL?­vŒïƒÛÝéŽöËƒ¶WÚ—-Òÿw1TÀp4Ä~?z¥ˆÉ/ReœÆªúweï‚QÝ»PÂ}° s/Íu3S7mQ´£kˆmnžrÏQ
=ƒR‡ì'ï¼Ð¡ãÄ²%»VlB"@4~Ñ…åU–B¹^)¤ç®¸“ÕÑu82¯0j§¨Å%épçnÔŽÕ_=ðÐ8K—v¢ãz™Ô¸¢"
ï|
Ñ“º„Ž¤7Ÿ§¸É?å¹A÷Â×È »Ë“?²œ?ðÜqŒ¼²F^8É­ej0,³Sî¾»šœäzµÝ¿Á±Â ñb<|ÿ¾QáÇ
Çè÷ý
¾æÁj?ÖòcKÄ‹ÇöÂ™¥àqRQ[8
{]û×a(lîãCkyâ§f`þ C…,	KÞÓ-¯±gâß‘ð5¡qã;Á]±†ŽÈVn)¿ów†3-¢ŒÑ/Í
ÙZÀ²Y>ÜÎãîê81ŽòfÑ›ž~nAÅžÜi‰ŸSáMð!5÷oø*¯)p×ZÃœÆƒMÞÑ<ïº‹wóÃY@ÆežoËãmuVîüÊ?ý€·Ppü bEønÖzõr,ÃØ¿hÉ"WWåÆ¦RE
Ã§ŠŸ¾‡öý¨ØÈ}¦ée÷p’žlœnŒyär8Šç€Ÿ!ü/GEîŒ'¡û ÂŽ#ÚƒFì™ø
ž¶K+yÚ´_‹§]ÒµÖÉî‘ÓêpÚŽzÙ {žlDmÞÏ“Ó!T\·Ú|ü“÷Í¿–æ!F¬À…žö¢‘‹Q	¤ëzËÙãb]oïzÜv–ƒÔÈcUË…ã`%ÞçÈÝ;=$ç‘uæe¿0OÃmòÜE­€SbÎh¡“ÿÅ€ûÔKK5hZA~;ß¼‹ï£ÄîCÄ9ëþLº÷Y}ÜëK³Í0±ZÇÕsÎµ´µÈHÊøÀTìŠ!.Ùiªh€?8N Ë\YñÎ]^!»é ]¿¼ß?åh›Ûí–ŽèŽÄË¡µ¦vs~zZºžm$‰»?¸O\8!b¶Ä?É¦ƒtåÁÝx”â®ÐS¡¸+ôT>ïÓVàGCo£&rÞ=êçVK^Ûvà©ðcØíÌ²\$½^ïÑ?¨*Š+‚÷—Vñyª-@úáþ‚xî@yéìU-](ùr[¦–8–ûöfÇ[±cm{Q/Ù¸üž×–›lÆÅîœPÜÄ¯µsP %CMŽh±@<2"¸‘($¸+
µ÷/R    
ouI‡ëéö6ßÒkžÝNÆÂsúT·½ëÈÏ'“$q)J~†›%†!®|T$H1@-oŠ¿ ž»
Y÷w•¬{¹˜-³º—‰7+~€À2ìa÷Â\{×Óú0½ï14F¡Âä)Oòasÿ…€Î|
Ü{€‘O€á@1ÈÞXïâF•¸©–œýLÒ¯]ñ‰<IÏjÒ±2Ñ°D_<ÎÛë¯V›.»ßÞ
oíÖ6ä€°mŠñÇàò%$"CWû²bce‚»²É¨lAúÒŸå‘ºñDÑ››Ë9‡,í™ Èõ¬+Z,“É&ÂQâŽTÇ­Q¾P	Ž?*úÆ©H6 ¼éÞ8$<¢"ƒôaé ŒÆ›y¶µÛÕñ)ºÓyÌ˜í\y. ·‰&ý`ˆ6§^ÔÔŽ¬
p~@1[>Btò‡E,þ
2¿`žaZýÀûµ>lÄ2lÁ
{i–Î§ 7­cÅ}SÝÊN'Q>Õ—†¤^û÷ÚŒ» ‡én/Qàû.Ú5DQd Áý
æI"æªˆ2°jE”`}
O{ŸîŒ¹”êÐi
õ…6àÖñÙ÷{ Ô23×6h ˜ƒ'6D<Få#Ä~0X0½ï_dÃŠîZ]ñ·92oŽ)Ÿf›
¿îŽÌ©¹Lyß‰ß?¥gNýÅ½gëS½)ŸÀñ„~r¨ô}S½:ˆBwc
“.D.­+¤¸ÝŠu…Ÿ¥:RÖßNv®Æù‘o ‡'î¹=LðvÅe{éæ¶L­}ˆ@íÐêµ=‰ü?O%îHŒA‚ô_<d¦ª© «ÕT¸Þ&­Õ›é««
´û<½è‹áyaxóËb.°íÇÜ0åÉteOk§|_·ÆˆÂðÝpW¶H m
÷/R€!¨,á•reUJaKè`
Î²«_º±¶×³Õœ¹û›¤%uG†·èõV±ºwgµS#/pèƒ<PÆ

iº/Kü‹j‰5ÇMÅg*pïò:Í”z\¶d±{,omf›aM2”-‰0”ÅÞ8àôÞ¶ÇÇà Œ‹f @,(}À¨ØœE",‘ì_”lÃÊ©5‚»VŠÄ¶ùhÚNü3r$4è$æÃ§ƒ+/uÂN+àö-yuóã<þÉ;/Ø àù/ëíŠ#–f?‹,8wó ]\ÑCŒY­kÓzK3nµ.âq»;mòG‰ö }U¤EÇ»ça÷tµùˆ	Gp³GTK`ÐwÞœ‹’+4í4«3¥8ì.„Iwäá¼s=¤çãê.ŽžÛÉ&b“¸rN'òì6K¹è‡ xÀ¾ß,(¦A–å‰]Í›ÿ§Ò³²t™ëU¥Ëò÷-r¡5êYË³÷<{äÐ&Ò†l`ŸÚ³çÙÑ'‡õ‰s¡ý€Qpˆ*qx?¢HÄ
"
š2ºO¸Šˆ\uîûiß¡flî
hæëÅs¦ßöƒÑ6çñ±ët8lé
~$ª–àÃ¾oŽDZTó¯ŒQIÈÉ;o¼
â¦K<*p[ N&%Ÿ®RmÕYx«–džÓI¶9‡
g³8
º'.œ6©ùWGù£àè
ÿeýìßGTÎcZ²…W$¼pW\¹U+àêÀÞãôì4nÒ›¬nê6€+.m¥í•ì1½íÔ™MÙ0Wî›ø1öpqü—]j¯#î•\‚äÜÍ3g´tSå¿sÖñßjÛòÒÅÙç™Ø›ÏÒwfg	IùFŒ×ÃöIy{^¬¢Ú´/pâ •ueßÚbÇ@x%¸›gÎn³òÛ¸N£8î~o{ï÷û<a+tŸ#g>b8/5–HŠrgo<º,çÃ\´ÅÓ¾*Ì•ì¹X\äÂÂ[@s¾6•@e‰#÷j•8Úk½u9 ~|ÙfË~
Ãe?ºÎÃiË<;’;¼±r
wjÿÄ‹Å½ß7,È‹ˆÚóæ™3*çXÑBkPÕø­	úl¶`Ô=ïéŠúÞzæá­O´yî
’HVâ£ü<´j—è
pÅ¥2ˆçÞXÚšÀ×Ny
h>Zì¯Ä]kõK6ÙØŽ(™½y‹‘Ðî+®,á<šÜ °·ð:J ’æ«Ú!á²°tÝìk^—…"‰¯Aó;
»´¤¸€]¹¤¸´,‘7;íÞx¡Æ›H™„¦’¶I &0Œ–‡²vÿ f·Ïý€¶ÐN3ðÁ#¶dÍ©¦íÅÂ‚@¬yãÝv•>6åJ!ýÒmk£gGÖ7ŒËNZ­.ÌòÕÂŠ]{¦L]0Íë@fƒA~Ýü 
}ö]q„ø–îyå	îß°5\!³Hp+U2‹åQÆ>·ÊOZ|x1Þy‡ÑrlŽÝÍSQíïP…Cö«çÝú Ör´ÐÇ°¼sr‚YâßX:oödMI«Ê^&]e\Ã˜ÇË¹%ÛÁº{VóÑìvšOo‡i´Ò¶ ™OÏ¦g,Î«È­Ý/ýG×‘÷ñ—b7,ù‰ˆC§¼È×ÿ+ÜÙ3*sWÇ¨rn†L×z¢ÚÉÁ_1×dy“Û­^ºPÔ°
s
gã¤vÙ« W¨Ú	".sž¶lp"yæÄª±M“LäZxÇM{,ÃŠ¬a…1¿¸Zï üt7ºNc…qú ,,”Ž×‡µ
§vëÞWC}öÆœZÕš”<U¿¥™Cø!ò 
Å&	È6e&PÏ©õûcörú—¯ó˜×ì•.PÜ8Þ"Ò‹xŽ‹Çê¨aÅ˜ÙóO|v‡=©8TL©ñ9æ¸¦é"â‚	’´¯Ç[!í[Ñú8ØÒ´
ÂjxÌÏ\o{ôÄa[‹ó$[æGi9Zé¬^
_ˆOêrÛ|kÊ1èyYÄw—mü5že2bÕ¤ûè¶þÝ‡¾Û
ÆÓÓM?F‡˜kßqÌeáÔGœò©H‡þM*UøO‘â£½®,'
¯Õ-T—­98¦L˜)8½aÎÛHÖôãá„Å‡û°wóÉèÞnñ›lÂrŒ62{ž=ÖÜ©k{uÁµ6Qä9\ÈCØ”/Ppä»{z)87¯õNíQÙ±=ö³àêk‡«v¤ÑXÙ'ðv5“•‘.×œðpÏuÁ	ÿÅÔ `Ú~]€kJ
¨zo¦—DO	¸©ò¬ó,.Ÿn|}þÌÓq?ÖrxFyÒê!o×ó'±yžmï
‚Û šà^~ŸDâ _àšº~
.×K—‚#.°Æ³<®·!ß ªÃ³ñq½Ê½1‡{Ì>CîÊg“da¬b‘³1ÐõºàÊn	o'—÷×Ô¿Spxœ^¡W‘ŒéšéšBMeìÙ•ót­öÁï,xs»žú¡À=wëÖ‡
<„¡øÇZÂ¦ŽÊn¼».è×Úh¾n£mÜZmú®¬]ðt{óGÇNEùÉðBv02%Ò½çlÉ™VMpÓqžˆMykÊPP¡Rrâ\½ô¡ãU·QÚS_m÷=ž‘wsî2¼ZãpšqaÞZ®.g\÷æ°Heˆ¸p ¼À5e(¨X´PZ–BÁÙÏZB1 {°}öÛ	fôíÌ5dUJÛ,n÷wŽkÞÀ¤ß;JµÀÑ•s4K @ ¼è])Ú¤"‡ÔR’›ûâ
¨dôÓðmsh?¯Ae|ÜÛ²uá[º*îl1«$l¶5{}Íè™Sœ;8H›ó?Xôn1l
0ÿ°XëDP!Žg_W†š–«!+L¹qhÇô5xW(ô·ñí¶ÎÂQoÚÚ%îºzú¾wpýHZ¯6cykt2àœí·+«ŽÈ­QZ£ é®À·#‘V6xÈq‰«×#ºâ¶î²Bë¨Fþcæ:Ý£…kežr³î‹ÖüØØè‡eÌ_¬I4cu—Ö}ªÞë Ä„‘½(Yã½Tà—ÕÌÉw˜ï*ÔÌ+ö´µÈîœö(úÛÑ¼'©Çµ5o'K=¼>¿ GxvëñMÚÌY4Pp¢øvD< !4PX–%/™i¸Ãé¹…ËªE;F”*Õ¢Ò›c§ûì‹v8
y9s–ënÏ0ÛŽ¡-¡ït‰Ý_Îû·“ÆúzÝ}d
#¥¡
oŒÈ!ñu­MsväZwiYÃ›¾Ù°JÃ»üf-ZB?ä§ë¯}}Ð—ê#÷gjl«ç¹z<;9ì-ç·ÙnWóZé|÷i¿úrD¨Ž@•ù#²&×Út4Ñ‘þòªæ]ÜSkU3Þ÷xÃ÷žÏlµ_îÛWÞêM ÞÝÓ,½«ÇˆosŒNàõsHÿ½¨ÏÄt» }3Pt0œæãITLq7æ¯$®HáPÜõR8m9ó`ÜÎý±îž·V&Îq÷Üó¼9“ôpÉ^‡ñj:ÞìÞ¿áos1
üABÌ–ŽðkjTÄÄ.7Öç§°ó²`
…m×¬yh›qŸ÷Ö¹¬ÇŒ/Â|xeD!êZ#»×Ù6\¾›½¿ñï`sE´Lüxñ¿Æ:ü£—ÖªQ|n^‡ÿM\'C»ó‰é„V»…Z­þ\ùçx1oÝœî€Á­ <z(¿ÃG³˜|ÅŸUÆŠ#P,É…ì¦ÕD
—µO)ÍPjiŸ.t©Ò…ßåžp×9^œ±Zè­Ú‹x¶[è>|(‡U®G=q Ô‡Mýþ ‰ûCëQÓ~û¾R]¡À—×¡QÖ	1½M×y¬CÂé
¨ÚÂNÛ‰Ü2îw—w=\Dƒq†÷öü=fùÈ/# Þi9"6Ï²P ÷Ú˜iú˜¥GŠÛ†µ6yÏq|òZI`ýt¿æ÷HÝ)Ù]m9ÍÙ.3i8³²öƒÏ•®•à	8 ?wýüÃ,Éo f)î¦7¬"ä×*ÈÆç‰G,‚>ÌúñjÍ/æ½Èî›þ$ßÌò«#Ž¹Ž;öÔìõ&zO+| X¤í]GÂÓ÷ï¾<4Ïî¨±;ŒÊ;·	à©T±s»|Ñ¶}œœGÛ[<Ÿ%~«»<êêÀ5By&¬íáÉ—aàxŽîíØ-HÛ×>Dª½ÏWñƒ!…Ýt"ð»Ñ2E=í»¹Šh«,ü3ÞnÚëu{hžENˆçËy´j…Wm-/üxw¾>¦ýá¥¤“£ïG¸è|âqð/h ¹»*C6Õ«Yéž=Fß·z
U
þœù»Ûþ:XYã6'¶»[{Á\B%Ý´ÒTð¾aaÈ ø²÷êïŠÀØ¿ ýŠn¶vU7[É~gñÑT<x }Òµ¥Q!ÿˆMàözî,ÀwýtÏÔ#?mM©›N¥ó_V
¼N8Zx …Ý´Ë¾€m–óˆ6ú~iÊ(„ó{|Ð	ÚáÕj{ÙäÞ'ä¹Û÷s{¼˜(çåx2ûÝ¦¡]! Ï¯¯£b·C%}	½Ä    Óo´âRÐ¢€­*­òÒ”ÞHžigÍº·Ö§ s„{_,{ìÉJ6Ñ.ÕS,ÆÂOpZ¬  ¼¡bõËó€'°AOúLy°™Âv+›+t	Àõœt2^Ê®öéÏªp±.‘·ðº?uódÐO/Ýü®-ï5šo`l´4Ê‰ƒÞ
CÇcÈÓàÿ‚žô+Vˆ¸k­éîg(\);vs÷/áÌÎ:‡ÑpÖ÷æù”HÎx½¥á˜ÓØQ¨X!‚Eøeðï#?èz(Eá¦ã€7Ð«èÉÔK¿¥'WÌØ5ŒcÉå
ú­Ée®ýÙe¼w§{?îÒt%õOËníhù…J,dm¹w7ýd  Ÿ<Ü85B £ò´ÁŽü¤ZÓá>=thÓrZ»A‡xì¥eoØÎMÔ”Ý5”=ÞÖD	¯ÿà»~	2@‘nn~?Šî5XÌù’‡Ð·þ,
)QÜz-!¥›;àxâyY™ƒy|aûÜÊÑàÅh
fa+räÐY>PJÒÒ·¸(.ÓUÝ%þ‹–ò]s´Á¥±$=Å—Û×(n»ª}­Üè±›ëm!b5r“î…›£Œ÷ \Žã57DÃö^7;Öò ÷MÀÑ}È‚ðeŽÿŸ#jÇYŽv+rMÇ
ÜfÙQÜ¨ŽPš¢pM ³	öû¡pHy#x[vÀÞ»d×ÍÜb
=}¼§­¿ÇM…Òèâ£w¿_ËbXbÃ‰ãš
6¼pOK´”âÆßÎ7_Fþ'ö6âì–‘™|,_Üç¶½Þë]_X2uŽåx„ÛŸÄ[á£´ÿú™Ñµ‰;8‘§üy"˜¥å!°‡j•¯OÏV>z.ñÍã¸
îþúºõüC_¯¥,oÙSynîê<‹å!¬È°_âL–)FŸñØ€%¨AÏï,ÉtSé
©Ö¦	pÚ®Éd=ˆ®WtèÌÏ½e[ö–8Òt°î£vkÖíÑ«Ÿýû–œxñ«ûz÷ÅbHQÿ‚é¢êZ3Ý7Ûëí%ö’^O½\7ÚdàÍÍÑlr˜ÜM.GbÔŽùäG¨i· .÷~T|Ô˜ÇFQŸÞü¶qyÄ€âVªFJ·½Z-]Gq—ðOµßË°cŸOmgóÜÝÛgÃ‚–¼¹s—V¿ý^
ÿw1b ©¢%z?*yH>ncsÛÁ¨ªeE˜àî×Ê‹#*Ç²~ò»1aãúimÜnŸ+8•²µ==ƒn”îã!:ýä¾‹0Ë2”O¨\;b9DMÚ/8šU1YÀ®5‰œ|ï¶¤ùÐa*ØKçÔY"inéâäßÊK¡-ÌO®»Ð&G¬ÀáÒ3/ÛbJ÷!‘H¤¹ï"¸Ë¹oŠ›ývÒ%÷Á6o­/òñp…ãh¿IøþÉ|F×õÔ¹÷q§Óñ
×Í!ýAEŽ±€¸ÒE‹EéJjÅù_3ëYIÎ¦z-rOœÛÂY‚Ùl9å•îêâ*ËÉ­ÓÝy.{ß3d=‡i
zöÜb‘ £¾UGÜ‡È@’ÒX|¿Àm–6È¸Q2>ö†hã8ÂÛNÐCY…„›ød.ã'rvóóàšêbï°¬ËU^àˆ‹‘ˆ„’÷©‰‰¿	)åAÎî’ü_»BÅöÓGö)Ù‹Ó¼åZ§ÉüÃ
·Ye‡ùM~ð¹fÊ³¥³á§ùÖ­êüAEnCß¿hP¸kcÓ‹nºTšnçÌÊòóTiÊªŸÿÜ
Ôñ=†`ôÔ€–N[=÷Ê?i?=Ú~Õ’û‡ýâÒNVù™üÕ™ª«I|¾Ì’X’ù ¡â^¡õå)°Ü¨¢Ù
j•±&ën««
:
ˆÑL»ˆ
ëmzöî.C{Ü™ÆÐ3… †?À'ÒØIE¾tDuÖ1m2àhÖ›ÿ±½·û¬“õŽ»Ñ¥7ÌW+
ÁÖdêÑù¨÷ŽË®hkÇéázJƒÉÚ‡nÁ)jâ¦à¨,ø²éëu„è\;'pBa±~ÑýeU¸wL­û½û,Mà´‹æÚ.Ñ[ó Ì< Ï]MZFryø“[oÙ»¤?ÀhŽ@éá×{þå cñDæuÂå|'3àÐ;ŒŸç§6?ýUqÃæ£Öø¬ìn¾×öwVÿ>\TqÙwEËÅ§LbË¿`c=uŠ—u¦	î\©Ò™.S­éôÞÙûÇ± Ff<K×)»ð.ëu8[†H¼Ÿt&ô—‰üGýà~éLCL»¿¡Bl…pnªŸ…_T¯èú›RÓ ëoê4Íå>8¯9˜¸±z;ÎÂ«æ„èdÞÓ°ù×ùHÝû~›æQ©{`0Ë³â» F˜V)Z¾÷ƒãUŒ+·k5»æÝ‹ÂìÙ
…­fDw§ËŒb£5—] î5Ÿ¢l!ŒËÞ9*J’TB»7#±èóçÕ£…õÔ)nP‘ß'¸½Zù}m¤Æ#5XJØtb]ãõí%&†‹yÂx+mÁµ{»]Ïýn‘¶°<fYüvDu[¹!HEGë©SÜlESÁ½«jŠ+á6[lˆmÂ¯Z¾Ûã7ÎìoìœØ³['
Ø¨£¶¶¶¿8¬Øøi\L¢
qXï÷M3Â´Áˆ#Qä_t®9nX–ó¤¸Ã*9ÏruZ÷ØÈÒ·ù8‚ÛÌ¹ÅTØëÆî°KÔÉæìÈ¬îÀs÷ƒwNÁQ1†ð÷#X4fÐÆ1jÏÁO\TÑh·\»6•gùuŸŽÃÂ·3ÿzæ25ÌÐ¼ë›÷I„ºò%O6ã™Y?À
éG,"öý¨ÈŠ˜DÕˆàþE¦ÄE¯wUÇk	÷å±·àö9]ËÛ•p;ÂÍ$YyŽvRÙ£rÑód)IÆI]7H~€›Î)}ðñSï~ì%×ËÑÝÑô¾ÑmC·SVñ²°Ö¸¶¹?)G‹áÉŸ†á=—Åö+ìÚ^?žLsŽ¯lZ›
þ	o)j7<ª+Ý7÷ªøð<Kùè/ì¹Å˜r…='Ü¤Ž=Ÿ¸ý…9ky§•>XñC9˜ä=}`©«Gs[ÚƒUfä"
Ù´n9ëOÔÈÓ%|Ë˜ê–P ß7¤^¬ñ¥A·[U„“†¬<ëôV
¸ÿ@çƒßšûh=ôì¬OØÕã
'¼s‡g60L®3Ÿ|Ý˜³BLˆ{¦,\üÅkö–r^Ä [`jÜjx{n²ÖµmûóØŸ(Ö%„ÐjW°½ùËYëb®ÜÅÁ¯[Ëx]‚2øk³	[¨B\ì‰·j¬–OqãªhÚ˜*UÑtYR…S—â¥<ï¿¿änF÷žm¸ÛÝ\;ÆL²ÛÃý=Ä-;¨ýš_à„$ˆ¨8BÜ ÃóµÚUå
ÜUÅ:‚»¢XW1ãÖ™‚;k’“CV‘·R80ŸÊºYËÖ<jÏ¬1vÖÌŸÕN
’‡4‹ $rå#È~Ðá>ÜÍ»©hS`¹wŽÖñ¾W•ÏÏ
kŸ¥4;n=càjkÜ?o"s¢çIìs“ÔcVâœ|Bÿ`j‹*îöÁb¶z4ƒŽw¢ò<€¯&Üb¸ƒéðí=`? bXÚsÑX[ÀíW
~BîV
~—‚L±»’Åu¿Z?z—«ž.‘ÊÅ­£tžž>yÎ$[PÉÞÇ‡ÿõš©¶]Á4yža¸ò
?xŽai)6'¡Ó>1×UÁÖîY'ØÊ—÷›™0$*2ÌÌ%SžÉt`œ£‰ØîäO,¡,ÛîWqß{lþí®!¦7J0ú3Ÿ 6›r,ÀQ %[ÍR¡‰o§ãMÇ¦i€ZƒÇ½'JçËrÃpãùZëî`Üsf|f¬</ÔK‰Ö€c:xøÏ¹Üâ0´#PdEÓÛlš"Âº¬TPÌ0Õ¯ÖPÕUcû]/î‹‚Vª­aÔ{ÝM®WÓ¾©ž–æ§Ûÿr›âß’!ÄB“ ás_Üëˆ¥b~ùhñ_ˆiZ‘¢˜‰~¿dŠy‡¿½d
½ì,>Üq2uõá‘oíåD¶õùz;#Œ¤ËsMüô¢ØuÁBšÁ¥ºN‚ð~ÄÑòa +’nDPñ—r¯>AK‚‹:Aãö”á%ÚI³wÆ{÷º6
ÞY•SÇyz†ùôžøý„ìÎµ@
@jì’¿f‹Ýaiöƒâ¦WLâÞ9%{l•žŠ‘ÐS›ðcï%Çjµwó‡Œ{Ï6ëŸ»Üb%:=QGºŸêñœ/V+ÔkÞ4[(¢‹,ûEÔ¬8‚ˆv‚"âÚž€nš# u¶L<ÂÔ¨ìªHã+Ëe+=<ê@ßi‚&7»AW‘n\rxfúhh<Ô›5ý´žè{Ð´õ‘ù ÅV¦˜ÔFLÓ]Ïœý4J]\@báîö´Ë™ñÙï)kã¾/Q’¨`s:â¤s÷‡ê¹;^žžv”ˆœU¤­Tþ È‰å#ºò›G˜ƒtÓDé¥±
ZIë„F²]x° ·»ð#›‹¸ñƒíøL7ù½‡¶?O¢ùã6j´Ïr	ÿ
t±±ƒ:¥×6­¶á2åîûÜrU÷}ùF‡‡”§hsW†²QyØ¾ÞI
wë„ []ˆ8ß?ò‘žÖÇ¡.‰gy–{AkJ#4êMJ6—jxT$ê>y˜õêÔyœ7âý²¼v“Ö.9õæ§¤JOb. Bo“å¾€Óö“‡AÜ¿ÓêFxš¡XáKOHÇ³±ØÔÌÑ
pÓŽk
–çV)à°bnõ`×œ¹žz=äëÉcë=ÒÑdê÷º±fê{q…,±Ç¢ýv+«ú¥6à¡º,øÏaÅÝÞL¥¡ÉûEÑŒeSÀä
4Jì?Ì¨`×·]-[;£\Ó§ª¾tP+ˆÛ„íÇ÷t>^_ì1ë&îvœÍý´Ûñ†´ÜðÁ‰¢ÀqoGÒ
bSš“¦@Az©Ë!Ì
!ìïºz®3k¯#Õõ»ÌŒ÷qwéjHø1?C“‰´‚x7áGÁn˜ ¢=+<‡q‘žA i± #7VRn3T)·—Ìì-eþÐé9GgíƒÔ“Sð¼%'Þ9í´å}zYŒ†-uäL¡žâi†•¼Q†¡í¤/CÔ´'‡R‚¬Šüƒ}5ÀþnNVè|X÷²îÕ©¦^ƒI”Í²Ëè±vnœÍ“EÒòû5),+E‹è+ãŠEp"	wXYr£M§Ù0m[(—½‰1Ê¥ZeovßëÅpû¸b‹XkÙ?¨–:rS®y.:;Ö£Ç
{š’~^ŽôhfÉsÅ,Çóøýˆ§e#ž¡‚fts~¸YyÇ0­Tí.ö`ñƒ…œõNÏ[§¿í=._Ô#õx\O‡joí]£ø²·ëƒ.s8ÀîëMB
t§ºHhq;Õè)èŠ…œ…Û©%¾w>    NÀQõƒN4ŒÙY;¾»œiOƒ«G•“¸xûXëy¾ôê‚.²å´}VßA#š’"3fˆëi,MNA3å¡szÓzÕÐyé¦w¡Œ¦ê®Õ™‡ún
-ñšŒä	H{-4—ï=Î§;~ùLoõ¾i‘.<"m,û¢C/þÑÅ`ÐA‘§ßts²x ¬­Eý­U¥­U½b¢]nN§½Þ£=éò
šN£dÅ
îË}`¤ÂA\]ˆë‚&—M¿iFàxîíˆ©ÏeàþE“RAïž‰
ês+eÐ)³Î²É£ÕoÉs»\®…#’aÒÆäõ].ƒîƒË,C©çš
d˜¸c,~n“.N^½hÇÒ·Ý´#‹"¦$¹±ÂVTzËþ*Vú×É¸• vK[
<^Óý]ºs›Svsé¨K—ñ|útÂšˆ!­•Pg,røýˆ¦™i Æôm7ÏÁ»¼\ ¢ ûU¢²èK‡3W7¸Á2ê2äNÇ~nÙíé(]ŸgÝß§,Þ4Å| º i&æC„3ïVBú­CQ ÷¡•Íùd˜W„¶¹Ø¡íç‘&v#ï¥§Ý·}5¸e«ëÍŸÌˆsÖ<Ü½h§×MÍp€§ ˜ß0Êb$‘*ó"ûj#1M¿K+ôn1­Ô»-Ýçy«»éÞëÎÇÇx£Þ.7Ai'ÛÎ—ÍãÚ¡p¸ÜÝ.á‚¯Ý ^TyÈÿÃ‹"­ð|®ˆàâ‰“ŸàäJÙÆI·\BFiÇ¹æ©ÇVÙè÷¤[/OÅd”˜œäôÀ™b¸“Ët·éíÃµª<o“LS×3¨õŽ_µk–ûàF"~?h9Ÿx$A$6šmN6såYVÒ# ©–’^œÅlœ—@ZðFò¼í7ÉqjÍ½®“áQ¸z¶á¶—\Z+EóBr€GoGôÐßËBŽð.5¿i%/7hPÐýªÒM÷­teìVëˆÒ,Ê]/´•X?–3'ªÌèd{Ùh¸ªE6)²bw]¹÷#Th8a,
tód\®0¾‰€Ö«|Syn)YÂ…ÝY?únë€SÓ2eÃØÒ\‰_œ£Å|7ŠFfª¶&µ¼ñ
	9_sÊ¯#:yŠ	4÷‹›f*(]IAÞošÑž÷EÚÓÕv;ÙóËØûÙcÑg,õ¹]Mð¿Ç‹i­úÐ
ÝLˆy}á ämCLûÂ1'P½ÄòÍAÕì
ßäUIð–@ƒ.ÑIÜ´UMŽÆh§Ï³÷tÇldÄQ÷q1G}}tyÖ
+ØbC „,áçÙêâ¿2²Ë
Ô!7­Ð^ZnÃ	éö§Zm8}>öGáª»tùÄ
mù~9>ý˜)†îÌïÇíífíÀ)
5AãB[À¡WþâF©hy)B"¥rø®ôŒW_[^öñÁgÍVOñ¼ÉŠÑ´œ•éd”ùCGjÛòÔûvÙÿÒ¬ñÙä
…øíèµæ‰®õb¨Á›ƒö*ÔhYªTGx }æF{UÒæRgy¸÷uÃ3Øí©GKazï}vU©î
´ÅPyHô~$Ò:NHž1d~š§²k2å~VÇ5mÎh¸±Mÿ2›Ë
Ïó£–ãì‘ŒSl=ƒÁà´MRw€ëz®©hE!NÀò|ùˆ%G˜C4ý›ç0	èŠô;]K6’íÄ 'rd óåð¸;·»seo&‹¤³å¯X—ê¬½i„ ßŠžcš i¼Ô‡ÒM¶ê¦	«ºé’Áš÷Gq§'+Æˆ](ñvÁÎº}g±M™î©}WƒÑšËÁÓz2ãzÏ»hÊ C–m×xa&„ˆý&l³±¬?½h¦¢
J.Z¯ª‚–‹ù
Ìë.–ëçõ†mæ™âenîGr&-Ž9/XMÝ	çY­ºö
äÉw+üWBðTÚ«Ø=GÁYµ:ªÂy›4öÂç/úÅ—ez^GËN”H»²HïBâîó™U\±M‡m5{;âi6H`×h,÷OA³å©Y
Ú®šš-Ý¨?æÝÅzÞïŒzÙõÍsàÌ…ît°LÝ¶Ó÷ÎÃ¹·ßòI×­G°XÚuDÂA,2¢(¼bù"¤FÿÂHÃò6M
Ú­Ú¦Y2Òúå8ÞzXK´UcçÎÜ6ë‚ðª÷MýØ•Å'‡fÃàQûCÐâ»7…Ê"ùq 	æ_0i—7RÌ»ª
ƒeÌ®5àí]3®yÆóu"×Pµ%×ÏAÚƒ¶7çoÖuL]¦'ÒÔUñå

ÅÇ)½ÂeµÖÕþE`í«ø¸{~Ð>uýEàS«ÅGq_Y:z:²-ŠÝxà(®ß?ÞêŠ‹Ziæ¾Œ`GTBŽõ²Çbsà!CüPp7¯ÞÛô8«ëã›ë.Á4_2–q®¢™Z;N¹øÍe=>,w“1¯ÿ_ë+]#&¢ï€Ó…b´¾ÂÐahzµuåñk&¡„°˜I¨ƒÐ—uW½a$mG
FN2jsƒ»Ø†ÏKÎVsòpc`zXºZÂ˜>Œÿ‹ó SôEŸ$ËÐe§/x 9<;5J#­
×x¹à÷f
ƒTYõÚ~²0ÓtÙîÐŸŽG'ÌwœñE±»G±><P¬+„—K%áOsx ÜƒOáyÿ2Ñþ3Ë+m)$Ú…
W‹Ç©Q¤,lâ³zûåÔ0Zr¯3T8h—áU¾Ï?‹™vq¾";ÔT}vÚ¾ÿÖ—Hia:¿ëK°ç½`bÚíûf.«ëü¶èëíE>”vÂe7jü>Î¾»Úœ+ UÞ]&#ÐêF<ó§…5L±¹©.+ Dé	.=°*)ý»»¸›ÉŒëÌ×\9÷³ýÑ3Óh¢M‰£„hüô’èvˆ±9°óO
iaµ» à¨bv¡c–å?QÑ	X(Kˆq„Ò£†>Ò¥l– h"5¯€*ç/-¶c ¡î¯ZëeKs‚­ºf¸¿L„çÒöÖîú 7¨«Zu@¿ôÈ]c²Ÿ:k^G€Æ³4ûÆ
Ý°ÊGA“0ý}Å6M¬n^§G£/ÅÜ¸ÃÇš`
žÈÞt–ÞÁ:íZ7}wº¥¶~±Ü¾Èå—bj‚¦íªäqó$`EïG´jmsK@7,ô ³RÚ¼ ­ÔJ›+Q å–Ñ9Kk‡o![ÚÚ@²ÔîÝð:½ós=5k	øÜ­
ºh)b `qhòò1&‘a
¨aBæº”…z®•…êÂ…ÇY¯#'ËToÅ¦u¬´k´ZgÑYôìöV:ÁQ·Ö7ý*¢€X^D¥ç]dßs€´ˆ¦Í_ß´ñ^¹}Ó Ž¨Ýl8õüXè½Ûi± z>Õ™—êPg;íív?9
¨÷èoúvÝoºØÅc
âÛ[t2 ºØ„}ÜP˜´¸i¦4GRÜ´^µ8±ô¼½»–2ý›÷Ä»•£
ãeÈ‘e4ôTkp®Æó|`îÍÕÓDuoš§Mæœ px Mò Ï bØ	è†Ífh¶¤B[€¶k©ÐšÆé°òØC«Ç ­>oËnòÜ÷ÇÏkcq7%›IÖ&Ö5dô:º~–åÞ¿iXä¡È †XoÜpÒàèŠçmRæU#ßè;Œ
­ÖÜ\÷uyäÊØXœ|'Wž¿f‰˜H<Þe&'uAÓmº•Ha4ÕJB[<ï†Ífô–‚
ú_ƒ‚¯7Í•“'p¼ÜVZÁñäº·øãF÷ÄÄËøLë_®ìP=ÖµÞ°ÐædÌšÆÑ-M,yÞ""Ý°ïª JkÅ
Ð^ÕZ±èmçÚm>”‡cÓj°ñig¼Ëñ}.Î÷—hÞî*÷^ÝošJi³ä¦ËÜ±Ôxc°´ºAÈv¸¤0R`ÞU)Œ”^wÛ™)º¢‡çüÜùn Æ;‚‹:š¬Õn9ß^]ÌÅ +†T¢òýý·èóx‘Ú±†s4¯Oº4˜ðú¤«Ê{gýÞvÔydÎƒ=„ú±¿÷Ã6ßuä=ùÀ—RÐŸIµ²y]ÅÂ)TîêS±èÐ$0AP¤«èÏ¤ñM“ï éøI­”\ÝÃ³±›ž˜ÄW3éuSÀyÓ¯ g3YK+¬ýT7ù7]¤h}7Þ¨­Ä°
ôy7)@§%™áây‡µd†Yõ°PØmæŸ¼aœºìˆË=AâÌílù=Ï{Yr4Æmã®ÔŠ11®n¿Žh¡—ù€ˆ&ìè_°Ðæ *nZuX¨š`ê·®ý(\éÛÞý@|r’,o#|áž}ûøƒ‹ÓÍý,Ôý’%‘”øYRÐü âÉO„Ü4×P„¡ J‹>
Ð^Õ¢ÏòÍˆõ­ÈÉN{¼tRoÝ³zK=k ­l÷<ï»‰E<¨ËM(2áC +¾’XÜ/8HˆJ5„¸JåÍ÷]Ïù»I"ã…´ï/˜¶Ÿp—$ÁHðÌ¹Ë²yÓ[³Ïí½‘Ö'ü—¡«zx†ç øÏÈ‘ 
ˆ€nØmV€Æ%]Ùô®BW¶r¬{ë[î£¥=–÷öÃ%¿±k)ïÝî`¬9§Ã}ÓªLáBáe±øÕ^š°„TCð˜|ºlŒ™Ø¦R
bžJµjaoBüq~W®Ýù±
/v2å¢?hé‡ëw3´gÖûã“T
sŒn° ûhñû¤o rPäXºy&¬0È¯û_º ßAËó±•‡è9þqç3”0÷þó8¶Ã”ü–8é ‘~Zz[® )ÑâH®ó5}Ä5ÔRu	ITòÒ¤` a“j¬~7GÆ*ÃKg©Ìd~†Ù;Rä‡&>o
˜Æ{c›ô¢ÎÖ³ÎáÞŠEéŸ6Xb> M_TffDB‘{&†ìÓô==â
uF*
ŽÚ¬À5Ž¤w´1á
²B3¶¨üˆ?Aæ¦ˆÑÄdé@/Ý\6žÞ
I
Qµ¢£>d¬N~ïY÷R†\q• PáèF<ˆ˜?ûi×p’â
™Ò²4Š+p¿_–6ï»öœ‡]½½…[½]]ócö1½ÛÊ>ØigÂ“ÞÕ÷jâz
› Æøç‰6¬q¹ÄàèeQZØ“ÿMEôk
Ad»Á00QtÎõ;Ö‘G[Ïƒáúžƒ¶w¹Ÿì×6Î5k Hh:¢ Ý3Â¦å¡–-Aô¿„ØFOqcrc±;¹ÅjÐ‡çGË>yÀïJÒÉÝ·Þe÷œ-éÒä7åšo Aáµ
P5îZÃ
~š
+¡åá÷Ðì¾Ú:D½]g£hÄè­e/LtÂ`~÷Žçåc‹Ô”9Ü™°†(ÅŠåÜ+ˆÁ,p5,û¸p™Ä*O£’Ä    ~^Ýv<r§k»ÝêøGM•Û;-4 C'[(ë¦=Æ9¬Gmc„s}\"M 1æÿÀjê,1J9
ËßÚF't†²¨nðÔæ“N·sî.^Ï<ñ$êö¬t:ë‡¦ÝÃÂ†päùÑXùßÍ=Š<´}¾ ÖPª –•Ä¡
`Ö÷âP\jÌû Í&Ï>”/óåêq<ÆÉöæiÉdç“¶äïKEÓúŸ ‰o(|ˆ<‚¥#TT?h‹<GB¾©Ÿ#w¸4"N! Ê÷#â0Ê3ã(õóxrl¥;4xþlk£i„FrXá¥üD¿ŒŠ¡€¿\ßÔÕQÓŸ–Ã
hý
ÁðÏãþáœÓàò¸Û%b<Ê­XàÅÙ¹?ÒÍv»Ÿå÷¶1^¤Éh Áo¡Ábí	¾Ð«îÊ7ìA+‰¨¼ }¿jIU¶þÌ{@CÛdøv<ËÓyorPn°÷“NfÆòyÎ™ø@´ÏL$aâKBE ÿOlmÚ‡¥å¦šI»ªyN¿OÚ
Q””ÛÛKG:YÑ²2ØÎ£ñLbFûÕd›ãSÆ³Î|‹Wï²¹Õ†“¥Ét(	ÿ©–s\sîe=²›#T ßº¹Åúp¹Ë~˜6ûÝÅ”ÝÛ¡7èk Ú›ömÑç\!]Á,ÔjÒè‚+c:Â/2Â×
…´úÀ 0Oi4qð¿ð€åÆ‡Â~ßø0‰¤ã™™1-±.ÄCdQLOn¢[[é~µu÷Š£§òæ*þÕÿmÝÏ‹è
, ÅäBaÈÓmÎÐè(ä»úDñtÝïÕ'în[šŽB.¯›øn0þ@\[{»{,¢‹k£
ÛRWÉ=¤ºo¶¨–	 <û†–öÔÁ!ß*¹Z¡9¹™ZY…y%¿f}o^G›Ë||ÒÕåšÁ”¾=m6ÇNhG1¼FÝþÛÉõt¡¦¿N$ñç
…ŽÀù´9°ÿ¡}åyã$x“C–=x¯2/™»Y¹Êð9ž¸{~8j]Ü?ç 3jÖwSƒ0s3¹µÌE()öÑþO¼/P<1fyòé¾HÐ˜ÍÑ5é¥=—)‡{>á<fÇ+ŒkÊ¸vé$LO"±·ü¤å,äE§uèfûŒë·PM«T@CE‚
jÃ½€À5
éÊÒò²@¡+Cª–—•‚BÜC7ô4Šsâö±,cg|‘œÚê‚Ap¶1E]D·S­î+/Ø…†g€øò'Bsã:Õq…½!_ ò½½¹Í“óýŽ—Žx<>V~§çå½¡„×Ë½mŽ÷'”ûÒ8<¹µýÉ§ÁQËÂp_.•6Ò¨E–üiÔÄ
MÙZ6Þ[YÉ”5Ô` ‡ø¦œ:§,ò}>Ÿæì†YÙù*÷$ÞÒÞö°§qçŽöÿ¶´ä>*S”¶8ô‡¹8Õä-íœ+À);ç>Ýg7‡gÉžœtÓAËá` ØSuÁß¤Ãö&Áé‰‹Ã
„Î‰kø*–ú1ûiOÀëÑ(ä0­å	9,¹ÊòÐfÖý>èWéÑ¿»áÄB¨.g63ó’yZŸ3%•±ªŸ9k­îœü©¯¾Ðjú7´¨È|#N`þÌð‰SÆ”ªÂ—bc–ªÂÏÛèË–
˜5ZmV—$³ÛsspÏÚGwëŠ×£ÜÞÅGïoÂƒá 14• @Q]'´• û'?#6l¯¦ tPZ~IAÑ [ÃŽ:H›Ý6~`vMgcÔÌòÚÁÜâÎ5Þö­µ¸žäZ×«™\+ÒL
¤eá§Æôˆ-œù]‡	Çv&àž—Ë7äŒîdª|~5Í§ˆ¬i%çnhŽ†½9
/¯ 4ßIÑ¾?îSiÃºÀ_èh’ þå"ÅÆ,Ž ¬Êå„ÿ#—³é*Æ]µÜ¥,°íý%•zÚLåv\KîK¾²ZwkÇÁ®ö8×y¯ì1ÝÒñÁÐa‡WC9áé¯Í£™(CîguÆa›¦®jÉž±fã ßÛ-=Èƒý×Î¡Òþ3nK¦žß Â£
˜é^Òcñïà•˜w¯N¿¼Ä®üÓV˜è«ó¼un NÜ9œOq{ÁìKëˆª¶ó½ÉR¹õú¯ò…Pø Á˜?¹ÆnžÎ°—Z(B‚¼ú»ûâæ/RÛå»þBŠöä¼Å-Béâjwz×íé’ë#[\Lú«l
ÅÂKÿ–¿yáŠ9XB†¡|„˜Ž¥jws@q—¹8Åý}¸|âeÙùãl¼FîYZ@Gði¦$¦õð¸Úùý‰òØþ`1ó$ÊÀ/j#6çmíVªz²»~ûz¡ü­?HÓC°SÝ»ÉTTXÇ7{ƒ$D‹Ð>Èò¼Ëªá±ö…¢bB‡°h±%ø0ÓÜCtíw)Ó©—Vw•~ý$í´+œ×[]÷/²³]t†•f,¨‰±J:â.tðŠáE$Õÿ$-?1â 'bá5Â‚™†3HaHBÝ
„
ë œŸøG›5ôãÝ|ŽO+c|SŽé€Xeô˜
ÕÓýÍÑÞ4Aù	BXôBCÄ1è«Å¥I»b## øc¦9	 ’uïÚ›Th”ÈuØÏÀßl†º„5ånõÙÖsbssþˆ®“íäòÐ4ýÑf¦'”yzï È
xtr’ö¿l\<%¯7×åRñ”¼^;­S<u–Ž®÷V­íZY
Ü
$‰›ùcé^–Êy<MÛW…q¶öúy¬'Ó§
hO• ˆèÓœ:=âèä #|@r¥$ÁLsšÛ@_+@/6ðòjmç¯°óUtbûüt:7ó³Üá/0yNÆì>Kïc,‡§¹rïìÛ“2­­†Íý™jÏ‰_øB"ˆ¡ÛpxBj1Óœ>ä!2ÊiDâjP ¶Æ…r1’ØÅŒ`M¯üÔ~,|oºÛ<R!”æÃP›ˆÑQ×…]`+ÊY„}õ­MuÑYRò0½íÆå SÖé†ŒwØX—wàÛü]ïl¯S³ãÈÏ.?œ.GêÀÚäãu"N<îá-ÎëÁH¾h“åˆû¿üK™ù»þë÷[à‚|‘ÀË67'ñ¹Žô24òkÒó[hÁ0˜XëÝÂÞt¸ßûÔKfƒÞÍ!ÑŠÇìäãùù<…%hÕ<ÿ)s1 ¼eáõ¸–Ãá¦ºÖô*w™^a‘IŒš•-ò'¼¼–Aölôìtµ0…Ås|¾rØšŒ<üˆcsÏOX‹C,:¬íšxéængs˜î{;Â´û½Ð4ÉÛTÖºÀKþ]²Ï¯›}Û´s½Þà±s[¶o¹Ä¥Ïh=Ä÷µ8š½!ÛMÛ1É«==ª—®RD<„èÕŠ™æùYÚßñ¾µ°DJÕJÔò\ópd3Ž›i²9[Xµú@ØµoAdOÇÆÞ’Û­„mAGšY?¯yºß‚–gYþ=‰‹æÚ
x‚œoŠœ£Š*'5FÿVåü‚ü¢ÏÖ³¬×5
u§äÙD™Ç’æò£ Î¡¿&z«8Û“š6¸0Ht[ ±€ßaëR&á
±Á qvÌ”É…—2…ýýC¾skä·,ãš_–ùi¼æ³ËnÛ·l+¾í'‚Úv9˜·ó¸¦¡z
’‡LÕn ~;¢üùQœH¨#hœ¡')-IR¼Óª‘Ÿð¶Ókx
<ÙnovâltžÙbf,U^eçÛÍÂðR<l¡M"Ðž­šx©‚¦@@!(roGˆÊ#1äUƒÆ~ÈœöŸå™å¥¹ù]øz4Û
é½³¹ß¸öä:¿ÍcÈµ¦“t5¿9ƒÉA:°ñõ:nm¸]	Éóâ+I†AÓÒ_FH"(Ï÷ª]ömb¾ï¡©eØ­T‰‡¾·mq7u;·E[ÖÆ¼údÐ˜wC‹'.ùLE–Ž}°°
üS8PÂ b¨Ê\©iÙ`ÚåF©a²Ÿ“;„ß~Š¬q¢ƒE€A!œJkíÊþlÄm9f4ˆcñí£³±mÕìŽ) A‘ÖQ–|/dMÛ,²¢k°©’Û¢¶õ»ÛZòÏEŠ× ÆÝ>¬aÈÇ«s>ìNgÝÌßßçþò:æ£»Qü^Xø7\ ˜ã…ÿŸ´7ÛRÙ¾‡¯õÿ0 DCsîT±AéT¼q(*
Š"(ÍÓ˜Uc§¸ó#É1ê\œMV=sE¬Xíœ$Aå¡€?	ÿÇ5¦Iíl\'¤3 íìo)øX"WÏ
Ê"Ê-OmoÎ„}Ø ³Å8Õ¹!ž¸÷‹ô–5¸0ë‹‹]ÔRœýÄ'P|ˆãéüg‰Oü¾¼ZD¡øz-¢ü‰o|³´UÂ˜\|æ·cˆ¹â^(Œ»ìƒDt£{d*Ò|OS…(RN|º‘¦lÒŸø*Ý„_þ­I´¨k8!¶æöÅöYQz»öÐ)DÐÛeƒÊÝé¢waj_¹'4@u1|Z4}×KdÕ©òÙ÷Såƒ$+:íØ(°<.ô ?»ñt5œ ûÇUhO'igyƒŠzù2–:À	žÐš>áZ•E¸„öŽEøhÏªÀõ9o‰—=£8í¥ÎFê4[ð>{p-»˜øKûGÐ ÝÈÃgø
š>×%´
•ÝÚ*»? õ¼@‘t&Ó
úÑ°ÇQvœäƒþZ­CYs±¾ëý!(3
ð´Û´N¡¥1öò
Þˆ±ÿ­5
¢)‹INqì§ý åž±;
œ[<áø›ç¨¦d´˜ÉÝµ$2?}dYÂàX‘ÿCNæ3¦A(Ç0HDÄ–ŸsøM‹–ÚRÓ¢ý°HÕlµPøþñ´eîÃÞO|ÎoÜ¨pø4'v¬­(cÛgˆ?ÞŽ™?•MY†!óy>›v(&Tr¥˜ÜwR•¦ÁTÑ8WFÁ*ì_ÚÃ|Íz˜¨nçÆîðÁEV+Û3sìÖj”ø@9É"°~Îï`À7ÇG'vßÜ?ºÖY£Ë5Vwæbêû!ší³ÕqX³3Üd.Ÿ{J
wK{ï2¿=çÝÞðq¥”„ÈÑd‰¯iÓ‡âË«eeŠ¯÷·²ò|í!²RþHŽÞ}O%WŠxâm:£qß·ý0kKÎàÜâW×ó#|$f#™=øŒÇ@Ó2T‰ïíÓà÷¾ÚîÚõ¯¡ªÙóiz‹æþ|>í£¶”–ƒL['LïnäñëÒwÀxú0°HžÝ:¨¨iµ¾Fß××@_™Œöts¾ÎòâìÇ=Ž[yf?Â‘tûSQj_nŸ”ùµ,†ž*ÂÇ§Å`Óáò˜VÙê+1ïÙ1¾žÈÃš½¶mç*fJÂ±}¦ÍD5*’èæ ÌšW6VŽâá„Û?Â‡À c>ñý"X¡	ø|$    ÿöÙk«Qï>KÖ«Îê&ÈóKîÂEzZê¢9sÔœ®ku7ÈlÅ? ©ô`8þù€¥¹Ý@uªŠâ²ÿ¢¸óÕnñ‚›ó)?‘Æ³AxXÖ¨Ñ},®âQKƒål¸N×#½><ÌRx,Ç|Î;`ˆkïÂ•ÂƒuðÝâ-ìMðƒwœB°Ð:¶ÜXHÐœÐßëÒquÝÛl»ŠœKÌ=ÇâÊ]âûÅK>NÇï"Í"Hë¼tù-O›ûö1¤ßE^qkK7£mö‹nl.bþÄwnŸØ+W…!ÿŸ_ùÅK>®êþRrNéoº¿_ñÉjnôLñ²T2O¼Þ£«ÞçZXwîÄZ#×²½éT–…àé &ñšÿy>ñ’ó*«Å×û
«ÐW|ƒËtžK|Â‰Vá›+v²^ÈÃf{iÞåP-.²ŽFÙtXß“¯ ÐEM–{Ã`ãŸF•¸ßøØï·àüSÐ™LÔ|1²—©ÚnÃHbº–±t/ýù¾ðÂd¾n]åSû !F¥J¦½ýWÌÏ}bÀ!Z˜†â/ÊŽ_åùJƒêÅ_e¿Ô3·ç˜x ÞŒwhLO6¼tîkß:KMÂÃîi <Í‚—Q‘åŸ«ý"‚¡«¯ÃÅ%¾ï‡‹q§cv'òjmZ½iø0,)ûh;™&çˆ­ÂÌô¯ ?¯ýþ»RÌ,¥ýú©ü‡\Rò8
ð/"›1zSÎ%€Ý7åÜªA;ýÒÓR8èy–.§æVØ°wèE“kÞRT è,ïƒÔøAé?åê
Ç¾dö9rÍßÄÜ¿ˆxÆ¸:)Hq{o&ÿ0txOtöœL­ÄŠW‘ö¦sYôCaÓ7ÎªßJN`ÑÉ=©ÞDÙ¿¨±&
Ás- ƒ¦Ã)4ùeª›4ùÿmÓáK‡0I÷ƒÜßô'Çõ=QD¸ìµµÖ‹¸gäöÎáä2SYáXwæú™Þ£ÿAæƒ0€“rt'‰ƒ˜DbÒ_8c¿=Ê–÷}g"Mð)ì\¼¸Ã=FNW¾ckˆº~"ŽNñÆ6¥õ±s]…ë}_­oRPö%D’ð
¯w—êLÒ‘^†áü‹Ú¾«{S
äoò&7¯íÛh¼T›ht:Ã›¸–m¥?3vm`Ü<;:©xmìnµ
,í}–3ƒ<ú“ƒóßOˆö20 Ì5/ôÛiu¶üf¶ZèÁ-÷®Á©^‡§Ùè>LRæ><ö ©kßÐú±{Œ<NzÌpcâ‘ˆ‹øõ
6> G»£è5I‚ºÂ¢S¢~Ã<ú§«º>ÒÝ¸Ãi´ôlqËïq¡$0M1NÌâöÅS>_å.®d<1Q[2_øeÿý Ucg K 7¥O.¿«/Àµ¤RrÜ:òÝËÒ%‘•phí²…ÙBÿl÷—WwE'Œö13y?x“(8Zdÿf5äInì¢õì]ÖVºáƒtª Gø~DäÛ ØëÒèƒ`r˜&§`²› U×‡¹îÐ¡íº.ºôÃ$oƒTý½‚çéFä“€	ò_T¾ì¼JIXJÔ¿¡$üs“}=M
¶ÏZœï…g—1—IøPÆ»‘Î’1ò¾pïÊ¤5ú‹†¨œ„¥rí¥E1Ó<Š²‹ŠRF‰Ký›RÆ—(JÕ¹]»¿jª:‰–‹ëaˆ´ëeÐîNøÜlµÓÕ%^m‚®áIBÝÂ^)Hž\("ôÙ§Ã¿èÓÙÅäM ¹äøÎn¦‡W<¾äIqäL™Õïùéßë¢,,k9X2¹y;¯Å%þ0®T• ,Ë>8~a8æ]kUóÇoZ«UÃ­vjÑét½ÃfûP»+|Ëlêf¿¬µ¡µ
Wº&¡Ñ‹~b8ž–Ò¡H"‡Ïƒù
Wc3oc"ü·ðþ‹«y„s#\X{1E÷ÑÎ³»f{ÆÐš?` k‘5_î–Û‹Â-5µkþCˆéò+`?›=ø%07­ÈYR„EðVÎòÕ‚ÀÜŒ®¢54§¡;Ï JK
¼Í®ßV/ØË,.ÐÛÆ}`¼Zð}'ë)‡Æ|0€gÑç½k<’BÀUõþÈ_ü½ÞßŸÿŽÝâv:Åæ°]ñm	¨ÀñR=´“v‘³ãýÕ>ŠèÝjŸËR;
	$ÂC÷	ì…/—y—~MhÁ¯Æ½k…é¹åZ¦în÷Ù.YÎêÇ÷qkè,Õo„©ÅôLÀ@§¦Õh»•ý`ÿ§œÒç§§BÄŒ@rmü‹j˜
Þ
M¨w­Ó·»ÅÜ:V/Ým£ß[ž¦GÊh¼rzË¿®  ÷8·.hø?L^I@Å^?ñe8ÏcñÐ¿¨¹H«°©SÐäÔ¸Ÿ“7hó7«½š[’G3gm]Ž]ß;œö&fÛk¯˜+ë³ýhÕØ¼ÿÙSó‚O÷ú‹”“nT¾)‡Á÷ÜÌ g`6U¼(f<2Â->ÒQ€wÂªdñh´nã×‘ª¿zHÇ9FEðòéçð°Ü¼'9XcSZíT«Œ]«t
Ö¹´hxëæknçuápÅáX¢œÍÚ›u.w€ÝŠ-uÚkõýÑ£v\hÑÒm-}ÆåÜ/‚Jº[±&[’îÖ(n^Úµ;‚'E@/${lìÁƒ¸¼Ù­3ÖÝIwýè	ÛRjÏÉR˜ˆ§k,@¨"GTjT„˜dÕÜ/‚»à
×R	ûûåÑÓÞ…¡i·§Úí6ÓUçè)ãÌBÝÙ^[‡s³e	ã´›Øì|Q;¸+ñR
âuÐ«ÆB™  ‰Kâš
<”çøMW‚žãZZ Fz²øzâó‰–õ§+Êºƒü:;
ÀÄGýBö†6Ÿè?Àè»ˆ0
ÞàFN¥ñˆânºlš—ÌoêEª³Š‰uyt•v¬"wY|ßàîÕZÂøôgùmˆæ‚Ž“=;ÈË¨ÖW‰
”6¥SiìW·Unò1”‹åi‰›kº·FÌ­ƒ7M6¶¤Ü¨{?š˜Îa;£Ù(Š”¶_²b3÷ÐBÚmglæ_äljŽæý{]Ø%6–£ dg/Ÿ(©yx9† ôZ7]’!°r¢«ÞŒ¤iñ¿“/ù»iÝ¢­°ÚÜô¶—-23ÏÍ³æ5pÎåÞá2­2Ûþ
6ÁF#HðgÜß˜¸ RqUJ’µYö÷”œ1ö¼5‰N÷¼uv}gæIGˆ{f{à0¾£ß5AÎ†êFqÍµ<TÎ¡ÓýŸD7¦ŸQ×´Jò„VqÈ%´ï™µÚj«Xr‡Ý'#I˜fcÅ«ž¸ØáòŒ'lº‰.F<h¯«Û.ßCCÜ ¦;–Ï'¶1q	­ºéQBû~ÓÃÞ™Ëd{8§Å¦c
—êÙs5v3‹nqAîhj\« Õu?mÿÌj¥0!|ò,ãÆÌßÅØ
˜*Ùù8Óøw ÒnÝµËö¾ËyrÕgI&øç|~!Ñš-\Äýyå·Kù%B%D™‰¨X7ÕH¹?µ¡P9ï…ÊÍw@?S6
ˆ)]F«ìd¬t_ö»Üôêô¤ÛtsòEzŒ»ÊÒÖ¯«ýÖ™PÏ«¸L´¿G Æõð>AQ–ù?›å'P°Ô3q ‘g¤1%%%²£d8.Æo•ÿäØÐŽƒìO&¶ƒŽ8ëš–jÝÑè([kŽÓ¶|¶ö<—jÚ÷íãy~ùDKðôý ÆE¬Hð6m$ãBñXŠ·°k‰ÇZžÔÝâØv£³zÙœ]Î[èÀùNÝÞ¬B80›…Ú>ÕUÃ¿ÝXªJIU>DŽ¡¿žÒ5c'Hè–Ýkj:¦7TSÓ?,:|( ápËÉÂüÅUðíô¬ØÁu

Î…$è…#(§S­­Â§ÙÊMvÈ"ôç%*i›˜ÿ‘(ñ‰ôÿÁù·‹rê­ê|)SUú­ó}pø.½›±ŸùÛ­ºžÎþæf;¨Ã¦gËÀþF=sÒ<oÕZ þ÷ÀÿÙãG”?¦\¤$	:%°&x›VÏ^/­ò4Œ‹	åöÿïî¢Î7á>kSÑ+&pšZ‰¥“nìlö§˜‹[w'\ÛNÝûEò$Bþ«}Ñ§â3G®,åoÌÉ]ÐÖU`vL[ÿofÿ\9iåüž%A^¬òc#¸õ“JúvÛ
´ít-Dxdo–Zï½§Ó3jLÈMslP¥W§ücö÷ôêË¡èòp–OÍé e¢&®œh¢í#i]¬„ð’sˆCU{/|•+9 ÊT@ƒw
ž‡è9­Ñ˜›\½qö&Ô#Ž·ý}¨§§çž]óëô7ºvÏ£ÍdU<œ¯ÞlŸÆ#%ŽÛ7þ•ŠóïÐJ©LJ¢ÊWó¬ð6&5¦;¢l•æwLÕR¿§ùUÂNg+Ÿ– iä_RÏ§”Yï
e$ì’‘ÆŽ|©»îÒHY$öÿ! aKA›¿Â‚4Ë„Â Ï ?-&4å3¢â.oFþÆèýÈß»ùš€gž­ƒ
ÓY£ól=NÎ’½6zrgÔV—!0˜#òf^´
ÿ?*RTR‚ ŒEü€š’´ ¯Uü(¼ ÖyõÓSÞÖ#lV³ÕÀéèE=œcˆ®´ÐÓUŒüB6E•#îoðpÉÕÄr‡ŸO¾Ð´Æ”Ji•n‘NÅÄ²:ÓQ£Û~ÈÉ53ñAN30“]~g­5¶Q¶ÔŒëÁè"3Jk5ø³xK^<²tü©DØô‘§K$yudZÏËå™ïÂÔ
»[¦æõd0–u<žæºŠ:“³\sW¼ÝßNÂA½u:+¼šÿ%4º7Ã}0Ä÷Ï”_h‘RhYU	ŽBk¿U‚{5^~ÍG›±î¶'—<™®Æmw?ŽùÎm)£¡{ìPvO g˜ÜÌªñÞžÍ'<â0Ú5‚/Ÿ(—:"9D–ÀnÆØtùäÕ“RØó­'½íPÝ«¦o†ë”se™^×JGÿ&¨©>b¹±ÏžOcT/¢û
`|ºš¦Ï:ÁEB“JoZ§£™o¤—þÀåqŠ÷¶Òù¬yC8‹&¬ @ÔÞgI1‘¾=Ø¹yQócUŒâM¸‚ixFn F$ü†ès†¸1A1Á¥UÂ(‚ËR¿'ŒÚ»Ž2æoíuWˆ1ØSVÌwÑÙî0ígÝÁÁägm­Ö[ï*Qmò6à’a_>‘W‘¤Rþ,6}é)^\
³)^ïû0[;©ráì´ì3ÅÜÇCv¶†A@Õ¿g¢)ˆâ›Z/…‰©YÈ°¯Ÿ¨nEÉVBÛ ©šé¼[méôoÚDà]ïGØ\ÂxÈv¯çù|þ˜L¶¥¥<;˜K×ËY÷|²XMYôêã…"³9„xñÕ¾¨œÈ„˜ò‹ÀM+0¨†r°ý}(·[Ø!sT˜ñ¸‰ó{êïÎþØW–q ,<©ýË;‰ÜX-­•’
”6âÏžõ¿Ÿ    È3*ÓÓF§Ð”e©ô¸Õ*eéqßi$Wá6‹Evnm%S˜£ž
[Š·”k1Q<í^Z³9ŸY7¿ðÓñÒ¹á²îñç.8¦©(Y

 vnÑ5Í
ƒ^Œé¾qàXÂ­rŸnº·pÅÍ…Å™Û¡²Ÿ§â²CrNqCö¢Ïª„•ïa£ÒÚ´­
©ÞÁ×OS÷E¥ õ_ÍÃŠ¢ýF^‡À¶Ú*þöt2‘v[,‡é˜ÓÛÃV,%³Ë^Ð{Ø™læ?Áê
þ°]÷™-±=.ÊFŸ#±y@XØo„‘ÈE£ýïnïÆŸB#eR¸÷bÏŽd}¬™ÛÁc»¾Ì=i=˜.:'íáœ—¶.Ç¦L•ÔA
À'¼|‚,õÝäŒ3”yUl:]D ;YµO í7¥øj#_ó”~Ë–0Ü~Ún	©xï‹þØììf±/kíÎ$S®Œ»u5Êžð0½Â
ùÏî—Ø<v*()Z%Ê§¿§à€Éø†oë¥ê ÃÔ”œ…#ÍEží›]Y›=œNd’èfÔA?‚ÆÑî` ÀpÕOH¤-±|…šQÈy•ÅˆBîýÅè‹Qgía,8u ·º‰tä·gNÍ©6˜^>;µÚYw
D®gÏß”ð0ƒÜ“Z‹†YÍZ¼	ˆ	Bõû€ø"0-ÆÆ>à³Îù²åm;Jƒs›µî»õ¥{ä+þXø4¡Ôùþ™º‘·çÐÐûé~ß“FhØ›a}ˆäƒ*) +Za{à\åõ%È2.ÖWû±ÂOœ*§Û HÜô„Ö´‹PB«VLJho*&ZMÕûü*´ýn²€m5¼•uÎy‚€“vaá´{ J¿3X7ÎO¬F ‘D ‚×/ÂSÜ‚D"AŒ~qqUnž"öÞÉÍWnbªXpv
VÝî´·<w×mKÉ7³+Ç¬ü-“Öûð098Qrû‘{¥ðÊÐ!ð/_0,/‚ xóL¼p‹êÌNk‚ßÏìäÞeÃ@ÖoÍ,f¸èn—«Õ{ìqzìàÛfŸ÷oƒMûpóÓŸœb\ŠVÓ\¼úf³"âDð%œiQõÁJ¹ŒÄ®µLØZè²Ö–F›™È‰íh½þ)É.r$Eói(ßM~µ9/Õ!®;>þtL$@b>8X¶‚\(×t¨ZGLÝt¬œš:¯jdQS¿ÓÈªžñQ"àøÙùUp<ðýe·ì³eb¯S+²Îáý¨<üèµ!'’ˆ‘üô‹Íù’Ò–¿)ò¦SÊLIðøÆæK­5P/8ëóž¿Qj–»ÝüLžŒS,,%ÄÀÅc”uVábfüà1*áÑ¦ G…ˆŸ»yzW¸oD¨mõZ¢
wíx59™Y"+eŽ¸»‰½j/9ñ4TN`Æ·í‘zÑ„^ÿG§š]:˜Áóðk`,”Ú‹"ù-ñ,d	òæ¥a¼»Ï…ú¦üýçÆ(/ö.ø¢Ü»6›tŠV_â‰a1Ø9&ûI×7=®­\ÃèIÄÀ
´AÆÒ:ÌÿO„Q&ìü%¦'dTÊiŽ\s¹©F£Iä «EcZydê÷Y¨.[C•éb²Ûô»ÞR®y¦c,Æü@ÞÚ[;öŠºïÿZ”ÞV^ä™WcÃ’‰ãxžáÿáØ¦ãžù˜©®êôÏk­²xwß´%µìÅYOœÑÝ\«¬y;ÚÇt£­d¡Óm¾½0&u7Áÿ…‡Á Ék_êUT4†Žró˜eXŸ°M[t”¬!U“S=¼:&gÂc:fK/ŒÚÛñ?‘=.¬ŽãyÕÑ³c2óÃãõ^WT¥„‡z¢E–¸Wä¸T”a I‚¼i÷Ž"gÞx6‚|\Ë³M‘£WÆº€SÍRÃÅA;êÌMU+uÉ¸ýÓí¶?9ƒYìÝën–>á=ã/,Bþkv(–êòIùD²CŽm\»¢ŠšÿÆæ¾
êØÜ{y6¼Î•ËŠïoÕmçº·ç‹÷°\yqŽ¹KÜ
ØÖ¨Ú–ý+ò½æ$‡_lº&†©»Ç¤×¼qùJ+Iþ+‘
S’ü×¸æñÕ´{»$˜Ý#Q|W>ôŽû³ˆo Ÿf™¡Ù÷t<XââügE€§ŒqEJþbÀ}@
½lirlãXŒümñ›ˆ„ŽÔŠHúY!±
Ôî ÇC½†=Í[û½æîËùÌÏ;Kmä^Ô÷jG$ J„tl Ÿ}"lœX”“½UWÍj¾ýÆUÿ9Ì,Ïbý.ê»#gû¹šçV;™ùû“ß^z¦~\û²2tÀ(å ªX ªTNåcVdß|¢’eH$ÿÈƒ°r<½ê¤éxz-'Í7>s†x—‡p±bòÎ¡Ÿšü…íÝgã(ïf‰Ê‡êj8”ðXü”ôÄÄK¿ùD+ð²ðÊLÓØØ^Ze…×Ù‰|Ï
Ï‰Åñtä¼sÎØçøúpÃ6«Ì
¥³+‚$Z…Ì(Òä<O¿ÌüÀ¿©ïâ%¿ñ  E(|^Ô¦±¹:ªnZØ™f¹µ6-æ(èÉB_¬¡ó œóªÞÛ(‘3ÞÇÉÕmõ©—GSý6¯+0È•ýž–•’90àå‚TÔ
<ÈÃ
šÆZ”åN*=_›Îvá:c3ëm;€kWÛá›·öNÞí)³Öï²è ókƒ6Hî&ˆ«£oSxü fÁyóòÉ6 ÷èr
ú‡2Ù5FîÀjY– §ê6wØ•þ°ØMÐn­íó)N]–‰d‰ïj“m×*­xv>ï;uïñðèeå¿Cqt|ò¿ÑL’´š[l¹VéQäî®°*òÕß†;A¹™]#‹:2gšþ<by·=,¼\Øt]!Éû']ªrü Ò`‹cÁë'TòjAN ô´7Ý¨"~[‡ÕŽyt©O¯¼.†0OÎÇ»i©Š³qVgç™q»+—»`€^q²¿ÔÍ©¸Oµr™y]ýD_?‘ü»$›M
b9ªªRän-5C1k±¼/_ÔÞ(UmäM-ïþ˜]÷ìRR™Âé«Qgp-l¥·Rk#§ÁV9!‡xAøŠ”DáäžcÌ‹EÞ4Ì,m^¥"(m^K<Ölw'¬ÛëÓ«”^Ì@v ÛQÀ£ájš>—Zý»"±ŽE³I‘dŸäíbhà[“—”"Â_âë'pŽNÍóC
@hŽ›
sWÞ4Ú>­%å<ß*:„Ó¶ë†Ç“oŒKæozÚ\U°'}S[ôÚÅÕëâþ‡Ÿºwøå,=ŸÀ1ŒH/yóÇ¼p³ªæ’]L¤öÍ¥7£’öúkÎmŸöPÁaÄ¦èîN˜h&µÃãìâlÄ¾Ý÷ž•×NÐ•Ò)_XÊ/Ó_	‰Ûè¸ š¦OƒW
F¥ÁkŒVþÈšqWAQ6±5ì6Km¹½n”
6LÏ;ýüH‹Ú*ÉÿÞc?Xóøõ¤cž
“ˆ0Äâ°ySÐÏ×<‹2ÿ´k
ÇNíãÐÖøÝ¶µŠépìÇ[kê-øx„ ÕÉ.(”Cp
½XœØ•%Ï5Døå=4G¡¥$ža9‘¤Ð°ùK^Yµ…g3cJÃ[ÃäçdÏÐ!È_eg8-)ºæFY·‹×@Ð‡Ðš¥Üv/É¸6ð':šf‹¬À¿|¢
þƒáHZGC˜¦UÂPòœŠS§{l§>.Ì¶Ø»\ú“õé1”¹ŒÇaTäÓÂýDº“kpvûº•²ÿâá" À+rÑÒê!dy@’0Øø9Ó¤^ZÒ´é€ø›!Í7=€®ãÆÙUàNƒ$¹Íz=¯@KßPƒÞ=›Kítzñ]ñ1ÈƒºÅÑ'<DvbæÉ}N#™ÆÛo´Ð)Býo;_UjãÛyÈ+Ù%™Ë ¡¹’;+YÑ¹?îÛ>çŒ‡ã¹ýƒC
i€úìË'\*÷Š!!À›g$…÷F.‰º±wrIUàgÈÇZªMŒ!\JG0õŽÇMg‘8ølßV·‹³›:<ÅÚ¡~túé¥ñ É²ù?õ>¹²¦Â—q9"Àyã¸œjr¥_ËH”áLÏêTü Æ(s½¶œÀœ2ãM“1˜lóJåÍœ¸“	ä‚¶XÿÉ.íJ½4yž8PNÂ7F`¹òåj–kRÉy_^ŒkÉb>ÖUîXì‡“°¥oÖËhéÉ Ã^´ã]ð%[°ÌCXþ ððiWj€1Ì+rº¥
>8	ñà°q´B‘k•2Z‰Ö‰VnnŽ¤
fY}4V¬æJáþ’2×FëÖK½~vë¬þ›]Çð/Íã—OŽ¤,†´âÇåå–@¥Ao?û}uD¸ùól¦c=?."c;)öæË¤17>ó›Q½yxÎr÷öƒLìiWî
y	Ó@Ù×£4.ÑŽ&l˜k’þ†ö—"Gûû&ûVFœœx„g{–yœ³PõŽ0K•‡ûÞ_üûÐåô˜–=:a_#Úûú€`LÞlÔ8>-IØ+óq6S.Ô¸åØÙk$Mðú´æ6ÔµÞD[ûè˜»íP^(iÖe~ •SrXäñ‹Å!cèH;O¼"ÀÇ§šd£*0î»o€ßÔØîÅ¾ÇÚa—Û÷Ë£HÞ­ÓêÂs;}{èµ#.H¶H©{¢£SUüëQ/—N0&	æÉIoL”Kp;°J;J-7´£oR±þNui½Ä“Áõzëâîxd5Gò âmÏ<$(B/?À]–“>há”{ý„@É8ž¡'ýÑ©—Ui;m†dbµh;Sñ&Y€æ‹øÜê+g‘›¬×ZädŸž{Æ«]g?jÅãú	I‰ŽN•/süÿcž½LLWÂyŽ8uÔ8t# TÈéA×QTYfÜÆÝëúá/w]ò{B»Vk-ûŽ+vð¬˜ápúƒ¨Ðê!b> _“ÀPY7†$E¿ÝJUþŠœüqö5o3™	Ã›á‡ÅDë:…ã_®ìÚ¹é}_\n;K;)„©~ó£´žÅŸvÅ´†FbqáÏô_à,÷Á
ÔßàÍ«ÍT	pküFqñM}-”Ö­®* -¿ÅÓ®£ù‘s¼#G B¾€âjÓU™ë'ÅU¨iòá‘øLIPúŠœ¤0ˆªS`Ž:õæ1+^a)çu,îÏ L·å'Þ(­¥/ÅÓ 
ê˜ï_Ô 3æÊÙ›Ë®¨/k:õÿÎ3ù!Ìrìë'’zÓø…gGzóÈÍêÕ}VœRÑÕ ÎÛ@¸/ãë°c\w{mç¹wsN‚µ˜mÅ<^
></«kFß §fÈg’ž½~Â]Y’¡äÍ#7«÷f
ž"7ÿ&X÷™Âm‡§Ã‚-Ú×87.!zLê"    Ù†üdÑ¹o&·õf1ç§5ƒõÿì*Ò$L`Ð+ðR©‚Å¸|ÏpóÈÍR	ÐJ-‚¤ê=P§qÇí,É%v×Û_: ÛºK•
¼Úmñb›G³íÃ8Æ>ëÁOLŽK}‘ü$þò¥¬½Ñ}DÈ
"ÉÈqó ÍRaUŠ”wþ&EúxgÜ¨WðA²8/y]åõ.–ydú§à6ü<¦KŸ
?°85«@W ‡^se¬.`ï†›‡¬Ö˜ëJ^Ê–³y5òÒÑv|,´$ÜÎû§¥ÁøýsÁÁrwJ1–ft0¹ï ‹bÔ·øÓ®<×$?ã^>=9BX,ˆ´üÔ˜r"GÕ-JŠÜ­µEyÔÒ­eÃÛy`úQ‡c1LøÌ
 %šàú˜vxþÔ5.›šYÊvEœ@žò×³K†Y^dHxC€7Z-­ªRpúõÏ*ð¨í
º‘ž‡Ö#ÖÔê/Ùá¶ˆ¡’œ}tZîîÊ)Ì²û¿^Ú±Îi½~¢Åd¶2"a+n¼Y:¬ŽoQtN­IÛË
ÉóG6~ ‹™gÒbÉg>‰WwÎNÄgq^9}Q³îö¯]1•cA‚¯ÀË-	$ÇNýú/‚7¾é±šïÔêÙ—Ä¿Å#>wò«Aà3ÆXÞ.Ú¼hZ—|³È»©u‘û¥fsô_tüKòöåõ|ô0  ¨{ûEðf¿+8²%½XàîÚžÙ
—vœ­wêq(HìcfYÓÖ¶»ŽÐ•Ð.<üºÕ§ÿ´ð©`Ü—O%c-?“Äc‘ oÃ”ÍÀj[“cP«-,+ùIÞÌÖãØrg /b¦Ò>ƒ$¨	¥®µ‡Ö
íŽ@‰Ð,k×5ù“ô¡ää*Ã—O§ó0P¤¤ÿP¡¦À¥ U•Ò	pÉ}£”þ¦f±¸ëÖÐYe›ýšKÝ„W/LÿÖÉÉöxô3?¾uªkâß 'veÙréü
rò‹s<qì\ã † ÎÞ8vL²—ZŽ=›ç°j²]i.'û9ëðƒñ¬eõ¸•Ž—ó½t½¢áy,×e‚üqì„Ü×íIYÎV
­Gp£‚üÍn'Eþn·³Š¼u»FÒ<>¯Å
vÁ,æ]ïË.³â­4XóØ&3sˆêŽx=á±e— äªŸ åH‡‚H®yc®pŠü]×íöLfvµ¸Ójy]‹3ƒY·ïÈKÑrôôzêä™â´´ë6ŠšEæÿî2O™ÀPåšcHOƒ@g<É“Æ5ßp<©öˆÉ=\§¯°W'yêKjjïõÇP¹vº#¶3Ôó8”LFë‘­Ê&„ZæÔgüË‘kÎq rØE:ÞÊ³¤“NyÒ	rªÞþyPk‘ 7àñu«Ñ‰.>’”“UÏæÊ²Ó×Ey/®ÆÞq»)\]“S»R>|=ê€îVP™p’¯Ó!ˆÆDé÷-‚»ø«Í×*³µ›?–ân?3` õö‡Ð_åÅƒ]“Ñ<q»#÷ô-‘ëGu›‡Ox¥ 
'Š”ú¾‚œén€IÃ5ŽØK‹W;IÔâµ:I‡î êÕ[—nûîX;í¶?£”ñŽ†ãS­£#ëÐ9É[.Ò|š*z€áo{ÿZˆ<÷…è¦ÄM—¼©p&`8zÒ‡­7Ö*ü>ÔâSç¤·ÄJŽ“‰oæY¾ž/Q!
F—ô²ÑüË¶vi4l/Œ¼µ‹­Ÿç™£ÃÚ¬ðzÔ)90ø 'üÿ¡¼)¿îW
ÔITx{z*÷ã•³è¬XzÏ]Y¶Ý.òLV—ó.ÛÎ·»Y;©[_ÿ9}´–‡¯À1í }Û/¢VJƒ[µx)À^¸®l‡íÁ%Ñ‚Ë¡;½
„ãÕð æ-,®fÀt‡­Á¥èµOzyžéb‚È{üò‰&oä$±<‰Ýø_D0t»·zÅËÂT+.ÃHÒ$sv×-'gÙcm+^÷|48ù}5sÌkxÂ? NÑQf²’Î“ä$¿0+ÒªCÉ˜*mÕJÃ²A¯çTPìÙbw:z]9OÜ²Z==è¤¢Ö
$!Ø5ûdÿÝVáƒäûêÁ XF)Ôƒ‘(…ÿEH>Æo¦±	p¯Ö46G­‰™Mb,DŠatgãÝv0·o¦—öz|H9â}=ê×Z>¯«@N-ù]½ÞdDWø?xy– ÿE”b¿!É±©[«5à‚PWÏËE!ÊáoØäÒ;wÏÝ“¥'K¹È»Z<òýá4ÿà@?‡  #²ø9·Çÿ" Õa•Ú‰ÞXç/ê·/>:Ÿð{M… ï¼ùÔÌ¦6X3Ýxtt¡36ÞbÇµ¹–õ~p¦éÁÅTÛWÙ—OT¹ˆ£J×²«4 –ÍÇo’-ÍïuRŽCØSQG^N14g‚0ÈÚ{}
£iÀö²f|¶ê¸­‚-ê£þwpÉ£/‹ú|É*Ðò!YT^æ_„#Nþ¦ëµ¢W«ë}àÑXèvì3róõà¼N}ÑI7vÄF—ù–o‰öÕ16ví#]Žw æQá±çz+ÿ‹Û†UNbjYç
'ñ›ñ¼
Ü
Pl½ÓåÒ—´n³B·5J’óõ Å_‚ñØšßC£vß‹ž[ü©/% ô‚*Š€‚˜Èë+üâ}¢´Wï,ëÖêñÆ»h{:§2÷!
ƒ;œ0Î~rÒ#Î8ô¯ÎnºNñ°súèòË–L™9ûàÓ²¿ˆ«ðö*ìZïÐ´Õžö%<¨Ø‘Å«e²Â×ñlUó÷²>Ð‹E×8ÔÏŸæ>XT—}ý¸2«"ÇZ¤Îê‘t¹6ð¸þ7-Ï¯ÌH‹‘9qûû¥ŠÍƒ’‡sÝ½gŽ´ôÙË&YœM…IÚ.×$O—D3CŒ_jbÆ\$”fxžœé_„.ûf!
O¨JC
ä›ÎJöîp&;æbk#Àù×{êœûÙŸkâÁwûVÍ¹òÿìŠ?„ÄW/h~A’FZ' ¸I»¸ª‡Cq{µôpz{	ou—uÖQ›>¢‹Á&¼É[WY–î¯÷ax‘êw4?ÍJIœ*†ý‚œ§›`ä’
tºº1i>Aî±ïB®2·¨qÉ‡êV˜ðS_ºW©0õŠ¯T¾Ý)Ôô8‡“}÷¶´—ÝÙô^¿XÚ•ê:!f¿ºoÌ—ÃÕ<¥†%ÀñnEu(ËIÇ’Zo(ËÚ€7êx±;Ã+RoÛ™ºU™6³´{Žåö—­¹xS´¶T—Nå	¯œÊ0 ðúIüÃ È•“—Â/¢l¿+|“?¯Uø¶n†tnkG9mZKk7_YþCà‚M/ØsŸ-+a¦¿u­Ÿ6Ò1Zþ…CþkŠþÇp4½`éÀÁý‹P,`ªSåÔâãZSå©Ñ]¯CI±¦’çÖ^k;«}fçk"i^¤1XƒvcÆ5'Nÿ;ÏÜ‡@:÷‚›ú|Zâ9ºÞ+6T@©bVñn¸¥¾Ñª_v†²t‘™ñÈèzSßU•ëº5×RÁH’ãÄ;ÃÃ ‚»ÚÜOtôZ ž}’¾	¿x°¶J"C-«ÿDæëÔü~ŸFkšÁLWºrÚrÀ%Êr¤ôt•Õ”Wôƒ&VyaYæCäyæ¥V@Wõi•—A<äE‚ü1Z€«¬¹W‹•#¸ž“^´Ž9mÁN³qÑÇ¸-ºË{6³bmd­‚ƒK’k¯ö]~^XüEÊýò	”
t:I`É™n©Ð3ýF¡žéw
…Uàjz%Gv4š%»ý‚÷
{Ý–Ô‘!Ÿœï^r8Ý,n93Õ&@û×®$ãYÈW>AŽ2ˆ”çÄh™Ü	ò¬VýÚÞ©Uõ›pñM»¥
Þ_¡:ê]ÖŽæO¦£&[ÿ(
‹GÈŠ¾ž˜ó´.ÃáðJ¹yîÕ}ã’UˆÅsä¬7ær'ÀU’i¾Ž9T.­3v&Ü¡¼Qü‚—r¶UÅctWOxÂu–ÌPëw·ñ*—ë!è×ŸËø„ ?xÚ¤ÿzØ1½ eÄÎ’4ûºÍßùT îH~-ÙµîºØÐ…p–köwrQ§î`´ºŒ:xQ´C{{¶{ÿx™Ö±¤ðx:pGëØ<xùD¹à:¬B—·Å¦q9½åhR¡S¢·œÄë5Îú²ÏO{
:§)ÇËãÞa‘¹ûSÞ>Ž³ÅI÷={Äó!%h¨íÞÊUW–ƒ×_ÀôpcJrØ˜š—ÀÖ³ên±·Õ®µ3WøÖeeN¶h‘Fñ-9æ[ß¯ã!3…S¬n½É|9==õ £	¥QÉï R*‚W{Óâ0•b:›¾g9|gp·Õ2øM<ˆÒ"
#°»} F—Å€“•Ó”ïs|Âç|²Z>ûìå°Tb®
ÿ9 ÿTŽðÏXEl…R„ù¸¨Æ*%e‡kí8‡)³ ÊeüÊk}qŽá™Sþ¡Ì¶ËÑ­~ŠMLË—¡
‚€Á/Ÿ`¹ÍJÞrò¦ýC—~aÚq¥?Yš6¯ÓŸœÂÐ3 ÷ÓÕáØ½Ÿ:&Ç¸¹²ÓÉ…™óðr¾ºŒSû.?.A'Bôú•”ž"þ¡ÒÃqS’´×2šCÕikñ0<ÆÂÃÎ»ÛÞ©ž|Üw%yêË
>ì\{¦\ñî“dæõõÓŽ§UÊ(
_jþtS¢L; f Áý
ßmƒjÉŸâ¶k•üµÁãbXÞt&ï¥þ9p%7÷º²Ô;íIÿÌ
&{ìÑ±~}ôiU’fb…¡—O˜+r"ŽÿEœâdïâ­h×ŠSœBóëàðHýáãÈWæÄzÆ²¤16çqêÜÞi;¬?EYZ@Jì)ò_Ã®T(D€gÈÿ‡ê—4 þ†üZüùá¡uî‚ôÆNÐáÚ6ºö“ýÂº®R·Tç€ñPo0ŠRç'ÎQÎüz©,påšk¹Ž ÿE€Fÿ÷æ¬vZç¬ÏµÉñd‚¡ ½)Qk°¶²ƒÓŠyÑ7W—û~Í™L,äúÃ6ÏMõ•8ðjq:Ÿ é’CÒOžùE â¦U‚@Š;¨E(³ÖÁ¹l‡kk±Ïs±8/¹®ãd³½"²³Ez]=à)î°]{Ïíó<‹%É6â_—54‘‡´lÊ3¿(©è¨:]E3·ÖtU’XgÓW6Që¼õüõ¤cµŒõ|Î²“¹¨FÒgõÔ_h?èÑ—q
¢úð<B_Ÿq¾¤â(
5KòîÆ:´xˆª\Ì´xèÖâb6¼ž«^õâ0cG‰'÷Vq`ÓÖ¤•¶²Ø´økœoáIkÕ_é|–Ãéþ"Ë/ï¸ðÉCÏ3<†Äâ¿ˆÛˆeß^ñ V-X?ô¤«ï5Ë:?:úhÜD‘1#OåüÎwœú7êa¯¾s+=    ¢ä‡d_Ï:ISÚ=àbÿásÍäÞ›ñR<¤Öˆ¸Áù#Ï¸r·(ØnG9Œ¹\íw¹7Í<ÝÝc:ÝäÀþ	ò’¯˜„)tnÆä´‡ßÜ¶ì»Pe"éµBe|ò¯gŒÙXsó¶öØô'jÈNíûD·ëà0á‚tqjAý¹“§“æ?0ƒðKù£¬·ýÄ
Ôý"Ý"yt…ì“÷j‘}zóy‡VâÒ[¸Óz2óèbÆÝ‹‹‰ãúS¬Ñd—éÃVû°¯ßý)4y0F<~ýD¼Uû&Gú1¹ÇTwVé‘×ÚY½O½÷pn¢é:Õ3Øûl(ûƒø2[*­#8Ìá5>nôú±iiUÄÒáXÀã—O¨ª#©IlÚXD€GUõK
Ü­¥~9w/¤}®„ƒí`Õ‘+÷]o{×™”º(6D®½ÍöiUŽür„_O:.;”°ˆÆ¦5ð ¨êKÓ@]­¥/½˜r[Wž·¹¾(™#ý¶X'Üµf îÖ–>¿ìÕ	:e‡Iý!QšoÐ
¼ Á+ð§¬=ŽÿE6`­2O{L£¾<LVùñ|3WÛêcoì¹£ÝÑV™¯1á%O×cmòGïP¿ùSš•Ê•q<‚âK ÂðefJònHbr¶yLnµ‹7õ†ll©µê
ºž Ôšõ”v¨âÛMóUá²Qdþ$û˜7Zí]ÿb¬}¾Lê·FJ³ F®8à
pÚ1b)==¦N½1û>ÞËÇÕž}Ã‹:iØnt’Ùy~ÞOe…_Ýæ’ÇÏ6¦³r<;‹=´»5{žõéÜNMàOt˜Ò3¨œæÙæY‡ÕFÕIwjY·Ö¤{gµ¾«¬ÛF4Z!o·¦£smkvn±×Ñ}‘OŠÂ<êOQ–ç–Xböµ:Êÿ*±äÕ"±
½ËÍã«÷f|”Z¶Þøèè²fQÂ­ÚŽ;8µæÌHÐ„Ù~ç‚‰xñ×¥¢¦:w—ê—’žèð f1B¯9‡@Óœ²ˆ¤™ø	nVõ$n*yUgb¦ÆhpÊW³]ÏÙ
"r”»ƒÇj“„§d¼)ÌxÞcñÍÖ&›ú¯V‰SÎ7Ùç‰n‡Qýµê0
X!
îåÔ³›-qëÎx÷¸OØ3³‹3þˆñN¨w—7!N~Nò%¡'C»Ô¯[˜<ÝÂdé:&ÿbÚæ‘X¹¼Q	½³ry£†iÑÀÕµ	yš:ç©e£ˆü™0î‚7N£ÇšaÚ=|œ	:ûƒnæÿA^–e_òIS³#†ç1EÞ<£VÕq”L³ê‘îáTVmn…Œ (¶¡ÌbYÜµ¢£–&Ãf>›Jóu¡ý`Êð	ûé8
zùÊq4L)cHÚ˜™˜ §ÔòÕ„øt¶NH"´z^äåÊÙ>¶E§s-f«åfßNpmêörzo)ÜRùÁ´]	$UH ”M¾1¡>Eˆ«¤¡Wk‚t³oíöúÞž#gÞòþ±hã›4Œ‹-Îm9ž;î¦[?hU
´èÏŠ$¦dàËìl)ãE»ä_ã Aþ‹·ù¶&´þ«¶æ×TZN8ö>íÜ˜r‡é
,[çkçÊì»M{é4ÏEdº­º½ÿÁã>0üzŸK/:]ÊqTú‡oÌ-O{Y•úŠ ·Úµ¨¯¼½xÕfæÁØzçµ^7[ù"­º[Ôµw¶a’`tjíùUÜ~àÃŸð„‘œiöY&i,—@R¦„7uTçTŸ©u	Ô‡?êºù|w¶†lp|¤Öa™{³Èé_M¯7Pði¬×/‰å¬=Õ"þÊ]H>QÑy–NSi¾±^ ›ñUÚi'§ÍÜ:×ð,t»Cy³äÒù`
¥[W}›C[Êy:Î4dÓTûA	L¤÷¹TŠ€âKñO,çƒÙ€!fØøÆº`ì·™ê°(Uk×]Ää4ÕÈ¾®<ƒ?ÛsÁ¸1s¶Rà1ƒë®—Ÿ 
a#ÀÒŠîŸ¨^
¤
ˆÊ¥àMUÍé¼Í»Œ\“ÞÍ`ü¡äm}goœ¦Ù	ÍóYË»Gúâ$ Ñ9³±z÷´Q„Ö<Ü¯ãø%/ò›úû5¦„…%µ2+ÌSÉ‹‡MEÍ)2¶ªgE‘éoô¬þ5O–p5g½=é±ŽxŸâÇ£ÃælÌa\¤@¿ìì°×íÿCµ$‰”ð·¸Jñ(xº§ÆÜðWyãžr‚·–{bí¶[ƒýie¶7R[Þç
	«,gµ
ptîáÕ©Ì%±×>ªO-H’!¼Ð’';•KH
AÜÓ/JTú·š•Ò¿5.iÒk)×ˆOKçîè3ý¦Ì÷Á½åIf¨êÚÙñÇ…rZyqë óaÏÎ
üàÇ}]¯{
Pv.ŒÄ›7´ˆm«ì\ô,»µØ¹ìâÌ
Q¦X*s„»zJöƒÕñÚCÆmñ¸-„»·àÆøÞþ‰Í*gf8J+ùåû¿’¢ïƒä—Bl›
g‚’÷¿ZÐÌ	º¿M|ÎÔ{ñõbbÞï_‡é#é³-c¦ºƒû’CøžÌ<‡‹†ÁâØo×Î|"/Ç8’|†¤È){ñÙâÓ37´|¿	1	r¯Vˆyî¬îÃYî‡A$èCÛœZº<°ôàÈŸïæ†ãw½!×ïrÆ Õ·y	ï¹*Ë~ÝY¡j/|¹:-p&N¥(rV«¬Rä:¨S&èn¾{oOSx›N7FKÝr}x<—ã†Ý2ÝB€‰ê§ô2—j\ˆðk²ü³¡¼b0EÞTWóÓæ•àº´y5¸þãÍš+VŸEõFžNFéÕj™d”áÃfS?¼%Ã M6[ÆÒëó§±*@FÕÊgKl~‘mG¾æ÷Ò¿ä
_.rzO‘Ö²¦!{¿pÂLPÏáLXp–Ím:wažÙ£dÇscñ>±+Ow}:\âäžHç‘ðÕÁr}óÿðˆmŽÚaÞôcr­ÿ­óu»oÎ³å4¸‹·år©­n}Nf9y¥z›×²œ ç¹‰ó¸6j¼Ô‰E¸rÑŸoÌêOáá7ƒ1žWk0æN‡Psyumó>› (1€ÁÚÌ²k:ö}ušß\a0AñQ9¤"	1ÈeeÑw§–óÉ<ËrÌ³ÂÑX¯žZü.#Ò|¯VFä
uQ<ÄÂéjJ¼÷íÕ®&ÓÖÀ^º…¶]÷RûÌ3ì×‡ %c‰<EòS_+Tª¦l9a q ¦rÎt#¿™PÎË­ºïòS:Ì÷îª%z7O1w
Õ”Xyîýåñ2mñö±×2ù2ãéVp]OTòë”¸£g ÝX™€BcßtÌ4½VÇl–
³¸‹Ñj=Žöö’‹L›}@©ÞÃXïØ™;]Jìe®Õ¯ÅR„ôŸsBå[¦,ÁÌ`‚¼yEÒ÷Ò*MenjÑ„Ý³K¤ŽâS2ttÐN2;ëùÇjÜ›§–m
0³Ûâê°
×õ'Á“-‹ý`X$|%†%
K0	vzœùæ~˜.ƒV_ºZçõŒ&SØ›£Øpê1*§øÝj
n›ž£p«È¼Ÿ\)N)kÔË©¦MC–hãƒ}µl¹Ñ.ðÂ½×'ôržçEJæÌ7fl'Ðüæ	*èŒD¬INã-oîDxµ‡÷­òhõ/]Fé·G\ïFáC]%;8Âv\ßè€Îð•4ÃðÂË'TÖoÈ0t¢
3Í¼óaùß¶,¾=×Üë¶Xiý¿8ˆÌê<™iSk”92 2õÜJ‘é`f'ÑéÅˆô¼‹¼dÊ€&TÄ¯C+ä 1ò¢ßôÆIöìý­7þ¹˜%ÎZ)KËls½ÖI\–ìIcà\ÏöšY|6G žu/?BŽJé<Äˆ"÷ì%6V)½ø›Ù&êÅkÍ6mã©»M7‘#:Æ6s¼Ðƒ¢e	v–bgü	·áá »§§Œ®,d„ŠqË
<`¦IBcñ	z¬ILYANŽ5‰)ëˆZÚY}¬º2ùOXk§€ëµþ˜R%a[CÚ¨þx6Hø¯êï„RW&PÛòeüË'H‹ˆ
­@ÄWÖ˜²šk•öªÈéq¯Ã•vßØ“ùH÷Ó…SË­áX^f†|9ðÑ®—GppàXÈŸ™úÄ¦¥kùà /ãLOuc±…òâ¾Yt¦·Ö¢ó2Yøûè¦{Û~k/¢“g§cÝBvoC£ßo…ï¨„»™¼ýÑ©¦syä!@˜}Oûm$ÞääÍËô «ù!%J«ÕWºŸo–~»‚3”ùîhÉq ;Øîm¶Îµ³HV™PDšMPî€Ÿ}%@^¡g
KŽ<ô!k
ô™j^â*zhò¹ï¢:±Éê¶‹ÕÅé6ÍÓþBžóe<X×›û‰;à­aLËéD,¯þÀY—·#:¨%0¯Ÿ`¹"Ér¦Kcõ¨ÑÓ7ŒzP‹Ñ@µ–æQŸÈ÷Û¼{…»}§m] 8Ú¹PÜLˆIÀ|´
ïî}-×çKûDN~Gd*®ì© $B‘ùèànc£ëo‘—"Z5Œ~	º£ ÌüsÜöÆ§b
OÈÛÌ¶Aï|-®òªB(3Y$üÈèÄ²ô§©˜ðòé³wÎ{ÿÃ7¦å¦ÈÉVéËšeçµZmc9ÎFƒÍØK åj¾×cõdvW›t‚®Ò±5îÆwCwÃûlN
ËSn)þ+•€ŸU|Ž¼^qqIè	r*Á^}¸5_­²ºœ.XSÁ¼h	/Ö¾^6p Ó!;t¤©´ºÄ“¡¢íë„Px%ŸÄí_Ðç«1ó8EÈ¼)ò„ã¿ù¾ \+?Ù›ž»ž•›Jþ­ËwïÅHŽWFâXb¬˜v—B©?ñDHKòˆ*½=þ"²~[Æ,j—1—a'Lìõ±+((’G]qk;;?Ôì»8ÄþYÐÈŸŸ»æÞHto	D•ª r‘¥Z)ÅVäˆ³æPsè¬J3è…ó7iæ/ÐÕ¨{ÀÍwð¦Þ€ÏÁthu“Åt}â;÷pŠ’»?éLÓAµóèÿâ£Rë,þÜ+?ÑwŠNìbžŽûp¿x¢]ðfº¼˜Höß¦Ë¿@·ú±-&‘vS“óÒÛúÀ0»\‹+ñ°vVÏŸ¨Â„·ûÚVÿqZÃ‹,úò‰-+•øtÍ—Š†Ð5©]¼©œ0tXµÎïµ¬åêi/]ùqØ‡›àîÍû#?H~âìPy cXíLüz)—B¢/bXâ—O$‹~J7‹´~À5.i”‚¦ºEÂÐ¢þ_:p_ wM w{³“N‡dÓÕGÊNèŽï­å“(¯W7y
×î’Šõþ :É¢Y:\\^Tð    ˆ'‡@oÜˆ¢Ð«%ô7”±çàÅ}jíŠ‹¹¹õÚÃsq¿¹¦x\¦Ùè¾è‚å:ŠA4û™¹G«£Çs†dÿ~¢L§XÀˆ`n¬zFãpêËÞ£*¬Óp½ÆÂBYwÒIfŠûTãŒ
»ž7‰Ññ”Ä/¶a»xãþ,÷Kæ4Ž˜¯È)q9÷%wf Í+
Åø]E¼(•îj ÏÀµ§¹0õ=u	–Éù¤²]ÞÌ.öÛQ ù?ª~v˜Ÿä^OÒ
âÂðŸÄ;Oä\Éo@€“SÞ8×¤13©”0äÏqî\¾ÌüÇ4ñg
ñ8*6=sý°3ÏŸ_¸˜‰OÖaõP£¶ºþÉ‹Jz-†¦WPx6°øÆ5P—¼‹WèQ­xÅ3½s6‹”¡©†";\ û] ÍæûÛà¨yÎ!Ð£ueä£ìVÛ®ïMKò”2ŠDd€|‡Ü!ÛØUùóf[”Äúßvªàz¸ŽÛí¬tãÐFÇÜžµgƒ½zÝ'}ü0æž†wáòd°Þ³ù(¿1•Ôõ*&Sª”ñ$YàÙ—O¥âø ‡8srãÑ6­h“‡©Òv%Ñ™Ã|;´×Õwœ¢O¦çiœG¨' û|~8éøÞÒ2¨o—‹É°årÓV»÷ÈÄ!‘JR’÷iÍÆ
íM·‚B«Õ­(úÅ™uF‡QÏb•}.¦úá8îvdÕ“×Kse÷®‰°)na«îtÛ¿þ@Ê	EUJ„{æZÙ•¨ä¿°ìJÔa9[F'““5Ïä&;y„ù&ƒbÁO§“õáÔj3iÑ‰7YÜ¶”9â_X:„ö­	éà%UÐÄ¯á”H—Dè#D“W¦1…:1m/­²SÓµØ‡¯Š¯&r¬‡IOl9²ÐŠ—šnÀíÉ·\Û
ž0
Ð‹ œ £!´H÷ÏŸ–mÜ’ g½ñµ [+û½;ypuz[U“Fn"¬WYÀ	pâaO]>[2Ks>ûuˆÏ.Ê*ûåË”=çríXÉCÚ˜þŸš¾Y°/©4êÜZÀÚƒÑ€Ù´Ú¾»½åÉ	#Ãâ¼-æ³–±S†iïÜuµõÊªËgö/<òº2,I …—O”Ê‘² a‹ÿPË¦ïkAu˜*¯,u˜jd†‚wÐ4µÍÓîÞy\‚yßaŽ¬¹uh±£ØEÑˆ	×ÿ_iç¶­*®­áë5Ÿb¿€£qH ì;¨œPl»5›¢¢àäéw::g9ÐátQu¸¨‘šUõUBò÷žž¿«ÿ,jÚD¾ÏoÎ)#ð·j‰Ò.ñ H5Ò“6„‡Šøm(ìXÃ}<nêiµ93$<Ó8×”|²ÄduŠ»D¯…d»Ò§o~Ït†eèšæ
CPßÄaÄçnG¥;PrÑŸZ{ôäÕ¸Š›"«…”ùiQ5G =\Ò?Ù´“þ24ñ5NñœÛoWj8c>?Š ÍÍàF|ZÔôKghoÏ‰ˆ’—NTæ ^Q:ôÞúàs¶x¯Á£èiG~uì¹KÎQ•jzdÚZÝã9Î‚¶)“ë§%¿ñ¨èg ü–¨$¥Óx4Îc
åÉW—§äè _ÝoŸíÕ«VÕÑqº:·~5ñýU°á ‘¶ãS‹ñ:bÍºz­ˆ|üÙ²w}H¨ð¿_—5¼÷é"U¯Zqñf>CƒÜëG‹w¢jË)Ä}NO§PV[FŠ&UG§ŠÑN:’·ÃV¼{®•§Ëï‹¡¿ÿ#y^³@–]úÂ"ú¼Þ†ÀŒÿX‰ðÍ–”þíÛ,D›nÑ?Etß;D¨âzí,®óóášoõjD^Ëq,œ#n·7U²YY ·õÂ<÷'lÊ>/HxˆßéÇä­Üé?CBy‰OY«{ vÒ'c åŒ}®kŸnÉ£®XÝÙöÉ–Þ›Ž#¡9Ñ·U?Rê:Õ› ÷tdžÁ_RßØ¨ D²²·!N#>†Üòse{ 6<¸´ž±©ûÄ{©Uªa;ÙïÑ%ôÍødÌ+f_Ú=]YgoÕåüæœ{6éú	›²!âqs÷O¸¤¨òyÃ¶˜§ÚÓ,w2ú¨ö´¯4°8’ÆsÃ‹–LšLäëPáêýé¼î#Û>Î[×£?©žåísGe*›«e>ÇÃ,boq)—b„²ëlA-Ce«…Ö
µüÄ:ã`™­Vžˆ×¸!ŸŽ~’qcëÜà8uÌÁ8f<Mw²,ü×S=4ËVœ?ÅpÅ/"Î9“ô¡“ŠÁ¹¢à— wÙà\ñ£_˜?ë4ÊC#nâØµg&C|+Ù Ú¦‚ê{}¬ “LáXÌL{ƒ#6´þ“ÇåÐ0Ž–pœ”[åAy%=3û;ñÏw“Pôä¥â_bþ4Ò‹™Cû?Vn<B¯O¼ÕfºMÑHoW?ÎçèÈ®„øà
È¹ÞÐÇÂaÖ­ fXÿA‚Oþ>b‡xò’€x
Í–ƒÖè‡©Á úd“RÇ?í=ÐHaè¯š™)15µ{Ð{Ý;'[¿¥ï½©2ì)¤#ó³Ýéo3ÍåËøV“wA¼™„eLWsi8+-tË¹Ã9?vËy„;¥«^G«2=ÁÒ:áxÜæÒŽ,
ÖìñÜjÌ½Éq±áûVU²Ù¿Íèo8”Ÿ&"7þöJü¿€»^Ýá¼_=ÂQQ–¨—á*T|óÃ*]v]Ã·³äâŽ4ÄEýh­¯=ïS8É%ÄÑ£ò–î¥ò¨<[0>»ÃE?Ÿ=Âñö~„œ»­hýmt´Ú6g‹`ÍNS/ÑW3ä†²Ó5ª±è
'èã©²“n¡¨„Ë G!”ç™£ç=ó<s'†i¡%©ôù)î7i­ÏsO4œmu=Ú-*m¥kÐZŒBòUn$N§L"’ô»Kè}j)þ— 

Á¤rï/€•þ…*™ÛD‚x÷z¹ÝY
ån8ä–œ²ìÇ¶/u÷§>k^¿3«'ÈÜžÚ80œXáÞ
n’1Ý,ïÙ]I,IÅæ%mO36)ò‹6‘TáPïÆ8À™×ÒðñÈr³ùðp®N]dèºo÷"¾1SFéñƒíRÈ_íÂò#0ÂÝÖH*©d€
žU·K R“çíòªwÜPº8q&v¦É±“\“b0£}'ÊÓ:žÆVëp7ì“7*¸5»uŠ»•¢Ò®<U±ÀúNå¿¨Vz ÒFüŽ³ñ2‰–h™£á¢ž…ãî•ìÇg®ÃtgöZô§¢|H… 2Þ4±·£0Ì¿ âŸw Š^ìþ{ˆ&Äò¾’×sâ‡0<Z™ºá|_ž«4;¾ N:ÍäSªüJ›Ê/Ì³7ªrw`¼€ ]õŠÎÝÖþ9ì}¼êìNóöÙ¹V–zßãö½­¸·¤Uv]m´U«}rÙZ#Ž*©µàb‚oD˜†9=bà”Æˆ¹½ ÿ3ÄæŽÔ–£2T¤¤åü*²Ü`‡)x ä¤¸Ñ¿#ÍÖl‹+"6;æQg´é„W.¬EýU¡ÿÂ³ˆø@«
ë¯¤l^&I ÌÝ®¦ÿU	$ár<BIË]òeyc¦ðò=»»à½xùþ@JÆñ|´ÖÏçõj8Ò—CžŸG
3Þ,V]Íì¬—†=š.ø=)ËÞï,á8ã	4öù>ÄÃŒC­(ÃK”´¤hÉIyí{-ì”(²‹¤öälk¥Ä
/ü,im'®qñ—º4_†Ì(è·²î»ó)ó	pnçÀÐ™»Ùò€áÆ^à˜Ú’BÆãhŸ¬¦3ýÖKâ…Õô£5	R<r$Æ:ˆÝ$]D>ã‡3ãÅ¶ïîÚ»¥³#c¸œ¿‘ÞªúÁÑð`lW×/Ny	¦V,9µ<•kàôV …
ÝŠ?Ð£½ggAdgüþÐÐ+aZRßm¯±3H\|]5eÊqKƒ¨ï¹;‹á¡¡ÄKß†ò’ox6+8 .©Ûr`
¼ VñÛ¬ÆfrYí]yÂ¦Ý`Þžq&wµ÷ÍŠR»ø’qbã
ÑÝÕ¥N>!%ù“JA€F’Ï¤Ò#²,¢ ä_ÌlÑª   ´O¢~Ñ8Ì»<5Ž²2
FÊþÄiNÓTÜnµ)hÒWÎ-·ß÷þÊËç™Pí(	WB°qÐ_Rø5T¥g¶žš_ÜµÍ/fVî]û|Kié5OÚlN“æ$j3ã(®Wg«p@.
²<Æ=Ž\kò'¤®•«\®Æ	[R
ù’¤ÐÚ›ÆR>ý™ú¢µ÷ã6d™iÊÏj•A£Þã·¢c:Ñ°ë.M²p×êqƒ›™1xKÄ!(bexx2‡FWbÁHæK¤¡#¡ª-©|ø“)”öe·kïEißéà¨J²i„›,›7ZËýO	æ}\­-Ç=§ãº©tØÄµ¦oßë#ŠÃ²¹>"`ÌŠèÛw¿‰Ç%cJZRAN¼Žµ¢¤¤ôÝz·J«sN[E‹«y^ì[ÓeÐÑ?ðr?Š3n¥_÷µ¦älôýhÑ~ÿ=N¾Já‚K ü-OLØ’:(¿Ò¹¾X¥lÞaìmÌ8j‰j+¸¹hdNôã`S=sšyñ Ó`³ vägyÂí> âò.€4Fìý»Ce‰è‰
×«@D&¿w&k·U·ß”±Ü©´‚ƒÍU¹s<Æ›½;23º­há´™LR½?#8|ÿ¸’\"¤0Äsù+ žN Ý3Ù’B š WÍ.ºØZé[¡³ÂÊ¨Þ¬ólÚÎ®Òt’¥Ó™yp×¶1Lº–JÐáèŽÍÝ{
Ë	ùƒk>÷Z'skô0„l§,(A­³%ÏýüRº€4÷²~:¤çªÑf“êÈñe{ué°ÚB´vDéïfÛ•=8Øý
SÛQa8ŒÞK:ÀÉ{ñòp¸óˆýG­s"Ì)"76Ì3@ZRÒ©ƒžÎA Íä›@}K
ç^ßI±mOgÛÝüè,åšr "T›ØŠçMqá„æaòàœŠJr0ß£ ÄãÔÞ€óVÛð 
Ã–Z2½ãcZÛ¦ 0Ýfý·«º\„z?žõÙI¿¿
„U­·¿®ûÜ¥“4ƒh™ºûlÉ.g­þWR)OÃÑÃ¢­û–ZRÊ Q”èÅ šåÎÄïˆVÇê†ô+æe¡s‹E]VG¾’Õƒíf½ÔÛK½92»²šÇÖ€|@„ ‘ð¦b\Ê‹€	WòŠÙ*[°±Ì‰è6ûc+ÑÇE9ÊúCA·vÊõfËjŒgã3KŒù\1÷µÎ¥
fµ¦Ûú›rôï ÁÜ·!vVŽÆ\"ÃH.©h‚rV…:Yú×2\¿¨“}˜B×nzõZâºá°ÙrÛót×	XÞ¯Ùc68U³mUž**¾îò—s>œÀ
 ®YpêøgäÏ«3î‹á# hIA$    º¢2…»Ô°½v‡å>šiÃž¶3B9¨ˆ‘ïŽ»Kyƒ³áBK6ãtÈZ$ [–­üåø¿½´BPª!"ž½µq'\IA¤Z~ñ­ˆhÔ]æÞW^MFL¿3­L«ÊfŠ­ëü¶3ÕÜYNÕ½víY}4³Úü9ø‹%yY
AÃ	"÷¬£C·Ú
y6_¤%…NêpaSˆ¼¯÷«ž Á°˜- Y£éÛí6;
õ&çO»R‡›&q2Ì¶hc{æ×FªVH¶Ê³Íjû°¥\wç½V8ÄJ·êmÂ•T4)“¯S÷;’õÂÔýÉWŒáé¸Ò“ì¬³«Kì­]…Ñ£y£Éh-{_IÎYê÷fW„Š÷2Å‚±?`2P÷…x
¤0'üJ9ñ¿àp,	l€rá¢ÛPÔDS¨Œ{7‡+£ròO¾YGÍ½lž<Nkjx*b<¬U4£ÝoŒ×ý®ïI&`í†ÑÏÓ8I,‰·þë¢Ä _à$Uê(`ç)—ž‡¯réÏGÉñtqÚÃãueËæ0<¬–zËdxKu.ÊeÙQ˜äPípÒØñ§ÜÐÍÊ8"q\q®"é¯BŸOtI™Cuº,Åm)ÿÙ‹Bß‡‰6f–Ð
÷amŸ1“=¦*“Šœv³^Ä0Ó#ÏŒ¤kquýåD‘r—M3Lãlá9r%eDrVðX "ú
;/<ˆÖACY-W:wL±ÒÃ…?¼ãØž7gãáflŸ¥åe7ÜEËâ½ÜOSH¥9ý&yæ‹%áöä‰ðÌX¦4ûšÌÿÁ=‚9t3†Fx¹ÜÁÇ®J;$D$H:\ÃÎºS™ùŠ¼Œç
Gšª
Åò&Ó(7ï„/xÚÅ¿åÃ`š!`,!¡8$‚­‡ŠÍþl¨M~ð¯ëR¾cc‘m¯%©Ç,„Îù²Ùn¯]n©rê×´Ù¥^[
ñ´¼a}Ž-Âze	ËÝE,x±—ç+>8¾óE?<8þÎ×ØØ–—¬íåFgbßô°nö³Á.uA{f¯ñØ=\ŽlÏùœOk[”¹ñ•¬¼É3ÅšäÏP¬k’wÖHÓ»Ü%ZÅÉ^Ú(ünž;óJ»Â Óv¿Ú×¹êÚA¬ßâ®»Ï?KÈëH_XÀŒ † D |DÁžr—•AW®u²§¯*³·ûÐh˜ùžS397íœy§1ü¦Þ3T—‡B»‡Çf×¯&¨R¬Æy	Ì3ÿÃä=BÀÜ†eÁ´;ŸÐ²bèš÷´>2Àâå…#Ä£67'Ž(™x¬zI-;zÞÌ®,²­Ó	¥úeh©«fÖU Wxò¨<è·÷ÅÑß0[áâGàá8.+† n¿8#9¨ú{
¼¯3¥ºÍvŒ¾8¥·ÝÅý6h-«n/Q‹aO“¹EF™ü)0AÀz‹CáŠCÜD^àAÁ—4¤Î"¨CæŠõdÄÖJð¢žìX:î=Fìv£=^JÚ¥•…’Ü÷gl07V‹pQ=Mðe¯«=k],ØyÌUØüjå¥Uˆˆ,&Å¡¼c*·9F¢À%5Cùs®Ðÿ€€ßÅÕçô¨®*Î¼®{vs	M•1Îñ!PfžiÄºç¯
w5#r1dùøÖ1T„4:~ÁyƒE–á`oB%ï€"¬AÑxVä®y}ý;^Q´dÎf½u·²9Ç«}g wÛñò<t+²½¯BS9í.)Vù¼æ%÷~™X„›Ü­(‹ ’	
jW£˜7°£Zš¿Ítö“z$+8lO9/´ÎÁÑNfƒ¯š»KÛ^VœlèÔX?|6‘y°
EôÇ˜çÄâ×™‡G¨džx-¢XÏ¼¶z}§
yR)®ÅG•—Ó¡nž5Qw¥LHGºµxÛ`|4uK¶>žHhl†.\–º5®Á,ÝšÄÒ­	•L£ °Ïï… ˜
¨÷÷B'c$9;´öW5~¾ÛxReÓæêÕc»™ìº=­×4®IðÁáó›
]RõËÜ=ˆFøÜ€åN ñ*©" ÝL'¸˜L¡ÊˆNðûÞ ÞºëWlOyf¼¨×áIWC¼Myo2Z¤-UÃñ°ÁãI+øc².€ýù®Û!MwéÖ Àÿ
Y½"{ÑFîl_ŸRn«¶ªÊ<ØÆiÃ¹ì ‰8§aÌE¿öLÄ¬*ÿwd|îf€$RbáXeY,X»%uÄØ(Æo7âF¦Äñ9ië–zpJ·5×ksABæçñT:È£SË
—z¸m'þoˆ¡)À‹ïÛn©
_¨}¡ZšÖ2TÃÃ
ñMkÈ„]¥+¤óŽfŒ™l»ßŽ*ãCxÅ»ÅnÍö˜díÖgûuåœ\–m»ÜMëJPäË	˜'äÛ·Ÿ î‰$!*P)…t+ö¡¢!«€ë‰Rõônñ¢ÅºÒ¯Ön¤
5³Ñ­îjS¶Ñ˜f±²v—ªÜÝÍfÛŒ¸ä}Ìå/Þ©fèoèâRW*P¶EÊb38 KóghDkîu™µ,¡½žÂ?T¶1;ÆW3QÔÚ¡ÝpÖlttVâG
ør×/0W!˜°¨8”;Xq<¤¥à[Cë«;·üÞúj²íw~‡w4£Bgp†\_˜÷#}$
Í‰†“ˆ¬Pu±\ª1ú8¯5¥Ÿ&]ÁÂ30h|–è9[–—*Þk¡) ðRÅk½h
ðÀ;›gVÖ˜bÛflõô:ºyòNÓñi3œù-oÂVsŸUä™úALC¡X0âó^ ’(1|‚öKäèï¿àb­,/(^åi~Á“ôE’åW·O\³ØžÔ–›®ÜªŸøi0_jQ_†ò~:Ð,ý~ó÷'?ß/iLÃ`V¼åWp)Et#ó¨–—ŸÉ êÝ©ri
k¥{Øœ=2³¥ckC‘5™áb¼¼Nì^gãÔ–zÆîÖù/Èàþ=w ”îWf¸T…ðâïdQöI±¡Oän¯»®dnÚo¯5…?»þbáUÔP
/’©š-ÖçÛ›ùÿ ÎoäL$|ŸºR ixÉ2) ˆ)øûLŠÜ]¤.ßÜ·}‚ëD»ñÊ¯ÊzbuŒÆPekDÓ+–µÑî³M‡Í»›å]¯1‡È=§‰K)
F¿*•ÎBñ³z™}†¹=6ájîØõB¶•n3ÅØvM©·Iâýxmúîe=@‘6q\ã]­—×ÅÐ½Úw'Ò}-Š¥²´y1¸l}/ß‚çZW-ó~pÇøž¥µ…Ä3µþ¼‰¶h¾ïX•Nâ±¡UÅ`WéÍQ×«é$~ü@ŸŽ«mpÇâó‹Z6·¾0’ÐM·á’2 òjÖ'(]q¸÷Õ­×êRÞ.™p­F‹„­çé4QÎÛ]_6’f’žÍêÖsÂ‘ª½»ý¹ÝÚ'@Û@NúSÎÃC6–ÉOBp¸¥Š
	¿ !R–îñ¾ Ê@
/€Þ ÊçÁPp*šwªÍ¶ÄmŸÇËŽÙóÐxÖ«zóÍñ(È#ô¶Fä yu$Š"’þñùçÇ3ùÍ<D•ŒP*·Ö†Pd¯•LfÁBdßžt'É]œz,³[‹ºW¯É-£·nú—Þá({ÞªÍ2nÐì´dú®Ðà†““R	ƒ$N¼¹/¡¤Vñ`O§zåûÜé¡“äV=ïæÎÚ,õim·OzßÔO^O+¹{4š“ô‚M”¦§Îy³hO ïJ±à¼a†û,UÀûòœ¨¤#p=P
D¢ßÝûb“¢3ëŽßž¯ë‹q(9Õƒ~™ÈVÅÜ^9útVUÝL82°Ì¢’Jú F|Eõ»“ØmR}³×öp¥¨¢ävf?¯¡A8¬È·¹ŠóLœëæ\–®Z³Ê«]ÐTßâÕHQgþ‘ñTî+Íëðƒ(P¨0„#'å•s‘XRºµ¦å9‰JJ¡Tj&Ç
ééý½k à‚Í‹v;=ÖÅn4¯#þd éÉ¿àŠ¹QåÃÙÂI*U‘2xµóør Þƒ»fÞ
ûis$p8`n ÃG8¨	àù’ ”Sc¹±CR0ÆÊëËu¸	ù 2tÓ‘½ÔöòÀ•+ÃetŽÓKEUF~è­Ð>r˜zSj4÷­AKýh’qˆpr°4Núsýü{å¡>ÇX„i.)ÒrTÈ•ß¹å÷¹òãÄÇ§±+m]ÁŠŒðØ­ESózªNBÛè©6:ŠRë²ü»WLHQ^Í„™’¤\íXb`¡d'Ÿá'5p#ý‹@˜,âf_löI#íø§ÃR‘ƒpP:¢>¹ÈÕeÉIñµHáÝ/„ô¸N†rÿ>‰§ç'ÌiIÝ““²….»wRÿE—ÝG£k´
Î)êõ†U[%U/ÜHÎq£ÁÞ1Ùh"ÚÝ¦.ÔP÷"½{tø '4*	HdùÂ†ö²_„¥ÿk1%-åMs#
ÒÂUÞ|r?xŠ·lpƒÅöÔÕ“ÃºáHá\ž_¶ÚÌ€­Ÿg…,×´qøàöý\^?JUÐýÈéÿ¬Ò3pwˆ;_ðÂø´T-xu‘æ»RbY=‰9±Ò<˜^ü#íÜé±~^mõñÅì÷ZŽ|6{ûc6xpÜÀTæA³`Þš…!.W/2ˆû&Áå‰ŸúÛÝˆ³úýí¾o[‹iU‹pmã¸ÛÓF+!fNxîŸÚu2½®=iåŽ¬ùß—0†~pîPd†à9	ø”#^ «È•&†ÜMá=	CîæÅ{’gbqÐK®b/ì´J³YõœîÒ<ö½D‡öuP1ÎSsò¹}ŒþFLÏSR _¬Dx,‡àå=q#‚Ósyb®­ÜˆƒÑÊ3q°í6«l‚6rŸóÂ¡7ÙÁ.±ìuWØ÷[¹v¶»tá»ó°tE†P)UÂâhÓIDô/pý¢“]ŽKÃ™œì¾ãnðx£lu`ÜÚÊ9È¾ÌÕäØ¶jö2ukJýÚ¿ëƒîJ_¿{7ôÀDE—„	a¾?Pmz3 ç	ï†D\žøÖ^¤Hé®ˆ£‹×­òÛ©tŽ{)äºVý0“únè¬eén½M¬óx‡«ïžÓüÁs©,HäfEDèÁ[ž¬5´'2*"^<E|&«¨Ò44Ì®OâÉ&í/ŽƒÞVè cÉwØ½¾WÉòŒ.ÛQû¯ª	Ü6ÔéQÑÄb©8.Ð_Pó¹ÿ
1¯=AyŒðÉÄÖÛ‚‹ýVcØ™L/‰>ØÖÑÎ¸4k N$SLÇÃèÜ¨ëÓøb¥Ò=H’$G„ü	8¡?•(0ù7ÀØxŠóÀ
ºþâµû3p2rœN[?1ÑEÎ‹î@æçƒÞëyHžé,¨\Ã¬JC÷wa¹ðÛÈ`0¹…åTn”&Ëàäù³¤
êEÐ3Y³¶ ³  nÍzpYÒÓ*Ý8£®·ìá8“{ µÅHëÖYd
w¼ýû¾+å›+r.$’ç!è~BÕ!GÕ)—Z¡ÿÑÐÙ¥`hGåáW†v’ÿ0NÃ‘?«‹a/
ÍZ {˜»¦(×Y‹ï™¦™ìñ Ã½—ü¬ðûŠ#‰»W›’r™•lµ@Îõí
©tÙWÃˆ´OÇöÉb‡Q<î4èö"×ôš8a™Cz>GÌ@y—ýúDþ7ïXO0w'*—U¹±…ª;‘ÿ¾j`˜^æaXG5Š{JÌõ•]ú¼:˜…ílzÖÎmjãúâðî½þo">ow*rÆBq(7^DÝf)h¹|Ê
”/È¼;hôþÙ°×Ý©±ÐÂß‹W}ËŒ•Ý¸3~áúG’½qóý~r§Áù…#ÂüÍ”r© ÊdT¨FË‰°Þm$nrÒuA^èdH?#$Ÿæë¤Z³&®áe#+že]nZ©ôßG%¬pï)IgžYT‚‡´LÞJŒr–»îÉ9ëIá¢îÎ©¾¸¨{,'tÔ‘Ì •ßšó+ëÔ_š‚ph´¶‚°Or—[ÆRÍÚ(µ÷Âí/}	,¦gqˆÍí}$‘@Œ”K‘ÜHSíÅ~i(ô xkK UµÚ¾yX8ã‘¹õ¢Á¼ÓK›FmkªëA¨ì1ÖÝ°ú>êúƒCe$ˆ|OþŒ`(,ä1¡õ)çÓ{ e_/]ÿýÒm6ÄúQÛZŒØi­šÑr ´<Ì4,ÁÐ7 ÝÁhUëîjì–¼»/ùƒ/¿$öá©Ûï!0g¾‹èO)i¹›![¾jŠÃÞÔÂCMÈ,¼S[¹žz{rÍÎÎl|¦keY›µÄhìnŸ-’
Þ+î”ßö¬˜×NæMà¥›ßâÿ}ýúõëÿdZ‚         µ	  xœ¥ZÍrÛ8>COÁ…º9^o&Uöl&Næ”*BÁ6+©áOfü8sœÃžöòbÛ DH¤ä8e»$îF£ûënÐÝ›Ç&Ý¥&¯‹à_EŸÄÐç_½ß]mwiŽ(¦|‰Å’ò Ó5‹×T…ŠÆ
GcòEÔ’§U]êøE/ãÇ%¥
ŸˆÑua¾é¬ÑIZäÀ‘8‚wI‘_?é²¾MsƒV@±Ú—°‹ªXýf´âÜÜ˜õ†  ¤Gº©%fÆkÂÖŒ…R‘ãÙ(Àdùš²Äœ
ÐbÉ£8bâˆŠð5ŽCEœÐìàƒIŠÉ·N²©Gq·ç•Þï«•›·¦\ýžš?íLy»t*ž	‰5!œnžn‹
‰#IíT=HIÚç’Àºj¶i}ÿÛ-ìÏçM©óíÝsõG†Vn¾(S½²›€ñùÑžH}lrPº&xÍãPÄ\	æëÁÛÅ7eY”cMÜ Ç|,ÑØ±ê¹ªÍnnøÀl^²¦$dŠEØ·	Ãèº)«"xoÊ´ØÃ!ƒÝœaŠ¿:ë¿5ˆ]Ýiw>m4®Üº~ÙKé<a|t~N]ðe÷‹0ŽóˆR>LØ Og–‘âý>(ú]gEÙ{ª@¼·ê¿‹Ìú¢§¡G;?3~ØˆW++â0’r¢w tU¥¹cüÙ‚Å ë[7w:3yDîd'!	¤Ó`%™SÂ_¬iò˜1J{È¢à8õ€,ßÿ œ‘B» £‘²›¤:šsÈyä€" `ˆH
ÈIY,| Tè„¼Þš*¸Jôöû?»4Ñè2 è}òT†ŽïªÉÓz©Ò áô`ËpxÖ3aA Ì×Œ„‹9ÒŠ£÷ºüþ÷ÎÔ% Á m®³tÿ¥Ðåö²G/ˆ5Ðšryf´{,
÷8¯Ä+ 0#˜2?k1‰ rª"×œÔ Ñ§Ê”×O&ù:ÈuDGOÝÊsR™ìgLø¹
”xûýŸÜ”`²'´òE,Á{K39Ö	·OÀçœB…+ëÁžtYšRWœî7`—Ö€°‚R`ÆQºç%¬5f&:ÞózAnÅ!Ž9“ÔOZ ŸÅòfC0¢Ž‹‰‡é$Ùc¦`oÑ¯ÀŠa"ãX*/1c«€À¡àqDøB¾Yú ŽÝÁAôì~&~_¨lgÔ›Buqò‚ÊlŽä/}Ø¢c€Ç{S×iþX8úDþpv¸jÄ³>/.x„À Á ³/JWkRÄ¥“Þùöƒï›²/;ñ¤“}fÅ“%¨¬ÿ³óXŸ]¾àØÕ÷ÿB­t>ÕÄª @ñ68~ëíË6ûNv\–}†žEN±f4àdÊGNNÐušd®„«=À¢7þƒ[rN˜!q$Ž`AFnMR§ßœ¿r)šò1ÓÕ¨F[ïž.íNjgI Üð‘‘Sô.¯ê´n†@DßÉ×«|dýÎx_áo~ÃrMeµå~éHU[AUã:íºØíÛ=ž¯Á.´¼/–e' ÕV:B®9ƒJ‡ð¡Òjâ})CKäcÃÕ
¤«¯*àXºÂ©³ìæâöºU/$K:©¾NàE`
Å½xx‰l
 ”ë-Âz‹T?g’£Aâµ ¡±²à º£žmÃ¢-° WRøéjû»&«Ó½ÄÚèä	 ÚXeÚõóüÄó
{äk"ëO€Àç!lxÚdƒ=í~Øöºùbî÷ ­AmB«fÕ/€³þ¨¿øØœí²O"ˆ²PDyhëÐf¼º$Ž€H§nÌ9>éÄ[°Bm -6$–‰TÞžÐ¯Eml¢ó	^ŸXˆ
)…–_]°2•èªS@Ôè!ýÞšéGãGPK<0ã‰1Ç
}u®ZÙÃá´›ŸÖCèl%¥†¤û•”Áž»ÑC´¾ö"ÇÕ‚/Œï™K¼æÊörV1&
î.ž‚U0îå@;”-¿5p©…Èòëi hÝ¥ù)a/ˆüs9êZ‰KŽ)ë›‚­	º$H\qØve…ëFþwhŸWnÝ„‹N“I9€ÿçoý!!2‘þúqA#ôÁüÑ¤Ð}VÄØúK×:°C¤½1Yæ«:¬ªfÇç»óyÍÍ[s

3}ÀI{GWAâÐUqu¹ÑáÄvÙ,Æ÷v„QÒÞQq[iA ÆD±…$í1l‡[ßj|OÒuÙ#;TÓ£ÇÌ&•ˆƒU¦PÐÀŸA\öeÙ‚Ù(âlrÕå#¬?Î ¹õéÑÎÛ^F		•TL^J£ÐZ¼/Íc“×í5Ë¸JwýÍ(}öØ¹Ó^I
ë†O¥?{‹ }d„ûw’u÷YepÎFÒßÅ×IÙ÷&ƒÒþÜÔ	cßˆcõ˜»`à1;*å%¸>ÃGÚý’BWT&OÏÔSäªª ýØç™™cÞ®_Tr@‹9ó+) ¾«fgò 4.·…m±.ixøzßìvº|¾0{"ÄÝ{Î¨
]Y¤¢HøwÊ:è*Ñ™FÑH?çBÿÙ[Y•§Ã=šÖÁf†[n›hN¨²UH8µW ž"öv&H›Ñ½°è²7X7%™Þ9hU™¤)¡¼…/îš­ìË§Ò+K¼)‹l“¸vy³o[ÇOU£áË¦o!ÅI~ L¥±
O()?ÀSv'‰¢X- ?ô‡PÙ«·C¨Ø7o‹â13W¹Îžë4ñMú±ÔP3Þ¦OõüÄû&ž3-t ÝLEôÈ´jðéÿbï•—I¾f£OBâÚAÞü„ÏvV3fßx…PW@[îk&Ý½v0¾”“‡‚Ð©ÖìoO”Ë«?MÙË¹©cî9g<¹"„2QqJ@± ûšJaõ·òõ}­ålf#hþF’LZëly_ëº™³›¿â°wá¡ÀÔ–a^Ü»¸k/tFñÒ¸Çq°¸%ÃÒ“dôò‚âÐV½RœêÕâ5 ‚lØ7ÐäàyŠÌãiUÔÒ•¥0«—¹f¬!¬t{è>§ìâ¿T%DN+¨lZUŠKÒWxxÐïÎäÍ
ÜYR_A·ºûü	ã5PU	N†®‰ ‘ål;3häì#0ÿ2‘SXÖ
flMh1GbA)rÛ¡ cxûAƒcC¸eÎôµ&`ÐfD!UDÊ¡gè®Ø6Y1>ž @¹¶Ç1ÖÇ’y¾Ó-l?~â`"›éÜàÚPC"Ù¥mk3ë6{GSµ‰Ôs™ûÔ½nOïÂ¿	Ìê%ìýå‹Þa>‡‹Åâÿæ¬™ã         Ì  xœ¥—MŽó6†×ò)rø/Ò»^ '˜M¢@íê»?J&Í×ÈvœÉãÝð)þ¼T°aþýh¿üþ×Ÿ7’Ð’
ÑŠ±‚uUµöùëÏoáÆïCÒä}H›¾Y³÷¡ÑÆûfò¾¿™ÉÜù»Œ4ºeï· &>€/ +Ú
Úƒ1fLñ70kDßÀF#üæiù
,Z}ïbéŠZêó¤¯ßL`£}?ØS£}+Øs£}?œØg/Ä;öÚÞ±·Æûž>±é{o¼—[áhUZ;fåŒf,ïä'&+y‡<Æ,UÐx/!¯1l|Xô5>¬ý
,õ°^`Òø°^`Úä°!^`Öä°/^`£Éa{œcy¯Šñ¯êñFÒŒ×´dè ®KNå×ôýð$_»z@ªÁ-@oûÔ¿sžrw3á¸o:¨Uâyã
`•'á•­“!šßØþ”Î‚â¼(ÞNÜ)¤]ViÝEÝ`4¥ÚOÏ0‘ÊqF>¯(Ã–-ã‡`@s·øõ
¥K]ºk¶ûä0Z~vtóG‡ÿç¿‹Á=ºÝ50ˆ• ‡˜øqr¯VHUÕp¥%Õ©¤e—%Ä
a©rgŒp™³Ä%– ]WUµ»Ä™’’äcJ®ÝÜpãKkQœPhÝ€ƒç
iVò£t6T6!ŽÚ’'”pŽ¹g_Ì˜×²<ÁÔ»ÀØ¼ð¢væS,
˜qè,*š=5P+û9”9cÃ@7EÙ9·ôC(‹ªüÀZNsªMF
Aó 5Ù=ÁR+
«HSW†ägŒ›ì|f_ÓpšGiHyÓ[¤
©{qT? +9©M’=6Ò%Â¦]†–K}tyÅhÔg©Ùµ1Â7‘Z­sÞcQB—J(Ò=|V™QkRžP9AY÷¼mé^S'cüˆQÅˆŒ÷´<1cïaaKæýzâ“@èªÓº™HõVs²I¿\¯¼w
hÓ¹ôw)Ia*¡¿ï¸©àcÀêD"fžÉwƒäœï…M®˜~4«–^ök¨ÒíÐ]„²ãÝz‰Dîæ\¡Kê„Ø±«ê«œÕ4M=qüÇ=e  èRýG'jŸ“Œ”Ê0ôüDÒj±²ÈhÊG:?Q±ÇÐ—'¦päX.ž³¿ù-ôh"“™‡)»Ýøãœ
‹ØÈ¡gìr†Izc6Ÿ› «gz†©d#6¿…\›§XíÅ|šY¾86Xþ¾ö3ŒF–CS'gl4‹3,‡’b³Xü:iO1«E›3âÙÛg_–ån¢‹r         
  xœ”KnÛ0†×Ô)tœá[;÷‰.ÚEî²ÉÄ+¬4—ê*GðÅ:Rd[q Ô.À
g†œ?R³E¼kë2}ß?‡vS¥§ˆfßVÕv±.ã&œ
sÍvlîË-Cj&ôL`*DÖVŒ2¾Ë€ÏÀf(¹ ƒR³›4Ï>?›¶X•ÕöØzòlù”.Ÿf÷qÛ2vûjÛé†ï¢¨e&ˆFr#•Õ>1lÞ†rWÕû?Åb2½ ?ãCUï±¨WëÑ‚Ü\¦…aØ5 ™¡ç„’fÐ^¶(›]M ß?ŸÄ(ŽñPÕz”E¸‹ç+r¸îBPdÚgÜjÂ È>U«¸ÝÅ#ÀaŽ}ë/å&6‡šéJ.n©û³ëîìN
ƒö•8f&E¤l&
÷ œ‚D±¯±!0ÃTõ,óßE†Š\]:êd3„¢Ð©)%9¥À$’Í›ØŒP†©ìQdøØ.ãâaë8æò2¢‘1È•h¸²Ò£ž$¢§ˆ,ë,Ùt>,«#Ö8f_d"Ã–q\Û«Ù:ÁH-o¥„)6
ÜZèGÝV½ÚÐ¿c²Ì/Äô<åÞ¾¯³’Üý¯6\ säí)^E_€´h€|D zÈ_M¬›QiNñÛ·F§‹”¡ã^*rò Ú]£àV˜¾lí¸vZ8—Üð$IþØŽ         P  xœ•’InÃ †×ø\ÀÖÃ1žvVU]4ê°ÍaQÙP1äNYtÕ#øb%4é¤Dª%$ô€÷ýðÙê¬°Ú G/§ƒÂx'¬“Z1,Ì½±÷B9sœÌüÀð^çÙ€ê–÷wk”C^¤@SB0@ Ú¬¿Ç6¡¨ó½t!åöLö¹6½±È¶Ò:1²X‚º~”*ôÖ ø¯*2Ÿg2]R¢®ölð
q.ð3ÂbÆY?FÉµq×-5"ÅQ´PX¼î]´üjÂNô”¸s —Ó»šP¡'Áõ(TZµ­Ú"vtrjoRX`Ò´9ms’Õ¤‚¢:õ_;F3¨¡‚2Ô83» &ºuï‡ø
óçœ»†/ ++XÍŸ·,ârñ‹þõ_OÐP
PÓ¦8nÓHšW˜Ê–Ò¬,+RÖ_Ù›,I’0>àu         ì  xœµ”Án7†ÏôSìTÄÌp†Còd!(Š‰ƒè-î.é*¬B²SØOßY;q$µÚCžvÉÝo¾ù9ÉAF¡œ@³«w·m[ëÝS½¾ÝÕÍÖOûk˜uB˜kN Ò<¥)ô©Qç,
ÑuwïHVV”ÂÂ©xÒ¨\w›»/pEy P
¢Ä!æS‚óÏ”<k¶ÿ¸7ËB×¯Ø©CdMÄµíñÑöóasûÐž×·¾Í¾MêLb‡cEŒm=«=m=c~%çäÂ@P$fŸ™³©y%·
º
0 XÖYM/´Tlõæ$…ü£`ˆ‹L©Šëõáx¿÷Ÿë¶ÚÓþxR‚ö$Ð:äq%L,-c¤*Ýü¶¿•€Bd1Bø7%ü‡7
{tlH’Ùµyn ¿ÛßÝïëçSrN	­G€ iV®Ó”¤*Ð*²ö“ØÄÈ ºÈ§¸Œ$gÙ,¨–™ÂÑgâ¨ùâü3AŸQ¬‡/±YÀÉ‰	€1%KÝ¡öÚ¶~·9Ô»¹Öò™F¬›ñçQ“e Íh¨±10*ÂEÈkÊJÿ‡óì–z³±ûùÇõÍ›õ¯ïÖ¿üööæÃõOï×oßù7Þ;HªØ‚]ÔÄª½§ 2óœÆ8rïtŽžj·ØK’ã…tÄ%×lµe»«9Z®_t~“ŠèÂbÕL¥è>ííßýT÷‡ýé]ÄžÇZ¤Ì–|‰§‘!×b¸Œæ"©@öbâït[´`2þK¼äÒóI
YŸéü®}ÚÔÉÐ~ø:&2ZTçšºHNÚê82Ç>Ö*~“†`#l C
%d#_Jƒ8€IË…Õ Í6H¾l8÷æ¾>>¶ißfÿgOf.!êd³JlÙ­	f­Bcó‡}:·…ºØ²‘jwÃæYOÖ'H¶‡ø§ÉeGã21—€žÀk‡Æþêêê/ùnqŒ         
   xœ‹Ñãââ Å ©         õ   xœµ’1nAEkösña`º\ 'p)MŠ¤òýì(²5N%‚ÿ
 ¡âéõýíƒ„eìl;KcÎkÒéù–çMè/wÝsWnøîþMå¼)Ù?L4Èÿ|ªÑQqß;{cIã„tƒêËÚœ‚tPK>R5‡öÉâ|,Ð,÷FfÌ‡Å¸‘z5iÑ#à²€G¸©Õ=±­ ‰äÑa`ÓŠ‚Æ¢v%%"KP¢WÍ¦-$˜*u,L41èjÃ°º.˜ýŒy*ºëp+&eÔÊ.h@š)b>*]4Q¯Ÿo<ÓfJ¡âbë-N}Û¶Oàk§\      9   
   xœ‹Ñãââ Å ©      ?   
   xœ‹Ñãââ Å ©      =   
   xœ‹Ñãââ Å ©      5   
   xœ‹Ñãââ Å ©      3   
   xœ‹Ñãââ Å ©      ;   
   xœ‹Ñãââ Å ©      7   
   xœ‹Ñãââ Å ©     