CLASS lcl_pr_buffer DEFINITION.
  PUBLIC SECTION.

    TYPES  : tt_totes TYPE STANDARD TABLE OF zpr_tb_tote_inv.

    CLASS-DATA: mt_totes TYPE tt_totes.
ENDCLASS.

CLASS lhc_toteinv DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS get_instance_authorizations FOR INSTANCE AUTHORIZATION
      IMPORTING keys REQUEST requested_authorizations FOR toteinv RESULT result.

    METHODS read FOR READ
      IMPORTING keys FOR READ toteinv RESULT result.

    METHODS lock FOR LOCK
      IMPORTING keys FOR LOCK toteinv.

    METHODS get_instance_features FOR INSTANCE FEATURES
      IMPORTING keys REQUEST requested_features FOR toteinv RESULT result.

    METHODS transfer FOR MODIFY
      IMPORTING keys FOR ACTION toteinv~transfer RESULT result.

    METHODS getdefaultsfortransfer FOR READ
      IMPORTING keys FOR FUNCTION toteinv~getdefaultsfortransfer RESULT result.

ENDCLASS.

CLASS lhc_toteinv IMPLEMENTATION.

  METHOD get_instance_authorizations.
  ENDMETHOD.

  METHOD read.

  ENDMETHOD.

  METHOD lock.
  ENDMETHOD.

  METHOD get_instance_features.
  ENDMETHOD.

  METHOD transfer.

    DATA: ls_toteinv TYPE zpr_tb_tote_inv,
          lt_toteinv TYPE STANDARD TABLE OF zpr_tb_tote_inv,
          lv_lifnr   TYPE lifnr.

    READ ENTITIES OF zpr_i_tote_inv IN LOCAL MODE
                           ENTITY toteinv
                             ALL FIELDS WITH CORRESPONDING #( keys )
                           RESULT DATA(totes).

    READ TABLE keys INTO DATA(ls_keys) INDEX 1.

    lv_lifnr = '0017300001'.

    IF ls_keys-lifnr = lv_lifnr.
* Own Vendor
      ls_toteinv-lifnr = lv_lifnr.
      ls_toteinv-totetype = ls_keys-totetype.
      ls_toteinv-qty = ls_keys-%param-tqty.
      ls_toteinv-erdat = sy-datum.
      ls_toteinv-time = sy-uzeit.
      ls_toteinv-shkzg = 'S'.
      APPEND ls_toteinv TO lt_toteinv.
      CLEAR: ls_toteinv.

      ls_toteinv-lifnr = ls_keys-%param-tgrower.
      ls_toteinv-totetype = ls_keys-totetype.
      ls_toteinv-qty = ls_keys-%param-tqty.
      ls_toteinv-erdat = sy-datum.
      ls_toteinv-time = sy-uzeit.
      ls_toteinv-shkzg = 'H'.
      APPEND ls_toteinv TO lt_toteinv.
      CLEAR: ls_toteinv.
    ELSE.
* Other Vendor
      ls_toteinv-lifnr = lv_lifnr.
      ls_toteinv-totetype = ls_keys-totetype.
      ls_toteinv-qty = ls_keys-%param-tqty.
      ls_toteinv-erdat = sy-datum.
      ls_toteinv-time = sy-uzeit.
      ls_toteinv-shkzg = 'H'.
      APPEND ls_toteinv TO lt_toteinv.
      CLEAR: ls_toteinv.

      ls_toteinv-lifnr = ls_keys-lifnr.
      ls_toteinv-totetype = ls_keys-totetype.
      ls_toteinv-qty = ls_keys-%param-tqty.
      ls_toteinv-erdat = sy-datum.
      ls_toteinv-time = sy-uzeit.
      ls_toteinv-shkzg = 'S'.
      APPEND ls_toteinv TO lt_toteinv.
      CLEAR: ls_toteinv.
    ENDIF.

    IF lt_toteinv[] IS NOT INITIAL.
      APPEND LINES OF lt_toteinv TO lcl_pr_buffer=>mt_totes.
    ENDIF.

  ENDMETHOD.

  METHOD getdefaultsfortransfer.

    DATA: lv_flag TYPE boolean.

    READ TABLE keys INTO DATA(key) INDEX 1.
    IF sy-subrc EQ 0.
      IF key-lifnr NE '0017300001'.
        lv_flag = abap_true.
      ELSE.
        lv_flag = abap_false.
      ENDIF.
      APPEND VALUE #( %tky = key-%tky
                      %param-isfieldhidden = lv_flag
       ) TO result.

    ENDIF.

  ENDMETHOD.

ENDCLASS.

CLASS lsc_zpr_i_tote_inv DEFINITION INHERITING FROM cl_abap_behavior_saver.
  PROTECTED SECTION.

    METHODS finalize REDEFINITION.

    METHODS check_before_save REDEFINITION.

    METHODS save REDEFINITION.

    METHODS cleanup REDEFINITION.

    METHODS cleanup_finalize REDEFINITION.

ENDCLASS.

CLASS lsc_zpr_i_tote_inv IMPLEMENTATION.

  METHOD finalize.
  ENDMETHOD.

  METHOD check_before_save.
  ENDMETHOD.

  METHOD save.

    IF lcl_pr_buffer=>mt_totes[] IS NOT INITIAL.
      MODIFY zpr_tb_tote_inv FROM TABLE @lcl_pr_buffer=>mt_totes[].
    ENDIF.

  ENDMETHOD.

  METHOD cleanup.
  ENDMETHOD.

  METHOD cleanup_finalize.
  ENDMETHOD.

ENDCLASS.