METHOD ZPRIF_IL_HANDLER~HANDLE_INSPECTIONLOT_CANC_FA8B.

  " Event Type: sap.s4.beh.inspectionlot.v1.InspectionLot.Canceled.v1
   DATA ls_business_data TYPE STRUCTURE FOR HIERARCHY ZPR_InspectionLot_Canceled_v1.
*
*
   ls_business_data = io_event->get_business_data( ).



ENDMETHOD.