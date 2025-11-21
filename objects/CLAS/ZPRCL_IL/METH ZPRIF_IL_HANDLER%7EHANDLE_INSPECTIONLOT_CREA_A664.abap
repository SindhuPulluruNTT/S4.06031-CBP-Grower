METHOD ZPRIF_IL_HANDLER~HANDLE_INSPECTIONLOT_CREA_A664.

  " Event Type: sap.s4.beh.inspectionlot.v1.InspectionLot.Created.v1
   DATA ls_business_data TYPE STRUCTURE FOR HIERARCHY ZPR_InspectionLot_Created_v1.
*
*
   ls_business_data = io_event->get_business_data( ).



ENDMETHOD.