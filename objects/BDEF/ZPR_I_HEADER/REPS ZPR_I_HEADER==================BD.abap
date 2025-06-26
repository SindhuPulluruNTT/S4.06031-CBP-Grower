
unmanaged implementation in class zcl_pr_i_header unique;
strict ( 1 );
with draft;
define behavior for ZPR_I_HEADER alias Header
draft table zpr_tb_wt_dr
etag master LastChangedAt
lock master total etag LastChangedAt
authorization master ( global )
early numbering
{
  field ( mandatory : create, readonly : update ) Werks;
  field ( mandatory ) Lifnr;
  field ( readonly ) wtktno, Status, LiveWg, TrkUnloadwg,
  PoPrice, InvoiceSpl1, InvoiceSpl2, InvoiceSpl3, HaulerPO;

  create;
  update;
  delete;

  association _Item { create; with draft; }

  action ( features : instance ) Haulerpo result [1] $self;

  draft action Activate;
  draft action Edit;
  draft action Discard;
  draft action Resume;
  draft determine action Prepare;

  side effects
  {
    field MatDistance affects field Distravelleduom;
    field TRKLOADWG affects field LiveWg;
    field TRKUNLOADWG affects field LiveWg;
    field Wtktno affects entity _WttktHelp;
  }

  determination CalcNetWeight on modify { field TrkLoadwg, TrkUnloadwg; create; }
  determination GetUom on modify { field MatDistance; create; }
  determination DefaultData on modify { create; }

  mapping for zpr_tb_wt_hd
    {
      Werks   = werks;
      Wtktno  = wtktno;
    }

  factory action copy [1];

}

define behavior for ZPR_I_ITEM alias Item
draft table zpr_tb_it_dr
lock dependent by _Header
authorization dependent by _Header
early numbering
{
  create;
  update;
  delete ( features : instance );
  field ( mandatory ) Supplier, Matnr, Lgort;
  field ( features: instance ) TareWeight;
  field ( readonly ) Werks, Wtktno, Wtktitm, Prueflos, Ebeln, Mblnr, Invoice, status, Charg,
  PoPrice, SplitInvoice1, SplitInvoice2, SplitInvoice3, Unit, Aedat, Aeeit, Aenam, Erdat, Ereit, Ernam, Weight, GrossWeight;
  association _Header { with draft; }
  association _Tote { create; with draft; }

  action ( features : instance ) Processidata result [1] $self;
  action ( features : instance ) Processiteminv result [1] $self;
  action ( features : instance ) Stock parameter ZPR_TR_STOCK result [1] $self { default function GetDefaultsForStock; }

  determination GetUom on modify { field Matnr; create; }
  determination DefaultItemData on modify { create; }
  determination HandleWeight on modify { field TareWeight; }
  side effects
  {
    field Matnr affects field Unit;
    field PoPrice affects entity _Pocond;
    field TareWeight affects field Weight;
    entity _Tote affects field Weight;
  }
}

define behavior for zpr_i_item_tote alias Tote
draft table zpr_tb_tote_dr
lock dependent by _Header
authorization dependent by _Header
early numbering
{
  create;
  update;
  delete;
  field ( readonly ) Werks, Wtktno, Wtktitm, Toteitem, IWerks, IWtktno, Tweight, Tuom, TWeightUom;
  field ( features: instance ) Quantity, Totetype, Tote;
  determination UpdateWeight on modify { field Quantity, Totetype; create; }
  determination GetTUom on modify { field Totetype; create; }
  association _Item { with draft; }
  ancestor association _Header { with draft; }
  side effects
  {
    field Totetype affects field Tuom, field TWeightUom, field Tweight;
    field Quantity affects field Tweight, entity _Item;
  }
}