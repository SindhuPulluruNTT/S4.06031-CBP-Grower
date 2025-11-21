CLASS lhc_rap_tdat_cts DEFINITION FINAL.
  PUBLIC SECTION.
    CLASS-METHODS:
      get
        RETURNING
          VALUE(result) TYPE REF TO if_mbc_cp_rap_tdat_cts.

ENDCLASS.

CLASS lhc_rap_tdat_cts IMPLEMENTATION.
  METHOD get.
    result = mbc_cp_api=>rap_tdat_cts( tdat_name = 'ZPOPRICINGCONDITIONT'
                                       table_entity_relations = VALUE #(
                                         ( entity = 'PoPricingConditionT' table = 'ZPR_TB_PO_PRICE' )
                                       ) ) ##NO_TEXT.
  ENDMETHOD.
ENDCLASS.
CLASS lhc_zi_popricingconditiont_s DEFINITION FINAL INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.
    METHODS:
      get_instance_features FOR INSTANCE FEATURES
        IMPORTING
                  keys   REQUEST requested_features FOR popricingconditiall
        RESULT    result,
      selectcustomizingtransptreq FOR MODIFY
        IMPORTING
                  keys   FOR ACTION popricingconditiall~selectcustomizingtransptreq
        RESULT    result,
      get_global_authorizations FOR GLOBAL AUTHORIZATION
        IMPORTING
        REQUEST requested_authorizations FOR popricingconditiall
        RESULT result,
      edit FOR MODIFY
        IMPORTING
          keys FOR ACTION popricingconditiall~edit,

      earlynumbering_create FOR NUMBERING
        IMPORTING entities_cba FOR CREATE popricingconditiall\_popricingconditiont.

ENDCLASS.

CLASS lhc_zi_popricingconditiont_s IMPLEMENTATION.
  METHOD get_instance_features.
    DATA: edit_flag            TYPE abp_behv_op_ctrl    VALUE if_abap_behv=>fc-o-enabled
         ,transport_feature    TYPE abp_behv_field_ctrl VALUE if_abap_behv=>fc-f-mandatory
         ,selecttransport_flag TYPE abp_behv_op_ctrl    VALUE if_abap_behv=>fc-o-enabled.

    IF lhc_rap_tdat_cts=>get( )->is_editable( ) = abap_false.
      edit_flag = if_abap_behv=>fc-o-disabled.
    ENDIF.
    IF lhc_rap_tdat_cts=>get( )->is_transport_allowed( ) = abap_false.
      selecttransport_flag = if_abap_behv=>fc-o-disabled.
    ENDIF.
    IF lhc_rap_tdat_cts=>get( )->is_transport_mandatory( ) = abap_false.
      transport_feature = if_abap_behv=>fc-f-unrestricted.
    ENDIF.
    result = VALUE #( FOR key IN keys (
               %tky = key-%tky
               %action-edit = edit_flag
               %assoc-_popricingconditiont = edit_flag
               %field-transportrequestid = transport_feature
               %action-selectcustomizingtransptreq = COND #( WHEN key-%is_draft = if_abap_behv=>mk-off
                                                             THEN if_abap_behv=>fc-o-disabled
                                                             ELSE selecttransport_flag ) ) ).
  ENDMETHOD.
  METHOD selectcustomizingtransptreq.
    MODIFY ENTITIES OF zi_popricingconditiont_s IN LOCAL MODE
      ENTITY popricingconditiall
        UPDATE FIELDS ( transportrequestid )
        WITH VALUE #( FOR key IN keys
                        ( %tky               = key-%tky
                          transportrequestid = key-%param-transportrequestid
                         ) ).

    READ ENTITIES OF zi_popricingconditiont_s IN LOCAL MODE
      ENTITY popricingconditiall
        ALL FIELDS WITH CORRESPONDING #( keys )
        RESULT DATA(entities).
    result = VALUE #( FOR entity IN entities
                        ( %tky   = entity-%tky
                          %param = entity ) ).
  ENDMETHOD.
  METHOD get_global_authorizations.
*    AUTHORITY-CHECK OBJECT 'S_TABU_NAM' ID 'TABLE' FIELD 'ZI_POPRICINGCONDITIONT' ID 'ACTVT' FIELD '02'.
*    DATA(is_authorized) = COND #( WHEN sy-subrc = 0 THEN if_abap_behv=>auth-allowed
*                                  ELSE if_abap_behv=>auth-unauthorized ).
*    result-%UPDATE      = is_authorized.
*    result-%ACTION-Edit = is_authorized.
*    result-%ACTION-SelectCustomizingTransptReq = is_authorized.
  ENDMETHOD.
  METHOD edit.
    CHECK lhc_rap_tdat_cts=>get( )->is_transport_mandatory( ).
    DATA(transport_request) = lhc_rap_tdat_cts=>get( )->get_transport_request( ).
    IF transport_request IS NOT INITIAL.
      MODIFY ENTITY IN LOCAL MODE zi_popricingconditiont_s
        EXECUTE selectcustomizingtransptreq FROM VALUE #( ( %is_draft = if_abap_behv=>mk-on
                                                            singletonid = 1
                                                            %param-transportrequestid = transport_request ) ).
      reported-popricingconditiall = VALUE #( ( %is_draft = if_abap_behv=>mk-on
                                     singletonid = 1
                                     %msg = mbc_cp_api=>message( )->get_transport_selected( transport_request ) ) ).
    ENDIF.
  ENDMETHOD.

  METHOD earlynumbering_create.

    DATA: lv_item TYPE c LENGTH 3.

    READ TABLE entities_cba INTO DATA(lt_entity1) INDEX 1.
    READ TABLE lt_entity1-%target INTO DATA(ls_entity_item1) INDEX 1.


    SELECT MAX( counter  ) FROM zpr_tb_po_pri_d WHERE condtype = @ls_entity_item1-condtype INTO @DATA(lv_max_count).
    IF sy-subrc EQ 0.
      lv_item = lv_max_count + 1.
    ELSE.
      lv_item = 1.
    ENDIF.

    LOOP AT entities_cba INTO DATA(lt_entity).
      LOOP AT lt_entity-%target INTO DATA(ls_entity_item).
        IF ls_entity_item-counter EQ '000'.
          ls_entity_item-counter = lv_item.
        ENDIF.
        MODIFY lt_entity-%target FROM ls_entity_item.
        APPEND CORRESPONDING #( ls_entity_item ) TO mapped-popricingconditiont.
      ENDLOOP.
    ENDLOOP.

  ENDMETHOD.

ENDCLASS.
CLASS lsc_zi_popricingconditiont_s DEFINITION FINAL INHERITING FROM cl_abap_behavior_saver.
  PROTECTED SECTION.
    METHODS:
      save_modified REDEFINITION.

ENDCLASS.

CLASS lsc_zi_popricingconditiont_s IMPLEMENTATION.
  METHOD save_modified.

    DATA(transport_from_singleton) = VALUE #( update-popricingconditiall[ 1 ]-transportrequestid OPTIONAL ).

    IF transport_from_singleton IS NOT INITIAL.
      lhc_rap_tdat_cts=>get( )->record_changes(
                                  transport_request = transport_from_singleton
                                  create            = REF #( create )
                                  update            = REF #( update )
                                  delete            = REF #( delete ) )->update_last_changed_date_time( view_entity_name   = 'ZI_POPRICINGCONDITIONT'
                                                                                                        maintenance_object = 'ZPOPRICINGCONDITIONT' ).
    ENDIF.
  ENDMETHOD.
ENDCLASS.
CLASS lhc_zi_popricingconditiont DEFINITION FINAL INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.
    METHODS:
      get_global_features FOR GLOBAL FEATURES
        IMPORTING
        REQUEST requested_features FOR popricingconditiont
        RESULT result,
      validatetransportrequest FOR VALIDATE ON SAVE
        IMPORTING
          keys_popricingconditiall FOR popricingconditiall~validatetransportrequest
          keys_popricingconditiont FOR popricingconditiont~validatetransportrequest,
      markdel FOR MODIFY
        IMPORTING keys FOR ACTION popricingconditiont~markdel,
      get_global_authorizations FOR GLOBAL AUTHORIZATION
        IMPORTING
        REQUEST requested_authorizations FOR popricingconditiont
        RESULT result.
ENDCLASS.

CLASS lhc_zi_popricingconditiont IMPLEMENTATION.
  METHOD get_global_features.
    DATA edit_flag TYPE abp_behv_op_ctrl VALUE if_abap_behv=>fc-o-enabled.
    IF lhc_rap_tdat_cts=>get( )->is_editable( ) = abap_false.
      edit_flag = if_abap_behv=>fc-o-disabled.
    ENDIF.
    result-%update = edit_flag.
*    result-%delete = edit_flag.
  ENDMETHOD.
  METHOD validatetransportrequest.
    CHECK keys_popricingconditiont IS NOT INITIAL.
    DATA: lv_msg_num TYPE syst-msgno.
    DATA change TYPE REQUEST FOR CHANGE zi_popricingconditiont_s.
    READ ENTITY IN LOCAL MODE zi_popricingconditiont_s
    FIELDS ( transportrequestid ) WITH CORRESPONDING #( keys_popricingconditiall )
    RESULT FINAL(transport_from_singleton).
    lhc_rap_tdat_cts=>get( )->validate_all_changes(
                                transport_request     = VALUE #( transport_from_singleton[ 1 ]-transportrequestid OPTIONAL )
                                table_validation_keys = VALUE #(
                                                          ( table = 'ZPR_TB_PO_PRICE' keys = REF #( keys_popricingconditiont ) )
                                                               )
                                reported              = REF #( reported )
                                failed                = REF #( failed )
                                change                = REF #( change ) ).

     READ ENTITIES OF zi_popricingconditiont_s IN LOCAL MODE
      ENTITY PoPricingConditionT
        ALL FIELDS WITH CORRESPONDING #( keys_popricingconditiont )
        RESULT DATA(entities).

    lv_msg_num = '175'.
    LOOP AT entities INTO DATA(ls_data).

      IF ls_data-calctype IS INITIAL OR
         ls_data-condclass IS INITIAL OR
         ls_data-condvalue IS INITIAL OR
         ls_data-high IS INITIAL OR
         ls_data-enddate IS INITIAL OR
         ls_data-low IS INITIAL OR
         ls_data-uom IS INITIAL OR
         ls_data-unit IS INITIAL OR
         ls_data-startdate IS INITIAL OR
         ls_data-per IS INITIAL.


        APPEND VALUE #( %key = ls_data-%key ) TO failed-popricingconditiont.
        APPEND VALUE #(
                      %key = ls_data-%key
                    %msg = new_message(
                    id = 'ZPR_MESSAGES'
                    number = lv_msg_num
                    severity = if_abap_behv_message=>severity-error )
                    ) TO reported-popricingconditiont.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD markdel.

    SELECT * FROM zpr_tb_po_price
      FOR ALL ENTRIES IN @keys
      WHERE cond_type = @keys-condtype
      AND   counter = @keys-counter
      INTO TABLE @DATA(lt_po_price).
    IF sy-subrc EQ 0.
      LOOP AT lt_po_price INTO DATA(ls_po_price).
        ls_po_price-deletion_ind = 'X'.
        MODIFY zpr_tb_po_price FROM @ls_po_price.
      ENDLOOP.

    ENDIF.

  ENDMETHOD.

  METHOD get_global_authorizations.

  ENDMETHOD.

ENDCLASS.