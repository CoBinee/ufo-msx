; Route.s : 経路
;


; モジュール宣言
;
    .module Route

; 参照ファイル
;
    .include    "bios.inc"
    .include    "vdp.inc"
    .include    "System.inc"
    .include    "Sound.inc"
    .include    "App.inc"
    .include    "Game.inc"
    .include    "Player.inc"
    .include	"Route.inc"

; 外部変数宣言
;

; マクロの定義
;


; CODE 領域
;
    .area   _CODE

; 経路を初期化する
;
_RouteInitialize::

    ; レジスタの保存

    ; スクロールの初期化
    xor     a
    ld      (routeScroll), a

    ; 底の初期化
    ld      hl, #0x0000
    ld      (routeBottom), hl

    ; カウントの初期化
    xor     a
    ld      (routeCount), a

    ; ゴールの初期化
    ld      hl, #(routeGoal + 0x0000)
    ld      de, #(routeGoal + 0x0001)
    ld      bc, #(ROUTE_GOAL_LENGTH - 0x0001)
    ld      (hl), #0x00
    ldir

    ; 経路の作成
    call    RouteBuild

    ; レジスタの復帰

    ; 終了
    ret


; 経路を更新する
;
_RouteUpdate::

    ; レジスタの保存

    ; スクロールの取得
    ld      hl, #(routeScroll)

    ; フロアの取得
    call    _GameGetFloor
    cp      #(GAME_FLOOR_GOAL - 0x08)
    jr      c, 10$
    jr      nz, 19$
    ld      a, (hl)
    and     #0x0f
    jr      z, 19$
10$:

    ; プレイヤの位置の取得
    call    _PlayerGetPositionY
    ld      c, a

    ; スクロール
    ld      hl, #(routeScroll)
    sub     (hl)
    cp      #(ROUTE_SCROLL_RANGE + 0x01)
    jr      c, 19$
    ld      a, c
    sub     #(ROUTE_SCROLL_RANGE)
    ld      (hl), a
    and     #0xf0
    add     a, #(ROUTE_BOTTOM_RANGE << 4)
    ld      c, a
    ld      hl, (routeBottom)
    ld      a, l
    srl     h
    rra
    srl     h
    rra
    and     #0xf0
    cp      c
    jr      nz, 19$
    call    RouteBuildLine
19$:

    ; ゴールの更新
    call    RouteUpdateGoal

    ; レジスタの復帰
    
    ; 終了
    ret

; 経路を描画する
;
_RouteRender::
    
    ; レジスタの保存

    ; ゴールの描画
    call    RoutePrintGoal

    ; レジスタの復帰
    
    ; 終了
    ret

; 経路を転送する
;
_RouteTransfer::
    
    ; レジスタの保存
    push    de

    ; d < ポート #0
    ; e < ポート #1

    ; パターンネームテーブルの取得    
    ld      a, (_videoRegister + VDP_R2)
    add     a, a
    add     a, a
    ld      l, #ROUTE_OFFSET_X

    ; VRAM アドレスの設定
    ld      c, e
    out     (c), l
    or      #0b01000000
    out     (c), a

    ; スクロールの取得
    ld      a, (routeScroll)
    ld      b, a

    ; パターンネームテーブルの転送
    ld      c, d
;   ld      a, b
    and     #0xf8
    ld      h, #0x00
    add     a, a
    rl      h
    add     a, a
    rl      h
    ld      l, a
    ld      a, b
    and     #0x07
    ld      b, a
    ld      ix, #(_patternName + ROUTE_VIEW_X)
    ld      d, #ROUTE_VIEW_Y
10$:
    push    de
    push    hl
    ld      de, #_route
    add     hl, de
    ld      e, #ROUTE_VIEW_X
11$:
    ld      a, (hl)
    add     a, b
    out     (c), a
    inc     hl
    dec     e
    jr      nz, 11$
    ld      e, #(0x20 - ROUTE_VIEW_X)
12$:
    ld      a, 0x00(ix)
    out     (c), a
    inc     ix
    dec     e
    jr      nz, 12$
    ld      de, #ROUTE_VIEW_X
    add     ix, de
    pop     hl
    ld      de, #ROUTE_SIZE_X
    add     hl, de
    ld      a, h
    and     #0x03
    ld      h, a
    pop     de
    dec     d
    jr      nz, 10$

    ; レジスタの復帰
    pop     de
    
    ; 終了
    ret

; 経路を作成する
;
RouteBuild:

    ; レジスタの保存

    ; 経路のクリア
    ld      hl, #_route
    ld      c, #ROUTE_SIZE_Y / 0x02
10$:
    ld      a, #(ROUTE_WALL | ROUTE_UPPER)
    ld      b, #ROUTE_SIZE_X
11$:
    ld      (hl), a
    inc     hl
    djnz    11$
    ld      a, #(ROUTE_WALL | ROUTE_LOWER)
    ld      b, #ROUTE_SIZE_X
12$:
    ld      (hl), a
    inc     hl
    djnz    12$
    dec     c
    jr      nz, 10$

    ; 底の設定
    ld      b, #ROUTE_BOTTOM_RANGE
20$:
    call    RouteBuildLine
    djnz    20$

    ; レジスタの復帰

    ; 終了
    ret

RouteBuildLine:

    ; レジスタの保存
    push    hl
    push    bc
    push    de

    ; 経路の取得
    ld      de, (routeBottom)
    ld      hl, #_route
    add     hl, de

    ; 最初の作成
100$:
    ld      a, (routeCount)
    or      a
    jr      nz, 110$
    ld      a, #(ROUTE_WALL | ROUTE_UPPER)
    ld      b, #((ROUTE_VIEW_X - ROUTE_DOWN_WIDTH) / 0x02)
101$:
    ld      (hl), a
    inc     hl
    djnz    101$
    ld      (hl), #(ROUTE_DOWN_LEFT_0 | ROUTE_UPPER)
    inc     hl
    ld      (hl), #(ROUTE_DOWN_LEFT_1 | ROUTE_UPPER)
    inc     hl
    ld      (hl), #(ROUTE_DOWN_LEFT_2 | ROUTE_UPPER)
    inc     hl
    ld      a, #(ROUTE_WALL | ROUTE_UPPER)
    ld      b, #(ROUTE_SIZE_X - (((ROUTE_VIEW_X - ROUTE_DOWN_WIDTH) / 0x02) + ROUTE_DOWN_WIDTH))
102$:
    ld      (hl), a
    inc     hl
    djnz    102$
    ld      a, #(ROUTE_STRAIGHT | ROUTE_LOWER)
    ld      b, #((ROUTE_VIEW_X - ROUTE_DOWN_WIDTH) / 0x02)
103$:
    ld      (hl), a
    inc     hl
    djnz    103$
    ld      (hl), #(ROUTE_DOWN_LEFT_0 | ROUTE_LOWER)
    inc     hl
    ld      (hl), #(ROUTE_DOWN_LEFT_1 | ROUTE_LOWER)
    inc     hl
    ld      (hl), #(ROUTE_DOWN_LEFT_2 | ROUTE_LOWER)
    inc     hl
    ld      a, #(ROUTE_STRAIGHT | ROUTE_LOWER)
    ld      b, #(ROUTE_SIZE_X - (((ROUTE_VIEW_X - ROUTE_DOWN_WIDTH) / 0x02) + ROUTE_DOWN_WIDTH))
104$:
    ld      (hl), a
    inc     hl
    djnz    104$
    jp      190$

    ; 通路の作成
110$:
    cp      #GAME_FLOOR_GOAL
    jr      nc, 120$
    push    hl
    ld      c, #ROUTE_VIEW_X
111$:
    call    _SystemGetRandom
    and     #0x07
    jr      z, 113$
    cp      c
    jr      c, 112$
    ld      a, c
112$:
    ld      (hl), #(ROUTE_STRAIGHT + ROUTE_UPPER)
    inc     hl
    dec     c
    dec     a
    jr      nz, 112$
    ld      a, c
    or      a
    jr      z, 116$
113$:
    ld      a, c
    cp      #ROUTE_DOWN_WIDTH
    jr      c, 115$
    call    _SystemGetRandom
    and     #0x04
    ld      a, #(ROUTE_DOWN_LEFT_0 + ROUTE_UPPER)
    ld      b, #ROUTE_DOWN_WIDTH
    jr      z, 114$
    ld      a, #(ROUTE_DOWN_RIGHT_0 + ROUTE_UPPER)
114$:
    ld      (hl), a
    inc     hl
    add     a, #0x08
    dec     c
    djnz    114$
    ld      a, c
    or      a
    jr      z, 116$
    jr      111$
115$:
    ld      (hl), #(ROUTE_STRAIGHT + ROUTE_UPPER)
    inc     hl
    dec     c
    jr      nz, 115$
;   jr      116$
116$:
    pop     hl
    ld      e, l
    ld      d, h
    ld      bc, #ROUTE_SIZE_X
    add     hl, bc
    ld      bc, #((ROUTE_VIEW_X << 8) | (ROUTE_LOWER - ROUTE_UPPER))
117$:
    ld      a, (de)
    add     a, c
    ld      (hl), a
    inc     hl
    inc     de
    djnz    117$
    jr      190$

    ; ゴールの作成
120$:
;   cp      #GAME_FLOOR_GOAL
    jr      nz, 130$
    ld      a, #(ROUTE_STRAIGHT | ROUTE_UPPER)
    ld      b, #ROUTE_VIEW_X
121$:
    ld      (hl), a
    inc     hl
    djnz    121$
    ld      de, #(ROUTE_SIZE_X - ROUTE_VIEW_X)
    add     hl, de
    ld      a, #(ROUTE_WALL | ROUTE_LOWER)
    ld      b, #ROUTE_VIEW_X
122$:
    ld      (hl), a
    inc     hl
    djnz    122$
    call    RouteEntryGoal
    jr      190$

    ; ゴールより下の作成
130$:
    ld      a, #(ROUTE_WALL | ROUTE_UPPER)
    ld      b, #ROUTE_VIEW_X
131$:
    ld      (hl), a
    inc     hl
    djnz    131$
    ld      de, #(ROUTE_SIZE_X - ROUTE_VIEW_X)
    add     hl, de
    ld      a, #(ROUTE_WALL | ROUTE_LOWER)
    ld      b, #ROUTE_VIEW_X
132$:
    ld      (hl), a
    inc     hl
    djnz    132$
;   jr      190$

    ; 作成の完了
190$:

    ; 底の更新
    ld      hl, (routeBottom)
    ld      de, #(ROUTE_SIZE_X * 0x0002)
    add     hl, de
    ld      a, h
    and     #0x03
    ld      h, a
    ld      (routeBottom), hl

    ; カウントの更新
    ld      hl, #(routeCount)
    inc     (hl)

    ; レジスタの復帰
    pop     de
    pop     bc
    pop     hl

    ; 終了
    ret

; 経路を取得する
;
RouteGet:

    ; レジスタの保存
    push    hl
    push    de

    ; de < Y/X 位置
    ; a  > 経路

    ; 経路の判定
    ld      a, d
    and     #0xf8
    ld      h, #0x00
    add     a, a
    rl      h
    add     a, a
    rl      h
    ld      l, a
    ld      a, e
    and     #0xf8
    rrca
    rrca
    rrca
    ld      e, a
    ld      d, #0x00
    add     hl, de
    ld      de, #_route
    add     hl, de
    ld      a, (hl)

    ; レジスタの復帰
    pop     de
    pop     hl

    ; 終了
    ret

; 壁かどうかを判定する
;
_RouteIsWall::

    ; レジスタの保存

    ; de < Y/X 位置
    ; cf > 1 = 壁

    ; 経路の判定
    call    RouteGet
    and     #ROUTE_MASK
    cp      #ROUTE_WALL
    jr      z, 18$
    or      a
    jr      19$
18$:
    scf
19$:

    ; レジスタの復帰

    ; 終了
    ret

; 降下できるかどうかを判定する
;
_RouteIsDownLeft::

    ; レジスタの保存

    ; de < Y/X 位置
    ; cf > 1 = 降下する

    ; 経路の判定
    call    RouteGet
    and     #ROUTE_MASK
    cp      #ROUTE_DOWN_LEFT_2
    jr      z, 18$
    or      a
    jr      19$
18$:
    scf
19$:

    ; レジスタの復帰

    ; 終了
    ret

_RouteIsDownRight::

    ; レジスタの保存

    ; de < Y/X 位置
    ; cf > 1 = 降下する

    ; 経路の判定
    call    RouteGet
    and     #ROUTE_MASK
    cp      #ROUTE_DOWN_RIGHT_0
    jr      z, 18$
    or      a
    jr      19$
18$:
    scf
19$:

    ; レジスタの復帰

    ; 終了
    ret

; 上昇できるかどうかを判定する
;
_RouteIsUp::

    ; レジスタの保存

    ; de < Y/X 位置
    ; cf > 1 = 上昇する

    ; 経路の判定
    call    RouteGet
    and     #ROUTE_MASK
    cp      #ROUTE_DOWN_LEFT_1
    jr      z, 18$
    cp      #ROUTE_DOWN_RIGHT_1
    jr      z, 18$
    or      a
    jr      19$
18$:
    scf
19$:

    ; レジスタの復帰

    ; 終了
    ret

_RouteIsUpLeft::

    ; レジスタの保存

    ; de < Y/X 位置
    ; cf > 1 = 上昇する

    ; 経路の判定
    call    RouteGet
    and     #ROUTE_MASK
    cp      #ROUTE_DOWN_RIGHT_2
    jr      z, 18$
    or      a
    jr      19$
18$:
    scf
19$:

    ; レジスタの復帰

    ; 終了
    ret

_RouteIsUpRight::

    ; レジスタの保存

    ; de < Y/X 位置
    ; cf > 1 = 上昇する

    ; 経路の判定
    call    RouteGet
    and     #ROUTE_MASK
    cp      #ROUTE_DOWN_LEFT_0
    jr      z, 18$
    or      a
    jr      19$
18$:
    scf
19$:

    ; レジスタの復帰

    ; 終了
    ret

; スクロールを取得する
;
_RouteGetScroll::

    ; レジスタの保存

    ; a > スクロール

    ; スクロールの取得
    ld      a, (routeScroll)

    ; レジスタの復帰

    ; 終了
    ret

; 底を取得する
;
_RouteGetBottom::

    ; レジスタの保存
    push    hl
    push    de

    ; a  > 底
    ; cf > 1 = 壁

    ; 底の取得
    ld      hl, (routeBottom)
    ld      a, l
    srl     h
    rra
    srl     h
    rra
    and     #0xf8
    sub     #0x10
    ld      d, a
    ld      e, #0x00
    call    RouteGet
    and     #ROUTE_MASK
    cp      #ROUTE_WALL
    jr      z, 18$
    or      a
    jr      19$
18$:
    scf
19$:
    ld      a, d

    ; レジスタの復帰
    pop     de
    pop     hl

    ; 終了
    ret

; ゴールを生成する
;
RouteEntryGoal:

    ; レジスタの保存

    ; ゴールの生成
    ld      hl, (routeBottom)
    ld      a, l
    srl     h
    rra
    srl     h
    rra
    and     #0xf8
    ld      (routeGoal + ROUTE_GOAL_POSITION_Y), a
    xor     a
    ld      (routeGoal + ROUTE_GOAL_POSITION_X), a
    ld      a, #0x01
    ld      (routeGoal + ROUTE_GOAL_STATE), a

    ; レジスタの復帰

    ;　終了
    ret

; ゴールを更新する
;
RouteUpdateGoal:

    ; レジスタの保存

    ; ゴールの更新
    ld      a, (routeGoal + ROUTE_GOAL_STATE)
    or      a
    jr      z, 19$
    ld      hl, #(routeGoal + ROUTE_GOAL_ANIMATION)
    inc     (hl)
19$:

    ; レジスタの復帰

    ; 終了
    ret

; ゴールを表示する
;
RoutePrintGoal:

    ; レジスタの保存

    ; スクロールの取得
    ld      a, (routeScroll)
    ld      c, a

    ; スプライトの表示
    ld      a, (routeGoal + ROUTE_GOAL_STATE)
    or      a
    jr      z, 19$
    ld      a, (routeGoal + ROUTE_GOAL_ANIMATION)
    and     #0x0c
    ld      e, a
    ld      d, #0x00
    ld      hl, #routeGoalSprite
    add     hl, de
    ld      de, #(_sprite + GAME_SPRITE_GOAL)
    ld      a, (routeGoal + ROUTE_GOAL_POSITION_Y)
    sub     c
    add     a, (hl)
    ld      (de), a
    inc     hl
    inc     de
    ld      a, (routeGoal + ROUTE_GOAL_POSITION_X)
    add     a, (hl)
    ld      (de), a
    inc     hl
    inc     de
    ld      a, (hl)
    ld      (de), a
    inc     hl
    inc     de
    ld      a, (hl)
    ld      (de), a
;   inc     hl
;   inc     de
19$:

    ; レジスタの復帰

    ; 終了
    ret

; 定数の定義
;

; ゴール
;
routeGoalSprite:

    .db     -0x04 - 0x01, -0x00 + ROUTE_OFFSET_X * 0x08 + 0x20, 0x30, 0x80 | VDP_COLOR_LIGHT_YELLOW
    .db     -0x04 - 0x01, -0x00 + ROUTE_OFFSET_X * 0x08 + 0x20, 0x34, 0x80 | VDP_COLOR_LIGHT_YELLOW
    .db     -0x04 - 0x01, -0x00 + ROUTE_OFFSET_X * 0x08 + 0x20, 0x38, 0x80 | VDP_COLOR_LIGHT_YELLOW
    .db     -0x04 - 0x01, -0x00 + ROUTE_OFFSET_X * 0x08 + 0x20, 0x3c, 0x80 | VDP_COLOR_LIGHT_YELLOW


; DATA 領域
;
    .area   _DATA

; 変数の定義
;

; 経路
;
_route::
    
    .ds     ROUTE_SIZE_X * ROUTE_SIZE_Y

; スクロール
;
routeScroll:

    .ds     0x01

; 底
;
routeBottom:

    .ds     0x02

; カウント
;
routeCount:

    .ds     0x01

; ゴール
;
routeGoal:

    .ds     ROUTE_GOAL_LENGTH
