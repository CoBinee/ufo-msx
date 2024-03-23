; Title.s : タイトル
;


; モジュール宣言
;
    .module Title

; 参照ファイル
;
    .include    "bios.inc"
    .include    "vdp.inc"
    .include    "System.inc"
    .include    "Sound.inc"
    .include    "App.inc"
    .include    "Picture.inc"
    .include	"Title.inc"

; 外部変数宣言
;
    .globl  _patternTable

; マクロの定義
;


; CODE 領域
;
    .area   _CODE

; タイトルを初期化する
;
_TitleInitialize::
    
    ; レジスタの保存
    
    ; スプライトのクリア
    call    _SystemClearSprite
    
    ; パターンネームのクリア
    xor     a
    call    _SystemClearPatternName
    
    ; タイトルの初期化
    ld      hl, #titleDefault
    ld      de, #_title
    ld      bc, #TITLE_LENGTH
    ldir

    ; 転送の設定
    ld      hl, #_SystemUpdatePatternName
    ld      (_transfer), hl

    ; 描画の開始
    ld      hl, #(_videoRegister + VDP_R1)
    set     #VDP_R1_BL, (hl)
    
    ; 処理の設定
    ld      hl, #TitleIdle
    ld      (_title + TITLE_PROC_L), hl
    xor     a
    ld      (_title + TITLE_STATE), a

    ; 状態の設定
    ld      a, #APP_STATE_TITLE_UPDATE
    ld      (_app + APP_STATE), a
    
    ; レジスタの復帰
    
    ; 終了
    ret

; タイトルを更新する
;
_TitleUpdate::
    
    ; レジスタの保存
    
    ; スプライトのクリア
    call    _SystemClearSprite

    ; 状態別の処理
    ld      hl, #10$
    push    hl
    ld      hl, (_title + TITLE_PROC_L)
    jp      (hl)
;   pop     hl
10$:

    ; レジスタの復帰
    
    ; 終了
    ret

; 何もしない
;
TitleNull:

    ; レジスタの保存

    ; レジスタの復帰

    ; 終了
    ret

; タイトルを待機する
;
TitleIdle:

    ; レジスタの保存

    ; 初期化
    ld      a, (_title + TITLE_STATE)
    or      a
    jr      nz, 09$

    ; 点滅の設定
    xor     a
    ld      (_title + TITLE_BLINK), a

    ; アニメーションの設定
    xor     a
    ld      (_title + TITLE_ANIMATION), a

    ; デュークの表示
    call    _PicturePrintDuke
    
    ; ステータスの表示
    call    TitlePrintStatus

    ; BGM の再生
    ld      a, #SOUND_BGM_TITLE
    call    _SoundPlayBgm

    ; 初期化の完了
    ld      hl, #(_title + TITLE_STATE)
    inc     (hl)
09$:

    ; スペースキーの押下
    ld      a, (_input + INPUT_BUTTON_SPACE)
    dec     a
    jr      nz, 19$

    ; 状態の更新
    ld      hl, #TitleStart
    ld      (_title + TITLE_PROC_L), hl
    xor     a
    ld      (_title + TITLE_STATE), a
19$:

    ; HIT SPACE BAR の点滅
    ld      hl, #(_title + TITLE_BLINK)
    inc     (hl)
    call    TitlePrintHitSpaceBar

    ; デュークのアニメーション
    ld      hl, #(_title + TITLE_ANIMATION)
    ld      a, (hl)
    inc     a
    cp      #(0x06 * 0x04)
    jr      c, 30$
    xor     a
30$:
    ld      (hl), a
    ld      de, #(_sprite + TITLE_SPRITE_DUKE)
    call    _PictureAnimateDuke

    ; レジスタの復帰

    ; 終了
    ret

; タイトルを開始する
;
TitleStart:

    ; レジスタの保存

    ; 初期化
    ld      a, (_title + TITLE_STATE)
    or      a
    jr      nz, 09$

    ; フレームの設定
    ld      a, #0x40
    ld      (_title + TITLE_FRAME), a

    ; BGM の停止
    call    _SoundStop

    ; SE の再生
    ld      a, #SOUND_SE_BOOT
    call    _SoundPlaySe

    ; 初期化の完了
    ld      hl, #(_title + TITLE_STATE)
    inc     (hl)
09$:

    ; フレームの更新
    ld      hl, #(_title + TITLE_FRAME)
    dec     (hl)
    jr      nz, 19$

    ; 状態の更新
    ld      a, #APP_STATE_GAME_INITIALIZE
    ld      (_app + APP_STATE), a
19$:

    ; HIT SPACE BAR の点滅
    ld      hl, #(_title + TITLE_BLINK)
    ld      a, (hl)
    add     a, #0x08
    ld      (hl), a
    call    TitlePrintHitSpaceBar

    ; デュークのアニメーション
    ld      hl, #(_title + TITLE_ANIMATION)
    ld      a, (hl)
    inc     a
    cp      #(0x06 * 0x04)
    jr      c, 30$
    xor     a
30$:
    ld      (hl), a
    ld      de, #(_sprite + TITLE_SPRITE_DUKE)
    call    _PictureAnimateDuke

    ; レジスタの復帰

    ; 終了
    ret

; ステータスを表示する
;
TitlePrintStatus:

    ; レジスタの保存

    ; タイムの表示
    ld      hl, #(_patternName + 0x002b)
    ld      a, #0x27
    ld      b, #0x04
10$:
    ld      (hl), a
    inc     a
    inc     hl
    djnz    10$
    ld      hl, (_app + APP_TIME_L)
    ld      de, #(_patternName + 0x0030)
    ld      b, #0x05
    call    TitlePrintValue16

    ; レジスタの復帰

    ; 終了
    ret

; HIT SPACE BAR を表示する
;
TitlePrintHitSpaceBar:

    ; レジスタの保存

    ; HIT SPACE BAR の表示
    ld      hl, #(_patternName + 0x0289)
    ld      b, #0x0e
    ld      a, (_title + TITLE_BLINK)
    and     #0x10
    jr      nz, 11$
    ld      a, #0x30
10$:
    ld      (hl), a
    inc     a
    inc     hl
    djnz    10$
    jr      19$
11$:
    xor     a
12$:
    ld      (hl), a
    inc     hl
    djnz    12$
;   jr      19$
19$:

    ; レジスタの復帰

    ; 終了
    ret

; 数値を表示する
;
TitlePrintValue16:

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

TitlePrintValue8:

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
TitlePrintString:

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

; タイトルの初期値
;
titleDefault:

    .dw     TITLE_PROC_NULL
    .db     TITLE_STATE_NULL
    .db     TITLE_FLAG_NULL
    .db     TITLE_FRAME_NULL
    .db     TITLE_COUNT_NULL
    .db     TITLE_BLINK_NULL
    .db     TITLE_ANIMATION_NULL

; ステータス
;
titleStatusString:

    .ascii  "BEST"
    .db     0x00

; HIT SPACE BAR
;
titleHitSpaceBarString:

    .ascii  "HIT SPACE BAR"
    .db     0x00


; DATA 領域
;
    .area   _DATA

; 変数の定義
;

; タイトル
;
_title::

    .ds     TITLE_LENGTH

