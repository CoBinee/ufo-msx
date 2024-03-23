; Item.inc : アイテム
;


; マクロの定義
;

; アイテム
ITEM_STATE                      =   0x00
ITEM_FLAG                       =   0x01
ITEM_POSITION_X                 =   0x02
ITEM_POSITION_Y                 =   0x03
ITEM_ANIMATION                  =   0x04
ITEM_COLOR                      =   0x05
ITEM_LENGTH                     =   0x06

; 状態
ITEM_STATE_NULL                 =   0x00

; フラグ
ITEM_FLAG_NULL                  =   0x00

; 位置
ITEM_POSITION_NULL              =   0x00

; アニメーション
ITEM_ANIMATION_NULL             =   0x00

; 色
ITEM_ANIMATION_NULL             =   0x00

; 外部関数宣言
;

    .globl  _ItemInitialize
    .globl  _ItemUpdate
    .globl  _ItemRender
    .globl  _ItemBorn
    .globl  _ItemKill

; 外部変数宣言
;

    .globl  _item
