; Game.s : ゲーム
;


; モジュール宣言
;
    .module Game

; 参照ファイル
;
    .include    "bios.inc"
    .include    "vdp.inc"
    .include    "System.inc"
    .include    "Sound.inc"
    .include    "App.inc"
    .include    "Picture.inc"
    .include	"Game.inc"
    .include    "Player.inc"
    .include    "Enemy.inc"
    .include    "Item.inc"
    .include    "Route.inc"

; 外部変数宣言
;
    .globl  _patternTable

; マクロの定義
;


; CODE 領域
;
    .area   _CODE

; ゲームを初期化する
;
_GameInitialize::
    
    ; レジスタの保存
    
    ; スプライトのクリア
    call    _SystemClearSprite
    
    ; パターンネームのクリア
    xor     a
    call    _SystemClearPatternName
    
    ; ゲームの初期化
    ld      hl, #gameDefault
    ld      de, #_game
    ld      bc, #GAME_LENGTH
    ldir

    ; プレイヤの初期化
    call    _PlayerInitialize

    ; エネミーの初期化
    call    _EnemyInitialize

    ; アイテムの初期化
    call    _ItemInitialize

    ; 経路の初期化
    call    _RouteInitialize

    ; 転送の設定
    ld      hl, #_SystemUpdatePatternName
    ld      (_transfer), hl

    ; 描画の開始
    ld      hl, #(_videoRegister + VDP_R1)
    set     #VDP_R1_BL, (hl)
    
    ; 処理の設定
    ld      hl, #GameStart
    ld      (_game + GAME_PROC_L), hl
    xor     a
    ld      (_game + GAME_STATE), a

    ; 状態の設定
    ld      a, #APP_STATE_GAME_UPDATE
    ld      (_app + APP_STATE), a
    
    ; レジスタの復帰
    
    ; 終了
    ret

; ゲームを更新する
;
_GameUpdate::
    
    ; レジスタの保存
    
    ; スプライトのクリア
    call    _SystemClearSprite

    ; 状態別の処理
    ld      hl, #10$
    push    hl
    ld      hl, (_game + GAME_PROC_L)
    jp      (hl)
;   pop     hl
10$:

    ; レジスタの復帰
    
    ; 終了
    ret

; 何もしない
;
GameNull:

    ; レジスタの保存

    ; レジスタの復帰

    ; 終了
    ret

; ゲームを待機する
;
GameIdle:

    ; レジスタの保存

    ; 初期化
    ld      a, (_game + GAME_STATE)
    or      a
    jr      nz, 09$

    ; 初期化の完了
    ld      hl, #(_game + GAME_STATE)
    inc     (hl)
09$:

    ; レジスタの復帰

    ; 終了
    ret

; ゲームを開始する
;
GameStart:

    ; レジスタの保存

    ; 初期化
    ld      a, (_game + GAME_STATE)
    or      a
    jr      nz, 09$

    ; フレームの設定
    ld      a, #0x20
    ld      (_game + GAME_FRAME), a

    ; 画面のクリア
    xor     a
    call    _SystemClearPatternName

    ; スペイザーの表示
    call    _PicturePrintSpazer

    ; ステータスの表示
    call    GamePrintStatus

    ; 転送の設定
    ld      hl, #_SystemUpdatePatternName
    ld      (_transfer), hl

    ; BGM の再生
    ld      a, #SOUND_BGM_START
    call    _SoundPlayBgm

    ; 初期化の完了
    ld      hl, #(_game + GAME_STATE)
    inc     (hl)
09$:

    ; フレームの更新
    ld      hl, #(_game + GAME_FRAME)
    dec     (hl)
    jr      nz, 19$

    ; 処理の設定
    ld      hl, #GamePlay
    ld      (_game + GAME_PROC_L), hl
    xor     a
    ld      (_game + GAME_STATE), a
19$:

    ; スペイザーのアニメーション
    ld      de, #(_sprite + GAME_SPRITE_PICTURE)
    ld      a, (_game + GAME_FRAME)
    call    _PictureAnimateSpazer

    ; レジスタの復帰

    ; 終了
    ret

; ゲームをプレイする
;
GamePlay:

    ; レジスタの保存

    ; 初期化
    ld      a, (_game + GAME_STATE)
    or      a
    jr      nz, 09$

    ; 転送の設定
    ld      hl, #GameTransfer
    ld      (_transfer), hl

    ; ビデオの設定
    ld      a, #((APP_PATTERN_GENERATOR_TABLE + 0x0000) >> 11)
    ld      (_videoRegister + VDP_R4), a
    ld      a, #((APP_COLOR_TABLE + 0x0000) >> 6)
    ld      (_videoRegister + VDP_R3), a

    ; 初期化の完了
    ld      hl, #(_game + GAME_STATE)
    inc     (hl)
09$:

    ; ヒット判定
    call    GameHit

    ; プレイヤの更新
    call    _PlayerUpdate

    ; エネミーの更新
    call    _EnemyUpdate

    ; アイテムの更新
    call    _ItemUpdate

    ; 経路の更新
    call    _RouteUpdate

    ; タイムの更新
    call    GamePassTime

    ; プレイヤの描画
    call    _PlayerRender

    ; エネミーの描画
    call    _EnemyRender

    ; アイテムの描画
    call    _ItemRender

    ; 経路の描画
    call    _RouteRender

    ; ステータスの表示
    call    GamePrintStatus

    ; ゴールの判定
    call    _PlayerIsGoal
    jr      nc, 90$
    ld      hl, #GameClear
    ld      (_game + GAME_PROC_L), hl
    xor     a
    ld      (_game + GAME_STATE), a
    jr      99$
90$:

    ; ゲームオーバーの判定
    call    _PlayerIsOver
    jr      nc, 91$
    ld      hl, #GameOver
    ld      (_game + GAME_PROC_L), hl
    xor     a
    ld      (_game + GAME_STATE), a
    jr      99$
91$:

    ; プレイの完了
99$:

    ; レジスタの復帰

    ; 終了
    ret

; ゲームオーバーになる
;
GameOver:

    ; レジスタの保存

    ; 初期化
    ld      a, (_game + GAME_STATE)
    or      a
    jr      nz, 09$

    ; フレームの設定
    ld      a, #0x18
    ld      (_game + GAME_FRAME), a

    ; 画面のクリア
    xor     a
    call    _SystemClearPatternName

    ; ゲームオーバーの表示
    call    GamePrintOver

    ; ステータスの表示
    call    GamePrintStatus

    ; 転送の設定
    ld      hl, #_SystemUpdatePatternName
    ld      (_transfer), hl

    ; 初期化の完了
    ld      hl, #(_game + GAME_STATE)
    inc     (hl)
09$:

    ; フレームの更新
    ld      hl, #(_game + GAME_FRAME)
    ld      a, (hl)
    or      a
    jr      z, 10$
    dec     (hl)
    jr      19$

    ; スペースキーの押下
10$:
    ld      a, (_input + INPUT_BUTTON_SPACE)
    dec     a
    jr      nz, 19$

;   ; SE の再生
;   ld      a, #SOUND_SE_CLICK
;   call    _SoundPlaySe

    ; 状態の更新
    ld      a, #APP_STATE_TITLE_INITIALIZE
    ld      (_app + APP_STATE), a
19$:

    ; レジスタの復帰

    ; 終了
    ret

; ゲームをクリアする
;
GameClear:

    ; レジスタの保存

    ; 初期化
    ld      a, (_game + GAME_STATE)
    or      a
    jr      nz, 09$

    ; フレームの設定
    xor     a
    ld      (_game + GAME_FRAME), a

    ; 画面のクリア
    xor     a
    call    _SystemClearPatternName

    ; ダイザーの表示
    call    _PicturePrintDizer

    ; ステータスの表示
    call    GamePrintStatus

    ; 転送の設定
    ld      hl, #_SystemUpdatePatternName
    ld      (_transfer), hl

    ; BGM の再生
    ld      a, #SOUND_BGM_CLEAR
    call    _SoundPlayBgm

    ; 初期化の完了
    ld      hl, #(_game + GAME_STATE)
    inc     (hl)
09$:

    ; フレームの更新
    ld      hl, #(_game + GAME_FRAME)
    inc     (hl)
    ld      a, (hl)
    cp      #0x30
    jr      c, 19$

    ; 処理の設定
    ld      hl, #GameResult
    ld      (_game + GAME_PROC_L), hl
    xor     a
    ld      (_game + GAME_STATE), a
19$:

    ; ダイザーのアニメーション
    ld      de, #(_sprite + GAME_SPRITE_PICTURE)
    ld      a, (_game + GAME_FRAME)
    call    _PictureAnimateDizer

    ; レジスタの復帰

    ; 終了
    ret

; ゲームの結果を表示する
;
GameResult:

    ; レジスタの保存

    ; 初期化
    ld      a, (_game + GAME_STATE)
    or      a
    jr      nz, 09$

    ; フレームの設定
    ld      a, #0x18
    ld      (_game + GAME_FRAME), a

    ; 画面のクリア
    xor     a
    call    _SystemClearPatternName

    ; タイムの更新
    ld      hl, (_game + GAME_TIME_L)
    call    _AppSetTime

    ; 結果の表示
    call    GamePrintResult

    ; ステータスの表示
    call    GamePrintStatus

    ; 転送の設定
    ld      hl, #_SystemUpdatePatternName
    ld      (_transfer), hl

    ; 初期化の完了
    ld      hl, #(_game + GAME_STATE)
    inc     (hl)
09$:

    ; フレームの更新
    ld      hl, #(_game + GAME_FRAME)
    ld      a, (hl)
    or      a
    jr      z, 10$
    dec     (hl)
    jr      19$

    ; スペースキーの押下
10$:
    ld      a, (_input + INPUT_BUTTON_SPACE)
    dec     a
    jr      nz, 19$

;   ; SE の再生
;   ld      a, #SOUND_SE_CLICK
;   call    _SoundPlaySe

    ; 状態の更新
    ld      a, #APP_STATE_TITLE_INITIALIZE
    ld      (_app + APP_STATE), a
19$:

    ; レジスタの復帰

    ; 終了
    ret

; VRAM へ転送する
;
GameTransfer:

    ; レジスタの保存

    ; d < ポート #0
    ; e < ポート #1

    ; 経路の転送
    call    _RouteTransfer

    ; デバッグの転送
    ld      hl, #0x02e0
    ld      b, #0x20
    call    GameTransferPatternName

    ; レジスタの復帰

    ; 終了
    ret

GameTransferPatternName:

    ; レジスタの保存
    push    de

    ; d  < ポート #0
    ; e  < ポート #1
    ; hl < 相対アドレス
    ; b  < 転送バイト数

    ; パターンネームテーブルの取得    
    ld      a, (_videoRegister + VDP_R2)
    add     a, a
    add     a, a
    add     a, h

    ; VRAM アドレスの設定
    ld      c, e
    out     (c), l
    or      #0b01000000
    out     (c), a

    ; パターンネームテーブルの転送
    ld      c, d
    ld      de, #_patternName
    add     hl, de
10$:
    outi
    jp      nz, 10$

    ; レジスタの復帰
    pop     de

    ; 終了
    ret

; ヒットチェックを行う
;
GameHit:

    ; レジスタの保存

    ; 判定の可否
    ld      a, (_player + PLAYER_FLAG)
    bit     #PLAYER_FLAG_MISS_BIT, a
    jr      nz, 90$

    ; プレイヤの位置の取得
    ld      a, (_player + PLAYER_POSITION_Y)
    ld      h, a
    ld      a, (_player + PLAYER_POSITION_X_H)
    ld      l, a

    ;  無敵の取得
    ld      a, (_player + PLAYER_NODAMAGE)
    ld      c, a

    ; プレイヤとエネミーの判定
    ld      a, (_player + PLAYER_DIRECTION)
    or      a
    jr      z, 10$
    cp      #PLAYER_DIRECTION_RIGHT
    jr      z, 10$
    jr      19$
10$:

    ; エネミーとの判定
    ld      ix, #_enemy
    ld      de, #ENEMY_LENGTH
    ld      b, #ENEMY_ENTRY
11$:
    ld      a, ENEMY_PROC_L(ix)
    or      ENEMY_PROC_H(ix)
    jr      z, 18$
    ld      a, ENEMY_POSITION_Y(ix)
    sub     h
    jp      p, 12$
    neg
12$:
    cp      #0x04
    jr      nc, 18$
    ld      a, ENEMY_POSITION_X(ix)
    sub     l
    jp      p, 13$
    neg
13$:
    cp      #0x04
    jr      nc, 18$
    ld      a, c
    or      a
    jr      nz, 14$
    call    _PlayerSetMiss
    jr      90$
14$:
    call    _EnemyKill
;   jr      18$
18$:
    add     ix, de
    djnz    11$

    ; エネミーとの判定の完了
19$:

    ; プレイヤとアイテムの判定
    ld      de, (_item + ITEM_POSITION_X)
    ld      a, d
    sub     h
    jp      p, 20$
    neg
20$:
    cp      #0x06
    jr      nc, 29$
    ld      a, e
    sub     l
    jp      p, 21$
    neg
21$:
    cp      #0x06
    jr      nc, 29$
    call    _PlayerSetNoDamage
    call    _ItemKill
;   jr      29$
29$:

    ; プレイヤの判定の完了
90$:

    ; レジスタの復帰

    ; 終了
    ret

; タイムを更新する
;
GamePassTime:

    ; レジスタの保存

    ; 時間の経過
    ld      a, (_game + GAME_FLOOR)
    or      a
    jr      z, 19$
    ld      hl, (_game + GAME_TIME_L)
    ld      a, h
    or      l
    jr      z, 19$
    dec     hl
    ld      (_game + GAME_TIME_L), hl
    ld      a, h
    or      l
    jr      nz, 19$
    call    _PlayerSetMiss
19$:

    ; レジスタの復帰

    ; 終了
    ret

; 次のフロアへ行く
;
_GameNextFloor::

    ; レジスタの保存

    ; フロアの更新
    ld      hl, #(_game + GAME_FLOOR)
    ld      a, (hl)
    cp      #GAME_FLOOR_GOAL
    jr      nc, 19$
    inc     (hl)

    ; エネミーの生成
;   ld      hl, #(_game + GAME_FLOOR)
    ld      e, (hl)
    ld      d, #0x00
    ld      hl, #gameBornEnemy
    add     hl, de
    ld      a, (hl)
    or      a
    call    nz, _EnemyBorn

    ; アイテムの生成
    ld      a, (_game + GAME_FLOOR)
    and     #0x0f
    call    z, _ItemBorn

    ; 更新の完了
19$:

    ; レジスタの復帰

    ; 終了
    ret

; 現在のフロアを取得する
;
_GameGetFloor::

    ; レジスタの保存

    ; a > フロア

    ; フロアの取得
    ld      a, (_game + GAME_FLOOR)

    ; レジスタの復帰

    ; 終了
    ret

; ランダムな色を取得する
;
_GameGetRandomColor::

    ; レジスタの保存
    push    hl
    push    de

    ; a > 色

    ; 色の取得
    call    _SystemGetRandom
    and     #0x07
    ld      e, a
    ld      d, #0x00
    ld      hl, #gameColor
    add     hl, de
    ld      a, (hl)

    ; レジスタの復帰
    pop     de
    pop     hl

    ; 終了
    ret

; ステータスを表示する
;
GamePrintStatus:

    ; レジスタの保存

    ; タイムの表示
    ld      hl, #gameTimeString
    ld      de, #(_patternName + 0x0039)
    call    GamePrintString
    ld      hl, (_game + GAME_TIME_L)
    ld      de, #(_patternName + 0x005a)
    ld      b, #0x05
    call    GamePrintValue16

    ; ベストの表示
    ld      hl, #gameBestString
    ld      de, #(_patternName + 0x0099)
    call    GamePrintString
    ld      hl, (_app + APP_TIME_L)
    ld      de, #(_patternName + 0x00ba)
    ld      b, #0x05
    call    GamePrintValue16

    ; フロアの表示
    ld      hl, #gameFloorString
    ld      de, #(_patternName + 0x02b9)
    call    GamePrintString
    ld      a, (_game + GAME_FLOOR)
    sub     #GAME_FLOOR_GOAL
    neg
    ld      de, #(_patternName + 0x02dc)
    ld      b, #0x03
    call    GamePrintValue8

    ; レジスタの復帰

    ; 終了
    ret

; ゲームオーバーを表示する
;
GamePrintOver:

    ; レジスタの保存

    ; 文字列の表示
    ld      hl, #gameOverString
    ld      de, #(_patternName + 0x0167)
    call    GamePrintString

    ; レジスタの復帰

    ; 終了
    ret

; 結果を表示する
;
GamePrintResult:

    ; レジスタの保存

    ; cf < 1 = タイム更新

    ; メッセージの表示
    ld      hl, #gameResultNormalString
    jr      nc, 10$
    ld      hl, #gameResultBestString
10$:
    ld      de, #(_patternName + 0x0106)
    call    GamePrintString

    ; タイムの表示
    ld      hl, #gameResultTimeString
    ld      de, #(_patternName + 0x01c9)
    call    GamePrintString
    ld      hl, (_game + GAME_TIME_L)
    ld      de, #(_patternName + 0x020a)
    ld      b, #0x05
    call    GamePrintValue16

    ; レジスタの復帰

    ; 終了
    ret

; 数値を表示する
;
GamePrintValue16:

    ; レジスタの保存

    ; hl < 数値
    ; de < パターンネーム
    ; b  < 桁数

    ; 数値の表示
    call    _AppGetDecimal16
    ex      de, hl
    dec     b
    jr      z, 11$
10$:
    ld      a, (hl)
    or      a
    jr      nz, 11$
    inc     hl
    djnz    10$
11$:
    inc     b
12$:
    ld      a, (hl)
    add     a, #0x10
    ld      (hl), a
    inc     hl
    djnz    12$

    ; レジスタの復帰

    ; 終了
    ret

GamePrintValue8:

    ; レジスタの保存

    ; a  < 数値
    ; de < パターンネーム
    ; b  < 桁数

    ; 数値の表示
    call    _AppGetDecimal8
    ex      de, hl
    dec     b
    jr      z, 11$
10$:
    ld      a, (hl)
    or      a
    jr      nz, 11$
    inc     hl
    djnz    10$
11$:
    inc     b
12$:
    ld      a, (hl)
    add     a, #0x10
    ld      (hl), a
    inc     hl
    djnz    12$

    ; レジスタの復帰

    ; 終了
    ret

; 文字列を表示する
;
GamePrintString:

    ; レジスタの保存

    ; hl < 文字列
    ; de < パターンネーム

    ; 文字列の表示
10$:
    ld      a, (hl)
    or      a
    jr      z, 19$
    sub     #0x20
    ld      (de), a
    inc     hl
    inc     de
    jr      10$
19$:

    ; レジスタの復帰

    ; 終了
    ret

; 定数の定義
;

; ゲームの初期値
;
gameDefault:

    .dw     GAME_PROC_NULL
    .db     GAME_STATE_NULL
    .db     GAME_FLAG_NULL
    .db     GAME_FRAME_NULL
    .db     GAME_COUNT_NULL
    .dw     GAME_TIME_MAXIMUM ; GAME_TIME_NULL
    .db     GAME_FLOOR_NULL

; エネミーの生成数
;
gameBornEnemy:

    .db     0x00
    .db     0x00, 0x01, 0x00, 0x01, 0x00, 0x01, 0x00, 0x01, 0x00, 0x01
    .db     0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01
    .db     0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01
    .db     0x02, 0x01, 0x02, 0x01, 0x02, 0x01, 0x02, 0x01, 0x02, 0x01
    .db     0x02, 0x01, 0x02, 0x01, 0x02, 0x01, 0x02, 0x01, 0x02, 0x01
    .db     0x02, 0x02, 0x02, 0x02, 0x02, 0x02, 0x02, 0x02, 0x02, 0x02
    .db     0x02, 0x02, 0x02, 0x02, 0x02, 0x02, 0x02, 0x02, 0x02, 0x02
    .db     0x03, 0x02, 0x03, 0x02, 0x03, 0x02, 0x03, 0x02, 0x03, 0x02
    .db     0x03, 0x02, 0x03, 0x02, 0x03, 0x02, 0x03, 0x02, 0x03, 0x02
    .db     0x03, 0x03, 0x03, 0x03, 0x03, 0x03, 0x03, 0x03, 0x03, 0x03

; タイム
;
gameTimeString:

    .ascii  "TIME"
    .db     0x00

; ベスト
;
gameBestString:

    .ascii  "BEST"
    .db     0x00

; フロア
;
gameFloorString:

    .ascii  "DIZER"
    .db     0x00

; ゲームオーバー
;
gameOverString:

    .ascii  "NOT SHOOT IN"
    .db     0x00
    
; 結果
;
gameResultNormalString:

    .ascii  "NICE SHOOT IN"
    .db     0x00

gameResultBestString:

    .ascii  "BEST SHOOT IN"
    .db     0x00

gameResultTimeString:

    .ascii  "TIME"
    .db     0x00

; 色
;
gameColor:

    .db     VDP_COLOR_MAGENTA
    .db     VDP_COLOR_LIGHT_GREEN
    .db     VDP_COLOR_LIGHT_BLUE
    .db     VDP_COLOR_LIGHT_YELLOW
    .db     VDP_COLOR_CYAN
    .db     VDP_COLOR_MEDIUM_GREEN
    .db     VDP_COLOR_DARK_BLUE
    .db     VDP_COLOR_DARK_YELLOW


; DATA 領域
;
    .area   _DATA

; 変数の定義
;

; ゲーム
;
_game::

    .ds     GAME_LENGTH

