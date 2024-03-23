; Enemy.s : エネミー
;


; モジュール宣言
;
    .module Enemy

; 参照ファイル
;
    .include    "bios.inc"
    .include    "vdp.inc"
    .include    "System.inc"
    .include    "Sound.inc"
    .include    "App.inc"
    .include    "Game.inc"
    .include    "Route.inc"
    .include	"Enemy.inc"

; 外部変数宣言
;

; マクロの定義
;


; CODE 領域
;
    .area   _CODE

; エネミーを初期化する
;
_EnemyInitialize::
    
    ; レジスタの保存
    
    ; エネミーの初期化
    ld      hl, #(_enemy + 0x0000)
    ld      de, #(_enemy + 0x0001)
    ld      bc, #(ENEMY_LENGTH * ENEMY_ENTRY - 0x0001)
    ld      (hl), #0x00
    ldir

    ; スプライトの初期化
    xor     a
    ld      (enemySpriteRotate), a

    ; レジスタの復帰
    
    ; 終了
    ret

; エネミーを更新する
;
_EnemyUpdate::
    
    ; レジスタの保存

    ; エネミーの走査
    ld      ix, #_enemy
    ld      b, #ENEMY_ENTRY
10$:
    push    bc

    ; 種類別の処理
    ld      l, ENEMY_PROC_L(ix)
    ld      h, ENEMY_PROC_H(ix)
    ld      a, h
    or      l
    jr      z, 19$
    ld      de, #11$
    push    de
    jp      (hl)
;   pop     hl
11$:

    ; 次のエネミーへ
19$:
    ld      bc, #ENEMY_LENGTH
    add     ix, bc
    pop     bc
    djnz    10$

    ; レジスタの復帰
    
    ; 終了
    ret

; エネミーを描画する
;
_EnemyRender::

    ; レジスタの保存

    ; スクロールの取得
    call    _RouteGetScroll
    ld      c, a

    ; エネミーの走査
    ld      ix, #_enemy
    ld      a, (enemySpriteRotate)
    ld      e, a
    ld      d, #0x00
    ld      b, #ENEMY_ENTRY
10$:
    push    bc

    ; 描画の確認
    ld      a, ENEMY_PROC_H(ix)
    or      ENEMY_PROC_L(ix)
    jr      z, 19$

    ; スプライトの表示
    push    de
    ld      hl, #(_sprite + GAME_SPRITE_ENEMY)
    add     hl, de
    ex      de, hl
    ld      l, ENEMY_SPRITE_L(ix)
    ld      h, ENEMY_SPRITE_H(ix)
    ld      a, ENEMY_POSITION_Y(ix)
    sub     c
    add     a, (hl)
    cp      #0xd0
    jr      nz, 11$
    dec     a
11$:
    ld      (de), a
    inc     hl
    inc     de
    ld      a, ENEMY_POSITION_X(ix)
    add     a, (hl)
    ld      (de), a
    inc     hl
    inc     de
    ld      a, (hl)
    ld      (de), a
    inc     hl
    inc     de
    ld      a, ENEMY_COLOR(ix)
    or      (hl)
    ld      (de), a
;   inc     hl
;   inc     de
    pop     de

    ; スプライトのローテート
    ld      a, e
    add     a, #0x04
    and     #(ENEMY_ENTRY * 0x04 - 0x01)
    ld      e, a

    ; 次のエネミーへ
19$:
    ld      bc, #ENEMY_LENGTH
    add     ix, bc
    pop     bc
    djnz    10$

    ; スプライトの更新
    ld      a, (enemySpriteRotate)
    add     a, #0x04
    and     #(ENEMY_ENTRY * 0x04 - 0x01)
    ld      (enemySpriteRotate), a

    ; レジスタの復帰

    ; 終了
    ret

; エネミーが左右に移動する
;
EnemyMoveLeft:

    ; レジスタの保存

    ; 初期化
    ld      a, ENEMY_STATE(ix)
    or      a
    jr      nz, 09$

    ; 向きの設定
    ld      ENEMY_DIRECTION(ix), #ENEMY_DIRECTION_LEFT

    ; 初期化の完了
    inc     ENEMY_STATE(ix)
09$:

    ; 移動
    ld      a, ENEMY_POSITION_X(ix)
    sub     ENEMY_SPEED(ix)
    dec     a
    ld      e, a
    ld      d, ENEMY_POSITION_Y(ix)
    call    _RouteIsWall
    jr      c, 10$
    inc     e
    ld      ENEMY_POSITION_X(ix), e
    call    EnemyIsUp
    jr      19$
10$:
    ld      a, e
    and     #0xf8
    add     a, #0x08
    ld      ENEMY_POSITION_X(ix), a
    ld      e, a
    call    EnemyIsUp
    jr      c, 19$
    ld      hl, #EnemyMoveRight
    ld      ENEMY_PROC_L(ix), l
    ld      ENEMY_PROC_H(ix), h
    ld      ENEMY_STATE(ix), #0x00
;   jr      19$
19$:

    ; アニメーションの更新
    ld      a, ENEMY_ANIMATION(ix)
    inc     a
    cp      #(0x04 * 0x03)
    jr      c, 20$
    xor     a
20$:
    ld      ENEMY_ANIMATION(ix), a

    ; スプライトの設定
;   ld      a, ENEMY_ANIMATION(ix)
    and     #0x0fc
    ld      e, a
    ld      d, #0x00
    ld      hl, #enemySpriteLeft
    add     hl, de
    ld      ENEMY_SPRITE_L(ix), l
    ld      ENEMY_SPRITE_H(ix), h

    ; 消滅の判定
    call    EnemyIsDead

    ; レジスタの復帰

    ; 終了
    ret

EnemyMoveRight:

    ; レジスタの保存

    ; 初期化
    ld      a, ENEMY_STATE(ix)
    or      a
    jr      nz, 09$

    ; 向きの設定
    ld      ENEMY_DIRECTION(ix), #ENEMY_DIRECTION_RIGHT

    ; 初期化の完了
    inc     ENEMY_STATE(ix)
09$:

    ; 移動
    ld      a, ENEMY_POSITION_X(ix)
    add     a, ENEMY_SPEED(ix)
    add     a, #0x08
    ld      e, a
    ld      d, ENEMY_POSITION_Y(ix)
    call    _RouteIsWall
    jr      c, 10$
    ld      a, e
    sub     #0x08
    ld      ENEMY_POSITION_X(ix), a
    ld      e, a
    call    EnemyIsUp
    jr      19$
10$:
    ld      a, e
    and     #0xf8
    sub     #0x08
    ld      ENEMY_POSITION_X(ix), a
    ld      e, a
    call    EnemyIsUp
    jr      c, 19$
    ld      hl, #EnemyMoveLeft
    ld      ENEMY_PROC_L(ix), l
    ld      ENEMY_PROC_H(ix), h
    ld      ENEMY_STATE(ix), #0x00
;   jr      19$
19$:

    ; アニメーションの更新
    ld      a, ENEMY_ANIMATION(ix)
    inc     a
    cp      #(0x04 * 0x03)
    jr      c, 20$
    xor     a
20$:
    ld      ENEMY_ANIMATION(ix), a

    ; スプライトの設定
;   ld      a, ENEMY_ANIMATION(ix)
    and     #0x0fc
    ld      e, a
    ld      d, #0x00
    ld      hl, #enemySpriteRight
    add     hl, de
    ld      ENEMY_SPRITE_L(ix), l
    ld      ENEMY_SPRITE_H(ix), h

    ; 消滅の判定
    call    EnemyIsDead

    ; レジスタの復帰

    ; 終了
    ret

; エネミーが上昇する
;
EnemyUp:

    ; レジスタの保存

;   ; 初期化
;   ld      a, ENEMY_STATE(ix)
;   or      a
;   jr      nz, 09$
;
;   ; 初期化の完了
;   inc     ENEMY_STATE(ix)
;09$:

    ; 上昇
    ld      a, ENEMY_POSITION_Y(ix)
    ld      b, ENEMY_SPEED(ix)
10$:
    dec     a
    djnz    10$
    ld      ENEMY_POSITION_Y(ix), a
    and     #0x0f
    jr      nz, 19$
    call    EnemyIsUp
    jr      c, 19$
    ld      hl, #EnemyMoveLeft
    ld      a, ENEMY_DIRECTION(ix)
    or      a
    jr      z, 11$
    ld      hl, #EnemyMoveRight
11$:
    ld      ENEMY_PROC_L(ix), l
    ld      ENEMY_PROC_H(ix), h
    ld      ENEMY_STATE(ix), #0x00
;   jr      19$
19$:

    ; アニメーションの更新
    ld      a, ENEMY_ANIMATION(ix)
    inc     a
    cp      #(0x04 * 0x02)
    jr      c, 20$
    xor     a
20$:
    ld      ENEMY_ANIMATION(ix), a

    ; スプライトの設定
;   ld      a, ENEMY_ANIMATION(ix)
    and     #0x0fc
    ld      e, a
    ld      d, #0x00
    ld      hl, #enemySpriteUp
    add     hl, de
    ld      ENEMY_SPRITE_L(ix), l
    ld      ENEMY_SPRITE_H(ix), h

    ; 消滅の判定
    call    EnemyIsDead

    ; レジスタの復帰

    ; 終了
    ret

EnemyUpLeft:

    ; レジスタの保存

;   ; 初期化
;   ld      a, ENEMY_STATE(ix)
;   or      a
;   jr      nz, 09$
;
;   ; 初期化の完了
;   inc     ENEMY_STATE(ix)
;09$:

    ; 上昇
    ld      e, ENEMY_POSITION_X(ix)
    ld      d, ENEMY_POSITION_Y(ix)
    ld      b, ENEMY_SPEED(ix)
10$:
    dec     e
    dec     d
    djnz    10$
    ld      ENEMY_POSITION_X(ix), e
    ld      ENEMY_POSITION_Y(ix), d
    ld      a, d
    and     #0x0f
    jr      nz, 19$
    call    EnemyIsUp
    jr      c, 19$
    ld      hl, #EnemyMoveLeft
    ld      ENEMY_PROC_L(ix), l
    ld      ENEMY_PROC_H(ix), h
    ld      ENEMY_STATE(ix), #0x00
;   jr      19$
19$:

    ; アニメーションの更新
    ld      a, ENEMY_ANIMATION(ix)
    inc     a
    cp      #(0x04 * 0x03)
    jr      c, 20$
    xor     a
20$:
    ld      ENEMY_ANIMATION(ix), a

    ; スプライトの設定
;   ld      a, ENEMY_ANIMATION(ix)
    and     #0x0fc
    ld      e, a
    ld      d, #0x00
    ld      hl, #enemySpriteLeft
    add     hl, de
    ld      ENEMY_SPRITE_L(ix), l
    ld      ENEMY_SPRITE_H(ix), h

    ; 消滅の判定
    call    EnemyIsDead

    ; レジスタの復帰

    ; 終了
    ret

EnemyUpRight:

    ; レジスタの保存

;   ; 初期化
;   ld      a, ENEMY_STATE(ix)
;   or      a
;   jr      nz, 09$
;
;   ; 初期化の完了
;   inc     ENEMY_STATE(ix)
;09$:

    ; 上昇
    ld      e, ENEMY_POSITION_X(ix)
    ld      d, ENEMY_POSITION_Y(ix)
    ld      b, ENEMY_SPEED(ix)
10$:
    inc     e
    dec     d
    djnz    10$
    ld      ENEMY_POSITION_X(ix), e
    ld      ENEMY_POSITION_Y(ix), d
    ld      a, d
    and     #0x0f
    jr      nz, 19$
    call    EnemyIsUp
    jr      c, 19$
    ld      hl, #EnemyMoveRight
    ld      ENEMY_PROC_L(ix), l
    ld      ENEMY_PROC_H(ix), h
    ld      ENEMY_STATE(ix), #0x00
;   jr      19$
19$:

    ; アニメーションの更新
    ld      a, ENEMY_ANIMATION(ix)
    inc     a
    cp      #(0x04 * 0x03)
    jr      c, 20$
    xor     a
20$:
    ld      ENEMY_ANIMATION(ix), a

    ; スプライトの設定
;   ld      a, ENEMY_ANIMATION(ix)
    and     #0x0fc
    ld      e, a
    ld      d, #0x00
    ld      hl, #enemySpriteRight
    add     hl, de
    ld      ENEMY_SPRITE_L(ix), l
    ld      ENEMY_SPRITE_H(ix), h

    ; 消滅の判定
    call    EnemyIsDead

    ; レジスタの復帰

    ; 終了
    ret

; エネミーが消滅する
;
EnemyDead:

    ; レジスタの保存

    ; 初期化
    ld      a, ENEMY_STATE(ix)
    or      a
    jr      nz, 09$

    ; アニメーションの設定
    ld      ENEMY_ANIMATION(ix), #(0x04 * 0x04)
 
    ; 初期化の完了
    inc     ENEMY_STATE(ix)
09$:

    ; アニメーションの更新
    dec     ENEMY_ANIMATION(ix)
    jr      nz, 10$
    xor     a
    ld      ENEMY_PROC_L(ix), a
    ld      ENEMY_PROC_H(ix), a
10$:

    ; スプライトの設定
    ld      a, ENEMY_ANIMATION(ix)
    and     #0x0fc
    ld      e, a
    ld      d, #0x00
    ld      hl, #enemySpriteDead
    add     hl, de
    ld      ENEMY_SPRITE_L(ix), l
    ld      ENEMY_SPRITE_H(ix), h

    ; レジスタの復帰

    ; 終了
    ret

; エネミーが上昇するかどうかを判定する
;
EnemyIsUp:

    ; レジスタの保存
    push    hl
    push    de

    ; cf > 1 = 上昇する

    ; 上昇の判定
    ld      a, ENEMY_POSITION_X(ix)
    ld      e, a
    and     #0x07
    jr      nz, 18$
    ld      d, ENEMY_POSITION_Y(ix)
    dec     d
    bit     #ENEMY_FLAG_90_BIT, ENEMY_FLAG(ix)
    jr      z, 10$
    call    _RouteIsUp
    jr      nc, 18$
    ld      hl, #EnemyUp
    jr      17$
10$:
    bit     #ENEMY_FLAG_45_BIT, ENEMY_FLAG(ix)
    jr      z, 18$
    ld      a, ENEMY_DIRECTION(ix)
    or      a
    jr      nz, 11$
    call    _RouteIsUpLeft
    jr      nc, 18$
    ld      hl, #EnemyUpLeft
    jr      17$
11$:
    call    _RouteIsUpRight
    jr      nc, 18$
    ld      hl, #EnemyUpRight
;   jr      17$
17$:
    ld      ENEMY_PROC_L(ix), l
    ld      ENEMY_PROC_H(ix), h
    ld      ENEMY_STATE(ix), #0x00
    scf
    jr      19$
18$:
    or      a
19$:

    ; レジスタの復帰
    pop     de
    pop     hl

    ; 終了
    ret

; エネミーが消滅するかどうかを判定する
;
EnemyIsDead:

    ; レジスタの保存
    push    hl

    ; cf > 1 = 上昇する

    ; 消滅の判定
    call    _RouteGetScroll
    sub     ENEMY_POSITION_Y(ix)
    neg
    cp      #(0x10 + 0x01)
    jr      nc, 18$
    ld      hl, #EnemyDead
    ld      ENEMY_PROC_L(ix), l
    ld      ENEMY_PROC_H(ix), h
    ld      ENEMY_STATE(ix), #0x00
    scf
    jr      19$
18$:
    or      a
19$:

    ; レジスタの復帰
    pop     hl

    ; 終了
    ret

; エネミーを生成する
;
_EnemyBorn::

    ; レジスタの保存
    push    bc

    ; a < 生成する数

    ; １体の生成
    ld      b, a
10$:
    call    EnemyBornOne
    djnz    10$

    ; レジスタの復帰
    pop     bc

    ; 終了
    ret

EnemyBornOne:

    ; レジスタの保存
    push    hl
    push    bc
    push    de

    ; 底の取得
    call    _RouteGetBottom
    jp      c, 90$
    ld      c, a

    ; エネミーの検索
    ld      ix, #_enemy
    ld      de, #ENEMY_LENGTH
    ld      b, #ENEMY_ENTRY
20$:
    ld      a, ENEMY_PROC_L(ix)
    or      ENEMY_PROC_H(ix)
    jr      z, 21$
    add     ix, de
    djnz    20$
    jr      90$

    ; エネミーの設定
21$:
    call    _SystemGetRandom
    cp      #(ROUTE_VIEW_X * 0x08)
    jr      c, 22$
    add     a, #(((0x20 - ROUTE_VIEW_X) / 0x02) * 0x08 - (ROUTE_VIEW_X * 0x08))
22$:
    and     #0xf8
    ld      ENEMY_POSITION_X(ix), a
    ld      ENEMY_POSITION_Y(ix), c
    ld      ENEMY_ANIMATION(ix), a
    ld      hl, #EnemyMoveLeft
    call    _SystemGetRandom
    and     #0x01
    jr      z, 23$
    ld      hl, #EnemyMoveRight
23$:
    ld      ENEMY_PROC_L(ix), l
    ld      ENEMY_PROC_H(ix), h
    ld      ENEMY_STATE(ix), #0x00
    call    _SystemGetRandom
    and     #0x03
    jr      nz, 24$
    ld      ENEMY_FLAG(ix), #ENEMY_FLAG_NULL
    ld      ENEMY_SPEED(ix), #0x01
    ld      ENEMY_COLOR(ix), #VDP_COLOR_GRAY
    jr      29$
24$:
    dec     a
    jr      nz, 25$
    ld      ENEMY_FLAG(ix), #ENEMY_FLAG_90
    ld      ENEMY_SPEED(ix), #0x01
    ld      ENEMY_COLOR(ix), #VDP_COLOR_DARK_BLUE
    jr      29$
25$:
    dec     a
    jr      nz, 26$
    ld      ENEMY_FLAG(ix), #ENEMY_FLAG_45
    ld      ENEMY_SPEED(ix), #0x01
    ld      ENEMY_COLOR(ix), #VDP_COLOR_DARK_GREEN
    jr      29$
26$:
    ld      ENEMY_FLAG(ix), #ENEMY_FLAG_45
    ld      ENEMY_SPEED(ix), #0x02
    ld      ENEMY_COLOR(ix), #VDP_COLOR_DARK_YELLOW
;   jr      29$
29$:
;   jr      90$

    ; 生成の完了
90$:

    ; レジスタの復帰
    pop     de
    pop     bc
    pop     hl

    ; 終了
    ret

; エネミーを削除する
;
_EnemyKill::

    ; レジスタの保存
    push    hl

    ; ix < エネミー

    ; エネミーの削除
    ld      hl, #EnemyDead
    ld      ENEMY_PROC_L(ix), l
    ld      ENEMY_PROC_H(ix), h
    ld      ENEMY_STATE(ix), #0x00

    ; レジスタの復帰
    pop     hl

    ; 終了
    ret

; 定数の定義
;

; スプライト
;
enemySprite:

enemySpriteLeft:

    .db     -0x04 - 0x01, -0x04 + ROUTE_OFFSET_X * 0x08 + 0x20, 0x40, 0x80
    .db     -0x04 - 0x01, -0x04 + ROUTE_OFFSET_X * 0x08 + 0x20, 0x44, 0x80
    .db     -0x04 - 0x01, -0x04 + ROUTE_OFFSET_X * 0x08 + 0x20, 0x48, 0x80

enemySpriteRight:

    .db     -0x04 - 0x01, -0x04 + ROUTE_OFFSET_X * 0x08 + 0x20, 0x4c, 0x80
    .db     -0x04 - 0x01, -0x04 + ROUTE_OFFSET_X * 0x08 + 0x20, 0x50, 0x80
    .db     -0x04 - 0x01, -0x04 + ROUTE_OFFSET_X * 0x08 + 0x20, 0x54, 0x80

enemySpriteUp:

    .db     -0x04 - 0x01, -0x04 + ROUTE_OFFSET_X * 0x08 + 0x20, 0x58, 0x80
    .db     -0x04 - 0x01, -0x04 + ROUTE_OFFSET_X * 0x08 + 0x20, 0x5c, 0x80

enemySpriteDead:

    .db     -0x04 - 0x01, -0x04 + ROUTE_OFFSET_X * 0x08 + 0x20, 0x6c, 0x80
    .db     -0x04 - 0x01, -0x04 + ROUTE_OFFSET_X * 0x08 + 0x20, 0x68, 0x80
    .db     -0x04 - 0x01, -0x04 + ROUTE_OFFSET_X * 0x08 + 0x20, 0x64, 0x80
    .db     -0x04 - 0x01, -0x04 + ROUTE_OFFSET_X * 0x08 + 0x20, 0x60, 0x80


; DATA 領域
;
    .area   _DATA

; 変数の定義
;

; エネミー
;
_enemy::
    
    .ds     ENEMY_LENGTH * ENEMY_ENTRY

; スプライト
;
enemySpriteRotate:

    .ds     0x01

