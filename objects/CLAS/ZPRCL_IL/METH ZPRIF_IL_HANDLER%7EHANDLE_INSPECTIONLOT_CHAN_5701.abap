METHOD ZPRIF_IL_HANDLER~HANDLE_INSPECTIONLOT_CHAN_5701.

  " Event Type: sap.s4.beh.inspectionlot.v1.InspectionLot.Changed.v1
   DATA ls_business_data TYPE STRUCTURE FOR HIERARCHY ZPR_InspectionLot_Changed_v1.
*
*
   ls_business_data = io_event->get_business_data( ).



ENDMETHOD.