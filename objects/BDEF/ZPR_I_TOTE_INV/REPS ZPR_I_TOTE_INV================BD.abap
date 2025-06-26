unmanaged implementation in class zcl_pr_i_tote_inv unique;
strict ( 2 );

define behavior for ZPR_I_TOTE_INV alias ToteInv
//late numbering
lock master
authorization master ( instance )
//etag master <field_name>
{
//  create;
//  update;
//  delete;
  field ( readonly ) Lifnr, Totetype;

  action ( features : instance ) Transfer parameter ZPR_TR_TOTE result [0..1] $self { default function GetDefaultsForTransfer; }
  side effects {
   action Transfer affects $self;
  }
}