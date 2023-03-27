CLASS lhc_Supplement DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.
    METHODS calculateTotalSupplPrice FOR DETERMINE ON MODIFY
      IMPORTING keys FOR Supplement~calculateTotalSupplPrice.

ENDCLASS.

CLASS lhc_Supplement IMPLEMENTATION.

METHOD calculateTotalSupplPrice.
    IF NOT keys IS INITIAL.
      zcl_aux_trav_det_2914=>calculate_price( it_travel_id =
      VALUE #( FOR GROUPS <booking_suppl> OF booking_key IN keys
             GROUP BY booking_key-TravelId WITHOUT MEMBERS ( <booking_suppl> ) ) ).
    ENDIF.
ENDMETHOD.

ENDCLASS.
