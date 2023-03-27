CLASS lhc_Booking DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS calculateTotalFlightPrice FOR DETERMINE ON MODIFY
      IMPORTING keys FOR Booking~calculateTotalFlightPrice.

    METHODS validateStatus FOR VALIDATE ON SAVE
      IMPORTING keys FOR Booking~validateStatus.

    METHODS get_instance_features FOR INSTANCE FEATURES
      IMPORTING keys REQUEST requested_features FOR Booking RESULT result.

ENDCLASS.

CLASS lhc_Booking IMPLEMENTATION.

  METHOD calculateTotalFlightPrice .
    IF NOT keys IS INITIAL.
      zcl_aux_trav_det_2914=>calculate_price( it_travel_id =
      VALUE #( FOR GROUPS <booking> OF booking_key IN keys
             GROUP BY booking_key-TravelId WITHOUT MEMBERS ( <booking> ) ) ).
    ENDIF.
  ENDMETHOD.

  METHOD validateStatus.

    READ ENTITY z_i_travel2914\\Booking
    FIELDS ( BookingStatus )
    WITH VALUE #( FOR  <row_key> IN keys ( %key = <row_key>-%key ) )
    RESULT DATA(lt_booking_result).
    LOOP AT lt_booking_result INTO DATA(ls_booking_result).

      CASE ls_booking_result-BookingStatus.
        WHEN 'N'.
        WHEN 'B'.
        WHEN 'X'.
        WHEN OTHERS.
          APPEND VALUE #( %key = ls_booking_result-%key ) TO failed-booking.
          APPEND VALUE #( %key = ls_booking_result-%key
                          %msg = new_message( id = 'Z_MC_TRAVEL2914'
                                               number = '007'
                                               v1 = ls_booking_result-BookingId
                                               severity = if_abap_behv_message=>severity-error )
                          %element-BookingStatus = if_abap_behv=>mk-on
                          ) TO reported-booking.

      ENDCASE.
    ENDLOOP.

  ENDMETHOD.
  METHOD get_instance_features.

    READ ENTITIES OF z_i_travel2914 IN LOCAL MODE
    ENTITY Booking
    FIELDS ( BookingId BookingDate CustomerId BookingStatus )
    WITH VALUE #( FOR keyval IN keys ( %key = keyval-%key ) )
    RESULT DATA(lt_booking_result).

    result = VALUE #( FOR ls_travel IN lt_booking_result (
    %Key = ls_travel-%key
    %assoc-_BookingSupplement =  if_abap_behv=>fc-o-enabled ) ).

  ENDMETHOD.
ENDCLASS.
