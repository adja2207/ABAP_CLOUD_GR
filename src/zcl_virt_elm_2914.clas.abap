CLASS zcl_virt_elm_2914 DEFINITION
  PUBLIC

  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
  INTERFACES if_sadl_exit_calc_element_read.

  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS zcl_virt_elm_2914 IMPLEMENTATION.


  METHOD if_sadl_exit_calc_element_read~get_calculation_info.
   if iv_entity = 'Z_C_TRAVEL2914'.
   loop at it_requested_calc_elements into data(ls_calc_elements).
   IF ls_calc_elements = 'DISCOUNTPRICE'.
   APPEND 'TOTALPRICE' TO et_requested_orig_elements.
   ENDIF.
   ENDLOOP.
   ENDIF.

  ENDMETHOD.

  METHOD if_sadl_exit_calc_element_read~calculate.
   DATA: lt_original_data type STANDARD TABLE OF z_c_travel2914 with DEFAULT KEY.
    lt_original_data = CORRESPONDING #( it_original_data ).
        LOOP AT lt_original_data ASSIGNING FIELD-SYMBOL(<ls_original_data>).
        <ls_original_data>-DiscountPrice = <ls_original_data>-TotalPrice - ( <ls_original_data>-TotalPrice * ( 1 / 10 ) ).

        ENDLOOP.
         ct_calculated_data  = CORRESPONDING #( lt_original_data ).
  ENDMETHOD.
ENDCLASS.
