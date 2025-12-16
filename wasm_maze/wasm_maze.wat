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
    if
      i32.const 0xFF000080
      i32.const 0xFF0000FF
      i32.const 0xFF00FFFF
      return
    end
    i32.const 0xFF000000
    i32.const 0xFFF04F65
    i32.const 0xFFFFFFFF
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
        local.get $i
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
        call $render_sweet_rock
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
        local.get $i
        i32.const 0xFFFF0000
        i32.const 0xFFF04F65
        global.get $timer_60
        i32.const 29
        i32.lt_s
        select ;; color_01
        i32.const 0xFFFFFFFF ;; color_02
        i32.const 0x00000000 ;; color_03
        call $render_wasm_block
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

  (func $render_player
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

  (func $render_sweet_rock
    (param $i i32)
    (param $color_01 i32)
    (param $color_02 i32)
    (param $color_03 i32)
    (param $color_04 i32)
    (param $color_05 i32)
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
    local.get $color_01
    local.get $color_02
    local.get $color_03
    local.get $color_04 ;; color_04
    local.get $color_05 ;; color_05
    i32.const 129536    ;; data_address
    call $render_color_indexed_sprite
  )

  (func $render_wasm_block
    (param $i i32)
    (param $color_01 i32)
    (param $color_02 i32)
    (param $color_03 i32)
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
    local.get $color_01
    local.get $color_02
    local.get $color_03
    i32.const 0x00000000 ;; color_04
    i32.const 0x00000000 ;; color_05
    i32.const 132352     ;; data_address
    call $render_color_indexed_sprite
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
    call $render_player
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
    i32.const 0          ;; dx
    i32.const 0          ;; dy
    i32.const 16         ;; dw
    i32.const 16         ;; dh
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
    i32.const 56         ;; dx
    i32.const 8          ;; dy
    i32.const 16         ;; dw
    i32.const 16         ;; dh
    i32.const 0xFF000000 ;; color_01
    i32.const 0xFF00FF00 ;; color_02
    i32.const 0xFF000000 ;; color_03
    i32.const 0xFF000000 ;; color_04
    i32.const 0xFF000000 ;; color_05
    i32.const 128512     ;; memory_address
    call $render_color_indexed_sprite
    ;; down arrow
    i32.const 56         ;; dx
    i32.const 104        ;; dy
    i32.const 16         ;; dw
    i32.const 16         ;; dh
    i32.const 0xFF000000 ;; color_01
    i32.const 0xFF00FF00 ;; color_02
    i32.const 0xFF000000 ;; color_03
    i32.const 0xFF000000 ;; color_04
    i32.const 0xFF000000 ;; color_05
    i32.const 128768     ;; memory_address
    call $render_color_indexed_sprite
    ;; left arrow
    i32.const 8          ;; dx
    i32.const 56         ;; dy
    i32.const 16         ;; dw
    i32.const 16         ;; dh
    i32.const 0xFF000000 ;; color_01
    i32.const 0xFF00FF00 ;; color_02
    i32.const 0xFF000000 ;; color_03
    i32.const 0xFF000000 ;; color_04
    i32.const 0xFF000000 ;; color_05
    i32.const 129024     ;; memory_address
    call $render_color_indexed_sprite
    ;; right arrow
    i32.const 104        ;; dx
    i32.const 56         ;; dy
    i32.const 16         ;; dw
    i32.const 16         ;; dh
    i32.const 0xFF000000 ;; color_01
    i32.const 0xFF00FF00 ;; color_02
    i32.const 0xFF000000 ;; color_03
    i32.const 0xFF000000 ;; color_04
    i32.const 0xFF000000 ;; color_05
    i32.const 129280     ;; memory_address
    call $render_color_indexed_sprite
    ;; ???

    ;; sweet_rock
    i32.const 136        ;; dx
    i32.const 8          ;; dy
    i32.const 16         ;; dw
    i32.const 16         ;; dh
    i32.const 0xFF000000 ;; color_01
    i32.const 0xFFF5F5FF ;; color_02
    i32.const 0xFF0000FF ;; color_03
    i32.const 0xFFF04F65 ;; color_04
    i32.const 0xFF9CE1FF ;; color_05
    i32.const 129536     ;; memory_address
    call $render_color_indexed_sprite

    ;; player_idle
    i32.const 120        ;; dx
    i32.const 24         ;; dy
    i32.const 16         ;; dw
    i32.const 16         ;; dh
    i32.const 0xFF000000 ;; color_01
    i32.const 0xFFF04F65 ;; color_02
    i32.const 0xFFFFFFFF ;; color_03
    i32.const 0xFF0000FF ;; color_04
    i32.const 0x00000000 ;; color_05
    i32.const 130048     ;; memory_address
    call $render_color_indexed_sprite

    ;; wasm_block
    i32.const 136        ;; dx
    i32.const 24         ;; dy
    i32.const 16         ;; dw
    i32.const 16         ;; dh
    i32.const 0xFFF04F65 ;; color_01
    i32.const 0xFFF5F5FF ;; color_02
    i32.const 0xFFFFFFFF ;; color_03
    i32.const 0x00000000 ;; color_04
    i32.const 0x00000000 ;; color_05
    i32.const 132352     ;; memory_address
    call $render_color_indexed_sprite

    ;; key_red
    i32.const 120        ;; dx
    i32.const 80         ;; dy
    i32.const 16         ;; dw
    i32.const 16         ;; dh
    i32.const 0xFF0000FF ;; color_01
    i32.const 0xFFFFFFFF ;; color_02
    i32.const 0x00000000 ;; color_03
    i32.const 0x00000000 ;; color_04
    i32.const 0x00000000 ;; color_05
    i32.const 132608     ;; memory_address
    call $render_color_indexed_sprite

    ;; lock_red
    i32.const 136        ;; dx
    i32.const 80         ;; dy
    i32.const 16         ;; dw
    i32.const 16         ;; dh
    i32.const 0xFF0000FF ;; color_01
    i32.const 0xFF00FFFF ;; color_02
    i32.const 0x00000000 ;; color_03
    i32.const 0x00000000 ;; color_04
    i32.const 0x00000000 ;; color_05
    i32.const 132864     ;; memory_address
    call $render_color_indexed_sprite

    ;; key_green
    i32.const 120        ;; dx
    i32.const 96         ;; dy
    i32.const 16         ;; dw
    i32.const 16         ;; dh
    i32.const 0xFF008000 ;; color_01
    i32.const 0xFFFFFFFF ;; color_02
    i32.const 0x00000000 ;; color_03
    i32.const 0x00000000 ;; color_04
    i32.const 0x00000000 ;; color_05
    i32.const 132608     ;; memory_address
    call $render_color_indexed_sprite

    ;; lock_green
    i32.const 136        ;; dx
    i32.const 96         ;; dy
    i32.const 16         ;; dw
    i32.const 16         ;; dh
    i32.const 0xFF008000 ;; color_01
    i32.const 0xFF00FFFF ;; color_02
    i32.const 0x00000000 ;; color_03
    i32.const 0x00000000 ;; color_04
    i32.const 0x00000000 ;; color_05
    i32.const 132864     ;; memory_address
    call $render_color_indexed_sprite

    ;; key_blue
    i32.const 120        ;; dx
    i32.const 112        ;; dy
    i32.const 16         ;; dw
    i32.const 16         ;; dh
    i32.const 0xFFFF0000 ;; color_01
    i32.const 0xFFFFFFFF ;; color_02
    i32.const 0x00000000 ;; color_03
    i32.const 0x00000000 ;; color_04
    i32.const 0x00000000 ;; color_05
    i32.const 132608     ;; memory_address
    call $render_color_indexed_sprite

    ;; lock_blue
    i32.const 136        ;; dx
    i32.const 112        ;; dy
    i32.const 16         ;; dw
    i32.const 16         ;; dh
    i32.const 0xFFFF0000 ;; color_01
    i32.const 0xFF00FFFF ;; color_02
    i32.const 0x00000000 ;; color_03
    i32.const 0x00000000 ;; color_04
    i32.const 0x00000000 ;; color_05
    i32.const 132864     ;; memory_address
    call $render_color_indexed_sprite

    ;; maze_maker_play_button
    i32.const 8          ;; dx
    i32.const 136        ;; dy
    i32.const 40         ;; dw
    i32.const 16         ;; dh
    i32.const 0xFF808080 ;; color_01
    i32.const 0xFFFFFFFF ;; color_02
    i32.const 0x00000000 ;; color_03
    i32.const 0x00000000 ;; color_04
    i32.const 0x00000000 ;; color_05
    i32.const 133440     ;; memory_address
    call $render_color_indexed_sprite

    ;; maze_maker_load_button
    i32.const 60         ;; dx
    i32.const 136        ;; dy
    i32.const 40         ;; dw
    i32.const 16         ;; dh
    i32.const 0xFF808080 ;; color_01
    i32.const 0xFFFFFFFF ;; color_02
    i32.const 0x00000000 ;; color_03
    i32.const 0x00000000 ;; color_04
    i32.const 0x00000000 ;; color_05
    i32.const 134080     ;; memory_address
    call $render_color_indexed_sprite

    ;; maze_maker_share_button
    i32.const 112        ;; dx
    i32.const 136        ;; dy
    i32.const 40         ;; dw
    i32.const 16         ;; dh
    i32.const 0xFF808080 ;; color_01
    i32.const 0xFFFFFFFF ;; color_02
    i32.const 0x00000000 ;; color_03
    i32.const 0x00000000 ;; color_04
    i32.const 0x00000000 ;; color_05
    i32.const 134720     ;; memory_address
    call $render_color_indexed_sprite

    ;; todo: make a better way to show maze_maker_selected_indicator
    i32.const 136        ;; dx
    i32.const 8          ;; dy
    i32.const 16         ;; dw
    i32.const 16         ;; dh
    i32.const 0xFF0000FF
    i32.const 0xFF000080
    global.get $timer_60
    i32.const 29
    i32.lt_s
    select               ;; color_01
    i32.const 0x00000000 ;; color_02
    i32.const 0x00000000 ;; color_03
    i32.const 0x00000000 ;; color_04
    i32.const 0x00000000 ;; color_05
    i32.const 145203     ;; memory_address
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

  (data (i32.const 102400)
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
    ;; 146739 |    
  )
)

