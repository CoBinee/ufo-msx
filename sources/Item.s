; Item.s : アイテム
;


; モジュール宣言
;
    .module Item

; 参照ファイル
;
    .include    "bios.inc"
    .include    "vdp.inc"
    .include    "System.inc"
    .include    "Sound.inc"
    .include    "App.inc"
    .include    "Game.inc"
    .include    "Route.inc"
    .include	"Item.inc"

; 外部変数宣言
;

; マクロの定義
;


; CODE 領域
;
    .area   _CODE

; アイテムを初期化する
;
_ItemInitialize::
    
    ; レジスタの保存
    
    ; アイテムの初期化
    ld      hl, #(_item + 0x0000)
    ld      de, #(_item + 0x0001)
    ld      bc, #(ITEM_LENGTH - 0x0001)
    ld      (hl), #0x00
    ldir

    ; レジスタの復帰
    
    ; 終了
    ret

; アイテムを更新する
;
_ItemUpdate::
    
    ; レジスタの保存

    ; アイテムの存在
    ld      a, (_item + ITEM_STATE)
    or      a
    jr      z, 90$

    ; 消滅の判定
    call    _RouteGetScroll
    ld      c, a
    ld      a, (_item + ITEM_POSITION_Y)
    sub     c
    cp      #0xf8
    jr      c, 10$
    xor     a
    ld      (_item + ITEM_STATE), a
    jr      90$
10$:

    ; アニメーションの更新
    ld      hl, #(_item + ITEM_ANIMATION)
    inc     (hl)

    ; 色の設定
    call    _GameGetRandomColor
    ld      (_item + ITEM_COLOR), a

    ; 更新の完了
90$:

    ; レジスタの復帰
    
    ; 終了
    ret

; アイテムを描画する
;
_ItemRender::

    ; レジスタの保存

    ; アイテムの存在
    ld      a, (_item + ITEM_STATE)
    or      a
    jr      z, 19$

    ; スクロールの取得
    call    _RouteGetScroll
    ld      c, a

    ; スプライトの表示
    ld      a, (_item + ITEM_ANIMATION)
    and     #0x0c
    ld      e, a
    ld      d, #0x00
    ld      hl, #itemSprite
    add     hl, de
    ld      de, #(_sprite + GAME_SPRITE_ITEM)
    ld      a, (_item + ITEM_POSITION_Y)
    sub     c
    add     a, (hl)
    cp      #0xd0
    jr      nz, 10$
    dec     a
10$:
    ld      (de), a
    inc     hl
    inc     de
    ld      a, (_item + ITEM_POSITION_X)
    add     a, (hl)
    ld      (de), a
    inc     hl
    inc     de
    ld      a, (hl)
    ld      (de), a
    inc     hl
    inc     de
    ld      a, (_item + ITEM_COLOR)
    or      (hl)
    ld      (de), a
;   inc     hl
;   inc     de

    ; 描画の完了
19$:

    ; レジスタの復帰

    ; 終了
    ret

; アイテムを生成する
;
_ItemBorn::

    ; レジスタの保存
    push    bc

    ; アイテムの検索
    ld      a, (_item + ITEM_STATE)
    or      a
    jr      nz, 19$

    ; 底の取得
    call    _RouteGetBottom
    jr      c, 19$
    ld      c, a

    ; アイテムの設定
    call    _SystemGetRandom
    cp      #(ROUTE_VIEW_X * 0x08)
    jr      c, 10$
    add     a, #(((0x20 - ROUTE_VIEW_X) / 0x02) * 0x08 - (ROUTE_VIEW_X * 0x08))
10$:
    and     #0xf8
    ld      (_item + ITEM_POSITION_X), a
    ld      a, c
    ld      (_item + ITEM_POSITION_Y), a
    xor     a
    ld      (_item + ITEM_ANIMATION), a
    ld      a, #0x01
    ld      (_item + ITEM_STATE), a
;   jr      19$

    ; 生成の完了
19$:

    ; レジスタの復帰
    pop     bc

    ; 終了
    ret

; アイテムを削除する
;
_ItemKill::

    ; レジスタの保存

    ; アイテムの削除
    xor     a
    ld      (_item + ITEM_STATE), a

    ; レジスタの復帰

    ; 終了
    ret

; 定数の定義
;

; スプライト
;
itemSprite:

    .db     -0x04 - 0x01, -0x04 + ROUTE_OFFSET_X * 0x08 + 0x20, 0x70, 0x80
    .db     -0x04 - 0x01, -0x04 + ROUTE_OFFSET_X * 0x08 + 0x20, 0x74, 0x80
    .db     -0x04 - 0x01, -0x04 + ROUTE_OFFSET_X * 0x08 + 0x20, 0x78, 0x80
    .db     -0x04 - 0x01, -0x04 + ROUTE_OFFSET_X * 0x08 + 0x20, 0x7c, 0x80


; DATA 領域
;
    .area   _DATA

; 変数の定義
;

; アイテム
;
_item::
    
    .ds     ITEM_LENGTH

