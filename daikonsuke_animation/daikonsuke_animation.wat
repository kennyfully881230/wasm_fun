;; Kenny Fully made this example. May GOD bless you.
;; ===============================================================
;;  DAIKONSUKE ANIMATION  —  STACK-STYLE FIXED VERSION
;;  ---------------------------------------------------------------
;;  - Two animation frames (0–29 and 30–59)
;;  - Each pixel = 1 byte color index (0–3)
;;  - Colors: white, black, yellow, green
;;  - Sprite data starts at memory offset 1024
;;  - RGBA frame buffer starts at offset 0
;;  - Uses pure stack flow (no S-expression syntax)
;; ===============================================================

(module
  ;; ---------------------------------------------------------------
  ;; Memory & Globals
  ;; ---------------------------------------------------------------
  (memory (export "memory") 1)            ;; 1 page = 64KB
  (global $frame (mut i32) (i32.const 0)) ;; animation frame counter
  (global $white  i32 (i32.const 0xFFFFFFFF)) ;; RGBA: white
  (global $black  i32 (i32.const 0xFF000000)) ;; RGBA: black
  (global $yellow i32 (i32.const 0xFF00FFFF)) ;; RGBA: yellow
  (global $green  i32 (i32.const 0xFF00FF00)) ;; RGBA: green

  ;; ---------------------------------------------------------------
  ;; Sprite data section (1 byte per pixel index)
  ;;   Each value: 0=white, 1=black, 2=yellow, 3=green
  ;;   Base address = 1024
  ;; ---------------------------------------------------------------
  (data (i32.const 1024)
    ;; Frame 01 data
    "\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00"
    "\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00"
    "\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00"
    "\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00"
    "\00\00\00\00\00\00\01\01\01\01\00\00\00\00\00\00"
    "\00\00\00\00\00\01\02\02\02\02\01\00\00\00\00\00"
    "\00\00\00\00\01\02\01\02\01\02\02\01\00\00\00\00"
    "\00\00\00\00\01\02\01\02\01\02\02\01\00\00\00\00"
    "\00\00\00\00\01\02\02\01\02\02\02\01\00\00\00\00"
    "\00\00\00\00\00\01\02\02\02\02\01\00\00\00\00\00"
    "\00\00\00\00\01\01\01\01\01\01\01\01\00\00\00\00"
    "\00\00\00\01\03\03\01\03\03\01\03\03\01\00\00\00"
    "\00\00\00\00\01\01\00\01\01\00\01\01\00\00\00\00"
    "\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00"
    "\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00"
    "\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00"
    ;; Frame 02 data (starts at 1280)
    "\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00"
    "\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00"
    "\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00"
    "\00\00\00\00\00\00\01\01\01\01\00\00\00\00\00\00"
    "\00\00\00\00\00\01\02\02\02\02\01\00\00\00\00\00"
    "\00\00\00\00\01\02\01\02\01\02\02\01\00\00\00\00"
    "\00\00\00\00\01\02\01\02\01\02\02\01\00\00\00\00"
    "\00\00\00\00\01\02\02\01\02\02\02\01\00\00\00\00"
    "\00\00\00\00\00\01\02\02\02\02\01\00\00\00\00\00"
    "\00\00\00\00\00\01\01\01\01\01\01\00\00\00\00\00"
    "\00\00\00\00\01\03\01\03\03\01\03\01\00\00\00\00"
    "\00\00\00\00\01\03\01\03\03\01\03\01\00\00\00\00"
    "\00\00\00\00\00\01\00\01\01\00\01\00\00\00\00\00"
    "\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00"
    "\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00"
    "\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00"
  )

  ;; ---------------------------------------------------------------
  ;; draw_sprite()
  ;; ---------------------------------------------------------------
  (func (export "draw_sprite") (local $i i32) (local $pix i32) (local $col i32)
    global.get $frame
    i32.const 29
    i32.le_s
    if
      ;; ===============================================================
      ;;  FRAME 1: for frame <= 29
      ;; ===============================================================
      ;; ----------------------------------------------
      ;; Initialize i = 0
      i32.const 0
      local.set $i
      ;; ----------------------------------------------
      block
        loop
          ;; if (i >= 256) break
          local.get $i
          i32.const 256
          i32.ge_s
          br_if 1

          ;; load pixel index: memory[1024 + i]
          i32.const 1024
          local.get $i
          i32.add
          i32.load8_u
          local.set $pix

          ;; determine color
          local.get $pix
          i32.const 0
          i32.eq
          if
            global.get $white
            local.set $col
          else
            local.get $pix
            i32.const 1
            i32.eq
            if
              global.get $black
              local.set $col
            else
              local.get $pix
              i32.const 2
              i32.eq
              if
                global.get $yellow
                local.set $col
              else
                global.get $green
                local.set $col
              end
            end
          end

          ;; store RGBA color at address = i * 4
          local.get $i
          i32.const 4
          i32.mul
          local.get $col
          i32.store

          ;; increment i and continue
          local.get $i
          i32.const 1
          i32.add
          local.set $i
          br 0
        end
      end

    else
      ;; ===============================================================
      ;;  FRAME 2: for frame > 29
      ;; ===============================================================
      ;; ----------------------------------------------
      ;; Initialize i = 0
      i32.const 0
      local.set $i
      ;; ----------------------------------------------
      block
        loop
          ;; if (i >= 256) break
          local.get $i
          i32.const 256
          i32.ge_s
          br_if 1

          ;; load pixel index: memory[1280 + i]
          i32.const 1280
          local.get $i
          i32.add
          i32.load8_u
          local.set $pix

          ;; determine color
          local.get $pix
          i32.const 0
          i32.eq
          if
            global.get $white
            local.set $col
          else
            local.get $pix
            i32.const 1
            i32.eq
            if
              global.get $black
              local.set $col
            else
              local.get $pix
              i32.const 2
              i32.eq
              if
                global.get $yellow
                local.set $col
              else
                global.get $green
                local.set $col
              end
            end
          end

          ;; store RGBA color at address = i * 4
          local.get $i
          i32.const 4
          i32.mul
          local.get $col
          i32.store

          ;; increment i and continue
          local.get $i
          i32.const 1
          i32.add
          local.set $i
          br 0
        end
      end
    end

    ;; ===============================================================
    ;;  FRAME COUNTER UPDATE (wrap every 60 frames)
    ;; ===============================================================
    global.get $frame
    i32.const 59
    i32.lt_s
    if
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

