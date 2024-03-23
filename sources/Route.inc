; Route.inc : 経路
;


; マクロの定義
;

; 経路
ROUTE_SIZE_X                    =   0x20
ROUTE_SIZE_Y                    =   0x20
ROUTE_VIEW_X                    =   0x18
ROUTE_VIEW_Y                    =   0x18
ROUTE_OFFSET_X                  =   0x00
ROUTE_OFFSET_Y                  =   0x00
ROUTE_WALL                      =   0x00
ROUTE_STRAIGHT                  =   0x08
ROUTE_DOWN_LEFT_0               =   0x10
ROUTE_DOWN_LEFT_1               =   0x18
ROUTE_DOWN_LEFT_2               =   0x20
ROUTE_DOWN_RIGHT_0              =   0x28
ROUTE_DOWN_RIGHT_1              =   0x30
ROUTE_DOWN_RIGHT_2              =   0x38
ROUTE_DOWN_WIDTH                =   0x03
ROUTE_UPPER                     =   0x80
ROUTE_LOWER                     =   0xc0
ROUTE_MASK                      =   0x38

; スクロール
ROUTE_SCROLL_RANGE              =   0x30

; 底
ROUTE_BOTTOM_RANGE              =   0x0d

; ゴール
ROUTE_GOAL_STATE                =   0x00
ROUTE_GOAL_POSITION_X           =   0x01
ROUTE_GOAL_POSITION_Y           =   0x02
ROUTE_GOAL_ANIMATION            =   0x03
ROUTE_GOAL_LENGTH               =   0x04

; 外部関数宣言
;

    .globl  _RouteInitialize
    .globl  _RouteUpdate
    .globl  _RouteRender
    .globl  _RouteTransfer
    .globl  _RouteIsWall
    .globl  _RouteIsDownLeft
    .globl  _RouteIsDownRight
    .globl  _RouteIsUp
    .globl  _RouteIsUpLeft
    .globl  _RouteIsUpRight
    .globl  _RouteGetScroll
    .globl  _RouteGetBottom

; 外部変数宣言
;

    .globl  _route
