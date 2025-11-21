class-pool .
*"* class pool for class ZPRCL_IL_BASE

*"* local type definitions
include ZPRCL_IL_BASE=================ccdef.

*"* class ZPRCL_IL_BASE definition
*"* public declarations
  include ZPRCL_IL_BASE=================cu.
*"* protected declarations
  include ZPRCL_IL_BASE=================co.
*"* private declarations
  include ZPRCL_IL_BASE=================ci.
endclass. "ZPRCL_IL_BASE definition

*"* macro definitions
include ZPRCL_IL_BASE=================ccmac.
*"* local class implementation
include ZPRCL_IL_BASE=================ccimp.

*"* test class
include ZPRCL_IL_BASE=================ccau.

class ZPRCL_IL_BASE implementation.
*"* method's implementations
  include methods.
endclass. "ZPRCL_IL_BASE implementation
