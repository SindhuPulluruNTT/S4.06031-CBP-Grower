CLASS LTC_CONSUMER DEFINITION FOR TESTING DURATION SHORT RISK LEVEL HARMLESS.
  PRIVATE SECTION.
    DATA:
      MO_CUT TYPE REF TO ZPRCL_IL.

    METHODS:
      SETUP,
      HANDLE_INSPECTIONLOT_CANC_FA8B FOR TESTING
        RAISING
          CX_STATIC_CHECK,
      HANDLE_INSPECTIONLOT_CHAN_5701 FOR TESTING
        RAISING
          CX_STATIC_CHECK,
      HANDLE_INSPECTIONLOT_CREA_A664 FOR TESTING
        RAISING
          CX_STATIC_CHECK,
      HANDLE_INSPECTIONLOT_OPER_9AE4 FOR TESTING
        RAISING
          CX_STATIC_CHECK.
ENDCLASS.

CLASS LTC_CONSUMER IMPLEMENTATION.
  METHOD SETUP.
  mo_cut = NEW #( ).
  ENDMETHOD.
  METHOD HANDLE_INSPECTIONLOT_CANC_FA8B.
*    DATA: lo_event_dbl TYPE REF TO ZPRIF_INSPECTIONLOT_CANCE_ACF8.
*
*    " Given is an event double
*    lo_event_dbl ?= cl_abap_testdouble=>create( 'ZPRIF_INSPECTIONLOT_CANCE_ACF8' ).
*
*    " which is prepared for the get_business_data call
*    cl_abap_testdouble=>configure_call( lo_event_dbl
*                     )->returning( VALUE ZPRIF_INSPECTIONLOT_CANCE_ACF8=>ty_s_inspectionlot_canceled_v1( )
*                     )->and_expect( )->is_called_once( ).
*    lo_event_dbl->get_business_data( ).
*
*    " When handle_inspectionlot_canc_FA8B is called
*    mo_cut->ZPRIF_IL_HANDLER~handle_inspectionlot_canc_FA8B( lo_event_dbl ).
*
*    " Then the event double has been called
*    cl_abap_testdouble=>verify_expectations( lo_event_dbl ).
  ENDMETHOD.
  METHOD HANDLE_INSPECTIONLOT_CHAN_5701.
*    DATA: lo_event_dbl TYPE REF TO ZPRIF_INSPECTIONLOT_CHANGED_V1.
*
*    " Given is an event double
*    lo_event_dbl ?= cl_abap_testdouble=>create( 'ZPRIF_INSPECTIONLOT_CHANGED_V1' ).
*
*    " which is prepared for the get_business_data call
*    cl_abap_testdouble=>configure_call( lo_event_dbl
*                     )->returning( VALUE ZPRIF_INSPECTIONLOT_CHANGED_V1=>ty_s_inspectionlot_changed_v1( )
*                     )->and_expect( )->is_called_once( ).
*    lo_event_dbl->get_business_data( ).
*
*    " When handle_inspectionlot_chan_5701 is called
*    mo_cut->ZPRIF_IL_HANDLER~handle_inspectionlot_chan_5701( lo_event_dbl ).
*
*    " Then the event double has been called
*    cl_abap_testdouble=>verify_expectations( lo_event_dbl ).
  ENDMETHOD.
  METHOD HANDLE_INSPECTIONLOT_CREA_A664.
*    DATA: lo_event_dbl TYPE REF TO ZPRIF_INSPECTIONLOT_CREATED_V1.
*
*    " Given is an event double
*    lo_event_dbl ?= cl_abap_testdouble=>create( 'ZPRIF_INSPECTIONLOT_CREATED_V1' ).
*
*    " which is prepared for the get_business_data call
*    cl_abap_testdouble=>configure_call( lo_event_dbl
*                     )->returning( VALUE ZPRIF_INSPECTIONLOT_CREATED_V1=>ty_s_inspectionlot_created_v1( )
*                     )->and_expect( )->is_called_once( ).
*    lo_event_dbl->get_business_data( ).
*
*    " When handle_inspectionlot_crea_A664 is called
*    mo_cut->ZPRIF_IL_HANDLER~handle_inspectionlot_crea_A664( lo_event_dbl ).
*
*    " Then the event double has been called
*    cl_abap_testdouble=>verify_expectations( lo_event_dbl ).
  ENDMETHOD.
  METHOD HANDLE_INSPECTIONLOT_OPER_9AE4.
*    DATA: lo_event_dbl TYPE REF TO ZPRIF_INSPECTIONLOT_OPERA_894A.
*
*    " Given is an event double
*    lo_event_dbl ?= cl_abap_testdouble=>create( 'ZPRIF_INSPECTIONLOT_OPERA_894A' ).
*
*    " which is prepared for the get_business_data call
*    cl_abap_testdouble=>configure_call( lo_event_dbl
*                     )->returning( VALUE ZPRIF_INSPECTIONLOT_OPERA_894A=>ty_s_inspectionlot_operat_0283( )
*                     )->and_expect( )->is_called_once( ).
*    lo_event_dbl->get_business_data( ).
*
*    " When handle_inspectionlot_oper_9AE4 is called
*    mo_cut->ZPRIF_IL_HANDLER~handle_inspectionlot_oper_9AE4( lo_event_dbl ).
*
*    " Then the event double has been called
*    cl_abap_testdouble=>verify_expectations( lo_event_dbl ).
  ENDMETHOD.
ENDCLASS.