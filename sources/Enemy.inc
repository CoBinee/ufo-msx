; Enemy.inc : エネミー
;


; マクロの定義
;

; エネミー
ENEMY_PROC_L                    =   0x00
ENEMY_PROC_H                    =   0x01
ENEMY_STATE                     =   0x02
ENEMY_FLAG                      =   0x03
ENEMY_POSITION_X                =   0x04
ENEMY_POSITION_Y                =   0x05
ENEMY_SPEED                     =   0x06
ENEMY_DIRECTION                 =   0x07
ENEMY_ANIMATION                 =   0x08
ENEMY_SPRITE_L                  =   0x09
ENEMY_SPRITE_H                  =   0x0a
ENEMY_COLOR                     =   0x0b
ENEMY_LENGTH                    =   0x0c

; 処理
ENEMY_PROC_NULL                 =   0x00

; 状態
ENEMY_STATE_NULL                =   0x00

; フラグ
ENEMY_FLAG_NULL                 =   0x00
ENEMY_FLAG_90_BIT               =   0x00
ENEMY_FLAG_90                   =   (1 << ENEMY_FLAG_90_BIT)
ENEMY_FLAG_45_BIT               =   0x01
ENEMY_FLAG_45                   =   (1 << ENEMY_FLAG_45_BIT)

; 位置
ENEMY_POSITION_NULL             =   0x00

; 速度
ENEMY_SPEED_NULL                =   0x00

; 向き
ENEMY_DIRECTION_NULL            =   0x00
ENEMY_DIRECTION_LEFT            =   0x00
ENEMY_DIRECTION_RIGHT           =   0x01

; アニメーション
ENEMY_ANIMATION_NULL            =   0x00

; スプライト
ENEMY_SPRITE_NULL               =   0x00

; 色
ENEMY_COLOR_NULL                =   VDP_COLOR_TRANSPARENT

; エントリ
ENEMY_ENTRY                     =   0x10

; 外部関数宣言
;

    .globl  _EnemyInitialize
    .globl  _EnemyUpdate
    .globl  _EnemyRender
    .globl  _EnemyBorn
    .globl  _EnemyKill

; 外部変数宣言
;

    .globl  _enemy
