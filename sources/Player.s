; Player.s : プレイヤ
;


; モジュール宣言
;
    .module Player

; 参照ファイル
;
    .include    "bios.inc"
    .include    "vdp.inc"
    .include    "System.inc"
    .include    "Sound.inc"
    .include    "App.inc"
    .include    "Game.inc"
    .include    "Route.inc"
    .include	"Player.inc"

; 外部変数宣言
;

; マクロの定義
;


; CODE 領域
;
    .area   _CODE

; プレイヤを初期化する
;
_PlayerInitialize::
    
    ; レジスタの保存
    
    ; プレイヤの初期化
    ld      hl, #playerDefault
    ld      de, #_player
    ld      bc, #PLAYER_LENGTH
    ldir

    ; 処理の設定
    ld      hl, #PlayerStart
    ld      (_player + PLAYER_PROC_L), hl
    xor     a
    ld      (_player + PLAYER_STATE), a
    
    ; レジスタの復帰
    
    ; 終了
    ret

; プレイヤを更新する
;
_PlayerUpdate::
    
    ; レジスタの保存

    ; 状態別の処理
    ld      hl, #10$
    push    hl
    ld      hl, (_player + PLAYER_PROC_L)
    jp      (hl)
;   pop     hl
10$:

    ; 無敵の更新
    ld      hl, #(_player + PLAYER_NODAMAGE)
    ld      a, (hl)
    or      a
    jr      z, 29$
    dec     (hl)
    jr      nz, 29$
    ld      a, #PLAYER_SPEED_NORMAL
    ld      (_player + PLAYER_SPEED_MAXIMUM), a
29$:

    ; レジスタの復帰
    
    ; 終了
    ret

; プレイヤを描画する
;
_PlayerRender::

    ; レジスタの保存

    ; 位置の取得
    call    _RouteGetScroll
    ld      b, a
    ld      a, (_player + PLAYER_POSITION_Y)
    sub     b
    ld      b, a
    ld      a, (_player + PLAYER_POSITION_X_H)
    ld      c, a

    ; スプライトの表示
    ld      a, (_player + PLAYER_BLINK)
    and     #0x04
    jr      nz, 19$
    ld      hl, (_player + PLAYER_SPRITE_L)
    ld      de, #(_sprite + GAME_SPRITE_PLAYER_0)
    ld      a, b
    add     a, (hl)
    ld      (de), a
    inc     hl
    inc     de
    ld      a, c
    add     a, (hl)
    ld      (de), a
    inc     hl
    inc     de
    ld      a, (hl)
    ld      (de), a
    inc     hl
    inc     de
    ld      a, (_player + PLAYER_COLOR)
    or      (hl)
    ld      (de), a
    inc     hl
    ld      de, #(_sprite + GAME_SPRITE_PLAYER_1)
    ld      a, b
    add     a, (hl)
    ld      (de), a
    inc     hl
    inc     de
    ld      a, c
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
19$:

    ; レジスタの復帰

    ; 終了
    ret

; 何もしない
;
PlayerNull:

    ; レジスタの保存

    ; レジスタの復帰

    ; 終了
    ret

; プレイヤがスタートする
;
PlayerStart:

    ; レジスタの保存

    ; 初期化
    ld      a, (_player + PLAYER_STATE)
    or      a
    jr      nz, 09$

    ; 点滅の設定
    ld      a, #PLAYER_BLINK_START
    ld      (_player + PLAYER_BLINK), a

    ; 初期化の完了
    ld      hl, #(_player + PLAYER_STATE)
    inc     (hl)
09$:

    ; 点滅の更新
    ld      hl, #(_player + PLAYER_BLINK)
    dec     (hl)
    jr      nz, 19$

    ; 状態の更新
    ld      hl, #PlayerDownLeft
    ld      (_player + PLAYER_PROC_L), hl
    xor     a
    ld      (_player + PLAYER_STATE), a
19$:

    ; スプライトの設定
    call    PlayerSetSprite

    ; レジスタの復帰

    ; 終了
    ret

; プレイヤが左右に移動する
;
PlayerMoveLeft:

    ; レジスタの保存

    ; 初期化
    ld      a, (_player + PLAYER_STATE)
    or      a
    jr      nz, 09$

    ; フラグの設定
    ld      hl, #(_player + PLAYER_FLAG)
    res     #PLAYER_FLAG_TURN_BIT, (hl)

    ; 初期化の完了
    ld      hl, #(_player + PLAYER_STATE)
    inc     (hl)
09$:

    ; 向きの更新
    ld      hl, #(_player + PLAYER_FLAG)
    bit     #PLAYER_FLAG_TURN_BIT, (hl)
    jr      z, 10$
    call    PlayerDirectionCenter
    jr      19$
10$:
    ld      a, (_player + PLAYER_DIRECTION)
    or      a
    jr      nz, 11$
    ld      a, (_input + INPUT_BUTTON_SPACE)
    or      a
    jr      z, 11$
    set     #PLAYER_FLAG_TURN_BIT, (hl)
    ld      a, #SOUND_SE_CLICK
    call    _SoundPlaySe
    jr      19$
11$:
    call    PlayerDirectionLeft
;   jr      19$
19$:

    ; 速度の更新
    ld      hl, #(_player + PLAYER_FLAG)
    bit     #PLAYER_FLAG_TURN_BIT, (hl)
    jr      z, 20$
    call    PlayerBrake
    ld      a, (_player + PLAYER_SPEED)
    or      a
    jr      nz, 29$
    ld      hl, #PlayerMoveRight
    ld      (_player + PLAYER_PROC_L), hl
    xor     a
    ld      (_player + PLAYER_STATE), a
    jr      29$
20$:
    call    PlayerAccel
;   jr      29$
29$:

    ; 位置の更新
    ld      a, (_player + PLAYER_POSITION_Y)
    ld      d, a
    ld      hl, (_player + PLAYER_POSITION_X_L)
    ld      a, (_player + PLAYER_SPEED)
    ld      b, a
    xor     a
    srl     b
    rra
    srl     b
    rra
    srl     b
    rra
    ld      c, a
    or      a
    sbc     hl, bc
    ld      e, h
    call    _RouteIsWall
    jr      nc, 39$
    ld      a, e
    add     a, #0x07
    and     #0xf8
    ld      h, a
    ld      l, #0x00
    ld      de, #PlayerMoveRight
    ld      (_player + PLAYER_PROC_L), de
    xor     a
    ld      (_player + PLAYER_STATE), a
39$:
    ld      (_player + PLAYER_POSITION_X_L), hl

    ; 降下の判定
    call    PlayerIsDownLeft

    ; ゴールの判定
    call    PlayerIsMoveGoal

    ; スプライトの設定
    call    PlayerSetSprite

    ; レジスタの復帰

    ; 終了
    ret

PlayerMoveRight:

    ; レジスタの保存

    ; 初期化
    ld      a, (_player + PLAYER_STATE)
    or      a
    jr      nz, 09$

    ; フラグの設定
    ld      hl, #(_player + PLAYER_FLAG)
    res     #PLAYER_FLAG_TURN_BIT, (hl)

    ; 初期化の完了
    ld      hl, #(_player + PLAYER_STATE)
    inc     (hl)
09$:

    ; 向きの更新
    ld      hl, #(_player + PLAYER_FLAG)
    bit     #PLAYER_FLAG_TURN_BIT, (hl)
    jr      z, 10$
    call    PlayerDirectionCenter
    jr      19$
10$:
    ld      a, (_player + PLAYER_DIRECTION)
    cp      #PLAYER_DIRECTION_RIGHT
    jr      nz, 11$
    ld      a, (_input + INPUT_BUTTON_SPACE)
    or      a
    jr      z, 11$
    set     #PLAYER_FLAG_TURN_BIT, (hl)
    ld      a, #SOUND_SE_CLICK
    call    _SoundPlaySe
    jr      19$
11$:
    call    PlayerDirectionRight
;   jr      19$
19$:

    ; 速度の更新
    ld      hl, #(_player + PLAYER_FLAG)
    bit     #PLAYER_FLAG_TURN_BIT, (hl)
    jr      z, 20$
    call    PlayerBrake
    ld      a, (_player + PLAYER_SPEED)
    or      a
    jr      nz, 29$
    ld      hl, #PlayerMoveLeft
    ld      (_player + PLAYER_PROC_L), hl
    xor     a
    ld      (_player + PLAYER_STATE), a
    jr      29$
20$:
    call    PlayerAccel
;   jr      29$
29$:

    ; 位置の更新
    ld      a, (_player + PLAYER_POSITION_Y)
    ld      d, a
    ld      hl, (_player + PLAYER_POSITION_X_L)
    ld      a, (_player + PLAYER_SPEED)
    ld      b, a
    xor     a
    srl     b
    rra
    srl     b
    rra
    srl     b
    rra
    ld      c, a
    add     hl, bc
    ld      a, h
    add     a, #0x07
    ld      e, a
    call    _RouteIsWall
    jr      nc, 39$
    ld      a, e
    and     #0xf8
    sub     #0x08
    ld      h, a
    ld      l, #0x00
    ld      de, #PlayerMoveLeft
    ld      (_player + PLAYER_PROC_L), de
    xor     a
    ld      (_player + PLAYER_STATE), a
39$:
    ld      (_player + PLAYER_POSITION_X_L), hl

    ; 降下の判定
    call    PlayerIsDownRight

    ; ゴールの判定
    call    PlayerIsMoveGoal

    ; スプライトの設定
    call    PlayerSetSprite

    ; レジスタの復帰

    ; 終了
    ret

PlayerMoveGoal:

    ; レジスタの保存

;   ; 初期化
;   ld      a, (_player + PLAYER_STATE)
;   or      a
;   jr      nz, 09$
;
;   ; 初期化の完了
;   ld      hl, #(_player + PLAYER_STATE)
;   inc     (hl)
09$:

    ; ゴール済み
    ld      a, (_player + PLAYER_FLAG)
    bit     #PLAYER_FLAG_GOAL_BIT, a
    jr      nz, 90$

    ; 向きの更新
    call    PlayerDirectionLeft

    ; 速度の更新
    call    PlayerAccel

    ; 位置の更新
    ld      hl, (_player + PLAYER_POSITION_X_L)
    ld      a, h
    cp      #(ROUTE_VIEW_X * 0x08)
    jr      c, 30$
    cp      #(0xf8 + 0x01)
    jr      nc, 30$
    ld      hl, #(_player + PLAYER_FLAG)
    set     #PLAYER_FLAG_GOAL_BIT, (hl)
    jr      39$
30$:
    ld      a, (_player + PLAYER_SPEED)
    ld      b, a
    xor     a
    srl     b
    rra
    srl     b
    rra
    srl     b
    rra
    ld      c, a
    or      a
    sbc     hl, bc
    ld      (_player + PLAYER_POSITION_X_L), hl
39$:

    ; 移動の完了
90$:

    ; スプライトの設定
    call    PlayerSetSprite

    ; レジスタの復帰

    ; 終了
    ret

; プレイヤが降下する
;
PlayerDownLeft:

    ; レジスタの保存

;   ; 初期化
;   ld      a, (_player + PLAYER_STATE)
;   or      a
;   jr      nz, 09$
;
;   ; 初期化の完了
;   ld      hl, #(_player + PLAYER_STATE)
;   inc     (hl)
09$:

    ; 向きの更新
    call    PlayerDirectionLeft

    ; 速度の更新
    call    PlayerAccel

    ; 降下
    ld      a, (_player + PLAYER_POSITION_Y)
    ld      d, a
    ld      a, (_player + PLAYER_POSITION_X_H)
    ld      e, a
    ld      a, (_player + PLAYER_SPEED)
    and     #0xf8
    rrca
    rrca
    rrca
    jr      z, 39$
    ld      b, a
    ld      a, d
    and     #0x0f
    sub     #0x10
    neg
    cp      b
    jr      nc, 30$
    ld      b, a
30$:
    ld      a, e
    sub     b
    ld      (_player + PLAYER_POSITION_X_H), a
    ld      a, d
    and     #0x0f
    add     a, b
    cp      #0x10
    ld      a, d
    jr      nc, 31$
    add     a, b
    ld      (_player + PLAYER_POSITION_Y), a
    jr      39$
31$:
    and     #0xf0
    add     a, #0x10
    ld      (_player + PLAYER_POSITION_Y), a

    ; 降下の完了
    call    _GameNextFloor
    call    PlayerIsDownLeft
    jr      c, 39$
    ld      hl, #PlayerMoveLeft
    ld      (_player + PLAYER_PROC_L), hl
    xor     a
    ld      (_player + PLAYER_STATE), a
39$:

    ; スプライトの設定
    call    PlayerSetSprite

    ; レジスタの復帰

    ; 終了
    ret

PlayerDownRight:

    ; レジスタの保存

;   ; 初期化
;   ld      a, (_player + PLAYER_STATE)
;   or      a
;   jr      nz, 09$
;
;   ; 初期化の完了
;   ld      hl, #(_player + PLAYER_STATE)
;   inc     (hl)
09$:

    ; 向きの更新
    call    PlayerDirectionRight

    ; 速度の更新
    call    PlayerAccel

    ; 降下
    ld      a, (_player + PLAYER_POSITION_Y)
    ld      d, a
    ld      a, (_player + PLAYER_POSITION_X_H)
    ld      e, a
    ld      a, (_player + PLAYER_SPEED)
    and     #0xf8
    rrca
    rrca
    rrca
    jr      z, 39$
    ld      b, a
    ld      a, d
    and     #0x0f
    sub     #0x10
    neg
    cp      b
    jr      nc, 30$
    ld      b, a
30$:
    ld      a, e
    add     a, b
    ld      (_player + PLAYER_POSITION_X_H), a
    ld      a, d
    and     #0x0f
    add     a, b
    cp      #0x10
    ld      a, d
    jr      nc, 31$
    add     a, b
    ld      (_player + PLAYER_POSITION_Y), a
    jr      39$
31$:
    and     #0xf0
    add     a, #0x10
    ld      (_player + PLAYER_POSITION_Y), a

    ; 降下の完了
    call    _GameNextFloor
    call    PlayerIsDownRight
    jr      c, 39$
    ld      hl, #PlayerMoveRight
    ld      (_player + PLAYER_PROC_L), hl
    xor     a
    ld      (_player + PLAYER_STATE), a
39$:

    ; スプライトの設定
    call    PlayerSetSprite

    ; レジスタの復帰

    ; 終了
    ret

; プレイヤがミスする
;
PlayerMiss:

    ; レジスタの保存

    ; 初期化
    ld      a, (_player + PLAYER_STATE)
    or      a
    jr      nz, 09$

    ; フラグの設定
    ld      hl, #(_player + PLAYER_FLAG)
    set     #PLAYER_FLAG_MISS_BIT, (hl)

    ; アニメーションの設定
    ld      a, #PLAYER_ANIMATION_MISS
    ld      (_player + PLAYER_ANIMATION), a

    ; SE の再生
    ld      a, #SOUND_SE_BOMB
    call    _SoundPlaySe

    ; 初期化の完了
    ld      hl, #(_player + PLAYER_STATE)
    inc     (hl)
09$:

    ; アニメーションの更新
    ld      hl, #(_player + PLAYER_ANIMATION)
    ld      a, (hl)
    or      a
    jr      z, 19$
    dec     (hl)
    jr      nz, 19$
    ld      hl, #(_player + PLAYER_FLAG)
    set     #PLAYER_FLAG_OVER_BIT, (hl)
19$:

    ; スプライトの設定
    call    PlayerSetSprite

    ; レジスタの復帰

    ; 終了
    ret

; プレイヤの向きを更新する
;
PlayerDirectionLeft:

    ; レジスタの保存

    ; 向きの更新
    ld      hl, #(_player + PLAYER_DIRECTION)
    ld      a, (hl)
    or      a
    jr      z, 10$
    dec     (hl)
10$:

    ; レジスタの復帰

    ; 終了
    ret

PlayerDirectionRight:

    ; レジスタの保存

    ; 向きの更新
    ld      hl, #(_player + PLAYER_DIRECTION)
    ld      a, (hl)
    cp      #PLAYER_DIRECTION_RIGHT
    adc     a, #0x00
    ld      (hl), a

    ; レジスタの復帰

    ; 終了
    ret

PlayerDirectionCenter:

    ; レジスタの保存

    ; 向きの更新
    ld      hl, #(_player + PLAYER_DIRECTION)
    ld      a, (hl)
    cp      #PLAYER_DIRECTION_CENTER
    jr      z, 19$
    jr      nc, 10$
    inc     (hl)
    jr      19$
10$:
    dec     (hl)
19$:

    ; レジスタの復帰

    ; 終了
    ret

; プレイヤの速度を更新する
;
PlayerAccel:

    ; レジスタの保存

    ; 速度の更新
    ld      hl, #(_player + PLAYER_SPEED)
    ld      a, (_player + PLAYER_SPEED_MAXIMUM)
    ld      c, a
    ld      a, (hl)
    add     a, #PLAYER_SPEED_ACCEL
    cp      c
    jr      c, 10$
    ld      a, c
10$:
    ld      (hl), a

    ; レジスタの復帰

    ; 終了
    ret

PlayerBrake:

    ; レジスタの保存

    ; 速度の更新
    ld      hl, #(_player + PLAYER_SPEED)
    ld      a, (hl)
    sub     #PLAYER_SPEED_BRAKE
    jr      nc, 10$
    xor     a
10$:
    ld      (hl), a

    ; レジスタの復帰

    ; 終了
    ret

; プレイヤが降下できるかを判定する
;
PlayerIsDownLeft:

    ; レジスタの保存

    ; cf > 1 = 降下

    ; 降下の判定
    ld      a, (_player + PLAYER_DIRECTION)
    or      a
    jr      nz, 19$
;   cp      #PLAYER_DIRECTION_CENTER
;   jr      nc, 19$
    ld      a, (_player + PLAYER_POSITION_Y)
    ld      d, a
    ld      a, (_player + PLAYER_POSITION_X_H)
    add     a, #0x07
    ld      e, a
    call    _RouteIsDownLeft
    jr      nc, 19$
    ld      a, e
    and     #0x07
    sub     #0x08
    neg
    add     a, d
    ld      (_player + PLAYER_POSITION_Y), a
    ld      a, e
    sub     #0x07
    ld      (_player + PLAYER_POSITION_X_H), a
    ld      hl, #PlayerDownLeft
    ld      (_player + PLAYER_PROC_L), hl
    xor     a
    ld      (_player + PLAYER_STATE), a
    scf
19$:

    ; レジスタの保存

    ; 終了
    ret

PlayerIsDownRight:

    ; レジスタの保存

    ; cf > 1 = 降下

    ; 降下の判定
    ld      a, (_player + PLAYER_DIRECTION)
    cp      #PLAYER_DIRECTION_RIGHT
    jr      nz, 19$
;   cp      #(PLAYER_DIRECTION_CENTER + 0x01)
;   jr      c, 19$
    ld      a, (_player + PLAYER_POSITION_Y)
    ld      d, a
    ld      a, (_player + PLAYER_POSITION_X_H)
    ld      e, a
    call    _RouteIsDownRight
    jr      nc, 19$
    ld      a, e
    and     #0x07
    inc     a
    add     a, d
    ld      (_player + PLAYER_POSITION_Y), a
    ld      hl, #PlayerDownRight
    ld      (_player + PLAYER_PROC_L), hl
    xor     a
    ld      (_player + PLAYER_STATE), a
    scf
19$:

    ; レジスタの保存

    ; 終了
    ret

; プレイヤがゴールする／したかどうかを判定する
;
_PlayerIsGoal::

    ; レジスタの保存

    ; cf > 1 = ゴール

    ; ゴールの判定
    ld      a, (_player + PLAYER_FLAG)
    or      a
    bit     #PLAYER_FLAG_GOAL_BIT, a
    jr      z, 19$
    scf
19$:

    ; レジスタの復帰

    ; 終了
    ret

PlayerIsMoveGoal:

    ; レジスタの保存

    ; cf > 1 = ゴール

    ; ゴールの判定
    call    _GameGetFloor
    cp      #GAME_FLOOR_GOAL
    jr      nz, 18$
    ld      a, (_player + PLAYER_POSITION_X_H)
    cp      #0x10
    jr      nc, 18$
    ld      hl, #PlayerMoveGoal
    ld      (_player + PLAYER_PROC_L), hl
    xor     a
    ld      (_player + PLAYER_STATE), a
    scf
    jr      19$
18$:
    or      a
19$:

    ; レジスタの復帰

    ; 終了
    ret

; プレイヤがゲームオーバーになったどうかを判定する
;
_PlayerIsOver::

    ; レジスタの保存

    ; cf > 1 = オーバー

    ; ゲームオーバーの判定
    ld      a, (_player + PLAYER_FLAG)
    bit     #PLAYER_FLAG_OVER_BIT, a
    jr      z, 18$
    scf
    jr      19$
18$:
    or      a
19$:

    ; レジスタの復帰

    ; 終了
    ret

; プレイヤの位置を取得する
;
_PlayerGetPositionY::

    ; レジスタの保存

    ; a > Y 位置

    ; 位置の取得
    ld      a, (_player + PLAYER_POSITION_Y)

    ; レジスタの復帰

    ; 終了
    ret

; プレイヤのミスを設定する
;
_PlayerSetMiss::

    ; レジスタの保存
    push    hl

    ; ミスの設定
    ld      hl, #PlayerMiss
    ld      (_player + PLAYER_PROC_L), hl
    xor     a
    ld      (_player + PLAYER_STATE), a

    ; レジスタの復帰
    pop     hl

    ; 終了
    ret

; プレイヤの無敵を設定する
;
_PlayerSetNoDamage::

    ; レジスタの保存

    ; 無敵の設定
    ld      a, #PLAYER_NODAMAGE_FRAME
    ld      (_player + PLAYER_NODAMAGE), a
    ld      a, #PLAYER_SPEED_FAST
    ld      (_player + PLAYER_SPEED_MAXIMUM), a

    ; レジスタの復帰

    ; 終了
    ret

; プレイヤのスプライトを設定する
;
PlayerSetSprite:

    ; レジスタの保存

    ; 爆発の設定
    ld      a, (_player + PLAYER_FLAG)
    bit     #PLAYER_FLAG_MISS_BIT, a
    jr      z, 10$
    ld      a, (_player + PLAYER_ANIMATION)
    and     #0x08
    jr      nz, 10$
    ld      hl, #playerSpriteBomb
    ld      (_player + PLAYER_SPRITE_L), hl
    ld      a, #VDP_COLOR_DARK_YELLOW
    ld      (_player + PLAYER_COLOR), a
    jr      19$

    ; シートの設定
10$:
    ld      a, (_player + PLAYER_DIRECTION)
    add     a, a
    add     a, a
    add     a, a
    ld      e, a
    ld      d, #0x00
    ld      hl, #playerSpriteSheet
    add     hl, de
    ld      (_player + PLAYER_SPRITE_L), hl
    ld      a, (_player + PLAYER_NODAMAGE)
    or      a
    ld      a, #VDP_COLOR_WHITE
    jr      z, 11$
    call    _GameGetRandomColor
11$:
    ld      (_player + PLAYER_COLOR), a

    ; 設定の完了
19$:

    ; レジスタの復帰

    ; 終了
    ret

; 定数の定義
;

; プレイヤの初期値
;
playerDefault:

    .dw     PLAYER_PROC_NULL
    .db     PLAYER_STATE_NULL
    .db     PLAYER_FLAG_NULL
    .dw     0x6000 ; PLAYER_POSITION_NULL
    .db     0x00 ; PLAYER_POSITION_NULL
    .db     PLAYER_SPEED_NULL
    .db     PLAYER_SPEED_NORMAL ; PLAYER_SPEED_NULL
    .db     PLAYER_DIRECTION_LEFT ; PLAYER_DIRECTION_NULL
    .db     PLAYER_NODAMAGE_NULL
    .db     PLAYER_BLINK_NULL
    .db     PLAYER_ANIMATION_NULL
    .dw     PLAYER_SPRITE_NULL
    .db     PLAYER_COLOR_NULL

; スプライト
;
playerSprite:

playerSpriteSheet:

    .db     -0x04 - 0x01, -0x04 + ROUTE_OFFSET_X * 0x08 + 0x20, 0x04, 0x80 | VDP_COLOR_TRANSPARENT
    .db     -0x04 - 0x01, -0x04 + ROUTE_OFFSET_X * 0x08 + 0x20, 0x18, 0x80 | VDP_COLOR_BLACK
    .db     -0x04 - 0x01, -0x04 + ROUTE_OFFSET_X * 0x08 + 0x20, 0x08, 0x80 | VDP_COLOR_TRANSPARENT
    .db     -0x04 - 0x01, -0x04 + ROUTE_OFFSET_X * 0x08 + 0x20, 0x1c, 0x80 | VDP_COLOR_BLACK
    .db     -0x04 - 0x01, -0x04 + ROUTE_OFFSET_X * 0x08 + 0x20, 0x08, 0x80 | VDP_COLOR_TRANSPARENT
    .db     -0x04 - 0x01, -0x04 + ROUTE_OFFSET_X * 0x08 + 0x20, 0x1c, 0x80 | VDP_COLOR_BLACK
    .db     -0x04 - 0x01, -0x04 + ROUTE_OFFSET_X * 0x08 + 0x20, 0x0c, 0x80 | VDP_COLOR_TRANSPARENT
    .db     -0x04 - 0x01, -0x04 + ROUTE_OFFSET_X * 0x08 + 0x20, 0x20, 0x80 | VDP_COLOR_BLACK
    .db     -0x04 - 0x01, -0x04 + ROUTE_OFFSET_X * 0x08 + 0x20, 0x0c, 0x80 | VDP_COLOR_TRANSPARENT
    .db     -0x04 - 0x01, -0x04 + ROUTE_OFFSET_X * 0x08 + 0x20, 0x20, 0x80 | VDP_COLOR_BLACK
    .db     -0x04 - 0x01, -0x04 + ROUTE_OFFSET_X * 0x08 + 0x20, 0x0c, 0x80 | VDP_COLOR_TRANSPARENT
    .db     -0x04 - 0x01, -0x04 + ROUTE_OFFSET_X * 0x08 + 0x20, 0x20, 0x80 | VDP_COLOR_BLACK
    .db     -0x04 - 0x01, -0x04 + ROUTE_OFFSET_X * 0x08 + 0x20, 0x10, 0x80 | VDP_COLOR_TRANSPARENT
    .db     -0x04 - 0x01, -0x04 + ROUTE_OFFSET_X * 0x08 + 0x20, 0x24, 0x80 | VDP_COLOR_BLACK
    .db     -0x04 - 0x01, -0x04 + ROUTE_OFFSET_X * 0x08 + 0x20, 0x10, 0x80 | VDP_COLOR_TRANSPARENT
    .db     -0x04 - 0x01, -0x04 + ROUTE_OFFSET_X * 0x08 + 0x20, 0x24, 0x80 | VDP_COLOR_BLACK
    .db     -0x04 - 0x01, -0x04 + ROUTE_OFFSET_X * 0x08 + 0x20, 0x14, 0x80 | VDP_COLOR_TRANSPARENT
    .db     -0x04 - 0x01, -0x04 + ROUTE_OFFSET_X * 0x08 + 0x20, 0x28, 0x80 | VDP_COLOR_BLACK

playerSpriteBomb:

    .db     -0x04 - 0x01, -0x04 + ROUTE_OFFSET_X * 0x08 + 0x20, 0x2c, 0x80 | VDP_COLOR_TRANSPARENT
    .db     -0x04 - 0x01, -0x04 + ROUTE_OFFSET_X * 0x08 + 0x20, 0x00, 0x80 | VDP_COLOR_TRANSPARENT


; DATA 領域
;
    .area   _DATA

; 変数の定義
;

; プレイヤ
;
_player::
    
    .ds     PLAYER_LENGTH

