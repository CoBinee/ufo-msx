; Game.inc : ゲーム
;


; マクロの定義
;

; スプライト
GAME_SPRITE_NULL                =   0x00
GAME_SPRITE_PLAYER_0            =   0x00
GAME_SPRITE_PLAYER_1            =   0x74
GAME_SPRITE_ENEMY               =   0x10
GAME_SPRITE_ITEM                =   0x78
GAME_SPRITE_GOAL                =   0x7c
GAME_SPRITE_PICTURE             =   0x00

; ゲーム
GAME_PROC_L                     =   0x00
GAME_PROC_H                     =   0x01
GAME_STATE                      =   0x02
GAME_FLAG                       =   0x03
GAME_FRAME                      =   0x04
GAME_COUNT                      =   0x05
GAME_TIME_L                     =   0x06
GAME_TIME_H                     =   0x07
GAME_FLOOR                      =   0x08
GAME_LENGTH                     =   0x09

; 処理
GAME_PROC_NULL                  =   0x00

; 状態
GAME_STATE_NULL                 =   0x00

; フラグ
GAME_FLAG_NULL                  =   0x00

; フレーム
GAME_FRAME_NULL                 =   0x00

; カウント
GAME_COUNT_NULL                 =   0x00

; タイム
GAME_TIME_NULL                  =   0x0000
GAME_TIME_MAXIMUM               =   3000

; フロア
GAME_FLOOR_NULL                 =   0x00
GAME_FLOOR_GOAL                 =   100

; 外部関数宣言
;

    .globl  _GameInitialize
    .globl  _GameUpdate
    .globl  _GameNextFloor
    .globl  _GameGetFloor
    .globl  _GameGetRandomColor
    
; 外部変数宣言
;

    .globl  _game
