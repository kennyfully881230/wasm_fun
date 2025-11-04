(module
 (memory (export "memory")1)                     ;; Memory Definition 64kb

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
  ;; Row 00
  (i32.store offset=0    (i32.const 0) (global.get $red_50    )) ;; x= 0, y= 0
  (i32.store offset=4    (i32.const 0) (global.get $red_100   )) ;; x= 1, y= 0
  (i32.store offset=8    (i32.const 0) (global.get $red_200   )) ;; x= 2, y= 0
  (i32.store offset=12   (i32.const 0) (global.get $red_300   )) ;; x= 3, y= 0
  (i32.store offset=16   (i32.const 0) (global.get $red_400   )) ;; x= 4, y= 0
  (i32.store offset=20   (i32.const 0) (global.get $red_500   )) ;; x= 5, y= 0
  (i32.store offset=24   (i32.const 0) (global.get $red_600   )) ;; x= 6, y= 0
  (i32.store offset=28   (i32.const 0) (global.get $red_700   )) ;; x= 7, y= 0
  (i32.store offset=32   (i32.const 0) (global.get $red_800   )) ;; x= 8, y= 0
  (i32.store offset=36   (i32.const 0) (global.get $red_900   )) ;; x= 9, y= 0
  (i32.store offset=40   (i32.const 0) (global.get $red_950   )) ;; x=10, y= 0
  ;; Row 01
  (i32.store offset=44   (i32.const 0) (global.get $orange_50 )) ;; x= 0, y= 1
  (i32.store offset=48   (i32.const 0) (global.get $orange_100)) ;; x= 1, y= 1
  (i32.store offset=52   (i32.const 0) (global.get $orange_200)) ;; x= 2, y= 1
  (i32.store offset=56   (i32.const 0) (global.get $orange_300)) ;; x= 3, y= 1
  (i32.store offset=60   (i32.const 0) (global.get $orange_400)) ;; x= 4, y= 1
  (i32.store offset=64   (i32.const 0) (global.get $orange_500)) ;; x= 5, y= 1
  (i32.store offset=68   (i32.const 0) (global.get $orange_600)) ;; x= 6, y= 1
  (i32.store offset=72   (i32.const 0) (global.get $orange_700)) ;; x= 7, y= 1
  (i32.store offset=76   (i32.const 0) (global.get $orange_800)) ;; x= 8, y= 1
  (i32.store offset=80   (i32.const 0) (global.get $orange_900)) ;; x= 9, y= 1
  (i32.store offset=84   (i32.const 0) (global.get $orange_950)) ;; x=10, y= 1
  ;; Row 02
  (i32.store offset=88   (i32.const 0) (global.get $yellow_50 )) ;; x= 0, y= 2
  (i32.store offset=92   (i32.const 0) (global.get $yellow_100)) ;; x= 1, y= 2
  (i32.store offset=96   (i32.const 0) (global.get $yellow_200)) ;; x= 2, y= 2
  (i32.store offset=100  (i32.const 0) (global.get $yellow_300)) ;; x= 3, y= 2
  (i32.store offset=104  (i32.const 0) (global.get $yellow_400)) ;; x= 4, y= 2
  (i32.store offset=108  (i32.const 0) (global.get $yellow_500)) ;; x= 5, y= 2
  (i32.store offset=112  (i32.const 0) (global.get $yellow_600)) ;; x= 6, y= 2
  (i32.store offset=116  (i32.const 0) (global.get $yellow_700)) ;; x= 7, y= 2
  (i32.store offset=120  (i32.const 0) (global.get $yellow_800)) ;; x= 8, y= 2
  (i32.store offset=124  (i32.const 0) (global.get $yellow_900)) ;; x= 9, y= 2
  (i32.store offset=128  (i32.const 0) (global.get $yellow_950)) ;; x=10, y= 2
  ;; Row 03
  (i32.store offset=132  (i32.const 0) (global.get $green_50  )) ;; x= 0, y= 3
  (i32.store offset=136  (i32.const 0) (global.get $green_100 )) ;; x= 1, y= 3
  (i32.store offset=140  (i32.const 0) (global.get $green_200 )) ;; x= 2, y= 3
  (i32.store offset=144  (i32.const 0) (global.get $green_300 )) ;; x= 3, y= 3
  (i32.store offset=148  (i32.const 0) (global.get $green_400 )) ;; x= 4, y= 3
  (i32.store offset=152  (i32.const 0) (global.get $green_500 )) ;; x= 5, y= 3
  (i32.store offset=156  (i32.const 0) (global.get $green_600 )) ;; x= 6, y= 3
  (i32.store offset=160  (i32.const 0) (global.get $green_700 )) ;; x= 7, y= 3
  (i32.store offset=164  (i32.const 0) (global.get $green_800 )) ;; x= 8, y= 3
  (i32.store offset=168  (i32.const 0) (global.get $green_900 )) ;; x= 9, y= 3
  (i32.store offset=172  (i32.const 0) (global.get $green_950 )) ;; x=10, y= 3
  ;; Row 04
  (i32.store offset=176  (i32.const 0) (global.get $blue_50   )) ;; x= 0, y= 4
  (i32.store offset=180  (i32.const 0) (global.get $blue_100  )) ;; x= 1, y= 4
  (i32.store offset=184  (i32.const 0) (global.get $blue_200  )) ;; x= 2, y= 4
  (i32.store offset=188  (i32.const 0) (global.get $blue_300  )) ;; x= 3, y= 4
  (i32.store offset=192  (i32.const 0) (global.get $blue_400  )) ;; x= 4, y= 4
  (i32.store offset=196  (i32.const 0) (global.get $blue_500  )) ;; x= 5, y= 4
  (i32.store offset=200  (i32.const 0) (global.get $blue_600  )) ;; x= 6, y= 4
  (i32.store offset=204  (i32.const 0) (global.get $blue_700  )) ;; x= 7, y= 4
  (i32.store offset=208  (i32.const 0) (global.get $blue_800  )) ;; x= 8, y= 4
  (i32.store offset=212  (i32.const 0) (global.get $blue_900  )) ;; x= 9, y= 4
  (i32.store offset=216  (i32.const 0) (global.get $blue_950  )) ;; x=10, y= 4
  ;; Row 05
  (i32.store offset=220  (i32.const 0) (global.get $purple_50 )) ;; x= 0, y= 5
  (i32.store offset=224  (i32.const 0) (global.get $purple_100)) ;; x= 1, y= 5
  (i32.store offset=228  (i32.const 0) (global.get $purple_200)) ;; x= 2, y= 5
  (i32.store offset=232  (i32.const 0) (global.get $purple_300)) ;; x= 3, y= 5
  (i32.store offset=236  (i32.const 0) (global.get $purple_400)) ;; x= 4, y= 5
  (i32.store offset=240  (i32.const 0) (global.get $purple_500)) ;; x= 5, y= 5
  (i32.store offset=244  (i32.const 0) (global.get $purple_600)) ;; x= 6, y= 5
  (i32.store offset=248  (i32.const 0) (global.get $purple_700)) ;; x= 7, y= 5
  (i32.store offset=252  (i32.const 0) (global.get $purple_800)) ;; x= 8, y= 5
  (i32.store offset=256  (i32.const 0) (global.get $purple_900)) ;; x= 9, y= 5
  (i32.store offset=260  (i32.const 0) (global.get $purple_950)) ;; x=10, y= 5
  ;; Row 06
  (i32.store offset=264  (i32.const 0) (global.get $gray_50   )) ;; x= 0, y= 6
  (i32.store offset=268  (i32.const 0) (global.get $gray_100  )) ;; x= 1, y= 6
  (i32.store offset=272  (i32.const 0) (global.get $gray_200  )) ;; x= 2, y= 6
  (i32.store offset=276  (i32.const 0) (global.get $gray_300  )) ;; x= 3, y= 6
  (i32.store offset=280  (i32.const 0) (global.get $gray_400  )) ;; x= 4, y= 6
  (i32.store offset=284  (i32.const 0) (global.get $gray_500  )) ;; x= 5, y= 6
  (i32.store offset=288  (i32.const 0) (global.get $gray_600  )) ;; x= 6, y= 6
  (i32.store offset=292  (i32.const 0) (global.get $gray_700  )) ;; x= 7, y= 6
  (i32.store offset=296  (i32.const 0) (global.get $gray_800  )) ;; x= 8, y= 6
  (i32.store offset=300  (i32.const 0) (global.get $gray_900  )) ;; x= 9, y= 6
  (i32.store offset=304  (i32.const 0) (global.get $gray_950  )) ;; x=10, y= 6
  ;; Row 07
  (i32.store offset=308  (i32.const 0) (global.get $white     )) ;; x= 0, y= 7
  (i32.store offset=312  (i32.const 0) (global.get $red       )) ;; x= 1, y= 7
  (i32.store offset=316  (i32.const 0) (global.get $orange    )) ;; x= 2, y= 7
  (i32.store offset=320  (i32.const 0) (global.get $yellow    )) ;; x= 3, y= 7
  (i32.store offset=324  (i32.const 0) (global.get $green     )) ;; x= 4, y= 7
  (i32.store offset=328  (i32.const 0) (global.get $blue      )) ;; x= 5, y= 7
  (i32.store offset=332  (i32.const 0) (global.get $purple    )) ;; x= 6, y= 7
  (i32.store offset=336  (i32.const 0) (global.get $black     )) ;; x= 7, y= 7
 )
)
