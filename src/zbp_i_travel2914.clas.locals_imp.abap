CLASS lhc_Travel DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

*Acciones
    METHODS acceptTravel FOR MODIFY
      IMPORTING keys FOR ACTION Travel~acceptTravel RESULT result.
    METHODS regectTravel FOR MODIFY
      IMPORTING keys FOR ACTION Travel~regectTravel RESULT result.
    METHODS CreateTravelByTemplate FOR MODIFY
      IMPORTING keys FOR ACTION Travel~CreateTravelByTemplate RESULT result.


    METHODS get_instance_features FOR INSTANCE FEATURES
      IMPORTING keys REQUEST requested_features FOR Travel RESULT result.

    METHODS get_instance_authorizations FOR INSTANCE AUTHORIZATION
      IMPORTING keys REQUEST requested_authorizations FOR Travel RESULT result.

*Validaciones
    METHODS validateCustomer FOR VALIDATE ON SAVE
      IMPORTING keys FOR Travel~validateCustomer.

    METHODS validateDates FOR VALIDATE ON SAVE
      IMPORTING keys FOR Travel~validateDates.

    METHODS validateStatus FOR VALIDATE ON SAVE
      IMPORTING keys FOR Travel~validateStatus.

ENDCLASS.

CLASS lhc_Travel IMPLEMENTATION.

  METHOD get_instance_features.

    READ ENTITIES OF z_i_travel2914 IN LOCAL MODE
    ENTITY Travel
    FIELDS ( TravelId OverallStatus )
    WITH VALUE #( FOR key_row IN keys ( %key = key_row-%key ) )
    RESULT DATA(lt_travel_result).

    result = VALUE #( FOR ls_travel IN lt_travel_result (

    %Key = ls_travel-%key
*Sentencia para deshabilitar el campo
    %field-TravelId =      if_abap_behv=>fc-f-read_only
    %field-OverallStatus = if_abap_behv=>fc-f-read_only
    %action-acceptTravel = COND #( WHEN ls_travel-OverallStatus = 'A'
*deshabilitar y habilitar el campo
                                   THEN if_abap_behv=>fc-o-disabled
                                   ELSE if_abap_behv=>fc-o-enabled )
    %action-regectTravel = COND #( WHEN ls_travel-OverallStatus = 'X'
*deshabilitar y habilitar el campo
                                   THEN if_abap_behv=>fc-o-disabled
                                   ELSE if_abap_behv=>fc-o-enabled ) ) ).



  ENDMETHOD.

  METHOD get_instance_authorizations.
*  data lv_authh type c LENGTH 2.
*  data(lv_user) = cl_abap_context_info=>get_user_technical_name(  ).
* if lv_user eq 'CB9980008693'.
*  lv_authh = if_abap_behv=>auth-allowed.
* else.
* lv_authh  = if_abap_behv=>auth-unauthorized.
*endif.

*CB9980008693
    DATA(lv_auth) = COND #( WHEN cl_abap_context_info=>get_user_technical_name(  ) EQ 'CB9980008693'
                       THEN if_abap_behv=>auth-allowed
                       ELSE if_abap_behv=>auth-unauthorized ).

    LOOP AT keys ASSIGNING FIELD-SYMBOL(<ls_keys>).

      APPEND INITIAL LINE TO result ASSIGNING FIELD-SYMBOL(<ls_result>).

      <ls_result> = VALUE #( %key = <ls_keys>-%key
                             %op-%update                    = lv_auth
                             %delete                        = lv_auth
                             %action-acceptTravel           = lv_auth
                             %action-regectTravel           = lv_auth
                             %action-createTravelByTemplate = lv_auth
                             %assoc-_Booking                = lv_auth ).
    ENDLOOP.

  ENDMETHOD.

  METHOD acceptTravel.


*MODIFY LOCAL MODE - BO - related updates there are not relevant for autorization objects
    MODIFY ENTITIES OF z_i_travel2914 IN LOCAL MODE
    ENTITY Travel
    UPDATE FIELDS ( OverallStatus )
    WITH VALUE #( FOR key_row IN keys ( TravelId = key_row-TravelId
                                        OverallStatus = 'A' ) )
                                        FAILED failed
                                        REPORTED reported.
    READ ENTITIES OF z_i_travel2914 IN LOCAL MODE ENTITY Travel
    FIELDS ( AgencyId
             CustomerId
             BeginDate
             EndDate
             BookingFee
             TotalPrice
             CurrencyCode
             OverallStatus
             Description
             CreatedAt
             CreatedBy
             LastChangedAt
             LastChangedBy )
        WITH VALUE #( FOR key_row1 IN Keys ( %Key  = key_row1-%key ) )
        RESULT DATA(it_travel)
        FAILED failed
        REPORTED reported.
    result = VALUE #( FOR ls_travel IN  it_travel ( TravelId = ls_travel-TravelId
                               %param = ls_travel ) ) .
*Accepted
    LOOP AT it_travel ASSIGNING FIELD-SYMBOL(<ls_travel>).
      DATA(lv_travel_msg) =  <ls_travel>-TravelId.
*Eliminar los 0
      SHIFT lv_travel_msg LEFT DELETING LEADING '0'.

      APPEND VALUE #( TravelId = <ls_travel>-TravelId
                      %msg = new_message( id = 'Z_MC_TRAVEL2914'
                                           number = '005'
                                           v1 = lv_travel_msg
                                           severity = if_abap_behv_message=>severity-success )
                      %element-customerID = if_abap_behv=>mk-on ) TO reported-travel.
    ENDLOOP.
  ENDMETHOD.

  METHOD CreateTravelByTemplate.
*Estructura de entrada
* keys[ 1 ]-TravelId
*Estructura que se van a devolver
* Result [ 1 ]-TravelId
*Mapear los valores de las entidades a las cuales tiene referencia
*Mapped-
*Para tener una acceso a lo que devolvemos cuando falla alguna asociacion
*Failed-
*Para reportar los fallos y devolver mensajes
*Reported-

*Lectura con EML
    READ ENTITIES OF z_i_travel2914
        ENTITY Travel
        FIELDS ( TravelId  AgencyId CustomerId BookingFee TotalPrice CurrencyCode )
        WITH VALUE #( FOR row_key IN Keys ( %Key  = row_key-%key ) )
        RESULT DATA(it_entity_travel)
        FAILED failed
        REPORTED reported.
*    READ ENTITIES OF z_i_travel2914
*        FIELDS ( TravelId  AgencyId CustomerId BookingFee TotalPrice CurrencyCode )
*        WITH VALUE #( FOR row_key IN Keys ( %Key  = row_key-%key ) )
*        RESULT it_read_entity_travel
*        FAILED failed
*        REPORTED reported.
    CHECK failed IS INITIAL .

    DATA it_create_travel TYPE TABLE FOR CREATE z_i_travel2914\\Travel.
    DATA(lv_today) = cl_abap_context_info=>get_system_date(  ).

    SELECT MAX( travel_id ) FROM ztravel_log_2914
    INTO @DATA(lv_travel_id).
    it_create_travel = VALUE #( FOR create_row IN  it_entity_travel INDEX INTO idx
                              ( TravelId        = lv_travel_id + idx
                                AgencyId        = create_row-AgencyId
                                CustomerId      = create_row-CustomerId
                                BeginDate       = lv_today
                                EndDate         = lv_today + 30
                                BookingFee      = create_row-BookingFee
                                TotalPrice      = create_row-TotalPrice
                                CurrencyCode    = create_row-CurrencyCode
                                Description     = 'Add Comennts'
                                OverallStatus   = 'O' ) ) .
    MODIFY ENTITIES OF z_i_travel2914
    IN LOCAL MODE ENTITY Travel
    CREATE FIELDS ( TravelId
                    AgencyId
                    CustomerId
                    BeginDate
                    EndDate
                    BookingFee
                    TotalPrice
                    CurrencyCode
                    Description
                    OverallStatus )
                    WITH it_create_travel
                    MAPPED mapped
                    FAILED failed
                    REPORTED reported.

* Devolvemos los resultados a la interfaz con Result y debes declarar otra tabla diferente en este caso sera Result_row
    result = VALUE #( FOR result_row IN  it_create_travel INDEX INTO idx
                              ( %cid_ref = keys[ idx ]-%cid_ref
                                %key = keys[ idx ]-%key
*Devolvemos los resultados completos sin necesidad de llamarlos uno a uno
*con la sentencia CORRESPONDING y la estructura Result_row
                                %param = CORRESPONDING #( result_row ) ) ) .
  ENDMETHOD.

  METHOD regectTravel.
*MODIFY LOCAL MODE - BO - related updates there are not relevant for autorization objects
    MODIFY ENTITIES OF z_i_travel2914 IN LOCAL MODE
    ENTITY Travel
    UPDATE FIELDS ( OverallStatus )
    WITH VALUE #( FOR key_row IN keys ( TravelId = key_row-TravelId
                                        OverallStatus = 'X' ) )
                                        FAILED failed
                                        REPORTED reported.
    READ ENTITIES OF z_i_travel2914 IN LOCAL MODE ENTITY Travel
    FIELDS ( AgencyId
             CustomerId
             BeginDate
             EndDate
             BookingFee
             TotalPrice
             CurrencyCode
             OverallStatus
             Description
             CreatedAt
             CreatedBy
             LastChangedAt
             LastChangedBy )
        WITH VALUE #( FOR key_row1 IN Keys ( %Key  = key_row1-%key ) )
        RESULT DATA(it_travel)
        FAILED failed
        REPORTED reported.
    result = VALUE #( FOR ls_travel IN  it_travel ( TravelId = ls_travel-TravelId
                               %param = ls_travel ) ) .
*Rejected
    LOOP AT it_travel ASSIGNING FIELD-SYMBOL(<ls_travel>).
      DATA(lv_travel_msg) =  <ls_travel>-TravelId.
*Eliminar los 0
      SHIFT lv_travel_msg LEFT DELETING LEADING '0'.

      APPEND VALUE #( TravelId = <ls_travel>-TravelId
                      %msg = new_message( id = 'Z_MC_TRAVEL2914'
                                           number = '006'
                                           v1 = lv_travel_msg
                                           severity = if_abap_behv_message=>severity-success )
                      %element-customerID = if_abap_behv=>mk-on ) TO reported-travel.
    ENDLOOP.
  ENDMETHOD.

  METHOD validateCustomer.
    READ  ENTITIES OF z_i_travel2914 IN LOCAL MODE
    ENTITY Travel
    FIELDS ( CustomerId )
    WITH CORRESPONDING #( keys )
    RESULT DATA(lt_travel).

    DATA lt_customer TYPE SORTED TABLE OF /dmo/customer WITH UNIQUE KEY customer_id.

    lt_customer = CORRESPONDING #(  lt_travel DISCARDING DUPLICATES MAPPING
    customer_id = CustomerId EXCEPT * ).

    DELETE lt_customer WHERE customer_id IS INITIAL.

    SELECT FROM /dmo/customer FIELDS customer_id
      FOR ALL ENTRIES IN @lt_customer
      WHERE customer_id EQ @lt_customer-customer_id
      INTO TABLE @DATA(lt_customer_db).

    LOOP AT lt_travel ASSIGNING FIELD-SYMBOL(<ls_travel>).

      IF <ls_travel>-CustomerId IS INITIAL
      OR NOT line_exists( lt_customer_db[ customer_id = <ls_travel>-CustomerId ] ).
* Fallo
        APPEND VALUE #( TravelId = <ls_travel>-TravelId ) TO failed-travel.
        APPEND VALUE #( TravelId = <ls_travel>-TravelId
                        %msg = new_message( id = 'Z_MC_TRAVEL2914'
                                             number = '001'
                                             v1 = <ls_travel>-TravelId
                                             severity = if_abap_behv_message=>severity-error )
                        %element-customerID = if_abap_behv=>mk-on ) TO reported-travel.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD validateDates.
    READ  ENTITY z_i_travel2914\\Travel
      FIELDS ( beginDate EndDate )
      WITH VALUE #( FOR  <row_key> IN keys ( %key = <row_key>-%key ) )

    RESULT DATA(lt_travel_result).

    LOOP AT lt_travel_result INTO DATA(ls_travel_result).
      IF ls_travel_result-endDate LT ls_travel_result-beginDate.

        APPEND VALUE #( %key = ls_travel_result-%key
                        travelID = ls_travel_result-TravelId ) TO failed-travel.

        APPEND VALUE #( %key = ls_travel_result-%key
                        %msg = new_message( id = 'Z_MC_TRAVEL2914'
                                             number = '003'
                                             v1 = ls_travel_result-BeginDate
                                             v2 = ls_travel_result-EndDate
                                             v3 = ls_travel_result-TravelId
                                             severity = if_abap_behv_message=>severity-error )
                        %element-beginDate = if_abap_behv=>mk-on
                        %element-endDate = if_abap_behv=>mk-on
                        ) TO reported-travel.
      ELSEIF  ls_travel_result-beginDate LT cl_abap_context_info=>get_system_date( ).

        APPEND VALUE #( %key = ls_travel_result-%key
                        travelID = ls_travel_result-TravelId ) TO failed-travel.

        APPEND VALUE #( %key = ls_travel_result-%key
                        %msg = new_message( id = 'Z_MC_TRAVEL2914'
                                             number = '002'
                                             v1 = ls_travel_result-BeginDate
                                             v2 = ls_travel_result-EndDate
                                             v3 = ls_travel_result-TravelId
                                             severity = if_abap_behv_message=>severity-error )
                        %element-beginDate = if_abap_behv=>mk-on
                        %element-endDate = if_abap_behv=>mk-on
                        ) TO reported-travel.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD validateStatus.

    READ ENTITY z_i_travel2914\\Travel
    FIELDS ( OverallStatus )
    WITH VALUE #( FOR  <row_key> IN keys ( %key = <row_key>-%key ) )
    RESULT DATA(lt_travel_result).
    LOOP AT lt_travel_result INTO DATA(ls_travel_result).

      CASE ls_travel_result-OverallStatus.
        WHEN 'O'.
        WHEN 'A'.
        WHEN 'X'.
        WHEN OTHERS.
          APPEND VALUE #( %key = ls_travel_result-%key ) TO failed-travel.
          APPEND VALUE #( %key = ls_travel_result-%key
                          %msg = new_message( id = 'Z_MC_TRAVEL2914'
                                               number = '004'
                                               v1 = ls_travel_result-TravelId
                                               severity = if_abap_behv_message=>severity-error )
                          %element-OverallStatus = if_abap_behv=>mk-on
                          ) TO reported-travel.

      ENDCASE.
    ENDLOOP.

  ENDMETHOD.

ENDCLASS.

CLASS lsc_Z_I_TRAVEL2914 DEFINITION INHERITING FROM cl_abap_behavior_saver.
  PUBLIC SECTION.
    CONSTANTS create TYPE string VALUE 'CREATE'.
    CONSTANTS update TYPE string VALUE 'UPDATE'.
    CONSTANTS delete TYPE string VALUE 'DELETE'.


  PROTECTED SECTION.

    METHODS save_modified REDEFINITION.

    METHODS cleanup_finalize REDEFINITION.

ENDCLASS.

CLASS lsc_Z_I_TRAVEL2914 IMPLEMENTATION.

  METHOD save_modified.

    DATA: lt_travel_log   TYPE STANDARD TABLE OF zlog_2914,
          lt_travel_log_u TYPE STANDARD TABLE OF zlog_2914.
    DATA(lv_user)  =  cl_abap_context_info=>get_user_technical_name(  ).

    IF NOT create-travel IS INITIAL.
      lt_travel_log = CORRESPONDING #( create-travel ).

      LOOP AT lt_travel_log ASSIGNING FIELD-SYMBOL(<ls_travel_log>).
*Para obtener el TIMESTAMP
        GET TIME STAMP FIELD <ls_travel_log>-created_at.
*Para obtener la operacion
        <ls_travel_log>-changing_operation = lsc_Z_I_TRAVEL2914=>create.
*INTO DATA PARA CREAR O COPIAR EL REGISTRO y nunca modificamos la tabla interna
        READ TABLE create-travel WITH TABLE KEY entity
        COMPONENTS TravelId = <ls_travel_log>-travel_id
        INTO DATA(ls_travel) .
        IF sy-subrc EQ 0.
          IF ls_travel-%control-BookingFee EQ cl_abap_behv=>flag_changed.
            <ls_travel_log>-changed_field_name  = 'booking_fee'.
            <ls_travel_log>-changed_value       = ls_travel-BookingFee.
            <ls_travel_log>-user_mod            = lv_user.
            TRY.
                <ls_travel_log>-change_id           = cl_system_uuid=>create_uuid_x16_static(  ).
              CATCH cx_uuid_error.
            ENDTRY.
            APPEND <ls_travel_log> TO lt_travel_log_u.
          ENDIF.

        ENDIF.

      ENDLOOP.

    ENDIF.


    IF NOT update-travel IS INITIAL.



      lt_travel_log = CORRESPONDING #( update-travel ).

      LOOP AT update-travel INTO DATA(ls_update_travel).
      ASSIGN lt_travel_log[ travel_id = ls_update_travel-TravelId ] TO FIELD-SYMBOL(<ls_travel_log_bd>).
        IF SY-SUBRC EQ 0.

        get TIME STAMP FIELD <ls_travel_log_bd>-created_at.
        <ls_travel_log>-changing_operation = lsc_Z_I_TRAVEL2914=>update.
        IF ls_update_travel-%control-CustomerId EQ cl_abap_behv=>flag_changed.
          <ls_travel_log_bd>-changed_field_name     = 'customer_id'.
          <ls_travel_log_bd>-changed_value          = ls_update_travel-CustomerId.
          <ls_travel_log_bd>-changed_value          = ls_update_travel-BookingFee.
          <ls_travel_log_bd>-user_mod               = lv_user .
          TRY.
              <ls_travel_log_bd>-change_id        = cl_system_uuid=>create_uuid_x16_static(  ).
            CATCH cx_uuid_error.
          ENDTRY.
          APPEND <ls_travel_log_bd> TO lt_travel_log_u.
        ENDIF.
        ENDIF.
      ENDLOOP.
    ENDIF.

    IF NOT delete-travel IS INITIAL.
      lt_travel_log = CORRESPONDING #( delete-travel ).
      LOOP AT lt_travel_log ASSIGNING FIELD-SYMBOL(<ls_travel_log_del>).
        GET TIME STAMP FIELD <ls_travel_log_del>-created_at.
        <ls_travel_log_del>-changing_operation = lsc_Z_I_TRAVEL2914=>delete.
        <ls_travel_log_del>-user_mod           = lv_user .
        TRY.
            <ls_travel_log_del>-change_id        = cl_system_uuid=>create_uuid_x16_static(  ).
          CATCH cx_uuid_error.
        ENDTRY.
        APPEND <ls_travel_log_del> TO lt_travel_log_u.
      ENDLOOP.

    ENDIF.

    IF NOT lt_travel_log_u IS INITIAL.
    INSERT zlog_2914 FROM TABLE @lt_travel_log_u.
    ENDIF.

  ENDMETHOD.

  METHOD cleanup_finalize.
  ENDMETHOD.

ENDCLASS.
