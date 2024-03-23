; Picture.s : 絵
;


; モジュール宣言
;
    .module Sound

; 参照ファイル
;
    .include    "bios.inc"
    .include    "vdp.inc"
    .include    "System.inc"
    .include    "App.inc"
    .include	"Picture.inc"

; 外部変数宣言
;

; マクロの定義
;

; カラーテーブルを転送する
;
_PictureTransferColorTable::

    ; レジスタの保存

    ; スペイザーの転送
    ld      hl, #pictureSpazerColorTable
    ld      de, #(APP_COLOR_TABLE + 0x0040)
    ld      bc, #0x0020
    call    LDIRVM

    ; ダイザーの転送
    ld      hl, #pictureDizerColorTable
    ld      de, #(APP_COLOR_TABLE + 0x0080)
    ld      bc, #0x0020
    call    LDIRVM

    ; デュークの転送
    ld      hl, #pictureDukeColorTable
    ld      de, #(APP_COLOR_TABLE + 0x00c0)
    ld      bc, #0x0020
    call    LDIRVM

    ; レジスタの復帰

    ; 終了

; スペイザーを表示する
;
_PicturePrintSpazer::

    ; レジスタの保存

    ; パターンネームの表示
    ld      hl, #pictureSpazerPatternName
    ld      de, #(_patternName + 0x0000)
    ld      a, #0x08
10$:
    ld      bc, #0x0018
    ldir
    ex      de, hl
    ld      bc, #0x0008
    add     hl, bc
    ex      de, hl
    dec     a
    jr      nz, 10$

    ; ビデオの設定
    ld      a, #((APP_PATTERN_GENERATOR_TABLE + 0x0800) >> 11)
    ld      (_videoRegister + VDP_R4), a
    ld      a, #((APP_COLOR_TABLE + 0x0040) >> 6)
    ld      (_videoRegister + VDP_R3), a

    ; レジスタの復帰

    ; 終了
    ret

; スペイザーをアニメーションさせる
;
_PictureAnimateSpazer::

    ; レジスタの保存

    ; de < スプライト
    ; a  < フレーム

    ; スプライトの表示
    cp      #0x10
    jr      c, 10$
    ld      a, #(0x02 * 0x18)
    jr      11$
10$:
    sub     #0x04
    jr      c, 19$
    and     #0xfc
    add     a, a
    ld      c, a
    add     a, a
    add     a, c
11$:
    ld      c, a
    ld      b, #0x00
    ld      hl, #pictureSpazerSprite
    add     hl, bc
    ld      bc, #(0x06 * 0x04)
    ldir
19$:

    ; レジスタの復帰

    ; 終了
    ret

; ダイザーを表示する
;
_PicturePrintDizer::

    ; レジスタの保存

    ; パターンネームの表示
    ld      hl, #pictureDizerPatternName
    ld      de, #(_patternName + 0x0200)
    ld      a, #0x08
10$:
    ld      bc, #0x0018
    ldir
    ex      de, hl
    ld      bc, #0x0008
    add     hl, bc
    ex      de, hl
    dec     a
    jr      nz, 10$

    ; ビデオの設定
    ld      a, #((APP_PATTERN_GENERATOR_TABLE + 0x1000) >> 11)
    ld      (_videoRegister + VDP_R4), a
    ld      a, #((APP_COLOR_TABLE + 0x0080) >> 6)
    ld      (_videoRegister + VDP_R3), a

    ; レジスタの復帰

    ; 終了
    ret

; ダイザーをアニメーションさせる
;
_PictureAnimateDizer::

    ; レジスタの保存

    ; de < スプライト
    ; a  < フレーム

    ; スプライトの表示
    sub     #0x04
    jr      c, 19$
    cp      #0x0c
    jr      c, 10$
    ld      a, #(0x02 * 0x28)
    jr      11$
10$:
    and     #0xfc
    add     a, a
    ld      c, a
    add     a, a
    add     a, a
    add     a, c
11$:
    ld      c, a
    ld      b, #0x00
    ld      hl, #pictureDizerSprite
    add     hl, bc
    ld      bc, #(0x0a * 0x04)
    ldir
19$:

    ; レジスタの復帰

    ; 終了
    ret

; デュークを表示する
;
_PicturePrintDuke::

    ; レジスタの保存

    ; パターンネームの表示
    ld      hl, #(_patternName + 0x0100)
    ld      de, #(_patternName + 0x0101)
    ld      bc, #0x00ff
    ld      (hl), #0x5f
    ldir
    ld      hl, #(_patternName + 0x0229)
    ld      a, #0x02
    ld      b, #0x0e
10$:
    ld      (hl), a
    inc     a
    inc     hl
    djnz    10$

    ; ビデオの設定
    ld      a, #((APP_PATTERN_GENERATOR_TABLE + 0x1800) >> 11)
    ld      (_videoRegister + VDP_R4), a
    ld      a, #((APP_COLOR_TABLE + 0x00c0) >> 6)
    ld      (_videoRegister + VDP_R3), a

    ; レジスタの復帰

    ; 終了
    ret

; デュークをアニメーションさせる
;
_PictureAnimateDuke::

    ; レジスタの保存

    ; de < スプライト
    ; a  < フレーム

    ; パターンネームの表示
    push    de
    and     #0xfc
    add     a, a
    add     a, a
    add     a, a
    add     a, #0x40
    ld      hl, #(_patternName + 0x010e)
    ld      de, #0x001c
    ld      c, #0x08
10$:
    ld      b, #0x04
11$:
    ld      (hl), a
    inc     a
    inc     hl
    djnz    11$
    add     hl, de
    dec     c
    jr      nz, 10$
    pop     de

    ; スプライトの表示
    ld      hl, #pictureDukeSprite
    ld      bc, #(0x0003 * 0x0004)
    ldir

    ; レジスタの復帰

    ; 終了
    ret

; CODE 領域
;
    .area   _CODE

; 定数の定義
;

; スペイザー
;
pictureSpazerPatternName:

    .db     0x40, 0x40, 0x40, 0x40, 0x40, 0x40, 0x40, 0x41, 0x42, 0x43, 0x44, 0x61, 0x62, 0x45, 0x46, 0x47, 0x48, 0x40, 0x40, 0x40, 0x40, 0x40, 0x40, 0x40
    .db     0x40, 0x40, 0x40, 0x40, 0x49, 0x4a, 0x4b, 0x60, 0x60, 0x60, 0x62, 0x60, 0x60, 0x61, 0x60, 0x60, 0x60, 0x4c, 0x4d, 0x4e, 0x40, 0x40, 0x40, 0x40
    .db     0x40, 0x4f, 0x50, 0x51, 0x60, 0x63, 0x64, 0x65, 0x66, 0x67, 0x68, 0x91, 0x92, 0x69, 0x6a, 0x6b, 0x6c, 0x6d, 0x6e, 0x60, 0x52, 0x53, 0x54, 0x40    
    .db     0x55, 0x56, 0x6f, 0x60, 0x60, 0x60, 0x60, 0x60, 0x60, 0x70, 0x71, 0x90, 0x90, 0x72, 0x73, 0x60, 0x60, 0x60, 0x60, 0x60, 0x60, 0x74, 0x57, 0x58
    .db     0x60, 0x75, 0x76, 0x77, 0x60, 0x78, 0x79, 0x7a, 0x60, 0x60, 0x7b, 0x98, 0x99, 0x7c, 0x60, 0x60, 0x7d, 0x7e, 0x7f, 0x60, 0x80, 0x81, 0x82, 0x60
    .db     0xa0, 0xa1, 0xa2, 0xa3, 0x60, 0x83, 0x84, 0x85, 0x60, 0x86, 0x87, 0x9a, 0x9b, 0x88, 0x89, 0x60, 0x8a, 0x8b, 0x8c, 0x60, 0xa4, 0xa5, 0xa6, 0xa7
    .db     0xb0, 0xb0, 0xb0, 0xb0, 0xb0, 0xa8, 0xa9, 0xb1, 0xb2, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0xb3, 0xb4, 0xaa, 0xab, 0xb0, 0xb0, 0xb0, 0xb0, 0xb0
    .db     0xb0, 0xb0, 0xb0, 0xb0, 0xb0, 0xb0, 0xb0, 0xb0, 0xb0, 0xb5, 0x00, 0x00, 0x00, 0x00, 0xb6, 0xb0, 0xb0, 0xb0, 0xb0, 0xb0, 0xb0, 0xb0, 0xb0, 0xb0

pictureSpazerColorTable:

    .db     (VDP_COLOR_WHITE        << 4) | VDP_COLOR_BLACK,       (VDP_COLOR_WHITE        << 4) | VDP_COLOR_BLACK
    .db     (VDP_COLOR_WHITE        << 4) | VDP_COLOR_BLACK,       (VDP_COLOR_WHITE        << 4) | VDP_COLOR_BLACK
    .db     (VDP_COLOR_WHITE        << 4) | VDP_COLOR_BLACK,       (VDP_COLOR_WHITE        << 4) | VDP_COLOR_BLACK
    .db     (VDP_COLOR_WHITE        << 4) | VDP_COLOR_BLACK,       (VDP_COLOR_WHITE        << 4) | VDP_COLOR_BLACK
    .db     (VDP_COLOR_MEDIUM_RED   << 4) | VDP_COLOR_LIGHT_BLUE,  (VDP_COLOR_MEDIUM_RED   << 4) | VDP_COLOR_LIGHT_BLUE
    .db     (VDP_COLOR_MEDIUM_RED   << 4) | VDP_COLOR_LIGHT_BLUE,  (VDP_COLOR_MEDIUM_RED   << 4) | VDP_COLOR_LIGHT_BLUE
    .db     (VDP_COLOR_MEDIUM_RED   << 4) | VDP_COLOR_BLACK,       (VDP_COLOR_MEDIUM_RED   << 4) | VDP_COLOR_BLACK
    .db     (VDP_COLOR_MEDIUM_RED   << 4) | VDP_COLOR_BLACK,       (VDP_COLOR_MEDIUM_RED   << 4) | VDP_COLOR_BLACK
    .db     (VDP_COLOR_MEDIUM_RED   << 4) | VDP_COLOR_BLACK,       (VDP_COLOR_MEDIUM_RED   << 4) | VDP_COLOR_BLACK
    .db     (VDP_COLOR_CYAN         << 4) | VDP_COLOR_MEDIUM_RED,  (VDP_COLOR_CYAN         << 4) | VDP_COLOR_BLACK
    .db     (VDP_COLOR_WHITE        << 4) | VDP_COLOR_MEDIUM_RED,  (VDP_COLOR_WHITE        << 4) | VDP_COLOR_MEDIUM_RED
    .db     (VDP_COLOR_WHITE        << 4) | VDP_COLOR_BLACK,       (VDP_COLOR_WHITE        << 4) | VDP_COLOR_BLACK
    .db     (VDP_COLOR_WHITE        << 4) | VDP_COLOR_BLACK,       (VDP_COLOR_WHITE        << 4) | VDP_COLOR_BLACK
    .db     (VDP_COLOR_WHITE        << 4) | VDP_COLOR_BLACK,       (VDP_COLOR_WHITE        << 4) | VDP_COLOR_BLACK
    .db     (VDP_COLOR_WHITE        << 4) | VDP_COLOR_BLACK,       (VDP_COLOR_WHITE        << 4) | VDP_COLOR_BLACK
    .db     (VDP_COLOR_WHITE        << 4) | VDP_COLOR_BLACK,       (VDP_COLOR_WHITE        << 4) | VDP_COLOR_BLACK

pictureSpazerSprite:

    .db     0x1b - 0x01, 0x58, 0xa4, VDP_COLOR_BLACK
    .db     0x1b - 0x01, 0x58, 0xa8, VDP_COLOR_WHITE
    .db     0x1b - 0x01, 0x58, 0xac, VDP_COLOR_LIGHT_RED
    .db     0xcc - 0x01, 0xcc, 0x00, VDP_COLOR_TRANSPARENT
    .db     0xcc - 0x01, 0xcc, 0x00, VDP_COLOR_TRANSPARENT
    .db     0xcc - 0x01, 0xcc, 0x00, VDP_COLOR_TRANSPARENT
    .db     0x1b - 0x01, 0x58, 0x98, VDP_COLOR_BLACK
    .db     0x1b - 0x01, 0x58, 0x9c, VDP_COLOR_WHITE
    .db     0x1b - 0x01, 0x58, 0xa0, VDP_COLOR_LIGHT_RED
    .db     0xcc - 0x01, 0xcc, 0x00, VDP_COLOR_TRANSPARENT
    .db     0xcc - 0x01, 0xcc, 0x00, VDP_COLOR_TRANSPARENT
    .db     0xcc - 0x01, 0xcc, 0x00, VDP_COLOR_TRANSPARENT
    .db     0x18 - 0x01, 0x58, 0x80, VDP_COLOR_BLACK
    .db     0x18 - 0x01, 0x58, 0x84, VDP_COLOR_WHITE
    .db     0x18 - 0x01, 0x58, 0x88, VDP_COLOR_LIGHT_RED
    .db     0x28 - 0x01, 0x58, 0x8c, VDP_COLOR_BLACK
    .db     0x28 - 0x01, 0x58, 0x90, VDP_COLOR_WHITE
    .db     0x28 - 0x01, 0x58, 0x94, VDP_COLOR_LIGHT_RED

; ダイザー
;
pictureDizerPatternName:

    .db     0x40, 0x40, 0x40, 0x41, 0x00, 0x42, 0x43, 0x44, 0x45, 0x46, 0x70, 0x71, 0x72, 0x73, 0x47, 0x48, 0x49, 0x4a, 0x4b, 0x00, 0x4c, 0x40, 0x40, 0x40
    .db     0x40, 0x40, 0x40, 0x4d, 0x00, 0x4e, 0x4f, 0x60, 0x40, 0x61, 0x50, 0x00, 0x00, 0x51, 0x62, 0x40, 0x63, 0x52, 0x53, 0x00, 0x54, 0x40, 0x40, 0x40
    .db     0x68, 0x69, 0x55, 0x56, 0x00, 0x00, 0x00, 0x79, 0x64, 0x78, 0x00, 0x00, 0x00, 0x00, 0x78, 0x65, 0x7a, 0x00, 0x00, 0x00, 0x57, 0x58, 0x6a, 0x6b
    .db     0x88, 0x88, 0x89, 0x00, 0x00, 0x00, 0x00, 0x7b, 0x78, 0x78, 0x91, 0x92, 0x93, 0x94, 0x78, 0x78, 0x7c, 0x00, 0x00, 0x00, 0x00, 0x8a, 0x88, 0x88
    .db     0x88, 0x88, 0x8b, 0x00, 0x00, 0x00, 0x00, 0x7d, 0x80, 0x81, 0x90, 0x90, 0x90, 0x90, 0x82, 0x83, 0x7e, 0x00, 0x00, 0x00, 0x00, 0x8c, 0x88, 0x88 
    .db     0xa0, 0xa1, 0xa2, 0x00, 0x00, 0x00, 0x00, 0x95, 0x90, 0x90, 0x90, 0x90, 0x90, 0x90, 0x90, 0x90, 0x96, 0x00, 0x00, 0x00, 0x00, 0xa3, 0xa4, 0xa0
    .db     0xa0, 0xa0, 0xa5, 0x00, 0x00, 0x00, 0x00, 0x97, 0xb8, 0xb9, 0xba, 0xb1, 0xb2, 0xbb, 0xbc, 0xbd, 0x98, 0x00, 0x00, 0x00, 0x00, 0xa6, 0xa0, 0xa0
    .db     0xa0, 0xa0, 0xa7, 0x00, 0x00, 0x00, 0x00, 0xb3, 0xb0, 0xb0, 0xb0, 0xb4, 0xb5, 0xb0, 0xb0, 0xb0, 0xb6, 0x00, 0x00, 0x00, 0x00, 0xa8, 0xa0, 0xa0

pictureDizerColorTable:

    .db     (VDP_COLOR_WHITE        << 4) | VDP_COLOR_BLACK,       (VDP_COLOR_WHITE        << 4) | VDP_COLOR_BLACK
    .db     (VDP_COLOR_WHITE        << 4) | VDP_COLOR_BLACK,       (VDP_COLOR_WHITE        << 4) | VDP_COLOR_BLACK
    .db     (VDP_COLOR_WHITE        << 4) | VDP_COLOR_BLACK,       (VDP_COLOR_WHITE        << 4) | VDP_COLOR_BLACK
    .db     (VDP_COLOR_WHITE        << 4) | VDP_COLOR_BLACK,       (VDP_COLOR_WHITE        << 4) | VDP_COLOR_BLACK
    .db     (VDP_COLOR_LIGHT_YELLOW << 4) | VDP_COLOR_BLACK,       (VDP_COLOR_LIGHT_YELLOW << 4) | VDP_COLOR_BLACK
    .db     (VDP_COLOR_LIGHT_YELLOW << 4) | VDP_COLOR_BLACK,       (VDP_COLOR_LIGHT_YELLOW << 4) | VDP_COLOR_BLACK
    .db     (VDP_COLOR_LIGHT_YELLOW << 4) | VDP_COLOR_DARK_BLUE,   (VDP_COLOR_LIGHT_YELLOW << 4) | VDP_COLOR_DARK_YELLOW
    .db     (VDP_COLOR_WHITE        << 4) | VDP_COLOR_BLACK,       (VDP_COLOR_DARK_BLUE    << 4) | VDP_COLOR_BLACK
    .db     (VDP_COLOR_CYAN         << 4) | VDP_COLOR_DARK_BLUE,   (VDP_COLOR_DARK_YELLOW  << 4) | VDP_COLOR_BLACK
    .db     (VDP_COLOR_CYAN         << 4) | VDP_COLOR_BLACK,       (VDP_COLOR_CYAN         << 4) | VDP_COLOR_BLACK
    .db     (VDP_COLOR_MEDIUM_RED   << 4) | VDP_COLOR_BLACK,       (VDP_COLOR_MEDIUM_RED   << 4) | VDP_COLOR_BLACK
    .db     (VDP_COLOR_GRAY         << 4) | VDP_COLOR_BLACK,       (VDP_COLOR_GRAY         << 4) | VDP_COLOR_CYAN
    .db     (VDP_COLOR_WHITE        << 4) | VDP_COLOR_BLACK,       (VDP_COLOR_WHITE        << 4) | VDP_COLOR_BLACK
    .db     (VDP_COLOR_WHITE        << 4) | VDP_COLOR_BLACK,       (VDP_COLOR_WHITE        << 4) | VDP_COLOR_BLACK
    .db     (VDP_COLOR_WHITE        << 4) | VDP_COLOR_BLACK,       (VDP_COLOR_WHITE        << 4) | VDP_COLOR_BLACK
    .db     (VDP_COLOR_WHITE        << 4) | VDP_COLOR_BLACK,       (VDP_COLOR_WHITE        << 4) | VDP_COLOR_BLACK

pictureDizerSprite:

    .db     0xaa - 0x01, 0x58, 0xb0, VDP_COLOR_BLACK
    .db     0x9a - 0x01, 0x58, 0xb4, VDP_COLOR_WHITE
    .db     0xaa - 0x01, 0x58, 0xb8, VDP_COLOR_WHITE
    .db     0x9a - 0x01, 0x58, 0xbc, VDP_COLOR_LIGHT_RED
    .db     0xaa - 0x01, 0x50, 0xc0, VDP_COLOR_LIGHT_RED
    .db     0xaa - 0x01, 0x60, 0xc4, VDP_COLOR_LIGHT_RED
    .db     0xb0 - 0x01, 0x00, 0x00, VDP_COLOR_TRANSPARENT
    .db     0xb0 - 0x01, 0x00, 0x00, VDP_COLOR_TRANSPARENT
    .db     0xb0 - 0x01, 0x00, 0x00, VDP_COLOR_TRANSPARENT
    .db     0xb0 - 0x01, 0x00, 0x00, VDP_COLOR_TRANSPARENT
    .db     0xa5 - 0x01, 0x58, 0xb0, VDP_COLOR_BLACK
    .db     0x95 - 0x01, 0x58, 0xb4, VDP_COLOR_WHITE
    .db     0xa5 - 0x01, 0x58, 0xb8, VDP_COLOR_WHITE
    .db     0x95 - 0x01, 0x58, 0xbc, VDP_COLOR_LIGHT_RED
    .db     0xa5 - 0x01, 0x50, 0xc0, VDP_COLOR_LIGHT_RED
    .db     0xa5 - 0x01, 0x60, 0xc4, VDP_COLOR_LIGHT_RED
    .db     0xb0 - 0x01, 0x00, 0x00, VDP_COLOR_TRANSPARENT
    .db     0xb0 - 0x01, 0x00, 0x00, VDP_COLOR_TRANSPARENT
    .db     0xb0 - 0x01, 0x00, 0x00, VDP_COLOR_TRANSPARENT
    .db     0xb0 - 0x01, 0x00, 0x00, VDP_COLOR_TRANSPARENT
    .db     0xa0 - 0x01, 0x58, 0xb0, VDP_COLOR_BLACK
    .db     0x90 - 0x01, 0x58, 0xb4, VDP_COLOR_WHITE
    .db     0xa0 - 0x01, 0x58, 0xb8, VDP_COLOR_WHITE
    .db     0x90 - 0x01, 0x58, 0xbc, VDP_COLOR_LIGHT_RED
    .db     0xa0 - 0x01, 0x50, 0xc0, VDP_COLOR_LIGHT_RED
    .db     0xa0 - 0x01, 0x60, 0xc4, VDP_COLOR_LIGHT_RED
    .db     0xb0 - 0x01, 0x00, 0x00, VDP_COLOR_TRANSPARENT
    .db     0xb0 - 0x01, 0x00, 0x00, VDP_COLOR_TRANSPARENT
    .db     0xb0 - 0x01, 0x00, 0x00, VDP_COLOR_TRANSPARENT
    .db     0xb0 - 0x01, 0x00, 0x00, VDP_COLOR_TRANSPARENT

; デューク
;

pictureDukeColorTable:

    .db     (VDP_COLOR_WHITE        << 4) | VDP_COLOR_BLACK,       (VDP_COLOR_WHITE        << 4) | VDP_COLOR_BLACK
    .db     (VDP_COLOR_WHITE        << 4) | VDP_COLOR_BLACK,       (VDP_COLOR_WHITE        << 4) | VDP_COLOR_BLACK
    .db     (VDP_COLOR_WHITE        << 4) | VDP_COLOR_BLACK,       (VDP_COLOR_WHITE        << 4) | VDP_COLOR_BLACK
    .db     (VDP_COLOR_WHITE        << 4) | VDP_COLOR_BLACK,       (VDP_COLOR_WHITE        << 4) | VDP_COLOR_BLACK
    .db     (VDP_COLOR_BLACK        << 4) | VDP_COLOR_DARK_BLUE,   (VDP_COLOR_BLACK        << 4) | VDP_COLOR_DARK_BLUE
    .db     (VDP_COLOR_BLACK        << 4) | VDP_COLOR_DARK_BLUE,   (VDP_COLOR_BLACK        << 4) | VDP_COLOR_DARK_BLUE
    .db     (VDP_COLOR_BLACK        << 4) | VDP_COLOR_DARK_BLUE,   (VDP_COLOR_BLACK        << 4) | VDP_COLOR_DARK_BLUE
    .db     (VDP_COLOR_BLACK        << 4) | VDP_COLOR_DARK_BLUE,   (VDP_COLOR_BLACK        << 4) | VDP_COLOR_DARK_BLUE
    .db     (VDP_COLOR_BLACK        << 4) | VDP_COLOR_DARK_BLUE,   (VDP_COLOR_BLACK        << 4) | VDP_COLOR_DARK_BLUE
    .db     (VDP_COLOR_BLACK        << 4) | VDP_COLOR_DARK_BLUE,   (VDP_COLOR_BLACK        << 4) | VDP_COLOR_DARK_BLUE
    .db     (VDP_COLOR_BLACK        << 4) | VDP_COLOR_DARK_BLUE,   (VDP_COLOR_BLACK        << 4) | VDP_COLOR_DARK_BLUE
    .db     (VDP_COLOR_BLACK        << 4) | VDP_COLOR_DARK_BLUE,   (VDP_COLOR_BLACK        << 4) | VDP_COLOR_DARK_BLUE
    .db     (VDP_COLOR_BLACK        << 4) | VDP_COLOR_DARK_BLUE,   (VDP_COLOR_BLACK        << 4) | VDP_COLOR_DARK_BLUE
    .db     (VDP_COLOR_BLACK        << 4) | VDP_COLOR_DARK_BLUE,   (VDP_COLOR_BLACK        << 4) | VDP_COLOR_DARK_BLUE
    .db     (VDP_COLOR_BLACK        << 4) | VDP_COLOR_DARK_BLUE,   (VDP_COLOR_BLACK        << 4) | VDP_COLOR_DARK_BLUE
    .db     (VDP_COLOR_BLACK        << 4) | VDP_COLOR_DARK_BLUE,   (VDP_COLOR_BLACK        << 4) | VDP_COLOR_DARK_BLUE
    .db     (VDP_COLOR_BLACK        << 4) | VDP_COLOR_LIGHT_BLUE,  (VDP_COLOR_BLACK        << 4) | VDP_COLOR_LIGHT_BLUE
    .db     (VDP_COLOR_BLACK        << 4) | VDP_COLOR_LIGHT_BLUE,  (VDP_COLOR_BLACK        << 4) | VDP_COLOR_LIGHT_BLUE
    .db     (VDP_COLOR_BLACK        << 4) | VDP_COLOR_LIGHT_BLUE,  (VDP_COLOR_BLACK        << 4) | VDP_COLOR_LIGHT_BLUE
    .db     (VDP_COLOR_BLACK        << 4) | VDP_COLOR_LIGHT_BLUE,  (VDP_COLOR_BLACK        << 4) | VDP_COLOR_LIGHT_BLUE
    .db     (VDP_COLOR_BLACK        << 4) | VDP_COLOR_LIGHT_BLUE,  (VDP_COLOR_BLACK        << 4) | VDP_COLOR_LIGHT_BLUE
    .db     (VDP_COLOR_BLACK        << 4) | VDP_COLOR_LIGHT_BLUE,  (VDP_COLOR_BLACK        << 4) | VDP_COLOR_LIGHT_BLUE
    .db     (VDP_COLOR_BLACK        << 4) | VDP_COLOR_LIGHT_BLUE,  (VDP_COLOR_BLACK        << 4) | VDP_COLOR_LIGHT_BLUE
    .db     (VDP_COLOR_BLACK        << 4) | VDP_COLOR_LIGHT_BLUE,  (VDP_COLOR_BLACK        << 4) | VDP_COLOR_LIGHT_BLUE
    .db     (VDP_COLOR_BLACK        << 4) | VDP_COLOR_LIGHT_BLUE,  (VDP_COLOR_BLACK        << 4) | VDP_COLOR_LIGHT_BLUE
    .db     (VDP_COLOR_BLACK        << 4) | VDP_COLOR_LIGHT_BLUE,  (VDP_COLOR_BLACK        << 4) | VDP_COLOR_LIGHT_BLUE
    .db     (VDP_COLOR_BLACK        << 4) | VDP_COLOR_LIGHT_BLUE,  (VDP_COLOR_BLACK        << 4) | VDP_COLOR_LIGHT_BLUE
    .db     (VDP_COLOR_BLACK        << 4) | VDP_COLOR_LIGHT_BLUE,  (VDP_COLOR_BLACK        << 4) | VDP_COLOR_LIGHT_BLUE

pictureDukeSprite:

    .db     0x84 - 0x01, 0x44 + 0x00, 0xc8, VDP_COLOR_LIGHT_YELLOW
    .db     0x84 - 0x01, 0x44 + 0x35, 0xcc, VDP_COLOR_LIGHT_YELLOW
    .db     0x84 - 0x01, 0x44 + 0x51, 0xd0, VDP_COLOR_LIGHT_YELLOW


; DATA 領域
;
    .area   _DATA

; 変数の定義
;
