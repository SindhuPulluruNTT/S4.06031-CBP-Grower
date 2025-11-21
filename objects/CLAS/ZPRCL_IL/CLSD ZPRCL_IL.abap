class-pool .
*"* class pool for class ZPRCL_IL

*"* local type definitions
include ZPRCL_IL======================ccdef.

*"* class ZPRCL_IL definition
*"* public declarations
  include ZPRCL_IL======================cu.
*"* protected declarations
  include ZPRCL_IL======================co.
*"* private declarations
  include ZPRCL_IL======================ci.
endclass. "ZPRCL_IL definition

*"* macro definitions
include ZPRCL_IL======================ccmac.
*"* local class implementation
include ZPRCL_IL======================ccimp.

*"* test class
include ZPRCL_IL======================ccau.

class ZPRCL_IL implementation.
*"* method's implementations
  include methods.
endclass. "ZPRCL_IL implementation
