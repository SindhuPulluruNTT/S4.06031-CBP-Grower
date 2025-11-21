METHOD /IWXBE/IF_CONSUMER~HANDLE_EVENT.

  " This is a generated class, which might be overwritten in the future.
  " Go to ZPRCL_IL to add custom code.

  CASE io_event->get_cloud_event_type( ).
    WHEN 'sap.s4.beh.inspectionlot.v1.InspectionLot.Canceled.v1'.
      me->ZPRIF_IL_HANDLER~handle_inspectionlot_canc_FA8B( NEW LCL_INSPECTIONLOT_CANCELED_V1( io_event ) ).
    WHEN 'sap.s4.beh.inspectionlot.v1.InspectionLot.Changed.v1'.
      me->ZPRIF_IL_HANDLER~handle_inspectionlot_chan_5701( NEW LCL_INSPECTIONLOT_CHANGED_V1( io_event ) ).
    WHEN 'sap.s4.beh.inspectionlot.v1.InspectionLot.Created.v1'.
      me->ZPRIF_IL_HANDLER~handle_inspectionlot_crea_A664( NEW LCL_INSPECTIONLOT_CREATED_V1( io_event ) ).
    WHEN 'sap.s4.beh.inspectionlot.v1.InspectionLot.OperationCreated.v1'.
      me->ZPRIF_IL_HANDLER~handle_inspectionlot_oper_9AE4( NEW LCL_INSPECTIONLOT_OPERATI_E07B( io_event ) ).
    WHEN OTHERS.
      RAISE EXCEPTION TYPE /iwxbe/cx_exception
        EXPORTING
          textid = /iwxbe/cx_exception=>not_supported.
  ENDCASE.

ENDMETHOD.