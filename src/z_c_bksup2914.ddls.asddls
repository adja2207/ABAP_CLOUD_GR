@EndUserText.label: 'Consuption - Booking Supplement'
@AccessControl.authorizationCheck: #NOT_REQUIRED
@Metadata.allowExtensions: true
define view entity Z_C_BKSUP2914 
  as projection on Z_I_BKSUP2914

{
    key TravelId,
    key BookingId,
    key BookingSupplementId,
    SupplementId,
    _SupplementText.Description as SupplementDescription :localized,
      @Semantics.amount.currencyCode: 'CurrencyCode'
    Price,
    CurrencyCode,
    LastChangedAt,
    /* Associations */
    _Travel: redirected to Z_C_TRAVEL2914 ,
    _Booking: redirected  to parent Z_C_BOOK2914,
    _Product,
    _SupplementText

}
