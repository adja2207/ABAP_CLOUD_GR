CLASS zcl_ext_update_ent_2914 DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
  INTERFACES if_oo_adt_classrun.

  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS zcl_ext_update_ent_2914 IMPLEMENTATION.
  METHOD if_oo_adt_classrun~main.
   MODIFY ENTITIES OF z_i_travel2914
          ENTITY Travel
          UPDATE FIELDS ( AgencyId description )
          WITH VALUE #( ( TravelId = '00000015'
                          AgencyId = '70007'
                          Description = 'PRUEBA UPDATE GR') )
                  FAILED DATA(failed)
                  REPORTED DATA(reported).

   read ENTITIES OF z_i_travel2914
          ENTITY Travel
          FIELDS ( AgencyId description )
          WITH VALUE #( ( TravelId = '00000015') )
                  RESULT DATA(lt_travel_data)
                  FAILED failed
                  REPORTED reported.
   COMMIT ENTITIES.
   IF failed IS INITIAL.
   OUT->write( 'Commit Successfull' ).
   ELSE.
      OUT->write( 'Commit Failed' ).
   ENDIF.

  ENDMETHOD.

ENDCLASS.
