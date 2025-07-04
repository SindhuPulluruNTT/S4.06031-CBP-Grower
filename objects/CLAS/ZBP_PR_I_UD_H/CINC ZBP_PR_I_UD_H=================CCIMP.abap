CLASS lcl_cbp_buffer_ud DEFINITION.

  PUBLIC SECTION.

    CLASS-DATA : gv_wtktno     TYPE zpr_dt_wtktno,
                 gv_werks      TYPE c LENGTH 4,
                 gv_ss         TYPE c LENGTH 8,
                 gv_code       TYPE c LENGTH 4,
                 gv_cg         TYPE c LENGTH 8,
                 gv_ins_qty    TYPE menge_d,
                 gv_posted_qty TYPE menge_d.

ENDCLASS.

CLASS lhc_zpr_i_ud_h DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS get_instance_authorizations FOR INSTANCE AUTHORIZATION
      IMPORTING keys REQUEST requested_authorizations FOR zpr_i_ud_h RESULT result.

    METHODS create FOR MODIFY
      IMPORTING entities FOR CREATE zpr_i_ud_h.

    METHODS update FOR MODIFY
      IMPORTING entities FOR UPDATE zpr_i_ud_h.

    METHODS delete FOR MODIFY
      IMPORTING keys FOR DELETE zpr_i_ud_h.

    METHODS read FOR READ
      IMPORTING keys FOR READ zpr_i_ud_h RESULT result.

    METHODS lock FOR LOCK
      IMPORTING keys FOR LOCK zpr_i_ud_h.

    METHODS rba_item FOR READ
      IMPORTING keys_rba FOR READ zpr_i_ud_h\_item FULL result_requested RESULT result LINK association_links.

    METHODS cba_item FOR MODIFY
      IMPORTING entities_cba FOR CREATE zpr_i_ud_h\_item.

ENDCLASS.

CLASS lhc_zpr_i_ud_h IMPLEMENTATION.

  METHOD get_instance_authorizations.
  ENDMETHOD.

  METHOD create.

    LOOP AT entities INTO DATA(ls_header).
      lcl_cbp_buffer_ud=>gv_wtktno = ls_header-wtktno.
      lcl_cbp_buffer_ud=>gv_werks = ls_header-werks.
      lcl_cbp_buffer_ud=>gv_code = ls_header-udcode.
      lcl_cbp_buffer_ud=>gv_cg = ls_header-cgroup.
      lcl_cbp_buffer_ud=>gv_ins_qty = ls_header-qtyins.
*      lcl_cbp_buffer_ud=>gv_posted_qty = ls_header-qtypost.
    ENDLOOP.

  ENDMETHOD.

  METHOD update.
  ENDMETHOD.

  METHOD delete.
  ENDMETHOD.

  METHOD read.
  ENDMETHOD.

  METHOD lock.
  ENDMETHOD.

  METHOD rba_item.
  ENDMETHOD.

  METHOD cba_item.

    DATA : lv_prueflos  TYPE zpr_dt_qplos,
           lv_msg       TYPE string,
           lv_wtktno    TYPE zpr_dt_wtktno,
           lv_item      TYPE zpr_dt_wtktitm,
           lv_price_upd TYPE c.

    TYPES: BEGIN OF ty_return,
             message TYPE string,
           END OF ty_return,

           tt_return         TYPE STANDARD TABLE OF ty_return WITH DEFAULT KEY,
           tt_po_deep_create TYPE STANDARD TABLE OF zpr_scm_cbp_po_v2=>tys_a_pur_ord_pricing_elemen_2 WITH NON-UNIQUE DEFAULT KEY.

    DATA: lo_http_client         TYPE REF TO if_web_http_client,
          lo_client_proxy        TYPE REF TO /iwbep/if_cp_client_proxy,
          lo_request             TYPE REF TO /iwbep/if_cp_request_create,
          lo_response            TYPE REF TO /iwbep/if_cp_response_create,
          lt_property            TYPE /iwbep/if_cp_runtime_types=>ty_t_property_path,
          lt_item_property       TYPE /iwbep/if_cp_runtime_types=>ty_t_property_path,
          lt_msg                 TYPE tt_return,
          lv_message             TYPE string,
          ls_insp_business_data  TYPE zpr_scm_cbp_insp=>tys_a_insp_lot_usage_decisio_2,
          ls_business_data       TYPE zpr_scm_cbp_insp=>tys_a_insp_lot_usage_decisio_2,
          lo_resource_read       TYPE REF TO /iwbep/if_cp_resource_entity,
          lo_request_read        TYPE REF TO /iwbep/if_cp_request_read,
          lo_response_read       TYPE REF TO /iwbep/if_cp_response_read,
          ls_entity_key          TYPE zpr_scm_cbp_insp=>tys_a_inspection_lot_type,
          ls_header              TYPE zpr_scm_cbp_insp=>tys_a_inspection_lot_type,
          ls_po_business_data    TYPE zpr_scm_cbp_po_v2=>tys_a_pur_ord_pricing_elemen_2,
          ls_cond_business_data  TYPE tt_po_deep_create,
          ls_final_business_data TYPE zpr_scm_cbp_po_v2=>tys_a_pur_ord_pricing_elemen_2,
          lo_po_request          TYPE REF TO /iwbep/if_cp_request_create,
          lo_po_response         TYPE REF TO /iwbep/if_cp_response_create.

    CONSTANTS: lc_po_url   TYPE string VALUE 'https://my403232-api.s4hana.cloud.sap/sap/opu/odata/sap/API_PURCHASEORDER_PROCESS_SRV',
               lc_insp_url TYPE string VALUE 'https://my403232-api.s4hana.cloud.sap/sap/opu/odata/sap/API_INSPECTIONLOT_SRV',
               lc_user     TYPE string VALUE 'DEMO_API_PC',
               lc_password TYPE string VALUE 'fSQ#xoXWmonAJJnqVaKoqzmRuxAh9ZfFktRbFSfL'.

    LOOP AT entities_cba INTO DATA(ls_data).
      lv_wtktno = ls_data-wtktno.
      LOOP AT ls_data-%target INTO DATA(ls_item).
        lv_wtktno = ls_item-wtktno.
        lv_item = ls_item-wtktitm.
        SELECT SINGLE * FROM zpr_tb_wt_it WHERE wtktno =  @lv_wtktno
                                              AND wtktitm =  @lv_item INTO @DATA(ls_item_data).

        TRY.
* Update PO Price - add custom condition types based on results recording
            lo_http_client = cl_web_http_client_manager=>create_by_http_destination(
                      i_destination = cl_http_destination_provider=>create_by_url( lc_insp_url ) ).
            DATA(lo_http_req) = lo_http_client->get_http_request( ).
            lo_http_req->set_authorization_basic(
                                                   i_username = lc_user
                                                   i_password = lc_password
                                                 ).

            lo_client_proxy = /iwbep/cl_cp_factory_remote=>create_v2_remote_proxy(
            EXPORTING
               is_proxy_model_key       = VALUE #( repository_id       = 'DEFAULT'
                                                   proxy_model_id      = 'ZPR_SCM_CBP_INSP'
                                                   proxy_model_version = '0001' )
              io_http_client             = lo_http_client
              iv_relative_service_root   = ''  ).

            ASSERT lo_http_client IS BOUND.

            ls_entity_key = VALUE #(
                 inspection_lot =  ls_item_data-prueflos ).

            " Navigate to the resource
            lo_resource_read = lo_client_proxy->create_resource_for_entity_set( 'A_INSPECTION_LOT' )->navigate_with_key( ls_entity_key ).

            " Execute the request and retrieve the business data
            lo_response_read = lo_resource_read->create_request_for_read( )->execute( ).
            lo_response_read->get_business_data( IMPORTING es_business_data = ls_header ).

            lo_http_client->set_csrf_token( ).
            " Navigate to the resource and create a request for the create operation
            lo_request = lo_client_proxy->create_resource_for_entity_set( 'A_INSP_LOT_USAGE_DECISION' )->create_request_for_create( ).

            ls_insp_business_data-inspection_lot = ls_item_data-prueflos.
            ls_insp_business_data-insp_lot_usage_decision_le = 'L'.
            ls_insp_business_data-insp_lot_usage_decision_ca = '3'.
            ls_insp_business_data-selected_code_set_plant = lcl_cbp_buffer_ud=>gv_werks.
            ls_insp_business_data-insp_lot_usge_dcsn_selecte = lcl_cbp_buffer_ud=>gv_cg.
            ls_insp_business_data-inspection_lot_usage_decis = lcl_cbp_buffer_ud=>gv_code.
            ls_insp_business_data-insp_lot_usage_decision_co = lcl_cbp_buffer_ud=>gv_cg.
            ls_insp_business_data-changed_date_time = ls_header-changed_date_time.

            APPEND 'INSPECTION_LOT' TO lt_item_property.
            APPEND 'INSP_LOT_USAGE_DECISION_LE' TO lt_item_property.
            APPEND 'INSP_LOT_USAGE_DECISION_CA' TO lt_item_property.
            APPEND 'SELECTED_CODE_SET_PLANT' TO lt_item_property.
            APPEND 'INSP_LOT_USGE_DCSN_SELECTE' TO lt_item_property.
            APPEND 'INSPECTION_LOT_USAGE_DECIS' TO lt_item_property.
            APPEND 'INSP_LOT_USAGE_DECISION_CO' TO lt_item_property.
            APPEND 'CHANGED_DATE_TIME' TO lt_item_property.

            " Set the business data for the created entity
            lo_request->set_business_data(
            is_business_data =  ls_insp_business_data
            it_provided_property = lt_item_property
            ).

            " Execute the request
            lo_response = lo_request->execute( ).

            CLEAR: ls_business_data.
            " Get the after image
            lo_response->get_business_data( IMPORTING es_business_data = ls_business_data ).

            IF ls_business_data IS NOT INITIAL.
              UPDATE zpr_tb_wt_it SET status = '40' WHERE wtktno = @lv_wtktno AND wtktitm =  @lv_item.
* Add code for PO Update
              lv_price_upd = abap_true.
            ENDIF.

          CATCH /iwbep/cx_cp_remote INTO DATA(lx_remote).
            IF lx_remote->get_text( ) IS NOT INITIAL.
              lt_msg = VALUE #( ( message = lx_remote->get_text( ) ) ).
              IF lt_msg[] IS NOT INITIAL.
                lv_message = lt_msg[ 1 ]-message.
              ENDIF.
            ENDIF.

            IF lx_remote->s_odata_error-message IS NOT INITIAL.
              lt_msg = VALUE #( BASE lt_msg ( message = lx_remote->s_odata_error-message ) ).
              IF lt_msg[] IS NOT INITIAL.
                lv_message = lt_msg[ 2 ]-message.
              ENDIF.
            ENDIF.

          CATCH /iwbep/cx_gateway INTO DATA(lx_gateway).
            lt_msg = VALUE #( ( message = lx_gateway->get_text( ) ) ).
            IF lt_msg[] IS NOT INITIAL.
              lv_message = lt_msg[ 1 ]-message.
            ENDIF.

          CATCH cx_web_http_client_error INTO DATA(lx_web_http_client_error).
            lv_message =  lx_web_http_client_error->get_longtext(  ).

          CATCH cx_http_dest_provider_error INTO DATA(lx_web_http_dest_error).
            lv_message =  lx_web_http_dest_error->get_longtext(  ).
        ENDTRY.
      ENDLOOP.

    ENDLOOP.

* Add custom conditions to PO and update Price
    IF lv_price_upd EQ abap_true.
      CLEAR: lt_item_property[].
      SELECT * FROM i_inspectionresult WHERE inspectionlot = @ls_item_data-prueflos
         INTO TABLE @DATA(lt_insp_results).
      IF sy-subrc EQ 0.
* Get inspection lot characteristic
        SELECT * FROM i_inspectioncharacteristic WHERE inspectionlot = @ls_item_data-prueflos
          INTO TABLE @DATA(lt_insp_char).

        IF sy-subrc EQ 0.
          SELECT * FROM zpr_tb_cond_map FOR ALL ENTRIES IN @lt_insp_char
            WHERE char_name = @lt_insp_char-inspectionspecification
            INTO TABLE @DATA(lt_cond).

* Fetch the custom condition types for PO update
          SELECT * FROM zpr_tb_po_price FOR ALL ENTRIES IN @lt_cond
            WHERE cond_type = @lt_cond-cond_type
            AND start_date LE @sy-datum
            AND end_date GE @sy-datum
            AND deletion_ind = ''
            INTO TABLE @DATA(lt_price).
          IF sy-subrc EQ 0.
            SORT lt_price BY cond_type.
          ENDIF.

          SELECT SINGLE * FROM i_purorditmpricingelementapi01
           WHERE purchaseorder = @ls_item_data-ebeln
           AND purchaseorderitem = @ls_item_data-ebelp
           INTO @DATA(ls_element).

          LOOP AT lt_insp_char INTO DATA(ls_insp_char).
            READ TABLE lt_cond INTO DATA(ls_cond) WITH KEY char_name = ls_insp_char-inspectionspecification.
            IF sy-subrc EQ 0.
              READ TABLE lt_insp_results INTO DATA(ls_results) WITH KEY inspectionlot = ls_item_data-prueflos
                                                                        inspectioncharacteristic = ls_insp_char-inspectioncharacteristic.
              IF sy-subrc EQ 0.
                CLEAR: ls_po_business_data.
                LOOP AT lt_price INTO DATA(ls_price) WHERE cond_type = ls_cond-cond_type.
                  IF ls_price-low LE ls_results-inspectionresultmeanvalue AND
                     ls_results-inspectionresultmeanvalue LE ls_price-high.

                    TRY.
* Update PO Price - add custom condition types based on results recording
                        lo_http_client = cl_web_http_client_manager=>create_by_http_destination(
                                  i_destination = cl_http_destination_provider=>create_by_url( lc_po_url ) ).
                        lo_http_req = lo_http_client->get_http_request( ).
                        lo_http_req->set_authorization_basic(
                                                               i_username = lc_user
                                                               i_password = lc_password
                                                             ).

                        lo_client_proxy = /iwbep/cl_cp_factory_remote=>create_v2_remote_proxy(
                        EXPORTING
                           is_proxy_model_key       = VALUE #( repository_id       = 'DEFAULT'
                                                               proxy_model_id      = 'ZPR_SCM_CBP_PO_V2'
                                                               proxy_model_version = '0001' )
                          io_http_client             = lo_http_client
                          iv_relative_service_root   = ''  ).

                        ASSERT lo_http_client IS BOUND.

                        APPEND 'PURCHASE_ORDER' TO  lt_item_property.
                        APPEND 'PURCHASE_ORDER_ITEM' TO  lt_item_property.
                        APPEND 'PRICING_DOCUMENT' TO  lt_item_property.
                        APPEND 'PRICING_DOCUMENT_ITEM' TO  lt_item_property.
                        APPEND 'CONDITION_TYPE' TO lt_item_property.
                        APPEND 'CONDITION_RATE_VALUE' TO lt_item_property.

                        lo_http_client->set_csrf_token( ).
                        " Navigate to the resource and create a request for the create operation
                        lo_request = lo_client_proxy->create_resource_for_entity_set( 'A_PUR_ORD_PRICING_ELEMENT' )->create_request_for_create( ).

* Prepare business data
                        ls_po_business_data-purchase_order = ls_item_data-ebeln.
                        ls_po_business_data-purchase_order_item = ls_item_data-ebelp.
                        ls_po_business_data-pricing_document = ls_element-pricingdocument.
                        ls_po_business_data-pricing_document_item = ls_element-PricingDocumentItem.
                        ls_po_business_data-condition_type = ls_cond-cond_type.
                        ls_po_business_data-condition_rate_value = ls_price-cond_value.

                        " Set the business data for the created entity
                        lo_request->set_business_data(
                        is_business_data =  ls_po_business_data
                        it_provided_property = lt_item_property
                        ).

                        " Execute the request
                        lo_response = lo_request->execute( ).
                        WAIT UP TO 3 SECONDS.

                        CLEAR: ls_business_data.
                        " Get the after image
                        lo_response->get_business_data( IMPORTING es_business_data = ls_final_business_data ).

                        IF ls_final_business_data IS NOT INITIAL.
* Get Updated PO Price
                          SELECT SINGLE * FROM i_purchaseorderitemapi01 WHERE purchaseorder = @ls_item_data-ebeln
                          AND purchaseorderitem = @ls_item_data-ebelp
                          INTO @DATA(ls_po).
                          UPDATE zpr_tb_wt_it SET status = '50',
                                                  po_price = @ls_po-netamount
                                      WHERE wtktno =  @ls_item_data-wtktno
                                      AND   wtktitm = @ls_item_data-wtktitm.
                        ENDIF.

                      CATCH /iwbep/cx_cp_remote INTO lx_remote.
                        IF lx_remote->get_text( ) IS NOT INITIAL.
                          lt_msg = VALUE #( ( message = lx_remote->get_text( ) ) ).
                          IF lt_msg[] IS NOT INITIAL.
                            lv_message = lt_msg[ 1 ]-message.
                          ENDIF.
                        ENDIF.

                        IF lx_remote->s_odata_error-message IS NOT INITIAL.
                          lt_msg = VALUE #( BASE lt_msg ( message = lx_remote->s_odata_error-message ) ).
                          IF lt_msg[] IS NOT INITIAL.
                            lv_message = lt_msg[ 2 ]-message.
                          ENDIF.
                        ENDIF.

                      CATCH /iwbep/cx_gateway INTO lx_gateway.
                        lt_msg = VALUE #( ( message = lx_gateway->get_text( ) ) ).
                        IF lt_msg[] IS NOT INITIAL.
                          lv_message = lt_msg[ 1 ]-message.
                        ENDIF.

                      CATCH cx_web_http_client_error INTO lx_web_http_client_error.
                        lv_message =  lx_web_http_client_error->get_longtext(  ).

                      CATCH cx_http_dest_provider_error INTO lx_web_http_dest_error.
                        lv_message =  lx_web_http_dest_error->get_longtext(  ).
                    ENDTRY.

                  ENDIF.
                ENDLOOP.
              ENDIF.
            ENDIF.
          ENDLOOP.
        ENDIF.
      ENDIF.
    ENDIF.
  ENDMETHOD.

ENDCLASS.

CLASS lhc_zpr_i_ud_item DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS update FOR MODIFY
      IMPORTING entities FOR UPDATE zpr_i_ud_item.

    METHODS delete FOR MODIFY
      IMPORTING keys FOR DELETE zpr_i_ud_item.

    METHODS read FOR READ
      IMPORTING keys FOR READ zpr_i_ud_item RESULT result.

    METHODS rba_header FOR READ
      IMPORTING keys_rba FOR READ zpr_i_ud_item\_header FULL result_requested RESULT result LINK association_links.

ENDCLASS.

CLASS lhc_zpr_i_ud_item IMPLEMENTATION.

  METHOD update.
  ENDMETHOD.

  METHOD delete.
  ENDMETHOD.

  METHOD read.
  ENDMETHOD.

  METHOD rba_header.
  ENDMETHOD.

ENDCLASS.

CLASS lsc_zpr_i_ud_h DEFINITION INHERITING FROM cl_abap_behavior_saver.
  PROTECTED SECTION.

    METHODS finalize REDEFINITION.

    METHODS check_before_save REDEFINITION.

    METHODS save REDEFINITION.

    METHODS cleanup REDEFINITION.

    METHODS cleanup_finalize REDEFINITION.

ENDCLASS.

CLASS lsc_zpr_i_ud_h IMPLEMENTATION.

  METHOD finalize.
  ENDMETHOD.

  METHOD check_before_save.
  ENDMETHOD.

  METHOD save.
  ENDMETHOD.

  METHOD cleanup.
  ENDMETHOD.

  METHOD cleanup_finalize.
  ENDMETHOD.

ENDCLASS.