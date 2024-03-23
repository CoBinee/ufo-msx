; Player.inc : プレイヤ
;


; マクロの定義
;

; プレイヤ
PLAYER_PROC_L                   =   0x00
PLAYER_PROC_H                   =   0x01
PLAYER_STATE                    =   0x02
PLAYER_FLAG                     =   0x03
PLAYER_POSITION_X_L             =   0x04
PLAYER_POSITION_X_H             =   0x05
PLAYER_POSITION_Y               =   0x06
PLAYER_SPEED                    =   0x07
PLAYER_SPEED_MAXIMUM            =   0x08
PLAYER_DIRECTION                =   0x09
PLAYER_NODAMAGE                 =   0x0a
PLAYER_BLINK                    =   0x0b
PLAYER_ANIMATION                =   0x0c
PLAYER_SPRITE_L                 =   0x0d
PLAYER_SPRITE_H                 =   0x0e
PLAYER_COLOR                    =   0x0f
PLAYER_LENGTH                   =   0x10

; 処理
PLAYER_PROC_NULL                =   0x00

; 状態
PLAYER_STATE_NULL               =   0x00

; フラグ
PLAYER_FLAG_NULL                =   0x00
PLAYER_FLAG_TURN_BIT            =   0x00
PLAYER_FLAG_TURN                =   (1 << PLAYER_FLAG_TURN_BIT)
PLAYER_FLAG_MISS_BIT            =   0x01
PLAYER_FLAG_MISS                =   (1 << PLAYER_FLAG_MISS_BIT)
PLAYER_FLAG_OVER_BIT            =   0x06
PLAYER_FLAG_OVER                =   (1 << PLAYER_FLAG_OVER_BIT)
PLAYER_FLAG_GOAL_BIT            =   0x07
PLAYER_FLAG_GOAL                =   (1 << PLAYER_FLAG_GOAL_BIT)

; 位置
PLAYER_POSITION_NULL            =   0x00

; 速度
PLAYER_SPEED_NULL               =   0x00
PLAYER_SPEED_ACCEL              =   0x02
PLAYER_SPEED_BRAKE              =   0x04
PLAYER_SPEED_NORMAL             =   (0x04 << 3)
PLAYER_SPEED_FAST               =   (0x08 << 3)

; 向き
PLAYER_DIRECTION_NULL           =   0x00
PLAYER_DIRECTION_LEFT           =   0x00
PLAYER_DIRECTION_CENTER         =   0x03
PLAYER_DIRECTION_RIGHT          =   0x08

; 無敵
PLAYER_NODAMAGE_NULL            =   0x00
PLAYER_NODAMAGE_FRAME           =   0xa0

; 点滅
PLAYER_BLINK_NULL               =   0x00
PLAYER_BLINK_START              =   0x18

; アニメーション
PLAYER_ANIMATION_NULL           =   0x00
PLAYER_ANIMATION_MISS           =   0x38

; スプライト
PLAYER_SPRITE_NULL              =   0x00

; 色
PLAYER_COLOR_NULL               =   VDP_COLOR_TRANSPARENT

; 外部関数宣言
;

    .globl  _PlayerInitialize
    .globl  _PlayerUpdate
    .globl  _PlayerRender
    .globl  _PlayerIsGoal
    .globl  _PlayerIsOver
    .globl  _PlayerGetPositionY
    .globl  _PlayerSetMiss
    .globl  _PlayerSetNoDamage

; 外部変数宣言
;

    .globl  _player
