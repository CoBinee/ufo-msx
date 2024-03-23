; Sound.s : サウンド
;


; モジュール宣言
;
    .module Sound

; 参照ファイル
;
    .include    "bios.inc"
    .include    "System.inc"
    .include	"Sound.inc"

; 外部変数宣言
;

; マクロの定義
;


; CODE 領域
;
    .area   _CODE

; BGM を再生する
;
_SoundPlayBgm::

    ; レジスタの保存
    push    hl
    push    bc
    push    de

    ; a < BGM

    ; 現在再生している BGM の取得
    ld      bc, (_soundChannel + SOUND_CHANNEL_A + SOUND_CHANNEL_HEAD)

    ; サウンドの再生
    add     a, a
    ld      e, a
    add     a, a
    add     a, e
    ld      e, a
    ld      d, #0x00
    ld      hl, #soundBgm
    add     hl, de
    ld      e, (hl)
    inc     hl
    ld      d, (hl)
    inc     hl
    ld      a, e
    cp      c
    jr      nz, 10$
    ld      a, d
    cp      b
    jr      z, 19$
10$:
    ld      (_soundChannel + SOUND_CHANNEL_A + SOUND_CHANNEL_REQUEST), de
    ld      e, (hl)
    inc     hl
    ld      d, (hl)
    inc     hl
    ld      (_soundChannel + SOUND_CHANNEL_B + SOUND_CHANNEL_REQUEST), de
    ld      e, (hl)
    inc     hl
    ld      d, (hl)
;   inc     hl
    ld      (_soundChannel + SOUND_CHANNEL_C + SOUND_CHANNEL_REQUEST), de
19$:

    ; レジスタの復帰
    pop     de
    pop     bc
    pop     hl

    ; 終了
    ret

; SE を再生する
;
_SoundPlaySe::

    ; レジスタの保存
    push    hl
    push    de

    ; a < SE

    ; サウンドの再生
    add     a, a
    ld      e, a
    ld      d, #0x00
    ld      hl, #soundSe
    add     hl, de
    ld      e, (hl)
    inc     hl
    ld      d, (hl)
;   inc     hl
    ld      (_soundChannel + SOUND_CHANNEL_D + SOUND_CHANNEL_REQUEST), de

    ; レジスタの復帰
    pop     de
    pop     hl

    ; 終了
    ret

; サウンドを停止する
;
_SoundStop::

    ; レジスタの保存

    ; サウンドの停止
    call    _SystemStopSound

    ; レジスタの復帰

    ; 終了
    ret

; BGM が再生中かどうかを判定する
;
_SoundIsPlayBgm::

    ; レジスタの保存
    push    hl

    ; cf > 0/1 = 停止/再生中

    ; サウンドの監視
    ld      hl, (_soundChannel + SOUND_CHANNEL_A + SOUND_CHANNEL_REQUEST)
    ld      a, h
    or      l
    jr      nz, 10$
    ld      hl, (_soundChannel + SOUND_CHANNEL_A + SOUND_CHANNEL_PLAY)
    ld      a, h
    or      l
    jr      nz, 10$
    or      a
    jr      19$
10$:
    scf
19$:

    ; レジスタの復帰
    pop     hl

    ; 終了
    ret

; SE が再生中かどうかを判定する
;
_SoundIsPlaySe::

    ; レジスタの保存
    push    hl

    ; cf > 0/1 = 停止/再生中

    ; サウンドの監視
    ld      hl, (_soundChannel + SOUND_CHANNEL_D + SOUND_CHANNEL_REQUEST)
    ld      a, h
    or      l
    jr      nz, 10$
    ld      hl, (_soundChannel + SOUND_CHANNEL_D + SOUND_CHANNEL_PLAY)
    ld      a, h
    or      l
    jr      nz, 10$
    or      a
    jr      19$
10$:
    scf
19$:

    ; レジスタの復帰
    pop     hl

    ; 終了
    ret

; 定数の定義
;

; 共通
;
soundNull:

    .ascii  "T1@0"
    .db     0x00

; BGM
;
soundBgm:

    .dw     soundNull, soundNull, soundNull
    .dw     soundBgmTitle_A, soundBgmTitle_B, soundBgmTitle_C
    .dw     soundBgmStart_A, soundBgmStart_B, soundBgmStart_C
    .dw     soundBgmClear_A, soundBgmClear_B, soundBgmClear_C

; タイトル
soundBgmTitle_A:

    .ascii  "T3@0V15,4"
    .ascii  "L3O4C"
    .ascii  "L3O4F6CA-6RB-A-GFG5CC"
    .ascii  "L3O4E6CB-6RA-5G5F5R5"
    .db     0x00

soundBgmTitle_B:

    .ascii  "T3@0V13,4"
    .ascii  "L3R"
    .ascii  "L3O2FO3FO2CO3CO2FO3FO2CO3CO2GO3GO2CO3CO2GO3GO2CO3C"
    .ascii  "L3O2CO3CO2GO3GO2CO3CO1GO1GO1FO2FO2CO3CO1FO2FO2CO3C"
    .db     0x00

soundBgmTitle_C:

    .ascii  "T3@0V13,4"
    .ascii  "L3R"
    .ascii  "L3O4C6RF6RR9"
    .ascii  "L3O4C6RE6RC5E5R7"
    .db     0x00

; スタート
soundBgmStart_A:

    .ascii  "T3@0V15,4"
    .ascii  "L3O4G5GC5CFGB-5AG7R"
    .db     0x00

soundBgmStart_B:
    .ascii  "T3@0V13,4"
    .ascii  "L3O2AEAEAEAEAEAEAEAE"
    .db     0x00

soundBgmStart_C:

    .ascii  "T3@0V13,4"
    .ascii  "L3O4E5RR5RRRE5RR7R"
    .db     0x00

; クリア
soundBgmClear_A:

    .ascii  "T3@0V15,4"
    .ascii  "L5O4AA3A3B-GF8"
    .db     0x00

soundBgmClear_B:

    .ascii  "T3@0V13,4"
    .ascii  "L3O2CO1GO2CO1GO2CO1GO2CO1GO2FCFCFCFC"
    .db     0x00

soundBgmClear_C:

    .ascii  "T3@0V13,4"
    .ascii  "L5O4FF3F3GRR8"
    .db     0x00

; SE
;
soundSe:

    .dw     soundNull
    .dw     soundSeBoot
    .dw     soundSeClick
    .dw     soundSeBomb

; ブート
soundSeBoot:

    .ascii  "T2@0V15L3O6BO5BR9"
    .db     0x00

; クリック
soundSeClick:

    .ascii  "T2@0V15O4B0"
    .db     0x00

; 爆発
soundSeBomb:

    .ascii  "T1@0"
    .ascii  "V15L0O4GFEDCO3BAG"
    .ascii  "V14L0O4GFEDCO3BAG"
    .ascii  "V13L0O4GFEDCO3BAG"
    .ascii  "V12L0O4GFEDCO3BAG"
    .ascii  "V11L0O4GFEDCO3BAG"
    .ascii  "V10L0O4GFEDCO3BAG"
    .ascii  "V9L0O4GFEDCO3BAG"
    .ascii  "V8L0O4GFEDCO3BAG"
    .db     0x00


; DATA 領域
;
    .area   _DATA

; 変数の定義
;
