; App.inc : アプリケーション
;


; マクロの定義
;

; ビデオ
APP_COLOR_TABLE                 =   0x3400
APP_PATTERN_NAME_TABLE          =   0x3000
APP_PATTERN_GENERATOR_TABLE     =   0x0000
APP_SPRITE_ATTRIBUTE_TABLE      =   0x3300
APP_SPRITE_GENERATOR_TABLE      =   0x3800

; アプリケーション
APP_STATE                       =   0x00
APP_FRAME                       =   0x01
APP_TIME_L                      =   0x02
APP_TIME_H                      =   0x03
APP_LENGTH                      =   0x04

; 状態
APP_STATE_NULL                  =   0x00
APP_STATE_TITLE_INITIALIZE      =   0x01
APP_STATE_TITLE_UPDATE          =   0x02
APP_STATE_GAME_INITIALIZE       =   0x03
APP_STATE_GAME_UPDATE           =   0x04

; フレーム
APP_FRAME_NULL                  =   0x00

; タイム
APP_TIME_NULL                   =   0x00

; 外部関数宣言
;

    .globl  _AppInitialize
    .globl  _AppUpdate
    .globl  _AppNull
    .globl  _AppSetTime
    .globl  _AppGetDecimal16
    .globl  _AppGetDecimal8

; 外部変数宣言
;

; 状態
    .globl  _app
    