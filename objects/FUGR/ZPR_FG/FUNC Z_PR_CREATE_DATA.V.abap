*******************************************************************
*   THIS FILE IS GENERATED BY THE FUNCTION LIBRARY               **
*   NEVER CHANGE IT MANUALLY, PLEASE!                            **
*******************************************************************
FORM Z_PR_CREATE_DATA %_RFC.
* Parameter declaration
DATA I_WTKT TYPE
ZPR_DT_WTKTNO
.
DATA I_WTKTITEM TYPE
ZPR_DT_WTKTITM
.
DATA E_RETURN TYPE
CHAR1
.
* Assign default values
* Call remote function
  CALL FUNCTION 'Z_PR_CREATE_DATA' %_RFC
     EXPORTING
       I_WTKT = I_WTKT
       I_WTKTITEM = I_WTKTITEM
     IMPORTING
       E_RETURN = E_RETURN
  .
ENDFORM.