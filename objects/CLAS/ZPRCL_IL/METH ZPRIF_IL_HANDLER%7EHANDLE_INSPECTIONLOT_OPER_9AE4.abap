METHOD ZPRIF_IL_HANDLER~HANDLE_INSPECTIONLOT_OPER_9AE4.

  " Event Type: sap.s4.beh.inspectionlot.v1.InspectionLot.OperationCreated.v1
   DATA ls_business_data TYPE STRUCTURE FOR HIERARCHY ZPR_InspectionLot_Operati_E07B.
*
*
   ls_business_data = io_event->get_business_data( ).



ENDMETHOD.