;; Kenny Fully made this example. May GOD bless you.
;; Please understand that the maze editor feature is coming soon!
(module
  ;; imports
  (import "sound" "playDataSound" (func $play_data_sound (param i32)))
  ;; exports
  (memory (export "memory") 3) ;; 196608 bytes
  ;; mutable variables
  (global $countup                       (mut i32) (i32.const 0   ))
  (global $maze_cleared                  (mut i32) (i32.const 0   ))
  (global $maze_index                    (mut i32) (i32.const 0   ))
  (global $maze_init                     (mut i32) (i32.const 0   ))
  (global $maze_selected                 (mut i32) (i32.const 0   ))
  (global $player_mode                   (mut i32) (i32.const 0   ))
  (global $player_lucky                  (mut i32) (i32.const 0   ))
  (global $player_size                   (mut i32) (i32.const 16  ))
  (global $player_x                      (mut i32) (i32.const 16  ))
  (global $player_y                      (mut i32) (i32.const 16  ))
  (global $scene_index                   (mut i32) (i32.const 0   )) ;; current scene 0 = Title; 1 = Maze Select; 2 = Game
  (global $timer_30                      (mut i32) (i32.const 0   )) ;; 30 frame counter
  (global $timer_60                      (mut i32) (i32.const 0   )) ;; 60 frame counter
  (global $timer_cooldown_15             (mut i32) (i32.const 0   )) ;; used for limiting repeating sounds
  (global $title_image_loaded            (mut i32) (i32.const 0   )) ;; check to see if title image loaded

  ;; functions
   
  (func $check_for_lucky (result i32 i32 i32)
    global.get $player_lucky
    i32.const 1
    i32.eq
    if (result i32 i32 i32)
      i32.const 0xFF000080
      i32.const 0xFF0000FF
      i32.const 0xFF00FFFF
    else
      i32.const 0xFF000000
      i32.const 0xFFF04F65
      i32.const 0xFFFFFFFF
    end
  )

  (func $check_item_on_map (param $i i32) (param $item_index i32) (result i32)
    i32.const 400
    global.get $maze_index
    i32.mul
    i32.const 141321
    i32.add
    local.get $i
    i32.add
    i32.load8_u
    local.get $item_index
    i32.eq
  )

  (func $collision_check_key (param $color_index i32) (param $i i32)
    local.get $i
    call $player_to_object_collision
    if
      local.get $i
      call $player_to_object_collision
      if          
        i32.const 144925
        i32.load16_u
        call $play_data_sound
        i32.const 400
        global.get $maze_index
        i32.mul
        i32.const 141321
        i32.add
        local.get $i
        i32.add        
        i32.const 0x09 ;; indicates key picked up
        local.get $color_index
        i32.add
        i32.store8
        ;; update key status
        i32.const 144944
        local.get $color_index
        i32.add
        i32.const 1
        i32.store8
      end
    end
  )

  (func $collision_check_lock (param $color_index i32) (param $i i32)
    local.get $i
    call $player_to_object_collision
    if
      i32.const 144944
      local.get $color_index
      i32.add
      i32.load8_u
      i32.const 1
      i32.eq
      if          
        i32.const 144927
        i32.load16_u
        call $play_data_sound
        i32.const 400
        global.get $maze_index
        i32.mul
        i32.const 141321
        i32.add
        local.get $i
        i32.add        
        i32.const 0x0C ;; indicates unlocked
        i32.store8
        i32.const 144944
        local.get $color_index
        i32.add
        i32.const 0
        i32.store8
      else
        call $pushback_player
      end
    end
  )
  
  (func $collision_checks (local $i i32)
    loop $loop
      ;; check if a sweet_rock collides
      local.get $i
      i32.const 1
      call $check_item_on_map
      if
        local.get $i
        call $player_to_object_collision
        if
          call $pushback_player
        end
      end
      ;; check if a wasm_block collides
      local.get $i
      i32.const 2
      call $check_item_on_map
      if
        local.get $i
        call $player_to_object_collision
        if
          ;; set maze_cleared
          i32.const 1
          global.set $maze_cleared
          ;; add trophy to the maze button if maze level is less than 8
          global.get $maze_index
          i32.const 8
          i32.lt_s
          if
            i32.const 141312 ;; address for trophies
            global.get $maze_index
            i32.add
            i32.const 1
            i32.store8
          end
        end
      end
      ;; check if a key_red collides
      local.get $i
      i32.const 3
      call $check_item_on_map
      if
        i32.const 0
        local.get $i
        call $collision_check_key
      end
      ;; check if a key_green collides
      local.get $i
      i32.const 4
      call $check_item_on_map
      if
        i32.const 1
        local.get $i
        call $collision_check_key
      end
      ;; check if a key_blue collides
      local.get $i
      i32.const 5
      call $check_item_on_map
      if
        i32.const 2
        local.get $i
        call $collision_check_key
      end
      ;; check if a lock_red collides
      local.get $i
      i32.const 6
      call $check_item_on_map
      if
        i32.const 0
        local.get $i
        call $collision_check_lock
      end
      ;; check if a lock_green collides
      local.get $i
      i32.const 7
      call $check_item_on_map
      if
        i32.const 1
        local.get $i
        call $collision_check_lock
      end
      ;; check if a lock_blue collides
      local.get $i
      i32.const 8
      call $check_item_on_map
      if
        i32.const 2
        local.get $i
        call $collision_check_lock
      end
      ;; increment i
      local.get $i
      i32.const 1
      i32.add
      local.set $i
      local.get $i
      i32.const 400 ;; max amount of items on a map
      i32.lt_s
      br_if $loop
    end
  )
  
  (func $player_to_object_collision (param $i i32) (result i32)
    global.get $player_x
    i32.const 3
    i32.add
    global.get $player_y
    i32.const 6
    i32.add
    i32.const 10 ;; player_hitbox_size
    local.get $i
    i32.const 20
    i32.rem_s
    i32.const 16
    i32.mul       ;; object_x
    local.get $i
    f32.convert_i32_s
    i32.const 20
    f32.convert_i32_s
    f32.div
    f32.floor
    i32.trunc_f32_s
    i32.const 16
    i32.mul     ;; object_y
    i32.const 16 ;; object_size
    call $square_collision
    i32.const 1 ;; check for true
    i32.eq
  )

  (func $pushback_player
    global.get $timer_cooldown_15
    i32.const 0
    i32.eq
    if
      i32.const 15
      global.set $timer_cooldown_15
      i32.const 144923 
      i32.load16_u
      call $play_data_sound
    end
    global.get $player_mode
    i32.const 1
    i32.eq
    if
      global.get $player_y
      i32.const 1
      i32.add
      global.set $player_y
    else
      global.get $player_mode
      i32.const 2
      i32.eq
      if
        global.get $player_y
        i32.const 1
        i32.sub
        global.set $player_y
      else
        global.get $player_mode
        i32.const 3
        i32.eq
        if
          global.get $player_x
          i32.const 1
          i32.add
          global.set $player_x
        else
          global.get $player_mode
          i32.const 4
          i32.eq
          if
            global.get $player_x
            i32.const 1
            i32.sub
            global.set $player_x
          end
        end
      end
    end
  )

  ;; render a sprite based on index colors
  (func $render_color_indexed_sprite
    (param $dx i32)
    (param $dy i32)
    (param $dw i32)
    (param $dh i32)
    (param $color_01 i32)
    (param $color_02 i32)
    (param $color_03 i32)
    (param $color_04 i32)
    (param $color_05 i32)
    (param $data_address i32)
    (local $i i32)
    (local $j i32)
    (local $color_index i32)
    ;; for some reason init local variables to avoid rare bugs
    i32.const 0
    local.set $i
    i32.const 0
    local.set $j
    i32.const 0
    local.set $color_index
    loop $loop_y
      i32.const 0
      local.set $j
      loop $loop_x
        ;; Check bounds - y first
        local.get $dy
        local.get $i
        i32.add
        i32.const 0
        i32.ge_s
        if
          local.get $dy
          local.get $i
          i32.add
          i32.const 160 ;; gamebox_height
          i32.lt_s
          if
            ;; Check x bounds
            local.get $dx
            local.get $j
            i32.add
            i32.const 0
            i32.ge_s
            if
              local.get $dx
              local.get $j
              i32.add
              i32.const 160 ;; gamebox_width
              i32.lt_s
              if
                ;; Get sprite data: i * dw + j
                local.get $i
                local.get $dw
                i32.mul
                local.get $j
                i32.add
                local.get $data_address
                i32.add
                i32.load8_u
                i32.const 0
                i32.ne
                if
                  local.get $i
                  local.get $dw
                  i32.mul
                  local.get $j
                  i32.add
                  local.get $data_address
                  i32.add
                  i32.load8_u
                  i32.const 1
                  i32.eq
                  if
                    local.get $color_01
                    local.set $color_index
                  end
                  local.get $i
                  local.get $dw
                  i32.mul
                  local.get $j
                  i32.add
                  local.get $data_address
                  i32.add
                  i32.load8_u
                  i32.const 2
                  i32.eq
                  if
                    local.get $color_02
                    local.set $color_index
                  end
                  local.get $i
                  local.get $dw
                  i32.mul
                  local.get $j
                  i32.add
                  local.get $data_address
                  i32.add
                  i32.load8_u
                  i32.const 3
                  i32.eq
                  if
                    local.get $color_03
                    local.set $color_index
                  end
                  local.get $i
                  local.get $dw
                  i32.mul
                  local.get $j
                  i32.add
                  local.get $data_address
                  i32.add
                  i32.load8_u
                  i32.const 4
                  i32.eq
                  if
                    local.get $color_04
                    local.set $color_index
                  end
                  local.get $i
                  local.get $dw
                  i32.mul
                  local.get $j
                  i32.add
                  local.get $data_address
                  i32.add
                  i32.load8_u
                  i32.const 5
                  i32.eq
                  if
                    local.get $color_05
                    local.set $color_index
                  end
                  ;; Calculate pixel buffer offset: (dy+i) * width + (dx+j)
                  local.get $dy
                  local.get $i
                  i32.add
                  i32.const 160 ;; gamebox_width
                  i32.mul
                  local.get $dx
                  local.get $j
                  i32.add
                  i32.add
                  i32.const 4
                  i32.mul
                  local.get $color_index
                  i32.store
                end
              end
            end
          end
        end
        local.get $j
        i32.const 1
        i32.add
        local.set $j
        local.get $j
        local.get $dw
        i32.lt_s
        br_if $loop_x
      end
      local.get $i
      i32.const 1
      i32.add
      local.set $i
      local.get $i
      local.get $dh
      i32.lt_s
      br_if $loop_y
    end
  )

  (func $render_key
    (param $i i32)
    (param $color_01 i32)
    (param $color_02 i32)
    (param $color_03 i32)
    local.get $i         ;; key_dx
    i32.const 20
    i32.rem_s
    i32.const 16
    i32.mul
    i32.const 72 ;; cam_x
    i32.add
    global.get $player_x
    i32.sub
    local.get $i         ;; key_dy
    f32.convert_i32_s
    i32.const 20
    f32.convert_i32_s
    f32.div
    f32.floor
    i32.trunc_f32_s
    i32.const 16
    i32.mul
    i32.const 72 ;; cam_y
    i32.add
    global.get $player_y
    i32.sub
    i32.const 16         ;; key_dw
    i32.const 16         ;; key_dh
    local.get $color_01
    local.get $color_02
    local.get $color_03
    i32.const 0x00000000 ;; color_04
    i32.const 0x00000000  ;; color_05
    i32.const 132608   ;; data_address
    call $render_color_indexed_sprite
  )

  (func $render_lock
    (param $i i32)
    (param $color_01 i32)
    (param $color_02 i32)
    (param $color_03 i32)
    local.get $i         ;; key_red_dx
    i32.const 20
    i32.rem_s
    i32.const 16
    i32.mul
    i32.const 72 ;; cam_x
    i32.add
    global.get $player_x
    i32.sub
    local.get $i         ;; key_red_dy
    f32.convert_i32_s
    i32.const 20
    f32.convert_i32_s
    f32.div
    f32.floor
    i32.trunc_f32_s
    i32.const 16
    i32.mul
    i32.const 72 ;; cam_y
    i32.add
    global.get $player_y
    i32.sub
    i32.const 16         ;; key_red_dw
    i32.const 16         ;; key_red_dh
    local.get $color_01
    local.get $color_02
    local.get $color_03
    i32.const 0x00000000  ;; color_04
    i32.const 0x00000000  ;; color_05
    i32.const 132864      ;; data_address
    call $render_color_indexed_sprite
  )

  ;; render map
  (func $render_map (local $i i32)
    loop $loop
      ;; check for sweet_rock
      i32.const 400
      global.get $maze_index
      i32.mul
      i32.const 141321   
      i32.add
      local.get $i
      i32.add
      i32.load8_u
      i32.const 1
      i32.eq
      if
        local.get $i         ;; sweet_rock_dx
        i32.const 20
        i32.rem_s
        i32.const 16
        i32.mul
        i32.const 72 ;; cam_x
        i32.add
        global.get $player_x
        i32.sub
        local.get $i         ;; sweet_rock_dy
        f32.convert_i32_s
        i32.const 20
        f32.convert_i32_s
        f32.div
        f32.floor
        i32.trunc_f32_s
        i32.const 16
        i32.mul
        i32.const 72 ;; cam_y
        i32.add
        global.get $player_y
        i32.sub
        i32.const 16         ;; sweet_rock_dw
        i32.const 16         ;; sweet_rock_dh
        i32.const 0xFF000000     ;; color_01
        i32.const 0xFFF5F5FF        
        i32.const 0xFFF7F7FF
        global.get $timer_30
        i32.const 9
        i32.lt_s
        select
        i32.const 0xFFFFFFFF
        global.get $timer_30
        i32.const 19
        i32.lt_s
        select ;; color_02
        i32.const 144749
        i32.load8_u
        i32.const 0x00
        i32.const 0x00
        call $rgb_color_mix     ;; color_03
        i32.const 0xFFF04F65    ;; color_04
        i32.const 0xFF9CE1FF    ;; color_05
        i32.const 129536    ;; data_address
        call $render_color_indexed_sprite
      end
      ;; check for wasm_block
      i32.const 400
      global.get $maze_index
      i32.mul
      i32.const 141321   
      i32.add
      local.get $i
      i32.add
      i32.load8_u
      i32.const 2
      i32.eq
      if
        local.get $i         ;; wasm_block_dx
        i32.const 20
        i32.rem_s
        i32.const 16
        i32.mul
        i32.const 72 ;; cam_x
        i32.add
        global.get $player_x
        i32.sub
        local.get $i         ;; wasm_block_dy
        f32.convert_i32_s
        i32.const 20
        f32.convert_i32_s
        f32.div
        f32.floor
        i32.trunc_f32_s
        i32.const 16
        i32.mul
        i32.const 72 ;; cam_y
        i32.add
        global.get $player_y
        i32.sub
        i32.const 16         ;; wasm_block_dw
        i32.const 16         ;; wasm_block_dh
        i32.const 0xFFFF0000
        i32.const 0xFFF04F65
        global.get $timer_60
        i32.const 29
        i32.lt_s
        select ;; color_01
        i32.const 0xFFFFFFFF ;; color_02
        i32.const 0x00000000 ;; color_03
        i32.const 0x00000000 ;; color_04
        i32.const 0x00000000 ;; color_05
        i32.const 132352     ;; data_address
        call $render_color_indexed_sprite
      end
      ;; check for key_red
      i32.const 400
      global.get $maze_index
      i32.mul
      i32.const 141321   
      i32.add
      local.get $i
      i32.add
      i32.load8_u
      i32.const 3
      i32.eq
      if
        local.get $i
        i32.const 0xFF0000FF
        i32.const 0xFF000080
        global.get $timer_60
        i32.const 29
        i32.lt_s
        select ;; color_01
        i32.const 0xFFFFFFFF ;; color_02
        i32.const 0x00000000 ;; color_03
        call $render_key
      end
      ;; check for key_green
      i32.const 400
      global.get $maze_index
      i32.mul
      i32.const 141321   
      i32.add
      local.get $i
      i32.add
      i32.load8_u
      i32.const 4
      i32.eq
      if
        local.get $i
        i32.const 0xFF00FF00
        i32.const 0xFF008000
        global.get $timer_60
        i32.const 29
        i32.lt_s
        select ;; color_01
        i32.const 0xFFFFFFFF ;; color_02
        i32.const 0x00000000 ;; color_03
        call $render_key
      end
      ;; check for key_blue
      i32.const 400
      global.get $maze_index
      i32.mul
      i32.const 141321   
      i32.add
      local.get $i
      i32.add
      i32.load8_u
      i32.const 5
      i32.eq
      if
        local.get $i
        i32.const 0xFFFF0000
        i32.const 0xFF800000
        global.get $timer_60
        i32.const 29
        i32.lt_s
        select ;; color_01
        i32.const 0xFFFFFFFF ;; color_02
        i32.const 0x00000000 ;; color_03
        call $render_key
      end
      ;; check for lock_red
      i32.const 400
      global.get $maze_index
      i32.mul
      i32.const 141321   
      i32.add
      local.get $i
      i32.add
      i32.load8_u
      i32.const 6
      i32.eq
      if
        local.get $i
        i32.const 0xFF0000FF ;; color_01
        i32.const 0xFF00FFFF ;; color_02
        i32.const 0x00000000 ;; color_03
        call $render_lock
      end
      ;; check for lock_green
      i32.const 400
      global.get $maze_index
      i32.mul
      i32.const 141321   
      i32.add
      local.get $i
      i32.add
      i32.load8_u
      i32.const 7
      i32.eq
      if
        local.get $i
        i32.const 0xFF008000 ;; color_01
        i32.const 0xFF00FFFF   ;; color_02
        i32.const 0x00000000   ;; color_03
        call $render_lock
      end
      ;; check for lock_blue
      i32.const 400
      global.get $maze_index
      i32.mul
      i32.const 141321   
      i32.add
      local.get $i
      i32.add
      i32.load8_u
      i32.const 8
      i32.eq
      if
        local.get $i
        i32.const 0xFFFF0000 ;; color_01
        i32.const 0xFF00FFFF ;; color_02
        i32.const 0x00000000 ;; color_03
        call $render_lock
      end
      ;; increment i
      local.get $i
      i32.const 1
      i32.add
      local.set $i
      local.get $i
      i32.const 400 ;; max amount of possible items on a map
      i32.lt_s
      br_if $loop
    end
  )

  (func $render_maze_maker_map_background
    (local $i i32)
    (local $j i32)
    i32.const 0
    local.set $i
    loop $loop_i
      i32.const 0
      local.set $j
      loop $loop_j
        i32.const 16
        local.get $i
        i32.mul
        i32.const 24
        i32.add              ;; dx
        i32.const 16
        local.get $j
        i32.mul
        i32.const 24
        i32.add              ;; dy
        i32.const 16         ;; dw
        i32.const 16         ;; dh
        i32.const 0xFFF0F0FF ;; color_01
        i32.const 0xFFF0FFF0 ;; color_02
        i32.const 0xFF000000 ;; color_03
        i32.const 0xFF000000 ;; color_04
        i32.const 0xFF000000 ;; color_05
        i32.const 145459
        call $render_color_indexed_sprite
        ;; increment j
        local.get $j
        i32.const 1
        i32.add
        local.set $j
        local.get $j
        i32.const 5
        i32.lt_s
        br_if $loop_j
      end
      ;; increment i
      local.get $i
      i32.const 1
      i32.add
      local.set $i
      local.get $i
      i32.const 5
      i32.lt_s
      br_if $loop_i
    end
  )

  (func $render_pointer
    global.get $timer_30
    i32.const 14
    i32.lt_s
    if
      i32.const 144942
      i32.load8_u
      i32.const 8
      i32.sub
      i32.const 144943
      i32.load8_u
      i32.const 8
      i32.sub
      i32.const 16
      i32.const 16
      i32.const 0xFF000000
      i32.const 0xFF00FFFF
      i32.const 0x00000000
      i32.const 0x00000000
      i32.const 0x00000000
      i32.const 128000
      call $render_color_indexed_sprite
    else
      i32.const 144942
      i32.load8_u
      i32.const 8
      i32.sub
      i32.const 144943
      i32.load8_u
      i32.const 8
      i32.sub
      i32.const 16
      i32.const 16
      i32.const 0xFF000000
      i32.const 0xFF00FFFF
      i32.const 0x00000000
      i32.const 0x00000000
      i32.const 0x00000000
      i32.const 128256
      call $render_color_indexed_sprite
    end
  )

  (func $rgb_color_mix
    (param $red i32)
    (param $green i32)
    (param $blue i32)
    (result i32)
    i32.const 144745
    local.get $red
    i32.store8
    i32.const 144746
    local.get $green
    i32.store8
    i32.const 144747
    local.get $blue
    i32.store8
    i32.const 144748
    i32.const 0xFF
    i32.store8
    i32.const 144745
    i32.load
  )

  ;; todo: rewrite this function
  (func $rgb_fill_screen
    (param $red i32)
    (param $green i32)
    (param $blue i32)
    (local $i i32)       ;; Loop counter (pixel index)
    (local $color i32)   ;; Pre-calculated 32-bit RGBA color
    (local $offset i32)  ;; Memory offset
    ;; 1. Pre-calculate the 32-bit RGBA color word
    ;; Color format: 0xAABBGGRR (assuming little-endian memory)
    ;; The function parameters (R, G, B) are i32s, but we treat them as bytes (i8s).
    local.get $red        ;; Pushes R (i32)
    local.get $green
    i32.const 8
    i32.shl             ;; G << 8
    i32.or                ;; R | (G << 8) = GGRR
    local.get $blue
    i32.const 16
    i32.shl             ;; B << 16
    i32.or                ;; (GGRR) | (B << 16) = BBGGRR
    i32.const 0xFF000000  ;; Alpha (0xFF << 24)
    i32.or                ;; (BBGGRR) | (FF << 24) = AABBGGRR
    local.set $color      ;; Store the final 32-bit color word
    ;; Initialize loop counter
    i32.const 0
    local.set $i
    loop $loop
      ;; Calculate memory offset: i * 4
      local.get $i
      i32.const 2
      i32.shl             ;; i << 2 is equivalent to i * 4 (much faster)
      local.set $offset
      ;; Store the 32-bit color word at the calculated offset
      local.get $offset
      local.get $color
      i32.store           ;; Store the entire 32-bit word (4 bytes) at once
      ;; Increment loop counter
      local.get $i
      i32.const 1
      i32.add
      local.set $i
      ;; Check loop condition (i < 25600)
      local.get $i
      i32.const 25600
      i32.lt_s
      br_if $loop
    end
  )  
  
  (func $square_collision
    (param $x1 i32) (param $y1 i32) (param $size1 i32) 
    (param $x2 i32) (param $y2 i32) (param $size2 i32) 
    (result i32)
    (local $x1_end i32) (local $y1_end i32) 
    (local $x2_end i32) (local $y2_end i32)
    
    ;; calculate the right/bottom edges of both squares
    local.get $x1
    local.get $size1
    i32.add
    local.set $x1_end
    
    local.get $y1
    local.get $size1
    i32.add
    local.set $y1_end
    
    local.get $x2
    local.get $size2
    i32.add
    local.set $x2_end
    
    local.get $y2
    local.get $size2
    i32.add
    local.set $y2_end
    
    ;; check collision using AABB
    ;; if (x1 < x2_end && x1_end > x2 && y1 < y2_end && y1_end > y2)
    local.get $x1
    local.get $x2_end
    i32.lt_s
    if
      local.get $x1_end
      local.get $x2
      i32.gt_s
      if
        local.get $y1
        local.get $y2_end
        i32.lt_s
        if
          local.get $y1_end
          local.get $y2
          i32.gt_s
          if
            i32.const 1
            return
          end
        end
      end
    end
    i32.const 0
  )

  ;; scenes
  
  (func $scene_title
    global.get $title_image_loaded
    i32.const 1
    i32.ne
    if
      i32.const 1
      global.set $title_image_loaded
      i32.const 0
      i32.const 0
      i32.const 160
      i32.const 160
      i32.const 0xFFFFFFFF
      i32.const 0xFFF04F65
      i32.const 0xFF0000FF
      i32.const 0x00000000
      i32.const 0x00000000
      i32.const 102400
      call $render_color_indexed_sprite
    end
    global.get $countup
    i32.const 179
    i32.lt_s
    if
      global.get $countup
      i32.const 1
      i32.add
      global.set $countup
    else
      i32.const 0
      global.set $countup
      i32.const 1
      global.set $scene_index
    end    
  )

  (func $scene_maze_select (local $i i32)
      global.get $maze_selected
      i32.const 0
      i32.eq
      if
        i32.const 0x97
        i32.const 0x81
        i32.const 0xF0
        call $rgb_fill_screen
        ;; render maze select buttons
        loop $loop
          ;; button_x
          i32.const 16
          local.get $i
          i32.const 3
          i32.rem_s
          i32.const 48
          i32.mul
          i32.add
          ;; button_y
          i32.const 16
          local.get $i
          f32.convert_i32_s
          i32.const 3
          f32.convert_i32_s
          f32.div
          f32.floor
          i32.trunc_f32_s
          i32.const 48
          i32.mul
          i32.add
          ;; button_size
          i32.const 32
          i32.const 32
          i32.const 0xFFF04F65
          i32.const 0xFF00FFFF
          i32.const 0x00000000
          i32.const 0x00000000
          i32.const 0x00000000
          i32.const 135360          
          call $render_color_indexed_sprite
          ;; number_x
          i32.const 24
          local.get $i
          i32.const 3
          i32.rem_s
          i32.const 48
          i32.mul
          i32.add
          ;; number_y
          i32.const 24
          local.get $i
          f32.convert_i32_s
          i32.const 3
          f32.convert_i32_s
          f32.div
          f32.floor
          i32.trunc_f32_s
          i32.const 48
          i32.mul
          i32.add
          ;; number_size
          i32.const 16
          i32.const 16
          i32.const 0xFF0000FF
          i32.const 0x00000000
          i32.const 0x00000000
          i32.const 0x00000000
          i32.const 0x00000000
          i32.const 136384
          local.get $i
          i32.const 256
          i32.mul
          i32.add
          call $render_color_indexed_sprite
          ;; trophy (only renders if the maze was cleared)
          i32.const 141312
          local.get $i
          i32.add
          i32.load8_u
          i32.const 1
          i32.eq
          if
            i32.const 39
            local.get $i
            i32.const 3
            i32.rem_s
            i32.const 48
            i32.mul
            i32.add
            i32.const 39
            local.get $i
            f32.convert_i32_s
            i32.const 3
            f32.convert_i32_s
            f32.div
            f32.floor
            i32.trunc_f32_s
            i32.const 48
            i32.mul
            i32.add
            i32.const 8
            i32.const 8
            i32.const 0xFFF04F65
            i32.const 0x00000000
            i32.const 0x00000000
            i32.const 0x00000000
            i32.const 0x00000000
            i32.const 138688 
            call $render_color_indexed_sprite
          end
          ;; check col
          ;; pointer
          i32.const 144942
          i32.load8_u
          i32.const 144943
          i32.load8_u
          i32.const 1
          ;; button_x
          i32.const 16
          local.get $i
          i32.const 3
          i32.rem_s
          i32.const 48
          i32.mul
          i32.add
          ;; button_y
          i32.const 16
          local.get $i
          f32.convert_i32_s
          i32.const 3
          f32.convert_i32_s
          f32.div
          f32.floor
          i32.trunc_f32_s
          i32.const 48
          i32.mul
          i32.add
          ;; button_size
          i32.const 32
          call $square_collision
          i32.const 1
          i32.eq
          if
            local.get $i
            i32.const 8
            i32.eq
            if ;; TODO make maze_maker_scene
              i32.const 3
              global.set $scene_index
            else
              ;; normal modes
              i32.const 1
              global.set $maze_init
          
              local.get $i
              global.set $maze_index ;; set the maze index
              i32.const 1
              global.set $maze_selected

              ;; Check to see if player is lucky
              global.get $timer_60
              i32.const 56 ;; player will have a 5% chance to be lucky
              i32.ge_s
              if
                i32.const 1
                global.set $player_lucky
              else
                i32.const 0
                global.set $player_lucky
              end

              ;; TODO: set player x and y depending on maze
              local.get $i
              i32.const 0
              i32.eq
              if
                i32.const 16
                global.set $player_x
                i32.const 16 
                global.set $player_y
              end

              local.get $i
              i32.const 1
              i32.eq
              if
                i32.const 288
                global.set $player_x
                i32.const 288
                global.set $player_y
              end

              local.get $i
              i32.const 2
              i32.eq
              if
                i32.const 152
                global.set $player_x
                i32.const 152 
                global.set $player_y
              end

              local.get $i
              i32.const 3
              i32.eq
              if
                i32.const 16
                global.set $player_x
                i32.const 16 
                global.set $player_y
              end

              local.get $i
              i32.const 4
              i32.eq
              if
                i32.const 16
                global.set $player_x
                i32.const 16 
                global.set $player_y
              end

              local.get $i
              i32.const 5
              i32.eq
              if
                i32.const 16
                global.set $player_x
                i32.const 272 
                global.set $player_y
              end

              local.get $i
              i32.const 6
              i32.eq
              if
                i32.const 16
                global.set $player_x
                i32.const 16 
                global.set $player_y
              end

              local.get $i
              i32.const 7
              i32.eq
              if
                i32.const 16
                global.set $player_x
                i32.const 16 
                global.set $player_y
              end
            end
          end
          ;; increment by 1
          local.get $i
          i32.const 1
          i32.add
          local.set $i
          local.get $i
          i32.const 9 ;; 9 buttons are needed
          i32.lt_s
          br_if $loop
        end
      else
        ;; for when maze selected
        global.get $countup
        i32.const 59
	    i32.lt_s
        if
          i32.const 0x3B
          global.get $countup
          i32.sub
          i32.const 0x3B
          global.get $countup
          i32.sub
          i32.const 0x3B
          call $rgb_fill_screen
          ;; button_x
          i32.const 16
          global.get $maze_index
          i32.const 3
          i32.rem_s
          i32.const 48
          i32.mul
          i32.add
          ;; button_y
          i32.const 16
          global.get $maze_index
          f32.convert_i32_s
          i32.const 3
          f32.convert_i32_s
          f32.div
          f32.floor
          i32.trunc_f32_s
          i32.const 48
          i32.mul
          i32.add
          ;; button_size
          i32.const 32
          i32.const 32
          i32.const 0xFFF04F65
          i32.const 0xFF00FFFF
          i32.const 0x00000000
          i32.const 0x00000000
          i32.const 0x00000000
          i32.const 135360
          call $render_color_indexed_sprite          
          ;; number
          i32.const 24
          global.get $maze_index
          i32.const 3
          i32.rem_s
          i32.const 48
          i32.mul
          i32.add
          i32.const 24
          global.get $maze_index
          f32.convert_i32_s
          i32.const 3
          f32.convert_i32_s
          f32.div
          f32.floor
          i32.trunc_f32_s
          i32.const 48
          i32.mul
          i32.add
          i32.const 16
          i32.const 16
          i32.const 0xFF0000FF
          i32.const 0x00000000
          i32.const 0x00000000
          i32.const 0x00000000
          i32.const 0x00000000
          i32.const 136384
          global.get $maze_index
          i32.const 256
          i32.mul
          i32.add
          call $render_color_indexed_sprite
          ;; trophy (only renders if the maze was cleared)
          i32.const 141312
          global.get $maze_index
          i32.add
          i32.load8_u
          i32.const 1
          i32.eq
          if
            i32.const 39
            global.get $maze_index
            i32.const 3
            i32.rem_s
            i32.const 48
            i32.mul
            i32.add
            i32.const 39
            global.get $maze_index
            f32.convert_i32_s
            i32.const 3
            f32.convert_i32_s
            f32.div
            f32.floor
            i32.trunc_f32_s
            i32.const 48
            i32.mul
            i32.add
            i32.const 8
            i32.const 8
            i32.const 0xFFF04F65
            i32.const 0x00000000
            i32.const 0x00000000
            i32.const 0x00000000
            i32.const 0x00000000
            i32.const 138688             
            call $render_color_indexed_sprite
          end
          global.get $countup
          i32.const 1
          i32.add
          global.set $countup
        else
          i32.const 0
          global.set $maze_selected
          i32.const 2 ;; go to game scene
          global.set $scene_index
	      i32.const 0
	      global.set $countup
	      i32.const 2
	      global.set $scene_index
        end
      end
  )
 
  (func $scene_game
    (local $mask_copy i32)
    (local $value_copy i32)
    ;; check to see if maze cleared
    global.get $maze_cleared
    i32.const 1
    i32.eq
    if
    i32.const 0xFF
    i32.const 0xFF
    i32.const 0xFF
    call $rgb_fill_screen
    ;; if maze cleared just show the you win modal
    i32.const 40      ;; dx
    i32.const 64      ;; dy
    i32.const 80      ;; dw
    i32.const 32      ;; dh
    i32.const 0xFF000080
    i32.const 0xFF008000
    global.get $timer_30
    i32.const 9
    i32.lt_s
    select
    i32.const 0xFF800000
    global.get $timer_30
    i32.const 19
    i32.lt_s
    select ;; color_01
    i32.const 0xFF0000FF   ;; color_02
    i32.const 0xFFFF0000   ;; color_03
    i32.const 0x00000000   ;; color_04
    i32.const 0x00000000   ;; color_05
    i32.const 138752       ;; data_address
    call $render_color_indexed_sprite
    ;; 3 sound switcher
    global.get $timer_30
    i32.const 9
    i32.lt_s
    if
    global.get $timer_cooldown_15
    i32.const 0
    i32.eq
    if
    i32.const 9
    global.set $timer_cooldown_15
    i32.const 144923
    i32.load16_u
    call $play_data_sound
    end
    else
    global.get $timer_30
    i32.const 19
    i32.lt_s
    if
    global.get $timer_cooldown_15
    i32.const 0
    i32.eq
    if
    i32.const 9
    global.set $timer_cooldown_15
    i32.const 144925
    i32.load16_u
    call $play_data_sound
    end
    else
    global.get $timer_cooldown_15
    i32.const 0
    i32.eq
    if
    i32.const 9
    global.set $timer_cooldown_15
    i32.const 144927
    i32.load16_u
    call $play_data_sound
    end
    end
    end    
    ;; increment $countup if less than 179
    global.get $countup
    i32.const 179
    i32.lt_s
    if
    global.get $countup
    i32.const 1
    i32.add
    global.set $countup
    else
    i32.const 0
    global.set $maze_cleared
    i32.const 0
    global.set $countup
    i32.const 1
    global.set $scene_index
    end
    else
    i32.const 0xDF
    i32.const 0xFF
    i32.const 0xDF
    call $rgb_fill_screen

    call $render_map

    ;; render player
    global.get $timer_30
    i32.const 14
    i32.lt_s
    if
      i32.const 72 ;; cam_x
      i32.const 72 ;; cam_y
      i32.const 16
      i32.const 16
      call $check_for_lucky
      i32.const 0xFF0000FF
      i32.const 0x00000000
      i32.const 129792
      global.get $player_mode
      i32.const 512
      i32.mul
      i32.add
      call $render_color_indexed_sprite
    else
      i32.const 72 ;; cam_x
      i32.const 72 ;; cam_y
      i32.const 16
      i32.const 16
      call $check_for_lucky
      i32.const 0xFF0000FF
      i32.const 0x00000000
      i32.const 130048 
      global.get $player_mode
      i32.const 512
      i32.mul
      i32.add
      call $render_color_indexed_sprite
    end

    i32.const 144944
    i32.load8_u
    i32.const 1
    i32.eq
    if
    i32.const 0
    i32.const 0
    i32.const 8
    i32.const 8
    i32.const 0xFF0000FF
    i32.const 0xFFFFFFFF
    i32.const 0x00000000
    i32.const 0x00000000
    i32.const 0x00000000
    i32.const 133312 
    call $render_color_indexed_sprite
    end

    i32.const 144945
    i32.load8_u
    i32.const 1
    i32.eq
    if
    i32.const 8
    i32.const 0
    i32.const 8
    i32.const 8
    i32.const 0xFF008000
    i32.const 0xFFFFFFFF
    i32.const 0x00000000
    i32.const 0x00000000
    i32.const 0x00000000
    i32.const 133312 
    call $render_color_indexed_sprite
    end

    i32.const 144946
    i32.load8_u
    i32.const 1
    i32.eq
    if
    i32.const 16
    i32.const 0
    i32.const 8
    i32.const 8
    i32.const 0xFFFF0000
    i32.const 0xFFFFFFFF
    i32.const 0x00000000
    i32.const 0x00000000
    i32.const 0x00000000
    i32.const 133312 
    call $render_color_indexed_sprite
    end
    ;; update player pos
    i32.const 144942
    i32.load8_u
    i32.const 255
    i32.ne
    if
    i32.const 144943
    i32.load8_u
    i32.const 80 ;; half of the screen 
    i32.sub
    ;; i32_abs_inline_function        
    ;; --- INLINED i32_abs (Bitwise Trick) ---
    local.tee $value_copy  ;; Stack: [..., -10, -10]. Saves a copy to a local $value_copy
    i32.const 31           ;; Stack: [..., -10, 31]
    i32.shr_s              ;; Stack: [..., mask] (mask = -1 for -10)
    local.tee $mask_copy   ;; Stack: [..., mask, mask]. Saves mask to a local $mask_copy
    local.get $value_copy  ;; Stack: [..., mask, mask, -10]
    i32.xor                ;; Stack: [..., mask, (value XOR mask)]
    local.get $mask_copy   ;; Stack: [..., (value XOR mask), mask]
    i32.sub                ;; Stack: [..., ABS(value)] ((value XOR mask) - mask)

    i32.const 144942
    i32.load8_u
    i32.const 80 ;; half of the screen 
    i32.sub
    ;; --- INLINED i32_abs (Bitwise Trick) ---
    local.tee $value_copy  ;; Stack: [..., -10, -10]. Saves a copy to a local $value_copy
    i32.const 31           ;; Stack: [..., -10, 31]
    i32.shr_s              ;; Stack: [..., mask] (mask = -1 for -10)
    local.tee $mask_copy   ;; Stack: [..., mask, mask]. Saves mask to a local $mask_copy
    local.get $value_copy  ;; Stack: [..., mask, mask, -10]
    i32.xor                ;; Stack: [..., mask, (value XOR mask)]
    local.get $mask_copy   ;; Stack: [..., (value XOR mask), mask]

    i32.sub                ;; Stack: [..., ABS(value)] ((value XOR mask) - mask)
    i32.gt_s
    if
    i32.const 144943
    i32.load8_u
    i32.const 72 ;; cam_y
    i32.lt_s
    if
    global.get $player_y
    i32.const 1
    i32.sub
    global.set $player_y
    ;; up
    i32.const 1
    global.set $player_mode
    else
    global.get $player_y
    i32.const 1
    i32.add
    global.set $player_y
    ;; down
    i32.const 2
    global.set $player_mode
    end
    else
    i32.const 144942
    i32.load8_u 
    i32.const 72 ;; cam_x
    i32.lt_s
    if
    global.get $player_x
    i32.const 1
    i32.sub
    global.set $player_x
    ;; left
    i32.const 3
    global.set $player_mode
    else
    global.get $player_x
    i32.const 1
    i32.add
    global.set $player_x
    ;; right
    i32.const 4
    global.set $player_mode
    end
    end
    else
    i32.const 0
    global.set $player_mode ;; idle
    end
    ;; check for solids etc
    call $collision_checks
    end
    ;; just a fade in
    global.get $maze_init
    i32.const 1
    i32.eq
    if
    global.get $countup
    global.get $countup
    i32.const 0x3B
    call $rgb_fill_screen

    global.get $countup
    i32.const 59
    i32.gt_s
    if
    i32.const 0
    global.set $maze_init
    else
    global.get $countup
    i32.const 1
    i32.add
    global.set $countup
    end
    end
  )

  (func $scene_maze_maker
    i32.const 0xFF
    i32.const 0xFF
    i32.const 0xFF
    call $rgb_fill_screen

    ;; close button
    i32.const 0x00000000 ;; dx
    i32.const 0x00000000 ;; dy
    i32.const 0x00000010 ;; dw
    i32.const 0x00000010 ;; dh
    i32.const 0xFF0000FF ;; color_01
    i32.const 0xFFFFFFFF ;; color_02
    i32.const 0xFF000000 ;; color_03
    i32.const 0xFF000000 ;; color_04
    i32.const 0xFF000000 ;; color_05
    i32.const 144947     ;; memory_address
    call $render_color_indexed_sprite

    ;; map_background
    call $render_maze_maker_map_background

    ;; up arrow
    i32.const 0x00000038 ;; dx
    i32.const 0x00000008 ;; dy
    i32.const 0x00000010 ;; dw
    i32.const 0x00000010 ;; dh
    i32.const 0xFF000000 ;; color_01
    i32.const 0xFF00FF00 ;; color_02
    i32.const 0xFF000000 ;; color_03
    i32.const 0xFF000000 ;; color_04
    i32.const 0xFF000000 ;; color_05
    i32.const 128512     ;; memory_address
    call $render_color_indexed_sprite
    ;; down arrow
    i32.const 0x00000038 ;; dx
    i32.const 0x00000068 ;; dy
    i32.const 0x00000010 ;; dw
    i32.const 0x00000010 ;; dh
    i32.const 0xFF000000 ;; color_01
    i32.const 0xFF00FF00 ;; color_02
    i32.const 0xFF000000 ;; color_03
    i32.const 0xFF000000 ;; color_04
    i32.const 0xFF000000 ;; color_05
    i32.const 128768     ;; memory_address
    call $render_color_indexed_sprite
    ;; left arrow
    i32.const 0x00000008 ;; dx
    i32.const 0x00000038 ;; dy
    i32.const 0x00000010 ;; dw
    i32.const 0x00000010 ;; dh
    i32.const 0xFF000000 ;; color_01
    i32.const 0xFF00FF00 ;; color_02
    i32.const 0xFF000000 ;; color_03
    i32.const 0xFF000000 ;; color_04
    i32.const 0xFF000000 ;; color_05
    i32.const 129024     ;; memory_address
    call $render_color_indexed_sprite
    ;; right arrow
    i32.const 0x00000068 ;; dx
    i32.const 0x00000038 ;; dy
    i32.const 0x00000010 ;; dw
    i32.const 0x00000010 ;; dh
    i32.const 0xFF000000 ;; color_01
    i32.const 0xFF00FF00 ;; color_02
    i32.const 0xFF000000 ;; color_03
    i32.const 0xFF000000 ;; color_04
    i32.const 0xFF000000 ;; color_05
    i32.const 129280     ;; memory_address
    call $render_color_indexed_sprite
    ;; todo: make a representation of erase

    ;; sweet_rock
    i32.const 0x00000088 ;; dx
    i32.const 0x00000008 ;; dy
    i32.const 0x00000010 ;; dw
    i32.const 0x00000010 ;; dh
    i32.const 0xFF000000 ;; color_01
    i32.const 0xFFF5F5FF ;; color_02
    i32.const 0xFF0000FF ;; color_03
    i32.const 0xFFF04F65 ;; color_04
    i32.const 0xFF9CE1FF ;; color_05
    i32.const 129536     ;; memory_address
    call $render_color_indexed_sprite

    ;; player_idle
    i32.const 0x00000078 ;; dx
    i32.const 0x00000018 ;; dy
    i32.const 0x00000010 ;; dw
    i32.const 0x00000010 ;; dh
    i32.const 0xFF000000 ;; color_01
    i32.const 0xFFF04F65 ;; color_02
    i32.const 0xFFFFFFFF ;; color_03
    i32.const 0xFF0000FF ;; color_04
    i32.const 0x00000000 ;; color_05
    i32.const 130048     ;; memory_address
    call $render_color_indexed_sprite

    ;; wasm_block
    i32.const 0x00000088 ;; dx
    i32.const 0x00000018 ;; dy
    i32.const 0x00000010 ;; dw
    i32.const 0x00000010 ;; dh
    i32.const 0xFFF04F65 ;; color_01
    i32.const 0xFFF5F5FF ;; color_02
    i32.const 0xFFFFFFFF ;; color_03
    i32.const 0x00000000 ;; color_04
    i32.const 0x00000000 ;; color_05
    i32.const 132352     ;; memory_address
    call $render_color_indexed_sprite

    ;; key_red
    i32.const 0x00000078 ;; dx
    i32.const 0x00000050 ;; dy
    i32.const 0x00000010 ;; dw
    i32.const 0x00000010 ;; dh
    i32.const 0xFF0000FF ;; color_01
    i32.const 0xFFFFFFFF ;; color_02
    i32.const 0x00000000 ;; color_03
    i32.const 0x00000000 ;; color_04
    i32.const 0x00000000 ;; color_05
    i32.const 132608     ;; memory_address
    call $render_color_indexed_sprite

    ;; lock_red
    i32.const 0x00000088 ;; dx
    i32.const 0x00000050 ;; dy
    i32.const 0x00000010 ;; dw
    i32.const 0x00000010 ;; dh
    i32.const 0xFF0000FF ;; color_01
    i32.const 0xFF00FFFF ;; color_02
    i32.const 0x00000000 ;; color_03
    i32.const 0x00000000 ;; color_04
    i32.const 0x00000000 ;; color_05
    i32.const 132864     ;; memory_address
    call $render_color_indexed_sprite

    ;; key_green
    i32.const 0x00000078 ;; dx
    i32.const 0x00000060 ;; dy
    i32.const 0x00000010 ;; dw
    i32.const 0x00000010 ;; dh
    i32.const 0xFF008000 ;; color_01
    i32.const 0xFFFFFFFF ;; color_02
    i32.const 0x00000000 ;; color_03
    i32.const 0x00000000 ;; color_04
    i32.const 0x00000000 ;; color_05
    i32.const 132608     ;; memory_address
    call $render_color_indexed_sprite

    ;; lock_green
    i32.const 0x00000088 ;; dx
    i32.const 0x00000060 ;; dy
    i32.const 0x00000010 ;; dw
    i32.const 0x00000010 ;; dh
    i32.const 0xFF008000 ;; color_01
    i32.const 0xFF00FFFF ;; color_02
    i32.const 0x00000000 ;; color_03
    i32.const 0x00000000 ;; color_04
    i32.const 0x00000000 ;; color_05
    i32.const 132864     ;; memory_address
    call $render_color_indexed_sprite

    ;; key_blue
    i32.const 0x00000078 ;; dx
    i32.const 0x00000070 ;; dy
    i32.const 0x00000010 ;; dw
    i32.const 0x00000010 ;; dh
    i32.const 0xFFFF0000 ;; color_01
    i32.const 0xFFFFFFFF ;; color_02
    i32.const 0x00000000 ;; color_03
    i32.const 0x00000000 ;; color_04
    i32.const 0x00000000 ;; color_05
    i32.const 132608     ;; memory_address
    call $render_color_indexed_sprite

    ;; lock_blue
    i32.const 0x00000088 ;; dx
    i32.const 0x00000070 ;; dy
    i32.const 0x00000010 ;; dw
    i32.const 0x00000010 ;; dh
    i32.const 0xFFFF0000 ;; color_01
    i32.const 0xFF00FFFF ;; color_02
    i32.const 0x00000000 ;; color_03
    i32.const 0x00000000 ;; color_04
    i32.const 0x00000000 ;; color_05
    i32.const 132864     ;; memory_address
    call $render_color_indexed_sprite

    ;; maze_maker_play_button
    i32.const 0x00000008 ;; dx
    i32.const 0x00000088 ;; dy
    i32.const 0x00000028 ;; dw
    i32.const 0x00000010 ;; dh
    i32.const 0xFF808080 ;; color_01
    i32.const 0xFFFFFFFF ;; color_02
    i32.const 0x00000000 ;; color_03
    i32.const 0x00000000 ;; color_04
    i32.const 0x00000000 ;; color_05
    i32.const 133440     ;; memory_address
    call $render_color_indexed_sprite

    ;; maze_maker_load_button
    i32.const 0x0000003C ;; dx
    i32.const 0x00000088 ;; dy
    i32.const 0x00000028 ;; dw
    i32.const 0x00000010 ;; dh
    i32.const 0xFF808080 ;; color_01
    i32.const 0xFFFFFFFF ;; color_02
    i32.const 0x00000000 ;; color_03
    i32.const 0x00000000 ;; color_04
    i32.const 0x00000000 ;; color_05
    i32.const 134080     ;; memory_address
    call $render_color_indexed_sprite

    ;; maze_maker_share_button
    i32.const 0x00000070 ;; dx
    i32.const 0x00000088 ;; dy
    i32.const 0x00000028 ;; dw
    i32.const 0x00000010 ;; dh
    i32.const 0xFF808080 ;; color_01
    i32.const 0xFFFFFFFF ;; color_02
    i32.const 0x00000000 ;; color_03
    i32.const 0x00000000 ;; color_04
    i32.const 0x00000000 ;; color_05
    i32.const 0x00020E40 ;; memory_address
    call $render_color_indexed_sprite

    ;; todo: make a better way to show maze_maker_selected_indicator
    i32.const 0x00000088 ;; dx
    i32.const 0x00000008 ;; dy
    i32.const 0x00000010 ;; dw
    i32.const 0x00000010 ;; dh
    i32.const 0xFF0000FF
    i32.const 0xFF000080
    global.get $timer_60
    i32.const 0x0000001D
    i32.lt_s
    select               ;; color_01
    i32.const 0x00000000 ;; color_02
    i32.const 0x00000000 ;; color_03
    i32.const 0x00000000 ;; color_04
    i32.const 0x00000000 ;; color_05
    i32.const 0x00023733 ;; memory_address
    call $render_color_indexed_sprite

    ;; todo: make a better way to exit maze edit mode
    i32.const 144942
    i32.load8_u
    i32.const 16
    i32.lt_s
    if
      i32.const 144943
      i32.load8_u
      i32.const 16
      i32.lt_s
      if
        i32.const 1 ;; go back to scene_maze_select
        global.set $scene_index
      end
    end
  )

  ;; game loop
  (func (export "game_loop")  
    (local $i i32)

    global.get $scene_index
	i32.const 0
	i32.eq
	if
      call $scene_title
	end

    global.get $scene_index
	i32.const 1
	i32.eq
	if
     call $scene_maze_select
    end

    global.get $scene_index
	i32.const 2
	i32.eq
	if
      call $scene_game
	end

    global.get $scene_index
	i32.const 3
	i32.eq
	if
      call $scene_maze_maker
	end

    call $render_pointer

    ;; todo work on timers
    global.get $timer_30
    i32.const 29
    i32.lt_s
    if
      global.get $timer_30
      i32.const 1
      i32.add
      global.set $timer_30
    else
      i32.const 0
      global.set $timer_30
    end

    global.get $timer_60
    i32.const 59
    i32.lt_s
    if
      global.get $timer_60
      i32.const 1
      i32.add
      global.set $timer_60
    else
      i32.const 0
      global.set $timer_60
    end

    ;; TODO: change timers to memory only
    i32.const 144749 ;; timer_256
    i32.const 144749
    i32.load8_u
    i32.const 4
    i32.add
    i32.store8

    global.get $timer_cooldown_15
    i32.const 0
    i32.gt_s
    if
      global.get $timer_cooldown_15
      i32.const 1
      i32.sub
      global.set $timer_cooldown_15
    end
  )

  (data (i32.const 0x00019000)
    ;; 102400 | title_160x160 = 25600 bytes      
    "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01"
    "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01"
    "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01"
    "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01"
    "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01"
    "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01"
    "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01"
    "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01"
    "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01"
    "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01"
    "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01"
    "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01"
    "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01"
    "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01"
    "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01"
    "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01"
     
    "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01"
    "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01"
    "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01"
    "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01"
    "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01"
    "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01"
    "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01"
    "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01"
    "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01"
    "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01"
    "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01"
    "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01"
    "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01"
    "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01"
    "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01"
    "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01"

    "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01"      
    "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" 
    "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01"
    "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01"
    "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01"
    "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01"
    "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01"
    "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01"
    "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01"
    "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01"
    "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01"
    "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01"
    "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01"
    "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01"
    "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01"
    "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01"

    "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01"     
    "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01"
    "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01"
    "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01"
    "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01"
    "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01"
    "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\02\02\02\01\01\01\01" "\01\01\01\02\02\02\01\01\01\01\01\01\01\02\02\02" "\01\01\01\01\01\01\01\02\02\02\02\02\01\01\01\01" "\01\01\01\01\01\01\02\02\02\02\02\02\02\02\02\02" "\01\01\01\01\01\01\02\02\02\01\01\01\01\01\01\01" "\01\01\02\02\02\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01"
    "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\02\02\02\02\02\01\01\01" "\01\01\02\02\02\02\02\01\01\01\01\01\02\02\02\02" "\02\01\01\01\01\01\02\02\02\02\02\02\02\01\01\01" "\01\01\01\01\01\02\02\02\02\02\02\02\02\02\02\02" "\02\01\01\01\01\02\02\02\02\02\01\01\01\01\01\01" "\01\02\02\02\02\02\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01"
    "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\02\02\02\02\02\01\01\01" "\01\01\02\02\02\02\02\01\01\01\01\01\02\02\02\02" "\02\01\01\01\01\01\02\02\02\02\02\02\02\01\01\01" "\01\01\01\01\02\02\02\02\02\02\02\02\02\02\02\02" "\02\01\01\01\01\02\02\02\02\02\01\01\01\01\01\01" "\01\02\02\02\02\02\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01"
    "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\02\02\02\02\02\01\01\01" "\01\02\02\02\02\02\02\02\01\01\01\01\02\02\02\02" "\02\01\01\01\01\01\02\02\02\02\02\02\02\01\01\01" "\01\01\01\01\02\02\02\02\02\02\02\02\02\02\02\02" "\02\01\01\01\01\02\02\02\02\02\02\01\01\01\01\01" "\01\02\02\02\02\02\02\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01"
    "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\02\02\02\02\02\01\01" "\01\02\02\02\02\02\02\02\01\01\01\01\02\02\02\02" "\02\01\01\01\01\02\02\02\02\02\02\02\02\02\01\01" "\01\01\01\02\02\02\02\02\02\02\02\02\02\02\02\02" "\01\01\01\01\02\02\02\02\02\02\02\01\01\01\01\01" "\02\02\02\02\02\02\02\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01"
    "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\02\02\02\02\02\01\01" "\01\02\02\02\02\02\02\02\01\01\01\02\02\02\02\02" "\01\01\01\01\01\02\02\02\02\02\02\02\02\02\01\01" "\01\01\01\02\02\02\02\02\02\01\01\01\01\01\01\01" "\01\01\01\01\02\02\02\02\02\02\02\01\01\01\01\01" "\02\02\02\02\02\02\02\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01"
    "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\02\02\02\02\02\01\01" "\01\02\02\02\02\02\02\02\02\01\01\02\02\02\02\02" "\01\01\01\01\01\02\02\02\02\01\02\02\02\02\01\01" "\01\01\01\02\02\02\02\02\01\01\01\01\01\01\01\01" "\01\01\01\01\02\02\02\02\02\02\02\02\01\01\01\01" "\02\02\02\02\02\02\02\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01"
    "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\02\02\02\02\02\01\01" "\02\02\02\02\02\02\02\02\02\01\01\02\02\02\02\02" "\01\01\01\01\02\02\02\02\02\01\02\02\02\02\02\01" "\01\01\01\02\02\02\02\02\02\01\01\01\01\01\01\01" "\01\01\01\01\02\02\02\02\02\02\02\02\01\01\01\02" "\02\02\02\02\02\02\02\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01"
    "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\02\02\02\02\01\01" "\02\02\02\02\01\02\02\02\02\01\01\02\02\02\02\02" "\01\01\01\01\02\02\02\02\02\01\02\02\02\02\02\01" "\01\01\01\02\02\02\02\02\02\02\02\02\02\02\01\01" "\01\01\01\01\02\02\02\02\02\02\02\02\01\01\01\02" "\02\02\02\02\02\02\02\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01"
    "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\02\02\02\02\02\01" "\02\02\02\02\01\02\02\02\02\01\02\02\02\02\02\01" "\01\01\01\01\02\02\02\02\01\01\01\02\02\02\02\01" "\01\01\01\01\02\02\02\02\02\02\02\02\02\02\02\01" "\01\01\01\01\02\02\02\02\02\02\02\02\01\01\01\02" "\02\02\02\02\02\02\02\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01"
      
    "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\02\02\02\02\02\02" "\02\02\02\02\01\02\02\02\02\02\02\02\02\02\02\01" "\01\01\01\02\02\02\02\02\01\01\01\02\02\02\02\02" "\01\01\01\01\01\02\02\02\02\02\02\02\02\02\02\02" "\01\01\01\01\02\02\02\02\01\02\02\02\02\01\02\02" "\02\02\01\02\02\02\02\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01"
    "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\02\02\02\02\02\02" "\02\02\02\01\01\01\02\02\02\02\02\02\02\02\02\01" "\01\01\01\02\02\02\02\02\01\01\01\02\02\02\02\02" "\01\01\01\01\01\01\02\02\02\02\02\02\02\02\02\02" "\02\01\01\01\02\02\02\02\01\02\02\02\02\01\02\02" "\02\02\01\02\02\02\02\02\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01"
    "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\02\02\02\02\02\02" "\02\02\02\01\01\01\02\02\02\02\02\02\02\02\02\01" "\01\01\01\02\02\02\02\02\02\02\02\02\02\02\02\02" "\01\01\01\01\01\01\01\01\01\01\01\01\02\02\02\02" "\02\01\01\02\02\02\02\02\01\02\02\02\02\01\02\02" "\02\02\01\02\02\02\02\02\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01"
    "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\02\02\02\02\02" "\02\02\02\01\01\01\02\02\02\02\02\02\02\02\01\01" "\01\01\01\02\02\02\02\02\02\02\02\02\02\02\02\02" "\02\01\01\01\01\01\01\01\01\01\01\01\01\02\02\02" "\02\01\01\02\02\02\02\02\01\01\02\02\02\02\02\02" "\02\01\01\02\02\02\02\02\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01"
    "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\02\02\02\02\02" "\02\02\02\01\01\01\01\02\02\02\02\02\02\02\01\01" "\01\01\02\02\02\02\02\02\02\02\02\02\02\02\02\02" "\02\01\01\01\01\01\01\01\01\01\01\01\02\02\02\02" "\02\01\01\02\02\02\02\02\01\01\02\02\02\02\02\02" "\02\01\01\02\02\02\02\02\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01"
    "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\02\02\02\02\02" "\02\02\01\01\01\01\01\02\02\02\02\02\02\02\01\01" "\01\01\02\02\02\02\02\02\02\02\02\02\02\02\02\02" "\02\01\01\01\01\02\02\02\02\02\02\02\02\02\02\02" "\02\01\01\02\02\02\02\02\01\01\02\02\02\02\02\02" "\02\01\01\02\02\02\02\02\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01"
    "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\02\02\02\02\02" "\02\02\01\01\01\01\01\02\02\02\02\02\02\02\01\01" "\01\01\02\02\02\02\02\01\01\01\01\01\02\02\02\02" "\02\02\01\01\02\02\02\02\02\02\02\02\02\02\02\02" "\02\01\01\02\02\02\02\02\01\01\02\02\02\02\02\02" "\02\01\01\02\02\02\02\02\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01"
    "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\02\02\02\02" "\02\02\01\01\01\01\01\02\02\02\02\02\02\01\01\01" "\01\02\02\02\02\02\01\01\01\01\01\01\01\02\02\02" "\02\02\01\01\02\02\02\02\02\02\02\02\02\02\02\02" "\01\01\01\02\02\02\02\02\01\01\01\02\02\02\02\02" "\01\01\01\02\02\02\02\02\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01"
    "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\02\02\02\02" "\02\01\01\01\01\01\01\01\02\02\02\02\02\01\01\01" "\01\02\02\02\02\02\01\01\01\01\01\01\01\02\02\02" "\02\02\01\01\02\02\02\02\02\02\02\02\02\02\02\01" "\01\01\01\02\02\02\02\02\01\01\01\02\02\02\02\02" "\01\01\01\02\02\02\02\02\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" 
    "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\02\02\02" "\01\01\01\01\01\01\01\01\01\02\02\02\01\01\01\01" "\01\01\02\02\02\01\01\01\01\01\01\01\01\01\02\02" "\02\01\01\01\01\02\02\02\02\02\02\02\02\02\01\01" "\01\01\01\01\02\02\02\01\01\01\01\01\02\02\02\01" "\01\01\01\01\02\02\02\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01"
    "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01"
    "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01"
    "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01"
    "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01"
    "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01"
    "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01"
      
    "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" 
    "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01"
    "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01"
    "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01"
    "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01"
    "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01"
    "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\02\02\02\01\01\01\01\01\01\01\01\01\02\02\02" "\01\01\01\01\01\01\01\01\01\01\02\02\02\02\02\01" "\01\01\01\01\01\01\01\02\02\02\02\02\02\02\02\02" "\02\02\02\01\01\01\01\01\01\02\02\02\02\02\02\02" "\02\02\02\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01"
    "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\02\02\02\02\02\01\01\01\01\01\01\01\02\02\02\02" "\02\01\01\01\01\01\01\01\01\02\02\02\02\02\02\02" "\01\01\01\01\01\01\02\02\02\02\02\02\02\02\02\02" "\02\02\02\02\01\01\01\02\02\02\02\02\02\02\02\02" "\02\02\02\02\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01"
    "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\02\02\02\02\02\01\01\01\01\01\01\01\02\02\02\02" "\02\01\01\01\01\01\01\01\01\02\02\02\02\02\02\02" "\01\01\01\01\01\01\02\02\02\02\02\02\02\02\02\02" "\02\02\02\02\01\01\02\02\02\02\02\02\02\02\02\02" "\02\02\02\02\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01"
    "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\02\02\02\02\02\02\01\01\01\01\01\01\02\02\02\02" "\02\02\01\01\01\01\01\01\01\02\02\02\02\02\02\02" "\01\01\01\01\01\01\02\02\02\02\02\02\02\02\02\02" "\02\02\02\02\01\01\02\02\02\02\02\02\02\02\02\02" "\02\02\02\02\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01"
    "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\02" "\02\02\02\02\02\02\01\01\01\01\01\02\02\02\02\02" "\02\02\01\01\01\01\01\01\02\02\02\02\02\02\02\02" "\02\01\01\01\01\01\01\02\02\02\02\02\02\02\02\02" "\02\02\02\02\01\01\02\02\02\02\02\02\02\02\02\02" "\02\02\02\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01"
    "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\02" "\02\02\02\02\02\02\01\01\01\01\01\02\02\02\02\02" "\02\02\01\01\01\01\01\01\02\02\02\02\02\02\02\02" "\02\01\01\01\01\01\01\01\01\01\01\01\01\02\02\02" "\02\02\02\01\01\01\02\02\02\02\02\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01"
    "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\02" "\02\02\02\02\02\02\02\01\01\01\01\02\02\02\02\02" "\02\02\01\01\01\01\01\01\02\02\02\02\01\02\02\02" "\02\01\01\01\01\01\01\01\01\01\01\01\01\02\02\02" "\02\02\01\01\01\01\02\02\02\02\02\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01"
    "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\02" "\02\02\02\02\02\02\02\01\01\01\02\02\02\02\02\02" "\02\02\01\01\01\01\01\02\02\02\02\02\01\02\02\02" "\02\02\01\01\01\01\01\01\01\01\01\01\02\02\02\02" "\02\02\01\01\01\01\02\02\02\02\02\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01"
    "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\02" "\02\02\02\02\02\02\02\01\01\01\02\02\02\02\02\02" "\02\02\01\01\01\01\01\02\02\02\02\02\01\02\02\02" "\02\02\01\01\01\01\01\01\01\01\01\02\02\02\02\02" "\02\01\01\01\01\01\02\02\02\02\02\02\02\02\02\02" "\02\02\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01"
    "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\02" "\02\02\02\02\02\02\02\01\01\01\02\02\02\02\02\02" "\02\02\01\01\01\01\01\02\02\02\02\01\01\01\02\02" "\02\02\01\01\01\01\01\01\01\01\01\02\02\02\02\02" "\01\01\01\01\01\01\02\02\02\02\02\02\02\02\02\02" "\02\02\02\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01"
      
    "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\02" "\02\02\02\01\02\02\02\02\01\02\02\02\02\01\02\02" "\02\02\01\01\01\01\02\02\02\02\02\01\01\01\02\02" "\02\02\02\01\01\01\01\01\01\01\02\02\02\02\02\02" "\01\01\01\01\01\01\02\02\02\02\02\02\02\02\02\02" "\02\02\02\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01"
    "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\02" "\02\02\02\01\02\02\02\02\01\02\02\02\02\01\02\02" "\02\02\02\01\01\01\02\02\02\02\02\01\01\01\02\02" "\02\02\02\01\01\01\01\01\01\02\02\02\02\02\02\01" "\01\01\01\01\01\01\02\02\02\02\02\02\02\02\02\02" "\02\02\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01"
    "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\02\02" "\02\02\02\01\02\02\02\02\01\02\02\02\02\01\02\02" "\02\02\02\01\01\01\02\02\02\02\02\02\02\02\02\02" "\02\02\02\01\01\01\01\01\01\02\02\02\02\02\02\01" "\01\01\01\01\01\01\02\02\02\02\02\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01"
    "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\02\02" "\02\02\02\01\01\02\02\02\02\02\02\02\01\01\02\02" "\02\02\02\01\01\01\02\02\02\02\02\02\02\02\02\02" "\02\02\02\02\01\01\01\01\02\02\02\02\02\02\01\01" "\01\01\01\01\01\01\02\02\02\02\02\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01"
    "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\02\02" "\02\02\02\01\01\02\02\02\02\02\02\02\01\01\02\02" "\02\02\02\01\01\02\02\02\02\02\02\02\02\02\02\02" "\02\02\02\02\01\01\01\02\02\02\02\02\02\01\01\01" "\01\01\01\01\01\01\02\02\02\02\02\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01"
    "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\02\02" "\02\02\02\01\01\02\02\02\02\02\02\02\01\01\02\02" "\02\02\02\01\01\02\02\02\02\02\02\02\02\02\02\02" "\02\02\02\02\01\01\01\02\02\02\02\02\02\01\01\01" "\01\01\01\01\01\01\02\02\02\02\02\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01"
    "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\02\02" "\02\02\02\01\01\02\02\02\02\02\02\02\01\01\02\02" "\02\02\02\01\01\02\02\02\02\02\01\01\01\01\01\02" "\02\02\02\02\02\01\02\02\02\02\02\02\02\02\02\02" "\02\02\02\01\01\01\02\02\02\02\02\02\02\02\02\02" "\02\02\02\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01"
    "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\02\02" "\02\02\02\01\01\01\02\02\02\02\02\01\01\01\02\02" "\02\02\02\01\02\02\02\02\02\01\01\01\01\01\01\01" "\02\02\02\02\02\01\02\02\02\02\02\02\02\02\02\02" "\02\02\02\02\01\01\02\02\02\02\02\02\02\02\02\02" "\02\02\02\02\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01"
    "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\02\02" "\02\02\02\01\01\01\02\02\02\02\02\01\01\01\02\02" "\02\02\02\01\02\02\02\02\02\01\01\01\01\01\01\01" "\02\02\02\02\02\01\02\02\02\02\02\02\02\02\02\02" "\02\02\02\02\01\01\02\02\02\02\02\02\02\02\02\02" "\02\02\02\02\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01"
    "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\02" "\02\02\01\01\01\01\01\02\02\02\01\01\01\01\01\02" "\02\02\01\01\01\02\02\02\01\01\01\01\01\01\01\01" "\01\02\02\02\01\01\01\02\02\02\02\02\02\02\02\02" "\02\02\02\01\01\01\01\02\02\02\02\02\02\02\02\02" "\02\02\02\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01"
    "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01"
    "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01"
    "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01"
    "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01"
    "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01"
    "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01"
      
    "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01"
    "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01"
    "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01"
    "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01"
    "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01"
    "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01"
    "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01"
    "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01"
    "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01"
    "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01"
    "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01"
    "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01"
    "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01"
    "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01"
    "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01"
    "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01"
      
    "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\03\03\03\03\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01"
    "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\03\03\03\01\01\01\03\03\03\03\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01"
    "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\03\03\03\01\01\01\03\03\03\03\03\03" "\03\03\03\03\03\01\01\01\01\01\01\01\01\01\01\01"
    "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\03\03\03\01\01\01\03\03\03\03\03\03" "\03\03\03\03\03\01\01\01\01\01\01\01\01\01\01\01"
    "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\03\03\03\01\01\01\03\03\03\03\03\03" "\03\03\03\03\03\01\01\01\01\01\01\01\01\01\01\01"
    "\01\01\01\01\01\01\01\01\01\01\01\01\01\02\02\02" "\02\02\01\01\01\01\02\02\02\02\02\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\03\03\03\01\01\01\03\03\03\03\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01"
    "\01\01\01\01\01\01\01\01\01\01\01\01\01\02\02\02" "\02\02\02\01\01\02\02\02\02\02\02\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\03\03\03\03\03\03\03\03\03\03\03\03\03\03\03" "\03\03\03\03\03\03\03\01\01\01\01\01\01\01\01\01"
    "\01\01\01\01\01\01\01\01\01\01\01\01\01\02\02\02" "\02\02\02\02\02\02\02\02\02\02\02\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\03\03\03\03\03\03\03\03\03\03\03\03\03\03\03" "\03\03\03\03\03\03\03\01\01\01\01\01\01\01\01\01"
    "\01\01\01\01\01\01\01\01\01\01\01\01\01\02\02\02" "\02\02\02\02\02\02\02\02\02\02\02\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\03\03\03\03\03\03\03\03\03\03\03\03\03\03\03" "\03\03\03\03\03\03\03\01\01\01\01\01\01\01\01\01"
    "\01\01\01\01\01\01\01\01\01\01\01\01\01\02\02\02" "\02\02\02\02\02\02\02\02\02\02\02\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01"
    "\01\01\01\01\01\01\01\01\01\01\01\01\01\02\02\02" "\02\02\02\02\02\02\02\02\02\02\02\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\03\03\03\03\03\03\03\03\03\03\03\03\03" "\03\03\03\03\01\01\01\01\01\01\01\01\01\01\01\01"
    "\01\01\01\01\01\01\01\01\01\01\01\01\01\02\02\02" "\02\02\02\02\02\02\02\02\02\02\02\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\03\03\03\03\03\03\03\03\03\03\03\03\03" "\03\03\03\03\03\01\01\01\01\01\01\01\01\01\01\01"
    "\01\01\01\01\01\01\01\01\01\01\01\01\01\02\02\02" "\02\01\02\01\02\01\02\02\01\02\02\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\03\03\03\03\01\01\01\01\01\01\01\01\01" "\01\03\03\03\03\01\01\01\01\01\01\01\01\01\01\01"      
    "\01\01\01\01\01\01\01\01\01\01\01\01\01\02\02\02" "\02\01\02\01\02\01\02\01\02\01\02\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\03\03\03\03\01\01\01\01\01\01\01\01\01" "\01\03\03\03\03\01\01\01\01\01\01\01\01\01\01\01"
    "\01\01\01\01\01\01\01\01\01\01\01\01\01\02\02\02" "\02\01\02\01\02\01\02\01\02\01\02\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\03\03\03\03\03\03\03\03\03\03\03\03\03" "\03\03\03\03\03\01\01\01\01\01\01\01\01\01\01\01"
    "\01\01\01\01\01\01\01\01\01\01\01\01\01\02\02\02" "\02\01\01\01\01\01\02\01\01\01\02\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\03\03\03\03\03\03\03\03\03\03\03\03\03" "\03\03\03\03\03\01\01\01\01\01\01\01\01\01\01\01"
      
    "\01\01\01\01\01\01\01\01\01\01\01\01\01\02\02\02" "\02\02\01\02\01\02\02\01\02\01\02\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\03\03\03\03\01\01\01\01\01\01\01\01\01" "\01\03\03\03\03\01\01\01\01\01\01\01\01\01\01\01"
    "\01\01\01\01\01\01\01\01\01\01\01\01\01\02\02\02" "\02\02\02\02\02\02\02\02\02\02\02\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\03\03\03\03\01\01\01\01\01\01\01\01\01" "\01\03\03\03\03\01\01\01\01\01\01\01\01\01\01\01"
    "\01\01\01\01\01\01\01\01\01\01\01\01\01\02\02\02" "\02\02\02\02\02\02\02\02\02\02\02\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\03\03\03\03\03\03\03\03\03\03\03\03\03" "\03\03\03\03\03\01\01\01\01\01\01\01\01\01\01\01"
    "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\03\03\03\03\03\03\03\03\03\03\03\03\03" "\03\03\03\03\03\01\01\01\01\01\01\01\01\01\01\01"
    "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\03\03\03\03\01\01\01\01\01\01\01\01\01" "\01\03\03\03\03\01\01\01\01\01\01\01\01\01\01\01"
    "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\03\03\03\03\01\01\01\01\01\01\03\03\03" "\03\03\03\03\03\01\01\01\01\01\01\01\01\01\01\01"
    "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\03\03\03\03\01\01\01\01\01\01\03\03\03" "\03\03\03\03\03\01\01\01\01\01\01\01\01\01\01\01"
    "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\03\03\03\03\01\01\01\01\01\01\01\03\03" "\03\03\03\03\01\01\01\01\01\01\01\01\01\01\01\01"
    "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01"
    "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01"
    "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01"
    "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01"
    "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01"
    "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01"
    "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01"
    "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01"
    ;; 128000 | pointer_16x16_f1 = 256 bytes
    "\00\01\01\01\00\00\00\00\00\00\00\00\01\01\01\00"
    "\01\02\02\01\00\00\00\00\00\00\00\00\01\02\02\01"
    "\01\02\01\01\00\00\00\00\00\00\00\00\01\01\02\01"
    "\01\01\01\00\00\00\00\00\00\00\00\00\00\01\01\01"
    "\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00"
    "\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00"
    "\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00"
    "\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00"
    "\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00"
    "\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00"
    "\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00"
    "\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00"
    "\01\01\01\00\00\00\00\00\00\00\00\00\00\01\01\01"
    "\01\02\01\01\00\00\00\00\00\00\00\00\01\01\02\01"
    "\01\02\02\01\00\00\00\00\00\00\00\00\01\02\02\01"
    "\00\01\01\01\00\00\00\00\00\00\00\00\01\01\01\00"
    ;; 128256 | pointer_16x16_f2 = 256 bytes
    "\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00"
    "\00\00\01\01\01\00\00\00\00\00\00\01\01\01\00\00"
    "\00\01\02\02\01\00\00\00\00\00\00\01\02\02\01\00"
    "\00\01\02\01\01\00\00\00\00\00\00\01\01\02\01\00"
    "\00\01\01\01\00\00\00\00\00\00\00\00\01\01\01\00"
    "\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00"
    "\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00"
    "\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00"
    "\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00"
    "\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00"
    "\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00"
    "\00\01\01\01\00\00\00\00\00\00\00\00\01\01\01\00"
    "\00\01\02\01\01\00\00\00\00\00\00\01\01\02\01\00"
    "\00\01\02\02\01\00\00\00\00\00\00\01\02\02\01\00"
    "\00\00\01\01\01\00\00\00\00\00\00\01\01\01\00\00"
    "\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00"
    ;; 128512 | arrow_up_16x16 = 256 bytes
    "\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00"
    "\00\00\00\00\00\00\00\01\01\00\00\00\00\00\00\00"
    "\00\00\00\00\00\00\01\01\01\01\00\00\00\00\00\00"
    "\00\00\00\00\00\01\01\01\01\01\01\00\00\00\00\00"
    "\00\00\00\00\01\01\01\01\01\01\01\01\00\00\00\00"
    "\00\00\00\01\01\01\01\01\01\01\01\01\01\00\00\00"
    "\00\00\01\01\01\01\01\01\01\01\01\01\01\01\00\00"
    "\00\01\01\01\01\01\01\01\01\01\01\01\01\01\01\00"
    "\00\00\00\00\00\01\01\01\01\01\01\00\00\00\00\00"
    "\00\00\00\00\00\01\01\01\01\01\01\00\00\00\00\00"
    "\00\00\00\00\00\01\01\01\01\01\01\00\00\00\00\00"
    "\00\00\00\00\00\01\01\01\01\01\01\00\00\00\00\00"
    "\00\00\00\00\00\01\01\01\01\01\01\00\00\00\00\00"
    "\00\00\00\00\00\01\01\01\01\01\01\00\00\00\00\00"
    "\00\00\00\00\00\00\01\01\01\01\00\00\00\00\00\00"
    "\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00"
    ;; 128768 | arrow_down_16x16 = 256 bytes
    "\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00"
    "\00\00\00\00\00\00\01\01\01\01\00\00\00\00\00\00"
    "\00\00\00\00\00\01\01\01\01\01\01\00\00\00\00\00"
    "\00\00\00\00\00\01\01\01\01\01\01\00\00\00\00\00"
    "\00\00\00\00\00\01\01\01\01\01\01\00\00\00\00\00"
    "\00\00\00\00\00\01\01\01\01\01\01\00\00\00\00\00"
    "\00\00\00\00\00\01\01\01\01\01\01\00\00\00\00\00"
    "\00\00\00\00\00\01\01\01\01\01\01\00\00\00\00\00"
    "\00\01\01\01\01\01\01\01\01\01\01\01\01\01\01\00"
    "\00\00\01\01\01\01\01\01\01\01\01\01\01\01\00\00"
    "\00\00\00\01\01\01\01\01\01\01\01\01\01\00\00\00"
    "\00\00\00\00\01\01\01\01\01\01\01\01\00\00\00\00"
    "\00\00\00\00\00\01\01\01\01\01\01\00\00\00\00\00"
    "\00\00\00\00\00\00\01\01\01\01\00\00\00\00\00\00"
    "\00\00\00\00\00\00\00\01\01\00\00\00\00\00\00\00"
    "\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00"
    ;; 129024 | arrow_left_16x16 = 256 bytes
    "\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00"
    "\00\00\00\00\00\00\00\01\00\00\00\00\00\00\00\00"
    "\00\00\00\00\00\00\01\01\00\00\00\00\00\00\00\00"
    "\00\00\00\00\00\01\01\01\00\00\00\00\00\00\00\00"
    "\00\00\00\00\01\01\01\01\00\00\00\00\00\00\00\00"
    "\00\00\00\01\01\01\01\01\01\01\01\01\01\01\00\00"
    "\00\00\01\01\01\01\01\01\01\01\01\01\01\01\01\00"
    "\00\01\01\01\01\01\01\01\01\01\01\01\01\01\01\00"
    "\00\01\01\01\01\01\01\01\01\01\01\01\01\01\01\00"
    "\00\00\01\01\01\01\01\01\01\01\01\01\01\01\01\00"
    "\00\00\00\01\01\01\01\01\01\01\01\01\01\01\00\00"
    "\00\00\00\00\01\01\01\01\00\00\00\00\00\00\00\00"
    "\00\00\00\00\00\01\01\01\00\00\00\00\00\00\00\00"
    "\00\00\00\00\00\00\01\01\00\00\00\00\00\00\00\00"
    "\00\00\00\00\00\00\00\01\00\00\00\00\00\00\00\00"
    "\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00"
    ;; 129280 | arrow_right_16x16 256 bytes
    "\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00"
    "\00\00\00\00\00\00\00\00\01\00\00\00\00\00\00\00"
    "\00\00\00\00\00\00\00\00\01\01\00\00\00\00\00\00"
    "\00\00\00\00\00\00\00\00\01\01\01\00\00\00\00\00"
    "\00\00\00\00\00\00\00\00\01\01\01\01\00\00\00\00"
    "\00\00\01\01\01\01\01\01\01\01\01\01\01\00\00\00"
    "\00\01\01\01\01\01\01\01\01\01\01\01\01\01\00\00"
    "\00\01\01\01\01\01\01\01\01\01\01\01\01\01\01\00"
    "\00\01\01\01\01\01\01\01\01\01\01\01\01\01\01\00"
    "\00\01\01\01\01\01\01\01\01\01\01\01\01\01\00\00"
    "\00\00\01\01\01\01\01\01\01\01\01\01\01\00\00\00"
    "\00\00\00\00\00\00\00\00\01\01\01\01\00\00\00\00"
    "\00\00\00\00\00\00\00\00\01\01\01\00\00\00\00\00"
    "\00\00\00\00\00\00\00\00\01\01\00\00\00\00\00\00"
    "\00\00\00\00\00\00\00\00\01\00\00\00\00\00\00\00"
    "\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00"
    ;; 129536 | sweet_rock_16x16 = 256 bytes
    "\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00"
    "\00\00\00\00\00\00\01\01\01\01\00\00\00\00\00\00"
    "\00\00\00\00\01\01\02\02\02\02\01\01\00\00\00\00"
    "\00\00\00\01\02\02\02\03\03\02\02\02\01\00\00\00"
    "\00\00\01\02\02\02\03\02\03\03\02\02\02\01\00\00"
    "\00\00\01\02\02\04\03\03\03\03\04\02\02\01\00\00"
    "\00\01\02\02\02\04\03\03\03\03\04\02\02\02\01\00"
    "\00\01\02\02\02\02\04\03\03\04\02\02\02\02\01\00"
    "\00\01\02\04\02\02\02\02\02\02\02\02\02\04\01\00"
    "\00\01\04\05\02\04\02\02\02\02\02\04\04\05\01\00"
    "\00\00\01\05\04\05\02\04\02\04\04\05\05\01\00\00"
    "\00\00\01\05\05\05\04\05\04\05\05\05\05\01\00\00"
    "\00\00\00\01\05\05\05\05\05\05\05\05\01\00\00\00"
    "\00\00\00\00\01\01\05\05\05\05\01\01\00\00\00\00"
    "\00\00\00\00\00\00\01\01\01\01\00\00\00\00\00\00"
    "\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00"
    ;; 129792 | player_idle_16x16_f1 = 256 bytes
    "\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00"
    "\00\00\00\01\01\01\00\00\00\00\00\00\00\00\00\00"
    "\00\00\01\02\02\02\01\00\00\00\00\00\00\00\00\00"
    "\00\01\02\03\03\02\02\01\00\00\01\01\01\00\00\00"
    "\00\01\02\03\03\02\02\01\00\01\03\03\02\01\00\00"
    "\00\01\02\02\02\02\02\01\01\01\02\02\02\01\00\00"
    "\00\00\01\02\02\02\01\02\02\02\01\02\01\00\00\00"
    "\00\00\00\01\01\01\02\03\02\03\02\01\00\00\00\00"
    "\00\00\00\00\00\01\03\03\03\03\03\01\00\00\00\00"
    "\00\00\00\00\01\01\03\01\03\01\03\01\01\00\00\00"
    "\00\00\00\01\02\02\03\01\03\01\03\02\02\01\00\00"
    "\00\00\00\00\01\01\02\03\04\03\02\01\01\00\00\00"
    "\00\00\00\00\01\03\01\02\02\02\01\03\01\00\00\00"
    "\00\00\00\00\00\01\02\02\02\02\02\01\00\00\00\00"
    "\00\00\00\00\00\00\01\01\01\01\01\00\00\00\00\00"
    "\00\00\00\00\00\01\03\03\01\03\03\01\00\00\00\00"
    ;; 130048 | player_idle_16x16_f2 = 256 bytes
    "\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00"
    "\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00"
    "\00\00\00\01\01\01\00\00\00\00\00\01\01\01\00\00"
    "\00\00\01\02\02\02\01\00\00\00\01\03\03\02\01\00"
    "\00\01\02\03\03\02\02\01\01\01\02\02\02\02\01\00"
    "\00\01\02\03\03\02\02\01\02\03\01\02\02\01\00\00"
    "\00\01\02\02\02\02\02\01\03\03\03\01\01\00\00\00"
    "\00\00\01\02\02\02\01\01\03\01\03\01\00\00\00\00"
    "\00\00\00\01\01\01\03\01\03\01\03\01\01\00\00\00"
    "\00\00\00\01\02\02\02\03\04\03\02\02\02\01\00\00"
    "\00\00\00\00\01\01\02\02\02\02\02\01\01\00\00\00"
    "\00\00\00\00\00\01\03\01\02\01\03\01\00\00\00\00"
    "\00\00\00\00\00\00\01\02\02\02\01\00\00\00\00\00"
    "\00\00\00\00\00\00\01\01\01\01\01\00\00\00\00\00"
    "\00\00\00\00\00\00\01\03\01\03\01\00\00\00\00\00"
    "\00\00\00\00\00\01\03\01\00\01\03\01\00\00\00\00"
    ;; 130304 | player_up_16x16_f1 = 256 bytes
    "\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00"
    "\00\00\00\00\00\00\00\00\00\00\01\01\01\00\00\00"
    "\00\00\00\00\00\00\00\00\00\01\02\02\02\01\00\00"
    "\00\00\00\01\01\01\00\00\01\02\03\03\02\02\01\00"
    "\00\00\01\03\02\02\01\00\01\02\03\03\02\02\01\00"
    "\00\00\01\02\02\02\01\01\01\02\02\02\02\02\01\00"
    "\00\00\00\01\02\02\02\02\02\02\02\02\02\01\00\00"
    "\00\00\00\00\01\02\02\01\02\02\01\01\01\00\00\00"
    "\00\00\00\00\01\02\01\02\01\02\01\00\00\00\00\00"
    "\00\00\00\01\01\02\01\01\01\02\01\01\00\00\00\00"
    "\00\00\01\02\02\02\01\02\01\02\02\02\01\00\00\00"
    "\00\00\00\01\01\02\02\01\02\01\01\01\00\00\00\00"
    "\00\00\00\01\03\01\02\02\01\01\00\00\00\00\00\00"
    "\00\00\00\00\01\02\02\01\03\03\01\00\00\00\00\00"
    "\00\00\00\00\00\01\01\01\03\03\01\00\00\00\00\00"
    "\00\00\00\00\00\01\03\01\01\01\00\00\00\00\00\00"
    ;; 130560 | player_up_16x16_f2 = 256 bytes
    "\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00"
    "\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00"
    "\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00"
    "\00\00\01\01\01\00\00\00\00\00\01\01\01\00\00\00"
    "\00\01\03\02\02\01\00\00\00\01\02\02\02\01\00\00"
    "\00\01\02\02\02\02\01\01\01\02\03\03\02\02\01\00"
    "\00\00\01\02\02\02\02\02\02\01\03\03\02\02\01\00"
    "\00\00\00\01\01\02\02\01\02\02\02\02\02\02\01\00"
    "\00\00\00\00\01\02\01\02\01\02\01\02\02\01\00\00"
    "\00\00\00\01\01\02\01\01\01\02\01\01\01\00\00\00"
    "\00\00\01\02\02\02\01\02\01\02\02\02\01\00\00\00"
    "\00\00\00\01\01\02\02\01\02\02\01\01\00\00\00\00"
    "\00\00\00\00\00\01\01\02\02\01\03\01\00\00\00\00"
    "\00\00\00\00\01\03\03\01\02\02\01\00\00\00\00\00"
    "\00\00\00\00\01\03\03\01\01\01\00\00\00\00\00\00"
    "\00\00\00\00\00\01\01\01\03\01\00\00\00\00\00\00"
    ;; 130816 | player_down_16x16_f1 = 256 bytes
    "\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00"
    "\00\00\00\01\01\01\00\00\00\00\00\00\00\00\00\00"
    "\00\00\01\02\02\02\01\00\00\00\00\00\00\00\00\00"
    "\00\01\02\03\03\02\02\01\00\00\01\01\01\00\00\00"
    "\00\01\02\03\03\02\02\01\00\01\03\03\02\01\00\00"
    "\00\01\02\02\02\02\02\01\01\01\02\02\02\01\00\00"
    "\00\00\01\02\02\02\01\02\02\02\01\02\01\00\00\00"
    "\00\00\00\01\01\01\02\03\02\03\02\01\00\00\00\00"
    "\00\00\00\00\00\01\03\03\03\03\03\01\00\00\00\00"
    "\00\00\00\00\01\01\03\01\03\01\03\01\01\00\00\00"
    "\00\00\00\01\02\02\03\01\03\01\03\02\02\01\00\00"
    "\00\00\00\00\01\01\02\03\04\03\01\01\01\00\00\00"
    "\00\00\00\00\01\03\01\02\02\01\01\00\00\00\00\00"
    "\00\00\00\00\00\01\02\02\01\03\03\01\00\00\00\00"
    "\00\00\00\00\00\00\01\01\01\03\03\01\00\00\00\00"
    "\00\00\00\00\00\00\01\03\01\01\01\00\00\00\00\00"
    ;; 131072 | player_down_16x16_f2 = 256 bytes
    "\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00"
    "\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00"
    "\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00"
    "\00\00\00\01\01\01\00\00\00\00\00\01\01\01\00\00"
    "\00\00\01\02\02\02\01\00\00\00\01\03\03\02\01\00"
    "\00\01\02\03\03\02\02\01\01\01\02\02\02\02\01\00"
    "\00\01\02\03\03\02\02\01\02\02\01\02\02\01\00\00"
    "\00\01\02\02\02\02\02\01\02\03\02\01\01\00\00\00"
    "\00\00\01\02\02\02\01\03\03\03\03\01\00\00\00\00"
    "\00\00\00\01\01\01\03\01\03\01\03\01\01\00\00\00"
    "\00\00\00\01\02\02\03\01\03\01\03\02\02\01\00\00"
    "\00\00\00\00\01\01\02\03\04\03\02\01\01\00\00\00"
    "\00\00\00\00\00\00\01\01\02\02\01\03\01\00\00\00"
    "\00\00\00\00\00\01\03\03\01\02\02\01\00\00\00\00"
    "\00\00\00\00\00\01\03\03\01\01\01\00\00\00\00\00"
    "\00\00\00\00\00\00\01\01\01\03\01\00\00\00\00\00"
    ;; 131328 | player_left_16x16_f1 = 256 bytes
    "\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00"
    "\00\00\00\00\00\01\01\01\00\00\00\00\00\00\00\00"
    "\00\00\00\00\01\02\02\02\01\00\00\00\00\00\00\00"
    "\00\00\00\01\02\03\03\02\01\01\01\01\00\00\00\00"
    "\00\00\00\01\02\01\01\01\01\02\03\03\01\00\00\00"
    "\00\00\00\00\01\02\02\01\02\02\02\02\01\00\00\00"
    "\00\00\00\01\02\03\02\02\02\02\02\01\00\00\00\00"
    "\00\00\00\01\03\03\03\02\02\01\01\00\00\00\00\00"
    "\00\00\00\01\03\01\03\02\02\02\01\00\00\00\00\00"
    "\00\00\01\03\03\01\03\02\02\02\01\01\00\00\00\00"
    "\00\00\00\01\04\03\02\01\01\02\02\02\01\00\00\00"
    "\00\00\00\00\01\02\01\03\03\01\01\01\00\00\00\00"
    "\00\00\00\00\01\02\01\03\03\01\02\01\00\00\00\00"
    "\00\00\00\00\00\01\02\01\01\02\02\02\01\00\00\00"
    "\00\00\00\00\00\00\01\01\01\01\01\01\00\00\00\00"
    "\00\00\00\00\00\00\01\03\03\01\00\00\00\00\00\00"
    ;; 131584 | player_left_16x16_f2 = 256 bytes
    "\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00"
    "\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00"
    "\00\00\00\00\00\01\01\01\00\00\01\01\01\00\00\00"
    "\00\00\00\00\01\02\02\02\01\01\02\03\03\01\00\00"
    "\00\00\00\01\02\01\01\01\01\02\02\02\02\01\00\00"
    "\00\00\00\00\01\02\02\01\02\02\02\02\01\00\00\00"
    "\00\00\00\01\02\03\02\02\02\02\01\01\00\00\00\00"
    "\00\00\00\01\03\03\03\02\02\02\01\00\00\00\00\00"
    "\00\00\00\01\03\01\03\02\02\02\01\00\00\00\00\00"
    "\00\00\01\03\03\01\03\02\02\02\01\01\00\00\00\00"
    "\00\00\00\01\04\03\02\02\01\01\02\02\01\00\00\00"
    "\00\00\00\00\01\02\02\01\03\03\01\01\00\00\00\00"
    "\00\00\00\00\01\02\02\01\03\03\01\01\00\00\00\00"
    "\00\00\00\00\01\01\02\02\01\01\02\02\01\00\00\00"
    "\00\00\00\01\03\03\01\01\01\01\01\01\00\00\00\00"
    "\00\00\00\00\01\01\01\00\01\03\01\00\00\00\00\00"
    ;; 131840 | player_right_16x16_f1 = 256 bytes
    "\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00"
    "\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00"
    "\00\00\00\00\01\01\01\00\00\00\01\01\00\00\00\00"
    "\00\00\00\01\02\02\02\01\00\01\03\02\01\00\00\00"
    "\00\00\01\02\03\03\02\02\01\01\01\02\01\00\00\00"
    "\00\00\01\02\03\03\02\02\01\02\02\01\00\00\00\00"
    "\00\00\01\02\02\02\02\02\01\02\03\02\01\00\00\00"
    "\00\00\00\01\02\02\02\01\02\03\03\03\01\00\00\00"
    "\00\00\00\00\01\01\01\02\02\03\01\03\01\00\00\00"
    "\00\00\00\00\01\02\02\02\02\03\01\03\03\01\00\00"
    "\00\00\00\01\02\02\02\01\01\02\03\04\01\00\00\00"
    "\00\00\00\00\01\01\01\03\03\01\02\01\00\00\00\00"
    "\00\00\00\00\01\02\01\03\03\01\02\01\00\00\00\00"
    "\00\00\00\01\02\02\02\01\01\02\01\00\00\00\00\00"
    "\00\00\00\00\01\01\01\01\01\01\00\00\00\00\00\00"
    "\00\00\00\00\00\00\01\03\03\01\00\00\00\00\00\00"
    ;; 132096 | player_right_16x16_f2 = 256 bytes
    "\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00"
    "\00\00\00\01\01\01\00\00\00\00\00\00\00\00\00\00"
    "\00\00\01\02\02\02\01\00\00\00\01\01\01\00\00\00"
    "\00\01\02\03\03\02\02\01\00\01\03\03\02\01\00\00"
    "\00\01\02\03\03\02\02\01\01\01\01\02\02\01\00\00"
    "\00\01\02\02\02\02\02\01\02\02\02\01\01\00\00\00"
    "\00\00\01\02\02\02\01\02\02\02\03\02\01\00\00\00"
    "\00\00\00\01\01\01\02\02\02\03\03\03\01\00\00\00"
    "\00\00\00\00\00\01\02\02\02\03\01\03\01\00\00\00"
    "\00\00\00\00\01\01\02\02\02\03\01\03\03\01\00\00"
    "\00\00\00\01\02\02\01\01\02\02\03\04\01\00\00\00"
    "\00\00\00\00\01\01\03\03\01\02\02\01\00\00\00\00"
    "\00\00\00\00\01\01\03\03\01\02\02\01\00\00\00\00"
    "\00\00\00\01\02\02\01\01\02\02\01\01\00\00\00\00"
    "\00\00\00\00\01\01\01\01\01\01\03\03\01\00\00\00"
    "\00\00\00\00\00\01\03\01\00\01\01\01\00\00\00\00" 
    ;; 132352 | wasm_block_16x16 = 256 bytes
    "\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00"
    "\00\01\01\01\01\01\00\00\00\00\01\01\01\01\01\00"
    "\00\01\01\01\01\01\01\00\00\01\01\01\01\01\01\00"
    "\00\01\01\01\01\01\01\01\01\01\01\01\01\01\01\00"
    "\00\01\01\01\01\01\01\01\01\01\01\01\01\01\01\00"
    "\00\01\01\01\01\01\01\01\01\01\01\01\01\01\01\00"
    "\00\01\01\01\01\01\01\01\01\01\01\01\01\01\01\00"
    "\00\01\01\01\01\01\01\01\01\01\01\01\01\01\01\00"
    "\00\01\01\01\01\02\01\02\01\02\01\01\02\01\01\00"
    "\00\01\01\01\01\02\01\02\01\02\01\02\01\02\01\00"
    "\00\01\01\01\01\02\01\02\01\02\01\02\01\02\01\00"
    "\00\01\01\01\01\02\02\02\02\02\01\02\02\02\01\00"
    "\00\01\01\01\01\01\02\01\02\01\01\02\01\02\01\00"
    "\00\01\01\01\01\01\01\01\01\01\01\01\01\01\01\00"
    "\00\01\01\01\01\01\01\01\01\01\01\01\01\01\01\00"
    "\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00"
    ;; 132608 | key_16x16 = 256 bytes
    "\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00"
    "\00\00\00\00\00\00\01\01\01\01\01\01\01\00\00\00"
    "\00\00\00\00\00\00\01\01\01\01\01\01\01\00\00\00"
    "\00\00\00\00\00\00\01\01\01\00\00\00\00\00\00\00"
    "\00\00\00\00\00\00\01\01\01\01\01\01\01\00\00\00"
    "\00\00\00\00\00\00\01\01\01\01\01\01\01\00\00\00"
    "\00\00\00\00\00\00\01\01\01\00\00\00\00\00\00\00"
    "\00\00\00\00\00\00\01\01\01\00\00\00\00\00\00\00"
    "\00\00\00\00\00\00\01\01\01\00\00\00\00\00\00\00"
    "\00\00\00\00\01\01\01\01\01\01\01\01\00\00\00\00"
    "\00\00\00\01\01\01\01\01\01\01\01\01\01\00\00\00"
    "\00\00\00\01\01\02\01\02\02\01\02\01\01\00\00\00"
    "\00\00\00\01\01\02\02\01\01\02\02\01\01\00\00\00"
    "\00\00\00\01\01\01\01\02\02\01\01\01\01\00\00\00"
    "\00\00\00\00\01\01\01\01\01\01\01\01\00\00\00\00"
    "\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00" 
    ;; 132864 | lock_16x16 = 256 bytes
    "\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00"
    "\00\00\00\00\00\01\01\01\01\01\01\00\00\00\00\00"
    "\00\00\00\00\01\02\02\02\02\02\02\01\00\00\00\00"
    "\00\00\00\01\02\02\01\01\01\01\02\02\01\00\00\00"
    "\00\00\00\01\02\01\00\00\00\00\01\02\01\00\00\00"
    "\00\00\00\01\02\01\00\00\00\00\01\02\01\00\00\00"
    "\00\00\01\01\01\01\01\01\01\01\01\01\01\01\00\00"
    "\00\01\02\02\02\02\02\02\02\02\02\02\02\02\01\00"
    "\00\01\01\01\01\02\02\01\01\02\02\01\01\01\01\00"
    "\00\01\02\02\02\02\01\01\01\01\02\02\02\02\01\00"
    "\00\01\01\01\02\02\01\01\01\01\02\02\01\01\01\00"
    "\00\01\02\02\02\02\01\01\01\01\02\02\02\02\01\00"
    "\00\01\01\02\02\02\02\01\01\02\02\02\02\01\01\00"
    "\00\01\02\02\02\02\02\02\02\02\02\02\02\02\01\00"
    "\00\00\01\01\01\01\01\01\01\01\01\01\01\01\00\00"
    "\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00"
    ;; 133120 | maze_maker_icon_sweet_rock_8x8 = 64 bytes
    "\00\00\00\00\00\00\00\00"
    "\00\00\01\01\01\01\00\00"
    "\00\01\02\03\03\02\01\00"
    "\00\01\04\03\03\04\01\00"
    "\00\01\05\04\04\05\01\00"
    "\00\01\05\05\05\05\01\00"
    "\00\00\01\01\01\01\00\00"
    "\00\00\00\00\00\00\00\00"
    ;; 133184 | maze_maker_icon_player_8x8 = 64 bytes
    "\00\00\00\00\00\00\00\00"
    "\00\01\01\01\01\01\01\00"
    "\00\01\02\01\02\01\01\00"
    "\00\02\03\02\03\02\01\00"
    "\00\02\03\02\03\02\01\00"
    "\00\01\02\04\02\01\01\00"
    "\00\01\01\01\01\01\01\00"
    "\00\00\00\00\00\00\00\00"
    ;; 133248 | maze_maker_icon_wasm_block_8x8 = 64 bytes
    "\00\00\00\00\00\00\00\00"
    "\00\01\01\00\00\01\01\00"
    "\00\01\01\01\01\01\01\00"
    "\00\01\01\01\01\01\01\00"
    "\00\01\01\01\01\01\01\00"
    "\00\01\01\01\02\02\01\00"
    "\00\01\01\01\01\01\01\00"
    "\00\00\00\00\00\00\00\00"
    ;; 133312 | maze_maker_icon_key_8x8 = 64 bytes
    "\00\00\00\00\00\00\00\00"
    "\00\00\00\01\01\00\00\00"
    "\00\00\00\01\00\00\00\00"
    "\00\00\00\01\01\00\00\00"
    "\00\00\00\01\00\00\00\00"
    "\00\00\01\02\01\00\00\00"
    "\00\00\01\01\01\00\00\00"
    "\00\00\00\00\00\00\00\00"
    ;; 133376 | maze_maker_icon_lock_8x8 = 64 bytes
    "\00\00\00\00\00\00\00\00"
    "\00\00\00\01\01\00\00\00"
    "\00\00\01\00\00\01\00\00"
    "\00\00\01\01\01\01\00\00"
    "\00\01\02\02\02\02\01\00"
    "\00\01\02\01\01\02\01\00"
    "\00\00\01\01\01\01\00\00"
    "\00\00\00\00\00\00\00\00"
    ;; 133440 | maze_maker_play_button_40x16 = 640 bytes
    "\00\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\00\01\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\01\01\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\01\01\02\02\02\01\01\01\01\01\02\02\02\02\01\01\02\02\02\02\02\02\02\01\01\01\01\01\02\02\02\02\01\01\02\01\01\02\02\02\01\01\02\02\01\01\01\01\01\01\01\02\02\01\01\01\01\02\02\02\02\02\01\01\01\01\01\01\01\02\02\01\01\01\02\01\01\01\02\02\01\01\02\02\01\01\01\01\01\01\01\02\02\01\01\01\01\02\02\02\02\02\01\01\01\01\01\01\01\02\02\01\01\01\02\01\01\01\02\02\01\01\02\02\01\01\02\02\02\01\01\02\02\01\01\01\01\02\02\02\02\02\01\01\02\02\02\01\01\02\02\01\01\01\01\01\01\01\02\02\01\01\02\02\01\01\02\02\02\01\01\02\02\01\01\01\01\02\02\02\02\02\01\01\02\02\02\01\01\02\02\01\01\01\01\01\01\01\02\02\01\01\02\02\01\01\01\01\01\01\01\02\02\01\01\01\01\02\02\02\02\02\01\01\01\01\01\01\01\02\02\02\01\01\01\01\01\02\02\02\01\01\02\02\01\01\01\01\01\01\02\02\02\01\01\01\01\01\01\02\02\02\01\01\01\01\01\01\01\02\02\02\02\01\01\01\02\02\02\02\01\01\02\02\01\01\01\01\02\02\02\02\02\01\01\01\01\01\01\01\02\02\01\01\01\02\01\01\01\02\02\02\02\01\01\01\02\02\02\02\01\01\02\02\01\01\01\01\02\02\02\02\02\01\01\01\01\01\01\01\02\02\01\01\01\02\01\01\01\02\02\02\02\01\01\01\02\02\02\02\01\01\02\02\02\01\01\02\02\02\02\02\02\02\01\01\01\01\01\02\02\02\02\01\01\02\01\01\02\02\02\02\02\02\01\02\02\02\02\02\01\01\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\01\01\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\01\00\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\00"
    ;; 134080 | maze_maker_load_button_40x16 = 640 bytes
    "\00\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\00\01\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\01\01\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\01\01\02\02\02\01\01\02\02\02\02\02\02\02\01\01\01\01\01\02\02\02\02\01\01\01\01\01\02\02\02\01\01\01\01\01\01\02\02\02\01\01\02\02\01\01\01\01\02\02\02\02\02\01\01\01\01\01\01\01\02\02\01\01\01\01\01\01\01\02\02\01\01\01\01\01\01\01\02\02\01\01\02\02\01\01\01\01\02\02\02\02\02\01\01\02\02\02\01\01\02\02\01\01\01\01\01\01\01\02\02\01\01\01\02\02\01\01\02\02\01\01\02\02\01\01\01\01\02\02\02\02\02\01\01\02\02\02\01\01\02\02\01\01\02\02\02\01\01\02\02\01\01\01\02\02\01\01\02\02\01\01\02\02\01\01\01\01\02\02\02\02\02\01\01\02\02\02\01\01\02\02\01\01\02\02\02\01\01\02\02\01\01\01\02\02\01\01\02\02\01\01\02\02\01\01\01\01\02\02\02\02\02\01\01\02\02\02\01\01\02\02\01\01\01\01\01\01\01\02\02\01\01\01\02\02\01\01\02\02\01\01\02\02\01\01\01\01\01\01\02\02\02\01\01\02\02\02\01\01\02\02\01\01\01\01\01\01\01\02\02\01\01\01\02\02\01\01\02\02\01\01\02\02\01\01\01\01\01\01\01\02\02\01\01\02\02\02\01\01\02\02\01\01\01\02\01\01\01\02\02\01\01\01\02\02\01\01\02\02\01\01\02\02\01\01\01\01\01\01\01\02\02\01\01\01\01\01\01\01\02\02\01\01\01\02\01\01\01\02\02\01\01\01\01\01\01\01\02\02\01\01\02\02\02\01\01\01\01\01\02\02\02\02\01\01\01\01\01\02\02\02\02\01\01\02\01\01\02\02\02\01\01\01\01\01\01\02\02\02\01\01\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\01\01\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\01\00\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\00"
    ;; 134720 | maze_maker_share_button_40x16 = 640 bytes
    "\00\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\00\01\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\01\01\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\01\01\02\02\02\01\01\01\02\02\02\02\01\02\01\02\02\02\02\01\01\01\01\02\02\02\02\01\01\01\02\02\02\02\01\01\01\02\02\02\01\01\02\02\01\01\01\01\01\02\02\01\01\02\01\01\02\02\01\01\01\01\01\01\02\02\01\01\01\01\01\02\02\01\01\01\01\01\02\02\01\01\02\02\01\01\02\01\01\02\02\01\01\02\01\01\02\02\01\01\01\01\01\01\02\02\01\01\01\01\01\02\02\01\01\01\01\01\02\02\01\01\02\02\01\01\02\02\02\02\02\01\01\01\01\01\02\02\01\01\02\02\01\01\02\02\01\01\02\01\01\02\02\01\01\01\02\02\02\02\01\01\02\02\01\01\01\01\02\02\02\01\01\01\01\01\02\02\01\01\02\02\01\01\02\02\01\01\02\01\01\02\02\01\01\01\01\01\02\02\01\01\02\02\02\01\01\01\01\02\02\01\01\01\01\01\02\02\01\01\01\01\01\01\02\02\01\01\01\01\02\02\02\01\01\01\01\01\02\02\01\01\02\02\02\02\02\01\01\02\02\01\01\01\01\01\02\02\01\01\01\01\01\01\02\02\01\01\01\01\01\02\02\01\01\01\02\02\02\02\01\01\02\02\01\01\02\01\01\02\02\01\01\02\01\01\02\02\01\01\02\02\01\01\02\02\01\01\01\01\01\02\02\01\01\01\01\01\02\02\01\01\02\02\01\01\01\01\01\02\02\01\01\02\01\01\02\02\01\01\02\02\01\01\02\02\01\01\02\01\01\02\02\01\01\01\01\01\02\02\01\01\02\02\02\01\01\01\02\02\02\02\01\02\01\02\02\02\02\01\02\02\01\02\02\02\01\01\02\01\01\02\02\02\01\01\01\02\02\02\01\01\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\01\01\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\01\00\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\00"
    ;; 135360 | maze_select_button_32x32 = 1024 bytes
    "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01"
    "\01\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02" "\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\01"
    "\01\02\02\02\02\02\02\02\02\01\02\01\02\02\02\01" "\02\02\01\01\01\02\01\01\02\02\02\02\02\02\02\01"
    "\01\02\02\02\02\02\02\02\01\02\01\02\01\02\01\02" "\01\02\02\02\01\02\01\02\02\02\02\02\02\02\02\01"
    "\01\02\02\02\02\02\02\02\01\02\01\02\01\02\01\01" "\01\02\02\01\02\02\01\01\02\02\02\02\02\02\02\01"
    "\01\02\02\02\02\02\02\02\01\02\01\02\01\02\01\02" "\01\02\01\02\02\02\01\02\02\02\02\02\02\02\02\01"
    "\01\02\02\02\02\02\02\02\01\02\01\02\01\02\01\02" "\01\02\01\01\01\02\01\01\02\02\02\02\02\02\02\01"
    "\01\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02" "\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\01"
    "\01\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02" "\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\01"
    "\01\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02" "\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\01"
    "\01\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02" "\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\01"
    "\01\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02" "\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\01"
    "\01\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02" "\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\01"
    "\01\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02" "\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\01"
    "\01\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02" "\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\01"
    "\01\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02" "\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\01"

    "\01\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02" "\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\01"
    "\01\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02" "\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\01"
    "\01\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02" "\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\01"
    "\01\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02" "\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\01"
    "\01\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02" "\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\01"
    "\01\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02" "\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\01"
    "\01\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02" "\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\01"
    "\01\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02" "\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\01"
    "\01\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02" "\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\01"
    "\01\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02" "\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\01"
    "\01\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02" "\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\01"
    "\01\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02" "\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\01"
    "\01\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02" "\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\01"
    "\01\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02" "\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\01"
    "\01\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02" "\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\01"
    "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01\01"
    ;; 136384 | maze_select_button_number_label_16x16x9 = 2304 bytes
    ;; 1
    "\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00"
    "\00\00\00\00\00\00\01\01\01\01\00\00\00\00\00\00"
    "\00\00\00\00\00\01\01\01\01\01\01\00\00\00\00\00"
    "\00\00\00\00\01\01\01\01\01\01\01\00\00\00\00\00"
    "\00\00\00\01\01\01\01\01\01\01\01\00\00\00\00\00"
    "\00\00\01\01\01\01\01\01\01\01\01\00\00\00\00\00"
    "\00\01\01\01\01\01\01\01\01\01\01\00\00\00\00\00"
    "\00\01\01\01\01\01\01\01\01\01\01\00\00\00\00\00"
    "\00\00\01\01\01\00\01\01\01\01\01\00\00\00\00\00"
    "\00\00\00\00\00\00\01\01\01\01\01\00\00\00\00\00"
    "\00\00\00\00\00\00\01\01\01\01\01\00\00\00\00\00"
    "\00\00\01\01\01\01\01\01\01\01\01\01\01\01\00\00"
    "\00\01\01\01\01\01\01\01\01\01\01\01\01\01\01\00"
    "\00\01\01\01\01\01\01\01\01\01\01\01\01\01\01\00"
    "\00\00\01\01\01\01\01\01\01\01\01\01\01\01\00\00"
    "\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00"
    ;; 2
    "\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00"
    "\00\00\00\00\01\01\01\01\01\01\01\01\00\00\00\00"
    "\00\00\01\01\01\01\01\01\01\01\01\01\01\01\00\00"
    "\00\01\01\01\01\01\01\01\01\01\01\01\01\01\01\00"
    "\00\01\01\01\01\01\01\00\00\01\01\01\01\01\01\00"
    "\00\00\01\01\01\01\00\00\00\00\01\01\01\01\01\00"
    "\00\00\00\00\00\00\00\00\00\01\01\01\01\01\00\00"
    "\00\00\00\00\00\00\00\00\01\01\01\01\01\00\00\00"
    "\00\00\00\00\00\00\00\01\01\01\01\01\00\00\00\00"
    "\00\00\00\00\00\00\01\01\01\01\01\00\00\00\00\00"
    "\00\00\00\00\00\01\01\01\01\01\00\00\00\00\00\00"
    "\00\00\01\01\01\01\01\01\01\01\01\01\01\01\00\00"
    "\00\01\01\01\01\01\01\01\01\01\01\01\01\01\01\00"
    "\00\01\01\01\01\01\01\01\01\01\01\01\01\01\01\00"
    "\00\00\01\01\01\01\01\01\01\01\01\01\01\01\00\00"
    "\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00"
    ;; 3
    "\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00"
    "\00\00\00\00\01\01\01\01\01\01\01\01\00\00\00\00"
    "\00\00\01\01\01\01\01\01\01\01\01\01\01\01\00\00"
    "\00\01\01\01\01\01\01\01\01\01\01\01\01\01\01\00"
    "\00\01\01\01\01\01\01\00\00\01\01\01\01\01\01\00"
    "\00\00\01\01\01\01\00\00\00\00\01\01\01\01\01\00"
    "\00\00\00\00\00\00\00\00\00\01\01\01\01\01\00\00"
    "\00\00\00\00\00\01\01\01\01\01\01\01\01\00\00\00"
    "\00\00\00\00\00\01\01\01\01\01\01\01\01\00\00\00"
    "\00\00\00\00\00\00\00\00\00\01\01\01\01\01\00\00"
    "\00\00\01\01\01\01\00\00\00\00\01\01\01\01\01\00"
    "\00\01\01\01\01\01\01\00\00\01\01\01\01\01\01\00"
    "\00\01\01\01\01\01\01\01\01\01\01\01\01\01\01\00"
    "\00\00\01\01\01\01\01\01\01\01\01\01\01\01\00\00"
    "\00\00\00\00\01\01\01\01\01\01\01\01\00\00\00\00"
    "\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00"
    ;; 4
    "\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00"
    "\00\00\01\01\01\00\00\00\00\00\00\01\01\01\00\00"
    "\00\01\01\01\01\01\00\00\00\00\01\01\01\01\01\00"
    "\00\01\01\01\01\01\00\00\00\00\01\01\01\01\01\00"
    "\00\01\01\01\01\01\00\00\00\00\01\01\01\01\01\00"
    "\00\01\01\01\01\01\01\01\01\01\01\01\01\01\01\00"
    "\00\01\01\01\01\01\01\01\01\01\01\01\01\01\01\00"
    "\00\01\01\01\01\01\01\01\01\01\01\01\01\01\01\00"
    "\00\01\01\01\01\01\01\01\01\01\01\01\01\01\01\00"
    "\00\00\01\01\01\01\01\01\01\01\01\01\01\01\01\00"
    "\00\00\00\00\00\00\00\00\00\00\01\01\01\01\01\00"
    "\00\00\00\00\00\00\00\00\00\00\01\01\01\01\01\00"
    "\00\00\00\00\00\00\00\00\00\00\01\01\01\01\01\00"
    "\00\00\00\00\00\00\00\00\00\00\01\01\01\01\01\00"
    "\00\00\00\00\00\00\00\00\00\00\00\01\01\01\00\00"
    "\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00"
    ;; 5
    "\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00"
    "\00\00\01\01\01\01\01\01\01\01\01\01\01\01\00\00"
    "\00\01\01\01\01\01\01\01\01\01\01\01\01\01\01\00"
    "\00\01\01\01\01\01\01\01\01\01\01\01\01\01\01\00"
    "\00\01\01\01\01\01\01\01\01\01\01\01\01\01\00\00"
    "\00\01\01\01\01\01\01\00\00\00\00\00\00\00\00\00"
    "\00\01\01\01\01\01\01\01\01\01\01\01\01\00\00\00"
    "\00\00\01\01\01\01\01\01\01\01\01\01\01\01\00\00"
    "\00\00\00\00\00\01\01\01\01\01\01\01\01\01\01\00"
    "\00\00\00\00\00\00\00\00\00\01\01\01\01\01\01\00"
    "\00\00\01\01\01\01\00\00\00\00\01\01\01\01\01\00"
    "\00\01\01\01\01\01\01\00\00\01\01\01\01\01\01\00"
    "\00\01\01\01\01\01\01\01\01\01\01\01\01\01\01\00"
    "\00\00\01\01\01\01\01\01\01\01\01\01\01\01\00\00"
    "\00\00\00\00\01\01\01\01\01\01\01\01\00\00\00\00"
    "\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00"
    ;; 6
    "\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00"
    "\00\00\00\00\01\01\01\01\01\01\01\01\01\00\00\00"
    "\00\00\00\01\01\01\01\01\01\01\01\01\01\01\00\00"
    "\00\00\01\01\01\01\01\01\01\01\01\01\01\01\01\00"
    "\00\01\01\01\01\01\01\01\01\01\01\01\01\01\01\00"
    "\00\01\01\01\01\01\00\00\00\00\00\01\01\01\00\00"
    "\00\01\01\01\01\00\00\00\00\00\00\00\00\00\00\00"
    "\00\01\01\01\01\00\01\01\01\01\01\01\00\00\00\00"
    "\00\01\01\01\01\01\01\01\01\01\01\01\01\01\00\00"
    "\00\01\01\01\01\01\01\00\00\00\01\01\01\01\01\00"
    "\00\01\01\01\01\01\00\00\00\00\00\01\01\01\01\00"
    "\00\01\01\01\01\01\01\00\00\00\01\01\01\01\01\00"
    "\00\00\01\01\01\01\01\01\01\01\01\01\01\01\01\00"
    "\00\00\00\01\01\01\01\01\01\01\01\01\01\01\00\00"
    "\00\00\00\00\01\01\01\01\01\01\01\01\00\00\00\00"
    "\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00"
    ;; 7
    "\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00"
    "\00\00\01\01\01\01\01\01\01\01\01\01\01\01\00\00"
    "\00\01\01\01\01\01\01\01\01\01\01\01\01\01\01\00"
    "\00\01\01\01\01\01\01\01\01\01\01\01\01\01\01\00"
    "\00\01\01\01\01\01\01\01\01\01\01\01\01\01\01\00"
    "\00\00\01\01\01\01\01\01\01\01\01\01\01\01\01\00"
    "\00\00\00\00\00\00\00\00\00\00\01\01\01\01\01\00"
    "\00\00\00\00\00\00\00\00\00\00\01\01\01\01\01\00"
    "\00\00\00\00\00\00\00\00\00\00\01\01\01\01\01\00"
    "\00\00\00\00\00\00\00\00\00\00\01\01\01\01\01\00"
    "\00\00\00\00\00\00\00\00\00\00\01\01\01\01\01\00"
    "\00\00\00\00\00\00\00\00\00\00\01\01\01\01\01\00"
    "\00\00\00\00\00\00\00\00\00\00\01\01\01\01\01\00"
    "\00\00\00\00\00\00\00\00\00\00\01\01\01\01\01\00"
    "\00\00\00\00\00\00\00\00\00\00\00\01\01\01\00\00"
    "\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00"
    ;; 8
    "\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00"
    "\00\00\00\00\01\01\01\01\01\01\01\01\00\00\00\00"
    "\00\00\01\01\01\01\01\01\01\01\01\01\01\01\00\00"
    "\00\01\01\01\01\01\01\01\01\01\01\01\01\01\01\00"
    "\00\01\01\01\01\01\01\00\00\01\01\01\01\01\01\00"
    "\00\01\01\01\01\01\00\00\00\00\01\01\01\01\01\00"
    "\00\00\01\01\01\01\01\00\00\01\01\01\01\01\00\00"
    "\00\00\00\01\01\01\01\01\01\01\01\01\01\00\00\00"
    "\00\00\00\01\01\01\01\01\01\01\01\01\01\00\00\00"
    "\00\00\01\01\01\01\01\00\00\01\01\01\01\01\00\00"
    "\00\01\01\01\01\01\00\00\00\00\01\01\01\01\01\00"
    "\00\01\01\01\01\01\01\00\00\01\01\01\01\01\01\00"
    "\00\01\01\01\01\01\01\01\01\01\01\01\01\01\01\00"
    "\00\00\01\01\01\01\01\01\01\01\01\01\01\01\00\00"
    "\00\00\00\00\01\01\01\01\01\01\01\01\00\00\00\00"
    "\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00"
    ;; ?
    "\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00"
    "\00\00\00\00\01\01\01\01\01\01\01\01\00\00\00\00"
    "\00\00\01\01\01\01\01\01\01\01\01\01\01\01\00\00"
    "\00\01\01\01\01\01\01\01\01\01\01\01\01\01\01\00"
    "\00\01\01\01\01\01\01\00\00\01\01\01\01\01\01\00"
    "\00\01\01\01\01\01\00\00\00\00\01\01\01\01\01\00"
    "\00\00\01\01\01\00\00\00\00\01\01\01\01\01\00\00"
    "\00\00\00\00\00\00\00\00\01\01\01\01\01\00\00\00"
    "\00\00\00\00\00\00\00\01\01\01\01\01\00\00\00\00"
    "\00\00\00\00\00\00\01\01\01\01\01\00\00\00\00\00"
    "\00\00\00\00\00\00\01\01\01\01\00\00\00\00\00\00"
    "\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00"
    "\00\00\00\00\00\01\01\01\01\01\01\00\00\00\00\00"
    "\00\00\00\00\01\01\01\01\01\01\01\01\00\00\00\00"
    "\00\00\00\00\00\01\01\01\01\01\01\00\00\00\00\00"
    "\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00"
    ;; 138688 | maze_select_button_trophy_icon_8x8 = 64 bytes
    "\00\00\00\00\00\00\00\00"
    "\00\00\00\00\00\00\00\00"
    "\00\00\01\01\01\01\01\00"
    "\00\00\01\01\01\01\01\00"
    "\00\00\00\01\01\01\00\00"
    "\00\00\00\00\01\00\00\00"
    "\00\00\00\01\01\01\00\00"
    "\00\00\00\00\00\00\00\00"
    ;; 138752 | you_win_overlay_80x32 = 2560 bytes
    "\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00" "\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00" "\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00" "\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00" "\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00"
    "\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00" "\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00" "\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00" "\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00" "\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00"
    "\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00" "\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00" "\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00" "\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00" "\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00"
    "\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00" "\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00" "\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00" "\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00" "\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00"
    "\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00" "\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00" "\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00" "\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00" "\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00" 
    "\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00" "\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00" "\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00" "\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00" "\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00"
    "\00\00\00\00\00\00\01\01\01\00\00\00\00\00\00\00" "\01\01\01\00\00\00\00\00\00\00\01\01\01\00\00\00" "\00\00\00\01\01\01\01\01\01\01\01\01\01\01\01\00" "\00\00\00\00\00\00\00\00\00\01\01\01\00\00\00\00" "\00\00\00\00\00\01\01\01\01\00\00\00\00\00\00\00"
    "\00\00\00\00\00\01\01\01\01\01\00\00\00\00\00\01" "\01\01\01\01\00\00\00\00\00\01\01\01\01\01\00\00" "\00\00\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\00\00\00\00\00\00\00\00\01\01\01\01\01\00\00\00" "\00\00\00\00\01\01\01\01\01\01\00\00\00\00\00\00"
    "\00\00\00\00\00\01\01\01\01\01\00\00\00\00\00\01" "\01\01\01\01\00\00\00\00\00\01\01\01\01\01\00\00" "\00\00\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\00\00\00\00\00\00\00\00\01\01\01\01\01\00\00\00" "\00\00\00\00\01\01\01\01\01\01\00\00\00\00\00\00"
    "\00\00\00\00\00\01\01\01\01\01\00\00\00\00\01\01" "\01\01\01\01\01\00\00\00\00\01\01\01\01\01\00\00" "\00\00\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\00\00\00\00\00\00\00\00\01\01\01\01\01\01\00\00" "\00\00\00\00\01\01\01\01\01\01\00\00\00\00\00\00"
    "\00\00\00\00\00\00\01\01\01\01\01\00\00\00\01\01" "\01\01\01\01\01\00\00\00\00\01\01\01\01\01\00\00" "\00\00\00\01\01\01\01\01\01\01\01\01\01\01\01\00" "\00\00\00\00\00\00\00\01\01\01\01\01\01\01\00\00" "\00\00\00\01\01\01\01\01\01\00\00\00\00\00\00\00"
    "\00\00\00\00\00\00\01\01\01\01\01\00\00\00\01\01" "\01\01\01\01\01\00\00\00\01\01\01\01\01\00\00\00" "\00\00\00\00\00\00\01\01\01\01\01\01\00\00\00\00" "\00\00\00\00\00\00\00\01\01\01\01\01\01\01\00\00" "\00\00\00\01\01\01\01\01\01\00\00\00\00\00\00\00"
    "\00\00\00\00\00\00\01\01\01\01\01\00\00\00\01\01" "\01\01\01\01\01\01\00\00\01\01\01\01\01\00\00\00" "\00\00\00\00\00\00\01\01\01\01\01\01\00\00\00\00" "\00\00\00\00\00\00\00\01\01\01\01\01\01\01\01\00" "\00\00\00\01\01\01\01\01\00\00\00\00\00\00\00\00"
    "\00\00\00\00\00\00\01\01\01\01\01\00\00\01\01\01" "\01\01\01\01\01\01\00\00\01\01\01\01\01\00\00\00" "\00\00\00\00\00\00\01\01\01\01\01\01\00\00\00\00" "\00\00\00\00\00\00\00\01\01\01\01\01\01\01\01\00" "\00\00\01\01\01\01\01\00\00\00\00\00\00\00\00\00"
    "\00\00\00\00\00\00\00\01\01\01\01\00\00\01\01\01" "\01\00\01\01\01\01\00\00\01\01\01\01\01\00\00\00" "\00\00\00\00\00\00\01\01\01\01\01\01\00\00\00\00" "\00\00\00\00\00\00\00\01\01\01\01\01\01\01\01\00" "\00\00\01\01\01\01\00\00\00\00\00\00\00\00\00\00"
    "\00\00\00\00\00\00\00\01\01\01\01\01\00\01\01\01" "\01\00\01\01\01\01\00\01\01\01\01\01\00\00\00\00" "\00\00\00\00\00\00\01\01\01\01\01\01\00\00\00\00" "\00\00\00\00\00\00\00\01\01\01\01\01\01\01\01\00" "\00\00\01\01\01\01\00\00\00\00\00\00\00\00\00\00"

    "\00\00\00\00\00\00\00\01\01\01\01\01\01\01\01\01" "\01\00\01\01\01\01\01\01\01\01\01\01\00\00\00\00" "\00\00\00\00\00\00\01\01\01\01\01\01\00\00\00\00" "\00\00\00\00\00\00\00\01\01\01\01\00\01\01\01\01" "\00\01\01\01\01\00\00\00\00\00\00\00\00\00\00\00"
    "\00\00\00\00\00\00\00\01\01\01\01\01\01\01\01\01" "\00\00\00\01\01\01\01\01\01\01\01\01\00\00\00\00" "\00\00\00\00\00\00\01\01\01\01\01\01\00\00\00\00" "\00\00\00\00\00\00\00\01\01\01\01\00\01\01\01\01" "\00\01\01\01\01\00\00\00\00\00\00\00\00\00\00\00"
    "\00\00\00\00\00\00\00\01\01\01\01\01\01\01\01\01" "\00\00\00\01\01\01\01\01\01\01\01\01\00\00\00\00" "\00\00\00\00\00\00\01\01\01\01\01\01\00\00\00\00" "\00\00\00\00\00\00\01\01\01\01\01\00\01\01\01\01" "\00\01\01\01\01\00\00\00\00\00\00\00\00\00\00\00"
    "\00\00\00\00\00\00\00\00\01\01\01\01\01\01\01\01" "\00\00\00\01\01\01\01\01\01\01\01\00\00\00\00\00" "\00\00\00\00\00\00\01\01\01\01\01\01\00\00\00\00" "\00\00\00\00\00\00\01\01\01\01\01\00\00\01\01\01" "\01\01\01\01\00\00\00\00\00\00\00\00\00\00\00\00"
    "\00\00\00\00\00\00\00\00\01\01\01\01\01\01\01\01" "\00\00\00\00\01\01\01\01\01\01\01\00\00\00\00\00" "\00\00\00\00\00\00\01\01\01\01\01\01\00\00\00\00" "\00\00\00\00\00\00\01\01\01\01\01\00\00\01\01\01" "\01\01\01\01\00\00\00\00\00\00\00\00\00\00\00\00"
    "\00\00\00\00\00\00\00\00\01\01\01\01\01\01\01\00" "\00\00\00\00\01\01\01\01\01\01\01\00\00\00\00\00" "\00\00\00\01\01\01\01\01\01\01\01\01\01\01\01\00" "\00\00\00\00\00\00\01\01\01\01\01\00\00\01\01\01" "\01\01\01\01\00\00\00\00\00\00\00\00\00\00\00\00"
    "\00\00\00\00\00\00\00\00\01\01\01\01\01\01\01\00" "\00\00\00\00\01\01\01\01\01\01\01\00\00\00\00\00" "\00\00\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\00\00\00\00\00\00\01\01\01\01\01\00\00\01\01\01" "\01\01\01\01\00\00\00\00\00\00\00\00\00\00\00\00"
    "\00\00\00\00\00\00\00\00\00\01\01\01\01\01\01\00" "\00\00\00\00\01\01\01\01\01\01\00\00\00\00\00\00" "\00\00\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\00\00\00\00\00\00\01\01\01\01\01\00\00\00\01\01" "\01\01\01\00\00\00\00\00\00\00\00\00\00\00\00\00"
    "\00\00\00\00\00\00\00\00\00\01\01\01\01\01\00\00" "\00\00\00\00\00\01\01\01\01\01\00\00\00\00\00\00" "\00\00\01\01\01\01\01\01\01\01\01\01\01\01\01\01" "\00\00\00\00\00\00\01\01\01\01\01\00\00\00\01\01" "\01\01\01\00\00\00\00\00\00\00\00\00\00\00\00\00"
    "\00\00\00\00\00\00\00\00\00\00\01\01\01\00\00\00" "\00\00\00\00\00\00\01\01\01\00\00\00\00\00\00\00" "\00\00\00\01\01\01\01\01\01\01\01\01\01\01\01\00" "\00\00\00\00\00\00\00\01\01\01\00\00\00\00\00\01" "\01\01\00\00\00\00\00\00\00\00\00\00\00\00\00\00"
    "\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00" "\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00" "\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00" "\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00" "\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00"
    "\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00" "\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00" "\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00" "\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00" "\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00"
    "\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00" "\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00" "\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00" "\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00" "\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00"
    "\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00" "\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00" "\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00" "\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00" "\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00"
    "\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00" "\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00" "\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00" "\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00" "\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00"
    "\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00" "\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00" "\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00" "\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00" "\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00"
    ;; 141312 | maze_cleared_data_trophy = 9 bytes
    ;; 0 = false 1 = true
    "\00\00\00"
    "\00\00\00"
    "\00\00\00"
    ;; This portion of data is for maze maps
    ;; 00 = nothing
    ;; 01 = sweet rock
    ;; 02 = wasm block
    ;; 03 = key (red)
    ;; 04 = key (green)
    ;; 05 = key (blue)
    ;; 06 = lock (red)
    ;; 07 = lock (green)
    ;; 08 = lock (blue)
    ;; 09 = picked key (red)
    ;; 0A = picked key (green)
    ;; 0B = picked key (blue)
    ;; 0C = unlocked lock (red)
    ;; 0D = unlocked lock (green)
    ;; 0E = unlocked lock (blue)
  
    ;; 141321 | maze_000_20x20 = 400 bytes
    "\01" "\01" "\01" "\01" "\01" "\01" "\01" "\01" "\01" "\01"   "\01" "\01" "\01" "\01" "\01" "\01" "\01" "\01" "\01" "\01"
    "\01" "\00" "\00" "\00" "\00" "\00" "\00" "\00" "\00" "\01"   "\01" "\00" "\00" "\00" "\00" "\06" "\00" "\01" "\02" "\01"
    "\01" "\00" "\00" "\00" "\00" "\00" "\00" "\00" "\00" "\01"   "\01" "\00" "\00" "\00" "\00" "\01" "\00" "\01" "\00" "\01"
    "\01" "\00" "\00" "\00" "\00" "\00" "\00" "\00" "\00" "\01"   "\01" "\00" "\00" "\00" "\00" "\01" "\00" "\01" "\00" "\01"
    "\01" "\00" "\00" "\00" "\00" "\00" "\00" "\00" "\00" "\01"   "\01" "\00" "\00" "\00" "\00" "\01" "\00" "\01" "\00" "\01"
    "\01" "\00" "\00" "\00" "\00" "\00" "\00" "\00" "\00" "\01"   "\01" "\00" "\00" "\00" "\00" "\01" "\00" "\01" "\00" "\01"
    "\01" "\00" "\00" "\00" "\00" "\00" "\00" "\00" "\00" "\01"   "\01" "\00" "\00" "\00" "\00" "\01" "\00" "\01" "\00" "\01"
    "\01" "\00" "\00" "\00" "\00" "\00" "\00" "\00" "\00" "\01"   "\01" "\00" "\00" "\00" "\00" "\01" "\00" "\01" "\00" "\01"
    "\01" "\00" "\00" "\00" "\00" "\00" "\00" "\00" "\00" "\01"   "\01" "\00" "\00" "\00" "\00" "\01" "\00" "\01" "\00" "\01"
    "\01" "\00" "\00" "\00" "\00" "\00" "\00" "\00" "\00" "\01"   "\01" "\00" "\00" "\00" "\00" "\01" "\00" "\01" "\00" "\01"

    "\01" "\05" "\00" "\00" "\00" "\00" "\00" "\00" "\00" "\08"   "\00" "\00" "\00" "\00" "\00" "\01" "\00" "\00" "\00" "\01"
    "\01" "\01" "\01" "\01" "\01" "\01" "\01" "\01" "\01" "\01"   "\00" "\00" "\00" "\00" "\00" "\01" "\01" "\01" "\01" "\01"
    "\01" "\00" "\00" "\00" "\00" "\00" "\00" "\00" "\00" "\01"   "\00" "\00" "\00" "\00" "\00" "\00" "\00" "\00" "\00" "\01"
    "\01" "\01" "\00" "\00" "\01" "\01" "\00" "\00" "\00" "\01"   "\00" "\00" "\00" "\00" "\00" "\00" "\00" "\00" "\00" "\01"
    "\01" "\00" "\00" "\00" "\00" "\01" "\00" "\01" "\01" "\01"   "\00" "\00" "\00" "\00" "\00" "\00" "\00" "\00" "\00" "\01"
    "\01" "\00" "\00" "\00" "\00" "\01" "\00" "\01" "\00" "\07"   "\00" "\00" "\00" "\00" "\00" "\00" "\00" "\00" "\00" "\01"
    "\01" "\00" "\00" "\00" "\00" "\01" "\00" "\01" "\00" "\01"   "\00" "\00" "\00" "\00" "\00" "\00" "\00" "\00" "\00" "\01"
    "\01" "\00" "\00" "\00" "\00" "\01" "\00" "\01" "\00" "\01"   "\00" "\00" "\00" "\00" "\00" "\00" "\00" "\00" "\00" "\01"
    "\01" "\03" "\00" "\00" "\00" "\01" "\00" "\00" "\00" "\01"   "\00" "\00" "\00" "\00" "\00" "\00" "\00" "\00" "\04" "\01"
    "\01" "\01" "\01" "\01" "\01" "\01" "\01" "\01" "\01" "\01"   "\01" "\01" "\01" "\01" "\01" "\01" "\01" "\01" "\01" "\01"
    ;; 141721 | maze_001_20x20 = 400 bytes
    "\01" "\01" "\01" "\01" "\01" "\01" "\01" "\01" "\01" "\01"   "\01" "\01" "\01" "\01" "\01" "\01" "\01" "\01" "\01" "\01"
    "\01" "\02" "\00" "\00" "\01" "\05" "\00" "\00" "\00" "\01"   "\00" "\01" "\00" "\00" "\00" "\01" "\00" "\04" "\00" "\01"
    "\01" "\01" "\01" "\07" "\01" "\01" "\01" "\00" "\01" "\01"   "\00" "\01" "\00" "\01" "\00" "\01" "\00" "\00" "\00" "\01"
    "\01" "\00" "\00" "\00" "\00" "\00" "\00" "\00" "\00" "\00"   "\00" "\01" "\00" "\01" "\00" "\01" "\01" "\06" "\01" "\01"
    "\01" "\00" "\00" "\00" "\00" "\00" "\00" "\00" "\00" "\00"   "\00" "\01" "\00" "\01" "\00" "\01" "\00" "\00" "\00" "\01"
    "\01" "\00" "\00" "\00" "\00" "\00" "\00" "\00" "\00" "\00"   "\00" "\01" "\00" "\01" "\00" "\01" "\00" "\00" "\00" "\01"
    "\01" "\00" "\00" "\00" "\00" "\00" "\00" "\00" "\00" "\00"   "\00" "\00" "\00" "\01" "\00" "\01" "\00" "\00" "\00" "\01"
    "\01" "\00" "\00" "\00" "\00" "\00" "\00" "\00" "\00" "\00"   "\00" "\00" "\00" "\01" "\00" "\01" "\00" "\00" "\00" "\01"
    "\01" "\00" "\00" "\00" "\00" "\00" "\00" "\00" "\00" "\00"   "\00" "\01" "\00" "\01" "\00" "\00" "\00" "\00" "\00" "\01"
    "\01" "\00" "\00" "\00" "\00" "\00" "\00" "\00" "\00" "\00"   "\00" "\01" "\00" "\01" "\00" "\01" "\00" "\00" "\00" "\01"

    "\01" "\01" "\01" "\01" "\01" "\01" "\01" "\01" "\01" "\01"   "\01" "\01" "\01" "\01" "\00" "\01" "\00" "\00" "\00" "\01"
    "\01" "\00" "\00" "\01" "\00" "\00" "\00" "\00" "\00" "\00"   "\00" "\00" "\00" "\01" "\00" "\01" "\00" "\00" "\00" "\01"
    "\01" "\03" "\00" "\01" "\00" "\00" "\00" "\00" "\00" "\00"   "\00" "\00" "\00" "\01" "\00" "\01" "\00" "\00" "\00" "\01"
    "\01" "\00" "\00" "\08" "\00" "\00" "\00" "\00" "\00" "\00"   "\00" "\00" "\00" "\01" "\00" "\01" "\00" "\00" "\00" "\01"
    "\01" "\00" "\00" "\01" "\00" "\00" "\00" "\00" "\00" "\00"   "\00" "\00" "\00" "\01" "\00" "\01" "\00" "\00" "\00" "\01"
    "\01" "\01" "\01" "\01" "\00" "\00" "\00" "\00" "\00" "\00"   "\00" "\00" "\00" "\01" "\00" "\01" "\00" "\00" "\00" "\01"
    "\01" "\00" "\00" "\00" "\00" "\00" "\00" "\00" "\00" "\00"   "\00" "\00" "\00" "\01" "\00" "\01" "\00" "\00" "\00" "\01"
    "\01" "\00" "\00" "\00" "\00" "\00" "\00" "\00" "\00" "\00"   "\00" "\00" "\00" "\01" "\00" "\01" "\00" "\00" "\00" "\01"
    "\01" "\00" "\00" "\00" "\00" "\00" "\00" "\00" "\00" "\00"   "\00" "\00" "\00" "\00" "\00" "\01" "\00" "\00" "\00" "\01"
    "\01" "\01" "\01" "\01" "\01" "\01" "\01" "\01" "\01" "\01"   "\01" "\01" "\01" "\01" "\01" "\01" "\01" "\01" "\01" "\01"
    ;; 142121 | maze_002_20x20 = 400 bytes    
    "\01" "\01" "\01" "\01" "\01" "\01" "\01" "\01" "\01" "\01"   "\01" "\01" "\01" "\01" "\01" "\01" "\01" "\01" "\01" "\01"
    "\01" "\04" "\01" "\00" "\00" "\00" "\00" "\00" "\00" "\01"   "\01" "\00" "\00" "\00" "\00" "\00" "\00" "\07" "\03" "\01"
    "\01" "\08" "\01" "\00" "\00" "\00" "\00" "\01" "\00" "\01"   "\01" "\00" "\00" "\00" "\00" "\00" "\00" "\01" "\01" "\01"
    "\01" "\00" "\00" "\00" "\00" "\00" "\00" "\01" "\00" "\01"   "\01" "\00" "\00" "\00" "\00" "\00" "\00" "\00" "\00" "\01"
    "\01" "\00" "\00" "\00" "\00" "\00" "\00" "\01" "\00" "\01"   "\01" "\00" "\00" "\00" "\00" "\00" "\00" "\00" "\00" "\01"
    "\01" "\00" "\00" "\00" "\00" "\00" "\00" "\01" "\00" "\01"   "\01" "\00" "\00" "\00" "\00" "\00" "\00" "\00" "\00" "\01"
    "\01" "\00" "\00" "\00" "\00" "\00" "\00" "\01" "\00" "\01"   "\01" "\00" "\00" "\00" "\00" "\00" "\00" "\00" "\00" "\01"
    "\01" "\00" "\00" "\00" "\00" "\00" "\00" "\01" "\00" "\01"   "\01" "\01" "\01" "\01" "\01" "\01" "\01" "\01" "\00" "\01"
    "\01" "\00" "\00" "\00" "\00" "\00" "\00" "\01" "\00" "\00"   "\00" "\00" "\00" "\00" "\00" "\00" "\00" "\00" "\00" "\01"
    "\01" "\01" "\01" "\01" "\01" "\01" "\01" "\01" "\00" "\00"   "\00" "\00" "\01" "\01" "\01" "\01" "\01" "\01" "\01" "\01"

    "\01" "\01" "\01" "\01" "\01" "\01" "\01" "\01" "\00" "\00"   "\00" "\00" "\01" "\01" "\01" "\01" "\01" "\01" "\01" "\01"
    "\01" "\00" "\00" "\00" "\00" "\00" "\00" "\00" "\00" "\00"   "\00" "\00" "\01" "\00" "\00" "\00" "\00" "\00" "\00" "\01"
    "\01" "\00" "\01" "\01" "\01" "\01" "\01" "\01" "\01" "\01"   "\01" "\00" "\01" "\00" "\00" "\00" "\00" "\00" "\00" "\01"
    "\01" "\00" "\00" "\00" "\00" "\00" "\00" "\00" "\00" "\01"   "\01" "\00" "\01" "\00" "\00" "\00" "\00" "\00" "\00" "\01"
    "\01" "\00" "\00" "\00" "\00" "\00" "\00" "\00" "\00" "\01"   "\01" "\00" "\01" "\00" "\00" "\00" "\00" "\00" "\00" "\01"
    "\01" "\00" "\00" "\00" "\00" "\00" "\00" "\00" "\00" "\01"   "\01" "\00" "\01" "\00" "\00" "\00" "\00" "\00" "\00" "\01"
    "\01" "\00" "\00" "\00" "\00" "\00" "\00" "\00" "\00" "\01"   "\01" "\00" "\01" "\00" "\00" "\00" "\00" "\00" "\00" "\01"
    "\01" "\01" "\01" "\00" "\00" "\00" "\00" "\00" "\00" "\01"   "\01" "\00" "\01" "\00" "\00" "\00" "\00" "\01" "\00" "\01"
    "\01" "\02" "\06" "\00" "\00" "\00" "\00" "\00" "\00" "\01"   "\01" "\00" "\00" "\00" "\00" "\00" "\00" "\01" "\05" "\01"
    "\01" "\01" "\01" "\01" "\01" "\01" "\01" "\01" "\01" "\01"   "\01" "\01" "\01" "\01" "\01" "\01" "\01" "\01" "\01" "\01"
    ;; 142521 | maze_003_20x20 = 400 bytes
    "\01" "\01" "\01" "\01" "\01" "\01" "\01" "\01" "\01" "\01"   "\01" "\01" "\01" "\01" "\01" "\01" "\01" "\01" "\01" "\01"
    "\01" "\00" "\00" "\00" "\01" "\00" "\00" "\00" "\00" "\00"   "\00" "\03" "\01" "\00" "\00" "\00" "\00" "\00" "\00" "\01"
    "\01" "\00" "\01" "\00" "\01" "\00" "\01" "\00" "\00" "\01"   "\01" "\01" "\01" "\01" "\01" "\01" "\01" "\00" "\01" "\01"
    "\01" "\00" "\01" "\00" "\01" "\00" "\01" "\00" "\00" "\00"   "\00" "\00" "\00" "\00" "\00" "\00" "\00" "\00" "\00" "\01"
    "\01" "\00" "\01" "\00" "\01" "\00" "\01" "\01" "\01" "\01"   "\01" "\01" "\01" "\00" "\01" "\00" "\01" "\01" "\00" "\01"
    "\01" "\00" "\01" "\00" "\01" "\00" "\01" "\00" "\00" "\00"   "\00" "\00" "\00" "\00" "\01" "\00" "\00" "\01" "\00" "\01"
    "\01" "\00" "\01" "\00" "\01" "\00" "\01" "\00" "\00" "\00"   "\00" "\00" "\00" "\00" "\01" "\01" "\00" "\01" "\00" "\01"
    "\01" "\08" "\01" "\00" "\01" "\00" "\01" "\00" "\00" "\00"   "\00" "\00" "\00" "\00" "\01" "\00" "\00" "\01" "\00" "\01"
    "\01" "\02" "\01" "\00" "\01" "\00" "\01" "\00" "\00" "\00"   "\00" "\00" "\00" "\00" "\01" "\00" "\01" "\01" "\00" "\01"
    "\01" "\01" "\01" "\00" "\01" "\00" "\01" "\00" "\00" "\00"   "\00" "\00" "\01" "\01" "\01" "\00" "\01" "\01" "\01" "\01"

    "\01" "\00" "\00" "\00" "\00" "\00" "\01" "\00" "\00" "\00"   "\00" "\00" "\01" "\00" "\00" "\00" "\01" "\05" "\00" "\01"
    "\01" "\00" "\01" "\01" "\01" "\01" "\01" "\01" "\01" "\01"   "\01" "\01" "\01" "\00" "\01" "\01" "\01" "\01" "\07" "\01"
    "\01" "\00" "\00" "\00" "\00" "\00" "\00" "\00" "\00" "\00"   "\00" "\00" "\01" "\00" "\01" "\00" "\01" "\00" "\00" "\01"
    "\01" "\00" "\01" "\00" "\00" "\00" "\00" "\00" "\00" "\00"   "\01" "\00" "\01" "\00" "\01" "\00" "\01" "\00" "\01" "\01"
    "\01" "\01" "\01" "\01" "\00" "\01" "\01" "\01" "\01" "\00"   "\01" "\00" "\01" "\00" "\01" "\00" "\00" "\00" "\00" "\01"
    "\01" "\00" "\01" "\00" "\00" "\00" "\01" "\04" "\01" "\00"   "\00" "\01" "\01" "\00" "\01" "\00" "\01" "\01" "\00" "\01"
    "\01" "\00" "\00" "\00" "\00" "\00" "\01" "\00" "\01" "\01"   "\00" "\00" "\01" "\00" "\01" "\00" "\01" "\00" "\00" "\01"
    "\01" "\00" "\01" "\01" "\00" "\01" "\01" "\00" "\06" "\01"   "\01" "\00" "\01" "\00" "\01" "\00" "\01" "\01" "\01" "\01"
    "\01" "\00" "\01" "\00" "\00" "\00" "\01" "\01" "\00" "\00"   "\00" "\00" "\01" "\00" "\00" "\00" "\00" "\00" "\00" "\01"
    "\01" "\01" "\01" "\01" "\01" "\01" "\01" "\01" "\01" "\01"   "\01" "\01" "\01" "\01" "\01" "\01" "\01" "\01" "\01" "\01"
    ;; 142921 | maze_004_20x20 = 400 bytes
    "\01" "\01" "\01" "\01" "\01" "\01" "\01" "\01" "\01" "\01"   "\01" "\01" "\01" "\01" "\01" "\01" "\01" "\01" "\01" "\01"
    "\01" "\00" "\01" "\00" "\00" "\00" "\01" "\00" "\00" "\00"   "\00" "\01" "\00" "\00" "\00" "\00" "\00" "\00" "\00" "\01"
    "\01" "\00" "\01" "\00" "\01" "\00" "\01" "\00" "\01" "\01"   "\00" "\00" "\00" "\01" "\00" "\01" "\01" "\01" "\00" "\01"
    "\01" "\00" "\00" "\00" "\01" "\00" "\01" "\00" "\01" "\00"   "\00" "\01" "\00" "\00" "\00" "\01" "\00" "\00" "\00" "\01"
    "\01" "\01" "\01" "\01" "\01" "\00" "\01" "\00" "\01" "\01"   "\01" "\00" "\01" "\01" "\00" "\01" "\00" "\01" "\01" "\01"
    "\01" "\05" "\00" "\01" "\00" "\00" "\01" "\00" "\01" "\00"   "\00" "\00" "\00" "\00" "\00" "\01" "\00" "\00" "\00" "\01"
    "\01" "\00" "\00" "\01" "\00" "\01" "\01" "\00" "\01" "\00"   "\01" "\01" "\01" "\01" "\01" "\01" "\01" "\01" "\00" "\01"
    "\01" "\01" "\00" "\06" "\00" "\00" "\00" "\00" "\01" "\00"   "\00" "\00" "\01" "\00" "\00" "\00" "\00" "\01" "\00" "\01"
    "\01" "\02" "\01" "\01" "\01" "\00" "\01" "\01" "\01" "\00"   "\01" "\00" "\00" "\00" "\01" "\00" "\01" "\01" "\00" "\01"
    "\01" "\08" "\01" "\00" "\00" "\00" "\01" "\00" "\01" "\01"   "\01" "\01" "\01" "\01" "\01" "\01" "\01" "\01" "\00" "\01"

    "\01" "\00" "\01" "\00" "\01" "\01" "\00" "\00" "\00" "\00"   "\00" "\00" "\00" "\00" "\00" "\00" "\00" "\01" "\00" "\01"
    "\01" "\00" "\01" "\00" "\00" "\00" "\00" "\01" "\01" "\01"   "\01" "\01" "\01" "\00" "\01" "\01" "\01" "\01" "\00" "\01"
    "\01" "\00" "\01" "\01" "\01" "\01" "\00" "\01" "\00" "\01"   "\00" "\00" "\00" "\00" "\01" "\01" "\00" "\01" "\00" "\01"
    "\01" "\00" "\00" "\01" "\00" "\00" "\00" "\01" "\00" "\01"   "\00" "\01" "\01" "\01" "\00" "\00" "\00" "\01" "\00" "\01"
    "\01" "\00" "\00" "\01" "\00" "\01" "\01" "\01" "\00" "\01"   "\00" "\00" "\00" "\01" "\00" "\01" "\00" "\01" "\04" "\01"
    "\01" "\00" "\01" "\01" "\00" "\00" "\00" "\00" "\00" "\01"   "\01" "\01" "\00" "\01" "\00" "\01" "\00" "\01" "\01" "\01"
    "\01" "\00" "\00" "\01" "\01" "\01" "\01" "\01" "\00" "\01"   "\03" "\01" "\00" "\00" "\00" "\01" "\00" "\00" "\00" "\01"
    "\01" "\00" "\00" "\01" "\00" "\00" "\00" "\01" "\00" "\01"   "\00" "\01" "\01" "\01" "\01" "\01" "\07" "\01" "\01" "\01"
    "\01" "\01" "\00" "\00" "\00" "\01" "\00" "\00" "\00" "\01"   "\00" "\00" "\00" "\00" "\00" "\00" "\00" "\00" "\00" "\01"
    "\01" "\01" "\01" "\01" "\01" "\01" "\01" "\01" "\01" "\01"   "\01" "\01" "\01" "\01" "\01" "\01" "\01" "\01" "\01" "\01"
    ;; 143321 | maze_005_20x20 = 400 bytes
    "\01" "\01" "\01" "\01" "\01" "\01" "\01" "\01" "\01" "\01"   "\01" "\01" "\01" "\01" "\01" "\01" "\01" "\01" "\01" "\01"
    "\01" "\01" "\00" "\01" "\01" "\00" "\01" "\01" "\03" "\01"   "\01" "\00" "\01" "\01" "\00" "\01" "\01" "\00" "\01" "\01"
    "\01" "\00" "\00" "\00" "\00" "\00" "\00" "\00" "\00" "\01"   "\00" "\00" "\00" "\00" "\00" "\00" "\00" "\00" "\00" "\01"
    "\01" "\01" "\00" "\01" "\01" "\00" "\01" "\01" "\01" "\01"   "\01" "\00" "\01" "\01" "\00" "\01" "\01" "\01" "\01" "\01"
    "\01" "\01" "\08" "\01" "\01" "\01" "\01" "\01" "\00" "\01"   "\01" "\00" "\01" "\01" "\01" "\01" "\01" "\00" "\01" "\01"
    "\01" "\00" "\00" "\00" "\00" "\00" "\00" "\00" "\00" "\00"   "\00" "\00" "\00" "\00" "\00" "\00" "\00" "\00" "\00" "\01"
    "\01" "\01" "\00" "\01" "\01" "\00" "\01" "\01" "\00" "\01"   "\01" "\00" "\01" "\01" "\00" "\01" "\01" "\00" "\01" "\01"
    "\01" "\01" "\00" "\01" "\01" "\00" "\01" "\01" "\00" "\01"   "\01" "\00" "\01" "\01" "\00" "\01" "\01" "\00" "\01" "\01"
    "\01" "\00" "\00" "\00" "\00" "\00" "\00" "\00" "\00" "\00"   "\00" "\00" "\01" "\00" "\00" "\00" "\00" "\00" "\00" "\01"
    "\01" "\01" "\00" "\01" "\01" "\00" "\01" "\01" "\00" "\01"   "\01" "\00" "\01" "\01" "\00" "\01" "\01" "\00" "\01" "\01"

    "\01" "\00" "\00" "\00" "\00" "\00" "\00" "\00" "\00" "\01"   "\01" "\00" "\01" "\01" "\00" "\01" "\01" "\00" "\01" "\01"
    "\01" "\00" "\01" "\01" "\01" "\01" "\01" "\01" "\00" "\00"   "\01" "\00" "\00" "\00" "\00" "\00" "\00" "\00" "\00" "\01"
    "\01" "\00" "\01" "\01" "\00" "\00" "\00" "\01" "\01" "\01"   "\01" "\00" "\01" "\01" "\00" "\01" "\01" "\06" "\01" "\01"
    "\01" "\00" "\01" "\01" "\00" "\02" "\00" "\01" "\00" "\01"   "\01" "\01" "\01" "\01" "\00" "\01" "\01" "\00" "\01" "\01"
    "\01" "\00" "\01" "\01" "\00" "\00" "\00" "\01" "\00" "\00"   "\00" "\00" "\00" "\00" "\00" "\01" "\00" "\00" "\00" "\01"
    "\01" "\00" "\01" "\01" "\01" "\07" "\01" "\01" "\00" "\01"   "\01" "\01" "\01" "\01" "\00" "\01" "\01" "\00" "\01" "\01"
    "\01" "\00" "\01" "\01" "\01" "\00" "\01" "\01" "\00" "\01"   "\01" "\00" "\01" "\01" "\00" "\01" "\01" "\00" "\01" "\01"
    "\01" "\00" "\01" "\00" "\00" "\00" "\00" "\00" "\00" "\00"   "\01" "\00" "\00" "\00" "\00" "\01" "\00" "\00" "\00" "\01"
    "\01" "\01" "\01" "\01" "\01" "\00" "\01" "\01" "\05" "\01"   "\01" "\00" "\01" "\01" "\00" "\01" "\01" "\04" "\01" "\01"
    "\01" "\01" "\01" "\01" "\01" "\01" "\01" "\01" "\01" "\01"   "\01" "\01" "\01" "\01" "\01" "\01" "\01" "\01" "\01" "\01"
    ;; 143721 | maze_006_20x20 = 400 bytes
    "\01" "\01" "\01" "\01" "\01" "\01" "\01" "\01" "\01" "\01"   "\01" "\01" "\01" "\01" "\01" "\01" "\01" "\01" "\01" "\01"
    "\01" "\00" "\00" "\00" "\00" "\00" "\00" "\01" "\00" "\00"   "\00" "\01" "\00" "\00" "\01" "\04" "\00" "\00" "\00" "\01"
    "\01" "\01" "\01" "\01" "\00" "\01" "\01" "\01" "\00" "\01"   "\00" "\00" "\00" "\01" "\01" "\01" "\01" "\01" "\00" "\01"
    "\01" "\00" "\00" "\00" "\00" "\01" "\00" "\00" "\00" "\01"   "\00" "\01" "\00" "\00" "\01" "\00" "\00" "\01" "\00" "\01"
    "\01" "\00" "\01" "\01" "\01" "\01" "\00" "\01" "\00" "\01"   "\00" "\01" "\01" "\00" "\01" "\00" "\01" "\01" "\00" "\01"
    "\01" "\00" "\00" "\00" "\00" "\01" "\00" "\01" "\01" "\01"   "\00" "\01" "\00" "\00" "\00" "\00" "\01" "\00" "\00" "\01"
    "\01" "\01" "\01" "\01" "\00" "\00" "\00" "\01" "\03" "\01"   "\00" "\01" "\00" "\01" "\00" "\00" "\01" "\00" "\01" "\01"
    "\01" "\00" "\05" "\01" "\07" "\01" "\01" "\01" "\00" "\01"   "\00" "\00" "\01" "\01" "\01" "\00" "\00" "\00" "\00" "\01"
    "\01" "\00" "\01" "\00" "\00" "\00" "\00" "\00" "\00" "\01"   "\01" "\00" "\00" "\01" "\00" "\01" "\01" "\01" "\01" "\01"
    "\01" "\00" "\01" "\00" "\01" "\01" "\01" "\01" "\01" "\01"   "\00" "\00" "\00" "\00" "\00" "\00" "\00" "\00" "\00" "\01"

    "\01" "\00" "\01" "\01" "\00" "\00" "\01" "\00" "\00" "\00"   "\01" "\01" "\01" "\01" "\01" "\01" "\01" "\01" "\06" "\01"
    "\01" "\00" "\00" "\01" "\00" "\00" "\00" "\00" "\01" "\00"   "\01" "\00" "\00" "\00" "\00" "\00" "\00" "\01" "\00" "\01"
    "\01" "\00" "\00" "\01" "\00" "\00" "\00" "\01" "\01" "\00"   "\01" "\00" "\01" "\01" "\08" "\01" "\01" "\01" "\00" "\01"
    "\01" "\01" "\00" "\01" "\00" "\01" "\00" "\00" "\01" "\00"   "\01" "\00" "\01" "\01" "\02" "\01" "\00" "\00" "\00" "\01"
    "\01" "\00" "\00" "\01" "\01" "\01" "\01" "\00" "\01" "\00"   "\01" "\00" "\01" "\01" "\01" "\01" "\00" "\01" "\00" "\01"
    "\01" "\00" "\01" "\01" "\00" "\01" "\00" "\00" "\01" "\00"   "\01" "\00" "\00" "\00" "\00" "\01" "\00" "\01" "\00" "\01"
    "\01" "\00" "\01" "\00" "\00" "\00" "\01" "\00" "\01" "\00"   "\01" "\00" "\01" "\00" "\00" "\01" "\00" "\01" "\00" "\01"
    "\01" "\00" "\01" "\00" "\01" "\00" "\01" "\00" "\01" "\00"   "\01" "\00" "\01" "\01" "\01" "\01" "\01" "\01" "\00" "\01"
    "\01" "\00" "\00" "\00" "\01" "\00" "\00" "\00" "\01" "\00"   "\00" "\00" "\00" "\00" "\00" "\00" "\00" "\00" "\00" "\01"
    "\01" "\01" "\01" "\01" "\01" "\01" "\01" "\01" "\01" "\01"   "\01" "\01" "\01" "\01" "\01" "\01" "\01" "\01" "\01" "\01"
    ;; 144121 | maze_007_20x20 = 400 bytes
    "\01" "\01" "\01" "\01" "\01" "\01" "\01" "\01" "\01" "\01"   "\01" "\01" "\01" "\01" "\01" "\01" "\01" "\01" "\01" "\01"
    "\01" "\00" "\00" "\00" "\00" "\01" "\03" "\01" "\00" "\00"   "\00" "\00" "\00" "\00" "\00" "\01" "\00" "\06" "\00" "\01"
    "\01" "\00" "\01" "\01" "\00" "\01" "\00" "\01" "\00" "\01"   "\01" "\01" "\01" "\01" "\00" "\01" "\00" "\01" "\00" "\01"
    "\01" "\00" "\01" "\00" "\00" "\07" "\00" "\01" "\00" "\00"   "\00" "\00" "\00" "\01" "\00" "\00" "\00" "\01" "\00" "\01"
    "\01" "\00" "\01" "\00" "\01" "\01" "\01" "\01" "\01" "\01"   "\01" "\01" "\00" "\01" "\01" "\01" "\01" "\01" "\00" "\01"
    "\01" "\00" "\01" "\00" "\00" "\00" "\00" "\00" "\00" "\00"   "\00" "\01" "\00" "\00" "\02" "\01" "\05" "\01" "\00" "\01"
    "\01" "\00" "\01" "\01" "\01" "\01" "\01" "\01" "\01" "\01"   "\00" "\01" "\01" "\01" "\01" "\01" "\00" "\01" "\00" "\01"
    "\01" "\00" "\00" "\00" "\00" "\01" "\00" "\00" "\00" "\01"   "\00" "\00" "\00" "\01" "\00" "\00" "\00" "\01" "\00" "\01"
    "\01" "\01" "\01" "\01" "\00" "\01" "\00" "\01" "\01" "\01"   "\01" "\01" "\00" "\01" "\00" "\01" "\01" "\01" "\00" "\01"
    "\01" "\00" "\00" "\00" "\00" "\01" "\00" "\00" "\00" "\00"   "\00" "\00" "\00" "\01" "\00" "\00" "\00" "\00" "\00" "\01"

    "\01" "\00" "\01" "\01" "\01" "\01" "\01" "\01" "\00" "\01"   "\01" "\01" "\01" "\01" "\01" "\01" "\01" "\01" "\00" "\01"
    "\01" "\00" "\00" "\00" "\00" "\00" "\00" "\00" "\00" "\01"   "\00" "\00" "\00" "\00" "\00" "\00" "\00" "\01" "\00" "\01"
    "\01" "\01" "\01" "\01" "\01" "\01" "\01" "\01" "\00" "\01"   "\00" "\01" "\01" "\01" "\01" "\01" "\00" "\01" "\00" "\01"
    "\01" "\00" "\00" "\00" "\00" "\01" "\00" "\00" "\00" "\00"   "\00" "\00" "\00" "\01" "\00" "\00" "\00" "\01" "\00" "\01"
    "\01" "\01" "\01" "\01" "\00" "\01" "\00" "\01" "\01" "\01"   "\01" "\01" "\00" "\01" "\00" "\01" "\01" "\01" "\00" "\01"
    "\01" "\00" "\00" "\00" "\00" "\01" "\00" "\00" "\00" "\01"   "\00" "\00" "\00" "\01" "\00" "\00" "\00" "\01" "\00" "\01"
    "\01" "\00" "\01" "\01" "\01" "\01" "\01" "\01" "\00" "\01"   "\00" "\01" "\01" "\01" "\01" "\01" "\00" "\01" "\00" "\01"
    "\01" "\00" "\00" "\00" "\00" "\00" "\00" "\00" "\00" "\01"   "\00" "\00" "\08" "\00" "\00" "\01" "\00" "\00" "\00" "\01"
    "\01" "\01" "\01" "\01" "\01" "\01" "\00" "\01" "\01" "\01"   "\01" "\01" "\04" "\01" "\01" "\01" "\01" "\01" "\00" "\01"
    "\01" "\01" "\01" "\01" "\01" "\01" "\01" "\01" "\01" "\01"   "\01" "\01" "\01" "\01" "\01" "\01" "\01" "\01" "\01" "\01"    
    ;; 144521 | maze_008_20x20 = 400 bytes
    "\01" "\01" "\01" "\01" "\01" "\01" "\01" "\01" "\01" "\01"   "\01" "\01" "\01" "\01" "\01" "\01" "\01" "\01" "\01" "\01"
    "\01" "\00" "\03" "\04" "\05" "\06" "\07" "\08" "\02" "\01"   "\00" "\00" "\00" "\00" "\00" "\00" "\00" "\00" "\00" "\01"
    "\01" "\00" "\01" "\01" "\01" "\01" "\01" "\01" "\01" "\01"   "\00" "\00" "\00" "\00" "\00" "\00" "\00" "\00" "\00" "\01"
    "\01" "\00" "\00" "\00" "\00" "\00" "\00" "\00" "\00" "\00"   "\00" "\00" "\00" "\00" "\00" "\00" "\00" "\00" "\00" "\01"
    "\01" "\00" "\00" "\00" "\00" "\00" "\00" "\00" "\00" "\00"   "\00" "\00" "\00" "\00" "\00" "\00" "\00" "\00" "\00" "\01"
    "\01" "\00" "\00" "\00" "\00" "\00" "\00" "\00" "\00" "\00"   "\00" "\00" "\00" "\00" "\00" "\00" "\00" "\00" "\00" "\01"
    "\01" "\00" "\00" "\00" "\00" "\00" "\00" "\00" "\00" "\00"   "\00" "\00" "\00" "\00" "\00" "\00" "\00" "\00" "\00" "\01"
    "\01" "\00" "\00" "\00" "\00" "\00" "\00" "\00" "\00" "\00"   "\00" "\00" "\00" "\00" "\00" "\00" "\00" "\00" "\00" "\01"
    "\01" "\00" "\00" "\00" "\00" "\00" "\00" "\00" "\00" "\00"   "\00" "\00" "\00" "\00" "\00" "\00" "\00" "\00" "\00" "\01"
    "\01" "\00" "\00" "\00" "\00" "\00" "\00" "\00" "\00" "\00"   "\00" "\00" "\00" "\00" "\00" "\00" "\00" "\00" "\00" "\01"

    "\01" "\00" "\00" "\00" "\00" "\00" "\00" "\00" "\00" "\00"   "\00" "\00" "\00" "\00" "\00" "\00" "\00" "\00" "\00" "\01"
    "\01" "\00" "\00" "\00" "\00" "\00" "\00" "\00" "\00" "\00"   "\00" "\00" "\00" "\00" "\00" "\00" "\00" "\00" "\00" "\01"
    "\01" "\00" "\00" "\00" "\00" "\00" "\00" "\00" "\00" "\00"   "\00" "\00" "\00" "\00" "\00" "\00" "\00" "\00" "\00" "\01"
    "\01" "\00" "\00" "\00" "\00" "\00" "\00" "\00" "\00" "\00"   "\00" "\00" "\00" "\00" "\00" "\00" "\00" "\00" "\00" "\01"
    "\01" "\00" "\00" "\00" "\00" "\00" "\00" "\00" "\00" "\00"   "\00" "\00" "\00" "\00" "\00" "\00" "\00" "\00" "\00" "\01"
    "\01" "\00" "\00" "\00" "\00" "\00" "\00" "\00" "\00" "\00"   "\00" "\00" "\00" "\00" "\00" "\00" "\00" "\00" "\00" "\01"
    "\01" "\00" "\00" "\00" "\00" "\00" "\00" "\00" "\00" "\00"   "\00" "\00" "\00" "\00" "\00" "\00" "\00" "\00" "\00" "\01"
    "\01" "\00" "\00" "\00" "\00" "\00" "\00" "\00" "\00" "\00"   "\00" "\00" "\00" "\00" "\00" "\00" "\00" "\00" "\00" "\01"
    "\01" "\00" "\00" "\00" "\00" "\00" "\00" "\00" "\00" "\00"   "\00" "\00" "\00" "\00" "\00" "\00" "\00" "\00" "\00" "\01"
    "\01" "\01" "\01" "\01" "\01" "\01" "\01" "\01" "\01" "\01"   "\01" "\01" "\01" "\01" "\01" "\01" "\01" "\01" "\01" "\01"
    ;; 144921
    ;; data_notes = 16 bytes
    "\06\01" ;; 262 = DO C4 (Middle C)
    "\26\01" ;; 294 = RE D4
    "\4A\01" ;; 330 = MI E4
    "\5D\01" ;; 349 = FA F4
    "\88\01" ;; 392 = SO (Sol) G4
    "\B8\01" ;; 440 = LA A4
    "\EE\01" ;; 494 = TI (Si) B4
    "\0B\02" ;; 523 = DO C5 (High C)
    ;; 144937 | color_mixer = 4 bytes
    "\00\00\00\FF"
    ;; 144941 | counter_256_up = 1 byte
    "\00"
    ;; 144942 | pointer_x and pointer_y = 2 bytes
    "\FF\FF"
    ;; 144944 | key obtain status (red, green, blue) = 3 bytes
    "\00\00\00"
    ;; 144947 | maze_maker_button_close_16x16 = 256 bytes
    "\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\01\01\01\01\01\01\01\01\01\01\00\00\00\00\00\01\01\01\01\01\01\01\01\01\01\01\01\00\00\00\01\01\01\01\01\01\01\01\01\01\01\01\01\01\00\00\01\01\01\02\02\01\01\01\01\02\02\01\01\01\00\00\01\01\01\02\02\02\01\01\02\02\02\01\01\01\00\00\01\01\01\01\02\02\02\02\02\02\01\01\01\01\00\00\01\01\01\01\01\02\02\02\02\01\01\01\01\01\00\00\01\01\01\01\01\02\02\02\02\01\01\01\01\01\00\00\01\01\01\01\02\02\02\02\02\02\01\01\01\01\00\00\01\01\01\02\02\02\01\01\02\02\02\01\01\01\00\00\01\01\01\02\02\01\01\01\01\02\02\01\01\01\00\00\01\01\01\01\01\01\01\01\01\01\01\01\01\01\00\00\00\01\01\01\01\01\01\01\01\01\01\01\01\00\00\00\00\00\01\01\01\01\01\01\01\01\01\01\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00"
    ;; 145203 | maze_maker_selected_indicator_16x16 | 256 bytes
    "\00\00\00\01\01\01\01\01\01\01\01\01\01\00\00\00\00\01\01\01\01\01\01\01\01\01\01\01\01\01\01\00\00\01\01\00\00\00\00\00\00\00\00\00\00\01\01\00\01\01\00\00\00\00\00\00\00\00\00\00\00\00\01\01\01\01\00\00\00\00\00\00\00\00\00\00\00\00\01\01\01\01\00\00\00\00\00\00\00\00\00\00\00\00\01\01\01\01\00\00\00\00\00\00\00\00\00\00\00\00\01\01\01\01\00\00\00\00\00\00\00\00\00\00\00\00\01\01\01\01\00\00\00\00\00\00\00\00\00\00\00\00\01\01\01\01\00\00\00\00\00\00\00\00\00\00\00\00\01\01\01\01\00\00\00\00\00\00\00\00\00\00\00\00\01\01\01\01\00\00\00\00\00\00\00\00\00\00\00\00\01\01\01\01\00\00\00\00\00\00\00\00\00\00\00\00\01\01\00\01\01\00\00\00\00\00\00\00\00\00\00\01\01\00\00\01\01\01\01\01\01\01\01\01\01\01\01\01\01\00\00\00\00\01\01\01\01\01\01\01\01\01\01\00\00\00"
    ;; 145459 | maze_maker_map_background_16x16 = 256 bytes
    "\01\01\01\01\01\01\01\01\02\02\02\02\02\02\02\02\01\01\01\01\01\01\01\01\02\02\02\02\02\02\02\02\01\01\01\01\01\01\01\01\02\02\02\02\02\02\02\02\01\01\01\01\01\01\01\01\02\02\02\02\02\02\02\02\01\01\01\01\01\01\01\01\02\02\02\02\02\02\02\02\01\01\01\01\01\01\01\01\02\02\02\02\02\02\02\02\01\01\01\01\01\01\01\01\02\02\02\02\02\02\02\02\01\01\01\01\01\01\01\01\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\02\01\01\01\01\01\01\01\01\02\02\02\02\02\02\02\02\01\01\01\01\01\01\01\01\02\02\02\02\02\02\02\02\01\01\01\01\01\01\01\01\02\02\02\02\02\02\02\02\01\01\01\01\01\01\01\01\02\02\02\02\02\02\02\02\01\01\01\01\01\01\01\01\02\02\02\02\02\02\02\02\01\01\01\01\01\01\01\01\02\02\02\02\02\02\02\02\01\01\01\01\01\01\01\01\02\02\02\02\02\02\02\02\01\01\01\01\01\01\01\01"
    ;; 145715 | heart_16x16x4 = 1024 bytes
    "\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\01\01\01\01\00\00\01\01\01\01\00\00\00\00\00\01\02\02\02\02\01\01\02\02\02\02\01\00\00\00\01\02\02\03\02\02\01\02\02\03\02\02\02\01\00\00\01\02\03\02\02\02\01\02\03\02\02\02\02\01\00\00\01\02\02\02\02\02\02\02\02\02\02\02\02\01\00\00\00\01\02\02\02\02\02\02\02\02\02\02\01\00\00\00\00\00\01\02\02\02\02\02\02\02\02\01\00\00\00\00\00\00\00\01\02\02\02\02\02\02\01\00\00\00\00\00\00\00\00\00\01\02\02\02\02\01\00\00\00\00\00\00\00\00\00\00\00\01\02\02\01\00\00\00\00\00\00\00\00\00\00\00\00\00\01\01\00\00\00\00\00\00\00\00\00\00\00\00\00\01\03\02\01\00\00\00\00\00\00\00\00\00\00\00\00\01\02\02\01\00\00\00\00\00\00\00\00\00\00\00\00\00\01\01\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\01\01\00\01\01\01\01\00\00\00\00\00\00\00\00\01\02\02\01\02\02\02\02\01\00\00\00\00\00\00\01\02\02\01\02\02\03\02\02\02\01\00\00\00\00\00\01\02\03\01\02\03\02\02\02\02\01\00\00\00\00\00\01\02\02\02\02\02\02\02\02\02\01\00\00\00\00\00\00\01\02\02\02\02\02\02\02\01\00\00\00\00\00\00\00\00\01\02\02\02\02\02\01\00\00\00\00\00\00\00\00\00\01\02\02\02\02\01\00\00\00\00\00\00\00\00\00\00\00\01\02\02\01\00\00\00\00\00\00\00\00\00\00\00\00\01\02\02\01\00\00\00\00\00\00\00\00\00\00\00\00\00\01\01\00\00\00\00\00\00\00\00\00\00\00\00\00\01\03\02\01\00\00\00\00\00\00\00\00\00\00\00\00\01\02\02\01\00\00\00\00\00\00\00\00\00\00\00\00\00\01\01\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\01\01\01\01\00\00\00\00\00\00\00\00\00\00\00\01\02\02\02\02\01\00\00\00\00\00\00\00\00\00\01\02\02\03\02\02\02\01\00\00\00\00\00\00\00\00\01\02\03\02\02\02\02\01\00\00\00\00\00\00\00\00\01\02\02\02\02\02\02\01\00\00\00\00\00\00\00\00\00\01\02\02\02\02\01\00\00\00\00\00\00\00\00\00\00\01\02\02\02\02\01\00\00\00\00\00\00\00\00\00\00\00\01\02\02\01\00\00\00\00\00\00\00\00\00\00\00\00\01\02\02\01\00\00\00\00\00\00\00\00\00\00\00\00\01\02\02\01\00\00\00\00\00\00\00\00\00\00\00\00\00\01\01\00\00\00\00\00\00\00\00\00\00\00\00\00\01\03\02\01\00\00\00\00\00\00\00\00\00\00\00\00\01\02\02\01\00\00\00\00\00\00\00\00\00\00\00\00\00\01\01\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\01\01\01\01\00\01\01\00\00\00\00\00\00\00\00\01\02\02\02\02\01\02\02\01\00\00\00\00\00\00\01\02\02\03\02\02\02\01\02\02\01\00\00\00\00\00\01\02\03\02\02\02\02\01\02\02\01\00\00\00\00\00\01\02\02\02\02\02\02\02\02\02\01\00\00\00\00\00\00\01\02\02\02\02\02\02\02\01\00\00\00\00\00\00\00\00\01\02\02\02\02\02\01\00\00\00\00\00\00\00\00\00\00\01\02\02\02\02\01\00\00\00\00\00\00\00\00\00\00\00\01\02\02\01\00\00\00\00\00\00\00\00\00\00\00\00\01\02\02\01\00\00\00\00\00\00\00\00\00\00\00\00\00\01\01\00\00\00\00\00\00\00\00\00\00\00\00\00\01\03\02\01\00\00\00\00\00\00\00\00\00\00\00\00\01\02\02\01\00\00\00\00\00\00\00\00\00\00\00\00\00\01\01\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00"
    ;; 146739 | test_sound = 4640
    "\49\44\33\04\00\00\00\00\00\22\54\53\53\45\00\00\00\0E\00\00\03\4C\61\76\66\36\31\2E\37\2E\31\30\30\00\00\00\00\00\00\00\00\00\00\00\FF\FB\50\C0\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\49\6E\66\6F\00\00\00\0F\00\00\00\15\00\00\11\F4\00\17\17\17\17\22\22\22\22\22\2E\2E\2E\2E\2E\3A\3A\3A\3A\3A\45\45\45\45\51\51\51\51\51\5D\5D\5D\5D\5D\68\68\68\68\68\74\74\74\74\7F\7F\7F\7F\7F\8B\8B\8B\8B\8B\97\97\97\97\97\A2\A2\A2\A2\AE\AE\AE\AE\AE\BA\BA\BA\BA\BA\C5\C5\C5\C5\C5\D1\D1\D1\D1\DD\DD\DD\DD\DD\E8\E8\E8\E8\E8\F4\F4\F4\F4\F4\FF\FF\FF\FF\00\00\00\00\4C\61\76\63\36\31\2E\31\39\00\00\00\00\00\00\00\00\00\00\00\00\24\02\40\00\00\00\00\00\00\11\F4\CA\FF\C6\79\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\00\FF\FB\50\C4\00\02\48\FD\70\DE\01\15\39\89\73\AA\A3\66\92\50\00\BB\2A\29\8A\2C\59\17\A2\BB\B3\D5\15\DB\D9\FF\EA\18\48\00\B8\81\D0\AE\45\63\A5\FF\FF\76\EA\66\14\3A\7A\BB\B7\F6\FD\24\54\2B\B3\B1\DD\BF\FF\FE\A8\51\E2\E2\87\27\FF\F7\67\EE\D0\FE\AD\25\51\1E\12\13\A9\74\D9\77\7F\64\46\48\18\32\40\83\11\BE\19\35\32\75\0C\23\04\C9\D4\C1\C0\10\00\1D\53\90\84\63\B9\08\D5\46\39\CE\30\38\7F\13\0F\9D\FA\4E\EC\26\00\01\03\84\9D\C3\84\F1\31\EC\7B\90\9C\84\A3\2A\00\29\EC\8C\26\F7\21\08\73\A3\49\D0\84\27\FD\64\FF\F5\7F\E8\42\11\BF\90\84\14\C1\08\80\3E\B1\07\07\CF\C8\35\4D\86\8A\00\0F\FF\D9\84\69\37\FF\9D\F2\E2\1F\D7\FF\BB\68\4E\39\1B\FF\FB\52\C4\0B\00\0C\FD\8B\4C\B9\88\80\00\7C\94\B2\77\12\F0\02\37\60\B9\41\96\3A\66\F0\B9\80\2F\C3\90\FB\E2\3C\1B\82\94\33\FF\C4\A0\3B\16\C2\B9\FB\BF\88\F0\1B\66\00\24\2D\3C\BA\52\FF\FC\70\0C\99\C2\70\E1\71\BF\FF\F3\32\6C\9F\22\08\31\7D\FF\FF\FF\AD\3A\90\41\F3\44\3F\FF\FF\FF\62\E1\70\D0\98\22\85\43\E0\06\61\EC\F6\EB\25\9F\FF\77\B7\25\ED\C0\60\30\00\F8\0E\89\7F\26\44\92\7C\D7\30\00\42\7E\F9\1C\92\45\DD\1C\74\B2\C4\6E\4F\D9\6D\C9\C1\B3\0E\2F\B3\8F\BB\6E\96\73\5D\47\D5\A9\9F\F3\FD\BF\BF\0E\97\74\AF\F6\FF\FF\37\FE\F2\C5\94\C8\E7\35\3A\94\23\03\01\8E\7F\C5\9E\46\2C\CF\FD\00\3E\74\08\60\4E\18\8E\C9\65\89\03\7D\32\15\A5\4C\96\FF\FB\52\C4\05\80\0B\DC\89\75\FC\F5\80\21\77\10\EE\3C\F3\15\A8\11\7E\5C\F0\5C\8E\57\CE\44\F8\80\94\C4\A5\00\3B\8E\F3\85\0E\F9\35\21\54\72\27\0D\78\38\75\04\D6\71\DA\FB\D8\A5\BB\AB\88\64\DD\FF\FF\71\01\41\59\D7\7D\22\10\80\C1\00\41\BB\5D\87\CC\2C\C8\CC\85\75\AF\7E\27\CD\B2\ED\CE\A3\E3\12\65\C4\D8\85\56\49\CA\00\DA\F9\10\C0\AA\80\97\51\6D\BB\A6\95\62\BA\42\99\92\51\52\34\57\AE\96\D3\93\27\C4\00\4D\49\81\06\3C\07\6D\99\EF\23\C4\56\3A\F3\5E\59\19\92\AA\9A\FF\50\10\05\15\BE\56\16\1C\A0\34\2A\63\3C\17\AB\C0\A9\52\5A\69\9E\A3\DA\11\7D\21\F6\25\BA\DE\D5\38\F3\01\A1\75\34\E1\B0\D8\27\24\95\9D\A8\8A\67\87\63\55\40\0B\18\76\5D\8C\FF\FB\52\C4\05\00\0B\98\81\6B\E7\8C\F2\C1\7B\AC\2C\35\84\A9\A1\17\E4\C8\D1\44\17\B5\84\E2\E5\2B\B5\1E\0F\6D\B4\38\C2\6C\9A\02\93\25\07\E8\E6\78\00\EC\14\2C\33\49\51\0B\37\CC\95\FF\F0\A0\15\D2\DC\51\8F\2E\84\93\05\C6\00\81\B1\76\B6\AE\8B\9E\1A\B8\57\5C\36\2A\C7\8B\C5\89\B8\5C\A3\36\53\36\C0\E4\51\A9\BA\B7\BE\49\BB\68\C4\80\40\01\A2\63\BB\06\BB\0F\2B\F7\14\DC\00\24\8A\BE\A5\B0\1D\13\06\96\36\74\A9\65\A4\B8\CB\85\46\A3\B0\AD\AD\BC\9D\21\C8\CB\36\D3\1B\EE\AF\88\00\02\06\C4\4C\E6\CE\7F\FF\B4\89\7D\8E\33\3A\6E\BA\18\AC\7B\77\E6\6D\DB\FF\FF\FF\BE\BF\F5\FD\11\00\75\1F\3C\F9\2F\CB\52\68\1E\F5\5F\95\72\44\03\00\A0\2A\59\14\9E\45\FF\FB\52\C4\05\00\0B\5C\7F\61\86\05\74\81\79\0E\ED\B8\F1\B2\94\2E\16\44\33\82\79\60\C4\AC\57\00\57\42\58\3B\59\36\53\75\26\C2\21\5C\AC\F2\7B\68\42\23\33\BC\F1\2A\57\62\5E\A8\1F\00\AC\F4\B2\25\5B\0E\38\46\D5\2D\02\82\96\D8\75\31\E2\7F\AD\7F\DD\75\6F\6C\FD\8B\3E\6C\00\E9\B3\85\03\27\24\71\CC\88\47\02\44\13\13\0C\B0\6E\60\9F\36\A6\28\1B\C9\E0\B1\21\CD\67\82\BD\AD\61\3B\3A\B1\C3\BF\3A\D3\F2\BF\8D\8F\48\45\E8\E0\9E\69\35\69\94\43\52\90\1B\D2\2F\6A\7E\72\9C\13\34\0D\21\F3\6A\1C\E4\A5\00\18\01\78\5C\68\F1\30\BA\02\15\01\B6\DD\0F\A9\7A\8F\ED\53\B5\5B\FF\4A\6A\0C\30\58\2C\BA\00\E7\33\0E\01\AA\6A\55\53\13\40\05\0B\FF\12\A4\F0\B9\FF\FB\52\C4\06\00\0B\80\73\65\C7\98\EC\C1\80\0F\6B\21\81\BE\88\B1\26\E5\66\3F\00\AB\1F\21\40\73\BB\E0\62\2A\61\36\45\8A\5A\24\70\BC\64\55\4B\D3\66\ED\AD\1E\E0\00\02\4A\CA\21\C1\A4\17\67\04\C2\49\99\40\60\68\44\71\23\C9\06\C3\A0\D9\63\E9\AC\49\41\A1\57\9B\DD\7B\D8\65\CA\18\F7\E7\16\CD\AE\79\23\C8\A7\E8\A6\80\00\01\54\34\8D\C1\BB\EA\35\22\E4\65\FB\96\C7\5D\9B\11\A8\DC\56\C5\0F\C9\32\DD\2C\A9\C2\24\28\F5\25\93\D9\A9\01\00\58\61\63\3C\60\FA\DD\FF\D5\ED\28\E0\08\A6\6B\C4\BC\33\00\93\4F\A4\59\82\78\A2\8E\B8\7D\C9\43\18\B8\64\11\53\3F\B5\F4\CF\13\73\51\D8\A7\DF\6D\AD\52\9F\7F\7C\4B\2C\D6\69\78\77\76\05\53\15\03\B7\6F\C9\A3\62\FF\FB\52\C4\06\00\0B\94\71\6D\E7\A4\E5\C1\82\90\6E\7C\F4\19\EC\61\8D\9C\BA\03\65\85\06\44\A1\D2\01\25\9A\32\46\AC\E0\8E\A3\35\03\E4\66\2E\AE\D7\9A\E8\C9\3B\FC\7C\17\8B\89\06\C2\D5\10\D8\70\A3\EC\6E\3C\DC\CD\8D\17\4E\87\52\2A\F5\B5\ED\00\E7\D3\0F\56\D1\F9\55\A9\25\D4\F8\66\8B\85\0C\1C\30\C3\48\30\9B\EA\65\44\C5\40\BB\00\5A\BC\8E\CC\0D\45\0B\71\E6\89\61\55\27\D3\4C\00\05\63\53\1D\D5\EA\F6\72\0C\21\29\10\CD\F4\AA\41\D5\57\77\32\B5\D7\CF\C1\00\10\46\95\3C\DB\E0\83\15\CB\83\43\4F\14\4B\FB\C1\6B\A8\97\26\D5\7D\26\00\CE\78\A8\50\00\C3\63\45\50\66\72\D9\AF\D4\4F\38\7C\58\9C\FB\C1\E9\04\24\84\7A\2A\87\98\75\24\54\47\03\B2\27\00\FF\FB\52\C4\05\00\00\00\73\6B\E6\60\F2\01\4B\0E\2C\70\F3\2A\80\E9\C4\23\B8\4A\D9\64\B4\41\1D\90\8E\93\13\AE\B5\D6\68\B3\97\43\3F\9B\C0\64\8E\CC\E9\5B\29\B7\DD\87\91\BC\C0\80\06\91\CB\9C\45\DA\DE\0E\8D\38\E1\02\21\F5\89\95\43\C2\34\56\B6\87\2F\67\F5\7A\7F\93\F4\D1\F7\FD\E8\77\78\CE\24\41\D4\9A\81\7D\5D\47\11\FC\87\B3\AB\8F\C8\EC\91\95\22\1E\94\21\65\86\2F\CC\5B\56\4B\D1\E9\BC\4B\99\C3\24\47\DC\AD\75\4E\C3\30\A6\04\12\CF\96\12\04\DA\51\06\91\00\25\14\D2\58\7B\85\AD\71\67\FD\7A\9D\F4\FF\FF\CA\15\40\A3\65\9D\AA\B7\6A\AE\73\46\83\40\01\CC\51\49\00\E2\48\C2\43\4E\65\6B\C4\FA\D3\C7\90\C2\44\62\99\6A\30\B2\67\21\00\A7\53\C8\1A\FF\FB\52\C4\11\80\00\FC\67\5F\87\99\AE\C1\2C\8C\6C\B4\C6\B2\88\03\0B\B4\E2\19\9B\57\59\98\F8\05\28\94\9E\2E\6C\8A\06\95\0F\8B\17\07\5B\04\5E\BE\A0\F8\A3\E5\0B\B8\A8\B1\6C\AB\FF\FF\6C\59\74\7F\FF\D1\27\F6\34\D0\00\39\24\94\0C\00\6D\16\42\71\70\72\0D\48\A7\28\7C\70\D9\75\A6\2A\84\ED\3E\F9\4A\67\4D\97\04\3D\3E\FD\9D\5D\0E\C0\31\F3\F9\25\31\51\AE\07\CE\1E\7C\70\0E\93\45\C3\9A\89\57\C6\7D\DB\3E\CE\CE\DF\EC\3C\F4\D5\A7\7B\AE\79\36\77\65\52\00\4C\96\D1\96\E3\45\72\DF\A9\F9\6D\47\16\9E\4B\41\95\F8\64\2C\30\F1\C9\5F\90\30\62\55\B7\B7\AB\47\46\BF\F5\68\46\05\10\17\D2\F2\CE\14\78\44\D0\BD\78\0C\BF\D8\FA\F1\05\96\34\5B\22\61\0F\45\FF\FB\52\C4\22\00\00\E4\5F\69\EC\0C\EE\81\35\0B\EE\F4\F4\8D\A2\69\FF\FE\D8\C8\A5\EB\9A\E9\E2\75\5B\75\AD\B8\93\0E\48\04\19\AB\25\39\B8\8E\42\D2\8A\25\84\E2\7D\4C\D6\D4\7A\89\02\46\18\6E\1C\A3\2D\DF\F9\38\26\B0\00\ED\E9\CA\5C\01\01\2F\2C\71\67\26\C1\61\A5\12\5C\0C\B1\2B\40\57\1C\10\8A\B0\5F\6A\E5\C0\57\7F\FF\FF\FF\6D\72\3D\31\F5\75\78\85\61\45\00\13\72\C9\44\A3\99\7F\5A\2A\82\65\33\F0\68\4E\3B\7C\CC\96\66\D9\FB\EB\0F\12\4A\D5\CB\5F\39\93\56\03\C6\8C\FE\97\25\02\9A\7B\D0\48\59\0C\48\D7\F0\F4\34\00\A2\AB\67\C4\01\D7\00\99\44\11\2E\C3\9D\5F\C9\A9\DA\E9\DD\36\F9\9B\BE\F7\5A\FA\5A\91\A4\00\00\28\04\0C\00\C6\C5\31\0D\A1\B2\72\FF\FB\52\C4\31\80\00\68\5D\69\E7\B0\E3\C1\49\8C\6B\70\C7\99\80\82\C6\8E\5D\6C\69\2F\A0\98\6C\41\1A\ED\E9\25\FA\AB\00\38\0C\02\19\0E\F8\F2\F2\76\1A\99\C5\C4\82\44\AA\00\15\14\22\DB\07\91\08\4D\B5\4A\19\BB\67\52\DA\BF\BE\84\FF\FF\B9\AD\82\F1\C2\CA\52\EA\4D\28\5C\B2\46\42\48\00\10\08\90\94\56\21\CC\4B\00\E8\13\42\55\31\E5\4C\A6\3B\02\00\D7\DD\69\E8\AD\F3\95\82\75\8A\EC\A7\B0\9D\89\46\E5\A8\AF\23\5E\F0\2F\BD\BD\8C\23\83\12\58\F0\A0\87\84\8D\00\A0\8D\85\48\D1\1C\30\B2\4D\FF\FF\A7\47\F6\7F\FA\29\A2\97\FF\AE\B9\AC\AD\90\10\AD\B8\29\24\66\47\B2\B2\2E\02\A1\10\DA\ED\98\46\2B\28\64\F9\02\04\76\C6\F1\5D\3E\29\F6\82\A0\42\60\B1\F8\FF\FB\52\C4\3C\80\00\18\71\59\87\B1\E5\C1\4C\10\2C\34\F4\AC\70\65\BD\9F\CE\1F\80\0C\9E\BC\A0\C7\33\D2\38\C5\06\9A\4F\15\D2\D1\B1\05\1F\AF\7D\DA\66\1E\D4\D6\FF\FF\D5\6C\9C\51\ED\4E\2A\6E\A6\A2\68\96\66\50\23\22\06\6D\C9\45\0B\9C\A7\6A\1E\B8\69\AB\14\35\4B\73\25\A6\F0\8B\B2\17\B8\F7\42\40\C5\59\90\C0\63\24\BF\FF\64\08\D2\1B\B4\77\A3\77\69\EC\3F\29\DA\5C\9B\CF\EA\A4\6F\E2\9B\D3\DE\4E\56\D1\05\E7\05\AA\66\F4\94\BD\4A\66\DA\28\A2\E7\FE\50\63\6D\4C\2B\8A\21\A8\0C\6C\48\2D\2A\51\71\26\E6\22\D3\B4\F0\D0\AA\02\00\82\36\1A\01\4D\10\62\49\25\B5\95\BD\DE\67\00\88\8E\41\A4\14\A2\D7\67\FE\64\33\C2\C8\22\0D\EB\82\B4\43\0B\A7\65\6A\51\FF\FB\52\C4\48\80\00\54\87\65\E7\85\70\C1\4A\8E\2C\BC\F3\44\F8\55\45\1D\CA\59\FF\EB\BC\9A\C7\7F\B8\DB\35\35\2B\6D\57\AD\1B\EA\69\9B\78\64\14\32\80\96\4B\05\4B\59\29\84\8D\3F\8F\34\EB\42\E4\32\1A\44\F2\87\58\15\80\E1\3C\D6\16\CD\66\30\8D\7A\BA\BB\81\D0\03\00\E4\FF\EC\87\11\01\91\0E\FF\1F\2C\3D\29\26\DB\5A\26\60\01\F2\5B\AA\45\F1\4C\87\8C\D0\F1\03\CD\C6\B5\16\D8\EF\B7\EB\F4\2C\B5\2B\31\01\A1\00\49\26\C5\2B\81\7C\3A\17\4C\2E\00\F7\8A\F4\7C\28\4B\88\98\CC\AF\51\D1\34\21\DC\E9\99\C2\85\E8\55\C0\DF\3F\EF\EB\F3\4E\00\FA\BF\16\1A\EB\85\6D\8A\C7\47\3F\5A\BF\AF\FA\6F\55\57\99\26\D5\73\D2\54\38\74\DA\6E\46\BC\65\A3\EA\44\74\84\55\FF\FB\52\C4\53\80\00\64\73\65\E7\A5\49\C1\3C\8E\EC\7C\F1\B2\00\01\10\40\4D\C1\03\75\9D\2C\D3\31\38\86\C6\C0\BB\A1\63\40\07\26\40\02\51\73\15\AD\93\9B\F3\FA\66\8B\CF\01\EC\39\2F\BA\08\E8\BD\92\32\06\D0\94\26\FC\99\1F\D3\1B\73\2C\DA\E0\13\BD\F5\ED\DF\59\76\7F\FD\C7\8E\B2\B3\36\33\DD\D3\76\D7\6B\23\84\65\30\99\58\2A\14\68\7A\79\23\3B\83\2B\D5\D3\7B\26\DF\45\54\F5\55\45\8F\33\52\5D\7E\CB\1A\97\6B\D7\D4\74\89\BF\F5\5E\3A\02\4E\27\D7\AB\CC\B9\84\14\AE\21\1C\A1\43\89\00\A8\CF\D9\FF\FF\93\79\C8\B2\43\A4\8A\A0\F8\A3\C2\64\5F\33\59\97\A7\77\24\36\18\4E\01\46\AA\61\36\69\1E\07\02\B1\70\90\4E\BC\4D\4A\9E\46\2B\E9\02\02\4D\40\D2\C9\FF\FB\52\C4\60\00\00\BC\7B\5D\E7\99\A9\81\40\0F\6E\30\FC\1D\CE\2D\A2\39\54\8A\84\64\64\5F\60\1C\0E\2A\E4\3E\BB\63\FD\CA\4F\47\E6\1F\BF\D9\7E\BC\E6\BC\4D\46\B3\0B\FF\FF\FF\D0\A3\6C\C0\27\21\B5\CC\B6\C7\ED\7E\CB\7D\04\C0\0F\18\AC\60\44\1C\48\4A\1E\C2\66\D4\2E\58\FB\02\3D\46\8A\BA\06\15\D4\EE\EB\21\E8\33\59\56\5B\1C\31\11\81\C8\5C\34\57\F3\8B\3E\A6\10\00\01\D0\2F\17\CF\B7\FF\FB\54\FD\55\FD\8D\2B\00\00\91\2B\3E\CA\E7\9F\45\4D\EF\FF\D9\C6\D2\E9\25\A8\C4\65\CB\25\A5\59\A9\BA\99\7A\6A\18\3B\5D\CA\59\0B\78\A9\7C\77\27\8B\91\DC\78\B3\29\18\5B\D5\AC\EA\B7\F3\50\D3\EC\23\8A\12\D9\1C\B6\10\4C\C5\4D\5B\31\29\A7\7F\38\7A\CD\37\FC\EE\FF\FB\52\C4\6F\00\00\00\81\61\E7\95\F2\C1\5B\19\6B\30\F4\B4\B8\80\BA\07\40\6C\B9\9F\FF\4F\63\3F\3F\65\44\5E\D3\8F\72\C6\8F\7B\5F\6F\D0\B2\96\04\4F\F1\71\62\D6\1A\73\25\63\0D\43\AB\04\C1\39\97\88\A7\AA\71\45\AD\85\6D\DC\7C\10\13\07\62\31\C5\CF\08\6D\00\B7\E4\36\21\15\01\01\B0\C5\08\FF\5D\00\21\32\BE\F4\CA\49\A0\FA\F4\37\53\FB\1D\9E\1E\22\C1\AA\0F\1E\75\D7\FB\72\1C\26\E0\18\C4\17\1C\68\26\82\D5\EA\FB\24\9A\AB\45\48\33\5D\D7\AB\E6\25\4C\98\36\CB\50\E4\C2\1B\59\3F\B9\80\EC\6B\F6\B5\8C\8B\1F\44\24\61\C3\DE\0B\1E\22\30\7D\62\8C\44\56\58\76\31\46\80\12\4B\83\21\4C\36\4B\A1\75\2E\C7\BA\26\E6\E8\49\89\69\50\42\57\53\A2\12\84\02\FF\FB\52\C4\79\00\0C\10\DF\65\E7\E1\4E\41\C2\1B\2B\BD\84\C1\38\53\73\C9\EE\1E\AB\8D\B3\11\3D\AF\A1\7A\D7\21\C5\17\6F\F4\8E\52\38\68\45\C3\FA\00\01\EF\A0\5C\41\4D\FD\96\9A\90\43\D7\41\4C\9B\57\6A\CD\E0\3A\04\FA\B2\DF\47\F4\3E\4D\2C\7E\BA\52\42\1E\B7\66\DB\EF\B7\F1\FC\F5\BD\66\5F\5D\FB\A6\75\F3\6F\0F\8F\3A\5E\53\C4\C2\92\DA\C0\BA\CC\44\3E\82\29\00\49\79\80\7C\49\84\A0\9C\4F\30\52\F0\E8\25\51\51\FD\12\8E\95\A4\2C\3D\E0\2A\03\90\35\68\84\A6\0E\00\AA\72\4F\FF\FE\1A\82\1D\4B\29\FF\FE\C7\91\1F\4B\5D\23\D2\27\48\7D\FB\5B\AC\6D\8B\2B\4A\5A\EB\75\3A\FA\7F\83\F7\07\22\36\0B\33\15\55\8C\33\E1\45\3B\39\2F\6C\AC\A1\D9\21\BC\73\2D\97\FF\FB\52\C4\6E\80\0E\34\D3\5B\E7\9A\0E\C9\7B\9D\EB\FC\F6\0C\78\46\B5\4A\21\3E\8C\8A\73\35\AC\AB\1C\54\4D\8F\21\42\7A\9E\4F\4B\34\2C\D7\3E\DF\55\AD\7C\6C\6F\D7\EA\B4\7D\39\CA\82\F9\D9\00\00\C2\12\63\91\99\84\9E\02\1F\CB\4C\66\AF\E9\74\7F\33\17\73\54\E8\F3\4E\8F\92\5D\3D\27\08\5D\FF\55\C3\28\A5\C9\6B\96\6C\D4\4C\97\28\65\61\B8\9A\24\00\78\55\4C\D8\85\9D\B0\92\8A\66\74\7C\B4\91\AF\31\15\AD\FA\7F\51\A8\A2\EA\45\34\5A\5B\75\C5\D4\BC\DF\50\C8\2E\02\A3\1C\9C\8C\AF\9B\CD\9F\49\93\B8\AB\21\43\A9\5C\93\FE\49\0E\46\9F\2F\2A\B3\9F\72\FC\AF\D7\35\CB\8B\96\7F\FC\CB\F2\FE\97\50\77\19\A0\32\C6\4A\6B\FD\EB\E9\EB\44\68\64\54\40\52\89\2D\FF\FB\52\C4\64\00\0C\4D\33\4D\67\84\5B\01\76\A7\69\10\F4\0E\00\B8\89\A3\00\F8\1D\D9\87\1A\D3\D0\EC\CA\23\D4\F2\88\8C\0F\37\7A\B8\A9\03\45\3E\03\60\D0\3B\07\CB\1E\FA\4F\4A\E4\4E\B2\95\D5\C6\F3\7A\56\91\F5\37\C5\F7\11\EA\87\DD\77\CE\D7\33\F5\F6\F1\CC\DB\35\F5\4F\DB\E9\DC\FC\57\55\F3\03\93\69\D6\96\4C\EA\78\88\76\C1\E1\F8\5D\4E\0D\07\D3\6D\CB\28\2A\28\49\23\F3\78\A0\01\EE\A8\49\A8\28\DA\FB\48\9C\C0\81\2E\E5\7C\E0\C4\42\00\CD\5F\42\D4\C8\61\A4\A2\61\E3\5E\36\8E\1E\91\1D\65\88\83\CD\A0\A7\D3\0C\CB\B5\04\87\2E\71\8B\65\C1\69\8A\AA\57\CC\D3\37\3F\FF\FE\9F\62\88\FD\EA\B1\E3\54\AD\6C\4C\7F\EF\3F\3B\8B\A8\AD\91\BB\02\B9\52\AB\8F\FF\FB\52\C4\62\00\0C\48\FF\51\F5\84\00\02\5D\A5\28\33\30\F0\00\96\0F\F1\9F\FB\52\C4\38\93\3C\89\B7\F5\8B\3B\ED\39\66\9B\FF\FF\FF\F0\1E\62\2C\1D\69\F4\6A\4B\1A\66\FA\EE\9B\7B\5C\CD\F2\A7\99\61\A0\45\CB\46\B4\7F\CA\7F\FC\54\C2\00\80\46\CC\C7\A8\50\16\1E\00\82\A0\A8\77\50\32\00\E1\D5\03\40\D1\EE\00\86\A5\41\50\54\16\0E\C4\A0\A9\E0\68\1A\0E\AC\15\0D\02\A0\AC\15\05\7E\25\3D\ED\A8\1A\3B\E5\41\50\54\15\06\9F\F8\8B\FC\A8\34\FE\22\06\83\A5\78\34\79\40\D0\35\3E\35\5F\6B\7F\55\D5\7C\28\00\52\66\58\6A\A1\9F\CB\98\43\71\10\AF\F9\57\3A\5F\F5\55\63\2A\AA\93\30\66\D8\D5\03\3F\FF\CE\83\5F\66\59\CD\06\83\BF\D6\00\9D\3B\96\92\CE\92\C4\A0\FF\FB\52\C4\43\02\89\7C\14\F4\BC\31\80\00\FA\98\18\04\30\8E\98\D0\77\5F\2C\EA\4C\41\4D\45\33\2E\31\30\30\AA\AA\AA\AA\AA\AA\AA\AA\AA\AA\AA\AA\AA\AA\AA\AA\AA\AA\AA\AA\AA\AA\AA\AA\AA\AA\AA\AA\AA\AA\AA\AA\AA\AA\AA\AA\AA\AA\AA\AA\AA\AA\AA\AA\AA\AA\AA\AA\AA\AA\AA\AA\AA\AA\AA\AA\AA\AA\AA\AA\AA\AA\AA\AA\AA\AA\AA\AA\AA\AA\AA\AA\AA\AA\AA\AA\AA\AA\AA\AA\AA\AA\AA\AA\AA\AA\AA\AA\AA\AA\AA\AA\AA\AA\AA\AA\AA\AA\AA\AA\AA\AA\AA\AA\AA\AA\AA\AA\AA\AA\AA\AA\AA\AA\AA\AA\AA\AA\AA\AA\AA\AA\AA\AA\AA\AA\AA\AA\AA\AA\AA\AA\AA\AA\AA\AA\AA\AA\AA\AA\AA\AA\AA\AA\AA\AA\AA\AA\AA\AA\AA\AA\AA\AA\AA\AA\AA\AA\AA\AA\AA\AA\AA\AA\AA\AA\AA\AA\AA\AA\AA\AA\AA\AA"
  )
)

