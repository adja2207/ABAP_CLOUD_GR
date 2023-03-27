@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Interface de tipo entidad Booking'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity Z_I_BOOK2914
  as select from zbooking_2914 as Booking
  composition [0..*] of Z_I_BKSUP2914     as _BookingSupplement 
  association        to parent Z_I_TRAVEL2914    as _Tavel on $projection.TravelId = _Tavel.TravelId
  association [1..1] to /DMO/I_Customer   as _Customer      on $projection.CustomerId = _Customer.CustomerID
  association [1..1] to /DMO/I_Carrier    as _Carrier       on $projection.CarrierId  = _Carrier.AirlineID
  association [1..*] to /DMO/I_Connection as _Connection    on $projection.ConnectionID = _Connection.ConnectionID

{ 
  key travel_id       as TravelId,
  key booking_id      as BookingId,
      booking_date    as BookingDate,
      customer_id     as CustomerId,
      carrier_id      as CarrierId,
      connection_id   as ConnectionID,
      flight_date     as FlightDate,
      @Semantics.amount.currencyCode : 'CurrencyCode'
      flight_price    as FlightPrice,
      currency_code   as CurrencyCode,
      booking_status  as BookingStatus,
      last_changed_at as LastChangedAt,
      _Tavel,
      _BookingSupplement,
      _Customer,
      _Carrier,
      _Connection
}
