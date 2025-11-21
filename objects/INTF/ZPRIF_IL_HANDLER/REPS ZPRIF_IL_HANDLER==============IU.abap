interface ZPRIF_IL_HANDLER
  public .


  methods HANDLE_INSPECTIONLOT_CANC_FA8B
    importing
      !IO_EVENT type ref to ZPRIF_INSPECTIONLOT_CANCE_ACF8
    raising
      /IWXBE/CX_EXCEPTION .
  methods HANDLE_INSPECTIONLOT_CHAN_5701
    importing
      !IO_EVENT type ref to ZPRIF_INSPECTIONLOT_CHANGED_V1
    raising
      /IWXBE/CX_EXCEPTION .
  methods HANDLE_INSPECTIONLOT_CREA_A664
    importing
      !IO_EVENT type ref to ZPRIF_INSPECTIONLOT_CREATED_V1
    raising
      /IWXBE/CX_EXCEPTION .
  methods HANDLE_INSPECTIONLOT_OPER_9AE4
    importing
      !IO_EVENT type ref to ZPRIF_INSPECTIONLOT_OPERA_894A
    raising
      /IWXBE/CX_EXCEPTION .
endinterface.