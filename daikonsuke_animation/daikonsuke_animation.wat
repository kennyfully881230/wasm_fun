(module
 (memory (export "memory")1) ;; Memory Definition 1 page = 64kb

 ;; FPS
 (global $frame    (mut i32) (i32.const  0)) ;; Current frame
 (global $frame_29      i32  (i32.const 29)) ;; Frame 29
 (global $frame_59      i32  (i32.const 59)) ;; Frame 59

 ;; Common colors
 (global $clear      i32 (i32.const 0x00000000)) ;; ABGR clear
 (global $white      i32 (i32.const 0xFFFFFFFF)) ;; ABGR white
 (global $black      i32 (i32.const 0xFF000000)) ;; ABGR black
 ;; Red
 (global $red        i32 (i32.const 0xFF0000FF)) ;; ABGR red
 (global $red_50     i32 (i32.const 0xFFF2F2FE)) ;; ABGR red     50
 (global $red_100    i32 (i32.const 0xFFE2E2FF)) ;; ABGR red    100
 (global $red_200    i32 (i32.const 0xFFC9C9FF)) ;; ABGR red    200
 (global $red_300    i32 (i32.const 0xFFA2A2FF)) ;; ABGR red    300
 (global $red_400    i32 (i32.const 0xFF6764FF)) ;; ABGR red    400
 (global $red_500    i32 (i32.const 0xFF362CFB)) ;; ABGR red    500
 (global $red_600    i32 (i32.const 0xFF0B00E7)) ;; ABGR red    600
 (global $red_700    i32 (i32.const 0xFF0700C1)) ;; ABGR red    700
 (global $red_800    i32 (i32.const 0xFF12079F)) ;; ABGR red    800
 (global $red_900    i32 (i32.const 0xFF1A1882)) ;; ABGR red    900
 (global $red_950    i32 (i32.const 0xFF090846)) ;; ABGR red    950
 ;; Orange
 (global $orange     i32 (i32.const 0xFF00A5FF)) ;; ABGR orange
 (global $orange_50  i32 (i32.const 0xFFEDF7FF)) ;; ABGR orange  50
 (global $orange_100 i32 (i32.const 0xFFD4EDFF)) ;; ABGR orange 100
 (global $orange_200 i32 (i32.const 0xFFA8D6FF)) ;; ABGR orange 200
 (global $orange_300 i32 (i32.const 0xFF6AB8FF)) ;; ABGR orange 300
 (global $orange_400 i32 (i32.const 0xFF0489FF)) ;; ABGR orange 400
 (global $orange_500 i32 (i32.const 0xFF0069FF)) ;; ABGR orange 500
 (global $orange_600 i32 (i32.const 0xFF004AF5)) ;; ABGR orange 600
 (global $orange_700 i32 (i32.const 0xFF0035CA)) ;; ABGR orange 700
 (global $orange_800 i32 (i32.const 0xFF002D9F)) ;; ABGR orange 800
 (global $orange_900 i32 (i32.const 0xFF0C2A7E)) ;; ABGR orange 900
 (global $orange_950 i32 (i32.const 0xFF061344)) ;; ABGR orange 950
 ;; Yellow
 (global $yellow     i32 (i32.const 0xFF00FFFF)) ;; ABGR yellow
 (global $yellow_50  i32 (i32.const 0xFFE8FCFE)) ;; ABGR yellow  50
 (global $yellow_100 i32 (i32.const 0xFFC2F9FE)) ;; ABGR yellow 100
 (global $yellow_200 i32 (i32.const 0xFF85F0FF)) ;; ABGR yellow 200
 (global $yellow_300 i32 (i32.const 0xFF20DFFF)) ;; ABGR yellow 300
 (global $yellow_400 i32 (i32.const 0xFF00C8FC)) ;; ABGR yellow 400
 (global $yellow_500 i32 (i32.const 0xFF00B1EF)) ;; ABGR yellow 500
 (global $yellow_600 i32 (i32.const 0xFF0087D0)) ;; ABGR yellow 600
 (global $yellow_700 i32 (i32.const 0xFF005FA6)) ;; ABGR yellow 700
 (global $yellow_800 i32 (i32.const 0xFF004B89)) ;; ABGR yellow 800
 (global $yellow_900 i32 (i32.const 0xFF0A3E73)) ;; ABGR yellow 900
 (global $yellow_950 i32 (i32.const 0xFF042043)) ;; ABGR yellow 950
 ;; Green
 (global $green      i32 (i32.const 0xFF00FF00)) ;; ABGR green
 (global $green_50   i32 (i32.const 0xFFF4FDF0)) ;; ABGR green   50
 (global $green_100  i32 (i32.const 0xFFE7FCDC)) ;; ABGR green  100
 (global $green_200  i32 (i32.const 0xFFCFF8B9)) ;; ABGR green  200
 (global $green_300  i32 (i32.const 0xFFA8F17B)) ;; ABGR green  300
 (global $green_400  i32 (i32.const 0xFF72DF05)) ;; ABGR green  400
 (global $green_500  i32 (i32.const 0xFF51C900)) ;; ABGR green  500
 (global $green_600  i32 (i32.const 0xFF3EA600)) ;; ABGR green  600
 (global $green_700  i32 (i32.const 0xFF368200)) ;; ABGR green  700
 (global $green_800  i32 (i32.const 0xFF306601)) ;; ABGR green  800
 (global $green_900  i32 (i32.const 0xFF2B540D)) ;; ABGR green  900
 (global $green_950  i32 (i32.const 0xFF152E03)) ;; ABGR green  950
 ;; Blue
 (global $blue       i32 (i32.const 0xFFFF0000)) ;; ABGR blue
 (global $blue_50    i32 (i32.const 0xFFFFF6EF)) ;; ABGR blue    50
 (global $blue_100   i32 (i32.const 0xFFFEEADB)) ;; ABGR blue   100
 (global $blue_200   i32 (i32.const 0xFFFFDBBE)) ;; ABGR blue   200
 (global $blue_300   i32 (i32.const 0xFFFFC58E)) ;; ABGR blue   300
 (global $blue_400   i32 (i32.const 0xFFFFA251)) ;; ABGR blue   400
 (global $blue_500   i32 (i32.const 0xFFFF7F2B)) ;; ABGR blue   500
 (global $blue_600   i32 (i32.const 0xFFFC5D15)) ;; ABGR blue   600
 (global $blue_700   i32 (i32.const 0xFFE64714)) ;; ABGR blue   700
 (global $blue_800   i32 (i32.const 0xFFB83C19)) ;; ABGR blue   800
 (global $blue_900   i32 (i32.const 0xFF8E391C)) ;; ABGR blue   900
 (global $blue_950   i32 (i32.const 0xFF562416)) ;; ABGR blue   950
 ;; Purple
 (global $purple     i32 (i32.const 0xFF800080)) ;; ABGR purple
 (global $purple_50  i32 (i32.const 0xFFFFF5FA)) ;; ABGR purple  50
 (global $purple_100 i32 (i32.const 0xFFFFE8F3)) ;; ABGR purple 100
 (global $purple_200 i32 (i32.const 0xFFFFD4E9)) ;; ABGR purple 200
 (global $purple_300 i32 (i32.const 0xFFFFB2DA)) ;; ABGR purple 300
 (global $purple_400 i32 (i32.const 0xFFFF7AC2)) ;; ABGR purple 400
 (global $purple_500 i32 (i32.const 0xFFFF46AD)) ;; ABGR purple 500
 (global $purple_600 i32 (i32.const 0xFFFA1098)) ;; ABGR purple 600
 (global $purple_700 i32 (i32.const 0xFFDB0082)) ;; ABGR purple 700
 (global $purple_800 i32 (i32.const 0xFFB0116E)) ;; ABGR purple 800
 (global $purple_900 i32 (i32.const 0xFF8B1659)) ;; ABGR purple 900
 (global $purple_950 i32 (i32.const 0xFF66033C)) ;; ABGR purple 950
 ;; Gray
 (global $gray       i32 (i32.const 0xFF808080)) ;; ABGR gray 
 (global $gray_50    i32 (i32.const 0xFFFBFAF9)) ;; ABGR gray    50
 (global $gray_100   i32 (i32.const 0xFFF6F4F3)) ;; ABGR gray   100
 (global $gray_200   i32 (i32.const 0xFFEBE7E5)) ;; ABGR gray   200
 (global $gray_300   i32 (i32.const 0xFFDCD5D1)) ;; ABGR gray   300
 (global $gray_400   i32 (i32.const 0xFFAFA199)) ;; ABGR gray   400
 (global $gray_500   i32 (i32.const 0xFF82726A)) ;; ABGR gray   500
 (global $gray_600   i32 (i32.const 0xFF65554A)) ;; ABGR gray   600
 (global $gray_700   i32 (i32.const 0xFF534136)) ;; ABGR gray   700
 (global $gray_800   i32 (i32.const 0xFF39291E)) ;; ABGR gray   800
 (global $gray_900   i32 (i32.const 0xFF281810)) ;; ABGR gray   900
 (global $gray_950   i32 (i32.const 0xFF120703)) ;; ABGR gray   950

 (func (export "draw_sprite")
  ;; Check to see if $frame is less than or equal to $frame_29
  global.get $frame
  global.get $frame_29
  i32.le_s

  if
  ;; Row 00
  (i32.store offset=0    (i32.const 0) (global.get $white     )) ;; x= 0, y= 0
  (i32.store offset=4    (i32.const 0) (global.get $white     )) ;; x= 1, y= 0
  (i32.store offset=8    (i32.const 0) (global.get $white     )) ;; x= 2, y= 0
  (i32.store offset=12   (i32.const 0) (global.get $white     )) ;; x= 3, y= 0
  (i32.store offset=16   (i32.const 0) (global.get $white     )) ;; x= 4, y= 0
  (i32.store offset=20   (i32.const 0) (global.get $white     )) ;; x= 5, y= 0
  (i32.store offset=24   (i32.const 0) (global.get $white     )) ;; x= 6, y= 0
  (i32.store offset=28   (i32.const 0) (global.get $white     )) ;; x= 7, y= 0
  (i32.store offset=32   (i32.const 0) (global.get $white     )) ;; x= 8, y= 0
  (i32.store offset=36   (i32.const 0) (global.get $white     )) ;; x= 9, y= 0
  (i32.store offset=40   (i32.const 0) (global.get $white     )) ;; x=10, y= 0
  (i32.store offset=44   (i32.const 0) (global.get $white     )) ;; x=11, y= 0
  (i32.store offset=48   (i32.const 0) (global.get $white     )) ;; x=12, y= 0
  (i32.store offset=52   (i32.const 0) (global.get $white     )) ;; x=13, y= 0
  (i32.store offset=56   (i32.const 0) (global.get $white     )) ;; x=14, y= 0
  (i32.store offset=60   (i32.const 0) (global.get $white     )) ;; x=15, y= 0
  ;; Row 01
  (i32.store offset=64   (i32.const 0) (global.get $white     )) ;; x= 0, y= 1
  (i32.store offset=68   (i32.const 0) (global.get $white     )) ;; x= 1, y= 1
  (i32.store offset=72   (i32.const 0) (global.get $white     )) ;; x= 2, y= 1
  (i32.store offset=76   (i32.const 0) (global.get $white     )) ;; x= 3, y= 1
  (i32.store offset=80   (i32.const 0) (global.get $white     )) ;; x= 4, y= 1
  (i32.store offset=84   (i32.const 0) (global.get $white     )) ;; x= 5, y= 1
  (i32.store offset=88   (i32.const 0) (global.get $white     )) ;; x= 6, y= 1
  (i32.store offset=92   (i32.const 0) (global.get $white     )) ;; x= 7, y= 1
  (i32.store offset=96   (i32.const 0) (global.get $white     )) ;; x= 8, y= 1
  (i32.store offset=100  (i32.const 0) (global.get $white     )) ;; x= 9, y= 1
  (i32.store offset=104  (i32.const 0) (global.get $white     )) ;; x=10, y= 1
  (i32.store offset=108  (i32.const 0) (global.get $white     )) ;; x=11, y= 1
  (i32.store offset=112  (i32.const 0) (global.get $white     )) ;; x=12, y= 1
  (i32.store offset=116  (i32.const 0) (global.get $white     )) ;; x=13, y= 1
  (i32.store offset=120  (i32.const 0) (global.get $white     )) ;; x=14, y= 1
  (i32.store offset=124  (i32.const 0) (global.get $white     )) ;; x=15, y= 1
  ;; Row 02
  (i32.store offset=128  (i32.const 0) (global.get $white     )) ;; x= 0, y= 2
  (i32.store offset=132  (i32.const 0) (global.get $white     )) ;; x= 1, y= 2
  (i32.store offset=136  (i32.const 0) (global.get $white     )) ;; x= 2, y= 2
  (i32.store offset=140  (i32.const 0) (global.get $white     )) ;; x= 3, y= 2
  (i32.store offset=144  (i32.const 0) (global.get $white     )) ;; x= 4, y= 2
  (i32.store offset=148  (i32.const 0) (global.get $white     )) ;; x= 5, y= 2
  (i32.store offset=152  (i32.const 0) (global.get $white     )) ;; x= 6, y= 2
  (i32.store offset=156  (i32.const 0) (global.get $white     )) ;; x= 7, y= 2
  (i32.store offset=160  (i32.const 0) (global.get $white     )) ;; x= 8, y= 2
  (i32.store offset=164  (i32.const 0) (global.get $white     )) ;; x= 9, y= 2
  (i32.store offset=168  (i32.const 0) (global.get $white     )) ;; x=10, y= 2
  (i32.store offset=172  (i32.const 0) (global.get $white     )) ;; x=11, y= 2
  (i32.store offset=176  (i32.const 0) (global.get $white     )) ;; x=12, y= 2
  (i32.store offset=180  (i32.const 0) (global.get $white     )) ;; x=13, y= 2
  (i32.store offset=184  (i32.const 0) (global.get $white     )) ;; x=14, y= 2
  (i32.store offset=188  (i32.const 0) (global.get $white     )) ;; x=15, y= 2
  ;; Row 03
  (i32.store offset=192  (i32.const 0) (global.get $white     )) ;; x= 0, y= 3
  (i32.store offset=196  (i32.const 0) (global.get $white     )) ;; x= 1, y= 3
  (i32.store offset=200  (i32.const 0) (global.get $white     )) ;; x= 2, y= 3
  (i32.store offset=204  (i32.const 0) (global.get $white     )) ;; x= 3, y= 3
  (i32.store offset=208  (i32.const 0) (global.get $white     )) ;; x= 4, y= 3
  (i32.store offset=212  (i32.const 0) (global.get $white     )) ;; x= 5, y= 3
  (i32.store offset=216  (i32.const 0) (global.get $white     )) ;; x= 6, y= 3
  (i32.store offset=220  (i32.const 0) (global.get $white     )) ;; x= 7, y= 3
  (i32.store offset=224  (i32.const 0) (global.get $white     )) ;; x= 8, y= 3
  (i32.store offset=228  (i32.const 0) (global.get $white     )) ;; x= 9, y= 3
  (i32.store offset=232  (i32.const 0) (global.get $white     )) ;; x=10, y= 3
  (i32.store offset=236  (i32.const 0) (global.get $white     )) ;; x=11, y= 3
  (i32.store offset=240  (i32.const 0) (global.get $white     )) ;; x=12, y= 3
  (i32.store offset=244  (i32.const 0) (global.get $white     )) ;; x=13, y= 3
  (i32.store offset=248  (i32.const 0) (global.get $white     )) ;; x=14, y= 3
  (i32.store offset=252  (i32.const 0) (global.get $white     )) ;; x=15, y= 3
  ;; Row 04
  (i32.store offset=256  (i32.const 0) (global.get $white     )) ;; x= 0, y= 4
  (i32.store offset=260  (i32.const 0) (global.get $white     )) ;; x= 1, y= 4
  (i32.store offset=264  (i32.const 0) (global.get $white     )) ;; x= 2, y= 4
  (i32.store offset=268  (i32.const 0) (global.get $white     )) ;; x= 3, y= 4
  (i32.store offset=272  (i32.const 0) (global.get $white     )) ;; x= 4, y= 4
  (i32.store offset=276  (i32.const 0) (global.get $white     )) ;; x= 5, y= 4
  (i32.store offset=280  (i32.const 0) (global.get $black     )) ;; x= 6, y= 4
  (i32.store offset=284  (i32.const 0) (global.get $black     )) ;; x= 7, y= 4
  (i32.store offset=288  (i32.const 0) (global.get $black     )) ;; x= 8, y= 4
  (i32.store offset=292  (i32.const 0) (global.get $black     )) ;; x= 9, y= 4
  (i32.store offset=296  (i32.const 0) (global.get $white     )) ;; x=10, y= 4
  (i32.store offset=300  (i32.const 0) (global.get $white     )) ;; x=11, y= 4
  (i32.store offset=304  (i32.const 0) (global.get $white     )) ;; x=12, y= 4
  (i32.store offset=308  (i32.const 0) (global.get $white     )) ;; x=13, y= 4
  (i32.store offset=312  (i32.const 0) (global.get $white     )) ;; x=14, y= 4
  (i32.store offset=316  (i32.const 0) (global.get $white     )) ;; x=15, y= 4
  ;; Row 05
  (i32.store offset=320  (i32.const 0) (global.get $white     )) ;; x= 0, y= 5
  (i32.store offset=324  (i32.const 0) (global.get $white     )) ;; x= 1, y= 5
  (i32.store offset=328  (i32.const 0) (global.get $white     )) ;; x= 2, y= 5
  (i32.store offset=332  (i32.const 0) (global.get $white     )) ;; x= 3, y= 5
  (i32.store offset=336  (i32.const 0) (global.get $white     )) ;; x= 4, y= 5
  (i32.store offset=340  (i32.const 0) (global.get $black     )) ;; x= 5, y= 5
  (i32.store offset=344  (i32.const 0) (global.get $yellow    )) ;; x= 6, y= 5
  (i32.store offset=348  (i32.const 0) (global.get $yellow    )) ;; x= 7, y= 5
  (i32.store offset=352  (i32.const 0) (global.get $yellow    )) ;; x= 8, y= 5
  (i32.store offset=356  (i32.const 0) (global.get $yellow    )) ;; x= 9, y= 5
  (i32.store offset=360  (i32.const 0) (global.get $black     )) ;; x=10, y= 5
  (i32.store offset=364  (i32.const 0) (global.get $white     )) ;; x=11, y= 5
  (i32.store offset=368  (i32.const 0) (global.get $white     )) ;; x=12, y= 5
  (i32.store offset=372  (i32.const 0) (global.get $white     )) ;; x=13, y= 5
  (i32.store offset=376  (i32.const 0) (global.get $white     )) ;; x=14, y= 5
  (i32.store offset=380  (i32.const 0) (global.get $white     )) ;; x=15, y= 5
  ;; Row 06
  (i32.store offset=384  (i32.const 0) (global.get $white     )) ;; x= 0, y= 6
  (i32.store offset=388  (i32.const 0) (global.get $white     )) ;; x= 1, y= 6
  (i32.store offset=392  (i32.const 0) (global.get $white     )) ;; x= 2, y= 6
  (i32.store offset=396  (i32.const 0) (global.get $white     )) ;; x= 3, y= 6
  (i32.store offset=400  (i32.const 0) (global.get $black     )) ;; x= 4, y= 6
  (i32.store offset=404  (i32.const 0) (global.get $yellow    )) ;; x= 5, y= 6
  (i32.store offset=408  (i32.const 0) (global.get $black     )) ;; x= 6, y= 6
  (i32.store offset=412  (i32.const 0) (global.get $yellow    )) ;; x= 7, y= 6
  (i32.store offset=416  (i32.const 0) (global.get $black     )) ;; x= 8, y= 6
  (i32.store offset=420  (i32.const 0) (global.get $yellow    )) ;; x= 9, y= 6
  (i32.store offset=424  (i32.const 0) (global.get $yellow    )) ;; x=10, y= 6
  (i32.store offset=428  (i32.const 0) (global.get $black     )) ;; x=11, y= 6
  (i32.store offset=432  (i32.const 0) (global.get $white     )) ;; x=12, y= 6
  (i32.store offset=436  (i32.const 0) (global.get $white     )) ;; x=13, y= 6
  (i32.store offset=440  (i32.const 0) (global.get $white     )) ;; x=14, y= 6
  (i32.store offset=444  (i32.const 0) (global.get $white     )) ;; x=15, y= 6
  ;; Row 07
  (i32.store offset=448  (i32.const 0) (global.get $white     )) ;; x= 0, y= 7
  (i32.store offset=452  (i32.const 0) (global.get $white     )) ;; x= 1, y= 7
  (i32.store offset=456  (i32.const 0) (global.get $white     )) ;; x= 2, y= 7
  (i32.store offset=460  (i32.const 0) (global.get $white     )) ;; x= 3, y= 7
  (i32.store offset=464  (i32.const 0) (global.get $black     )) ;; x= 4, y= 7
  (i32.store offset=468  (i32.const 0) (global.get $yellow    )) ;; x= 5, y= 7
  (i32.store offset=472  (i32.const 0) (global.get $black     )) ;; x= 6, y= 7
  (i32.store offset=476  (i32.const 0) (global.get $yellow    )) ;; x= 7, y= 7
  (i32.store offset=480  (i32.const 0) (global.get $black     )) ;; x= 8, y= 7
  (i32.store offset=484  (i32.const 0) (global.get $yellow    )) ;; x= 9, y= 7
  (i32.store offset=488  (i32.const 0) (global.get $yellow    )) ;; x=10, y= 7
  (i32.store offset=492  (i32.const 0) (global.get $black     )) ;; x=11, y= 7
  (i32.store offset=496  (i32.const 0) (global.get $white     )) ;; x=12, y= 7
  (i32.store offset=500  (i32.const 0) (global.get $white     )) ;; x=13, y= 7
  (i32.store offset=504  (i32.const 0) (global.get $white     )) ;; x=14, y= 7
  (i32.store offset=508  (i32.const 0) (global.get $white     )) ;; x=15, y= 7
  ;; Row 08
  (i32.store offset=512  (i32.const 0) (global.get $white     )) ;; x= 0, y= 8
  (i32.store offset=516  (i32.const 0) (global.get $white     )) ;; x= 1, y= 8
  (i32.store offset=520  (i32.const 0) (global.get $white     )) ;; x= 2, y= 8
  (i32.store offset=524  (i32.const 0) (global.get $white     )) ;; x= 3, y= 8
  (i32.store offset=528  (i32.const 0) (global.get $black     )) ;; x= 4, y= 8
  (i32.store offset=532  (i32.const 0) (global.get $yellow    )) ;; x= 5, y= 8
  (i32.store offset=536  (i32.const 0) (global.get $yellow    )) ;; x= 6, y= 8
  (i32.store offset=540  (i32.const 0) (global.get $black     )) ;; x= 7, y= 8
  (i32.store offset=544  (i32.const 0) (global.get $yellow    )) ;; x= 8, y= 8
  (i32.store offset=548  (i32.const 0) (global.get $yellow    )) ;; x= 9, y= 8
  (i32.store offset=552  (i32.const 0) (global.get $yellow    )) ;; x=10, y= 8
  (i32.store offset=556  (i32.const 0) (global.get $black     )) ;; x=11, y= 8
  (i32.store offset=560  (i32.const 0) (global.get $white     )) ;; x=12, y= 8
  (i32.store offset=564  (i32.const 0) (global.get $white     )) ;; x=13, y= 8
  (i32.store offset=568  (i32.const 0) (global.get $white     )) ;; x=14, y= 8
  (i32.store offset=572  (i32.const 0) (global.get $white     )) ;; x=15, y= 8
  ;; Row 09
  (i32.store offset=576  (i32.const 0) (global.get $white     )) ;; x= 0, y= 9
  (i32.store offset=580  (i32.const 0) (global.get $white     )) ;; x= 1, y= 9
  (i32.store offset=584  (i32.const 0) (global.get $white     )) ;; x= 2, y= 9
  (i32.store offset=588  (i32.const 0) (global.get $white     )) ;; x= 3, y= 9
  (i32.store offset=592  (i32.const 0) (global.get $white     )) ;; x= 4, y= 9
  (i32.store offset=596  (i32.const 0) (global.get $black     )) ;; x= 5, y= 9
  (i32.store offset=600  (i32.const 0) (global.get $yellow    )) ;; x= 6, y= 9
  (i32.store offset=604  (i32.const 0) (global.get $yellow    )) ;; x= 7, y= 9
  (i32.store offset=608  (i32.const 0) (global.get $yellow    )) ;; x= 8, y= 9
  (i32.store offset=612  (i32.const 0) (global.get $yellow    )) ;; x= 9, y= 9
  (i32.store offset=616  (i32.const 0) (global.get $black     )) ;; x=10, y= 9
  (i32.store offset=620  (i32.const 0) (global.get $white     )) ;; x=11, y= 9
  (i32.store offset=624  (i32.const 0) (global.get $white     )) ;; x=12, y= 9
  (i32.store offset=628  (i32.const 0) (global.get $white     )) ;; x=13, y= 9
  (i32.store offset=632  (i32.const 0) (global.get $white     )) ;; x=14, y= 9
  (i32.store offset=636  (i32.const 0) (global.get $white     )) ;; x=15, y= 9
  ;; Row 10
  (i32.store offset=640  (i32.const 0) (global.get $white     )) ;; x= 0, y=10
  (i32.store offset=644  (i32.const 0) (global.get $white     )) ;; x= 1, y=10
  (i32.store offset=648  (i32.const 0) (global.get $white     )) ;; x= 2, y=10
  (i32.store offset=652  (i32.const 0) (global.get $white     )) ;; x= 3, y=10
  (i32.store offset=656  (i32.const 0) (global.get $black     )) ;; x= 4, y=10
  (i32.store offset=660  (i32.const 0) (global.get $black     )) ;; x= 5, y=10
  (i32.store offset=664  (i32.const 0) (global.get $black     )) ;; x= 6, y=10
  (i32.store offset=668  (i32.const 0) (global.get $black     )) ;; x= 7, y=10
  (i32.store offset=672  (i32.const 0) (global.get $black     )) ;; x= 8, y=10
  (i32.store offset=676  (i32.const 0) (global.get $black     )) ;; x= 9, y=10
  (i32.store offset=680  (i32.const 0) (global.get $black     )) ;; x=10, y=10
  (i32.store offset=684  (i32.const 0) (global.get $black     )) ;; x=11, y=10
  (i32.store offset=688  (i32.const 0) (global.get $white     )) ;; x=12, y=10
  (i32.store offset=692  (i32.const 0) (global.get $white     )) ;; x=13, y=10
  (i32.store offset=696  (i32.const 0) (global.get $white     )) ;; x=14, y=10
  (i32.store offset=700  (i32.const 0) (global.get $white     )) ;; x=15, y=10
  ;; Row 11
  (i32.store offset=704  (i32.const 0) (global.get $white     )) ;; x= 0, y=11
  (i32.store offset=708  (i32.const 0) (global.get $white     )) ;; x= 1, y=11
  (i32.store offset=712  (i32.const 0) (global.get $white     )) ;; x= 2, y=11
  (i32.store offset=716  (i32.const 0) (global.get $black     )) ;; x= 3, y=11
  (i32.store offset=720  (i32.const 0) (global.get $green     )) ;; x= 4, y=11
  (i32.store offset=724  (i32.const 0) (global.get $green     )) ;; x= 5, y=11
  (i32.store offset=728  (i32.const 0) (global.get $black     )) ;; x= 6, y=11
  (i32.store offset=732  (i32.const 0) (global.get $green     )) ;; x= 7, y=11
  (i32.store offset=736  (i32.const 0) (global.get $green     )) ;; x= 8, y=11
  (i32.store offset=740  (i32.const 0) (global.get $black     )) ;; x= 9, y=11
  (i32.store offset=744  (i32.const 0) (global.get $green     )) ;; x=10, y=11
  (i32.store offset=748  (i32.const 0) (global.get $green     )) ;; x=11, y=11
  (i32.store offset=752  (i32.const 0) (global.get $black     )) ;; x=12, y=11
  (i32.store offset=756  (i32.const 0) (global.get $white     )) ;; x=13, y=11
  (i32.store offset=760  (i32.const 0) (global.get $white     )) ;; x=14, y=11
  (i32.store offset=764  (i32.const 0) (global.get $white     )) ;; x=15, y=11
  ;; Row 12
  (i32.store offset=768  (i32.const 0) (global.get $white     )) ;; x= 0, y=12
  (i32.store offset=772  (i32.const 0) (global.get $white     )) ;; x= 1, y=12
  (i32.store offset=776  (i32.const 0) (global.get $white     )) ;; x= 2, y=12
  (i32.store offset=780  (i32.const 0) (global.get $white     )) ;; x= 3, y=12
  (i32.store offset=784  (i32.const 0) (global.get $black     )) ;; x= 4, y=12
  (i32.store offset=788  (i32.const 0) (global.get $black     )) ;; x= 5, y=12
  (i32.store offset=792  (i32.const 0) (global.get $white     )) ;; x= 6, y=12
  (i32.store offset=796  (i32.const 0) (global.get $black     )) ;; x= 7, y=12
  (i32.store offset=800  (i32.const 0) (global.get $black     )) ;; x= 8, y=12
  (i32.store offset=804  (i32.const 0) (global.get $white     )) ;; x= 9, y=12
  (i32.store offset=808  (i32.const 0) (global.get $black     )) ;; x=10, y=12
  (i32.store offset=812  (i32.const 0) (global.get $black     )) ;; x=11, y=12
  (i32.store offset=816  (i32.const 0) (global.get $white     )) ;; x=12, y=12
  (i32.store offset=820  (i32.const 0) (global.get $white     )) ;; x=13, y=12
  (i32.store offset=824  (i32.const 0) (global.get $white     )) ;; x=14, y=12
  (i32.store offset=828  (i32.const 0) (global.get $white     )) ;; x=15, y=12
  ;; Row 13
  (i32.store offset=832  (i32.const 0) (global.get $white     )) ;; x= 0, y=13
  (i32.store offset=836  (i32.const 0) (global.get $white     )) ;; x= 1, y=13
  (i32.store offset=840  (i32.const 0) (global.get $white     )) ;; x= 2, y=13
  (i32.store offset=844  (i32.const 0) (global.get $white     )) ;; x= 3, y=13
  (i32.store offset=848  (i32.const 0) (global.get $white     )) ;; x= 4, y=13
  (i32.store offset=852  (i32.const 0) (global.get $white     )) ;; x= 5, y=13
  (i32.store offset=856  (i32.const 0) (global.get $white     )) ;; x= 6, y=13
  (i32.store offset=860  (i32.const 0) (global.get $white     )) ;; x= 7, y=13
  (i32.store offset=864  (i32.const 0) (global.get $white     )) ;; x= 8, y=13
  (i32.store offset=868  (i32.const 0) (global.get $white     )) ;; x= 9, y=13
  (i32.store offset=872  (i32.const 0) (global.get $white     )) ;; x=10, y=13
  (i32.store offset=876  (i32.const 0) (global.get $white     )) ;; x=11, y=13
  (i32.store offset=880  (i32.const 0) (global.get $white     )) ;; x=12, y=13
  (i32.store offset=884  (i32.const 0) (global.get $white     )) ;; x=13, y=13
  (i32.store offset=888  (i32.const 0) (global.get $white     )) ;; x=14, y=13
  (i32.store offset=892  (i32.const 0) (global.get $white     )) ;; x=15, y=13
  ;; Row 14
  (i32.store offset=896  (i32.const 0) (global.get $white     )) ;; x= 0, y=14
  (i32.store offset=900  (i32.const 0) (global.get $white     )) ;; x= 1, y=14
  (i32.store offset=904  (i32.const 0) (global.get $white     )) ;; x= 2, y=14
  (i32.store offset=908  (i32.const 0) (global.get $white     )) ;; x= 3, y=14
  (i32.store offset=912  (i32.const 0) (global.get $white     )) ;; x= 4, y=14
  (i32.store offset=916  (i32.const 0) (global.get $white     )) ;; x= 5, y=14
  (i32.store offset=920  (i32.const 0) (global.get $white     )) ;; x= 6, y=14
  (i32.store offset=924  (i32.const 0) (global.get $white     )) ;; x= 7, y=14
  (i32.store offset=928  (i32.const 0) (global.get $white     )) ;; x= 8, y=14
  (i32.store offset=932  (i32.const 0) (global.get $white     )) ;; x= 9, y=14
  (i32.store offset=936  (i32.const 0) (global.get $white     )) ;; x=10, y=14
  (i32.store offset=940  (i32.const 0) (global.get $white     )) ;; x=11, y=14
  (i32.store offset=944  (i32.const 0) (global.get $white     )) ;; x=12, y=14
  (i32.store offset=948  (i32.const 0) (global.get $white     )) ;; x=13, y=14
  (i32.store offset=952  (i32.const 0) (global.get $white     )) ;; x=14, y=14
  (i32.store offset=956  (i32.const 0) (global.get $white     )) ;; x=15, y=14
  ;; Row 15
  (i32.store offset=960  (i32.const 0) (global.get $white     )) ;; x= 0, y=15
  (i32.store offset=964  (i32.const 0) (global.get $white     )) ;; x= 1, y=15
  (i32.store offset=968  (i32.const 0) (global.get $white     )) ;; x= 2, y=15
  (i32.store offset=972  (i32.const 0) (global.get $white     )) ;; x= 3, y=15
  (i32.store offset=976  (i32.const 0) (global.get $white     )) ;; x= 4, y=15
  (i32.store offset=980  (i32.const 0) (global.get $white     )) ;; x= 5, y=15
  (i32.store offset=984  (i32.const 0) (global.get $white     )) ;; x= 6, y=15
  (i32.store offset=988  (i32.const 0) (global.get $white     )) ;; x= 7, y=15
  (i32.store offset=992  (i32.const 0) (global.get $white     )) ;; x= 8, y=15
  (i32.store offset=996  (i32.const 0) (global.get $white     )) ;; x= 9, y=15
  (i32.store offset=1000 (i32.const 0) (global.get $white     )) ;; x=10, y=15
  (i32.store offset=1004 (i32.const 0) (global.get $white     )) ;; x=11, y=15
  (i32.store offset=1008 (i32.const 0) (global.get $white     )) ;; x=12, y=15
  (i32.store offset=1012 (i32.const 0) (global.get $white     )) ;; x=13, y=15
  (i32.store offset=1016 (i32.const 0) (global.get $white     )) ;; x=14, y=15
  (i32.store offset=1020 (i32.const 0) (global.get $white     )) ;; x=15, y=15
  else
  ;; Row 00
  (i32.store offset=0    (i32.const 0) (global.get $white     )) ;; x= 0, y= 0
  (i32.store offset=4    (i32.const 0) (global.get $white     )) ;; x= 1, y= 0
  (i32.store offset=8    (i32.const 0) (global.get $white     )) ;; x= 2, y= 0
  (i32.store offset=12   (i32.const 0) (global.get $white     )) ;; x= 3, y= 0
  (i32.store offset=16   (i32.const 0) (global.get $white     )) ;; x= 4, y= 0
  (i32.store offset=20   (i32.const 0) (global.get $white     )) ;; x= 5, y= 0
  (i32.store offset=24   (i32.const 0) (global.get $white     )) ;; x= 6, y= 0
  (i32.store offset=28   (i32.const 0) (global.get $white     )) ;; x= 7, y= 0
  (i32.store offset=32   (i32.const 0) (global.get $white     )) ;; x= 8, y= 0
  (i32.store offset=36   (i32.const 0) (global.get $white     )) ;; x= 9, y= 0
  (i32.store offset=40   (i32.const 0) (global.get $white     )) ;; x=10, y= 0
  (i32.store offset=44   (i32.const 0) (global.get $white     )) ;; x=11, y= 0
  (i32.store offset=48   (i32.const 0) (global.get $white     )) ;; x=12, y= 0
  (i32.store offset=52   (i32.const 0) (global.get $white     )) ;; x=13, y= 0
  (i32.store offset=56   (i32.const 0) (global.get $white     )) ;; x=14, y= 0
  (i32.store offset=60   (i32.const 0) (global.get $white     )) ;; x=15, y= 0
  ;; Row 01
  (i32.store offset=64   (i32.const 0) (global.get $white     )) ;; x= 0, y= 1
  (i32.store offset=68   (i32.const 0) (global.get $white     )) ;; x= 1, y= 1
  (i32.store offset=72   (i32.const 0) (global.get $white     )) ;; x= 2, y= 1
  (i32.store offset=76   (i32.const 0) (global.get $white     )) ;; x= 3, y= 1
  (i32.store offset=80   (i32.const 0) (global.get $white     )) ;; x= 4, y= 1
  (i32.store offset=84   (i32.const 0) (global.get $white     )) ;; x= 5, y= 1
  (i32.store offset=88   (i32.const 0) (global.get $white     )) ;; x= 6, y= 1
  (i32.store offset=92   (i32.const 0) (global.get $white     )) ;; x= 7, y= 1
  (i32.store offset=96   (i32.const 0) (global.get $white     )) ;; x= 8, y= 1
  (i32.store offset=100  (i32.const 0) (global.get $white     )) ;; x= 9, y= 1
  (i32.store offset=104  (i32.const 0) (global.get $white     )) ;; x=10, y= 1
  (i32.store offset=108  (i32.const 0) (global.get $white     )) ;; x=11, y= 1
  (i32.store offset=112  (i32.const 0) (global.get $white     )) ;; x=12, y= 1
  (i32.store offset=116  (i32.const 0) (global.get $white     )) ;; x=13, y= 1
  (i32.store offset=120  (i32.const 0) (global.get $white     )) ;; x=14, y= 1
  (i32.store offset=124  (i32.const 0) (global.get $white     )) ;; x=15, y= 1
  ;; Row 02
  (i32.store offset=128  (i32.const 0) (global.get $white     )) ;; x= 0, y= 2
  (i32.store offset=132  (i32.const 0) (global.get $white     )) ;; x= 1, y= 2
  (i32.store offset=136  (i32.const 0) (global.get $white     )) ;; x= 2, y= 2
  (i32.store offset=140  (i32.const 0) (global.get $white     )) ;; x= 3, y= 2
  (i32.store offset=144  (i32.const 0) (global.get $white     )) ;; x= 4, y= 2
  (i32.store offset=148  (i32.const 0) (global.get $white     )) ;; x= 5, y= 2
  (i32.store offset=152  (i32.const 0) (global.get $white     )) ;; x= 6, y= 2
  (i32.store offset=156  (i32.const 0) (global.get $white     )) ;; x= 7, y= 2
  (i32.store offset=160  (i32.const 0) (global.get $white     )) ;; x= 8, y= 2
  (i32.store offset=164  (i32.const 0) (global.get $white     )) ;; x= 9, y= 2
  (i32.store offset=168  (i32.const 0) (global.get $white     )) ;; x=10, y= 2
  (i32.store offset=172  (i32.const 0) (global.get $white     )) ;; x=11, y= 2
  (i32.store offset=176  (i32.const 0) (global.get $white     )) ;; x=12, y= 2
  (i32.store offset=180  (i32.const 0) (global.get $white     )) ;; x=13, y= 2
  (i32.store offset=184  (i32.const 0) (global.get $white     )) ;; x=14, y= 2
  (i32.store offset=188  (i32.const 0) (global.get $white     )) ;; x=15, y= 2
  ;; Row 03
  (i32.store offset=192  (i32.const 0) (global.get $white     )) ;; x= 0, y= 3
  (i32.store offset=196  (i32.const 0) (global.get $white     )) ;; x= 1, y= 3
  (i32.store offset=200  (i32.const 0) (global.get $white     )) ;; x= 2, y= 3
  (i32.store offset=204  (i32.const 0) (global.get $white     )) ;; x= 3, y= 3
  (i32.store offset=208  (i32.const 0) (global.get $white     )) ;; x= 4, y= 3
  (i32.store offset=212  (i32.const 0) (global.get $white     )) ;; x= 5, y= 3
  (i32.store offset=216  (i32.const 0) (global.get $black     )) ;; x= 6, y= 3
  (i32.store offset=220  (i32.const 0) (global.get $black     )) ;; x= 7, y= 3
  (i32.store offset=224  (i32.const 0) (global.get $black     )) ;; x= 8, y= 3
  (i32.store offset=228  (i32.const 0) (global.get $black     )) ;; x= 9, y= 3
  (i32.store offset=232  (i32.const 0) (global.get $white     )) ;; x=10, y= 3
  (i32.store offset=236  (i32.const 0) (global.get $white     )) ;; x=11, y= 3
  (i32.store offset=240  (i32.const 0) (global.get $white     )) ;; x=12, y= 3
  (i32.store offset=244  (i32.const 0) (global.get $white     )) ;; x=13, y= 3
  (i32.store offset=248  (i32.const 0) (global.get $white     )) ;; x=14, y= 3
  (i32.store offset=252  (i32.const 0) (global.get $white     )) ;; x=15, y= 3
  ;; Row 04
  (i32.store offset=256  (i32.const 0) (global.get $white     )) ;; x= 0, y= 4
  (i32.store offset=260  (i32.const 0) (global.get $white     )) ;; x= 1, y= 4
  (i32.store offset=264  (i32.const 0) (global.get $white     )) ;; x= 2, y= 4
  (i32.store offset=268  (i32.const 0) (global.get $white     )) ;; x= 3, y= 4
  (i32.store offset=272  (i32.const 0) (global.get $white     )) ;; x= 4, y= 4
  (i32.store offset=276  (i32.const 0) (global.get $black     )) ;; x= 5, y= 4
  (i32.store offset=280  (i32.const 0) (global.get $yellow    )) ;; x= 6, y= 4
  (i32.store offset=284  (i32.const 0) (global.get $yellow    )) ;; x= 7, y= 4
  (i32.store offset=288  (i32.const 0) (global.get $yellow    )) ;; x= 8, y= 4
  (i32.store offset=292  (i32.const 0) (global.get $yellow    )) ;; x= 9, y= 4
  (i32.store offset=296  (i32.const 0) (global.get $black     )) ;; x=10, y= 4
  (i32.store offset=300  (i32.const 0) (global.get $white     )) ;; x=11, y= 4
  (i32.store offset=304  (i32.const 0) (global.get $white     )) ;; x=12, y= 4
  (i32.store offset=308  (i32.const 0) (global.get $white     )) ;; x=13, y= 4
  (i32.store offset=312  (i32.const 0) (global.get $white     )) ;; x=14, y= 4
  (i32.store offset=316  (i32.const 0) (global.get $white     )) ;; x=15, y= 4
  ;; Row 05
  (i32.store offset=320  (i32.const 0) (global.get $white     )) ;; x= 0, y= 5
  (i32.store offset=324  (i32.const 0) (global.get $white     )) ;; x= 1, y= 5
  (i32.store offset=328  (i32.const 0) (global.get $white     )) ;; x= 2, y= 5
  (i32.store offset=332  (i32.const 0) (global.get $white     )) ;; x= 3, y= 5
  (i32.store offset=336  (i32.const 0) (global.get $black     )) ;; x= 4, y= 5
  (i32.store offset=340  (i32.const 0) (global.get $yellow    )) ;; x= 5, y= 5
  (i32.store offset=344  (i32.const 0) (global.get $black     )) ;; x= 6, y= 5
  (i32.store offset=348  (i32.const 0) (global.get $yellow    )) ;; x= 7, y= 5
  (i32.store offset=352  (i32.const 0) (global.get $black     )) ;; x= 8, y= 5
  (i32.store offset=356  (i32.const 0) (global.get $yellow    )) ;; x= 9, y= 5
  (i32.store offset=360  (i32.const 0) (global.get $yellow    )) ;; x=10, y= 5
  (i32.store offset=364  (i32.const 0) (global.get $black     )) ;; x=11, y= 5
  (i32.store offset=368  (i32.const 0) (global.get $white     )) ;; x=12, y= 5
  (i32.store offset=372  (i32.const 0) (global.get $white     )) ;; x=13, y= 5
  (i32.store offset=376  (i32.const 0) (global.get $white     )) ;; x=14, y= 5
  (i32.store offset=380  (i32.const 0) (global.get $white     )) ;; x=15, y= 5
  ;; Row 06
  (i32.store offset=384  (i32.const 0) (global.get $white     )) ;; x= 0, y= 6
  (i32.store offset=388  (i32.const 0) (global.get $white     )) ;; x= 1, y= 6
  (i32.store offset=392  (i32.const 0) (global.get $white     )) ;; x= 2, y= 6
  (i32.store offset=396  (i32.const 0) (global.get $white     )) ;; x= 3, y= 6
  (i32.store offset=400  (i32.const 0) (global.get $black     )) ;; x= 4, y= 6
  (i32.store offset=404  (i32.const 0) (global.get $yellow    )) ;; x= 5, y= 6
  (i32.store offset=408  (i32.const 0) (global.get $black     )) ;; x= 6, y= 6
  (i32.store offset=412  (i32.const 0) (global.get $yellow    )) ;; x= 7, y= 6
  (i32.store offset=416  (i32.const 0) (global.get $black     )) ;; x= 8, y= 6
  (i32.store offset=420  (i32.const 0) (global.get $yellow    )) ;; x= 9, y= 6
  (i32.store offset=424  (i32.const 0) (global.get $yellow    )) ;; x=10, y= 6
  (i32.store offset=428  (i32.const 0) (global.get $black     )) ;; x=11, y= 6
  (i32.store offset=432  (i32.const 0) (global.get $white     )) ;; x=12, y= 6
  (i32.store offset=436  (i32.const 0) (global.get $white     )) ;; x=13, y= 6
  (i32.store offset=440  (i32.const 0) (global.get $white     )) ;; x=14, y= 6
  (i32.store offset=444  (i32.const 0) (global.get $white     )) ;; x=15, y= 6
  ;; Row 07
  (i32.store offset=448  (i32.const 0) (global.get $white     )) ;; x= 0, y= 7
  (i32.store offset=452  (i32.const 0) (global.get $white     )) ;; x= 1, y= 7
  (i32.store offset=456  (i32.const 0) (global.get $white     )) ;; x= 2, y= 7
  (i32.store offset=460  (i32.const 0) (global.get $white     )) ;; x= 3, y= 7
  (i32.store offset=464  (i32.const 0) (global.get $black     )) ;; x= 4, y= 7
  (i32.store offset=468  (i32.const 0) (global.get $yellow    )) ;; x= 5, y= 7
  (i32.store offset=472  (i32.const 0) (global.get $yellow    )) ;; x= 6, y= 7
  (i32.store offset=476  (i32.const 0) (global.get $black     )) ;; x= 7, y= 7
  (i32.store offset=480  (i32.const 0) (global.get $yellow    )) ;; x= 8, y= 7
  (i32.store offset=484  (i32.const 0) (global.get $yellow    )) ;; x= 9, y= 7
  (i32.store offset=488  (i32.const 0) (global.get $yellow    )) ;; x=10, y= 7
  (i32.store offset=492  (i32.const 0) (global.get $black     )) ;; x=11, y= 7
  (i32.store offset=496  (i32.const 0) (global.get $white     )) ;; x=12, y= 7
  (i32.store offset=500  (i32.const 0) (global.get $white     )) ;; x=13, y= 7
  (i32.store offset=504  (i32.const 0) (global.get $white     )) ;; x=14, y= 7
  (i32.store offset=508  (i32.const 0) (global.get $white     )) ;; x=15, y= 7
  ;; Row 08
  (i32.store offset=512  (i32.const 0) (global.get $white     )) ;; x= 0, y= 8
  (i32.store offset=516  (i32.const 0) (global.get $white     )) ;; x= 1, y= 8
  (i32.store offset=520  (i32.const 0) (global.get $white     )) ;; x= 2, y= 8
  (i32.store offset=524  (i32.const 0) (global.get $white     )) ;; x= 3, y= 8
  (i32.store offset=528  (i32.const 0) (global.get $white     )) ;; x= 4, y= 8
  (i32.store offset=532  (i32.const 0) (global.get $black     )) ;; x= 5, y= 8
  (i32.store offset=536  (i32.const 0) (global.get $yellow    )) ;; x= 6, y= 8
  (i32.store offset=540  (i32.const 0) (global.get $yellow    )) ;; x= 7, y= 8
  (i32.store offset=544  (i32.const 0) (global.get $yellow    )) ;; x= 8, y= 8
  (i32.store offset=548  (i32.const 0) (global.get $yellow    )) ;; x= 9, y= 8
  (i32.store offset=552  (i32.const 0) (global.get $black     )) ;; x=10, y= 8
  (i32.store offset=556  (i32.const 0) (global.get $white     )) ;; x=11, y= 8
  (i32.store offset=560  (i32.const 0) (global.get $white     )) ;; x=12, y= 8
  (i32.store offset=564  (i32.const 0) (global.get $white     )) ;; x=13, y= 8
  (i32.store offset=568  (i32.const 0) (global.get $white     )) ;; x=14, y= 8
  (i32.store offset=572  (i32.const 0) (global.get $white     )) ;; x=15, y= 8
  ;; Row 09
  (i32.store offset=576  (i32.const 0) (global.get $white     )) ;; x= 0, y= 9
  (i32.store offset=580  (i32.const 0) (global.get $white     )) ;; x= 1, y= 9
  (i32.store offset=584  (i32.const 0) (global.get $white     )) ;; x= 2, y= 9
  (i32.store offset=588  (i32.const 0) (global.get $white     )) ;; x= 3, y= 9
  (i32.store offset=592  (i32.const 0) (global.get $white     )) ;; x= 4, y= 9
  (i32.store offset=596  (i32.const 0) (global.get $black     )) ;; x= 5, y= 9
  (i32.store offset=600  (i32.const 0) (global.get $black     )) ;; x= 6, y= 9
  (i32.store offset=604  (i32.const 0) (global.get $black     )) ;; x= 7, y= 9
  (i32.store offset=608  (i32.const 0) (global.get $black     )) ;; x= 8, y= 9
  (i32.store offset=612  (i32.const 0) (global.get $black     )) ;; x= 9, y= 9
  (i32.store offset=616  (i32.const 0) (global.get $black     )) ;; x=10, y= 9
  (i32.store offset=620  (i32.const 0) (global.get $white     )) ;; x=11, y= 9
  (i32.store offset=624  (i32.const 0) (global.get $white     )) ;; x=12, y= 9
  (i32.store offset=628  (i32.const 0) (global.get $white     )) ;; x=13, y= 9
  (i32.store offset=632  (i32.const 0) (global.get $white     )) ;; x=14, y= 9
  (i32.store offset=636  (i32.const 0) (global.get $white     )) ;; x=15, y= 9
  ;; Row 10
  (i32.store offset=640  (i32.const 0) (global.get $white     )) ;; x= 0, y=10
  (i32.store offset=644  (i32.const 0) (global.get $white     )) ;; x= 1, y=10
  (i32.store offset=648  (i32.const 0) (global.get $white     )) ;; x= 2, y=10
  (i32.store offset=652  (i32.const 0) (global.get $white     )) ;; x= 3, y=10
  (i32.store offset=656  (i32.const 0) (global.get $black     )) ;; x= 4, y=10
  (i32.store offset=660  (i32.const 0) (global.get $green     )) ;; x= 5, y=10
  (i32.store offset=664  (i32.const 0) (global.get $black     )) ;; x= 6, y=10
  (i32.store offset=668  (i32.const 0) (global.get $green     )) ;; x= 7, y=10
  (i32.store offset=672  (i32.const 0) (global.get $green     )) ;; x= 8, y=10
  (i32.store offset=676  (i32.const 0) (global.get $black     )) ;; x= 9, y=10
  (i32.store offset=680  (i32.const 0) (global.get $green     )) ;; x=10, y=10
  (i32.store offset=684  (i32.const 0) (global.get $black     )) ;; x=11, y=10
  (i32.store offset=688  (i32.const 0) (global.get $white     )) ;; x=12, y=10
  (i32.store offset=692  (i32.const 0) (global.get $white     )) ;; x=13, y=10
  (i32.store offset=696  (i32.const 0) (global.get $white     )) ;; x=14, y=10
  (i32.store offset=700  (i32.const 0) (global.get $white     )) ;; x=15, y=10
  ;; Row 11
  (i32.store offset=704  (i32.const 0) (global.get $white     )) ;; x= 0, y=11
  (i32.store offset=708  (i32.const 0) (global.get $white     )) ;; x= 1, y=11
  (i32.store offset=712  (i32.const 0) (global.get $white     )) ;; x= 2, y=11
  (i32.store offset=716  (i32.const 0) (global.get $white     )) ;; x= 3, y=11
  (i32.store offset=720  (i32.const 0) (global.get $black     )) ;; x= 4, y=11
  (i32.store offset=724  (i32.const 0) (global.get $green     )) ;; x= 5, y=11
  (i32.store offset=728  (i32.const 0) (global.get $black     )) ;; x= 6, y=11
  (i32.store offset=732  (i32.const 0) (global.get $green     )) ;; x= 7, y=11
  (i32.store offset=736  (i32.const 0) (global.get $green     )) ;; x= 8, y=11
  (i32.store offset=740  (i32.const 0) (global.get $black     )) ;; x= 9, y=11
  (i32.store offset=744  (i32.const 0) (global.get $green     )) ;; x=10, y=11
  (i32.store offset=748  (i32.const 0) (global.get $black     )) ;; x=11, y=11
  (i32.store offset=752  (i32.const 0) (global.get $white     )) ;; x=12, y=11
  (i32.store offset=756  (i32.const 0) (global.get $white     )) ;; x=13, y=11
  (i32.store offset=760  (i32.const 0) (global.get $white     )) ;; x=14, y=11
  (i32.store offset=764  (i32.const 0) (global.get $white     )) ;; x=15, y=11
  ;; Row 12
  (i32.store offset=768  (i32.const 0) (global.get $white     )) ;; x= 0, y=12
  (i32.store offset=772  (i32.const 0) (global.get $white     )) ;; x= 1, y=12
  (i32.store offset=776  (i32.const 0) (global.get $white     )) ;; x= 2, y=12
  (i32.store offset=780  (i32.const 0) (global.get $white     )) ;; x= 3, y=12
  (i32.store offset=784  (i32.const 0) (global.get $white     )) ;; x= 4, y=12
  (i32.store offset=788  (i32.const 0) (global.get $black     )) ;; x= 5, y=12
  (i32.store offset=792  (i32.const 0) (global.get $white     )) ;; x= 6, y=12
  (i32.store offset=796  (i32.const 0) (global.get $black     )) ;; x= 7, y=12
  (i32.store offset=800  (i32.const 0) (global.get $black     )) ;; x= 8, y=12
  (i32.store offset=804  (i32.const 0) (global.get $white     )) ;; x= 9, y=12
  (i32.store offset=808  (i32.const 0) (global.get $black     )) ;; x=10, y=12
  (i32.store offset=812  (i32.const 0) (global.get $white     )) ;; x=11, y=12
  (i32.store offset=816  (i32.const 0) (global.get $white     )) ;; x=12, y=12
  (i32.store offset=820  (i32.const 0) (global.get $white     )) ;; x=13, y=12
  (i32.store offset=824  (i32.const 0) (global.get $white     )) ;; x=14, y=12
  (i32.store offset=828  (i32.const 0) (global.get $white     )) ;; x=15, y=12
  ;; Row 13
  (i32.store offset=832  (i32.const 0) (global.get $white     )) ;; x= 0, y=13
  (i32.store offset=836  (i32.const 0) (global.get $white     )) ;; x= 1, y=13
  (i32.store offset=840  (i32.const 0) (global.get $white     )) ;; x= 2, y=13
  (i32.store offset=844  (i32.const 0) (global.get $white     )) ;; x= 3, y=13
  (i32.store offset=848  (i32.const 0) (global.get $white     )) ;; x= 4, y=13
  (i32.store offset=852  (i32.const 0) (global.get $white     )) ;; x= 5, y=13
  (i32.store offset=856  (i32.const 0) (global.get $white     )) ;; x= 6, y=13
  (i32.store offset=860  (i32.const 0) (global.get $white     )) ;; x= 7, y=13
  (i32.store offset=864  (i32.const 0) (global.get $white     )) ;; x= 8, y=13
  (i32.store offset=868  (i32.const 0) (global.get $white     )) ;; x= 9, y=13
  (i32.store offset=872  (i32.const 0) (global.get $white     )) ;; x=10, y=13
  (i32.store offset=876  (i32.const 0) (global.get $white     )) ;; x=11, y=13
  (i32.store offset=880  (i32.const 0) (global.get $white     )) ;; x=12, y=13
  (i32.store offset=884  (i32.const 0) (global.get $white     )) ;; x=13, y=13
  (i32.store offset=888  (i32.const 0) (global.get $white     )) ;; x=14, y=13
  (i32.store offset=892  (i32.const 0) (global.get $white     )) ;; x=15, y=13
  ;; Row 14
  (i32.store offset=896  (i32.const 0) (global.get $white     )) ;; x= 0, y=14
  (i32.store offset=900  (i32.const 0) (global.get $white     )) ;; x= 1, y=14
  (i32.store offset=904  (i32.const 0) (global.get $white     )) ;; x= 2, y=14
  (i32.store offset=908  (i32.const 0) (global.get $white     )) ;; x= 3, y=14
  (i32.store offset=912  (i32.const 0) (global.get $white     )) ;; x= 4, y=14
  (i32.store offset=916  (i32.const 0) (global.get $white     )) ;; x= 5, y=14
  (i32.store offset=920  (i32.const 0) (global.get $white     )) ;; x= 6, y=14
  (i32.store offset=924  (i32.const 0) (global.get $white     )) ;; x= 7, y=14
  (i32.store offset=928  (i32.const 0) (global.get $white     )) ;; x= 8, y=14
  (i32.store offset=932  (i32.const 0) (global.get $white     )) ;; x= 9, y=14
  (i32.store offset=936  (i32.const 0) (global.get $white     )) ;; x=10, y=14
  (i32.store offset=940  (i32.const 0) (global.get $white     )) ;; x=11, y=14
  (i32.store offset=944  (i32.const 0) (global.get $white     )) ;; x=12, y=14
  (i32.store offset=948  (i32.const 0) (global.get $white     )) ;; x=13, y=14
  (i32.store offset=952  (i32.const 0) (global.get $white     )) ;; x=14, y=14
  (i32.store offset=956  (i32.const 0) (global.get $white     )) ;; x=15, y=14
  ;; Row 15
  (i32.store offset=960  (i32.const 0) (global.get $white     )) ;; x= 0, y=15
  (i32.store offset=964  (i32.const 0) (global.get $white     )) ;; x= 1, y=15
  (i32.store offset=968  (i32.const 0) (global.get $white     )) ;; x= 2, y=15
  (i32.store offset=972  (i32.const 0) (global.get $white     )) ;; x= 3, y=15
  (i32.store offset=976  (i32.const 0) (global.get $white     )) ;; x= 4, y=15
  (i32.store offset=980  (i32.const 0) (global.get $white     )) ;; x= 5, y=15
  (i32.store offset=984  (i32.const 0) (global.get $white     )) ;; x= 6, y=15
  (i32.store offset=988  (i32.const 0) (global.get $white     )) ;; x= 7, y=15
  (i32.store offset=992  (i32.const 0) (global.get $white     )) ;; x= 8, y=15
  (i32.store offset=996  (i32.const 0) (global.get $white     )) ;; x= 9, y=15
  (i32.store offset=1000 (i32.const 0) (global.get $white     )) ;; x=10, y=15
  (i32.store offset=1004 (i32.const 0) (global.get $white     )) ;; x=11, y=15
  (i32.store offset=1008 (i32.const 0) (global.get $white     )) ;; x=12, y=15
  (i32.store offset=1012 (i32.const 0) (global.get $white     )) ;; x=13, y=15
  (i32.store offset=1016 (i32.const 0) (global.get $white     )) ;; x=14, y=15
  (i32.store offset=1020 (i32.const 0) (global.get $white     )) ;; x=15, y=15
  end

  ;; check to see if $frame is <= 
  global.get $frame
  global.get $frame_59

  i32.lt_s
  
  if
  ;; Increment the frame number
  global.get $frame
  i32.const 1
  i32.add
  global.set $frame

  else
  i32.const 0
  global.set $frame
  end
 )
)
